libname dat "E:\data";
%let path=D:\basic_data;/*基础数据路径*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%read_tablen(&path,sys_liushui,导出工作表,pay_1);
%read_tablen(&path,sys_liushui,sheet1,pay_2);
data dat.it_pay;
set pay_1 pay_2;
run;





/*李华流水*/
data my_pay;
set dat.pay;
keep submit_date amount contractno;
rename submit_date=submit_date1 amount=amount1 contractno=contract_no1;
run;
data my_pay;/*删除无效流水*/
set my_pay; 
if submit_date1='' or amount1='' or contract_no1='' then delete;
run;
/*改金额，两位小数*/
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
/*唯一标识出现一次的*/
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



/*系统流水*/
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
/*唯一标识出现一次的*/
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




/************************************************唯一的对比**************************************************************************************************/
/*it有财务没有的*/
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
/*财务有it没有的*/
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

PROC EXPORT DATA=it_delete OUTFILE="E:\source_data\it需要删除的流水1123.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
PROC EXPORT DATA=it_add OUTFILE="E:\source_data\it需要增加的流水1123.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;


/******************************************************一天多笔的对比*******************************************************************************************************/
/*排序*/
proc sql;/*重新排序*/
create table my_cishu2_1 as
select
b.*
from my_cishu2 a left join my_pay b on a.fig1=b.fig1
order by submit_date1,contract_no1,amount1;
quit;
proc sql;/*重新排序*/
create table it_cishu2_1 as
select
b.*
from it_cishu2 a left join it_pay b on a.fig=b.fig
order by submit_date,contract_no,amount;
quit;
/*merge一起*/
data my_it_check_2;
merge my_cishu2_1 it_cishu2_1;
run;
PROC EXPORT DATA=my_it_check_2 OUTFILE="E:\source_data\财务需要核实的流水1123.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
















































































/*******************************************************第一次差异********************************************************************************/
data all;
merge it_pay my_pay;
run;
data all1;
set all;
label submit_date="it_还款日期" amount="it_还款金额" contract_no="it_合同编号" fig="it_标识"
      submit_date1="my_还款日期" amount1="my_还款金额" contract_no1="my_合同编号" fig1="my_标识";
run;
data final;
retain fig fig1 submit_date amount contract_no submit_date1 amount1 contract_no1;
set all1;
run;
/*开始找差异*/
data check;
set final;
if fig=fig1 then do check=1; end;
run;
/*差异*/
data check1;
set check;
if check=. then output;
run;




/****删除李华流水*************************************************************************/
data x;
set my_pay;
if fig1='205842750FTAYX34225_001' 
then output;
run;
/*PROC EXPORT DATA=x OUTFILE="E:\source_data\李华需要删除的流水.xlsx" DBMS=EXCEL REPLACE LABEL;*/
/*RUN;*/
data my_pay;
set my_pay;
if fig1='205842750FTAYX34225_001'  
then delete;
run;
/*增加李华的流水,it有李华没有的************************************************************************************************************************/
data y;
input submit_date1 yymmdd10. amount1 contract_no1 $42.;
datalines;
2016-05-10 2750 FTAYX34225_001
;
run;
/*PROC EXPORT DATA=y OUTFILE="E:\source_data\李华需要增加的流水.xlsx" DBMS=EXCEL REPLACE LABEL;*/
/*RUN;*/
data z;/*加标识*/
set y;
fig1=compress(submit_date1)||compress(amount1)||compress(contract_no1);
run;
data my_pay;/*加入*/
set my_pay z;
run;
proc sql;/*重新排序*/
create table my_pay as
select
a.*
from my_pay a
order by submit_date1,contract_no1,amount1;
quit;








/****删除it流水*************************************************************************/
data c;
set it_pay;
if fig='2062059910840101120023409-01' 
then output;
run;
/*PROC EXPORT DATA=c OUTFILE="E:\source_data\it需要删除的流水.xlsx" DBMS=EXCEL REPLACE LABEL;*/
/*RUN;*/
data it_pay;
set it_pay;
if fig='2062059910840101120023409-01'
then delete;
run;
/*增加it的流水************************************************************************************************************************/
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
/*PROC EXPORT DATA=a OUTFILE="E:\source_data\it需要增加的流水.xlsx" DBMS=EXCEL REPLACE LABEL;*/
/*RUN;*/
data b;/*加标识*/
set a;
fig=compress(submit_date)||compress(amount)||compress(contract_no);
run;
data it_pay;/*加入*/
set it_pay b;
run;
proc sql;/*重新排序*/
create table it_pay as
select
a.*
from it_pay a
order by submit_date,contract_no,amount;
quit;




/*放一起*/
data all;
merge it_pay my_pay;
run;
data all1;
set all;
label submit_date="it_还款日期" amount="it_还款金额" contract_no="it_合同编号" fig="it_标识"
      submit_date1="my_还款日期" amount1="my_还款金额" contract_no1="my_合同编号" fig1="my_标识";
run;
data final;
retain fig fig1 submit_date amount contract_no submit_date1 amount1 contract_no1;
set all1;
run;
/*开始找差异*/
data check;
set final;
if fig=fig1 then do check=1; end;
run;
/*差异*/
data check1;
set check;
if check=. then output;
run;









/*李华有it没有的*/
proc sql;
create table my_it_pay as
select
a.*,b.*
from my_pay a left join it_pay b on a.fig1=b.fig
order by submit_date1,contract_no1,amount1;
quit;
data my_it_check;/*系统需要增加*/
set my_it_pay;
if submit_date=. then output;
run;
/*it有李华没有的*/
proc sql;
create table it_my_pay as
select
a.*,b.*
from it_pay a left join my_pay b on a.fig=b.fig1
order by submit_date,contract_no,amount;
quit;
data it_my_check;/*系统需要删除*/
set it_my_pay;
if submit_date1=. then output;
run;
PROC EXPORT DATA=my_it_check OUTFILE="E:\source_data\it需要增加的流水1.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
