%let path=E:\basic_data;/*基础数据路径*/
%let today="21Jul2016"d;
%let mytoday=20160721;/*用于输出文件名的标识*/
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
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
/*应还期数*/
data dis;
set dis;
m0=intck("month",loan_date,&today);
d0=day(&today);
pay_day=day(loan_date);/*还款日*/
if d0>=pay_day then sh_pay_peri=m0;else sh_pay_peri=m0-1;
if sh_pay_peri>=periods_num then sh_pay_peri=periods_num;/*应还期数不能超过期数*/
if loan_date<=&today.;/*放款日在今天之前（包括）*/
drop m0 d0 pay_day;
run;
/*****************************************************生成还款计划dis**************************************************************************/
data dis;/*生成每期扣款日期*/
set dis;
array term(60);
do i=1 to periods_num;
	term(i)=intnx("month",loan_date,i,"sameday");
end;
format term1-term60 yymmdd10.;
drop i;
run;

/******************************************************生成还款流水liushui************************************************************************/
/*读入，预处理payment表*/
%read_tablen(&path,数据汇总（有重复）,汇总,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
/*删除流水中的重复值*/
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;
/*流水转置*/
proc sql;
create table pay1 as
select
      a.*,
	  sum(amount) as amount1
from pay a
group by submit_date,CONTRACTNO;/*(提交日期 合同编号)*/
quit;
proc sort data=pay1 nodupkey;/*一个客户一天合并为一笔*/
by  submit_date CONTRACTNO;
run;
proc sort data=pay1 out=aaa;
by contractno;
proc transpose data=aaa out=bbb let;/*转置每一笔的还款日期*/
by contractno;
var submit_date;
run;
data bbbb;
set bbb(rename=(COL1=d1 COL2=d2 COL3=d3 COL4=d4 COL5=d5 COL6=d6 COL7=d7 COL8=d8 COL9=d9 COL10=d10 COL11=d11 COL12=d12 COL13=d13 COL14=d14 COL15=d15 COL16=d16 COL17=d17 COL18=d18 COL19=d19 COL20=d20 COL21=d21));
drop _NAME_ _LABEL_;
label d1='第一笔还款日期' d2='第二笔还款日期' d3='第三笔还款日期' d4='第四笔还款日期' d5='第五笔还款日期' d6='第六笔还款日期' d7='第七笔还款日期'
      d8='第八笔还款日期' d9='第九笔还款日期' d10='第十笔还款日期' d11='第十一笔还款日期' d12='第十二笔还款日期' d13='第十三笔还款日期' d14='第十四笔还款日期'
      d15='第十五笔还款日期' d16='第十六笔还款日期' d17='第十七笔还款日期' d18='第十八笔还款日期' d19='第十九笔还款日期' d20='第二十笔还款日期' d21='第二十一笔还款日期';
run;
proc transpose data=aaa out=ccc let;/*装置每一笔的还款金额*/
by contractno;
var amount;
run;
data cccc;
set ccc(rename=(COL1=a1 COL2=a2 COL3=a3 COL4=a4 COL5=a5 COL6=a6 COL7=a7 COL8=a8 COL9=a9 COL10=a10 COL11=a11 COL12=a12 COL13=a13 COL14=a14 COL15=a15 COL16=a16 COL17=a17 COL18=a18 COL19=a19 COL20=a20 COL21=a21));
drop _NAME_ _LABEL_;
label a1='第一笔还款金额' a2='第二笔还款金额' a3='第三笔还款金额' a4='第四笔还款金额' a5='第五笔还款金额' a6='第六笔还款金额' a7='第七笔还款金额'
      a8='第八笔还款金额' a9='第九笔还款金额' a10='第十笔还款金额' a11='第十一笔还款金额' a12='第十二笔还款金额' a13='第十三笔还款金额' a14='第十四笔还款金额'
      a15='第十五笔还款金额' a16='第十六笔还款金额' a17='第十七笔还款金额'a18='第十八笔还款金额' a19='第十九笔还款金额' a20='第二十笔还款金额' a21='第二十一笔还款金额';
run;
data liushui;
merge bbbb cccc;
run;
data liushui;
retain contractno d1 a1 d2 a2 d3 a3 d4 a4 d5 a5 d6 a6 d7 a7 d8 a8 d9 a9 d10 a10 d11 a11 d12 a12 d13 a13 d14 a14 d15 a15 d16 a16 d17 a17 d18 a18 d19 a19 d20 a20 d21 a21 ;
set liushui;
run;/*转置流水完毕*/


/*删除结清客户*/
/******************************************************************************************************************/
/*提前结清客户*/
data tiqian;
set pay;
if comment in ("全款收完","全部结清","全额结清","全款结清") then output;
run;
/*期数正常结束*/
data zhengchang;
set pay; 
comment=compress(comment);
a=index(comment,"扣款")+4;
b=index(comment,"期");
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
run;/*已删结清客户，应还期数>=6*/
/****************************************************目标客户连上还款流水*******************************************************************************************/
proc sql;
create table zhangwu as
select
      a.*,
	  b.*
from dis_test a
left join liushui b
on a.CONTRACT_NO=b.CONTRACTNO;
quit;

data part1;/*应还期数为6*/
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
data part2;/*应还期数为7*/
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
data part3;/*应还期数为8*/
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
data part4;/*应还期数为9*/
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
data part5;/*应还期数为10*/
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
data part6;/*应还期数为11*/
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
data part7;/*应还期数为12*/
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
data part8;/*应还期数为13*/
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
if product_name in ('小牛工薪贷','工薪贷','非深圳工薪贷','小牛精英贷','精英贷') then output;
run;

PROC EXPORT DATA=part OUTFILE="E:\source_data\续贷客户&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
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
%mend fenqi;/*出表(2013版excel)宏*/
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
xx=o1-&today.;/*还款计划的日期和今天的日期可以正常相减*/
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
xx=o1-&today.;/*还款计划的日期和今天的日期可以正常相减*/
keep xx contract_no o1 term1 o2 term2 o13 term13;
run;

/*应还期数*/
data all;
set all;
m0=intck("month",loan_date,&today);
d0=day(&today);
pay_day=day(loan_date);/*还款日*/
if d0>=pay_day then sh_pay_peri=m0;else sh_pay_peri=m0-1;
if sh_pay_peri>=periods_num then sh_pay_peri=periods_num;/*应还期数不能超过期数*/
drop m0 d0;
run;

/*读入，预处理payment表*/
%read_tablen(&path,数据汇总（有重复）,汇总,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
/*删除流水中的重复值*/
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;
data pay;
set pay;
if submit_date<=&today then output;/*缴款日在今天之前（包括）*/
run;
/*流水转置*/
proc sql;
create table pay1 as
select
      a.*,
	  sum(amount) as amount1
from pay a
group by submit_date,CONTRACTNO;/*(提交日期 合同编号)*/
quit;
proc sort data=pay1 nodupkey;/*一个客户一天合并为一笔*/
by  submit_date CONTRACTNO;
run;
proc sort data=pay1 out=aaa;
by contractno;
proc transpose data=aaa out=bbb let;/*转置每一笔的还款日期*/
by contractno;
var submit_date;
run;
data bbbb;
set bbb(rename=(COL1=d1 COL2=d2 COL3=d3 COL4=d4 COL5=d5 COL6=d6 COL7=d7 COL8=d8 COL9=d9 COL10=d10 COL11=d11 COL12=d12 COL13=d13 COL14=d14 COL15=d15 COL16=d16 COL17=d17 COL18=d18 COL19=d19 COL20=d20 COL21=d21));
drop _NAME_ _LABEL_;
label d1='第一笔还款日期' d2='第二笔还款日期' d3='第三笔还款日期' d4='第四笔还款日期' d5='第五笔还款日期' d6='第六笔还款日期' d7='第七笔还款日期'
      d8='第八笔还款日期' d9='第九笔还款日期' d10='第十笔还款日期' d11='第十一笔还款日期' d12='第十二笔还款日期' d13='第十三笔还款日期' d14='第十四笔还款日期'
      d15='第十五笔还款日期' d16='第十六笔还款日期' d17='第十七笔还款日期' d18='第十八笔还款日期' d19='第十九笔还款日期' d20='第二十笔还款日期' d21='第二十一笔还款日期';
run;
proc transpose data=aaa out=ccc let;/*装置每一笔的还款金额*/
by contractno;
var amount;
run;
data cccc;
set ccc(rename=(COL1=a1 COL2=a2 COL3=a3 COL4=a4 COL5=a5 COL6=a6 COL7=a7 COL8=a8 COL9=a9 COL10=a10 COL11=a11 COL12=a12 COL13=a13 COL14=a14 COL15=a15 COL16=a16 COL17=a17 COL18=a18 COL19=a19 COL20=a20 COL21=a21));
drop _NAME_ _LABEL_;
label a1='第一笔还款金额' a2='第二笔还款金额' a3='第三笔还款金额' a4='第四笔还款金额' a5='第五笔还款金额' a6='第六笔还款金额' a7='第七笔还款金额'
      a8='第八笔还款金额' a9='第九笔还款金额' a10='第十笔还款金额' a11='第十一笔还款金额' a12='第十二笔还款金额' a13='第十三笔还款金额' a14='第十四笔还款金额'
      a15='第十五笔还款金额' a16='第十六笔还款金额' a17='第十七笔还款金额'a18='第十八笔还款金额' a19='第十九笔还款金额' a20='第二十笔还款金额' a21='第二十一笔还款金额';
run;
data liushui;
merge bbbb cccc;
run;
data liushui;
retain contractno d1 a1 d2 a2 d3 a3 d4 a4 d5 a5 d6 a6 d7 a7 d8 a8 d9 a9 d10 a10 d11 a11 d12 a12 d13 a13 d14 a14 d15 a15 d16 a16 d17 a17 d18 a18 d19 a19 d20 a20 d21 a21 ;
set liushui;
run;/*转置流水完毕*/
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
PROC EXPORT DATA=xxx OUTFILE="E:\source_data\今日回款客户_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
data aadata1;
set allx;
if sh_pay_peri=1 then do;/*当前应还期数为1*/
/**************************************没有还款流水********************************************************************/
	if d1=. then do;/*未还款*/
		overdue_dt1=term1;/*第一期逾期时间*/
		overdue_day1=&today.-term1;/*第一期逾期天数*/
		z1=(con_amount+sum(mon_int1+mon_man1))*0.001*overdue_day1;/*第一期滞纳金*/
	end;/*未还款*/
/**************************************只有一笔流水********************************************************************/
	if d1^=. and d2=. then do;/*<part1>*/
		if d1>term1 then do;/*还款日期在应还款日期之后*/
			if mon_pay1-(a1+1)<0 then do;/*足额还款*/
				overdue_dt1=term1;/*第一期逾期时间*/
				overdue_day1=d1-term1;/*第一期逾期天数*/
				z1=(con_amount+sum(mon_int1+mon_man1))*0.001*overdue_day1;/*第一期滞纳金*/
			end;/*足额还款*/
			if mon_pay1-(a1+1)>0 then do;/*部分还款*/
				overdue_dt1=term1;/*第一期逾期时间*/
				overdue_day1=&today.-term1;/*第一期逾期天数*/
				z1=(con_amount+sum(mon_int1+mon_man1)-a1)*0.001*overdue_day1;/*第一期滞纳金*/
			end;/*部分还款*/
		end;/*还款日期在应还款日期之后*/
	end;/*</part1>*/
/**************************************只有两笔流水********************************************************************/
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
end;/*当前应还期数为1*/























if sh_pay_peri=2 then do;/*当前应还期数为2*/
	if d1=. then do;/*未还款*/
		overdue_dt1=term1;/*第一期逾期时间*/
		overdue_dt2=term2;/*第二期逾期时间*/
		overdue_day1=&today.-term1;/*第一期逾期天数*/
		overdue_day2=&today.-term2;/*第二期逾期天数*/
		z1=(con_amount+sum(mon_int1+mon_man1))*0.001*overdue_day1;/*第一期滞纳金*/
		z2=(con_amount+sum(mon_int1+mon_man1+mon_int2+mon_man2))*0.001*overdue_day2;/*第二期滞纳金*/
	end;/*未还款*/
end;

run;
data check;
set aadata1;
if sh_pay_peri=1 then output;
keep contract_no overdue_dt1 overdue_day1 z1;
run;
PROC EXPORT DATA=check OUTFILE="E:\source_data\check.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
/**************************************只有一笔流水********************************************************************/
	if d2=. then do;
		if d1<=term1 then do ;/*《1》*/
			if mon_pay1+mon_pay2-(a1+2)<0 then do;
				overdue_dt1=.;/*第一期逾期时间*/
				overdue_dt2=.;/*第二期逾期时间*/
				overdue_day1=.;/*第一期逾期天数*/
				overdue_day2=.;/*第二期逾期天数*/
				z1=.;/*第一期滞纳金*/
				z2=.;/*第二期滞纳金*/
			end;
			 
		end;/*《1》*/
		if term1<d1<= then do ;/*《2》*/
		end;/*《2》*/
		if d1<=term1 then do ;/*《3》*/
		end;/*《3》*/
	end;
end;/*当前应还期数为2*/
