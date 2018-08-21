%let path=C:\Users\JoeLee\Downloads\�½��ļ���;/*��������·��*/
libname dat "D:\FSL_client_analysis";
/*%macro read_table(path,table_name,data_name);*/
/*proc import datafile="&path.\&table_name..csv" dbms=csv out=&data_name. replace;*/
/*datarow = 3;*/
/*getnames = no;*/
/*guessingrows = 50000;/*��ֹ��ȡ����ʱ
���ѣ���5����֮ǰ���������Ϊ���ֶεĿ��*/*/
/*run;*/
/*%mend read_table;/*�����*/*/
/***������proc import���̶�ȡ���ݵ��ֶ��������Կ���***/;
/*data data11;*/
/*set data1;*/
/*/*(rename=*/
/*				(trade_date=trade_date_1));*/
/*trade_date=put(trade_date_1,yymmdd10.);*//*����ֵ�ͻ��ַ��ͱ���תΪ�ַ��ͱ���*/*/
/*/*if trade_date=. then drop trade_date;*/*/
/*run;*/;
%macro read_table(path,table_name,data_name);
data &data_name.;
%let _EFIERR_ = 0; /*set the ERROR detection macro variable*/
infile "&path.\&table_name..csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=3 ;
informat VAR1 $38. ;
informat VAR2 $2. ;
informat VAR3 $14. ;
informat VAR4 $48. ;
informat VAR5 $123. ;
informat VAR6 $31. ;
informat VAR7 $22. ;
informat VAR8 $29. ;
informat VAR9 $22. ;
informat VAR10 $22. ;
informat VAR11 $25. ;
informat VAR12 yymmdd10. ;
informat VAR13 $12. ;
informat VAR14 $40. ;
informat VAR15 $24. ;
informat VAR16 yymmdd10. ;
informat VAR17 yymmdd10. ;
informat VAR18 yymmdd10. ;
informat VAR19 best32. ;
informat VAR20 $14. ;
informat VAR21 $9. ;
informat VAR22 $10. ;
informat VAR23 $10. ;
informat VAR24 $16. ;
informat VAR25 $14. ;
informat VAR26 $2. ;
format VAR1 $38. ;
format VAR2 $2. ;
format VAR3 $14. ;
format VAR4 $48. ;
format VAR5 $123. ;
format VAR6 $31. ;
format VAR7 $22. ;
format VAR8 $29. ;
format VAR9 $22. ;
format VAR10 $22. ;
format VAR11 $25. ;
format VAR12 yymmdd10. ;
format VAR13 $12. ;
format VAR14 $40. ;
format VAR15 $24. ;
format VAR16 yymmdd10. ;
format VAR17 yymmdd10. ;
format VAR18 yymmdd10. ;
format VAR19 best12. ;
format VAR20 $14. ;
format VAR21 $9. ;
format VAR22 $10. ;
format VAR23 $10. ;
format VAR24 $16. ;
format VAR25 $14. ;
format VAR26 $2. ;
input
	VAR1 $
	VAR2 $
	VAR3 $
	VAR4 $
	VAR5 $
	VAR6 $
	VAR7 $
	VAR8 $
	VAR9 $
	VAR10 $
	VAR11 $
	VAR12
	VAR13 $
	VAR14 $
	VAR15 $
	VAR16
	VAR17
	VAR18
	VAR19
	VAR20 $
	VAR21 $
	VAR22 $
	VAR23 $
	VAR24 $
	VAR25 $
	VAR26 $;
if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;
%mend read_table;/*�����*/
%read_table(&path,�ͻ����յȼ�00000000-20140211,data1);
%read_table(&path,�ͻ����յȼ�20140212-20140715,data2);
%read_table(&path,�ͻ����յȼ�20140716-20140828,data3);
%read_table(&path,�ͻ����յȼ�20140829-20141104,data4);
%read_table(&path,�ͻ����յȼ�20141105-20150106,data5);
%read_table(&path,�ͻ����յȼ�20150107-20150212,data6);
%read_table(&path,�ͻ����յȼ�20150213-20150317,data7);
%read_table(&path,�ͻ����յȼ�20150318-20150323,data8);
%read_table(&path,�ͻ����յȼ�20150324-20150623,data9);
%read_table(&path,�ͻ����յȼ�20150624-20150727,data10);
%read_table(&path,�ͻ����յȼ�20150728-20150926,data11);
%read_table(&path,�ͻ����յȼ�20150927-20151230,data12);
%read_table(&path,�ͻ����յȼ�20151231-20160205,data13);
%read_table(&path,�ͻ����յȼ�20160206-20160318,data14);
%read_table(&path,�ͻ����յȼ�20160319-20160629,data15);
%read_table(&path,�ͻ����յȼ�20160630-20160920,data16);
%read_table(&path,�ͻ����յȼ�20160921-20161124,data17);
%read_table(&path,�ͻ����յȼ�20161125-20170228,data18);
%read_table(&path,�ͻ����յȼ�20170301-20170607,data19);
%read_table(&path,�ͻ����յȼ�20170608-20170920,data20);
%read_table(&path,�ͻ����յȼ�20170921-20180105,data21);
%read_table(&path,�ͻ����յȼ�20180106-20180213,data22);
%read_table(&path,�ͻ����յȼ�20180214-20180327,data23);
%read_table(&path,�ͻ����յȼ�20180328-20180807,data24);

%macro pro_rename(data_name);
data &data_name.;
set &data_name.(rename=(VAR1=name VAR2=sex VAR3=nationality VAR4=job VAR5=addr VAR6=mail VAR7=mobile VAR8=comp_tele VAR9=home_tele VAR10=id_type VAR11=id VAR12=id_date VAR13=risk_level VAR14=name_of_insur VAR15=insur_num VAR16=trade_date VAR17=insur_begin VAR18=insur_end VAR19=trade_amount VAR20=pay_meth VAR21=pay_year VAR22=pay_mode VAR23=sale_chan VAR24=name_of_comp VAR25=policy_state VAR26=day_180));
label 
	name=����
	sex=�Ա�	
	nationality=����	
	job=����	
	addr=��ַ	
	mail=�ʼ�	
	mobile=�ƶ�����	
	comp_tele=�����绰	
	home_tele=��ͥ�绰	
	id_type=֤������	
	id=֤������	
	id_date=���֤����Ч��	
	risk_level=���յȼ�	
	name_of_insur=��������	
	insur_num=���պ�ͬ��	
	trade_date=��������	
	insur_begin=��������	
	insur_end=����ֹ��	
	trade_amount=���׽��	
	pay_meth=�ɷѷ�ʽ	
	pay_year=�ɷ�����	
	pay_mode=֧����ʽ	
	sale_chan=��������	
	name_of_comp=��˾����	
	policy_state=����״̬	
	day_180=�Ƿ���180����;
run;
%mend pro_rename;/*�����ֶ����ƺ�*/
%pro_rename(data1);%pro_rename(data2);%pro_rename(data3);%pro_rename(data4);%pro_rename(data5);
%pro_rename(data6);%pro_rename(data7);%pro_rename(data8);%pro_rename(data9);%pro_rename(data10);
%pro_rename(data11);%pro_rename(data12);%pro_rename(data13);%pro_rename(data14);%pro_rename(data15);
%pro_rename(data16);%pro_rename(data17);%pro_rename(data18);%pro_rename(data19);%pro_rename(data20);
%pro_rename(data21);%pro_rename(data22);%pro_rename(data23);%pro_rename(data24);

%macro set_data(data_add);
proc append base=data1 data=&data_add. force;quit;
%mend set_data;/*�ϲ����ݼ���*/
%set_data(data2);%set_data(data3);%set_data(data4);%set_data(data5);%set_data(data6);
%set_data(data7);%set_data(data8);%set_data(data9);%set_data(data10);%set_data(data11);
%set_data(data12);%set_data(data13);%set_data(data14);%set_data(data15);%set_data(data16);
%set_data(data17);%set_data(data18);%set_data(data19);%set_data(data20);%set_data(data21);
%set_data(data22);%set_data(data23);%set_data(data24);
data dat.FSL_client;/*�������յĿͻ�����Դ*/
set data1;
run;
/*����Ա����Ϣ*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*����(2013��excel)��*/
%read_tablen(&path,Ա��,owssvr,employee);
data employee;
set employee;
emp_bir_date1=input(_COL6,yymmdd10.);
emp_bir_date=put(emp_bir_date1,date9.);
drop emp_bir_date1;
run;

/*�˺�ֱ������sas����Դ***************************************************************************************************************************************/
data FSL_client;
set dat.FSL_client;
run;
/*����id*/
data FSL_client;
set FSL_client(rename=(id=id_new));
id_length=length(id_new);
if id_length=21 then id=substr(id_new,3,18);else id=id_new;/*��ȡ����λ��ʼ��18λid*/
drop id_new id_length;
label id=֤������;
run;
/*��ȡid�е���Ϣ�����ᣬ�������£�����ʱ�����䣬�Ա�*/
data FSL_client;
set FSL_client;
if length(id)=18 then island="��";else island="��";/*���������Ƿ�Ϊ�й���½����*/
if island="��" then do;
	native_place_code=substr(id,1,6);
	birth_date2=substr(id,7,8);
	birth_date1=input(birth_date2,yymmdd10.);
	birth_date=put(birth_date1,date9.);
	trade_age=year(trade_date)-substr(birth_date2,1,4);
	if mod(substr(id,17,1),2)=0 then sex="Ů";else sex="��";/*����ˢ���Ա�*/
end;
drop birth_date2 birth_date1;
run;
data check;
set FSL_client;
if age<0 then output;
run;
/*��˾Ա���������*/
proc sql;
create table emp_trade as
select
a._COL1,
a.emp_bir_date,
count(b.trade_amount),
sum(trade_amount) as trade_amount_sum
from employee a left join FSL_client b on a._COL1=b.name
where a._COL1=b.name and a.emp_bir_date=b.birth_date
group by a._COL1,a.emp_bir_date;
quit;
/*�ֶ�͸��*/
proc sql;
create table trade_amount_sum as
select
trade_age,
sale_chan,
sum(trade_amount) as trade_amount_sum
from FSL_client
group by trade_age,sale_chan;
quit;
/*�ֶ�͸��*/
proc sql;
create table trade_amount_sum as
select
policy_state,
sale_chan,
sum(trade_amount) as trade_amount_sum
from FSL_client
group by policy_state,sale_chan;
quit;
/*ɾ���ظ�ֵ*/
proc sort data=FSL_client out=data_1 nodupkey;
by id;
run;
/*�����¿ͻ�*/
proc sql;
create table client_201807 as
select
*
from FSL_client
where trade_date<='31Jul2018'd and trade_date>='01Jul2018'd;
quit;
proc sql;
create table id_times as
select
id,
count(id) as times
from FSL_client
group by id;
quit;
proc sql;
create table client_2018071 as
select
a.id,b.id as b_id
from client_201807 a left join id_times b on a.id=b.id
where times=1;
quit;
/**/
proc sql;
create table yqday as
select
CONTRACTNO,
sum(amount) as yqsum
from FSL_client
where submit_date<=&yqday
group by CONTRACTNO;
quit;
