select 
a.app_product_name as product_name,
a.cust_name as real_customer,
a.id_num as cert_id,
b.curr_app_amount as loan_amount,
b.period_value as periods_num,
to_char(a.real_pay_date,'YYYY/MM/DD') as loan_date,
a.contract_no,
c.curr_capital_remain_amount as con_amount,
c.repay_amount as mon_pay,
c.repay_capital_amount as mon_pri,
c.interest_amount as mon_int,
c.repay_amount-c.repay_capital_amount-c.interest_amount as mon_man
from xndb.apply_contract a,xndb.apply_status b,xndb.apply_repay_plan c
where a.apply_id=b.apply_id
and a.apply_id=c.apply_id
and c.period_num='1'
and a.contract_state in('PASS','STPASS','STFAILER')
and a.app_product_name not like '�׸���%';


select contract_amount_, from eam1.eam_account_info;
select * from eam1.eam 


SELECT d.apply_code as ������,
       d.id_num as ���֤��,
       b.final_score as ����,
       decode(b.final_decision,
              'Reject',
              '����ܾ�',
              'Review',
              '�������',
              'Accept',
              '����ͨ��') as ������,
       c.item_name as ���й���,
       decode(c.risk_level, 'low', '��', 'medium', '��', 'high', '��') as ���յȼ�,
       c.group_ as ɨ����
  FROM xndb.td_apply_baseinfo a
  inner join xndb.td_req_detail b
    on a.report_id = b.report_id
  inner join xndb.td_risk_item c
    on b.report_id = c.report_id
 inner join xndb.apply_status d
    on a.id_number = d.id_num  where d.apply_code is not null order by d.entry_date asc;


select b.pid,b.name,b.LOAN_TYPE,decode('reject','�ܾ�','fraud','��թ','overdue','����' ) as ����, b.CONFIRM_DETAILS
from xndb.zzc_black_list b
inner join xndb.zzc_apply_baseinfo a
 on b.pid=a.pid;


select b.pid,b.name,b.LOAN_TYPE,decode('reject','�ܾ�','fraud','��թ','overdue','����' ) as ����, b.CONFIRM_DETAILS
from xnbd.zzc_black_list b





