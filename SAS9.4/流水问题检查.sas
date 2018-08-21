%let path=E:\basic_data;/*基础数据路径*/
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
%read_tablen(&path,数据汇总（有重复）,汇总,pay);
data pay;
set pay(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
/*输出重复值*/
proc sort data=pay dupout=pay_dup nodupkey;
by submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;
proc sort data=pay_dup ;
by CONTRACTNO;
run;
/* 输出重复值*/
PROC EXPORT DATA=pay_dup OUTFILE="E:\source_data\流水重复值.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
/*备注错误*/
proc sql;
create table beizhu as
select
CONTRACTNO,
count(comment) as bzsum
from pay
group by CONTRACTNO,comment;
quit;
data mark_error;
set beizhu;
if bzsum>=2 then output;
run;
/*连出完整的流水*/
proc sql;
create table beizhu as
select
a.*,b.*
from mark_error a
left join pay b
on a.CONTRACTNO=b.CONTRACTNO;
quit;

/* 输出备注有问题*/
PROC EXPORT DATA=beizhu OUTFILE="E:\source_data\备注有问题.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
