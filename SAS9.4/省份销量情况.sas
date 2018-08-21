%let path=E:\basic_data;/*��������·��*/
%let today="13Jun2016"d;
%let mytoday=20160613;
%let yqday=&today.-30;
libname dat "E:\data";

%macro read_table(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xls" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_table;/*�����*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
%macro output_table(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xls" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_table;/*�����*/
%macro output_tablen(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xlsx" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_tablen;/*����(2013��excel)��*/
%read_tablen(&path,ʡ�ݶ�Ӧ��demo,sheet1,aaa);
proc sql;
create table bbb as
select
_COL0,
_COL1,
sum(_COL3)/10000 as sum
from aaa
group by _COL0,_COL1;
quit;
/* �������Դ*/
PROC EXPORT DATA=bbb OUTFILE="E:\source_data\ʡ������.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
