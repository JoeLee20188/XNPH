%let path=D:\basic_data;/*��������·��*/
%let today="22Nov2016"d;
%let mytoday=20161122;
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
if d0>=pay_day then sh_pay_peri=m0;else sh_pay_peri=m0-1;
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
/*������ˮ*/
data pay;
set dat.pay;
if comment in ("ȫ������","ȫ������","ȫ�����","ȫ�����") then payall=1; else payall=0;/*��ǰ����ͻ�*/
run;
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
/*�����ͬ��ÿ�»���Ӧ���ܶ��Լ��ж��Ƿ�����*/
data aaa;
set dis_pay_old;
al_pay_period=floor((al_pay_sum/(round(mon_pay,1)))+0.001);/*�ѻ�����*/
total_pay=round(mon_pay*periods_num,0.01);/*�ܼ�Ӧ���ܶ�*/
sh_pay_sum=round(mon_pay*sh_pay_peri-10,0.01);/*��ǰӦ���ܶ�*/
if payall_flag=1 then do;overdue_dt=.;end;
if payall_flag=0 then do;/*δ��עȫ������Ŀͻ�*/
   if sh_pay_sum<=al_pay_sum then do;overdue_dt=.;end; 
   if sh_pay_sum>al_pay_sum then do;
      overdue_dt=intnx("month",loan_date,al_pay_period+1,"sameday");
      overdue_day=intck("day",overdue_dt,&today);
	  prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
	  if city="����" then do; 
         sh_pay_ram=round((sh_pay_peri-al_pay_period)*(mon_pay-con_amount/periods_num),0.01);/*��ǰδ������Ѻ���Ϣ�ܶ�*/
         overdue_pay=round((sh_pay_ram+prin_yue)*0.001*overdue_day,0.01);/*���ɽ�=������+ʣ�౾��*0.001*��������*/ 
      end;
	  if city^="����" then do; 
         sh_pay_rat=round(con_amount*0.01*(sh_pay_peri-al_pay_period),0.01);/*��ǰδ����Ϣ�ܶ�*/
         overdue_pay=round((sh_pay_rat+prin_yue)*0.001*overdue_day,0.01);/*���ɽ�=������+ʣ�౾��*0.001*��������*/ 
      end;
   end;
end;
con_yue=round(con_amount-al_pay_sum,0.01);
prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
prin_yue1=round(loan_amount-(loan_amount/periods_num)*al_pay_period,0.01);
/*���㵱ǰ��ǰ�����ܶ�*/
if city="����" then do; 
   sh_pay_ram=round((sh_pay_peri-al_pay_period)*(mon_pay-con_amount/periods_num),0.01);/*��ǰδ������Ѻ���Ϣ�ܶ�*/
   tiqian_pay=round(sh_pay_ram+prin_yue+overdue_pay+con_amount*0.02,0.01);/*��ǰ�����ܶ�=����+ʣ�౾��+���ɽ�+��ǰ����ΥԼ��+δ���ۿ�ʧ�������ѣ��޷�֪����*/ 
end;
if city^="����" then do; 
   sh_pay_rat=round(con_amount*0.01*(sh_pay_peri-al_pay_period),0.01);/*��ǰδ����Ϣ�ܶ�*/
   tiqian_pay=round(sh_pay_rat+prin_yue+overdue_pay+con_amount*0.02,0.01);/*��ǰ�����ܶ�=����+ʣ�౾��+���ɽ�+��ǰ����ΥԼ��+δ���ۿ�ʧ�������ѣ��޷�֪����*/ 
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
/*������˵Ҫ�ӵľ�ϵͳ�ͻ�������*/
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
/*****************************************************��ϵͳ*********************************************************************************************************/
/*�����ͬ��ÿ�»���Ӧ���ܶ��Լ��ж��Ƿ�����*/
data ccc;
set dis_pay_new;
al_pay_period=floor((al_pay_sum/(round(mon_pay,1)))+0.001);/*�ѻ�����*/
total_pay=round(mon_pay*periods_num,0.01);/*�ܼ�Ӧ���ܶ�*/
sh_pay_sum=round(mon_pay*sh_pay_peri-10,0.01);/*��ǰӦ���ܶ�*/
if payall_flag=1 then do;overdue_dt=.;end;
if payall_flag=0 then do;/*δ��עȫ������Ŀͻ�*/
   if sh_pay_sum<=al_pay_sum then do;overdue_dt=.;end; 
   if sh_pay_sum>al_pay_sum then do;
      overdue_dt=intnx("month",loan_date,al_pay_period+1,"sameday");
      overdue_day=intck("day",overdue_dt,&today);
      prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
	  if substr(contract_no,1,3)=001 then do; 
         sh_pay_ram=round((sh_pay_peri-al_pay_period)*(mon_pay-con_amount/periods_num),0.01);/*��ǰδ������Ѻ���Ϣ�ܶ�*/
         overdue_pay=round((sh_pay_ram+prin_yue)*0.001*overdue_day,0.01);/*���ɽ�=������+ʣ�౾��*0.001*��������*/ 
      end;
	  if substr(contract_no,1,3)^=001 then do; 
         sh_pay_rat=round(con_amount*0.01*(sh_pay_peri-al_pay_period),0.01);/*��ǰδ����Ϣ�ܶ�*/
         overdue_pay=round((sh_pay_rat+prin_yue)*0.001*overdue_day,0.01);/*���ɽ�=������+ʣ�౾��*0.001*��������*/ 
      end;
   end;
end;
con_yue=round(con_amount-al_pay_sum,0.01);
prin_yue=round(con_amount-(con_amount/periods_num)*al_pay_period,0.01);
prin_yue1=round(loan_amount-(loan_amount/periods_num)*al_pay_period,0.01);
/*���㵱ǰ��ǰ�����ܶ�*/
if substr(contract_no,1,3)=001 then do; 
   sh_pay_ram=round((sh_pay_peri-al_pay_period)*(mon_pay-con_amount/periods_num),0.01);/*��ǰδ������Ѻ���Ϣ�ܶ�*/
   tiqian_pay=round(sh_pay_ram+prin_yue+overdue_pay+con_amount*0.02,0.01);/*��ǰ�����ܶ�=����+ʣ�౾��+���ɽ�+��ǰ����ΥԼ��+δ���ۿ�ʧ�������ѣ��޷�֪����*/ 
end;
if substr(contract_no,1,3)^=001 then do; 
   sh_pay_rat=round(con_amount*0.01*(sh_pay_peri-al_pay_period),0.01);/*��ǰδ����Ϣ�ܶ�*/
   tiqian_pay=round(sh_pay_rat+prin_yue+overdue_pay+con_amount*0.02,0.01);/*��ǰ�����ܶ�=����+ʣ�౾��+���ɽ�+��ǰ����ΥԼ��+δ���ۿ�ʧ�������ѣ��޷�֪����*/ 
end;
format overdue_dt mmddyy10.;
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
       CON_CORP_PHO3 tiqian_pay;
set dis_pay_new;
drop product_name cert_id division depart;
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
	  tiqian_pay="��ǰ�����ܶ�"
	  outmoney="ί�н��(��)"
	  outdate="ί������"
      deadline="��������" 
	  done="�Ƿ�ί��";
run;
data dat.wy_info&mytoday.;
set all_cust;
run;
data yq_cust;
set all_cust;
if overdue_day>=61 and done="" then output;
run;
/*ɾ���ض��ͻ�*/
data yq_cust;
set yq_cust;
if overdue_day<=90 and depart='ũ�̴���ҵ��' then delete;
if region_name='С΢����' or region_name='С΢����' then delete;
if depart='������ҵ��' then delete; 
run;
/*�ٴ�ί��*/
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
/* �����ǰ������������51���ί������*/
PROC EXPORT DATA=yq_cust OUTFILE="E:\source_data\��ǰ����_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
/* �����ǰί���ί������*/
PROC EXPORT DATA=zw_cust OUTFILE="E:\source_data\��ǰί��_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;


