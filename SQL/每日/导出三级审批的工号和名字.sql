select x.contract_no,x.user_name as fir,x.user_account as fir_id,
       y.user_name as sec,y.user_account as sec_id,
       z.user_name as thi,z.user_account as thi_id
from 
(select 
     a.CONTRACT_NO,
     a4.user_name,
     a4.user_account
from xndb.pub_users a4,
(select 
      a3.apply_id,
      a2.handl_user_id
from xndb.app_result a2,
(select 
      max(a1.id_) as qiao_a,
      a1.APPLY_ID 
from xndb.app_result a1 
where a1.activity_name='风控初审' 
group by a1.APPLY_ID
order by a1.apply_id) a3
where a3.qiao_a=a2.id_) a5,
xndb.APPLY_CONTRACT a
where a.apply_id=a5.apply_id
and a4.user_id=a5.handl_user_id
and a.CONTRACT_NO^=' ') x
left join 
(select 
     a.CONTRACT_NO,
     a4.user_name,
     a4.user_account
from xndb.pub_users a4,
(select 
      a3.apply_id,
      a2.handl_user_id
from xndb.app_result a2,
(select 
      max(a1.id_) as qiao_a,
      a1.APPLY_ID 
from xndb.app_result a1 
where a1.activity_name='风控审批' 
group by a1.APPLY_ID
order by a1.apply_id) a3
where a3.qiao_a=a2.id_) a5,
xndb.APPLY_CONTRACT a
where a.apply_id=a5.apply_id
and a4.user_id=a5.handl_user_id
and a.CONTRACT_NO^=' ') y
on x.CONTRACT_NO=y.CONTRACT_NO
left join 
(select 
     a.CONTRACT_NO,
     a4.user_name,
     a4.user_account
from xndb.pub_users a4,
(select 
      a3.apply_id,
      a2.handl_user_id
from xndb.app_result a2,
(select 
      max(a1.id_) as qiao_a,
      a1.APPLY_ID 
from xndb.app_result a1 
where a1.activity_name='风控高级审批' 
group by a1.APPLY_ID
order by a1.apply_id) a3
where a3.qiao_a=a2.id_) a5,
xndb.APPLY_CONTRACT a
where a.apply_id=a5.apply_id
and a4.user_id=a5.handl_user_id
and a.CONTRACT_NO^=' ') z
on x.CONTRACT_NO=z.CONTRACT_NO
