%let path=D:\basic_data;/*基础数据路径*/
%let mytoday=20161120;/*用于输出文件名的标识*/
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%read_tablen(&path,普通客户架构,导出工作表,putong);
%read_tablen(&path,最终架构,营业部架构,jiagou_fig);
%read_tablen(&path,最终架构,网商客户10211,a2);
%read_tablen(&path,最终架构,互联网客户2961,a3);
%read_tablen(&path,最终架构,重庆一部2015,a4);
%read_tablen(&path,最终架构,天津一部173,a5);
/*整个营业部修改*/
proc sql;
create table a1 as
select
a.CONTRACT_NO,SYST,CONTRACT_STATE,
b.a as BUSINESS_UNIT_SOURCE,
b.b as REGION_AREA_,
b.c as CITY_CENTER,
b.d as REGION_CITYY_,
b.e as BRANCH_NAME
from putong a
left join jiagou_fig b
on a.BUSINESS_UNIT_SOURCE=b.BUSINESS_UNIT_SOURCE and a.BRANCH_NAME=b.BRANCH_NAME;
quit;
/*set一起*/
data all;
set a1 a2 a3 a4 a5;
run;
/*删除重复值*/
proc sort data=all nodupkey;
by contract_no;
run;
/*存储数据集*/
data dat.fig_jiagou;
set all;
run;
/*修正后的架构表*/
proc sql;
create table jiagou as
select
a.BUSINESS_UNIT_SOURCE,REGION_AREA_,CITY_CENTER,REGION_CITYY_,BRANCH_NAME,
count(a.CONTRACT_NO) as num
from all a
group by BUSINESS_UNIT_SOURCE,REGION_AREA_,CITY_CENTER,REGION_CITYY_,BRANCH_NAME;
quit;
PROC EXPORT DATA=jiagou OUTFILE="E:\source_data\架构表&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
