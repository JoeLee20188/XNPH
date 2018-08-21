%let path=E:\basic_data;/*��������·��*/
%let today="22Aug2016"d;
%let mytoday=20160822;
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
/*���룬Ԥ����disbursement��*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
/*proc sql;
connect to oracle as mylib (user=jhjy password=jhjy path=10.15.18.11);
create table table_name as               
select * from connection to mylib (select��); �����в�ѯ��������oracle���﷨
disconnect  from  mylib;
quit;
proc setinit; run;

libname mylib odbc datasrc=newsys user=jhjy password='jhjy';;
libname mylib oracle datasrc=oracle user=szxn password='szxn#6';*/

%read_tablen(&path,new_xn_dis,����������,dis_2);
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
/*********************************************���ʴ������ϣ������Ŀͻ�****************************************************************************************/
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
/********��ʶ��һ�ʴ����������**************/
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
/**********����ҵ��,��������********************/
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
/******�������*****/

proc sql;/*��һ��*/
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
label product_name="��Ʒ����"
      loan_num="�ſ����"
	  loan_sum="�ſ���"
	  con_sum="��ͬ���"
	  overdue_sum="���ڱ���";
run;
proc sql;/*ʣ��*/
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
label product_name="��Ʒ����"
      loan_num="�ſ����"
	  loan_sum="�ſ���"
	  con_sum="��ͬ���"
	  overdue_sum="���ڱ���";
run;

/*������*/
%read_tablen(&path,������,sheet1,hlw);
proc sql;/*ʣ��*/
create table hlw as
select
b.*
from hlw a
left join info b
on a.contract_no=b.contract_no;
quit;



/* �������Դ*/
PROC EXPORT DATA=a1 OUTFILE="E:\source_data\�������ϴ���ͻ����_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET="��һ�ʴ���";
RUN;
PROC EXPORT DATA=b1 OUTFILE="E:\source_data\�������ϴ���ͻ����_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET="�ڶ��ʴ��������";
RUN;
PROC EXPORT DATA=dis OUTFILE="E:\source_data\�������ϴ���ͻ����_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET="����";
RUN;
PROC EXPORT DATA=hlw OUTFILE="E:\source_data\�������ϴ���ͻ����_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET="������";
RUN;






