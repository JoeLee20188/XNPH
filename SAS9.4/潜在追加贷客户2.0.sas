%let path=D:\basic_data;/*��������·��*/
%let today="23Nov2016"d;/*Ҫ�ȱ�֤�н�������ݼ�*/
%let mytoday=20161123;/*��������ļ����ı�ʶ*/
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
/*%read_tablen(&path,new_xn_dis,����������,dis_2);*/
data dis_2;
set dat.dis_2;
run;
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
/*Ӧ������*/
data dis;
set dis;
m0=intck("month",loan_date,&today);
d0=day(&today);
pay_day=day(loan_date);/*������*/
if d0>=pay_day then sh_pay_peri=m0;else sh_pay_peri=m0-1;
if sh_pay_peri>=periods_num then sh_pay_peri=periods_num;/*Ӧ���������ܳ�������*/
if loan_date<=&today.;/*�ſ����ڽ���֮ǰ��������*/
drop m0 d0 pay_day;
run;
/*****************************************************���ɻ���ƻ�dis**************************************************************************/
data dis;/*����ÿ�ڿۿ�����*/
set dis;
array term(60);
do i=1 to periods_num;
	term(i)=intnx("month",loan_date,i,"sameday");
end;
format term1-term60 yymmdd10.;
drop i;
run;

/******************************************************���ɻ�����ˮliushui************************************************************************/
/*���룬Ԥ����payment��*/
data pay;
set dat.pay;
run;
/*��ˮת��*/
proc sql;
create table pay1 as
select
      a.*,
	  sum(amount) as amount1
from pay a
group by submit_date,CONTRACTNO;/*(�ύ���� ��ͬ���)*/
quit;
proc sort data=pay1 nodupkey;/*һ���ͻ�һ��ϲ�Ϊһ��*/
by  submit_date CONTRACTNO;
run;
proc sort data=pay1 out=aaa;
by contractno;
proc transpose data=aaa out=bbb let;/*ת��ÿһ�ʵĻ�������*/
by contractno;
var submit_date;
run;
data bbbb;
set bbb(rename=(COL1=d1 COL2=d2 COL3=d3 COL4=d4 COL5=d5 COL6=d6 COL7=d7 COL8=d8 COL9=d9 COL10=d10 COL11=d11 COL12=d12 COL13=d13 COL14=d14 COL15=d15 COL16=d16 COL17=d17 COL18=d18 COL19=d19 COL20=d20 COL21=d21 COL22=d22 COL23=d23 COL24=d24 COL25=d25 COL26=d26));
drop _NAME_ _LABEL_;
label d1='��һ�ʻ�������' d2='�ڶ��ʻ�������' d3='�����ʻ�������' d4='���ıʻ�������' d5='����ʻ�������' d6='�����ʻ�������' d7='���߱ʻ�������'
      d8='�ڰ˱ʻ�������' d9='�ھűʻ�������' d10='��ʮ�ʻ�������' d11='��ʮһ�ʻ�������' d12='��ʮ���ʻ�������' d13='��ʮ���ʻ�������' d14='��ʮ�ıʻ�������'
      d15='��ʮ��ʻ�������' d16='��ʮ���ʻ�������' d17='��ʮ�߱ʻ�������' d18='��ʮ�˱ʻ�������' d19='��ʮ�űʻ�������' d20='�ڶ�ʮ�ʻ�������' d21='�ڶ�ʮһ�ʻ�������' 
      d22='�ڶ�ʮ���ʻ�������' d23='�ڶ�ʮ���ʻ�������' d24='�ڶ�ʮ�ıʻ�������' d25='�ڶ�ʮ��ʻ�������' d26='�ڶ�ʮ���ʻ�������';
run;
proc transpose data=aaa out=ccc let;/*װ��ÿһ�ʵĻ�����*/
by contractno;
var amount1;
run;
data cccc;
set ccc(rename=(COL1=a1 COL2=a2 COL3=a3 COL4=a4 COL5=a5 COL6=a6 COL7=a7 COL8=a8 COL9=a9 COL10=a10 COL11=a11 COL12=a12 COL13=a13 COL14=a14 COL15=a15 COL16=a16 COL17=a17 COL18=a18 COL19=a19 COL20=a20 COL21=a21 COL22=a22 COL23=a23 COL24=a24 COL25=a25 COL26=a26));
drop _NAME_ _LABEL_;
label a1='��һ�ʻ�����' a2='�ڶ��ʻ�����' a3='�����ʻ�����' a4='���ıʻ�����' a5='����ʻ�����' a6='�����ʻ�����' a7='���߱ʻ�����'
      a8='�ڰ˱ʻ�����' a9='�ھűʻ�����' a10='��ʮ�ʻ�����' a11='��ʮһ�ʻ�����' a12='��ʮ���ʻ�����' a13='��ʮ���ʻ�����' a14='��ʮ�ıʻ�����'
      a15='��ʮ��ʻ�����' a16='��ʮ���ʻ�����' a17='��ʮ�߱ʻ�����'a18='��ʮ�˱ʻ�����' a19='��ʮ�űʻ�����' a20='�ڶ�ʮ�ʻ�����' a21='�ڶ�ʮһ�ʻ�����'
      a22='�ڶ�ʮ���ʻ�����' a23='�ڶ�ʮ���ʻ�����' a24='�ڶ�ʮ�ıʻ�����' a25='�ڶ�ʮ��ʻ�����' a26='�ڶ�ʮ���ʻ�����';
run;
data liushui;
merge bbbb cccc;
run;
data liushui;
retain contractno d1 a1 d2 a2 d3 a3 d4 a4 d5 a5 d6 a6 d7 a7 d8 a8 d9 a9 d10 a10 d11 a11 d12 a12 d13 a13 d14 a14 d15 a15 d16 a16 d17 a17 d18 a18 d19 a19 d20 a20 d21 a21 ;
set liushui;
run;/*ת����ˮ���*/


/*ɾ������ͻ�*/
/******************************************************************************************************************/
/*��ǰ����ͻ�*/
data tiqian;
set pay;
if comment in ("ȫ������","ȫ������","ȫ�����","ȫ�����") then output;
run;
/*������������*/
data zhengchang;
set pay; 
comment=compress(comment);
a=index(comment,"�ۿ�")+4;
b=index(comment,"��");
term=input(substr(comment,a,b-a),$66.);

if term in ("3/3","6/6","9/9","12/12","15/15","18/18","24/24") then output;
drop a b term;
run;
data pay_all;
set tiqian zhengchang;
run;
proc sort data=pay_all nodupkey;
by contractno;
run;
proc sql;
create table dis1 as
select
      a.*,
      b.contractno
from dis a
left join pay_all b
on a.contract_no=b.contractno;
quit;
data dis_test;
set dis1;
if contractno^=' ' then delete;
if sh_pay_peri<6 then delete;
drop contractno;
run;/*��ɾ����ͻ���Ӧ������>=6*/
/****************************************************Ŀ��ͻ����ϻ�����ˮ*******************************************************************************************/
proc sql;
create table zhangwu as
select
      a.*,
	  b.*
from dis_test a
left join liushui b
on a.CONTRACT_NO=b.CONTRACTNO;
quit;

data part;
set zhangwu;
if product_name in ('��н��','Сţ��н��','���Ѵ�','��Ӣ��','Сţ��Ӣ��','רҵ��') then output;/*��Ʒ������Ĳ�Ʒ����*/
keep CONTRACT_NO d1-d12 a1-a12 term1-term12;
run;
data part;
set part;
if substr(CONTRACT_NO,1,1)="0" or substr(CONTRACT_NO,1,1)="1" or substr(CONTRACT_NO,1,1)="2" then output; /*��Ʒ�������ϵͳ����*/
run;
data info;
set dat.quanbu_cust&mytoday.;
keep sys depart region_name city branch_name CONTRACT_NO cust_name product_name ID_NUM GENDER loan_amount con_amount mon_pay periods_num con_yue daishou_yue prin_yue loan_date pay_day	
     sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay MOBILE mon_man mon_int;
run;
data info;/*�����ѻ�����*/
set info;
a=(mon_man+mon_int)*sh_pay_peri;
al_pay_pri=sh_pay_sum-a;
label al_pay_pri='�ѻ�����';
drop a mon_man mon_int;
run;
proc sql;
create table final as
select
a.*,
b.*
from part a
left join info b
on a.contract_no=b.contract_no;
quit;
data final;/*����*/
retain sys depart region_name city branch_name CONTRACT_NO cust_name product_name ID_NUM GENDER loan_amount con_amount mon_pay periods_num con_yue daishou_yue prin_yue loan_date pay_day	
     sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay MOBILE al_pay_pri;
set final;
run;

PROC EXPORT DATA=final OUTFILE="E:\source_data\׷�Ӵ��ͻ�2.0&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
