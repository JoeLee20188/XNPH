%let path=D:\basic_data;/*��������·��*/
%let today="03Nov2016"d;
%let mytoday=20161103;/*��������ļ����ı�ʶ*/
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
/*ɾ������*/
data dis;
set dis;
if product_name='����ͨ' then delete;
run;
/*����ͻ�*/
/*��ǰ����ͻ�*/
data all_1;
set dat.pay;
if comment in ("ȫ������","ȫ������","ȫ�����","ȫ�����") then output;
run;
data fig;
set all_1;
keep contractno submit_date;
run;








/*������������*/
/*data all_2;*/
/*set dat.pay; */
/*comment=compress(comment);*/
/*a=index(comment,"�ۿ�")+4;*/
/*b=index(comment,"��");*/
/*term=input(substr(comment,a,b-a),$66.);*/
/*if term in ("3/3","6/6","9/9","12/12","15/15","18/18","24/24") then output;*/
/*drop a b term;*/
/*run;*/
/*data all;*/
/*set all_1 all_2;*/
/*run;*/
/*proc sort data=all nodupkey;*/
/*by contractno;*/
/*run;*/
/*proc sql;*/
/*create table dis as*/
/*select*/
/*      a.*,*/
/*      b.submit_date*/
/*from dis a */
/*left join all b*/
/*on a.CONTRACT_NO=b.CONTRACTNO;*/
/*quit;*/
/*data dis;*/
/*set dis;*/
/*if submit_date^='' then delete;*/
/*drop submit_date;*/
/*run;*/

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
/*****************************************************���ɻ���ƻ�**************************************************************************/
data dis;/*����ÿ�ڿۿ�����*/
set dis;
array term(60);
do i=1 to periods_num;
	term(i)=intnx("month",loan_date,i,"sameday");
end;
format term1-term60 yymmdd10.;
drop i;
run;
%macro fenqi(term);
data a&term.;
set dis;
num=&term.;
keep CONTRACT_NO sh_pay_peri con_amount num term&term. mon_pay mon_pri	mon_int	mon_man;
if term&term.^=. then output;
rename term&term.=term;
run;
quit;
%mend fenqi;/*����(2013��excel)��*/
%fenqi(1);%fenqi(2);%fenqi(3);%fenqi(4);%fenqi(5);%fenqi(6);%fenqi(7);%fenqi(8);%fenqi(9);%fenqi(10);%fenqi(11);%fenqi(12);%fenqi(13);%fenqi(14);%fenqi(15);
%fenqi(16);%fenqi(17);%fenqi(18);%fenqi(19);%fenqi(20);%fenqi(21);%fenqi(22);%fenqi(23);%fenqi(24);%fenqi(25);%fenqi(26);%fenqi(27);%fenqi(28);%fenqi(29);%fenqi(30);
%fenqi(31);%fenqi(32);%fenqi(33);%fenqi(34);%fenqi(35);%fenqi(36);
data pay_plan;
set a1 a2 a3 a4 a5 a6 a7 a8 a9 a10
      a11 a12 a13 a14 a15 a16 a17 a18 a19 a20
      a21 a22 a23 a24 a25 a26 a27 a28 a29 a30
      a31 a32 a33 a34 a35 a36;
run;
/*������ǰ�����*/
proc sql;
create table fig1 as
select
      a.*,b.submit_date
from pay_plan a left join fig b on a.contract_no=b.contractno;
quit;
data pay_plan1;
set fig1;
if submit_date=. then output;
run;
data pay_plan2;
set fig1;
if submit_date^=. then output;
run;
data pay_plan22;
set pay_plan2;
if term>=submit_date then delete;
run;
data pay_plan;
set pay_plan1 pay_plan22;
drop submit_date;
run;

/*�ջ���*/
proc sql;
create table sday as
select
      a.term,
      round(sum(mon_pay)/10000,0.01) as day_pay,
	  round(sum(mon_pri)/10000,0.01) as day_pri,
	  round(sum(mon_int)/10000,0.01) as day_int,
	  round(sum(mon_man)/10000,0.01) as day_man
from pay_plan a 
group by term;
quit;
/*�»���*/
data fig_my;
set sday;
year=year(term);
dmonth=month(term);
if dmonth<10 then ddmonth=compress("0"||dmonth); else ddmonth=dmonth;
month=input(compress(year||ddmonth),12.);
drop dmonth ddmonth;
run;
proc sql;
create table smonth as
select
      a.month,
      round(sum(day_pay),0.01) as mon_pay,
	  round(sum(day_pri),0.01) as mon_pri,
	  round(sum(day_int),0.01) as mon_int,
	  round(sum(day_man),0.01) as mon_man
from fig_my a 
group by month;
quit;
proc sort data=smonth out=smonth;
by month;
run;
/*�����*/
proc sql;
create table syear as
select
      a.year,
      round(sum(day_pay),0.01) as year_pay,
	  round(sum(day_pri),0.01) as year_pri,
	  round(sum(day_int),0.01) as year_int,
	  round(sum(day_man),0.01) as year_man
from fig_my a 
group by year;
quit;
/*����������*/
data symd;
merge sday smonth syear;
run;
data demo01;
set symd;
keep term day_pay day_pri day_int day_man;
run;
PROC EXPORT DATA=demo01 OUTFILE="E:\echart_excel_to_mysql\ծȨ���Ѳ��_ÿ�գ�&mytoday.xlsx" DBMS=EXCEL;
RUN;
/*�����ֶ�����label*/
data symd;
set symd(rename=(term=day));
label day="��" month="��" year="��" day_pay="����" day_pri="�ձ�����" day_int="����Ϣ��" day_man="�չ������" mon_pay="����" mon_pri="�±�����" mon_int="����Ϣ��" mon_man="�¹������" year_pay="����" year_pri="�걾����" year_int="����Ϣ��" year_man="��������";
run;
PROC EXPORT DATA=symd OUTFILE="E:\source_data\���ۻؿ���(ɾ������������)&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;

