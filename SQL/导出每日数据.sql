select b.apply_date,count(b.apply_id) as apply_num from 
(select a.APPLY_ID,to_char(MIN(a.HANDL_TIME),'YYYY/MM/DD') as apply_date from xndb.app_result a where a.ACTIVITY_ID='utask_apply_review' group by a.APPLY_ID) b
group by b.apply_date order by apply_date; --每日申请数
select b.pass_date,count(b.apply_id) as pass_num from 
(select a.APPLY_ID,to_char(max(a.HANDL_TIME),'YYYY/MM/DD') as pass_date from xndb.app_result a where (a.ACTIVITY_ID='utask_check2' and a.result='PASS' and a.handl_time is not null) or (a.ACTIVITY_ID='utask_check3' and a.result='PASS' and a.handl_time is not null)  group by a.APPLY_ID) b
group by b.pass_date order by pass_date; --每日通过数
select b.pass_date,count(b.apply_id) as pass_num from 
(select a.APPLY_ID,to_char(max(a.HANDL_TIME),'YYYY/MM/DD') as pass_date from xndb.app_result a where (a.ACTIVITY_ID='utask_check2' and a.result='REFUSE' and a.handl_time is not null) or (a.ACTIVITY_ID='utask_check3' and a.result='REFUSE' and a.handl_time is not null)  group by a.APPLY_ID) b
group by b.pass_date order by pass_date; --每日拒绝数
select b.sign_date,count(b.apply_id) as apply_num from 
(select a.APPLY_ID,to_char(a.SIGN_DATE,'YYYY/MM/DD') as sign_date from xndb.apply_contract a where to_char(a.SIGN_DATE,'YYYY/MM/DD')='2016/06/22' ) b
group by b.sign_date order by sign_date; --每日签约数
select count(b.apply_id) as apply_num from 
(select a.APPLY_ID from XNDB.APPLY_STATUS a where a.STATUS='PRINT_CONTRACT') b; --未签约数
select b.apply_date,count(b.apply_id) as apply_num from 
(select a.APPLY_ID,to_char(MAX(a.HANDL_TIME),'YYYY/MM/DD') as apply_date from xndb.app_result a where a.ACTIVITY_NAME='风控初审' group by a.APPLY_ID) b
group by b.apply_date order by apply_date; --每日初审数
select b.apply_date,count(b.apply_id) as apply_num from 
(select a.APPLY_ID,to_char(MAX(a.HANDL_TIME),'YYYY/MM/DD') as apply_date from xndb.app_result a where a.ACTIVITY_ID='utask_check2' or a.ACTIVITY_ID='utask_check3' group by a.APPLY_ID) b
group by b.apply_date order by apply_date; --每日审批数
select b.apply_date,count(b.apply_id) as apply_num from 
(select a.APPLY_ID,to_char(MAX(a.BEGIN_DATE),'YYYY/MM/DD') as apply_date from xndb.app_result a where a.ACTIVITY_NAME='财务经办' group by a.APPLY_ID) b
group by b.apply_date order by apply_date; --每日签约数
select * from 
(select b.loan_date,count(b.contract_no) as loan_num,round(sum(b.CONTRACT_AMOUNT)/10000,0) as loan_money from 
(select a.contract_no,to_char(a.real_pay_date,'YYYY/MM/DD') as loan_date,a.CONTRACT_AMOUNT from xndb.apply_contract a where a.contract_state in('PASS','STPASS','STFAILER')) b
group by b.loan_date 
order by loan_date desc) 
where rownum<=7
order by loan_date; --每日放款数
select * from 
(select b.loan_date,count(b.contract_no) as loan_num,round(sum(b.CONTRACT_AMOUNT)/10000,0) as loan_money from 
(select a.contract_no,to_char(a.real_pay_date,'YYYY/MM/DD') as loan_date,a.CONTRACT_AMOUNT from xndb.apply_contract a where a.contract_state in('PASS','STPASS','STFAILER')) b
group by b.loan_date 
order by loan_date desc) 
where loan_date=to_char((select sysdate from dual),'YYYY/MM/DD'); --今天放款数





b.apply_code,
select * from 
(select distinct a.apply_id from xndb.app_result a where a.result='END') a
left join XNDB.APPLY_STATUS b on a.apply_id=b.apply_id where b.STATUS='END';





select distinct a.ACTIVITY_id,a.ACTIVITY_NAME from xndb.app_result a where a.apply_id='46154594'; 

select a.* from xndb.app_result a where a.apply_id='46413674'; --查询流程

select a.* from xndb.apply_status a where a.apply_id='46413674';--查询状态

select a.SIGN_DATE from XNDB.APPLY_CONTRACT a where a.apply_id='46040102';--查询合同

select a.apply_id from XNDB.APPLY_CONTRACT a where contract_no='0010106030209447-01' 


select distinct a.status from xndb.apply_status a
select apply_id,count(apply_id) as num from XNDB.APPLY_CONTRACT group by apply_id ;


select a.APPLY_ID from XNDB.APPLY_CONTRACT a where a.ID_NUM='430426197812238290'; 
select * from XNDB.APPLY_CONTRACT a where a.SIGN_DATE is not null and to_char(a.SIGN_DATE,'YYYY/MM/DD')='2016/07/08';


select sysdate from dual;  --截取当天的日期
select TRUNC(SYSDATE, 'MM')from dual; --截取当月的日期
select sysdate - interval '30' day from dual;--截取30天前的日期



select a.apply_id,b.month_income_bank,month_income_cash,month_income_total from 
(select max(id_) as id,apply_id from xndb.apply_cust_company_info group by apply_id ) a
left join xndb.apply_cust_company_info b
on a.id=b.id_

select b.apply_code,
        c.id_,
        a.apply_id,
        a.cust_name,
        a.id_num,
        b.product_name,
        a.age,
        c.policy_staffappprem,--缴费金额
        c.policy_pay_type,--方式
        c.policy_ins_period,--年限
        c.applycustinfo_id
from xndb.apply_cust_policy_info c
left join xndb.apply_cust_info a     
on c.apply_id=a.apply_id
left join xndb.apply_info b
on c.apply_id=b.apply_id
where c.applycustinfo_id is not null
and b.product_name='保单贷'


select c.business_unit_source as depart,
       c.region_area_ as region,
       c.region_cityy_ as city,
       c.branch_name as branch,
       c.sales_code as sales,
       c.product_name as product,
       b.apply_id,
       b.apply_date from 
(select a.APPLY_ID,to_char(MIN(a.HANDL_TIME),'YYYY/MM/DD') as apply_date from xndb.app_result a where a.ACTIVITY_ID='utask_apply_review' and a.HANDL_TIME is not null group by a.APPLY_ID) b
left join xndb.apply_info c on b.apply_id=c.apply_id --申请明细



group by b.apply_date order by apply_date; --每日申请数

select a.APPLY_ID,to_char(MIN(a.HANDL_TIME),'YYYY/MM/DD') as apply_date from xndb.app_result a where a.ACTIVITY_ID='utask_apply_review' group by a.APPLY_ID
select* from xndb.apply_info;











select d.product_sec,sum(d.product_money) as product_sec_money from (select c.product,decode(c.product,'APP工薪贷','APP工薪贷','按揭贷','按揭贷','保单贷','保单贷','小牛车主贷','车主贷','车主贷','车主贷','精英贷','精英贷','小牛精英贷','精英贷','专业贷','精英贷','农经贷','农经贷','小牛工薪贷（快递）','快递贷','助学贷','助学贷','工薪贷','工薪贷','消费贷','工薪贷','小牛工薪贷','工薪贷','工薪贷（业主）','工薪贷（业主）','惠农贷','惠农贷','惠商贷','生意贷','生意贷','生意贷','网商贷','生意贷','小牛生意贷','生意贷','生意贷（业主）','生意贷（业主）','小牛业主贷','业主贷','小牛业主贷（简易）','业主贷','小牛业主贷（优质）','业主贷','业主贷','业主贷','员工贷','员工贷','农商贷','农商贷') as product_sec,decode(c.product,'APP工薪贷','APP','按揭贷','专案','保单贷','专案','小牛车主贷','专案','车主贷','专案','精英贷','专案','小牛精英贷','专案','专业贷','专案','农经贷','专案','小牛工薪贷（快递）','专案','助学贷','专案','工薪贷','常规','消费贷','常规','小牛工薪贷','常规','工薪贷（业主）','常规','惠农贷','常规','惠商贷','常规','生意贷','常规','网商贷','常规','小牛生意贷','常规','生意贷（业主）','常规','小牛业主贷','常规','小牛业主贷（简易）','常规','小牛业主贷（优质）','常规','业主贷','常规','员工贷','常规','农商贷','农商贷') as product_thi,c.product_money from (select a.APP_PRODUCT_NAME as product,round(sum(b.curr_capital_remain_amount)/10000,0) as product_money from xndb.apply_contract a left join xndb.apply_repay_plan b on a.apply_id=b.apply_id where a.contract_state in('PASS','STPASS','STFAILER') and b.period_num='1' and a.APP_PRODUCT_NAME^='首付贷（先息后本）吉莱宝' and 
to_char(a.real_pay_date,'YYYY/MM/DD')>=to_char((select TRUNC(SYSDATE,'MM')from dual),'YYYY/MM/DD')group by a.APP_PRODUCT_NAME) c) d group by d.product_sec

select a.MANAGER_CITY_NAME as city,round(sum(b.curr_capital_remain_amount)/10000,0) as city_money from xndb.apply_contract a left join xndb.apply_repay_plan b on a.apply_id=b.apply_id where a.contract_state in('PASS','STPASS','STFAILER') and b.period_num='1' and to_char(a.real_pay_date,'YYYY/MM/DD')=to_char((select sysdate from dual),'YYYY/MM/DD') group by a.MANAGER_CITY_NAME
