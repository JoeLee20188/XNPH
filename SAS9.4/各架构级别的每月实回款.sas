%let path=D:\basic_data;/*基础数据路径*/
%let today="31Oct2016"d;/*计算到应还期数*/
%let mytoday=20161122;/*用于输出文件名的标识，用几号数据集的架构*/
libname dat "E:\data";
data pay;
set dat.pay;
run;
/**/
data allcust;
set dat.quanbu_cust&mytoday.;
if depart="房贷事业部" or depart="首付贷事业部" then delete;
run;


proc sql;
create table aaa as
select
      a.*,b.loan_date
from pay a 
left join allcust b
on a.CONTRACTNO=b.CONTRACT_NO;
quit;
data bbb;
set aaa;
if loan_date>='01Oct2016'd then delete; 
run;
data ccc;
set bbb;
drop loan_date;
run;
/*连级别*/
data ziliao;
set dat.fig_jiagou;
keep CONTRACT_NO BUSINESS_UNIT_SOURCE REGION_AREA_ CITY_CENTER REGION_CITYY_ BRANCH_NAME;
run;
proc sql;
create table pay_plan as
select
      a.*,
      b.*
from ccc a 
left join ziliao b
on a.CONTRACTNO=b.CONTRACT_NO;
quit;

/*日汇总*/
proc sql;
create table sday as
select
      a.submit_date,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME,
      round(sum(amount)/10000,0.01) as day_pay
from pay_plan a 
group by submit_date,BUSINESS_UNIT_SOURCE,REGION_AREA_,BRANCH_NAME;
quit;
/*月汇总*/
data fig_my;
set sday;
year=year(submit_date);
dmonth=month(submit_date);
if dmonth<10 then ddmonth=compress("0"||dmonth); else ddmonth=dmonth;
month=input(compress(year||ddmonth),12.);
drop dmonth ddmonth;
run;
proc sql;
create table smonth as
select
      a.month,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME,
      round(sum(day_pay),0.01) as mon_pay
from fig_my a 
group by month,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME;
quit;
proc sort data=smonth out=smonth;
by month;
run;
/*年汇总*/
/*proc sql;*/
/*create table syear as*/
/*select*/
/*      a.year,*/
/*      sum(day_sum) as year_sum*/
/*from fig_my a */
/*group by year;*/
/*quit;*/
/*汇总年月日*/
/*data symd;*/
/*merge sday smonth syear;*/
/*run;*/
/*对齐字段名和label*/
/*data symd;*/
/*set symd(rename=(submit_date=day));*/
/*label day="日" day_sum="日总" month="月" month_sum="月总" year="年" year_sum="年总";*/
/*run;*/
/* 输出*/
PROC EXPORT DATA=smonth OUTFILE="E:\source_data\实际回款金额&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;




















