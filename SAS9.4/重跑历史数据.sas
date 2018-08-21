
%macro lishi(today,mytoday);
%let path=D:\basic_data;/*��������·��*/
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
libname mylib odbc datasrc=oracle user=szxn password='szxn#6';*/

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
run;
/*��ˮת��*/
proc sql;
create table pay1 as
select
      a.*,
	  sum(amount) as amount1
from pay a
group by submit_date,CONTRACTNO;/*(�ύ���� ��ͬ���)*/
quit;
proc sort data=pay1 nodupkey;/*һ���ͻ�һ��ϲ�Ϊһ��*/
by  submit_date CONTRACTNO;
run;
proc sort data=pay1 out=aaa;
by contractno;
proc transpose data=aaa out=bbb let;/*ת��ÿһ�ʵĻ�������*/
by contractno;
var submit_date;
run;
data bbbb;
set bbb(rename=(COL1=d1 COL2=d2 COL3=d3 COL4=d4 COL5=d5 COL6=d6 COL7=d7 COL8=d8 COL9=d9 COL10=d10 COL11=d11 COL12=d12 COL13=d13 COL14=d14 COL15=d15 COL16=d16 COL17=d17 COL18=d18 COL19=d19 COL20=d20 COL21=d21));
drop _NAME_ _LABEL_;
label d1='��һ�ʻ�������' d2='�ڶ��ʻ�������' d3='�����ʻ�������' d4='���ıʻ�������' d5='����ʻ�������' d6='�����ʻ�������' d7='���߱ʻ�������'
      d8='�ڰ˱ʻ�������' d9='�ھűʻ�������' d10='��ʮ�ʻ�������' d11='��ʮһ�ʻ�������' d12='��ʮ���ʻ�������' d13='��ʮ���ʻ�������' d14='��ʮ�ıʻ�������'
      d15='��ʮ��ʻ�������' d16='��ʮ���ʻ�������' d17='��ʮ�߱ʻ�������' d18='��ʮ�˱ʻ�������' d19='��ʮ�űʻ�������' d20='�ڶ�ʮ�ʻ�������' d21='�ڶ�ʮһ�ʻ�������';
run;
proc transpose data=aaa out=ccc let;/*װ��ÿһ�ʵĻ�����*/
by contractno;
var amount;
run;
data cccc;
set ccc(rename=(COL1=a1 COL2=a2 COL3=a3 COL4=a4 COL5=a5 COL6=a6 COL7=a7 COL8=a8 COL9=a9 COL10=a10 COL11=a11 COL12=a12 COL13=a13 COL14=a14 COL15=a15 COL16=a16 COL17=a17 COL18=a18 COL19=a19 COL20=a20 COL21=a21));
drop _NAME_ _LABEL_;
label a1='��һ�ʻ�����' a2='�ڶ��ʻ�����' a3='�����ʻ�����' a4='���ıʻ�����' a5='����ʻ�����' a6='�����ʻ�����' a7='���߱ʻ�����'
      a8='�ڰ˱ʻ�����' a9='�ھűʻ�����' a10='��ʮ�ʻ�����' a11='��ʮһ�ʻ�����' a12='��ʮ���ʻ�����' a13='��ʮ���ʻ�����' a14='��ʮ�ıʻ�����'
      a15='��ʮ��ʻ�����' a16='��ʮ���ʻ�����' a17='��ʮ�߱ʻ�����'a18='��ʮ�˱ʻ�����' a19='��ʮ�űʻ�����' a20='�ڶ�ʮ�ʻ�����' a21='�ڶ�ʮһ�ʻ�����';
run;
data liushui;
merge bbbb cccc;
run;
data liushui;
retain contractno d1 a1 d2 a2 d3 a3 d4 a4 d5 a5 d6 a6 d7 a7 d8 a8 d9 a9 d10 a10 d11 a11 d12 a12 d13 a13 d14 a14 d15 a15 d16 a16 d17 a17 d18 a18 d19 a19 d20 a20 d21 a21 ;
set liushui;
run;/*ת����ˮ���*/
data pay;
set pay;
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
if product_name='����ͨ' then sys="old";
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
      overdue_day=intck("day",overdue_dt,&today);
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
      overdue_day=intck("day",overdue_dt,&today);
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
%read_table(&path,out_cust,Sheet1,out_cust);
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
/*��ת����ˮ*/
proc sql;
create table all_cust as
select
     a.*,
	 b.*
from all_cust a 
left join liushui b
on a.CONTRACT_NO=b.CONTRACTNO;
quit;
data all_cust;
set all_cust;
drop contractno;
run;
/*������������Ա*/
%read_tablen(&path,RM_member,����������,RM_member);
%read_tablen(&path,��ϵͳ������������,sheet1,jiu_member);
proc sql;
create table all_cust as
select
     a.*,
	 b.FIR,FIR_ID,SEC,SEC_ID,THI,THI_ID
from all_cust a 
left join RM_member b
on a.CONTRACT_NO=b.CONTRACT_NO;
quit;
proc sql;
create table all_cust as
select
     a.*,
	 b.auditacc
from all_cust a 
left join jiu_member b
on a.AUDITMAN=b.auditby
order by sys;
quit;
data all_cust;
set all_cust;
if FIR='' then FIR=SURVEYMAN; if SEC='' then SEC=AUDITMAN;
if SEC_ID='' then SEC_ID=auditacc;
drop SURVEYMAN AUDITMAN auditacc;
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
retain sys depart region_name city branch_name CUST_MNG CONTRACT_NO cust_name 
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
      FIR="һ������"
      FIR_ID="һ������"	
      SEC="��������"	
      SEC_ID="��������"	
      THI="��������"	
      THI_ID="��������"
      znj="�¿����ɽ�";
run;
/*��������Դ*/
data dat.quanbu_cust&mytoday.;
set all_cust;
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
%lishi("30Sep2016"d,20160930);
%lishi("31Oct2016"d,20161031);
