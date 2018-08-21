%let path=D:\前海人寿个险代理人分析;/*基础数据路径*/
libname dat "D:\前海人寿个险代理人分析\SAS数据集";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
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
%mend;/*属性变量编号宏*/

/*原始承保清单表*/
%read_tablen(&path,个险承保清单-截至2018年5月,Sheet1,sales_performance1);
/*整理字段*/
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

/*原始营销员资料表*/
%read_tablen(&path,个险营销员资料,Sheet1,sales_property1);
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

/*计算营销员累计业绩************************************************************************************************/
/*1.累计总业绩*/
proc sql;/*累计fyb*/
create table total_sale1 as
select
      b.sales_code,
	  sum(a.fyb_new) as fyb_new_sum,
	  sum(a.fyb) as fyb
from dat.sales_performance a
left join dat.sales_property b on a.sales_id=b.sales_code
group by b.sales_code;
quit;
/*2.在司时长*/
proc sql;/*匹配入司和离司时间*/
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
proc sql;/*符合累计业绩大于在职月份*8000p的营销员*/
create table total_sale4 as
select
      a.*,
	  ((a.leave_date-a.sign_date)*8000/30) as sale_standard
from total_sale3 a where ((a.leave_date-a.sign_date)*8000/30)<=a.fyb_new_sum;
quit;

/*计算承保日期在2017年3月31日期交的单仍然生效的比例********************************************************************/
proc sql;/*总期交保费*/
create table continue_rate1 as
select
      b.sales_code,
	  sum(a.fyb_new) as fyb_new_sum,
	  sum(a.fyb) as fyb
from dat.sales_performance a
left join dat.sales_property b on a.sales_id=b.sales_code
where a.pay_year_type^="趸交" and a.underwriting_date<="31Mar2017"d and a.ins_state^="契撤终止"
group by b.sales_code;
quit;
proc sql;/*现在仍然生效的保费*/
create table continue_rate2 as
select
      b.sales_code,
	  sum(a.fyb_new) as fyb_new_sum1,
	  sum(a.fyb) as fyb1
from dat.sales_performance a
left join dat.sales_property b on a.sales_id=b.sales_code
where a.pay_year_type^="趸交" and a.underwriting_date<="31Mar2017"d and a.ins_state="生效" and a.ins_state^="契撤终止"
group by b.sales_code;
quit;	
proc sql;/*“继续率大于70%的营销员”*/
create table continue_rate3 as
select
      a.sales_code,
	  b.fyb_new_sum1/a.fyb_new_sum as continue_rate
from continue_rate1 a
left join continue_rate2 b on a.sales_code=b.sales_code
having continue_rate>=0.7;
quit;	

/*目标绩优业务员********************************************************************/
proc sql;/*1.有继续率的，业绩和继续率均满足要求；2.还没有继续率的（签约时间在）*/
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

/*匹配营销员属性，输出csv文件*******************************************************************************/
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
if age>=100 or age<=0 then delete;/*删了非中国大陆的营销员*/
if marry="-" then delete;
if fig=" " then fig=0; else fig=1;
if branch_com1="上海" and substr(native_place,1,2)="31" then ifnative=1;
if branch_com1="苏州" and substr(native_place,1,6)="320500" then ifnative=1;
if branch_com1="江苏" and substr(native_place,1,2)="32" then ifnative=1;
if branch_com1="深圳" and substr(native_place,1,6)="440300" then ifnative=1;
if branch_com1="佛山" and substr(native_place,1,6)="440600" then ifnative=1;
if branch_com1="中山" and substr(native_place,1,6)="442000" then ifnative=1;
if branch_com1="广州" and substr(native_place,1,6)="440100" then ifnative=1;
if branch_com1="东莞" and substr(native_place,1,6)="441900" then ifnative=1;
if branch_com1="山东" and substr(native_place,1,2)="37" then ifnative=1;
if branch_com1="四川" and substr(native_place,1,2)="51" then ifnative=1;
if branch_com1="湖北" and substr(native_place,1,2)="42" then ifnative=1;
if branch_com1="广东" and substr(native_place,1,2)="44" then ifnative=1;
if branch_com1="珠海" and substr(native_place,1,6)="440400" then ifnative=1;
run;
data sales3;
set sales2;
if ifnative=. then ifnative=0;
keep fig education ifnative age_com sex marry;
run;
data sales;/*全部转换成数值变量*/
set sales3;
if education in ("中技","中专","高中","大专") then education=0;else education=1;
if sex="男" then sex=1;else sex=0;
if marry in ("分居","离婚","其他","丧偶","单身") then marry=0; else marry=1;
run;

PROC EXPORT DATA=sales OUTFILE="D:\前海人寿个险代理人分析\营销员分析数据源.csv" DBMS=CSV REPLACE;
RUN;


/*data sales;/*全部转换成数值变量*/*/
/*set sales3;*/
/*if education in ("中技","中专") then education=0;*/
/*if education in ("高中") then education=1;*/
/*if education in ("大专") then education=2;*/
/*if education in ("本科") then education=3;*/
/*if education in ("本科") then education=4;*/
/*if education in ("硕士") then education=5;*/
/*if education in ("博士") then education=6;*/
/*if sex="男" then sex=1;else sex=0;*/
/*if marry in ("分居","离婚","其他","丧偶") then marry=0;*/
/*if marry="单身" then marry=1;*/
/*if marry="结婚" then marry=2; */
/*if substr(native_place,1,2) in ("11","12","13","14","15") then native_place=0;/*华北*/*/
/*if substr(native_place,1,2) in ("21","22","23") then native_place=1;/*东北*/*/
/*if substr(native_place,1,2) in ("31","32","33","34","35","36","37") then native_place=2;/*华东*/*/
/*if substr(native_place,1,2) in ("41","42","43","44","45","46") then native_place=3;/*华中*/*/
/*if substr(native_place,1,2) in ("50","51","52","53","54") then native_place=4;/*西南*/*/
/*if substr(native_place,1,2) in ("61","62","63","64","65") then native_place=5;/*西北*/*/
/*run;*/
/**/
/*/*以下直接读取sas数据集，不再读取excel*/*/
/*data tansuo1;*/
/*set dat.sales_performance;*/
/*run;*/
/**/
/*/*开始进行数据预处理*/*/
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

