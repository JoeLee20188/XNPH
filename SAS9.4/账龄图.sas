/*******************************************��������***********************************************************************************************/

libname yuan "E:\data";
%let loandtnum=20160731;
/*************************************************�ջ�*********************************************************************************************************/

data all;
set yuan.quanbu_cust&loandtnum;
if depart^="������ҵ��";
run;

data all;
set all;
if depart="���̴���ҵ��" then depart="С΢����";
if region_name="������ҵ��" then region_name="δ����";
if region_name="" then region_name="δ����";
if region_name="ũ�̴�" then region_name="δ����";
if city="" then city="�հ�";
if city="ũ�̴�" then city="�հ�";
if branch_name="" then branch_name="�հ�";
if branch_name="������ҵ��" then branch_name="�հ�";
if branch_name="���̻�����" then branch_name="�հ�";
if BRANCH_NAME="�Ͼ��ֹ�˾" then BRANCH_NAME="�Ͼ��ػ��ֹ�˾";
if BRANCH_NAME="ũ�̴�" then BRANCH_NAME="�հ�";
if pro_name="" then pro_name="�հ�";

format interval $8.;
if overdue_day<=0 then interval="M0";
if 0<overdue_day<=30 then interval="M1";
if 30<overdue_day<=60 then interval="M2";
if 60<overdue_day<=90 then interval="M3";
if 90<overdue_day<=120 then interval="M4";
if 120<overdue_day<=150 then interval="M5";
if 150<overdue_day<=180 then interval="M6";
if 180<overdue_day then interval="M6m";

format loan_date date9.;
format ymdate $8.;
format x $4.;
format y $2.;
x=year(loan_date);
y=month(loan_date);
ymdate=x||y;
drop x y;

format conpany ;
if  CONTRACT_NO^="" then conpany="�ջ�";
format data_deadline date9.;
if  CONTRACT_NO^="" then data_deadline=&loandtnum.;

run;

data aa;
set all;
;
run;



data puhui;


run;









libname test excel "E:\����Դ\��ҵ��Դ\��������Դ&loandtnum..xlsx";
data test.����Դ(Dblabel=yes);
set cw;

run;

libname test clear;
