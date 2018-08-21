%let path=D:\ǰ�����ٸ��մ����˷���;/*��������·��*/
libname dat "D:\ǰ�����ٸ��մ����˷���\SAS���ݼ�";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
%macro decode/PARMBUFF;
%local i count ifn valuen countall currfeild valueelse;
%let countall=%sysfunc(countw(&SYSPBUFF,%quote(,)));
%let count=%eval((&countall-1)/2);
%let currfeild=%scan(%quote(&SYSPBUFF),1);
case &currfeild 
%do i=1 %to &count;
%let ifn=%scan(%quote(&SYSPBUFF),%eval(&i*2));
%let valuen=%scan(%quote(&SYSPBUFF),%eval(&i*2+1));

when &ifn then &valuen
%end;

%if %eval(&countall>(&count+1)) %then %do;
%let valueelse=%scan(%quote(&SYSPBUFF),&countall);
else &valueelse
%end;
end
%mend;/*���Ա�����ź�*/

/*ԭʼ�б��嵥��*/
%read_tablen(&path,���ճб��嵥-����2018��5��,Sheet1,sales_performance1);
/*�����ֶ�*/
data sales_performance2;
set sales_performance1(rename=(_COL1=branch_com _COL3=center_support_com _COL5=support_com _COL7=sale_district _COL8=sale_part _COL9=sale_group _COL10=policy_holder 
_COL12=ip_id _COL15=ins_name _COL16=ins_type _COL17=ins_state _COL18=pay_year_type _COL19=pay_year _COL21=underwriting_date
_COL22=withdrawing_date _COL23=surrender_date _COL24=scale_premium _COL26=num_of_underwriting _COL27=sales_id _COL28=sales_name _COL29=sales_position
_COL30=sign_date _COL41=self_uw _COL44=fyb _COL45=fyb_new _COL46=channel));
keep branch_com center_support_com support_com sale_district sale_part sale_group policy_holder ip_id ins_name ins_type 
	ins_state pay_year_type pay_year underwriting_date withdrawing_date surrender_date scale_premium  num_of_underwriting sales_id sales_name
	sales_position sign_date self_uw fyb fyb_new channel;
run;
data dat.sales_performance;
set sales_performance2;
run;

/*ԭʼӪ��Ա���ϱ�*/
%read_tablen(&path,����Ӫ��Ա����,Sheet1,sales_property1);
data sales_property2;
set sales_property1(rename=(_COL0=sales_code _COL1=sales_name1 _COL2=branch_com1 _COL3=center_support_com1 _COL4=support_com _COL5=sale_district1 
_COL6=sale_part1 _COL7=sale_group1 _COL8=job_state _COL9=sign_date _COL10=leave_date _COL11=sales_position1 
_COL12=sales_position2 _COL13=education _COL14=cert_id _COL15=native_place _COL16=age _COL17=age_com _COL18=sex _COL19=marry _COL20=addr));
keep sales_code sales_name1 branch_com1 center_support_com1 support_com sale_district1 sale_part1 sale_group1 job_state sign_date 
	leave_date sales_position1 sales_position2 education cert_id native_place age  age_com sex marry addr;
run;
data dat.sales_property;
set sales_property2;
run;

/*����Ӫ��Ա�ۼ�ҵ��************************************************************************************************/
/*1.�ۼ���ҵ��*/
proc sql;/*�ۼ�fyb*/
create table total_sale1 as
select
      b.sales_code,
	  sum(a.fyb_new) as fyb_new_sum,
	  sum(a.fyb) as fyb
from dat.sales_performance a
left join dat.sales_property b on a.sales_id=b.sales_code
group by b.sales_code;
quit;
/*2.��˾ʱ��*/
proc sql;/*ƥ����˾����˾ʱ��*/
create table total_sale2 as
select
      a.*,
	  b.sign_date,
	  b.leave_date
from total_sale1 a
left join dat.sales_property b on a.sales_code=b.sales_code;
quit;
data total_sale3;
set total_sale2;
if leave_date=. then leave_date="31May2018"d;
run;
proc sql;/*�����ۼ�ҵ��������ְ�·�*8000p��Ӫ��Ա*/
create table total_sale4 as
select
      a.*,
	  ((a.leave_date-a.sign_date)*8000/30) as sale_standard
from total_sale3 a where ((a.leave_date-a.sign_date)*8000/30)<=a.fyb_new_sum;
quit;

/*����б�������2017��3��31���ڽ��ĵ���Ȼ��Ч�ı���********************************************************************/
proc sql;/*���ڽ�����*/
create table continue_rate1 as
select
      b.sales_code,
	  sum(a.fyb_new) as fyb_new_sum,
	  sum(a.fyb) as fyb
from dat.sales_performance a
left join dat.sales_property b on a.sales_id=b.sales_code
where a.pay_year_type^="����" and a.underwriting_date<="31Mar2017"d and a.ins_state^="������ֹ"
group by b.sales_code;
quit;
proc sql;/*������Ȼ��Ч�ı���*/
create table continue_rate2 as
select
      b.sales_code,
	  sum(a.fyb_new) as fyb_new_sum1,
	  sum(a.fyb) as fyb1
from dat.sales_performance a
left join dat.sales_property b on a.sales_id=b.sales_code
where a.pay_year_type^="����" and a.underwriting_date<="31Mar2017"d and a.ins_state="��Ч" and a.ins_state^="������ֹ"
group by b.sales_code;
quit;	
proc sql;/*�������ʴ���70%��Ӫ��Ա��*/
create table continue_rate3 as
select
      a.sales_code,
	  b.fyb_new_sum1/a.fyb_new_sum as continue_rate
from continue_rate1 a
left join continue_rate2 b on a.sales_code=b.sales_code
having continue_rate>=0.7;
quit;	

/*Ŀ�꼨��ҵ��Ա********************************************************************/
proc sql;/*1.�м����ʵģ�ҵ���ͼ����ʾ�����Ҫ��2.��û�м����ʵģ�ǩԼʱ���ڣ�*/
create table target_sales1 as
select
      a.*,
	  b.*
from total_sale4 a
left join continue_rate3 b on a.sales_code=b.sales_code;
quit;
data target_sales2;
set target_sales1;
if continue_rate^=. then output;
run;
data target_sales3;
set target_sales1;
if sign_date>"31Mar2017"d then output;
run;
data target_sales;
set target_sales2 target_sales3;
run;

/*ƥ��Ӫ��Ա���ԣ����csv�ļ�*******************************************************************************/
proc sql;/**/
create table sales1 as
select
      a.sales_code,
	  a.sales_name1,
	  a.branch_com1,
	  a.education,
	  a.native_place,
	  a.age,
	  a.age_com,
	  a.sex,
	  a.marry,
	  a.addr,
	  b.sales_code as fig
from dat.sales_property a
left join target_sales b on a.sales_code=b.sales_code;
quit;
data sales2;
set sales1;
if age>=100 or age<=0 then delete;/*ɾ�˷��й���½��Ӫ��Ա*/
if marry="-" then delete;
if fig=" " then fig=0; else fig=1;
if branch_com1="�Ϻ�" and substr(native_place,1,2)="31" then ifnative=1;
if branch_com1="����" and substr(native_place,1,6)="320500" then ifnative=1;
if branch_com1="����" and substr(native_place,1,2)="32" then ifnative=1;
if branch_com1="����" and substr(native_place,1,6)="440300" then ifnative=1;
if branch_com1="��ɽ" and substr(native_place,1,6)="440600" then ifnative=1;
if branch_com1="��ɽ" and substr(native_place,1,6)="442000" then ifnative=1;
if branch_com1="����" and substr(native_place,1,6)="440100" then ifnative=1;
if branch_com1="��ݸ" and substr(native_place,1,6)="441900" then ifnative=1;
if branch_com1="ɽ��" and substr(native_place,1,2)="37" then ifnative=1;
if branch_com1="�Ĵ�" and substr(native_place,1,2)="51" then ifnative=1;
if branch_com1="����" and substr(native_place,1,2)="42" then ifnative=1;
if branch_com1="�㶫" and substr(native_place,1,2)="44" then ifnative=1;
if branch_com1="�麣" and substr(native_place,1,6)="440400" then ifnative=1;
run;
data sales3;
set sales2;
if ifnative=. then ifnative=0;
keep fig education ifnative age_com sex marry;
run;
data sales;/*ȫ��ת������ֵ����*/
set sales3;
if education in ("�м�","��ר","����","��ר") then education=0;else education=1;
if sex="��" then sex=1;else sex=0;
if marry in ("�־�","���","����","ɥż","����") then marry=0; else marry=1;
run;

PROC EXPORT DATA=sales OUTFILE="D:\ǰ�����ٸ��մ����˷���\Ӫ��Ա��������Դ.csv" DBMS=CSV REPLACE;
RUN;


/*data sales;/*ȫ��ת������ֵ����*/*/
/*set sales3;*/
/*if education in ("�м�","��ר") then education=0;*/
/*if education in ("����") then education=1;*/
/*if education in ("��ר") then education=2;*/
/*if education in ("����") then education=3;*/
/*if education in ("����") then education=4;*/
/*if education in ("˶ʿ") then education=5;*/
/*if education in ("��ʿ") then education=6;*/
/*if sex="��" then sex=1;else sex=0;*/
/*if marry in ("�־�","���","����","ɥż") then marry=0;*/
/*if marry="����" then marry=1;*/
/*if marry="���" then marry=2; */
/*if substr(native_place,1,2) in ("11","12","13","14","15") then native_place=0;/*����*/*/
/*if substr(native_place,1,2) in ("21","22","23") then native_place=1;/*����*/*/
/*if substr(native_place,1,2) in ("31","32","33","34","35","36","37") then native_place=2;/*����*/*/
/*if substr(native_place,1,2) in ("41","42","43","44","45","46") then native_place=3;/*����*/*/
/*if substr(native_place,1,2) in ("50","51","52","53","54") then native_place=4;/*����*/*/
/*if substr(native_place,1,2) in ("61","62","63","64","65") then native_place=5;/*����*/*/
/*run;*/
/**/
/*/*����ֱ�Ӷ�ȡsas���ݼ������ٶ�ȡexcel*/*/
/*data tansuo1;*/
/*set dat.sales_performance;*/
/*run;*/
/**/
/*/*��ʼ��������Ԥ����*/*/
/*proc sort data=tansuo1 out=tansuo2;*/
/*by ip_id;*/
/*run;*/
/**/
/*proc sql;*/
/*create table ins_state_test as*/
/*select*/
/*      a.ins_state,*/
/*      count(ins_state) as ins_state_num,*/
/*	  sum(fyb) as fyb_num*/
/*from tansuo2 a */
/*group by ins_state;*/
/*quit;*/
/**/
/*proc sql;*/
/*create table ip_id_test as*/
/*select*/
/*      a.ip_id,*/
/*      count(ip_id) as ip_id_num*/
/*from tansuo2 a */
/*group by ip_id;*/
/*quit;*/

