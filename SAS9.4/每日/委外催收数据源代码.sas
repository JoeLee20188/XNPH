%let path=D:\basic_data;/*基础数据路径*/
%let today="22Nov2016"d;
%let mytoday=20161122;
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
/*读入流水*/
data pay;
set dat.pay;
if comment in ("全款收完","全部结清","全额结清","全款结清") then payall=1; else payall=0;/*提前结清客户*/
run;
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
/*计算合同金额，每月还款额，应还总额以及判断是否逾期*/
data aaa;
set dis_pay_old;
al_pay_period=floor((al_pay_sum/(round(mon_pay,1)))+0.001);/*已还期数*/
total_pay=round(mon_pay*periods_num,0.01);/*总计应还总额*/
sh_pay_sum=round(mon_pay*sh_pay_peri-10,0.01);/*当前应还总额*/
if payall_flag=1 then do;overdue_dt=.;end;
if payall_flag=0 then do;/*未标注全款收完的客户*/
   if sh_pay_sum<=al_pay_sum then do;overdue_dt=.;end; 
   if sh_pay_sum>al_pay_sum then do;
      overdue_dt=intnx("month",loan_date,al_pay_period+1,"sameday");
      overdue_day=intck("day",overdue_dt,&today);
	  prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
	  if city="深圳" then do; 
         sh_pay_ram=round((sh_pay_peri-al_pay_period)*(mon_pay-con_amount/periods_num),0.01);/*当前未还服务费和利息总额*/
         overdue_pay=round((sh_pay_ram+prin_yue)*0.001*overdue_day,0.01);/*滞纳金=（上面+剩余本金）*0.001*逾期天数*/ 
      end;
	  if city^="深圳" then do; 
         sh_pay_rat=round(con_amount*0.01*(sh_pay_peri-al_pay_period),0.01);/*当前未还利息总额*/
         overdue_pay=round((sh_pay_rat+prin_yue)*0.001*overdue_day,0.01);/*滞纳金=（上面+剩余本金）*0.001*逾期天数*/ 
      end;
   end;
end;
con_yue=round(con_amount-al_pay_sum,0.01);
prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
prin_yue1=round(loan_amount-(loan_amount/periods_num)*al_pay_period,0.01);
/*计算当前提前还款总额*/
if city="深圳" then do; 
   sh_pay_ram=round((sh_pay_peri-al_pay_period)*(mon_pay-con_amount/periods_num),0.01);/*当前未还服务费和利息总额*/
   tiqian_pay=round(sh_pay_ram+prin_yue+overdue_pay+con_amount*0.02,0.01);/*提前还款总额=上面+剩余本金+滞纳金+提前还款违约金+未交扣款失败手续费（无法知道）*/ 
end;
if city^="深圳" then do; 
   sh_pay_rat=round(con_amount*0.01*(sh_pay_peri-al_pay_period),0.01);/*当前未还利息总额*/
   tiqian_pay=round(sh_pay_rat+prin_yue+overdue_pay+con_amount*0.02,0.01);/*提前还款总额=上面+剩余本金+滞纳金+提前还款违约金+未交扣款失败手续费（无法知道）*/ 
end;
format overdue_dt mmddyy10.;
run;
data bbb;
retain sys depart region city ORGNAME_fig CUST_MNG SURVEYMAN AUDITMAN CONTRACT_NO cust_name 
       pro_name ID_NUM GENDER loan_amount con_amount mon_pay total_pay periods_num con_yue prin_yue loan_date pay_day 
       sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay MARRY MOBILE	
       ADDR CORP_NAME CORP_ADDR CORP_PHONE SPO_NAME SPO_PHONE SPO_CORP SPO_CORP_ADDR SPO_CORP_PHO SPO_CORP_POS 
       CON_NAME1 CON_REL1 CON_PHO1 CON_ADDR1 CON_CORP_NAME1 CON_COM_POS1 CON_COM_PHO1 CON_NAME2	CON_REL2 CON_PHO2 
       CON_ADDR2 CON_CORP_NAME2 CON_CORP_POS2 CON_CORP_PHO2 CON_NAME3 CON_REL3 CON_PHO3	CON_ADDR3 CON_CORP_NAME3 CON_CORP_POS3	
       CON_CORP_PHO3 tiqian_pay;
set aaa;
drop CONTRACTNO product_name cert_id division MANAGEFEES FEE ORGNAME;
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
/*吕嘉容说要加的旧系统客户经理工号*/
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
/*****************************************************新系统*********************************************************************************************************/
/*计算合同金额，每月还款额，应还总额以及判断是否逾期*/
data ccc;
set dis_pay_new;
al_pay_period=floor((al_pay_sum/(round(mon_pay,1)))+0.001);/*已还期数*/
total_pay=round(mon_pay*periods_num,0.01);/*总计应还总额*/
sh_pay_sum=round(mon_pay*sh_pay_peri-10,0.01);/*当前应还总额*/
if payall_flag=1 then do;overdue_dt=.;end;
if payall_flag=0 then do;/*未标注全款收完的客户*/
   if sh_pay_sum<=al_pay_sum then do;overdue_dt=.;end; 
   if sh_pay_sum>al_pay_sum then do;
      overdue_dt=intnx("month",loan_date,al_pay_period+1,"sameday");
      overdue_day=intck("day",overdue_dt,&today);
      prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
	  if substr(contract_no,1,3)=001 then do; 
         sh_pay_ram=round((sh_pay_peri-al_pay_period)*(mon_pay-con_amount/periods_num),0.01);/*当前未还服务费和利息总额*/
         overdue_pay=round((sh_pay_ram+prin_yue)*0.001*overdue_day,0.01);/*滞纳金=（上面+剩余本金）*0.001*逾期天数*/ 
      end;
	  if substr(contract_no,1,3)^=001 then do; 
         sh_pay_rat=round(con_amount*0.01*(sh_pay_peri-al_pay_period),0.01);/*当前未还利息总额*/
         overdue_pay=round((sh_pay_rat+prin_yue)*0.001*overdue_day,0.01);/*滞纳金=（上面+剩余本金）*0.001*逾期天数*/ 
      end;
   end;
end;
con_yue=round(con_amount-al_pay_sum,0.01);
prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
prin_yue1=round(loan_amount-(loan_amount/periods_num)*al_pay_period,0.01);
/*计算当前提前还款总额*/
if substr(contract_no,1,3)=001 then do; 
   sh_pay_ram=round((sh_pay_peri-al_pay_period)*(mon_pay-con_amount/periods_num),0.01);/*当前未还服务费和利息总额*/
   tiqian_pay=round(sh_pay_ram+prin_yue+overdue_pay+con_amount*0.02,0.01);/*提前还款总额=上面+剩余本金+滞纳金+提前还款违约金+未交扣款失败手续费（无法知道）*/ 
end;
if substr(contract_no,1,3)^=001 then do; 
   sh_pay_rat=round(con_amount*0.01*(sh_pay_peri-al_pay_period),0.01);/*当前未还利息总额*/
   tiqian_pay=round(sh_pay_rat+prin_yue+overdue_pay+con_amount*0.02,0.01);/*提前还款总额=上面+剩余本金+滞纳金+提前还款违约金+未交扣款失败手续费（无法知道）*/ 
end;
format overdue_dt mmddyy10.;
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
       CON_CORP_PHO3 tiqian_pay;
set dis_pay_new;
drop product_name cert_id division depart;
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
data all_cust;
set all_cust;
if 1<=overdue_day<=90 then do;feerate=0.2 ;service=round(tiqian_pay*feerate,1);end;
if 91<=overdue_day<=180 then do;feerate=0.25 ;service=round(tiqian_pay*feerate,1);end;
if 181<=overdue_day<=360 then do;feerate=0.35 ;service=round(tiqian_pay*feerate,1);end;
if 360<overdue_day then do;feerate=0.4 ;service=round(tiqian_pay*feerate,1);end;
outmoney=tiqian_pay+service;
outdate=&today.;
deadline=intnx("month",outdate,3,"sameday");
format outdate  mmddyy10.
	   deadline  mmddyy10.;
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
data all_cust;
retain outdate deadline outmoney sys depart region_name city branch_name CUST_MNG SURVEYMAN AUDITMAN CONTRACT_NO cust_name 
       pro_name ID_NUM GENDER loan_amount con_amount mon_pay total_pay periods_num con_yue prin_yue loan_date pay_day 
       sh_pay_peri al_pay_period sh_pay_sum al_pay_sum overdue_dt overdue_day overdue_pay last_pay MARRY MOBILE	
       ADDR CORP_NAME CORP_ADDR CORP_PHONE SPO_NAME SPO_PHONE SPO_CORP SPO_CORP_ADDR SPO_CORP_PHO SPO_CORP_POS 
       CON_NAME1 CON_REL1 CON_PHO1 CON_ADDR1 CON_CORP_NAME1 CON_COM_POS1 CON_COM_PHO1 CON_NAME2	CON_REL2 CON_PHO2 
       CON_ADDR2 CON_CORP_NAME2 CON_CORP_POS2 CON_CORP_PHO2 CON_NAME3 CON_REL3 CON_PHO3	CON_ADDR3 CON_CORP_NAME3 CON_CORP_POS3	
       CON_CORP_PHO3 tiqian_pay;
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
	  tiqian_pay="提前还款总额"
	  outmoney="委托金额(总)"
	  outdate="委托日期"
      deadline="到期日期" 
	  done="是否委外";
run;
data dat.wy_info&mytoday.;
set all_cust;
run;
data yq_cust;
set all_cust;
if overdue_day>=61 and done="" then output;
run;
/*删除特定客户*/
data yq_cust;
set yq_cust;
if overdue_day<=90 and depart='农商贷事业部' then delete;
if region_name='小微八区' or region_name='小微九区' then delete;
if depart='房贷事业部' then delete; 
run;
/*再次委外*/
%read_table(&path,zaiwei,Sheet1,zaiw);
proc sql;
create table zw_cust as
select
     a.*,
	 b.*
from all_cust a
left join zaiw b
on a.contract_no=b.zw;
quit;
data zw_cust;
set zw_cust;
if zw^="" then output;
drop zw;
run;
/* 输出当前逾期天数大于51天的委外数据*/
PROC EXPORT DATA=yq_cust OUTFILE="E:\source_data\当前逾期_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
/* 输出提前委外的委外数据*/
PROC EXPORT DATA=zw_cust OUTFILE="E:\source_data\提前委外_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;


