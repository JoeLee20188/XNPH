%let path=E:\basic_data;/*基础数据路径*/
%let today="04Aug2016"d;
%let mytoday=20160804;/*用于输出文件名的标识*/
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
keep CONTRACT_NO sh_pay_peri con_amount num term&term. mon_pay mon_pri	mon_int	mon_man;
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
/*连级别*/
data ziliao;
set dat.quanbu_cust20160731;
keep CONTRACT_NO sys depart region_name branch_name city;
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
      a.term,a.sys,depart,a.region_name,a.branch_name,a.city,
      round(sum(mon_pay)/10000,0.01) as day_pay,
	  round(sum(mon_pri)/10000,0.01) as day_pri,
	  round(sum(mon_int)/10000,0.01) as day_int,
	  round(sum(mon_man)/10000,0.01) as day_man
from pay_plan a 
group by term,sys,depart,region_name,branch_name,city;
quit;
/*月汇总*/
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
      a.month,sys,depart,region_name,branch_name,city,
      round(sum(day_pay),0.01) as mon_pay,
	  round(sum(day_pri),0.01) as mon_pri,
	  round(sum(day_int),0.01) as mon_int,
	  round(sum(day_man),0.01) as mon_man
from fig_my a 
group by month,sys,depart,region_name,branch_name,city;
quit;
proc sort data=smonth out=smonth;
by month;
run;
/*年汇总*/
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
/*汇总年月日*/
data symd;
merge sday smonth syear;
run;
data demo01;
set symd;
keep term day_pay day_pri day_int day_man;
run;
PROC EXPORT DATA=demo01 OUTFILE="E:\echart_excel_to_mysql\债权（已拆分_每日）&mytoday.xlsx" DBMS=EXCEL;
RUN;
/*对齐字段名和label*/
data symd;
set symd(rename=(term=day));
label day="日" month="月" year="年" day_pay="日总" day_pri="日本金总" day_int="日利息总" day_man="日管理费总" mon_pay="月总" mon_pri="月本金总" mon_int="月利息总" mon_man="月管理费总" year_pay="年总" year_pri="年本金总" year_int="年利息总" year_man="年管理费总";
run;
PROC EXPORT DATA=smonth OUTFILE="E:\source_data\理论回款金额&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;

