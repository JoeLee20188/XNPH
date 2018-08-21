%let path=E:\basic_data;/*��������·��*/
%let today="13Sep2016"d;
%let mytoday=20160913;
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
/*�ջ���*/
proc sql;
create table sday as
select
      a.submit_date,
      sum(amount)/10000 as day_sum
from pay a 
group by submit_date;
quit;
/*�»���*/
data fig_my;
set sday;
year=year(submit_date);
dmonth=month(submit_date);
if dmonth<10 then ddmonth=compress("0"||dmonth); else ddmonth=dmonth;
month=input(compress(year||ddmonth),12.);
drop dmonth ddmonth;
run;
proc sql;
create table smonth as
select
      a.month,
      sum(day_sum) as month_sum
from fig_my a 
group by month;
quit;
proc sort data=smonth out=smonth;
by month;
run;
/*�����*/
proc sql;
create table syear as
select
      a.year,
      sum(day_sum) as year_sum
from fig_my a 
group by year;
quit;
/*����������*/
data symd;
merge sday smonth syear;
run;
/*�����ֶ�����label*/
data symd;
set symd(rename=(submit_date=day));
label day="��" day_sum="����" month="��" month_sum="����" year="��" year_sum="����";
run;
/* ���*/
PROC EXPORT DATA=symd OUTFILE="E:\source_data\�������&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;




















