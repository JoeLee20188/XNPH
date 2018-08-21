%let path=D:\basic_data;/*基础数据路径*/
%let today="24Nov2016"d;
%let mytoday=20161124;
%let yqday=&today.-30;
libname dat "E:\data";

%macro read_table(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xls" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_table;/*读表宏*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%macro output_table(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xls" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_table;/*出表宏*/
%macro output_tablen(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xlsx" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_tablen;/*出表(2013版excel)宏*/
/*读入，预处理disbursement表*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
/*proc sql;
connect to oracle as mylib (user=jhjy password=jhjy path=10.15.18.11);
create table table_name as               
select * from connection to mylib (select…); 括号中查询语句需符合oracle的语法
disconnect  from  mylib;
quit;
proc setinit; run;

libname mylib odbc datasrc=newsys user=jhjy password='jhjy';;
libname mylib oracle datasrc=oracle user=szxn password='szxn#6';*/

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
/*统一产品*/
%read_table(&path,product_fig,sheet1,product_fig);
proc sql;
create table dis as
select
a.*,
b.pro_name,
b.depart
from dis a
left join product_fig b
on a.product_name=b.product_name1;
quit;
/*读入，预处理payment表
%read_tablen(&path,数据汇总（有重复）,汇总,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;*/
/*删除流水中的重复值
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;*/
data pay;
set dat.pay;
if comment in ("全款收完","全部结清","全额结清","全款结清") then payall=1; else payall=0;/*提前结清客户*/
run;
/*30天前的扣款总额*/
proc sql;
create table yqday as
select
CONTRACTNO,
sum(amount) as yqsum
from pay
where submit_date<=&yqday
group by CONTRACTNO;
quit;
data pay_al;
set pay;
if submit_date<=&today then output;/*缴款日在今天之前（包括）*/
run;
proc sql;
create table pay_al as
select
CONTRACTNO,
sum(amount) as al_pay_sum,
max(submit_date) format mmddyy10. as last_pay,/*最后缴款日*/
max(payall) as payall_flag
from pay_al
group by CONTRACTNO;
quit;
proc sql;
create table dis_pay as
select
     a.*,
	 b.al_pay_sum,
	 b.last_pay,
	 b.payall_flag
from dis a
left join pay_al b
on a.contract_no=b.CONTRACTNO
where a.loan_date<=&today;/*放款日在今天之前（包括）*/
quit;
data dis_pay;/*目前没有还款的置为0,还有。。。。*/
set dis_pay;
if al_pay_sum=. then al_pay_sum=0;
if payall_flag=. then payall_flag=0;
run;
data dis_pay;/*区分新旧系统数据*/
set dis_pay;
if substr(CONTRACT_NO,1,1)="0" or substr(CONTRACT_NO,1,1)="1" or substr(CONTRACT_NO,1,1)="2" then sys="new"; else sys="old"; 
run;
data dis_pay_old;
set dis_pay;
if sys="old" then output;
run;
data dis_pay_new;
set dis_pay;
if sys="new" then output;
run;
/*2016/6/23开始的滞纳金*/
%read_tablen(&path,特殊扣款表,Sheet1,zhinajin);
proc sql;
create table al_pay_znj as
select
     a._COL1 as CONTRACT_NO,
	 sum(a._COL3) as znj
from zhinajin a 
where a._COL7 in ("成功","交易成功","扣款成功")
group by a._COL1;
quit;
/*****************************************************旧系统*********************************************************************************************************/
/*加入旧系统客户资料
%read_tablen(&path,old_out_info,sheet1,old_out_info);*/
data old_out_info;
set dat.old_out_info;
run;
%read_table(&path,old_org_fig,sheet1,old_org_fig);
proc sql;
create table dis_pay_old as
select
     a.*,
	 b.*
from dis_pay_old a
left join old_out_info b
on a.contract_no=b.CONTRACTNO;
quit;
proc sort data=dis_pay_old nodupkey;
by contract_no;
run;
proc sql;
create table dis_pay_old as
select
     a.*,
	 b.city,
	 b.Region,
	 b.ORGNAME_fig
from dis_pay_old a
left join old_org_fig b
on a.ORGNAME=b.ORGNAME;
quit;
/*连滞纳金表*/
proc sql;
create table dis_pay_old as
select
     a.*,
	 b.znj
from dis_pay_old a
left join al_pay_znj b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;	
/*计算合同金额，每月还款额，应还总额以及判断是否逾期*/
data aaa;
set dis_pay_old;
if znj=. then znj=0;
al_pay_period=floor(((al_pay_sum-znj)/(round(mon_pay,1)))+0.001);/*已还期数*/
total_pay=round(mon_pay*periods_num,0.01);/*总计应还总额*/
sh_pay_sum=round(mon_pay*sh_pay_peri-10,0.01);/*当前应还总额*/
if payall_flag=1 then do;overdue_dt=.;end;
if payall_flag=0 then do;/*未标注全款收完的客户*/
   if sh_pay_sum<=al_pay_sum then do;overdue_dt=.;end; 
   if sh_pay_sum>al_pay_sum then do;
      overdue_dt=intnx("month",loan_date,al_pay_period+1,"sameday");
      overdue_day=intck("day",overdue_dt,&today)+1;
      overdue_pay=round((periods_num-al_pay_period)*mon_pay*0.001*overdue_day,0.01);
   end;
end;
con_yue=round(con_amount-al_pay_sum,0.01);
prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
format overdue_dt mmddyy10.;
drop znj;
run;
data bbb;
retain sys depart region city ORGNAME_fig CUST_MNG SURVEYMAN AUDITMAN CONTRACT_NO cust_name 
       pro_name ID_NUM GENDER loan_amount con_amount mon_pay total_pay periods_num con_yue prin_yue loan_date pay_day 
       sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay MARRY MOBILE	
       ADDR CORP_NAME CORP_ADDR CORP_PHONE SPO_NAME SPO_PHONE SPO_CORP SPO_CORP_ADDR SPO_CORP_PHO SPO_CORP_POS 
       CON_NAME1 CON_REL1 CON_PHO1 CON_ADDR1 CON_CORP_NAME1 CON_COM_POS1 CON_COM_PHO1 CON_NAME2	CON_REL2 CON_PHO2 
       CON_ADDR2 CON_CORP_NAME2 CON_CORP_POS2 CON_CORP_PHO2 CON_NAME3 CON_REL3 CON_PHO3	CON_ADDR3 CON_CORP_NAME3 CON_CORP_POS3	
       CON_CORP_PHO3 product_name;
set aaa;
drop CONTRACTNO cert_id division MANAGEFEES FEE ORGNAME;
run;
data old;
set bbb(rename=(Region=REGION_NAME ORGNAME_fig=BRANCH_NAME));
run;
/*刘佳琪说要改一些客户的营业部*/
%read_table(&path,jq_fig,Sheet1,jq_fig);
proc sql;
create table old as
select
     a.*,
	 b.yyn
from old a
left join jq_fig b
on a.CONTRACT_NO=b.cony;
quit;
data old;
set old;
if yyn^="" then BRANCH_NAME=yyn;
drop yyn;
run;
/*吕嘉容说要加的旧系统客户经理工号，姓名*/
%read_table(&path,empno_fig,Sheet1,empno_fig);
proc sql;
create table old as
select
     a.*,
	 b.sales_code
from old a
left join empno_fig b
on a.CONTRACT_NO=b.conno;
quit;
data old;
set old;
if sales_code="xn017575" then cust_mng="杨伟东";
if sales_code="xn011584" then cust_mng="官林雲";
run;
/*连滞纳金表*/
proc sql;
create table dis_pay_old as
select
     a.*,
	 b.znj
from dis_pay_old a
left join al_pay_znj b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;
/*****************************************************新系统*********************************************************************************************************/
/*计算合同金额，每月还款额，应还总额以及判断是否逾期*/
data ccc;
set dis_pay_new;
if znj=. then znj=0;
al_pay_period=floor(((al_pay_sum-znj)/(round(mon_pay,1)))+0.001);/*已还期数*/
total_pay=round(mon_pay*periods_num,0.01);/*总计应还总额*/
sh_pay_sum=round(mon_pay*sh_pay_peri-10,0.01);/*当前应还总额*/
if payall_flag=1 then do;overdue_dt=.;end;
if payall_flag=0 then do;/*未标注全款收完的客户*/
   if sh_pay_sum<=al_pay_sum then do;overdue_dt=.;end; 
   if sh_pay_sum>al_pay_sum then do;
      overdue_dt=intnx("month",loan_date,al_pay_period+1,"sameday");
      overdue_day=intck("day",overdue_dt,&today)+1;
      overdue_pay=round((periods_num-al_pay_period)*mon_pay*0.001*overdue_day,0.01);
   end;
end;
con_yue=round(con_amount-al_pay_sum,0.01);
prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
format overdue_dt mmddyy10.;
drop znj;
run;
/*加入新系统客户资料
%read_tablen(&path,new_out_info,导出工作表,new_out_info);*/
data new_out_info;
set dat.new_out_info;
run;
proc sql;
create table dis_pay_new as
select
     a.*,
	 b.*
from ccc a
left join new_out_info b
on a.contract_no=b.CONTRACT_NO;
quit;
proc sort data=dis_pay_new nodupkey;
by contract_no;
run;
data new;
retain sys syb region_name city branch_name CUST_MNG SURVEYMAN AUDITMAN CONTRACT_NO cust_name 
       pro_name ID_NUM GENDER loan_amount con_amount mon_pay total_pay periods_num con_yue prin_yue loan_date pay_day 
       sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay MARRY MOBILE	
       ADDR CORP_NAME CORP_ADDR CORP_PHONE SPO_NAME SPO_PHONE SPO_CORP SPO_CORP_ADDR SPO_CORP_PHO SPO_CORP_POS 
       CON_NAME1 CON_REL1 CON_PHO1 CON_ADDR1 CON_CORP_NAME1 CON_COM_POS1 CON_COM_PHO1 CON_NAME2	CON_REL2 CON_PHO2 
       CON_ADDR2 CON_CORP_NAME2 CON_CORP_POS2 CON_CORP_PHO2 CON_NAME3 CON_REL3 CON_PHO3	CON_ADDR3 CON_CORP_NAME3 CON_CORP_POS3	
       CON_CORP_PHO3 product_name;
set dis_pay_new;
drop cert_id division depart;
run;
data new;
set new(rename=(syb=depart));
run;
/**********************************汇总新旧系统的客户********************************************************************************************************/
data all_cust;
set old new;
drop real_customer;
run;
/*委外标签*/
%read_tablen(&path,委外客户表,Sheet1,out_cust);
proc sql;
create table all_cust as
select
     a.*,
	 b.done
from all_cust a
left join out_cust b
on a.contract_no=b.con;
quit;
proc sort data=all_cust nodupkey;
by contract_no;
run;
/*下次还款日*/
data all_cust;
set all_cust;
wik=intnx("month",loan_date,sh_pay_peri+1,"sameday");
t0=day(loan_date);
t1=day(wik);
if t0>t1 then do;/*上月月末日期>下月月末日期，取下下个月1号*/
wik=wik+1;
end;
format wik mmddyy10.;
drop t0 t1;
run;
/*修改大区（十二区）*/
%read_tablen(&path,系统名称对照表,Sheet1,shierqu);
proc sql;
create table all_cust1 as
select
     a.*,
	 b._COL4
from all_cust a
left join shierqu b
on a.branch_name=b._COL2
where a.depart='小微贷事业部' and sys='old';
quit;
proc sort data=all_cust1 nodupkey;
by contract_no;
run;
data all_cust2;
set all_cust;
if depart='小微贷事业部' and sys='old' then delete;
run;
data all_cust;
set all_cust1 all_cust2;
if _COL4^='' then region_name=_COL4;
drop _COL4;
run;
/*求30天前的合同余额*/
proc sql;
create table all_cust as
select
     a.*,
	 a.con_amount-b.yqsum as thircon
from all_cust a 
left join yqday b
on a.CONTRACT_NO=b.CONTRACTNO;
quit;
/*30天前已经放款，但近30天内没有还过款的客户*/
data all_cust;
set all_cust;
if thircon=. and loan_date<=&yqday then thircon=con_amount;
run;
/*求30天前的待收余额和现在的待收余额*/
data all_cust;
set all_cust;
daishou_yue=total_pay-al_pay_sum;
thirdaishou_yue=total_pay-con_amount+thircon;
run;
/*修改营业部*/
data all_cust;
set all_cust;
if branch_name="佛山一部" and depart="小微贷事业部" then branch_name="佛山三部";
if branch_name="江阴一部" and depart="小微贷事业部" then branch_name="无锡二部";
if branch_name="岳阳一部" and depart="小微贷事业部" then branch_name="常德一部";
if product_name="房贷通" then depart="房贷事业部";
run;
/*2016/6/23开始的滞纳金*/
%read_tablen(&path,特殊扣款表,Sheet1,zhinajin);
proc sql;
create table al_pay_znj as
select
     a._COL1 as CONTRACT_NO,
	 sum(a._COL3) as znj
from zhinajin a 
where a._COL7 in ("成功","交易成功","扣款成功")
group by a._COL1;
quit;
proc sql;
create table all_cust as
select
     a.*,
	 b.znj
from all_cust a 
left join al_pay_znj b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;
data all_cust;
retain sys depart region_name city branch_name CUST_MNG SURVEYMAN AUDITMAN CONTRACT_NO cust_name 
       pro_name ID_NUM GENDER loan_amount con_amount mon_pay total_pay periods_num con_yue daishou_yue thircon thirdaishou_yue prin_yue loan_date pay_day 
       sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay done MARRY age sales_code customer_sources WS_INS MOBILE	
       ADDR CORP_NAME CORP_ADDR CORP_PHONE SPO_NAME SPO_PHONE SPO_CORP SPO_CORP_ADDR SPO_CORP_PHO SPO_CORP_POS 
       CON_NAME1 CON_REL1 CON_PHO1 CON_ADDR1 CON_CORP_NAME1 CON_COM_POS1 CON_COM_PHO1 CON_NAME2	CON_REL2 CON_PHO2 
       CON_ADDR2 CON_CORP_NAME2 CON_CORP_POS2 CON_CORP_PHO2 CON_NAME3 CON_REL3 CON_PHO3	CON_ADDR3 CON_CORP_NAME3 CON_CORP_POS3	
       CON_CORP_PHO3 product_name wik;
set all_cust;
run;
data all_cust;
set all_cust;
label sys="签约系统"
      REGION_NAME="大区"
      depart="事业部"
      BRANCH_NAME="营业部"
      city="城市"
      CUST_MNG="客户经理"
      SURVEYMAN="审核人"
      AUDITMAN="审批人"
      CONTRACT_NO="合同编号"
      cust_name="客户名字"
	  
	  pro_name="产品名字"
      ID_NUM="身份证"
	  GENDER="性别"
	  loan_amount="放款金额"
      con_amount="合同金额"
      mon_pay="每月还款额"
      total_pay="累计应还总额"
      periods_num="期数"
	  con_yue="合同余额" 
      prin_yue="剩余本金"
      loan_date="放款时间"
	  pay_day="还款日"

      sh_pay_peri="应还期数"
	  al_pay_period="已还期数"
	  sh_pay_sum="当前应还总额"
	  al_pay_sum="当前已还总额"
	  overdue_dt="逾期时间"
	  overdue_day="逾期天数"
      overdue_pay="滞纳金"
      last_pay="最后一次还款日"
      MARRY="婚姻状况"
      MOBILE="客户手机号码"

      ADDR="客户住址"
      CORP_NAME="客户公司名字"
      CORP_ADDR="客户公司地址" 
	  CORP_PHONE="客户公司电话"
      SPO_NAME="配偶名字"
	  SPO_PHONE="配偶电话"
      SPO_CORP="配偶公司名字"
	  SPO_CORP_ADDR="配偶公司地址"
	  SPO_CORP_PHO="配偶公司电话"
	  SPO_CORP_POS="配偶公司职位"

	  CON_NAME1="联系人1名字"
	  CON_REL1="联系人1关系"
	  CON_PHO1="联系人1电话"
	  CON_ADDR1="联系人1住址"
	  CON_CORP_NAME1="联系人1公司名字"
	  CON_COM_POS1="联系人1公司职位"
      CON_COM_PHO1="联系人1公司电话"
	  CON_NAME2="联系人2名字"
	  CON_REL2="联系人2关系"
	  CON_PHO2="联系人2电话"

	  CON_ADDR2="联系人2住址"
	  CON_CORP_NAME2="联系人2公司名字"
	  CON_CORP_POS2="联系人2公司职位"
      CON_CORP_PHO2="联系人2公司电话"
	  CON_NAME3="联系人3名字"
	  CON_REL3="联系人3关系"
	  CON_PHO3="联系人3电话"
	  CON_ADDR3="联系人3住址"
	  CON_CORP_NAME3="联系人3公司名字"
	  CON_CORP_POS3="联系人3公司职位"

      CON_CORP_PHO3="联系人3公司电话"
	  wik="下次还款日"
	  customer_sources="来源渠道"
      WS_INS="网商机构"
	  age="客户年龄"
	  sales_code="客户经理工号"
	  product_name="原始产品类型"
	  payall_flag="提前结清"
	  done="是否委外"
      thircon="30天前的合同余额"
      daishou_yue="待收余额"
      thirdaishou_yue="30天前的待收余额"
      znj="新扣滞纳金";
run;
/* 输出数据源*/
PROC EXPORT DATA=all_cust OUTFILE="E:\source_data\数据源_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;


