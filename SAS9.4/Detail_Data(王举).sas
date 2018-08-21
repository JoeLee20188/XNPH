libname overdue'E:\data';

%macro wj(today);
data allcust&today;
set overdue.quanbu_cust&today;
format interval $8.;
if overdue_day=0 or overdue_day=. then interval="M0";if overdue_day>0 and overdue_day<=30 then interval="M1";
if overdue_day>30 and overdue_day<=60 then interval="M2";if overdue_day>60 and overdue_day<=90 then interval="M3";
if overdue_day>90 and overdue_day<=120 then interval="M4";if overdue_day>120 and overdue_day<=150 then interval="M5"; 
if overdue_day>150 and overdue_day<=180 then interval="M6";if overdue_day>180 then interval="M6M";
format normal_amount best12.;
if overdue_day=. or overdue_day=0 then normal_amount=daishou_yue;
if overdue_day>0 then normal_amount=0;
format od_amount best12.;
if overdue_day=. or overdue_day=0 then od_amount=0;
if overdue_day>0 then od_amount=daishou_yue;
format x $4.;
format y $2.;
format ldate $8.;
x=year(loan_date);
y=month(loan_date);
ldate=x||y;
drop x y;
keep sys depart region_name city branch_name CUST_MNG CONTRACT_NO cust_name ID_NUM con_amount mon_pay 
	 total_pay con_yue daishou_yue loan_date al_pay_sum sh_pay_sum overdue_day sales_code mon_pri mon_int mon_man al_pay_period
	normal_amount od_amount payall_flag FIR_ID FIR SEC_ID SEC THI_ID THI interval ldate periods_num pro_name product_name loan_amount;
run;

/****��ϸ*****/
data detail&today;
set allcust&today;
un_pri=(periods_num-al_pay_period)*mon_pri;
un_int=(periods_num-al_pay_period)*mon_int;
un_man=(periods_num-al_pay_period)*mon_man;
keep depart region_name city branch_name CONTRACT_NO loan_date con_amount total_pay al_pay_sum al_pay_period daishou_yue un_pri un_int un_man interval
		;
run;

libname output excel "E:\source_data\wj&today..xlsx";
data output.��ϸ(DBlabel=yes);
set detail&today;
label depart="��ҵ��" region_name="����"  city="����" branch_name="�ŵ�" CONTRACT_NO="��ͬ���" loan_date="�ſ�����" con_amount="��ͬ���" total_pay="�ۼ�Ӧ���ܶ�" al_pay_sum="�ѻ����" al_pay_period="�ѻ�����" daishou_yue="�������"
	  un_pri="ʣ�౾��" un_int="ʣ����Ϣ" un_man="ʣ������" interval="���ڼ���";
run;
libname output clear;
%mend wj;

%wj(20161124);
run;


