%let path=E:\basic_data;/*基础数据路径*/
%let today="31May2016"d;
%let mytoday=20160531;
%let yqday=&today.-30;
libname dat "E:\data";
data info;
set dat.quanbu_cust&mytoday.;
drop d1	a1	d2	a2	d3	a3	d4	a4	d5	a5	d6	a6	d7	a7	d8	a8	d9	a9	d10	a10	d11	a11	d12	a12	d13	a13	d14	a14	d15	a15	d16	a16	d17	a17	d18	a18	d19	a19	d20	a20	d21	a21	
     COL22	COL23	COL24	COL25	COL26	COL27	COL28	COL29	COL30	COL31	COL32	COL33	COL34	COL35 COL36
     wik	mon_pri	mon_int	mon_man	 MOBILE	ADDR	CORP_NAME	CORP_ADDR	CORP_PHONE	SPO_NAME	SPO_PHONE	SPO_CORP	SPO_CORP_ADDR	SPO_CORP_PHO	
    SPO_CORP_POS	CON_NAME1	CON_REL1	CON_PHO1	CON_ADDR1	CON_CORP_NAME1	CON_COM_POS1	CON_COM_PHO1	CON_NAME2	CON_REL2	CON_PHO2	CON_ADDR2	CON_CORP_NAME2	CON_CORP_POS2	
    CON_CORP_PHO2	CON_NAME3	CON_REL3	CON_PHO3	CON_ADDR3	CON_CORP_NAME3	CON_CORP_POS3	CON_CORP_PHO3;
run;
PROC EXPORT DATA=info OUTFILE="E:\source_data\审批管理部数据源_&mytoday..xlsx" DBMS=EXCEL REPLACE LABEL;
RUN;
