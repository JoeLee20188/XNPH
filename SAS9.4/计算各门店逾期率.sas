%let today="01Nov2016"d;
%let mytoday=20161101;/*运行前要有当天的数据集*/
libname dat "E:\data";
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
depart region_name city branch_name city_center;
run;
/*连新的架构*/
/*连级别*/
data ziliao;
set dat.fig_jiagou;
keep CONTRACT_NO BUSINESS_UNIT_SOURCE REGION_AREA_ CITY_CENTER REGION_CITYY_ BRANCH_NAME;
run;
proc sql;
create table all as
select
      a.*,
      b.*
from all a 
left join ziliao b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;
data all;
set all;
loan_yue=loan_amount-(loan_amount/periods_num)*al_pay_period;
run;
/*区分M0-6+*/
data all_M;
set all;
if loan_yue<0 then loan_yue=0;
if 1  <=overdue_day<=30  then do interval="M1"; M1=loan_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=loan_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=loan_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=loan_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=loan_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=loan_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=loan_yue; end;
run;
/*计算逾期金额*/
proc sql;
create table Overdue_Money as
select
a.BRANCH_NAME,
round(sum(M1)/10000,1) as M1_sum,
round(sum(M2)/10000,1) as M2_sum,
round(sum(M3)/10000,1) as M3_sum,
round(sum(M4)/10000,1) as M4_sum,
round(sum(M5)/10000,1) as M5_sum,
round(sum(M6)/10000,1) as M6_sum,
round(sum(M6_plus)/10000,1) as M6_plus_sum,
round(sum(loan_amount)/10000,1) as fengmu
from all_M a
group by BRANCH_NAME;
quit;
/*空值标为0*/
data Overdue_Money;
set Overdue_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
run;
/*计算逾期率*/
proc sql;
create table city_Rate as
select
a.BRANCH_NAME,
round(M1_sum/(fengmu),0.001) as M1_Rate,
round(M2_sum/(fengmu),0.001) as M2_Rate,
round(M3_sum/(fengmu),0.001) as M3_Rate,
round(M4_sum/(fengmu),0.001) as M4_Rate,
round(M5_sum/(fengmu),0.001) as M5_Rate,
round(M6_sum/(fengmu),0.001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.001) as M6_plus_Rate,
round((M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum+M6_plus_sum)/(fengmu),0.001) as Total_Rate
from Overdue_Money a
group by BRANCH_NAME;
quit;
/*删除房贷*/
data city_Rate;
set city_Rate;
if city='房贷事业部' then delete;
run;
data Overdue_Money;
set Overdue_Money;
if city='房贷事业部' then delete;
run;
/*逾期金额和逾期率放在一起*/
proc sql;
create table connect as
select
b.*,
a.*
from Overdue_Money a
left join city_Rate b on a.city=b.city;
quit;
/*加一行普惠汇总*/
proc sql;
create table all as
select
'小牛普惠' as BRANCH_NAME,
round((sum(m1_sum)+sum(m2_sum)+sum(m3_sum)+sum(m4_sum)+sum(m5_sum)+sum(m6_sum)+sum(m6_plus_sum))/sum(fengmu),0.001) as total_rate,
round(sum(m1_sum)/sum(fengmu),0.001) as m1_rate,
round(sum(m2_sum)/sum(fengmu),0.001) as m2_rate,
round(sum(m3_sum)/sum(fengmu),0.001) as m3_rate,
round(sum(m4_sum)/sum(fengmu),0.001) as m4_rate,
round(sum(m5_sum)/sum(fengmu),0.001) as m5_rate,
round(sum(m6_sum)/sum(fengmu),0.001) as m6_rate,
round(sum(m6_plus_sum)/sum(fengmu),0.001) as m6_plus_rate,
sum(fengmu) as fengmu,
sum(m1_sum) as m1_sum,
sum(m2_sum) as m2_sum,
sum(m3_sum) as m3_sum,
sum(m4_sum) as m4_sum,
sum(m5_sum) as m5_sum,
sum(m6_sum) as m6_sum,
sum(m6_plus_sum) as m6_plus_sum
from overdue_money a;
quit;
/*把汇总加上*/
data connect;
set connect all;
run;
/*逾期率变为百分数*/
data connect;
set connect;
format M1_Rate M2_Rate M3_Rate M4_Rate M5_Rate M6_Rate M6_plus_Rate Total_Rate percent8.1;
M1_Rate1=trim(M1_Rate*100)||'%';M2_Rate1=trim(M2_Rate*100)||'%';M3_Rate1=trim(M3_Rate*100)||'%';M4_Rate1=trim(M4_Rate*100)||'%';M5_Rate1=trim(M5_Rate*100)||'%';M6_Rate1=trim(M6_Rate*100)||'%';M6_Plus_Rate1=trim(M6_Plus_Rate*100)||'%';total_Rate1=trim(total_Rate*100)||'%';
drop M1_Rate M2_Rate M3_Rate M4_Rate M5_Rate M6_Rate M6_plus_Rate Total_Rate;
rename M1_Rate1=M1_Rate M2_Rate1=M2_Rate M3_Rate1=M3_Rate M4_Rate1=M4_Rate M5_Rate1=M5_Rate M6_Rate1=M6_Rate M6_plus_Rate1=M6_plus_Rate Total_Rate1=Total_Rate;
run;
/*字段排序和保留*/
data connect;
set connect;
if city='互联网服务事业' then do; city1=input(city||'部',$16.);end;
if city^='互联网服务事业' then do;city1=city;end;
drop city;
rename city1=city;
run;
data overdue;
retain city total_rate m1_rate m2_rate m3_rate m4_rate m5_rate m6_rate m6_plus_rate fengmu m1_sum m2_sum m3_sum m4_sum m5_sum m6_sum m6_plus_sum;
set connect;
run;
/*输出到mysql*/
/*data echart_d.overdue;*/
/*set overdue;*/
/*run;*/
/*输出*/
PROC EXPORT DATA=city_rate OUTFILE="E:\echart_excel_to_mysql\城市逾期（剩余放款金额）数据.xlsx" DBMS=EXCEL replace;
RUN;
