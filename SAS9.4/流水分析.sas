%let path=E:\basic_data;/*基础数据路径*/
%let today="13Sep2016"d;
%let mytoday=20160913;
%let yqday=&today.-30;
libname dat "E:\data";
%macro read_table(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xls" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_table;/*读表宏*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%macro output_table(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xls" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_table;/*出表宏*/
%macro output_tablen(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xlsx" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_tablen;/*出表(2013版excel)宏*/
/*读入，预处理payment表
%read_tablen(&path,数据汇总（有重复）,汇总,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;*/
/*删除流水中的重复值
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;*/
data pay;
set dat.pay;
run;
/*日汇总*/
proc sql;
create table sday as
select
      a.submit_date,
      sum(amount)/10000 as day_sum
from pay a 
group by submit_date;
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
      a.month,
      sum(day_sum) as month_sum
from fig_my a 
group by month;
quit;
proc sort data=smonth out=smonth;
by month;
run;
/*年汇总*/
proc sql;
create table syear as
select
      a.year,
      sum(day_sum) as year_sum
from fig_my a 
group by year;
quit;
/*汇总年月日*/
data symd;
merge sday smonth syear;
run;
/*对齐字段名和label*/
data symd;
set symd(rename=(submit_date=day));
label day="日" day_sum="日总" month="月" month_sum="月总" year="年" year_sum="年总";
run;
/* 输出*/
PROC EXPORT DATA=symd OUTFILE="E:\source_data\还款汇总&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;




















