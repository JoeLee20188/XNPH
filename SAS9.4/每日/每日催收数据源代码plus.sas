%let path=D:\basic_data;/*��������·��*/
%let today="24Nov2016"d;
%let mytoday=20161124;
%let yqday=&today.-30;
libname dat "E:\data";

%macro read_table(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xls" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_table;/*�����*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
%macro output_table(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xls" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_table;/*�����*/
%macro output_tablen(data_name,table_name,sheet_name,path);
proc export data=&data_name. outfile="&path.\&table_name..xlsx" dbms=excel replace;
sheet = "&sheet_name";
run;
%mend output_tablen;/*����(2013��excel)��*/
/*���룬Ԥ����disbursement��*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
/*proc sql;
connect to oracle as mylib (user=jhjy password=jhjy path=10.15.18.11);
create table table_name as               
select * from connection to mylib (select��); �����в�ѯ��������oracle���﷨
disconnect  from  mylib;
quit;
proc setinit; run;

libname mylib odbc datasrc=newsys user=jhjy password='jhjy';;
libname mylib oracle datasrc=oracle user=szxn password='szxn#6';*/

/*%read_tablen(&path,new_xn_dis,����������,dis_2);*/
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
/*Ӧ������*/
data dis;
set dis;
m0=intck("month",loan_date,&today);
d0=day(&today);
pay_day=day(loan_date);/*������*/
if d0>=pay_day then sh_pay_peri=m0;
/*else sh_pay_peri=m0-1;*//*�������������30���ǣ���31�ŷſ�Ŀͻ�Ӧ��������Ӧ��-1*/
if pay_day>d0 then do;
	if d0=30 and pay_day=31 then sh_pay_peri=m0;
	if d0^=30 or pay_day^=31 then sh_pay_peri=m0-1;
end;
if sh_pay_peri>=periods_num then sh_pay_peri=periods_num;/*Ӧ���������ܳ�������*/
drop m0 d0;
run;
/*ͳһ��Ʒ*/
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
/*���룬Ԥ����payment��
%read_tablen(&path,���ݻ��ܣ����ظ���,����,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;*/
/*ɾ����ˮ�е��ظ�ֵ
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;*/
data pay;
set dat.pay;
if comment in ("ȫ������","ȫ������","ȫ�����","ȫ�����") then payall=1; else payall=0;/*��ǰ����ͻ�*/
run;
/*30��ǰ�Ŀۿ��ܶ�*/
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
if submit_date<=&today then output;/*�ɿ����ڽ���֮ǰ��������*/
run;
proc sql;
create table pay_al as
select
CONTRACTNO,
sum(amount) as al_pay_sum,
max(submit_date) format mmddyy10. as last_pay,/*���ɿ���*/
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
where a.loan_date<=&today;/*�ſ����ڽ���֮ǰ��������*/
quit;
data dis_pay;/*Ŀǰû�л������Ϊ0,���С�������*/
set dis_pay;
if al_pay_sum=. then al_pay_sum=0;
if payall_flag=. then payall_flag=0;
run;
data dis_pay;/*�����¾�ϵͳ����*/
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
/*2016/6/23��ʼ�����ɽ�*/
%read_tablen(&path,����ۿ��,Sheet1,zhinajin);
proc sql;
create table al_pay_znj as
select
     a._COL1 as CONTRACT_NO,
	 sum(a._COL3) as znj
from zhinajin a 
where a._COL7 in ("�ɹ�","���׳ɹ�","�ۿ�ɹ�")
group by a._COL1;
quit;
/*****************************************************��ϵͳ*********************************************************************************************************/
/*�����ϵͳ�ͻ�����
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
/*�����ɽ��*/
proc sql;
create table dis_pay_old as
select
     a.*,
	 b.znj
from dis_pay_old a
left join al_pay_znj b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;	
/*�����ͬ��ÿ�»���Ӧ���ܶ��Լ��ж��Ƿ�����*/
data aaa;
set dis_pay_old;
if znj=. then znj=0;
al_pay_period=floor(((al_pay_sum-znj)/(round(mon_pay,1)))+0.001);/*�ѻ�����*/
total_pay=round(mon_pay*periods_num,0.01);/*�ܼ�Ӧ���ܶ�*/
sh_pay_sum=round(mon_pay*sh_pay_peri-10,0.01);/*��ǰӦ���ܶ�*/
if payall_flag=1 then do;overdue_dt=.;end;
if payall_flag=0 then do;/*δ��עȫ������Ŀͻ�*/
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
/*������˵Ҫ��һЩ�ͻ���Ӫҵ��*/
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
/*������˵Ҫ�ӵľ�ϵͳ�ͻ������ţ�����*/
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
if sales_code="xn017575" then cust_mng="��ΰ��";
if sales_code="xn011584" then cust_mng="�����";
run;
/*�����ɽ��*/
proc sql;
create table dis_pay_old as
select
     a.*,
	 b.znj
from dis_pay_old a
left join al_pay_znj b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;
/*****************************************************��ϵͳ*********************************************************************************************************/
/*�����ͬ��ÿ�»���Ӧ���ܶ��Լ��ж��Ƿ�����*/
data ccc;
set dis_pay_new;
if znj=. then znj=0;
al_pay_period=floor(((al_pay_sum-znj)/(round(mon_pay,1)))+0.001);/*�ѻ�����*/
total_pay=round(mon_pay*periods_num,0.01);/*�ܼ�Ӧ���ܶ�*/
sh_pay_sum=round(mon_pay*sh_pay_peri-10,0.01);/*��ǰӦ���ܶ�*/
if payall_flag=1 then do;overdue_dt=.;end;
if payall_flag=0 then do;/*δ��עȫ������Ŀͻ�*/
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
/*������ϵͳ�ͻ�����
%read_tablen(&path,new_out_info,����������,new_out_info);*/
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
/**********************************�����¾�ϵͳ�Ŀͻ�********************************************************************************************************/
data all_cust;
set old new;
drop real_customer;
run;
/*ί���ǩ*/
%read_tablen(&path,ί��ͻ���,Sheet1,out_cust);
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
/*�´λ�����*/
data all_cust;
set all_cust;
wik=intnx("month",loan_date,sh_pay_peri+1,"sameday");
t0=day(loan_date);
t1=day(wik);
if t0>t1 then do;/*������ĩ����>������ĩ���ڣ�ȡ���¸���1��*/
wik=wik+1;
end;
format wik mmddyy10.;
drop t0 t1;
run;
/*�޸Ĵ�����ʮ������*/
%read_tablen(&path,ϵͳ���ƶ��ձ�,Sheet1,shierqu);
proc sql;
create table all_cust1 as
select
     a.*,
	 b._COL4
from all_cust a
left join shierqu b
on a.branch_name=b._COL2
where a.depart='С΢����ҵ��' and sys='old';
quit;
proc sort data=all_cust1 nodupkey;
by contract_no;
run;
data all_cust2;
set all_cust;
if depart='С΢����ҵ��' and sys='old' then delete;
run;
data all_cust;
set all_cust1 all_cust2;
if _COL4^='' then region_name=_COL4;
drop _COL4;
run;
/*��30��ǰ�ĺ�ͬ���*/
proc sql;
create table all_cust as
select
     a.*,
	 a.con_amount-b.yqsum as thircon
from all_cust a 
left join yqday b
on a.CONTRACT_NO=b.CONTRACTNO;
quit;
/*30��ǰ�Ѿ��ſ����30����û�л�����Ŀͻ�*/
data all_cust;
set all_cust;
if thircon=. and loan_date<=&yqday then thircon=con_amount;
run;
/*��30��ǰ�Ĵ����������ڵĴ������*/
data all_cust;
set all_cust;
daishou_yue=total_pay-al_pay_sum;
thirdaishou_yue=total_pay-con_amount+thircon;
run;
/*�޸�Ӫҵ��*/
data all_cust;
set all_cust;
if branch_name="��ɽһ��" and depart="С΢����ҵ��" then branch_name="��ɽ����";
if branch_name="����һ��" and depart="С΢����ҵ��" then branch_name="��������";
if branch_name="����һ��" and depart="С΢����ҵ��" then branch_name="����һ��";
if product_name="����ͨ" then depart="������ҵ��";
run;
/*2016/6/23��ʼ�����ɽ�*/
%read_tablen(&path,����ۿ��,Sheet1,zhinajin);
proc sql;
create table al_pay_znj as
select
     a._COL1 as CONTRACT_NO,
	 sum(a._COL3) as znj
from zhinajin a 
where a._COL7 in ("�ɹ�","���׳ɹ�","�ۿ�ɹ�")
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
label sys="ǩԼϵͳ"
      REGION_NAME="����"
      depart="��ҵ��"
      BRANCH_NAME="Ӫҵ��"
      city="����"
      CUST_MNG="�ͻ�����"
      SURVEYMAN="�����"
      AUDITMAN="������"
      CONTRACT_NO="��ͬ���"
      cust_name="�ͻ�����"
	  
	  pro_name="��Ʒ����"
      ID_NUM="���֤"
	  GENDER="�Ա�"
	  loan_amount="�ſ���"
      con_amount="��ͬ���"
      mon_pay="ÿ�»����"
      total_pay="�ۼ�Ӧ���ܶ�"
      periods_num="����"
	  con_yue="��ͬ���" 
      prin_yue="ʣ�౾��"
      loan_date="�ſ�ʱ��"
	  pay_day="������"

      sh_pay_peri="Ӧ������"
	  al_pay_period="�ѻ�����"
	  sh_pay_sum="��ǰӦ���ܶ�"
	  al_pay_sum="��ǰ�ѻ��ܶ�"
	  overdue_dt="����ʱ��"
	  overdue_day="��������"
      overdue_pay="���ɽ�"
      last_pay="���һ�λ�����"
      MARRY="����״��"
      MOBILE="�ͻ��ֻ�����"

      ADDR="�ͻ�סַ"
      CORP_NAME="�ͻ���˾����"
      CORP_ADDR="�ͻ���˾��ַ" 
	  CORP_PHONE="�ͻ���˾�绰"
      SPO_NAME="��ż����"
	  SPO_PHONE="��ż�绰"
      SPO_CORP="��ż��˾����"
	  SPO_CORP_ADDR="��ż��˾��ַ"
	  SPO_CORP_PHO="��ż��˾�绰"
	  SPO_CORP_POS="��ż��˾ְλ"

	  CON_NAME1="��ϵ��1����"
	  CON_REL1="��ϵ��1��ϵ"
	  CON_PHO1="��ϵ��1�绰"
	  CON_ADDR1="��ϵ��1סַ"
	  CON_CORP_NAME1="��ϵ��1��˾����"
	  CON_COM_POS1="��ϵ��1��˾ְλ"
      CON_COM_PHO1="��ϵ��1��˾�绰"
	  CON_NAME2="��ϵ��2����"
	  CON_REL2="��ϵ��2��ϵ"
	  CON_PHO2="��ϵ��2�绰"

	  CON_ADDR2="��ϵ��2סַ"
	  CON_CORP_NAME2="��ϵ��2��˾����"
	  CON_CORP_POS2="��ϵ��2��˾ְλ"
      CON_CORP_PHO2="��ϵ��2��˾�绰"
	  CON_NAME3="��ϵ��3����"
	  CON_REL3="��ϵ��3��ϵ"
	  CON_PHO3="��ϵ��3�绰"
	  CON_ADDR3="��ϵ��3סַ"
	  CON_CORP_NAME3="��ϵ��3��˾����"
	  CON_CORP_POS3="��ϵ��3��˾ְλ"

      CON_CORP_PHO3="��ϵ��3��˾�绰"
	  wik="�´λ�����"
	  customer_sources="��Դ����"
      WS_INS="���̻���"
	  age="�ͻ�����"
	  sales_code="�ͻ�������"
	  product_name="ԭʼ��Ʒ����"
	  payall_flag="��ǰ����"
	  done="�Ƿ�ί��"
      thircon="30��ǰ�ĺ�ͬ���"
      daishou_yue="�������"
      thirdaishou_yue="30��ǰ�Ĵ������"
      znj="�¿����ɽ�";
run;
/* �������Դ*/
PROC EXPORT DATA=all_cust OUTFILE="E:\source_data\����Դ_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;


