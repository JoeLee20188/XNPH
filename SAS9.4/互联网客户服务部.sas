%let path=E:\basic_data;/*��������·��*/
%let today="22Nov2016"d;
%let mytoday=20161122;
%let yqday=&today.-30;
libname dat "E:\data";
/*��ǰ����ͻ�*/
data all_1;
set dat.pay;
if comment in ("ȫ������","ȫ������","ȫ�����","ȫ�����") then output;
run;
/*������������*/
data all_2;
set dat.pay; 
comment=compress(comment);
a=index(comment,"�ۿ�")+4;
b=index(comment,"��");
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
PROC EXPORT DATA=final OUTFILE="E:\source_data\������������Դ���ٴ���_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
