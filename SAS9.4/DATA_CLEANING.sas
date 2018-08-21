%let path=E:\basic_data;/*基础数据路径*/
%let today="26Aug2016"d;
%let mytoday=20160826;
%let yqday=&today.-30;
libname dat "E:\data";
data yuan;
set dat.quanbu_cust&mytoday.;
run;
data target;
set yuan;
keep dapart; 
run;

