%let today="09Sep2016"d;
%let mytoday=20160909;/*运行前要有当天的数据集*/
libname dat "E:\data";
%macro lishi(today,mytoday);
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;
data all;
set all;
year=year(loan_date);
dmonth=month(loan_date);
if dmonth<10 then ddmonth=compress("0"||dmonth); else ddmonth=dmonth;
month=input(compress(year||ddmonth),12.);
drop dmonth ddmonth;
run;
/*区分M0-6+*/
data all_M;
set all;
if daishou_yue<0 then daishou_yue=0;
if 1  <=overdue_day<=30  then do interval="M1"; M1=daishou_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=daishou_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=daishou_yue;end;
if overdue_day>90 then do interval="M3+"; M3_plus=daishou_yue; end;
run;
/*计算逾期金额*/
proc sql;
create table Overdue_Money as
select
a.depart,month,
round(sum(M1)/10000,1) as M1_sum,
round(sum(M2)/10000,1) as M2_sum,
round(sum(M3)/10000,1) as M3_sum,
round(sum(M3_plus)/10000,1) as M3_plus_sum,
round(sum(total_pay)/10000,1) as fengmu
from all_M a
group by depart,month;
quit;
/*空值标为0*/
data Overdue_Money;
set Overdue_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M3_plus_sum=. then M3_plus_sum=0;
run;
/*计算逾期率*/
proc sql;
create table Depart_Rate as
select
a.depart,month,
round(M1_sum/(fengmu),0.001) as M1_Rate,
round(M2_sum/(fengmu),0.001) as M2_Rate,
round(M3_sum/(fengmu),0.001) as M3_Rate,
round(M3_plus_sum/(fengmu),0.001) as M3_plus_Rate,
round((M1_sum+M2_sum+M3_sum+M3_plus_sum)/(fengmu),0.001) as Total_Rate
from Overdue_Money a
group by depart,month;
quit;
/*删除房贷*/
data Depart_Rate;
set Depart_Rate;
if depart='房贷事业部' then delete;
run;
data Overdue_Money;
set Overdue_Money;
if depart='房贷事业部' then delete;
run;
/*逾期金额和逾期率放在一起*/
proc sql;
create table connect as
select
b.*,
a.*
from Overdue_Money a
left join Depart_Rate b on a.depart=b.depart and a.month=b.month;
quit;
/*加一行普惠汇总*/
proc sql;
create table all as
select
'小牛普惠' as depart,
round((sum(m1_sum)+sum(m2_sum)+sum(m3_sum)+sum(m3_plus_sum))/sum(fengmu),0.001) as total_rate,
round(sum(m1_sum)/sum(fengmu),0.001) as m1_rate,
round(sum(m2_sum)/sum(fengmu),0.001) as m2_rate,
round(sum(m3_sum)/sum(fengmu),0.001) as m3_rate,
round(sum(m3_plus_sum)/sum(fengmu),0.001) as m3_plus_rate,
sum(fengmu) as fengmu,
sum(m1_sum) as m1_sum,
sum(m2_sum) as m2_sum,
sum(m3_sum) as m3_sum,
sum(m3_plus_sum) as m3_plus_sum
from overdue_money a;
quit;
/*把汇总加上*/
data connect;
set connect all;
run;
/*逾期率变为百分数*/
data connect;
set connect;
format M1_Rate M2_Rate M3_Rate M3_plus_Rate Total_Rate percent8.1;
M1_Rate1=trim(M1_Rate*100)||'%';M2_Rate1=trim(M2_Rate*100)||'%';M3_Rate1=trim(M3_Rate*100)||'%';M3_Plus_Rate1=trim(M3_Plus_Rate*100)||'%';total_Rate1=trim(total_Rate*100)||'%';
drop M1_Rate M2_Rate M3_Rate M3_plus_Rate Total_Rate;
rename M1_Rate1=M1_Rate M2_Rate1=M2_Rate M3_Rate1=M3_Rate M3_plus_Rate1=M3_plus_Rate Total_Rate1=Total_Rate;
run;
/*字段排序和保留*/
data connect;
set connect;
if depart='互联网服务事业' then do; depart1=input(depart||'部',$16.);end;
if depart^='互联网服务事业' then do;depart1=depart;end;
drop depart;
rename depart1=depart;
run;
data overdue&mytoday;
retain depart total_rate m1_rate m2_rate m3_rate m3_plus_rate fengmu m1_sum m2_sum m3_sum m3_plus_sum;
set connect;
run;
%mend lishi;
%lishi("30Jun2014"d,20140630);
%lishi("31Jul2014"d,20140731);
%lishi("31Aug2014"d,20140831);
%lishi("30Sep2014"d,20140930);
%lishi("31Oct2014"d,20141031);
%lishi("30Nov2014"d,20141130);
%lishi("31Dec2014"d,20141231);

%lishi("31Jan2015"d,20150131);
%lishi("28Feb2015"d,20150228);
%lishi("31Mar2015"d,20150331);
%lishi("30Apr2015"d,20150430);
%lishi("31May2015"d,20150531);
%lishi("30Jun2015"d,20150630);
%lishi("31Jul2015"d,20150731);
%lishi("31Aug2015"d,20150831);
%lishi("30Sep2015"d,20150930);
%lishi("31Oct2015"d,20151031);
%lishi("30Nov2015"d,20151130);
%lishi("31Dec2015"d,20151231);

%lishi("31Jan2016"d,20160131);
%lishi("29Feb2016"d,20160229);
%lishi("31Mar2016"d,20160331);
%lishi("30Apr2016"d,20160430);
%lishi("31May2016"d,20160531);
%lishi("30Jun2016"d,20160630);
%lishi("31Jul2016"d,20160731);
%lishi("31Aug2016"d,20160831);
