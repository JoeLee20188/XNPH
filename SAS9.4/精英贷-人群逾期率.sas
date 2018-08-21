%let path=D:\basic_data;/*基础数据路径*/
%let today="19Sep2016"d;
%let mytoday=20160919;
%let yqday=&today.-30;
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%macro output_tablen(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xlsx" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_tablen;/*出表(2013版excel)宏*/
%read_tablen(&path,精英贷,导出工作表,aaa);
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;

proc sql;
create table all as
select
a.*,b.*
from all a left join aaa b on a.contract_no=b.contract_no;
quit;
/*区分M0-6+*/
data all_M;
set all;
if daishou_yue<0 then daishou_yue=0;
if thirdaishou_yue<0 then thirdaishou_yue=0;
if      overdue_day=.    then do interval="M0"; M0=daishou_yue;end;
if 1  <=overdue_day<=30  then do interval="M1"; M1=daishou_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=daishou_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=daishou_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=daishou_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=daishou_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=daishou_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=daishou_yue; end;
run;
/*精英贷客户*/
data JYD;
set all_M;
if product_name="小牛精英贷" or product_name="精英贷" then output;

run;
data jyd;
set jyd;
if PERSON_TYPE_DESC='' then output;
run;
/*计算逾期金额*/
proc sql;
create table JYD_Money as
select
a.depart,
round(sum(M0)/10000,0.01) as M0_sum,
round(sum(M1)/10000,0.01) as M1_sum,
round(sum(M2)/10000,0.01) as M2_sum,
round(sum(M3)/10000,0.01) as M3_sum,
round(sum(M4)/10000,0.01) as M4_sum,
round(sum(M5)/10000,0.01) as M5_sum,
round(sum(M6)/10000,0.01) as M6_sum,
round(sum(M6_plus)/10000,0.01) as M6_plus_sum,
round(sum(daishou_yue)/10000,0.01) as fengmu
from JYD a
group by depart;
quit;
/*空值标为0*/
data JYD_Money;
set JYD_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
run;
/*计算逾期率*/
proc sql;
create table JYD_Rate as
select
a.depart,
round(M1_sum/(fengmu-M6_plus_sum),0.0001) as M1_Rate,
round(M2_sum/(fengmu-M6_plus_sum),0.0001) as M2_Rate,
round(M3_sum/(fengmu-M6_plus_sum),0.0001) as M3_Rate,
round(M4_sum/(fengmu-M6_plus_sum),0.0001) as M4_Rate,
round(M5_sum/(fengmu-M6_plus_sum),0.0001) as M5_Rate,
round(M6_sum/(fengmu-M6_plus_sum),0.0001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.0001) as M6_plus_Rate,
round(sum(M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum)/(fengmu),0.0001) as Total_Rate
from JYD_Money a
group by depart;
quit;
/*逾期金额和逾期率放在一起*/
proc sql;
create table connect as
select
b.*,
a.*
from JYD_Money a
left join JYD_Rate b on a.depart=b.depart;
quit;
/*输出*/
PROC EXPORT DATA=connect OUTFILE="E:\source_data\没有填那个字段.xlsx" DBMS=EXCEL;
RUN;

and a.PERSON_TYPE_DESC=b.PERSON_TYPE_DESC
