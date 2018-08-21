%let path=D:\basic_data;/*��������·��*/
%let today="31Oct2016"d;
%let mytoday=20161031;
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
data pay;
set pay;
if submit_date<=&today. then output;
run;
/*�ѻ���ʱ��ת��*/
     /*����һ���ͻ�һ���ڶ�ʻ���*/
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
var amount1;
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
/*���룬����ſ��*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
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
if d0>=pay_day then sh_pay_peri=m0;else sh_pay_peri=m0-1;
if sh_pay_peri>=periods_num then sh_pay_peri=periods_num;/*Ӧ���������ܳ�������*/
if loan_date<=&today.;/*�ſ����ڽ���֮ǰ��������*/
drop m0 d0 pay_day;
run;
/*****************************************************���ɻ���ƻ�**************************************************************************/
data dis;/*����ÿ�ڿۿ�����*/
set dis;
array term(60);
do i=1 to periods_num;
	term(i)=intnx("month",loan_date,i,"sameday");
end;
format term1-term60 yymmdd10.;
drop i;
run;
/*����ˮ*/
proc sql;
create table d_p as
select
      a.*,
	  b.*
from dis a
left join pay b
on a.CONTRACT_NO=b.contractno;
quit;
/*�����*/
%macro qiuhe(i); 
proc sql;
create table a&i. as
select
      a.contract_no,
      a.term&i.,
      sum(amount) as al_sum&i.,
	  &i.*mon_pay as sh_sum&i.,
	  &i.*mon_pri as sh_pri_sum&i.,
	  &i.*mon_int as sh_int_sum&i.,
	  &i.*mon_man as sh_man_sum&i.
from d_p a 
where submit_date<=term&i.
group by contract_no;
quit;
proc sort data=a&i. nodupkey;
by contract_no;
run;
%mend qiuhe;
%qiuhe(1);
%qiuhe(2);
%qiuhe(3);
%qiuhe(4);
%qiuhe(5);
%qiuhe(6);
%qiuhe(7);
%qiuhe(8);
%qiuhe(9);
%qiuhe(10);
%qiuhe(11);
%qiuhe(12);
data all;
merge a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12;
by contract_no;
keep contract_no al_sum1 al_sum2 al_sum3 al_sum4 al_sum5 al_sum6 al_sum7 al_sum8 al_sum9 al_sum10 al_sum11 al_sum12
                 sh_sum1 sh_sum2 sh_sum3 sh_sum4 sh_sum5 sh_sum6 sh_sum7 sh_sum8 sh_sum9 sh_sum10 sh_sum11 sh_sum12
                 sh_pri_sum1 sh_pri_sum2 sh_pri_sum3 sh_pri_sum4 sh_pri_sum5 sh_pri_sum6 sh_pri_sum7 sh_pri_sum8 sh_pri_sum9 sh_pri_sum10 sh_pri_sum11 sh_pri_sum12
                 sh_int_sum1 sh_int_sum2 sh_int_sum3 sh_int_sum4 sh_int_sum5 sh_int_sum6 sh_int_sum7 sh_int_sum8 sh_int_sum9 sh_int_sum10 sh_int_sum11 sh_int_sum12
                 sh_man_sum1 sh_man_sum2 sh_man_sum3 sh_man_sum4 sh_man_sum5 sh_man_sum6 sh_man_sum7 sh_man_sum8 sh_man_sum9 sh_man_sum10 sh_man_sum11 sh_man_sum12;
run;
/*����ԭ���ſ����ֶ�*/
proc sql;
create table final as
select
      a.*,
	  b.product_name,real_customer,cert_id,loan_amount,periods_num,loan_date,b.CONTRACT_NO,con_amount,mon_pay,mon_pri,mon_int,mon_man,term1,term2,term3,term4,term5,term6
from all a
left join dis b
on a.contract_no=b.contract_no; 
quit;
data final;
retain product_name real_customer cert_id loan_amount periods_num loan_date CONTRACT_NO con_amount mon_pay mon_pri mon_int mon_man term1 al_sum1 term2 al_sum2 term3 al_sum3 term4 al_sum4 term5 al_sum5 term6 al_sum6;
set final;
format loan_date date9.;
run;

/**********************************************************************************/
/*����ת�ù�����ˮ*/
proc sql;
create table final as
select
      a.*,
	  b.*
from final a
left join liushui b
on a.contract_no=b.contractno; 
quit;
/*����һЩ�ֶ�*/
data ziduan;
set dat.quanbu_cust20161104;
keep CONTRACT_NO depart REGION_NAME BRANCH_NAME city CUST_MNG sales_code;
run;
proc sql;
create table final as
select
      a.*,
	  b.*
from final a
left join ziduan b
on a.contract_no=b.contract_no; 
quit;
data dat.lvjiarong;
set final;
run;
/*������*/
PROC EXPORT DATA=final OUTFILE="E:\source_data\�������ݷ�������&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
/*%output_tablen(final,huankuan,sheet1,&path.);*/

