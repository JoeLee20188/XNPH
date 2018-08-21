%let path=D:\basic_data;/*基础数据路径*/
%let mytoday=20161120;/*运行前要有当天的数据集*/
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%read_tablen(&path,ph_fast_table,每日快报,ph);/*总览*/
%read_tablen(&path,ph_fast_table_xw,每日快报,xw);/*小微贷*/
%read_tablen(&path,ph_fast_table_sn,每日快报,sn);/*三农贷*/
%read_tablen(&path,ph_fast_table_ns,每日快报,ns);/*农商贷*/
%read_tablen(&path,ph_fast_table_hlw,每日快报,hlw);/*互联网*/
data echart_d.fast_table;
set ph;
run;
data echart_d.fast_table_xw;
set xw;
run;
data echart_d.fast_table_sn;
set sn;
run;
data echart_d.fast_table_ns;
set ns;
run;
data echart_d.fast_table_hlw;
set hlw;
run;
/**********************************************************************************************************************************************/
/*********普惠*****************/
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;
/*区分M0-6+*/
data all_M;
set all;
if daishou_yue<0 then daishou_yue=0;
if 1  <=overdue_day<=30  then do interval="M1"; M1=daishou_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=daishou_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=daishou_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=daishou_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=daishou_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=daishou_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=daishou_yue; end;
run;
/*计算逾期金额*/
proc sql;
create table Overdue_Money as
select
a.depart,
round(sum(M1)/10000,1) as M1_sum,
round(sum(M2)/10000,1) as M2_sum,
round(sum(M3)/10000,1) as M3_sum,
round(sum(M4)/10000,1) as M4_sum,
round(sum(M5)/10000,1) as M5_sum,
round(sum(M6)/10000,1) as M6_sum,
round(sum(M6_plus)/10000,1) as M6_plus_sum,
round(sum(daishou_yue)/10000,1) as fengmu
from all_M a
group by depart;
quit;
/*空值标为0*/
data Overdue_Money;
set Overdue_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
run;
/*计算逾期率*/
proc sql;
create table Depart_Rate as
select
a.depart,
round(M1_sum/(fengmu),0.001) as M1_Rate,
round(M2_sum/(fengmu),0.001) as M2_Rate,
round(M3_sum/(fengmu),0.001) as M3_Rate,
round(M4_sum/(fengmu),0.001) as M4_Rate,
round(M5_sum/(fengmu),0.001) as M5_Rate,
round(M6_sum/(fengmu),0.001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.001) as M6_plus_Rate,
round((M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum+M6_plus_sum)/(fengmu),0.001) as Total_Rate
from Overdue_Money a
group by depart;
quit;
/*删除房贷*/
data Depart_Rate;
set Depart_Rate;
if depart='房贷事业部' then delete;
run;
data Overdue_Money;
set Overdue_Money;
if depart='房贷事业部' then delete;
run;
/*逾期金额和逾期率放在一起*/
proc sql;
create table connect as
select
b.*,
a.*
from Overdue_Money a
left join Depart_Rate b on a.depart=b.depart;
quit;
/*加一行普惠汇总*/
proc sql;
create table all as
select
'小牛普惠' as depart,
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
if depart='互联网服务事业' then do; depart1=input(depart||'部',$16.);end;
if depart^='互联网服务事业' then do;depart1=depart;end;
drop depart;
rename depart1=depart;
run;
data overdue;
retain depart total_rate m1_rate m2_rate m3_rate m4_rate m5_rate m6_rate m6_plus_rate fengmu m1_sum m2_sum m3_sum m4_sum m5_sum m6_sum m6_plus_sum;
set connect;
run;
/*输出到mysql*/
data echart_d.overdue;
set overdue;
run;
/**********小微贷****************/
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;
/*区分M0-6+*/
data all_M;
set all;
if daishou_yue<0 then daishou_yue=0;
if 1  <=overdue_day<=30  then do interval="M1"; M1=daishou_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=daishou_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=daishou_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=daishou_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=daishou_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=daishou_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=daishou_yue; end;
run;
/*计算逾期金额*/
proc sql;
create table Overdue_Money as
select
a.region_name,
round(sum(M1)/10000,1) as M1_sum,
round(sum(M2)/10000,1) as M2_sum,
round(sum(M3)/10000,1) as M3_sum,
round(sum(M4)/10000,1) as M4_sum,
round(sum(M5)/10000,1) as M5_sum,
round(sum(M6)/10000,1) as M6_sum,
round(sum(M6_plus)/10000,1) as M6_plus_sum,
round(sum(daishou_yue)/10000,1) as fengmu
from all_M a
where depart='小微贷事业部'
group by region_name;
quit;
/*空值标为0*/
data Overdue_Money;
set Overdue_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
if region_name='' or region_name='小微十二区' then delete;/*处理空值和十二区*/
run;
/*计算逾期率*/
proc sql;
create table Region_Rate as
select
a.region_name,
round(M1_sum/(fengmu),0.001) as M1_Rate,
round(M2_sum/(fengmu),0.001) as M2_Rate,
round(M3_sum/(fengmu),0.001) as M3_Rate,
round(M4_sum/(fengmu),0.001) as M4_Rate,
round(M5_sum/(fengmu),0.001) as M5_Rate,
round(M6_sum/(fengmu),0.001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.001) as M6_plus_Rate,
round((M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum+M6_plus_sum)/(fengmu),0.001) as Total_Rate
from Overdue_Money a
group by region_name;
quit;
/*逾期金额和逾期率放在一起*/
proc sql;
create table connect as
select
b.*,
a.*
from Overdue_Money a
left join Region_Rate b on a.region_name=b.region_name;
quit;
/*加一行小微贷汇总*/
proc sql;
create table all as
select
'小微贷汇总' as region_name,
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
/*排序*/
proc sort data=connect;
by descending fengmu;
run;
data overdue_xw;
retain region_name total_rate m1_rate m2_rate m3_rate m4_rate m5_rate m6_rate m6_plus_rate fengmu m1_sum m2_sum m3_sum m4_sum m5_sum m6_sum m6_plus_sum;
set connect;
run;
/*输出到mysql*/
data echart_d.overdue_xw;
set overdue_xw;
run;
/***********三农贷***************/
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;
/*区分M0-6+*/
data all_M;
set all;
if daishou_yue<0 then daishou_yue=0;
if 1  <=overdue_day<=30  then do interval="M1"; M1=daishou_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=daishou_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=daishou_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=daishou_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=daishou_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=daishou_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=daishou_yue; end;
run;
/*计算逾期金额*/
proc sql;
create table Overdue_Money as
select
a.region_name,
round(sum(M1)/10000,1) as M1_sum,
round(sum(M2)/10000,1) as M2_sum,
round(sum(M3)/10000,1) as M3_sum,
round(sum(M4)/10000,1) as M4_sum,
round(sum(M5)/10000,1) as M5_sum,
round(sum(M6)/10000,1) as M6_sum,
round(sum(M6_plus)/10000,1) as M6_plus_sum,
round(sum(daishou_yue)/10000,1) as fengmu
from all_M a
where depart='三农贷事业部'
group by region_name;
quit;
/*空值标为0*/
data Overdue_Money;
set Overdue_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
if region_name='' then delete;/*处理空值*/
run;
/*计算逾期率*/
proc sql;
create table Region_Rate as
select
a.region_name,
round(M1_sum/(fengmu),0.001) as M1_Rate,
round(M2_sum/(fengmu),0.001) as M2_Rate,
round(M3_sum/(fengmu),0.001) as M3_Rate,
round(M4_sum/(fengmu),0.001) as M4_Rate,
round(M5_sum/(fengmu),0.001) as M5_Rate,
round(M6_sum/(fengmu),0.001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.001) as M6_plus_Rate,
round((M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum+M6_plus_sum)/(fengmu),0.001) as Total_Rate
from Overdue_Money a
group by region_name;
quit;
/*逾期金额和逾期率放在一起*/
proc sql;
create table connect as
select
b.*,
a.*
from Overdue_Money a
left join Region_Rate b on a.region_name=b.region_name;
quit;
/*加一行三农贷汇总*/
proc sql;
create table all as
select
'三农贷汇总' as region_name,
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
/*排序*/
proc sort data=connect;
by descending fengmu;
run;
data overdue_sn;
retain region_name total_rate m1_rate m2_rate m3_rate m4_rate m5_rate m6_rate m6_plus_rate fengmu m1_sum m2_sum m3_sum m4_sum m5_sum m6_sum m6_plus_sum;
set connect;
run;
/*输出到mysql*/
data echart_d.overdue_sn;
set overdue_sn;
run;
/***********农商贷***************/
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;
/*区分M0-6+*/
data all_M;
set all;
if daishou_yue<0 then daishou_yue=0;
if 1  <=overdue_day<=30  then do interval="M1"; M1=daishou_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=daishou_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=daishou_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=daishou_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=daishou_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=daishou_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=daishou_yue; end;
run;
/*计算逾期金额*/
proc sql;
create table Overdue_Money as
select
a.region_name,
round(sum(M1)/10000,1) as M1_sum,
round(sum(M2)/10000,1) as M2_sum,
round(sum(M3)/10000,1) as M3_sum,
round(sum(M4)/10000,1) as M4_sum,
round(sum(M5)/10000,1) as M5_sum,
round(sum(M6)/10000,1) as M6_sum,
round(sum(M6_plus)/10000,1) as M6_plus_sum,
round(sum(daishou_yue)/10000,1) as fengmu
from all_M a
where depart='农商贷事业部'
group by region_name;
quit;
/*空值标为0*/
data Overdue_Money;
set Overdue_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
if region_name='' or region_name='华南区' then delete;/*处理空值*/
run;
/*计算逾期率*/
proc sql;
create table Region_Rate as
select
a.region_name,
round(M1_sum/(fengmu),0.001) as M1_Rate,
round(M2_sum/(fengmu),0.001) as M2_Rate,
round(M3_sum/(fengmu),0.001) as M3_Rate,
round(M4_sum/(fengmu),0.001) as M4_Rate,
round(M5_sum/(fengmu),0.001) as M5_Rate,
round(M6_sum/(fengmu),0.001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.001) as M6_plus_Rate,
round((M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum+M6_plus_sum)/(fengmu),0.001) as Total_Rate
from Overdue_Money a
group by region_name;
quit;
/*逾期金额和逾期率放在一起*/
proc sql;
create table connect as
select
b.*,
a.*
from Overdue_Money a
left join Region_Rate b on a.region_name=b.region_name;
quit;
/*加一行农商贷汇总*/
proc sql;
create table all as
select
'农商贷汇总' as region_name,
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
/*排序*/
proc sort data=connect;
by descending fengmu;
run;
data overdue_ns;
retain region_name total_rate m1_rate m2_rate m3_rate m4_rate m5_rate m6_rate m6_plus_rate fengmu m1_sum m2_sum m3_sum m4_sum m5_sum m6_sum m6_plus_sum;
set connect;
run;
/*输出到mysql*/
data echart_d.overdue_ns;
set overdue_ns;
run;
/***********互联网***************/
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;
/*区分M0-6+*/
data all_M;
set all;
if daishou_yue<0 then daishou_yue=0;
if 1  <=overdue_day<=30  then do interval="M1"; M1=daishou_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=daishou_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=daishou_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=daishou_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=daishou_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=daishou_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=daishou_yue; end;
run;
/*计算逾期金额*/
proc sql;
create table Overdue_Money as
select
a.region_name,
round(sum(M1)/10000,1) as M1_sum,
round(sum(M2)/10000,1) as M2_sum,
round(sum(M3)/10000,1) as M3_sum,
round(sum(M4)/10000,1) as M4_sum,
round(sum(M5)/10000,1) as M5_sum,
round(sum(M6)/10000,1) as M6_sum,
round(sum(M6_plus)/10000,1) as M6_plus_sum,
round(sum(daishou_yue)/10000,1) as fengmu
from all_M a
where depart='互联网服务事业'
group by region_name;
quit;
/*空值标为0*/
data Overdue_Money;
set Overdue_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
if region_name='' then delete;/*处理空值*/
run;
/*计算逾期率*/
proc sql;
create table Region_Rate as
select
a.region_name,
round(M1_sum/(fengmu),0.001) as M1_Rate,
round(M2_sum/(fengmu),0.001) as M2_Rate,
round(M3_sum/(fengmu),0.001) as M3_Rate,
round(M4_sum/(fengmu),0.001) as M4_Rate,
round(M5_sum/(fengmu),0.001) as M5_Rate,
round(M6_sum/(fengmu),0.001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.001) as M6_plus_Rate,
round((M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum+M6_plus_sum)/(fengmu),0.001) as Total_Rate
from Overdue_Money a
group by region_name;
quit;
/*逾期金额和逾期率放在一起*/
proc sql;
create table connect as
select
b.*,
a.*
from Overdue_Money a
left join Region_Rate b on a.region_name=b.region_name;
quit;
/*加一行互联网汇总*/
proc sql;
create table all as
select
'互联网汇总' as region_name,
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
/*排序*/
proc sort data=connect;
by descending fengmu;
run;
data overdue_hlw;
retain region_name total_rate m1_rate m2_rate m3_rate m4_rate m5_rate m6_rate m6_plus_rate fengmu m1_sum m2_sum m3_sum m4_sum m5_sum m6_sum m6_plus_sum;
set connect;
run;
/*输出到mysql*/
data echart_d.overdue_hlw;
set overdue_hlw;
run;
