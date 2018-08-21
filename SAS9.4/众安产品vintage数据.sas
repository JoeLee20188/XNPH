libname overdue 'E:\data';

%macro ints(interval);
%macro mon(lastday);
data allcust&lastday;
set overdue.quanbu_cust&lastday;
x=year(loan_date);
y=month(loan_date);
ldate=x||y;
newdate=compress(ldate);
newyue=(loan_amount/periods_num)*(periods_num-al_pay_period);
if pro_name="" then pro_name=product_name;
format interval$8.;
if overdue_day=0 or overdue_day=. then interval="M0";
if overdue_day>0 and overdue_day<=30 then interval="M1";
if overdue_day>30 and overdue_day<=60 then interval="M2";
if overdue_day>60 and overdue_day<=90 then interval="M3";
if overdue_day>90 and overdue_day<=120 then interval="M4";
if overdue_day>120 and overdue_day<=150 then interval="M5";
if overdue_day>150 and overdue_day<=180 then interval="M6";
if overdue_day>180 then interval="M6M";
keep depart region_name city branch_name CONTRACT_NO pro_name loan_amount con_amount mon_pay total_pay periods_num
		con_yue daishou_yue loan_date overdue_day product_name newdate newyue interval;
run;

proc sql;
create table con&lastday&interval as
select pro_name,newdate,sum(newyue)/10000 as m&lastday&interval
from allcust&lastday
where interval="&interval"
group by pro_name,newdate;
quit;
%mend mon;
%mon(20160930);
%mon(20160831);
%mon(20160731);
%mon(20160630);
%mon(20160531);
%mon(20160430);
%mon(20160331);
%mon(20160229);
%mon(20160131);
%mon(20151231);
%mon(20151130);
%mon(20151031);
%mon(20150930);
%mon(20150831);
%mon(20150731);
%mon(20150630);
%mon(20150531);
%mon(20150430);
%mon(20150331);
%mon(20150228);
%mon(20150131);
%mon(20141231);
%mon(20141130);
%mon(20141031);
%mon(20140930);
%mon(20140831);
%mon(20140731);

proc sql;
create table alls as
select pro_name,newdate,sum(loan_amount)/10000 as all_amt
from allcust20160930
group by pro_name,newdate;
quit;

data join_all&interval;
merge alls con20140731&interval con20140831&interval con20140930&interval con20141031&interval con20141130&interval con20141231&interval con20150131&interval con20150228&interval con20150331&interval con20150430&interval con20150531&interval
		con20150630&interval con20150731&interval con20150831&interval con20150930&interval con20151031&interval con20151130&interval con20151231&interval con20160131&interval con20160229&interval con20160331&interval con20160430&interval con20160531&interval
		con20160630&interval con20160731&interval con20160831&interval con20160930&interval;
by pro_name newdate;
run;

%mend ints;
%ints(M1);
%ints(M2);
%ints(M3);
%ints(M4);
%ints(M5);
%ints(M6);
%ints(M6M);

libname output excel 'E:\source_data\在线账龄数据.xlsx';
data output.M1(Dblabel=yes);
set join_allm1;
label pro_name="产品名称" newdate="放款日期" all_amt="当月放款金额" m20140731m1="2014年7月" m20140831m1="2014年8月" m20140930m1="2014年9月" m20141031m1="2014年10月" m20141130m1="2014年11月"
		m20141231m1="2014年12月" m20150131m1="2015年1月" m20150228m1="2015年2月" m20150331m1="2015年3月" m20150430m1="2015年4月" m20150531m1="2015年5月" m20150630m1="2015年6月"
		m20150731m1="2015年7月" m20150831m1="2015年8月" m20150930m1="2015年9月" m20151031m1="2015年10月" m20151130m1="2015年11月" m20151231m1="2015年12月" m20160131m1="2016年1月" m20160229m1="2016年2月"
		m20160331m1="2016年3月" m20160430m1="2016年4月" m20160531m1="2016年5月" m20160630m1="2016年6月" m20160731m1="2016年7月" m20160831m1="2016年8月";
run;
data output.M2(Dblabel=yes);
set join_allm2;
label pro_name="产品名称" newdate="放款日期" all_amt="当月放款金额" m20140731m2="2014年7月" m20140831m2="2014年8月" m20140930m2="2014年9月" m20141031m2="2014年10月" m20141130m2="2014年11月"
		m20141231m2="2014年12月" m20150131m2="2015年1月" m20150228m2="2015年2月" m20150331m2="2015年3月" m20150430m2="2015年4月" m20150531m2="2015年5月" m20150630m2="2015年6月"
		m20150731m2="2015年7月" m20150831m2="2015年8月" m20150930m2="2015年9月" m20151031m2="2015年10月" m20151130m2="2015年11月" m20151231m2="2015年12月" m20160131m2="2016年1月" m20160229m2="2016年2月"
		m20160331m2="2016年3月" m20160430m2="2016年4月" m20160531m2="2016年5月" m20160630m2="2016年6月" m20160731m2="2016年7月" m20160831m2="2016年8月";
run;
data output.M3(Dblabel=yes);
set join_allm3;
label pro_name="产品名称" newdate="放款日期" all_amt="当月放款金额" m20140731m3="2014年7月" m20140831m3="2014年8月" m20140930m3="2014年9月" m20141031m3="2014年10月" m20141130m3="2014年11月"
		m20141231m3="2014年12月" m20150131m3="2015年1月" m20150228m3="2015年2月" m20150331m3="2015年3月" m20150430m3="2015年4月" m20150531m3="2015年5月" m20150630m3="2015年6月"
		m20150731m3="2015年7月" m20150831m3="2015年8月" m20150930m3="2015年9月" m20151031m3="2015年10月" m20151130m3="2015年11月" m20151231m3="2015年12月" m20160131m3="2016年1月" m20160229m3="2016年2月"
		m20160331m3="2016年3月" m20160430m3="2016年4月" m20160531m3="2016年5月" m20160630m3="2016年6月" m20160731m3="2016年7月" m20160831m3="2016年8月";
run;
data output.M4(Dblabel=yes);
set join_allm4;
label pro_name="产品名称" newdate="放款日期" all_amt="当月放款金额" m20140731m4="2014年7月" m20140831m4="2014年8月" m20140930m4="2014年9月" m20141031m4="2014年10月" m20141130m4="2014年11月"
		m20141231m4="2014年12月" m20150131m4="2015年1月" m20150228m4="2015年2月" m20150331m4="2015年3月" m20150430m4="2015年4月" m20150531m4="2015年5月" m20150630m4="2015年6月"
		m20150731m4="2015年7月" m20150831m4="2015年8月" m20150930m4="2015年9月" m20151031m4="2015年10月" m20151130m4="2015年11月" m20151231m4="2015年12月" m20160131m4="2016年1月" m20160229m4="2016年2月"
		m20160331m4="2016年3月" m20160430m4="2016年4月" m20160531m4="2016年5月" m20160630m4="2016年6月" m20160731m4="2016年7月" m20160831m4="2016年8月";
run;
data output.M5(Dblabel=yes);
set join_allm5;
label pro_name="产品名称" newdate="放款日期" all_amt="当月放款金额" m20140731m5="2014年7月" m20140831m5="2014年8月" m20140930m5="2014年9月" m20141031m5="2014年10月" m20141130m5="2014年11月"
		m20141231m5="2014年12月" m20150131m5="2015年1月" m20150228m5="2015年2月" m20150331m5="2015年3月" m20150430m5="2015年4月" m20150531m5="2015年5月" m20150630m5="2015年6月"
		m20150731m5="2015年7月" m20150831m5="2015年8月" m20150930m5="2015年9月" m20151031m5="2015年10月" m20151130m5="2015年11月" m20151231m5="2015年12月" m20160131m5="2016年1月" m20160229m5="2016年2月"
		m20160331m5="2016年3月" m20160430m5="2016年4月" m20160531m5="2016年5月" m20160630m5="2016年6月" m20160731m5="2016年7月" m20160831m5="2016年8月";
run;
data output.M6(Dblabel=yes);
set join_allm6;
label pro_name="产品名称" newdate="放款日期" all_amt="当月放款金额" m20140731m6="2014年7月" m20140831m6="2014年8月" m20140930m6="2014年9月" m20141031m6="2014年10月" m20141130m6="2014年11月"
		m20141231m6="2014年12月" m20150131m6="2015年1月" m20150228m6="2015年2月" m20150331m6="2015年3月" m20150430m6="2015年4月" m20150531m6="2015年5月" m20150630m6="2015年6月"
		m20150731m6="2015年7月" m20150831m6="2015年8月" m20150930m6="2015年9月" m20151031m6="2015年10月" m20151130m6="2015年11月" m20151231m6="2015年12月" m20160131m6="2016年1月" m20160229m6="2016年2月"
		m20160331m6="2016年3月" m20160430m6="2016年4月" m20160531m6="2016年5月" m20160630m6="2016年6月" m20160731m6="2016年7月" m20160831m6="2016年8月";
run;
data output.M6M(Dblabel=yes);
set join_allm6m;
label pro_name="产品名称" newdate="放款日期" all_amt="当月放款金额" m20140731m6m="2014年7月" m20140831m6m="2014年8月" m20140930m6m="2014年9月" m20141031m6m="2014年10月" m20141130m6m="2014年11月"
		m20141231m6m="2014年12月" m20150131m6m="2015年1月" m20150228m6m="2015年2月" m20150331m6m="2015年3月" m20150430m6m="2015年4月" m20150531m6m="2015年5月" m20150630m6m="2015年6月"
		m20150731m6m="2015年7月" m20150831m6m="2015年8月" m20150930m6m="2015年9月" m20151031m6m="2015年10月" m20151130m6m="2015年11月" m20151231m6m="2015年12月" m20160131m6m="2016年1月" m20160229m6m="2016年2月"
		m20160331m6m="2016年3月" m20160430m6m="2016年4月" m20160531m6m="2016年5月" m20160630m6m="2016年6月" m20160731m6m="2016年7月" m20160831m6m="2016年8月";
run;
libname output clear;
