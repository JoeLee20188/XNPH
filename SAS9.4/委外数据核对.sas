%let path=E:\basic_data;/*��������·��*/
%let today="11Jul2016"d;
%let mytoday=20160711;
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
%read_tablen(&path,ί�����ݺ˶�,sheet1,wwsj);
data wwsj1;
set wwsj;
if con='' then delete;
if weituo>='25May2016'd then output;
run;
/*����ί��ͻ����˶�ί������*/
%read_tablen(&path,ί��ͻ����ܣ�2016��5��25�տ�ʼ��,Sheet1,out_cust);
data wtrq;
set out_cust;
keep _COL14 _COL1;
run;
proc sql;
create table date as
select
     a.weituo,con,
	 b._COL1
from wwsj1 a
left join wtrq b
on a.con=b._COL14;
quit;
data date_final;
set date;
if weituo^=_COL1 then output;
run;
data date_final;
set date_final;
label weituo='����ϵ�ί������'
      con='��ͬ���';
run;
/* ���*/
PROC EXPORT DATA=date_final OUTFILE="E:\source_data\ί�����ݺ˶Խ��.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;






