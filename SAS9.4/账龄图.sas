/*******************************************不含房贷***********************************************************************************************/

libname yuan "E:\data";
%let loandtnum=20160731;
/*************************************************普惠*********************************************************************************************************/

data all;
set yuan.quanbu_cust&loandtnum;
if depart^="房贷事业部";
run;

data all;
set all;
if depart="网商贷事业部" then depart="小微渠道";
if region_name="网商事业部" then region_name="未分区";
if region_name="" then region_name="未分区";
if region_name="农商贷" then region_name="未分区";
if city="" then city="空白";
if city="农商贷" then city="空白";
if branch_name="" then branch_name="空白";
if branch_name="网商事业部" then branch_name="空白";
if branch_name="网商华北区" then branch_name="空白";
if BRANCH_NAME="南京分公司" then BRANCH_NAME="南京秦淮分公司";
if BRANCH_NAME="农商贷" then BRANCH_NAME="空白";
if pro_name="" then pro_name="空白";

format interval $8.;
if overdue_day<=0 then interval="M0";
if 0<overdue_day<=30 then interval="M1";
if 30<overdue_day<=60 then interval="M2";
if 60<overdue_day<=90 then interval="M3";
if 90<overdue_day<=120 then interval="M4";
if 120<overdue_day<=150 then interval="M5";
if 150<overdue_day<=180 then interval="M6";
if 180<overdue_day then interval="M6m";

format loan_date date9.;
format ymdate $8.;
format x $4.;
format y $2.;
x=year(loan_date);
y=month(loan_date);
ymdate=x||y;
drop x y;

format conpany ;
if  CONTRACT_NO^="" then conpany="普惠";
format data_deadline date9.;
if  CONTRACT_NO^="" then data_deadline=&loandtnum.;

run;

data aa;
set all;
;
run;



data puhui;


run;









libname test excel "E:\数据源\事业部源\财务数据源&loandtnum..xlsx";
data test.数据源(Dblabel=yes);
set cw;

run;

libname test clear;
