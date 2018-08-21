%let path=E:\basic_data;/*基础数据路径*/
%let today="22Aug2016"d;
%let mytoday=20160822;
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
/*读入，预处理disbursement表*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
/*proc sql;
connect to oracle as mylib (user=jhjy password=jhjy path=10.15.18.11);
create table table_name as               
select * from connection to mylib (select…); 括号中查询语句需符合oracle的语法
disconnect  from  mylib;
quit;
proc setinit; run;

libname mylib odbc datasrc=newsys user=jhjy password='jhjy';;
libname mylib oracle datasrc=oracle user=szxn password='szxn#6';*/

%read_tablen(&path,new_xn_dis,导出工作表,dis_2);
data dis;
set dis_1 dis_2;
run;
data dis;
set dis;
newdt=input(loan_date,yymmdd10.);
format newdt yymmdd10.;
drop loan_date;
run;
data dis;
set dis(rename=(newdt=loan_date));
run;
/*********************************************两笔贷款以上（含）的客户****************************************************************************************/
proc sql;
create table aaa as
select
cert_id,
count(CONTRACT_NO) as num
from dis a
group by cert_id;
quit;
data bbb;
set aaa;
if num>1 then output;
run;
proc sql;
create table dis as
select
b.*
from bbb a
left join dis b on a.cert_id=b.cert_id;
quit;
/********标识第一笔贷款，后续贷款**************/
proc sql;
create table aaa as
select
cert_id,
min(loan_date) as loan_date1
from dis a
group by cert_id;
quit;
proc sql;
create table bbb as
select
b.*
from aaa a
left join dis b on a.cert_id=b.cert_id and a.loan_date1=b.loan_date;
quit;
data ccc;
set bbb;
format fig best12.;
fig=1;
run;
proc sql;
create table dis as
select
a.*,b.fig
from dis a
left join ccc b on a.contract_no=b.contract_no;
quit;
/**********连事业部,逾期资料********************/
data info;
set dat.quanbu_cust20160819;
keep contract_no depart al_pay_sum sh_pay_sum overdue_dt overdue_day last_pay done con_yue daishou_yue thircon thirdaishou_yue prin_yue;
run;
proc sql;
create table dis as
select
a.*,b.depart,al_pay_sum,sh_pay_sum,overdue_dt,overdue_day,last_pay,done,con_yue,daishou_yue,thircon,thirdaishou_yue,prin_yue
from dis a
left join info b on a.contract_no=b.contract_no;
quit;
/******分组汇总*****/

proc sql;/*第一笔*/
create table a1 as
select
a.product_name,
a.depart,
count(contract_no) as loan_num,
round(sum(loan_amount)/10000,0.01) as loan_sum,
round(sum(con_amount)/10000,0.01) as con_sum,
count(overdue_day) as overdue_sum
from dis a
where fig=1
group by product_name,depart;
quit;
data a1;
set a1;
label product_name="产品名称"
      loan_num="放款件数"
	  loan_sum="放款金额"
	  con_sum="合同金额"
	  overdue_sum="逾期笔数";
run;
proc sql;/*剩余*/
create table b1 as
select
a.product_name,
a.depart,
count(contract_no) as loan_num,
round(sum(loan_amount)/10000,0.01) as loan_sum,
round(sum(con_amount)/10000,0.01) as con_sum,
count(overdue_day) as overdue_sum
from dis a
where fig=.
group by product_name,depart;
quit;
data b1;
set b1;
label product_name="产品名称"
      loan_num="放款件数"
	  loan_sum="放款金额"
	  con_sum="合同金额"
	  overdue_sum="逾期笔数";
run;

/*互联网*/
%read_tablen(&path,互联网,sheet1,hlw);
proc sql;/*剩余*/
create table hlw as
select
b.*
from hlw a
left join info b
on a.contract_no=b.contract_no;
quit;



/* 输出数据源*/
PROC EXPORT DATA=a1 OUTFILE="E:\source_data\两笔以上贷款客户情况_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET="第一笔贷款";
RUN;
PROC EXPORT DATA=b1 OUTFILE="E:\source_data\两笔以上贷款客户情况_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET="第二笔贷款或以上";
RUN;
PROC EXPORT DATA=dis OUTFILE="E:\source_data\两笔以上贷款客户情况_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET="数据";
RUN;
PROC EXPORT DATA=hlw OUTFILE="E:\source_data\两笔以上贷款客户情况_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET="互联网";
RUN;






