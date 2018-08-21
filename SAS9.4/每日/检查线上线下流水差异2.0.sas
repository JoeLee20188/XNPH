libname dat "E:\data";
%let path=D:\basic_data;/*��������·��*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
%read_tablen(&path,sys_liushui,����������,pay_1);
%read_tablen(&path,sys_liushui,sheet1,pay_2);
data dat.it_pay;
set pay_1 pay_2;
run;





/*���ˮ*/
data my_pay;
set dat.pay;
keep submit_date amount contractno;
rename submit_date=submit_date1 amount=amount1 contractno=contract_no1;
run;
data my_pay;/*ɾ����Ч��ˮ*/
set my_pay; 
if submit_date1='' or amount1='' or contract_no1='' then delete;
run;
/*�Ľ���λС��*/
data my_pay;
set my_pay(rename=(amount1=aaa));
amount1=round(aaa,0.01);
drop aaa;
run;
data my_pay1;
set my_pay;
format submit_date1 yymmdd10.;
fig1=compress(submit_date1)||compress(amount1)||compress(contract_no1);
run;
proc sql;
create table my_pay as
select
a.*
from my_pay1 a
order by submit_date1,contract_no1,amount1;
quit;
/*Ψһ��ʶ����һ�ε�*/
proc sql;
create table my_cishu as
select
a.fig1,
count(fig1) as my_fig1_num
from my_pay a
group by fig1;
quit;
data my_cishu1;
set my_cishu;
if my_fig1_num=1 then output;
run;
data my_cishu2;
set my_cishu;
if my_fig1_num>1 then output;
run;



/*ϵͳ��ˮ*/
data it_pay;
set dat.it_pay;
run;
data it_pay1;
set it_pay;
newdt=input(submit_date,yymmdd10.);
format newdt yymmdd10.;
drop submit_date;
rename newdt=submit_date;
run;
data it_pay2;
set it_pay1;
fig=compress(submit_date)||compress(amount)||compress(contract_no);
run;
proc sql;
create table it_pay as
select
a.*
from it_pay2 a
order by submit_date,contract_no,amount;
quit;
/*Ψһ��ʶ����һ�ε�*/
proc sql;
create table it_cishu as
select
a.fig,
count(fig) as it_fig_num
from it_pay a
group by fig;
quit;
data it_cishu1;
set it_cishu;
if it_fig_num=1 then output;
run;
data it_cishu2;
set it_cishu;
if it_fig_num>1 then output;
run;




/************************************************Ψһ�ĶԱ�**************************************************************************************************/
/*it�в���û�е�*/
proc sql;
create table it_my_check as
select
a.*,b.*
from it_cishu1 a left join my_cishu1 b on a.fig=b.fig1;
quit;
data it_my;
set it_my_check;
if fig1='' then output;
run;
proc sql;
create table it_delete as
select
b.*
from it_my a left join it_pay b on a.fig=b.fig;
quit;
/*������itû�е�*/
proc sql;
create table my_it_check as
select
a.*,b.*
from my_cishu1 a left join it_cishu1 b on a.fig1=b.fig;
quit;
data my_it;
set my_it_check;
if fig='' then output;
run;
proc sql;
create table it_add as
select
b.*
from my_it a left join my_pay b on a.fig1=b.fig1;
quit;

PROC EXPORT DATA=it_delete OUTFILE="E:\source_data\it��Ҫɾ������ˮ1123.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
PROC EXPORT DATA=it_add OUTFILE="E:\source_data\it��Ҫ���ӵ���ˮ1123.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;


/******************************************************һ���ʵĶԱ�*******************************************************************************************************/
/*����*/
proc sql;/*��������*/
create table my_cishu2_1 as
select
b.*
from my_cishu2 a left join my_pay b on a.fig1=b.fig1
order by submit_date1,contract_no1,amount1;
quit;
proc sql;/*��������*/
create table it_cishu2_1 as
select
b.*
from it_cishu2 a left join it_pay b on a.fig=b.fig
order by submit_date,contract_no,amount;
quit;
/*mergeһ��*/
data my_it_check_2;
merge my_cishu2_1 it_cishu2_1;
run;
PROC EXPORT DATA=my_it_check_2 OUTFILE="E:\source_data\������Ҫ��ʵ����ˮ1123.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
















































































/*******************************************************��һ�β���********************************************************************************/
data all;
merge it_pay my_pay;
run;
data all1;
set all;
label submit_date="it_��������" amount="it_������" contract_no="it_��ͬ���" fig="it_��ʶ"
      submit_date1="my_��������" amount1="my_������" contract_no1="my_��ͬ���" fig1="my_��ʶ";
run;
data final;
retain fig fig1 submit_date amount contract_no submit_date1 amount1 contract_no1;
set all1;
run;
/*��ʼ�Ҳ���*/
data check;
set final;
if fig=fig1 then do check=1; end;
run;
/*����*/
data check1;
set check;
if check=. then output;
run;




/****ɾ�����ˮ*************************************************************************/
data x;
set my_pay;
if fig1='205842750FTAYX34225_001' 
then output;
run;
/*PROC EXPORT DATA=x OUTFILE="E:\source_data\���Ҫɾ������ˮ.xlsx" DBMS=EXCEL REPLACE LABEL;*/
/*RUN;*/
data my_pay;
set my_pay;
if fig1='205842750FTAYX34225_001'  
then delete;
run;
/*���������ˮ,it���û�е�************************************************************************************************************************/
data y;
input submit_date1 yymmdd10. amount1 contract_no1 $42.;
datalines;
2016-05-10 2750 FTAYX34225_001
;
run;
/*PROC EXPORT DATA=y OUTFILE="E:\source_data\���Ҫ���ӵ���ˮ.xlsx" DBMS=EXCEL REPLACE LABEL;*/
/*RUN;*/
data z;/*�ӱ�ʶ*/
set y;
fig1=compress(submit_date1)||compress(amount1)||compress(contract_no1);
run;
data my_pay;/*����*/
set my_pay z;
run;
proc sql;/*��������*/
create table my_pay as
select
a.*
from my_pay a
order by submit_date1,contract_no1,amount1;
quit;








/****ɾ��it��ˮ*************************************************************************/
data c;
set it_pay;
if fig='2062059910840101120023409-01' 
then output;
run;
/*PROC EXPORT DATA=c OUTFILE="E:\source_data\it��Ҫɾ������ˮ.xlsx" DBMS=EXCEL REPLACE LABEL;*/
/*RUN;*/
data it_pay;
set it_pay;
if fig='2062059910840101120023409-01'
then delete;
run;
/*����it����ˮ************************************************************************************************************************/
data a;
input submit_date yymmdd10. amount contract_no $42.;
datalines;
2015-07-04 1659	HXQFSZ23425_001
2015-08-04 1659	HXQFSZ23425_001
2015-09-04 1659	HXQFSZ23425_001
2015-10-04 1659	HXQFSZ23425_001
2015-11-04 1659	HXQFSZ23425_001
2015-12-04 1659	HXQFSZ23425_001
2016-01-04 1659	HXQFSZ23425_001
2016-02-04 1659	HXQFSZ23425_001
2016-03-04 1659	HXQFSZ23425_001
2016-04-03 2962.06	HXQFSZ23425_001
2015-09-10 2749	FTAYX34225_001
2015-10-10 2749	FTAYX34225_001
2015-11-10 2749	FTAYX34225_001
2015-12-10 2749	FTAYX34225_001
2016-01-10 2749	FTAYX34225_001
2016-02-10 2749	FTAYX34225_001
2016-03-10 2749	FTAYX34225_001
2016-04-10 2749	FTAYX34225_001
2016-05-10 2750	FTAYX34225_001
2016-06-12 2750	FTAYX34225_001
2016-07-16 2750	FTAYX34225_001
2016-08-12 2749	FTAYX34225_001
2016-09-10 2749	FTAYX34225_001
2016-10-10 2750	FTAYX34225_001
2015-08-27 5529	GZFSZ31416_001
2015-09-28 5529	GZFSZ31416_001
2015-11-27 5529	GZFSZ31416_001
2015-12-27 5529	GZFSZ31416_001
2016-01-27 5529	GZFSZ31416_001
2016-02-27 5529	GZFSZ31416_001
2016-03-27 5529	GZFSZ31416_001
2016-04-27 5529	GZFSZ31416_001
2016-05-27 5529	GZFSZ31416_001
2016-06-27 5529	GZFSZ31416_001
2015-10-26 5530	GZFSZ31416_001
2016-09-23 5822	GZFSZ31416_001
2016-01-12 4000 HXQFSZ22620_001
2016-08-16 1947.21 2130107010158425-01
2016-04-20 3215 WSSYBWSD09045_001
2016-04-28 1000 0090101050079478-01
2016-05-05 10 0090101050079478-01
2016-08-19 53.08 2070106060192552-01
2016-08-22 5000	0260201160009914-01
2016-06-29 26000 0010501010062755-01
2016-05-16 5645	FTAYX34214_001
2016-08-22 5000	0260201160009914-01
;
run;
/*PROC EXPORT DATA=a OUTFILE="E:\source_data\it��Ҫ���ӵ���ˮ.xlsx" DBMS=EXCEL REPLACE LABEL;*/
/*RUN;*/
data b;/*�ӱ�ʶ*/
set a;
fig=compress(submit_date)||compress(amount)||compress(contract_no);
run;
data it_pay;/*����*/
set it_pay b;
run;
proc sql;/*��������*/
create table it_pay as
select
a.*
from it_pay a
order by submit_date,contract_no,amount;
quit;




/*��һ��*/
data all;
merge it_pay my_pay;
run;
data all1;
set all;
label submit_date="it_��������" amount="it_������" contract_no="it_��ͬ���" fig="it_��ʶ"
      submit_date1="my_��������" amount1="my_������" contract_no1="my_��ͬ���" fig1="my_��ʶ";
run;
data final;
retain fig fig1 submit_date amount contract_no submit_date1 amount1 contract_no1;
set all1;
run;
/*��ʼ�Ҳ���*/
data check;
set final;
if fig=fig1 then do check=1; end;
run;
/*����*/
data check1;
set check;
if check=. then output;
run;









/*���itû�е�*/
proc sql;
create table my_it_pay as
select
a.*,b.*
from my_pay a left join it_pay b on a.fig1=b.fig
order by submit_date1,contract_no1,amount1;
quit;
data my_it_check;/*ϵͳ��Ҫ����*/
set my_it_pay;
if submit_date=. then output;
run;
/*it���û�е�*/
proc sql;
create table it_my_pay as
select
a.*,b.*
from it_pay a left join my_pay b on a.fig=b.fig1
order by submit_date,contract_no,amount;
quit;
data it_my_check;/*ϵͳ��Ҫɾ��*/
set it_my_pay;
if submit_date1=. then output;
run;
PROC EXPORT DATA=my_it_check OUTFILE="E:\source_data\it��Ҫ���ӵ���ˮ1.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
