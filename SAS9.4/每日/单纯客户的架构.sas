%let path=D:\basic_data;/*��������·��*/
%let mytoday=20161120;/*��������ļ����ı�ʶ*/
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
%read_tablen(&path,��ͨ�ͻ��ܹ�,����������,putong);
%read_tablen(&path,���ռܹ�,Ӫҵ���ܹ�,jiagou_fig);
%read_tablen(&path,���ռܹ�,���̿ͻ�10211,a2);
%read_tablen(&path,���ռܹ�,�������ͻ�2961,a3);
%read_tablen(&path,���ռܹ�,����һ��2015,a4);
%read_tablen(&path,���ռܹ�,���һ��173,a5);
/*����Ӫҵ���޸�*/
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
/*setһ��*/
data all;
set a1 a2 a3 a4 a5;
run;
/*ɾ���ظ�ֵ*/
proc sort data=all nodupkey;
by contract_no;
run;
/*�洢���ݼ�*/
data dat.fig_jiagou;
set all;
run;
/*������ļܹ���*/
proc sql;
create table jiagou as
select
a.BUSINESS_UNIT_SOURCE,REGION_AREA_,CITY_CENTER,REGION_CITYY_,BRANCH_NAME,
count(a.CONTRACT_NO) as num
from all a
group by BUSINESS_UNIT_SOURCE,REGION_AREA_,CITY_CENTER,REGION_CITYY_,BRANCH_NAME;
quit;
PROC EXPORT DATA=jiagou OUTFILE="E:\source_data\�ܹ���&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
