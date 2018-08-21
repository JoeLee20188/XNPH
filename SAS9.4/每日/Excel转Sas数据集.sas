%let path=D:\前海人寿个险代理人分析;/*基础数据路径*/
libname dat "D:\前海人寿个险代理人分析\SAS数据集";
%macro read_tablen(path,table_name,sheet_name,data_name);
proc import datafile="&path.\&table_name..xlsx" dbms=excel out=&data_name. replace;
sheet = "&sheet_name";
getnames = yes;
run;
%mend read_tablen;/*读表(2013版excel)宏*/
/*每日流水*/
%read_tablen(&path,数据汇总（有重复）,汇总,pay1);
%read_tablen(&path,数据汇总（有重复）,汇总1,pay2);
data pay1;
set pay1(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
data pay2;
set pay2(rename=(_COL0=submit_date _COL2=amount _COL4=cust_name _COL5=per_corp _COL6=comment _COL7=cert_id _COL8=contractno));
keep submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
if contractno="" then delete;
run;
data pay; 
set pay1 pay2;
run;
/*删除流水中的重复值*/
proc sort data=pay nodupkey;
by  submit_date cust_name cert_id amount comment per_corp CONTRACTNO;
run;
data dat.pay;
set pay;
run;
/*新系统放款的客户*/
%read_tablen(&path,new_xn_dis,导出工作表,dis_2);
data dat.dis_2;
set dis_2;
run;
/*新系统客户资料*/
%read_tablen(&path,new_out_info,导出工作表,new_out_info);
data dat.new_out_info;
set new_out_info;
run;
/*新系统三级审批*/
%read_tablen(&path,RM_member,导出工作表,RM_member);
data dat.RM_member;
set RM_member;
run;
/*旧系统客户资料*/
/*%read_tablen(&path,old_out_info,sheet1,old_out_info);*/
/*data dat.old_out_info;*/
/*set old_out_info;*/
/*run;*/

data pay;
set dat.pay;
run;
data pay1;
set pay(firstobs=1 obs=1000000);
run;
data pay2;
set pay(firstobs=1000001 obs=1548954);
run;


PROC EXPORT DATA=pay2 OUTFILE="E:\source_data\李华全量流水.xlsx" DBMS=EXCEL REPLACE LABEL;
SHEET='部分二';
RUN;
/*读取特定的流水*/
/*%read_tablen(&path,新系统客户所有的流水,aaa,aaa);*/
/*data dat.pay;*/
/*set aaa(rename=(_COL0=submit_date _COL1=amount _COL2=cust_name _COL3=per_corp _COL4=comment _COL5=cert_id _COL6=contractno));*/
/*run;*/
