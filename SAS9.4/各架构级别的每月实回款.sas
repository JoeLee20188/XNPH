%let path=D:\basic_data;/*��������·��*/
%let today="31Oct2016"d;/*���㵽Ӧ������*/
%let mytoday=20161122;/*��������ļ����ı�ʶ���ü������ݼ��ļܹ�*/
libname dat "E:\data";
data pay;
set dat.pay;
run;
/**/
data allcust;
set dat.quanbu_cust&mytoday.;
if depart="������ҵ��" or depart="�׸�����ҵ��" then delete;
run;


proc sql;
create table aaa as
select
      a.*,b.loan_date
from pay a 
left join allcust b
on a.CONTRACTNO=b.CONTRACT_NO;
quit;
data bbb;
set aaa;
if loan_date>='01Oct2016'd then delete; 
run;
data ccc;
set bbb;
drop loan_date;
run;
/*������*/
data ziliao;
set dat.fig_jiagou;
keep CONTRACT_NO BUSINESS_UNIT_SOURCE REGION_AREA_ CITY_CENTER REGION_CITYY_ BRANCH_NAME;
run;
proc sql;
create table pay_plan as
select
      a.*,
      b.*
from ccc a 
left join ziliao b
on a.CONTRACTNO=b.CONTRACT_NO;
quit;

/*�ջ���*/
proc sql;
create table sday as
select
      a.submit_date,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME,
      round(sum(amount)/10000,0.01) as day_pay
from pay_plan a 
group by submit_date,BUSINESS_UNIT_SOURCE,REGION_AREA_,BRANCH_NAME;
quit;
/*�»���*/
data fig_my;
set sday;
year=year(submit_date);
dmonth=month(submit_date);
if dmonth<10 then ddmonth=compress("0"||dmonth); else ddmonth=dmonth;
month=input(compress(year||ddmonth),12.);
drop dmonth ddmonth;
run;
proc sql;
create table smonth as
select
      a.month,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME,
      round(sum(day_pay),0.01) as mon_pay
from fig_my a 
group by month,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME;
quit;
proc sort data=smonth out=smonth;
by month;
run;
/*�����*/
/*proc sql;*/
/*create table syear as*/
/*select*/
/*      a.year,*/
/*      sum(day_sum) as year_sum*/
/*from fig_my a */
/*group by year;*/
/*quit;*/
/*����������*/
/*data symd;*/
/*merge sday smonth syear;*/
/*run;*/
/*�����ֶ�����label*/
/*data symd;*/
/*set symd(rename=(submit_date=day));*/
/*label day="��" day_sum="����" month="��" month_sum="����" year="��" year_sum="����";*/
/*run;*/
/* ���*/
PROC EXPORT DATA=smonth OUTFILE="E:\source_data\ʵ�ʻؿ���&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;




















