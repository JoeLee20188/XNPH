libname dat "E:\data";
%macro zhongan(riqi);
data quanbu_cust&riqi.;
set dat.quanbu_cust&riqi.;
if depart='房贷事业部' then delete;
keep CONTRACT_NO con_yue loan_date overdue_day al_pay_sum pro_name;
run;
data target;/*加月份*/
set quanbu_cust&riqi.;
year=year(loan_date);
dmonth=month(loan_date);
if dmonth<10 then ddmonth=compress("0"||dmonth); else ddmonth=dmonth;
month=input(compress(year||ddmonth),12.);
drop dmonth ddmonth year;
run;
data target;/*修正合同余额为非负*/
set target;
if con_yue<0 then con_yue=0;
run;
proc sql;/*计算 '截至当月的存量本金余额'*/
create table a1 as
select 
    a.pro_name,
	round(sum(con_yue)/10000,1) as con_yue_sum,
	&riqi. as month
from target a
group by a.pro_name;
quit;
proc sql;/*计算 '截至当月的存量户数'*/
create table a2 as
select 
    a.pro_name,
	count(con_yue) as con_sum,
	&riqi. as month
from target a
where a.con_yue>0
group by a.pro_name;
quit;
proc sql;/*计算 '逾期1-30天本金金额'*/
create table a3 as
select 
    a.pro_name,
	round(sum(con_yue)/10000,1) as con_yue_sum_m1,
	&riqi. as month
from target a
where a.overdue_day>=1 and a.overdue_day<=30
group by a.pro_name;
quit;
proc sql;/*计算 '逾期30天以上本金金额'*/
create table a4 as
select 
    a.pro_name,
	round(sum(con_yue)/10000,1) as con_yue_sum_m1plus,
	&riqi. as month
from target a
where a.overdue_day>30
group by a.pro_name;
quit;
proc sql;/*合并计算结果*/
create table data&riqi as
select 
	a.pro_name,a.month,a.con_yue_sum,b.con_sum,c.con_yue_sum_m1,d.con_yue_sum_m1plus
from a1 a
left join a2 b on a.pro_name=b.pro_name
left join a3 c on a.pro_name=c.pro_name
left join a4 d on a.pro_name=d.pro_name;
quit;
data data&riqi;/*字段排序*/
retain pro_name month con_yue_sum con_sum con_yue_sum_m1 con_yue_sum_m1plus;
set data&riqi;
run;
%mend zhongan;/*众安数据的宏*/
%zhongan(20160831);%zhongan(20160731);%zhongan(20160630);%zhongan(20160531);%zhongan(20160430);%zhongan(20160331);%zhongan(20160229);%zhongan(20160131);
%zhongan(20151231);%zhongan(20151130);%zhongan(20151031);%zhongan(20150930);%zhongan(20150831);%zhongan(20150731);%zhongan(20150630);%zhongan(20150531);%zhongan(20150430);%zhongan(20150331);%zhongan(20150228);%zhongan(20150131);
%zhongan(20141231);%zhongan(20141130);%zhongan(20141031);%zhongan(20140930);%zhongan(20140831);%zhongan(20140731);%zhongan(20140630);
data all;
set data20160831 data20160731 data20160630 data20160531 data20160430 data20160331 data20160229 data20160131
    data20151231 data20151130 data20151031 data20150930 data20150831 data20150731 data20150630 data20150531 data20150430 data20150331 data20150228 data20150131
	data20141231 data20141130 data20141031 data20140930 data20140831 data20140731 data20140630;
run;
/* 输出*/
PROC EXPORT DATA=all OUTFILE="E:\source_data\众安数据.xlsx" DBMS=EXCEL;
SHEET='数据';
RUN;
/*****************************************************************************************************************************************************/
%let path=D:\basic_data;/*基础数据路径*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
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
keep CONTRACT_NO term&term. mon_pri;
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
proc sql;/*连产品名字*/
create table pay_plan as
select
      a.*,b.pro_name
from pay_plan a left join Quanbu_cust20160831 b on a.CONTRACT_NO=b.CONTRACT_NO;
quit;
data pay_plan;/*删除产品为空的*/
set pay_plan;
if pro_name='' then delete;
run;
/*日汇总*/
proc sql;
create table sday as
select
      a.term,a.pro_name,
	  round(sum(mon_pri)/10000,0.01) as day_pri
from pay_plan a 
group by term,pro_name;
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
      a.month,pro_name,
	  round(sum(day_pri),0.01) as mon_pri
from fig_my a 
group by month,pro_name;
quit;
proc sort data=smonth out=smonth;
by month;
run;
data smonth;
set smonth;
if month<=201608 then output; 
run;
/* 输出*/
PROC EXPORT DATA=smonth OUTFILE="E:\source_data\众安数据.xlsx" DBMS=EXCEL;
SHEET='理论本金';
RUN;
/***********************************************************************************************************************************/
data pay;
set dat.pay;
run;
proc sql;/*连产品名字*/
create table pay as
select
      a.*,b.pro_name
from pay a left join Quanbu_cust20160831 b on a.CONTRACTNO=b.CONTRACT_NO;
quit;
data pay;/*删除产品为空的*/
set pay;
keep pro_name CONTRACTNO submit_date amount;
if pro_name='' then delete;
run;
/*日汇总*/
proc sql;
create table sday as
select
      a.submit_date,pro_name,
      round(sum(amount)/10000,0.01) as day_sum
from pay a 
group by submit_date,pro_name;
quit;
/*月汇总*/
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
      a.month,pro_name,
      sum(day_sum) as month_sum
from fig_my a 
group by month,pro_name;
quit;
proc sort data=smonth out=smonth;
by month;
run;
/* 输出*/
PROC EXPORT DATA=smonth OUTFILE="E:\source_data\众安数据.xlsx" DBMS=EXCEL;
SHEET='流水汇总';
RUN;
