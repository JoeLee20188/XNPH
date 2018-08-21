%let path=D:\basic_data;/*基础数据路径*/
%let today="31Oct2016"d;
%let mytoday=20161031;
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
/*读入，预处理payment表
%read_tablen(&path,数据汇总（有重复）,汇总,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;*/
/*删除流水中的重复值
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
/*把还款时间转置*/
     /*处理一个客户一天内多笔还款*/
proc sql;
create table pay1 as
select
      a.*,
	  sum(amount) as amount1
from pay a
group by submit_date,CONTRACTNO;/*(提交日期 合同编号)*/
quit;
proc sort data=pay1 nodupkey;/*一个客户一天合并为一笔*/
by  submit_date CONTRACTNO;
run;
proc sort data=pay1 out=aaa;
by contractno;
proc transpose data=aaa out=bbb let;/*转置每一笔的还款日期*/
by contractno;
var submit_date;
run;
data bbbb;
set bbb(rename=(COL1=d1 COL2=d2 COL3=d3 COL4=d4 COL5=d5 COL6=d6 COL7=d7 COL8=d8 COL9=d9 COL10=d10 COL11=d11 COL12=d12 COL13=d13 COL14=d14 COL15=d15 COL16=d16 COL17=d17 COL18=d18 COL19=d19 COL20=d20 COL21=d21));
drop _NAME_ _LABEL_;
label d1='第一笔还款日期' d2='第二笔还款日期' d3='第三笔还款日期' d4='第四笔还款日期' d5='第五笔还款日期' d6='第六笔还款日期' d7='第七笔还款日期'
      d8='第八笔还款日期' d9='第九笔还款日期' d10='第十笔还款日期' d11='第十一笔还款日期' d12='第十二笔还款日期' d13='第十三笔还款日期' d14='第十四笔还款日期'
      d15='第十五笔还款日期' d16='第十六笔还款日期' d17='第十七笔还款日期' d18='第十八笔还款日期' d19='第十九笔还款日期' d20='第二十笔还款日期' d21='第二十一笔还款日期';
run;
proc transpose data=aaa out=ccc let;/*装置每一笔的还款金额*/
by contractno;
var amount1;
run;
data cccc;
set ccc(rename=(COL1=a1 COL2=a2 COL3=a3 COL4=a4 COL5=a5 COL6=a6 COL7=a7 COL8=a8 COL9=a9 COL10=a10 COL11=a11 COL12=a12 COL13=a13 COL14=a14 COL15=a15 COL16=a16 COL17=a17 COL18=a18 COL19=a19 COL20=a20 COL21=a21));
drop _NAME_ _LABEL_;
label a1='第一笔还款金额' a2='第二笔还款金额' a3='第三笔还款金额' a4='第四笔还款金额' a5='第五笔还款金额' a6='第六笔还款金额' a7='第七笔还款金额'
      a8='第八笔还款金额' a9='第九笔还款金额' a10='第十笔还款金额' a11='第十一笔还款金额' a12='第十二笔还款金额' a13='第十三笔还款金额' a14='第十四笔还款金额'
      a15='第十五笔还款金额' a16='第十六笔还款金额' a17='第十七笔还款金额'a18='第十八笔还款金额' a19='第十九笔还款金额' a20='第二十笔还款金额' a21='第二十一笔还款金额';
run;
data liushui;
merge bbbb cccc;
run;
data liushui;
retain contractno d1 a1 d2 a2 d3 a3 d4 a4 d5 a5 d6 a6 d7 a7 d8 a8 d9 a9 d10 a10 d11 a11 d12 a12 d13 a13 d14 a14 d15 a15 d16 a16 d17 a17 d18 a18 d19 a19 d20 a20 d21 a21 ;
set liushui;
run;/*转置流水完毕*/
/*读入，处理放款表*/
%read_tablen(&path,old_xn_dis,sheet1,dis_1);
/*%read_tablen(&path,new_xn_dis,导出工作表,dis_2);*/
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
if loan_date<=&today.;/*放款日在今天之前（包括）*/
drop m0 d0 pay_day;
run;
/*****************************************************生成还款计划**************************************************************************/
data dis;/*生成每期扣款日期*/
set dis;
array term(60);
do i=1 to periods_num;
	term(i)=intnx("month",loan_date,i,"sameday");
end;
format term1-term60 yymmdd10.;
drop i;
run;
/*连流水*/
proc sql;
create table d_p as
select
      a.*,
	  b.*
from dis a
left join pay b
on a.CONTRACT_NO=b.contractno;
quit;
/*定义宏*/
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
/*连上原来放款表的字段*/
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
/*加入转置过的流水*/
proc sql;
create table final as
select
      a.*,
	  b.*
from final a
left join liushui b
on a.contract_no=b.contractno; 
quit;
/*加上一些字段*/
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
/*输出结果*/
PROC EXPORT DATA=final OUTFILE="E:\source_data\还款数据分析数据&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
/*%output_tablen(final,huankuan,sheet1,&path.);*/

