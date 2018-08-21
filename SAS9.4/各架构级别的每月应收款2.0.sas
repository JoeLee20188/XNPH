%let path=D:\basic_data;/*基础数据路径*/
%let today="30Nov2016"d;/*计算到应还期数*/
%let mytoday=20161114;/*用于输出文件名的标识*/
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
if d0>=pay_day then sh_pay_peri=m0;
/*else sh_pay_peri=m0-1;*//*当今天的日期是30号是，在31号放款的客户应还期数不应该-1*/
if pay_day>d0 then do;
	if d0=30 and pay_day=31 then sh_pay_peri=m0;
	if d0^=30 or pay_day^=31 then sh_pay_peri=m0-1;
end;
if sh_pay_peri>=periods_num then sh_pay_peri=periods_num;/*应还期数不能超过期数*/
drop m0 d0;
run;
/*结清客户*/
/*提前结清客户*/
data all_1;
set dat.pay;
if comment in ("全款收完","全部结清","全额结清","全款结清") then output;
run;
data fig;
set all_1;
keep contractno submit_date;
run;

/*删除特定的客户*/
data dis;
set dis;
if loan_date>='01Oct2016'd then delete;
if product_name='房贷通' then delete;
run;
/*****************************************************生成还款计划**************************************************************************/
data dis;/*生成每期扣款日期*/
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
keep CONTRACT_NO sh_pay_peri con_amount periods_num loan_date num term&term. mon_pay mon_pri mon_int mon_man;
if term&term.^=. then output;
rename term&term.=term;
run;
quit;
%mend fenqi;/*出表(2013版excel)宏*/
%fenqi(1);%fenqi(2);%fenqi(3);%fenqi(4);%fenqi(5);%fenqi(6);%fenqi(7);%fenqi(8);%fenqi(9);%fenqi(10);%fenqi(11);%fenqi(12);%fenqi(13);%fenqi(14);%fenqi(15);
%fenqi(16);%fenqi(17);%fenqi(18);%fenqi(19);%fenqi(20);%fenqi(21);%fenqi(22);%fenqi(23);%fenqi(24);%fenqi(25);%fenqi(26);%fenqi(27);%fenqi(28);%fenqi(29);%fenqi(30);
%fenqi(31);%fenqi(32);%fenqi(33);%fenqi(34);%fenqi(35);%fenqi(36);
data pay_plan;
set a1 a2 a3 a4 a5 a6 a7 a8 a9 a10
      a11 a12 a13 a14 a15 a16 a17 a18 a19 a20
      a21 a22 a23 a24 a25 a26 a27 a28 a29 a30
      a31 a32 a33 a34 a35 a36;
run;
/*修正提前结清的*/
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
data pay_plan;
set pay_plan;
if term<='30Nov2016'd and term>='01Nov2016'd then output;
run;
/*连级别*/
data ziliao;
set dat.fig_jiagou;
keep CONTRACT_NO BUSINESS_UNIT_SOURCE REGION_AREA_ CITY_CENTER REGION_CITYY_ BRANCH_NAME;
run;
proc sql;
create table pay_plan as
select
      a.*,
      b.*
from pay_plan a 
left join ziliao b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;
/*日汇总*/
proc sql;
create table sday as
select
      a.loan_date,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME,periods_num,sh_pay_peri,
      round(sum(mon_pay)/10000,0.01) as day_pay,
	  round(sum(mon_pri)/10000,0.01) as day_pri,
	  round(sum(mon_int)/10000,0.01) as day_int,
	  round(sum(mon_man)/10000,0.01) as day_man
from pay_plan a 
group by loan_date,BUSINESS_UNIT_SOURCE,REGION_AREA_,BRANCH_NAME,periods_num,sh_pay_peri;
quit;
/*月汇总*/
data fig_my;
set sday;
year=year(loan_date);
dmonth=month(loan_date);
if dmonth<10 then ddmonth=compress("0"||dmonth); else ddmonth=dmonth;
month=input(compress(year||ddmonth),12.);
drop dmonth ddmonth;
run;
proc sql;
create table smonth as
select
      a.month,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME,periods_num,sh_pay_peri,
      round(sum(day_pay),0.01) as mon_pay,
	  round(sum(day_pri),0.01) as mon_pri,
	  round(sum(day_int),0.01) as mon_int,
	  round(sum(day_man),0.01) as mon_man
from fig_my a 
group by month,a.BUSINESS_UNIT_SOURCE,a.REGION_AREA_,a.BRANCH_NAME,periods_num,sh_pay_peri;
quit;
proc sort data=smonth out=smonth;
by month;
run;
data smonth;
set smonth;
label month="放款月份" BUSINESS_UNIT_SOURCE="事业部" REGION_AREA_="区域" BRANCH_NAME="营业部" periods_num="期数" sh_pay_peri="应还期数" mon_pay="应收月供总计" mon_pri="应收本金总计" mon_int="应收利息总计" mon_man='应收管理费总计';
run;
/*年汇总*/
/*proc sql;*/
/*create table syear as*/
/*select*/
/*      a.year,*/
/*      round(sum(day_pay),0.01) as year_pay,*/
/*	  round(sum(day_pri),0.01) as year_pri,*/
/*	  round(sum(day_int),0.01) as year_int,*/
/*	  round(sum(day_man),0.01) as year_man*/
/*from fig_my a */
/*group by year;*/
/*quit;*/
/*汇总年月日*/
/*data symd;*/
/*merge sday smonth syear;*/
/*run;*/
/*对齐字段名和label*/
/*data symd;*/
/*set symd(rename=(term=day));*/
/*label day="日" month="月" year="年" day_pay="日总" day_pri="日本金总" day_int="日利息总" day_man="日管理费总" mon_pay="月总" mon_pri="月本金总" mon_int="月利息总" mon_man="月管理费总" year_pay="年总" year_pri="年本金总" year_int="年利息总" year_man="年管理费总";*/
/*run;*/
PROC EXPORT DATA=smonth OUTFILE="E:\source_data\11月理论回款金额剔除10月&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;

