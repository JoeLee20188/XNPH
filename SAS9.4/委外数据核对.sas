%let path=E:\basic_data;/*基础数据路径*/
%let today="11Jul2016"d;
%let mytoday=20160711;
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
%read_tablen(&path,委外数据核对,sheet1,wwsj);
data wwsj1;
set wwsj;
if con='' then delete;
if weituo>='25May2016'd then output;
run;
/*读入委外客户表，核对委外日期*/
%read_tablen(&path,委外客户汇总（2016年5月25日开始）,Sheet1,out_cust);
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
label weituo='你表上的委托日期'
      con='合同编号';
run;
/* 输出*/
PROC EXPORT DATA=date_final OUTFILE="E:\source_data\委外数据核对结果.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;






