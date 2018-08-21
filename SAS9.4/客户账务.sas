%let path=E:\basic_data;/*��������·��*/
%let today="21Jul2016"d;
%let mytoday=20160721;/*��������ļ����ı�ʶ*/
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
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
%read_tablen(&path,���ݻ��ܣ����ظ���,����,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
/*ɾ����ˮ�е��ظ�ֵ*/
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
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
set bbb(rename=(COL1=d1 COL2=d2 COL3=d3 COL4=d4 COL5=d5 COL6=d6 COL7=d7 COL8=d8 COL9=d9 COL10=d10 COL11=d11 COL12=d12 COL13=d13 COL14=d14 COL15=d15 COL16=d16 COL17=d17 COL18=d18 COL19=d19 COL20=d20 COL21=d21));
drop _NAME_ _LABEL_;
label d1='��һ�ʻ�������' d2='�ڶ��ʻ�������' d3='�����ʻ�������' d4='���ıʻ�������' d5='����ʻ�������' d6='�����ʻ�������' d7='���߱ʻ�������'
      d8='�ڰ˱ʻ�������' d9='�ھűʻ�������' d10='��ʮ�ʻ�������' d11='��ʮһ�ʻ�������' d12='��ʮ���ʻ�������' d13='��ʮ���ʻ�������' d14='��ʮ�ıʻ�������'
      d15='��ʮ��ʻ�������' d16='��ʮ���ʻ�������' d17='��ʮ�߱ʻ�������' d18='��ʮ�˱ʻ�������' d19='��ʮ�űʻ�������' d20='�ڶ�ʮ�ʻ�������' d21='�ڶ�ʮһ�ʻ�������';
run;
proc transpose data=aaa out=ccc let;/*װ��ÿһ�ʵĻ�����*/
by contractno;
var amount;
run;
data cccc;
set ccc(rename=(COL1=a1 COL2=a2 COL3=a3 COL4=a4 COL5=a5 COL6=a6 COL7=a7 COL8=a8 COL9=a9 COL10=a10 COL11=a11 COL12=a12 COL13=a13 COL14=a14 COL15=a15 COL16=a16 COL17=a17 COL18=a18 COL19=a19 COL20=a20 COL21=a21));
drop _NAME_ _LABEL_;
label a1='��һ�ʻ�����' a2='�ڶ��ʻ�����' a3='�����ʻ�����' a4='���ıʻ�����' a5='����ʻ�����' a6='�����ʻ�����' a7='���߱ʻ�����'
      a8='�ڰ˱ʻ�����' a9='�ھűʻ�����' a10='��ʮ�ʻ�����' a11='��ʮһ�ʻ�����' a12='��ʮ���ʻ�����' a13='��ʮ���ʻ�����' a14='��ʮ�ıʻ�����'
      a15='��ʮ��ʻ�����' a16='��ʮ���ʻ�����' a17='��ʮ�߱ʻ�����'a18='��ʮ�˱ʻ�����' a19='��ʮ�űʻ�����' a20='�ڶ�ʮ�ʻ�����' a21='�ڶ�ʮһ�ʻ�����';
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

data part1;/*Ӧ������Ϊ6*/
set zhangwu;
if sh_pay_peri=6 and
   term6>=d6 and a6+1>=mon_pay and 
   term5>=d5 and a5+1>=mon_pay and 
   term4>=d4 and a4+1>=mon_pay and 
   term3>=d3 and a3+1>=mon_pay and 
   term2>=d2 and a2+1>=mon_pay and
   term1>=d1 and a1+1>=mon_pay
then output;
run;
data part2;/*Ӧ������Ϊ7*/
set zhangwu;
if sh_pay_peri=7 and
   term7>=d7 and a7+1>=mon_pay and
   term6>=d6 and a6+1>=mon_pay and 
   term5>=d5 and a5+1>=mon_pay and 
   term4>=d4 and a4+1>=mon_pay and 
   term3>=d3 and a3+1>=mon_pay and 
   term2>=d2 and a2+1>=mon_pay 
then output;
run;
data part3;/*Ӧ������Ϊ8*/
set zhangwu;
if sh_pay_peri=8 and
   term8>=d8 and a8+1>=mon_pay and
   term7>=d7 and a7+1>=mon_pay and
   term6>=d6 and a6+1>=mon_pay and 
   term5>=d5 and a5+1>=mon_pay and 
   term4>=d4 and a4+1>=mon_pay and 
   term3>=d3 and a3+1>=mon_pay 
then output;
run;
data part4;/*Ӧ������Ϊ9*/
set zhangwu;
if sh_pay_peri=9 and
   term9>=d9 and a9+1>=mon_pay and
   term8>=d8 and a8+1>=mon_pay and
   term7>=d7 and a7+1>=mon_pay and
   term6>=d6 and a6+1>=mon_pay and 
   term5>=d5 and a5+1>=mon_pay and 
   term4>=d4 and a4+1>=mon_pay 
then output;
run;
data part5;/*Ӧ������Ϊ10*/
set zhangwu;
if sh_pay_peri=10 and
   term10>=d10 and a10+1>=mon_pay and
   term9>=d9 and a9+1>=mon_pay and
   term8>=d8 and a8+1>=mon_pay and
   term7>=d7 and a7+1>=mon_pay and
   term6>=d6 and a6+1>=mon_pay and 
   term5>=d5 and a5+1>=mon_pay 
then output;
run;
data part6;/*Ӧ������Ϊ11*/
set zhangwu;
if sh_pay_peri=11 and
   term11>=d11 and a11+1>=mon_pay and
   term10>=d10 and a10+1>=mon_pay and
   term9>=d9 and a9+1>=mon_pay and
   term8>=d8 and a8+1>=mon_pay and
   term7>=d7 and a7+1>=mon_pay and
   term6>=d6 and a6+1>=mon_pay 
then output;
run;
data part7;/*Ӧ������Ϊ12*/
set zhangwu;
if sh_pay_peri=12 and
   term12>=d12 and a12+1>=mon_pay and
   term11>=d11 and a11+1>=mon_pay and
   term10>=d10 and a10+1>=mon_pay and
   term9>=d9 and a9+1>=mon_pay and
   term8>=d8 and a8+1>=mon_pay and
   term7>=d7 and a7+1>=mon_pay 
then output;
run;
data part8;/*Ӧ������Ϊ13*/
set zhangwu;
if sh_pay_peri=13 and
   term13>=d13 and a13+1>=mon_pay and
   term12>=d12 and a12+1>=mon_pay and
   term11>=d11 and a11+1>=mon_pay and
   term10>=d10 and a10+1>=mon_pay and
   term9>=d9 and a9+1>=mon_pay and
   term8>=d8 and a8+1>=mon_pay 
then output;
run;

data part;
set part1 part2 part3 part4 part5 part6 part7;
if product_name in ('Сţ��н��','��н��','�����ڹ�н��','Сţ��Ӣ��','��Ӣ��') then output;
run;

PROC EXPORT DATA=part OUTFILE="E:\source_data\�����ͻ�&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;

























%macro fenqi(term);
data a&term.;
set dis;
num=&term.;
keep CONTRACT_NO sh_pay_peri con_amount num term&term. mon_pay mon_pri	mon_int	mon_man;
rename num=num&term. mon_pay=mon_pay&term. mon_pri=mon_pri&term. mon_int=mon_int&term. mon_man=mon_man&term.;
run;
proc sort data=a&term.;
by contract_no;
quit;
%mend fenqi;/*����(2013��excel)��*/
%fenqi(1);%fenqi(2);%fenqi(3);%fenqi(4);%fenqi(5);%fenqi(6);%fenqi(7);%fenqi(8);%fenqi(9);%fenqi(10);%fenqi(11);%fenqi(12);%fenqi(13);%fenqi(14);%fenqi(15);
%fenqi(16);%fenqi(17);%fenqi(18);%fenqi(19);%fenqi(20);%fenqi(21);%fenqi(22);%fenqi(23);%fenqi(24);%fenqi(25);%fenqi(26);%fenqi(27);%fenqi(28);%fenqi(29);%fenqi(30);
%fenqi(31);%fenqi(32);%fenqi(33);%fenqi(34);%fenqi(35);%fenqi(36);
data pay_plan;
merge a1 a2 a3 a4 a5 a6 a7 a8 a9 a10
      a11 a12 a13 a14 a15 a16 a17 a18 a19 a20
      a21 a22 a23 a24 a25 a26 a27 a28 a29 a30
      a31 a32 a33 a34 a35 a36;
by CONTRACT_NO;
run;




format o1 o2 o13 yymmdd10.;
xx=o1-&today.;/*����ƻ������ںͽ�������ڿ����������*/
keep xx contract_no o1 term1 o2 term2 o13 term13;

data all;
set all1 all2;
newdt=input(loan_date,yymmdd10.);
format newdt yymmdd10.;
drop loan_date;
run;

data all;
set all(rename=(newdt=loan_date));
o1=intnx("month",loan_date,1,"sameday");
o2=intnx("month",loan_date,2,"sameday");
o13=intnx("month",loan_date,13,"sameday");
format o1 o2 o13 yymmdd10.;
xx=o1-&today.;/*����ƻ������ںͽ�������ڿ����������*/
keep xx contract_no o1 term1 o2 term2 o13 term13;
run;

/*Ӧ������*/
data all;
set all;
m0=intck("month",loan_date,&today);
d0=day(&today);
pay_day=day(loan_date);/*������*/
if d0>=pay_day then sh_pay_peri=m0;else sh_pay_peri=m0-1;
if sh_pay_peri>=periods_num then sh_pay_peri=periods_num;/*Ӧ���������ܳ�������*/
drop m0 d0;
run;

/*���룬Ԥ����payment��*/
%read_tablen(&path,���ݻ��ܣ����ظ���,����,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
/*ɾ����ˮ�е��ظ�ֵ*/
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;
data pay;
set pay;
if submit_date<=&today then output;/*�ɿ����ڽ���֮ǰ��������*/
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
set bbb(rename=(COL1=d1 COL2=d2 COL3=d3 COL4=d4 COL5=d5 COL6=d6 COL7=d7 COL8=d8 COL9=d9 COL10=d10 COL11=d11 COL12=d12 COL13=d13 COL14=d14 COL15=d15 COL16=d16 COL17=d17 COL18=d18 COL19=d19 COL20=d20 COL21=d21));
drop _NAME_ _LABEL_;
label d1='��һ�ʻ�������' d2='�ڶ��ʻ�������' d3='�����ʻ�������' d4='���ıʻ�������' d5='����ʻ�������' d6='�����ʻ�������' d7='���߱ʻ�������'
      d8='�ڰ˱ʻ�������' d9='�ھűʻ�������' d10='��ʮ�ʻ�������' d11='��ʮһ�ʻ�������' d12='��ʮ���ʻ�������' d13='��ʮ���ʻ�������' d14='��ʮ�ıʻ�������'
      d15='��ʮ��ʻ�������' d16='��ʮ���ʻ�������' d17='��ʮ�߱ʻ�������' d18='��ʮ�˱ʻ�������' d19='��ʮ�űʻ�������' d20='�ڶ�ʮ�ʻ�������' d21='�ڶ�ʮһ�ʻ�������';
run;
proc transpose data=aaa out=ccc let;/*װ��ÿһ�ʵĻ�����*/
by contractno;
var amount;
run;
data cccc;
set ccc(rename=(COL1=a1 COL2=a2 COL3=a3 COL4=a4 COL5=a5 COL6=a6 COL7=a7 COL8=a8 COL9=a9 COL10=a10 COL11=a11 COL12=a12 COL13=a13 COL14=a14 COL15=a15 COL16=a16 COL17=a17 COL18=a18 COL19=a19 COL20=a20 COL21=a21));
drop _NAME_ _LABEL_;
label a1='��һ�ʻ�����' a2='�ڶ��ʻ�����' a3='�����ʻ�����' a4='���ıʻ�����' a5='����ʻ�����' a6='�����ʻ�����' a7='���߱ʻ�����'
      a8='�ڰ˱ʻ�����' a9='�ھűʻ�����' a10='��ʮ�ʻ�����' a11='��ʮһ�ʻ�����' a12='��ʮ���ʻ�����' a13='��ʮ���ʻ�����' a14='��ʮ�ıʻ�����'
      a15='��ʮ��ʻ�����' a16='��ʮ���ʻ�����' a17='��ʮ�߱ʻ�����'a18='��ʮ�˱ʻ�����' a19='��ʮ�űʻ�����' a20='�ڶ�ʮ�ʻ�����' a21='�ڶ�ʮһ�ʻ�����';
run;
data liushui;
merge bbbb cccc;
run;
data liushui;
retain contractno d1 a1 d2 a2 d3 a3 d4 a4 d5 a5 d6 a6 d7 a7 d8 a8 d9 a9 d10 a10 d11 a11 d12 a12 d13 a13 d14 a14 d15 a15 d16 a16 d17 a17 d18 a18 d19 a19 d20 a20 d21 a21 ;
set liushui;
run;/*ת����ˮ���*/
proc sql;
create table allx as
select
      a.*,
	  b.*
from pay_plan a
left join liushui b
on a.contract_no=b.contractno;
quit;
data dat.kehuzhangwu;
set allx;
run;
PROC EXPORT DATA=xxx OUTFILE="E:\source_data\���ջؿ�ͻ�_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
data aadata1;
set allx;
if sh_pay_peri=1 then do;/*��ǰӦ������Ϊ1*/
/**************************************û�л�����ˮ********************************************************************/
	if d1=. then do;/*δ����*/
		overdue_dt1=term1;/*��һ������ʱ��*/
		overdue_day1=&today.-term1;/*��һ����������*/
		z1=(con_amount+sum(mon_int1+mon_man1))*0.001*overdue_day1;/*��һ�����ɽ�*/
	end;/*δ����*/
/**************************************ֻ��һ����ˮ********************************************************************/
	if d1^=. and d2=. then do;/*<part1>*/
		if d1>term1 then do;/*����������Ӧ��������֮��*/
			if mon_pay1-(a1+1)<0 then do;/*����*/
				overdue_dt1=term1;/*��һ������ʱ��*/
				overdue_day1=d1-term1;/*��һ����������*/
				z1=(con_amount+sum(mon_int1+mon_man1))*0.001*overdue_day1;/*��һ�����ɽ�*/
			end;/*����*/
			if mon_pay1-(a1+1)>0 then do;/*���ֻ���*/
				overdue_dt1=term1;/*��һ������ʱ��*/
				overdue_day1=&today.-term1;/*��һ����������*/
				z1=(con_amount+sum(mon_int1+mon_man1)-a1)*0.001*overdue_day1;/*��һ�����ɽ�*/
			end;/*���ֻ���*/
		end;/*����������Ӧ��������֮��*/
	end;/*</part1>*/
/**************************************ֻ��������ˮ********************************************************************/
	if d2^=. and d3=. then do;/*<part2>*/
		if d2<=term1 then do;
			if mon_pay1-(a1+a2+1)<0 then do;
				
			end;
		end;
		if d1>=term1 then do;
			if mon_pay1-(a1+a2+1)<=0 then do;
				
			end;
		end;
	end;/*</part2>*/
end;/*��ǰӦ������Ϊ1*/























if sh_pay_peri=2 then do;/*��ǰӦ������Ϊ2*/
	if d1=. then do;/*δ����*/
		overdue_dt1=term1;/*��һ������ʱ��*/
		overdue_dt2=term2;/*�ڶ�������ʱ��*/
		overdue_day1=&today.-term1;/*��һ����������*/
		overdue_day2=&today.-term2;/*�ڶ�����������*/
		z1=(con_amount+sum(mon_int1+mon_man1))*0.001*overdue_day1;/*��һ�����ɽ�*/
		z2=(con_amount+sum(mon_int1+mon_man1+mon_int2+mon_man2))*0.001*overdue_day2;/*�ڶ������ɽ�*/
	end;/*δ����*/
end;

run;
data check;
set aadata1;
if sh_pay_peri=1 then output;
keep contract_no overdue_dt1 overdue_day1 z1;
run;
PROC EXPORT DATA=check OUTFILE="E:\source_data\check.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
/**************************************ֻ��һ����ˮ********************************************************************/
	if d2=. then do;
		if d1<=term1 then do ;/*��1��*/
			if mon_pay1+mon_pay2-(a1+2)<0 then do;
				overdue_dt1=.;/*��һ������ʱ��*/
				overdue_dt2=.;/*�ڶ�������ʱ��*/
				overdue_day1=.;/*��һ����������*/
				overdue_day2=.;/*�ڶ�����������*/
				z1=.;/*��һ�����ɽ�*/
				z2=.;/*�ڶ������ɽ�*/
			end;
			 
		end;/*��1��*/
		if term1<d1<= then do ;/*��2��*/
		end;/*��2��*/
		if d1<=term1 then do ;/*��3��*/
		end;/*��3��*/
	end;
end;/*��ǰӦ������Ϊ2*/
