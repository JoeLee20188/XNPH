%let path=D:\basic_data;/*基础数据路径*/
%let today="24Nov2016"d;/*要先保证有今天的数据集*/
%let mytoday=20161124;/*用于输出文件名的标识*/
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
/*%read_tablen(&path,new_xn_dis,导出工作表,dis_2);*/
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
data pay;
set dat.pay;
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
set bbb(rename=(COL1=d1 COL2=d2 COL3=d3 COL4=d4 COL5=d5 COL6=d6 COL7=d7 COL8=d8 COL9=d9 COL10=d10 COL11=d11 COL12=d12 COL13=d13 COL14=d14 COL15=d15 COL16=d16 COL17=d17 COL18=d18 COL19=d19 COL20=d20 COL21=d21 COL22=d22 COL23=d23 COL24=d24 COL25=d25 COL26=d26));
drop _NAME_ _LABEL_;
label d1='第一笔还款日期' d2='第二笔还款日期' d3='第三笔还款日期' d4='第四笔还款日期' d5='第五笔还款日期' d6='第六笔还款日期' d7='第七笔还款日期'
      d8='第八笔还款日期' d9='第九笔还款日期' d10='第十笔还款日期' d11='第十一笔还款日期' d12='第十二笔还款日期' d13='第十三笔还款日期' d14='第十四笔还款日期'
      d15='第十五笔还款日期' d16='第十六笔还款日期' d17='第十七笔还款日期' d18='第十八笔还款日期' d19='第十九笔还款日期' d20='第二十笔还款日期' d21='第二十一笔还款日期' 
      d22='第二十二笔还款日期' d23='第二十三笔还款日期' d24='第二十四笔还款日期' d25='第二十五笔还款日期' d26='第二十六笔还款日期';
run;
proc transpose data=aaa out=ccc let;/*装置每一笔的还款金额*/
by contractno;
var amount1;
run;
data cccc;
set ccc(rename=(COL1=a1 COL2=a2 COL3=a3 COL4=a4 COL5=a5 COL6=a6 COL7=a7 COL8=a8 COL9=a9 COL10=a10 COL11=a11 COL12=a12 COL13=a13 COL14=a14 COL15=a15 COL16=a16 COL17=a17 COL18=a18 COL19=a19 COL20=a20 COL21=a21 COL22=a22 COL23=a23 COL24=a24 COL25=a25 COL26=a26));
drop _NAME_ _LABEL_;
label a1='第一笔还款金额' a2='第二笔还款金额' a3='第三笔还款金额' a4='第四笔还款金额' a5='第五笔还款金额' a6='第六笔还款金额' a7='第七笔还款金额'
      a8='第八笔还款金额' a9='第九笔还款金额' a10='第十笔还款金额' a11='第十一笔还款金额' a12='第十二笔还款金额' a13='第十三笔还款金额' a14='第十四笔还款金额'
      a15='第十五笔还款金额' a16='第十六笔还款金额' a17='第十七笔还款金额'a18='第十八笔还款金额' a19='第十九笔还款金额' a20='第二十笔还款金额' a21='第二十一笔还款金额'
      a22='第二十二笔还款金额' a23='第二十三笔还款金额' a24='第二十四笔还款金额' a25='第二十五笔还款金额' a26='第二十六笔还款金额';
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
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and/*修正客户有很多笔还款，但在前面几期应还日期之后，按下面的规则，逾期的客户也会出来*/
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
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
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
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
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
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
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
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
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
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
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
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
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
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   term13>=d13 and a13+1>=mon_pay and
   term12>=d12 and a12+1>=mon_pay and
   term11>=d11 and a11+1>=mon_pay and
   term10>=d10 and a10+1>=mon_pay and
   term9>=d9 and a9+1>=mon_pay and
   term8>=d8 and a8+1>=mon_pay 
then output;
run;
data part9;/*应还期数为14*/
set zhangwu;
if sh_pay_peri=14 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   term14>=d14 and a14+1>=mon_pay and
   term13>=d13 and a13+1>=mon_pay and
   term12>=d12 and a12+1>=mon_pay and
   term11>=d11 and a11+1>=mon_pay and
   term10>=d10 and a10+1>=mon_pay and
   term9>=d9 and a9+1>=mon_pay 
then output;
run;
data part10;/*应还期数为15*/
set zhangwu;
if sh_pay_peri=15 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   term15>=d15 and a15+1>=mon_pay and
   term14>=d14 and a14+1>=mon_pay and
   term13>=d13 and a13+1>=mon_pay and
   term12>=d12 and a12+1>=mon_pay and
   term11>=d11 and a11+1>=mon_pay and
   term10>=d10 and a10+1>=mon_pay 
then output;
run;
data part11;/*应还期数为16*/
set zhangwu;
if sh_pay_peri=16 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   term16>=d16 and a16+1>=mon_pay and
   term15>=d15 and a15+1>=mon_pay and
   term14>=d14 and a14+1>=mon_pay and
   term13>=d13 and a13+1>=mon_pay and
   term12>=d12 and a12+1>=mon_pay and
   term11>=d11 and a11+1>=mon_pay 
then output;
run;
data part12;/*应还期数为17*/
set zhangwu;
if sh_pay_peri=17 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   term17>=d17 and a17+1>=mon_pay and
   term16>=d16 and a16+1>=mon_pay and
   term15>=d15 and a15+1>=mon_pay and
   term14>=d14 and a14+1>=mon_pay and
   term13>=d13 and a13+1>=mon_pay and
   term12>=d12 and a12+1>=mon_pay 
then output;
run;
data part13;/*应还期数为18*/
set zhangwu;
if sh_pay_peri=18 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   term18>=d18 and a18+1>=mon_pay and
   term17>=d17 and a17+1>=mon_pay and
   term16>=d16 and a16+1>=mon_pay and
   term15>=d15 and a15+1>=mon_pay and
   term14>=d14 and a14+1>=mon_pay and
   term13>=d13 and a13+1>=mon_pay
then output;
run;
data part14;/*应还期数为19*/
set zhangwu;
if sh_pay_peri=19 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+19>=mon_pay*19 and
   term19>=d19 and a19+1>=mon_pay and
   term18>=d18 and a18+1>=mon_pay and
   term17>=d17 and a17+1>=mon_pay and
   term16>=d16 and a16+1>=mon_pay and
   term15>=d15 and a15+1>=mon_pay and
   term14>=d14 and a14+1>=mon_pay 
then output;
run;
data part15;/*应还期数为20*/
set zhangwu;
if sh_pay_peri=20 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+19>=mon_pay*19 and
   a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+20>=mon_pay*20 and
   term20>=d20 and a20+1>=mon_pay and
   term19>=d19 and a19+1>=mon_pay and
   term18>=d18 and a18+1>=mon_pay and
   term17>=d17 and a17+1>=mon_pay and
   term16>=d16 and a16+1>=mon_pay and
   term15>=d15 and a15+1>=mon_pay 
then output;
run;
data part16;/*应还期数为21*/
set zhangwu;
if sh_pay_peri=21 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+19>=mon_pay*19 and
   a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+20>=mon_pay*20 and
   a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+21>=mon_pay*21 and
   term21>=d21 and a21+1>=mon_pay and
   term20>=d20 and a20+1>=mon_pay and
   term19>=d19 and a19+1>=mon_pay and
   term18>=d18 and a18+1>=mon_pay and
   term17>=d17 and a17+1>=mon_pay and
   term16>=d16 and a16+1>=mon_pay 
then output;
run;
data part17;/*应还期数为22*/
set zhangwu;
if sh_pay_peri=22 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+19>=mon_pay*19 and
   a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+20>=mon_pay*20 and
   a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+22>=mon_pay*22 and
   term22>=d22 and a22+1>=mon_pay and
   term21>=d21 and a21+1>=mon_pay and
   term20>=d20 and a20+1>=mon_pay and
   term19>=d19 and a19+1>=mon_pay and
   term18>=d18 and a18+1>=mon_pay and
   term17>=d17 and a17+1>=mon_pay 
then output;
run;
data part18;/*应还期数为23*/
set zhangwu;
if sh_pay_peri=23 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+19>=mon_pay*19 and
   a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+20>=mon_pay*20 and
   a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+22>=mon_pay*22 and
   a23+a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+23>=mon_pay*23 and
   term23>=d23 and a23+1>=mon_pay and
   term22>=d22 and a22+1>=mon_pay and
   term21>=d21 and a21+1>=mon_pay and
   term20>=d20 and a20+1>=mon_pay and
   term19>=d19 and a19+1>=mon_pay and
   term18>=d18 and a18+1>=mon_pay 
then output;
run;
data part19;/*应还期数为24*/
set zhangwu;
if sh_pay_peri=24 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+19>=mon_pay*19 and
   a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+20>=mon_pay*20 and
   a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+22>=mon_pay*22 and
   a24+a23+a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+24>=mon_pay*24 and
   term24>=d24 and a24+1>=mon_pay and
   term23>=d23 and a23+1>=mon_pay and
   term22>=d22 and a22+1>=mon_pay and
   term21>=d21 and a21+1>=mon_pay and
   term20>=d20 and a20+1>=mon_pay and
   term19>=d19 and a19+1>=mon_pay 
then output;
run;
data part20;/*应还期数为25*/
set zhangwu;
if sh_pay_peri=25 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+19>=mon_pay*19 and
   a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+20>=mon_pay*20 and
   a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+22>=mon_pay*22 and
   a24+a23+a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+24>=mon_pay*24 and
   a25+a24+a23+a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+25>=mon_pay*25 and
   term25>=d25 and a25+1>=mon_pay and
   term24>=d24 and a24+1>=mon_pay and
   term23>=d23 and a23+1>=mon_pay and
   term22>=d22 and a22+1>=mon_pay and
   term21>=d21 and a21+1>=mon_pay and
   term20>=d20 and a20+1>=mon_pay 
then output;
run;
data part21;/*应还期数为26*/
set zhangwu;
if sh_pay_peri=26 and
   a1+1>=mon_pay and 
   a2+a1+2>=mon_pay*2 and 
   a3+a2+a1+3>=mon_pay*3 and 
   a4+a3+a2+a1+4>=mon_pay*4 and
   a5+a4+a3+a2+a1+5>=mon_pay*5 and
   a6+a5+a4+a3+a2+a1+6>=mon_pay*6 and
   a7+a6+a5+a4+a3+a2+a1+7>=mon_pay*7 and
   a8+a7+a6+a5+a4+a3+a2+a1+8>=mon_pay*8 and
   a9+a8+a7+a6+a5+a4+a3+a2+a1+9>=mon_pay*9 and
   a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+10>=mon_pay*10 and
   a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+11>=mon_pay*11 and
   a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+12>=mon_pay*12 and
   a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+13>=mon_pay*13 and
   a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+14>=mon_pay*14 and
   a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+15>=mon_pay*15 and
   a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+16>=mon_pay*16 and
   a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+17>=mon_pay*17 and
   a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+18>=mon_pay*18 and
   a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+19>=mon_pay*19 and
   a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+20>=mon_pay*20 and
   a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+22>=mon_pay*22 and
   a24+a23+a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+24>=mon_pay*24 and
   a25+a24+a23+a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+25>=mon_pay*25 and
   a26+a25+a24+a23+a22+a21+a20+a19+a18+a17+a16+a15+a14+a13+a12+a11+a10+a9+a8+a7+a6+a5+a4+a3+a2+a1+26>=mon_pay*26 and
   term26>=d26 and a26+1>=mon_pay and
   term25>=d25 and a25+1>=mon_pay and
   term24>=d24 and a24+1>=mon_pay and
   term23>=d23 and a23+1>=mon_pay and
   term22>=d22 and a22+1>=mon_pay and
   term21>=d21 and a21+1>=mon_pay 
then output;
run;/*公司开业到现在2年2个月*/

data part;
set part1 part2 part3 part4 part5 part6 part7 part8 part9 part10 part11 part12 part13 part14 part15 part16 part17 part18 part19 part20 part21;
if product_name in ('工薪贷','小牛工薪贷','消费贷','精英贷','小牛精英贷','专业贷') then output;/*产品部提出的产品限制*/
keep CONTRACT_NO d1-d12 a1-a12 term1-term12;
run;
data part;
set part;
if substr(CONTRACT_NO,1,1)="0" or substr(CONTRACT_NO,1,1)="1" or substr(CONTRACT_NO,1,1)="2" then output; /*产品部提出的系统限制*/
run;
data info;
set dat.quanbu_cust&mytoday.;
keep sys CONTRACT_NO cust_name product_name ID_NUM GENDER loan_amount con_amount mon_pay periods_num con_yue daishou_yue prin_yue loan_date pay_day	
     sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay MOBILE mon_man mon_int;
run;
/*连级别*/
data ziliao;
set dat.fig_jiagou;
keep CONTRACT_NO BUSINESS_UNIT_SOURCE REGION_AREA_ CITY_CENTER REGION_CITYY_ BRANCH_NAME;
run;
proc sort data=ziliao dupout=check nodupkey;
by contract_no;
run;
proc sql;
create table part as
select
      a.*,
      b.*
from part a 
left join ziliao b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;
data info;/*计算已还本金*/
set info;
a=(mon_man+mon_int)*sh_pay_peri;
al_pay_pri=sh_pay_sum-a;
label al_pay_pri='已还本金';
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
data final;
set final;
label 
	BUSINESS_UNIT_SOURCE='事业部' 
	REGION_AREA_='区域'
	CITY_CENTER='城市分中心' 
	REGION_CITYY_='城市' 
	BRANCH_NAME='营业部'
	CONTRACT_NO='合同编号';
run;
data final;/*排序*/
retain sys BUSINESS_UNIT_SOURCE REGION_AREA_ CITY_CENTER REGION_CITYY_ BRANCH_NAME CONTRACT_NO cust_name product_name ID_NUM GENDER loan_amount con_amount mon_pay periods_num con_yue daishou_yue prin_yue loan_date pay_day	
     sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay MOBILE al_pay_pri;
set final;
run;
PROC EXPORT DATA=final OUTFILE="E:\source_data\追加贷（一期）客户&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
