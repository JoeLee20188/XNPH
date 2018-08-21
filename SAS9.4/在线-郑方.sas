
%macro lishi(mytoday);
libname dat "E:\data";
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;
/*��Ӣ���ͻ�*/
data JYD;
set all;
loan_yue=(loan_amount/periods_num)*(periods_num-al_pay_period);
if product_name="Сţ��Ӣ��" or product_name="��Ӣ��" then output;
run;
/*����M0-6+*/
data all_M;
set JYD;
if loan_yue<0 then loan_yue=0;
if      overdue_day=.    then do interval="M0"; M0=loan_yue;end;
if 1  <=overdue_day<=30  then do interval="M1"; M1=loan_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=loan_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=loan_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=loan_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=loan_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=loan_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=loan_yue; end;
run;
/*�������ڽ��*/
proc sql;
create table JYD_Money as
select
round(sum(M0)/10000,0.01) as M0_sum,
round(sum(M1)/10000,0.01) as M1_sum,
round(sum(M2)/10000,0.01) as M2_sum,
round(sum(M3)/10000,0.01) as M3_sum,
round(sum(M4)/10000,0.01) as M4_sum,
round(sum(M5)/10000,0.01) as M5_sum,
round(sum(M6)/10000,0.01) as M6_sum,
round(sum(M6_plus)/10000,0.01) as M6_plus_sum,
round(sum(loan_yue)/10000,0.01) as fengmu
from all_M a;
quit;
/*��ֵ��Ϊ0*/
data JYD_Money;
set JYD_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
run;
/*����������*/
proc sql;
create table JYD_Rate as
select
round(M1_sum/(fengmu),0.0001) as M1_Rate,
round(M2_sum/(fengmu),0.0001) as M2_Rate,
round(M3_sum/(fengmu),0.0001) as M3_Rate,
round(M4_sum/(fengmu),0.0001) as M4_Rate,
round(M5_sum/(fengmu),0.0001) as M5_Rate,
round(M6_sum/(fengmu),0.0001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.0001) as M6_plus_Rate,
round(sum(M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum+M6_plus_sum)/(fengmu),0.0001) as Total_Rate
from JYD_Money a;
quit;
/*�����ʷ�һ��*/
data a1;
merge JYD_Money JYD_Rate;
run;
/*�Ӹ���ʶ*/
data a&mytoday.;
set a1;
fig=&mytoday.;
run;
%mend lishi;/*�����ض����ڵľ�Ӣ������������ĺ�*/
%lishi(20150831);
%lishi(20150930);
%lishi(20151031);
%lishi(20151130);
%lishi(20151231);
%lishi(20160131);
%lishi(20160229);
%lishi(20160331);
%lishi(20160430);
%lishi(20160531);
%lishi(20160630);
%lishi(20160731);
%lishi(20160831);
%lishi(20160930);
/*����ÿһ��ʱ���*/
data final;
set a20150831 a20150930 a20151031 a20151130 a20151231
    a20160131 a20160229 a20160331 a20160430 a20160531
    a20160630 a20160731 a20160831 a20160930;
run;



/******************************�������**********************************************************************/
%macro lishi(mytoday);
libname dat "E:\data";
data all;
set dat.quanbu_cust&mytoday.;
drop MOBILE CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3
;
run;
/*��Ӣ���ͻ�*/
data JYD;
set all;
if product_name="Сţ��Ӣ��" or product_name="��Ӣ��" then output;
run;
/*����M0-6+*/
data all_M;
set JYD;
if daishou_yue<0 then daishou_yue=0;
if      overdue_day=.    then do interval="M0"; M0=daishou_yue;end;
if 1  <=overdue_day<=30  then do interval="M1"; M1=daishou_yue;end;
if 31 <=overdue_day<=60  then do interval="M2"; M2=daishou_yue;end;
if 61 <=overdue_day<=90  then do interval="M3"; M3=daishou_yue;end;
if 91 <=overdue_day<=120 then do interval="M4"; M4=daishou_yue;end;
if 121<=overdue_day<=150 then do interval="M5"; M5=daishou_yue;end;
if 151<=overdue_day<=180 then do interval="M6"; M6=daishou_yue;end;
if overdue_day>=181 then do interval="M6+"; M6_plus=daishou_yue; end;
run;
/*�������ڽ��*/
proc sql;
create table JYD_Money as
select
round(sum(M0)/10000,0.01) as M0_sum,
round(sum(M1)/10000,0.01) as M1_sum,
round(sum(M2)/10000,0.01) as M2_sum,
round(sum(M3)/10000,0.01) as M3_sum,
round(sum(M4)/10000,0.01) as M4_sum,
round(sum(M5)/10000,0.01) as M5_sum,
round(sum(M6)/10000,0.01) as M6_sum,
round(sum(M6_plus)/10000,0.01) as M6_plus_sum,
round(sum(daishou_yue)/10000,0.01) as fengmu
from all_M a;
quit;
/*��ֵ��Ϊ0*/
data JYD_Money;
set JYD_Money;
if M1_sum=. then M1_sum=0;if M2_sum=. then M2_sum=0;if M3_sum=. then M3_sum=0;if M4_sum=. then M4_sum=0;if M5_sum=. then M5_sum=0;if M6_sum=. then M6_sum=0;if M6_plus_sum=. then M6_plus_sum=0;
run;
/*����������*/
proc sql;
create table JYD_Rate as
select
round(M1_sum/(fengmu),0.0001) as M1_Rate,
round(M2_sum/(fengmu),0.0001) as M2_Rate,
round(M3_sum/(fengmu),0.0001) as M3_Rate,
round(M4_sum/(fengmu),0.0001) as M4_Rate,
round(M5_sum/(fengmu),0.0001) as M5_Rate,
round(M6_sum/(fengmu),0.0001) as M6_Rate,
round(M6_plus_sum/(fengmu),0.0001) as M6_plus_Rate,
round(sum(M1_sum+M2_sum+M3_sum+M4_sum+M5_sum+M6_sum+M6_plus_sum)/(fengmu),0.0001) as Total_Rate
from JYD_Money a;
quit;
/*�����ʷ�һ��*/
data a1;
merge JYD_Money JYD_Rate;
run;
/*�Ӹ���ʶ*/
data a&mytoday.;
set a1;
fig=&mytoday.;
run;
%mend lishi;/*�����ض����ڵľ�Ӣ������������ĺ�*/
%lishi(20150831);
%lishi(20150930);
%lishi(20151031);
%lishi(20151130);
%lishi(20151231);
%lishi(20160131);
%lishi(20160229);
%lishi(20160331);
%lishi(20160430);
%lishi(20160531);
%lishi(20160630);
%lishi(20160731);
%lishi(20160831);
%lishi(20160930);
/*����ÿһ��ʱ���*/
data final1;
set a20150831 a20150930 a20151031 a20151130 a20151231
    a20160131 a20160229 a20160331 a20160430 a20160531
    a20160630 a20160731 a20160831 a20160930;
run;
/* �������Դ*/
PROC EXPORT DATA=final OUTFILE="E:\source_data\����֣�����ſ����ʣ�౾��.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
/* �������Դ*/
PROC EXPORT DATA=final1 OUTFILE="E:\source_data\����֣����������.xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
