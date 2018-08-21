%let path=D:\basic_data;/*基础数据路径*/
%let today="31Oct2016"d;
%let mytoday=20161031;
%let yqday=&today.-30;
libname dat "E:\data";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
/*读流水*/
data pay;
set dat.pay;
run;
proc sql;
create table pay_al as
select
CONTRACTNO,
sum(amount) as al_pay_sum
from pay
where submit_date<=&today.
group by CONTRACTNO;
quit;
%read_tablen(&path,10月绩效考核数据,sheet1,target);
proc sql;
create table final as
select
a.*,
b.al_pay_sum
from target a
left join pay_al b
on a.contract_no=b.contractno;
quit;
data aaa;
set final;
if al_pay_sum=. then al_pay_sum=0;
al_pay_period=floor(((al_pay_sum)/(round(mon_pay,1)))+0.001);/*已还期数*/
if mon_pay*sh_pay_period<=al_pay_sum+10 then do;overdue_dt=.;end; 
if mon_pay*sh_pay_period>al_pay_sum+10 then do;
	overdue_dt=intnx("month",loan_date,al_pay_period+1,"sameday");
	overdue_day=intck("day",overdue_dt,&today);
end;
format overdue_dt mmddyy10.;
run;
data kaohe;
set aaa;
drop _COL6 _COL7 _COL8;
label 
      syb="事业部"
      contract_no="合同编号"
	  signamount="合同金额"
      mon_pay="每月还款额"
      loan_date="放款时间"
	  sh_pay_period="应还期数"
	  al_pay_sum="当前已还总额"
	  overdue_dt="逾期时间"
	  overdue_day="逾期天数"
	  al_pay_period="已还期数";	
run;
/* 输出数据源*/
PROC EXPORT DATA=kaohe OUTFILE="E:\source_data\月度考核_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;















