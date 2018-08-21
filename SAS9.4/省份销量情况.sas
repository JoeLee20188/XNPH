%let path=E:\basic_data;/*基础数据路径*/
%let today="13Jun2016"d;
%let mytoday=20160613;
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
%read_tablen(&path,省份对应表demo,sheet1,aaa);
proc sql;
create table bbb as
select
_COL0,
_COL1,
sum(_COL3)/10000 as sum
from aaa
group by _COL0,_COL1;
quit;
/* 输出数据源*/
PROC EXPORT DATA=bbb OUTFILE="E:\source_data\省份销量.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
