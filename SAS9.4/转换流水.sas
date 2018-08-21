%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%let path=D:\basic_data;/*基础数据路径*/
%let today="29Sep2016"d;
%let mytoday=20160929;
%let yqday=&today.-30;
libname dat "E:\data";
data aaa;
set dat.pay;
run;
data bbb;/*区分新旧系统数据*/
set aaa;
if substr(contractno,1,1)="0" or substr(contractno,1,1)="1" or substr(contractno,1,1)="2" then sys="new"; else sys="old"; 
run;
data new;
set bbb;
if sys='new' then output;
run;
data old;
set bbb;
if sys='old' then output;
run;
/* 输出数据源*/
PROC EXPORT DATA=new OUTFILE="E:\source_data\新系统客户全量流水.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
PROC EXPORT DATA=old OUTFILE="E:\source_data\旧系统客户全量流水.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
data;
set;
round(mon_pay*periods_num,0.01);
run;
