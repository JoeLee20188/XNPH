%let path=E:\basic_data;/*基础数据路径*/
%let today="22Nov2016"d;
%let mytoday=20161122;
%let yqday=&today.-30;
libname dat "E:\data";
/*提前结清客户*/
data all_1;
set dat.pay;
if comment in ("全款收完","全部结清","全额结清","全款结清") then output;
run;
/*期数正常结束*/
data all_2;
set dat.pay; 
comment=compress(comment);
a=index(comment,"扣款")+4;
b=index(comment,"期");
term=input(substr(comment,a,b-a),$66.);
if term in ("3/3","6/6","9/9","12/12","15/15","18/18","24/24") then output;
drop a b term;
run;
data all;
set all_1 all_2;
run;
proc sort data=all nodupkey;
by contractno;
run;
data info;
set dat.quanbu_cust&mytoday.;
run;
proc sql;
create table final as
select b.*
from all a
left join info b
on a.contractno=b.contract_no
where b.overdue_day=.;
quit;
PROC EXPORT DATA=final OUTFILE="E:\source_data\互联网部数据源（再贷）_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
