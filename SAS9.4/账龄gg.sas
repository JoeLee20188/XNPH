libname overdue 'E:\data';
%macro ljr1(loan_month);
	%macro ljr(loandate,cal_date);
	data allcust&cal_date.;
	set overdue.quanbu_cust&cal_date.;
	if depart='房贷事业部' then delete;
	curr_date=&cal_date.;
	if overdue_day=0 or overdue_day=. then do interval="M0"; M0=daishou_yue; end;/*逾期金额口径*/
	if overdue_day>0 and overdue_day<=30 then do interval="M1"; M1=daishou_yue; end;
	if overdue_day>30 and overdue_day<=60 then do interval="M2"; M2=daishou_yue; end;
	if overdue_day>60 and overdue_day<=90 then do interval="M3"; M3=daishou_yue; end;
	if overdue_day>90 and overdue_day<=120 then do interval="M4"; M4=daishou_yue; end;
	if overdue_day>120 and overdue_day<=150 then do interval="M5"; M5=daishou_yue; end;
	if overdue_day>150 and overdue_day<=180 then do interval="M6"; M6=daishou_yue; end;
	if overdue_day>180 then do interval="M6P"; M6P=daishou_yue; end;
	year=year(loan_date);
	dmonth=month(loan_date);
	if dmonth<10 then ddmonth=compress("0"||dmonth); else ddmonth=dmonth;
	month=input(compress(year||ddmonth),12.);
	drop dmonth ddmonth;
	if month=&loandate. then output;
	run;
	/*选字段*/
	/*计算逾期金额*/
	proc sql;
	create table target&cal_date. as
	select 
	month as loan_m,curr_date as cal_m,
	round(sum(loan_amount)/10000,1) as loan_sum,
	round(sum(con_amount)/10000,1) as con_sum,
	round(sum(con_yue)/10000,1) as conyue_sum,
	round(sum(daishou_yue)/10000,1) as ds_sum,
	round(sum(M0)/10000,1) as M0_sum,
	round(sum(M1)/10000,1) as M1_sum,
	round(sum(M2)/10000,1) as M2_sum,
	round(sum(M3)/10000,1) as M3_sum,
	round(sum(M4)/10000,1) as M4_sum,
	round(sum(M5)/10000,1) as M5_sum,
	round(sum(M6)/10000,1) as M6_sum,
	round(sum(M6P)/10000,1) as M6P_sum
	from allcust&cal_date.
	group by month,curr_date;
	quit;
	%mend ljr;
	%ljr(&loan_month.,20140630);
	%ljr(&loan_month.,20140731);
	%ljr(&loan_month.,20140831);
	%ljr(&loan_month.,20140930);
	%ljr(&loan_month.,20141031);
	%ljr(&loan_month.,20141130);
	%ljr(&loan_month.,20141231);

	%ljr(&loan_month.,20150131);
	%ljr(&loan_month.,20150228);
	%ljr(&loan_month.,20150331);
	%ljr(&loan_month.,20150430);
	%ljr(&loan_month.,20150531);
	%ljr(&loan_month.,20150630);
	%ljr(&loan_month.,20150731);
	%ljr(&loan_month.,20150831);
	%ljr(&loan_month.,20150930);
	%ljr(&loan_month.,20151031);
	%ljr(&loan_month.,20151130);
	%ljr(&loan_month.,20151231);

	%ljr(&loan_month.,20160131);
	%ljr(&loan_month.,20160229);
	%ljr(&loan_month.,20160331);
	%ljr(&loan_month.,20160430);
	%ljr(&loan_month.,20160531);
	%ljr(&loan_month.,20160630);
	%ljr(&loan_month.,20160731);
	%ljr(&loan_month.,20160831);
	%ljr(&loan_month.,20160930);
	%ljr(&loan_month.,20161031);

	data final&loan_month.;
	set target20140630 target20140731 target20140831 target20140930 target20141031 target20141130 target20141231
	    target20150131 target20150228 target20150331 target20150430 target20150531 target20150630 target20150731 target20150831 target20150930 target20151031 target20151130 target20151231
		target20160131 target20160229 target20160331 target20160430 target20160531 target20160630 target20160731 target20160831 target20160930 target20161031;
	run;
%mend ljr1;
%ljr1(201406);
%ljr1(201407);
%ljr1(201408);
%ljr1(201409);
%ljr1(201410);
%ljr1(201411);
%ljr1(201412);

%ljr1(201501);
%ljr1(201502);
%ljr1(201503);
%ljr1(201504);
%ljr1(201505);
%ljr1(201506);
%ljr1(201507);
%ljr1(201508);
%ljr1(201509);
%ljr1(201510);
%ljr1(201511);
%ljr1(201512);

%ljr1(201601);
%ljr1(201602);
%ljr1(201603);
%ljr1(201604);
%ljr1(201605);
%ljr1(201606);
%ljr1(201607);
%ljr1(201608);
%ljr1(201609);
%ljr1(201610);

data zhangling;
set final201406 final201407 final201408 final201409 final201410 final201411 final201412
    final201501 final201502 final201503 final201504 final201505 final201506 final201507 final201508 final201509 final201510 final201511 final201512
    final201601 final201602 final201603 final201604 final201605 final201606 final201607 final201608 final201609 final201610;
label loan_m="放款月份" cal_m="数据截至日期" loan_sum="放款金额" con_sum="合同金额" conyue_sum="合同余额" ds_sum="待收余额";
run;
PROC EXPORT DATA=zhangling OUTFILE="E:\source_data\账龄数据分析.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
