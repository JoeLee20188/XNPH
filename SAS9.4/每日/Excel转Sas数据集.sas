%let path=D:\ǰ�����ٸ��մ����˷���;/*��������·��*/
libname dat "D:\ǰ�����ٸ��մ����˷���\SAS���ݼ�";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
/*ÿ����ˮ*/
%read_tablen(&path,���ݻ��ܣ����ظ���,����,pay1);
%read_tablen(&path,���ݻ��ܣ����ظ���,����1,pay2);
data pay1;
set pay1(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
data pay2;
set pay2(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
data pay; 
set pay1 pay2;
run;
/*ɾ����ˮ�е��ظ�ֵ*/
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;
data dat.pay;
set pay;
run;
/*��ϵͳ�ſ�Ŀͻ�*/
%read_tablen(&path,new_xn_dis,����������,dis_2);
data dat.dis_2;
set dis_2;
run;
/*��ϵͳ�ͻ�����*/
%read_tablen(&path,new_out_info,����������,new_out_info);
data dat.new_out_info;
set new_out_info;
run;
/*��ϵͳ��������*/
%read_tablen(&path,RM_member,����������,RM_member);
data dat.RM_member;
set RM_member;
run;
/*��ϵͳ�ͻ�����*/
/*%read_tablen(&path,old_out_info,sheet1,old_out_info);*/
/*data dat.old_out_info;*/
/*set old_out_info;*/
/*run;*/

data pay;
set dat.pay;
run;
data pay1;
set pay(firstobs=1 obs=1000000);
run;
data pay2;
set pay(firstobs=1000001 obs=1548954);
run;


PROC EXPORT DATA=pay2 OUTFILE="E:\source_data\�ȫ����ˮ.xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET='���ֶ�';
RUN;
/*��ȡ�ض�����ˮ*/
/*%read_tablen(&path,��ϵͳ�ͻ����е���ˮ,aaa,aaa);*/
/*data dat.pay;*/
/*set aaa(rename=(_COL0=submit_date _COL1=amount _COL2=cust_name _COL3=per_corp _COL4=comment _COL5=cert_id _COL6=contractno));*/
/*run;*/
