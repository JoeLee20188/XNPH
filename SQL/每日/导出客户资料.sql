select 
a.contract_no,
f.region_area_ as region_name,
a.branch_name,
a.manager_city_name as city,
f.sales as cust_mng,
f.updator_ as surveyman,
(select g1.updator_ 
from xndb.apply_check_approve g1 where
id_=(select max(id_) from xndb.apply_check_approve g
where g.apply_id=a.apply_id))as auditman,
a.cust_name,
a.id_num,
case when b.sex='1' then '��' else 'Ů'end as gender,
b.age,    
case when b.web_status='01' then 'δ��' when b.web_status='02' then '�ѻ�' else '����' end as marry,
b.mobile,
b.id_province||b.id_city||b.id_distinct||b.id_details as addr,

(select c1.company_name 
from xndb.APPLY_CUST_COMPANY_INFO c1 where
id_=(select max(id_) from xndb.APPLY_CUST_COMPANY_INFO c
where c.apply_id=a.apply_id))as corp_name,
(select c1.com_province||c1.com_city||c1.com_distinct||c1.com_details 
from xndb.APPLY_CUST_COMPANY_INFO c1 where
id_=(select max(id_) from xndb.APPLY_CUST_COMPANY_INFO c
where c.apply_id=a.apply_id))as corp_addr,             
(select c1.com_phone_ar||c1.com_phone_ex||c1.com_phone_sb 
from xndb.APPLY_CUST_COMPANY_INFO c1 where
id_=(select max(id_) from xndb.APPLY_CUST_COMPANY_INFO c
where c.apply_id=a.apply_id))as corp_phone, 

(select d1.contact_name_wife  
from xndb.APPLY_CUST_SPOUSE_INFO d1 where
id_=(select max(id_) from xndb.APPLY_CUST_SPOUSE_INFO d
where d.apply_id=a.apply_id))as spo_name,
(select d1.mobile_wife  
from xndb.APPLY_CUST_SPOUSE_INFO d1 where
id_=(select max(id_) from xndb.APPLY_CUST_SPOUSE_INFO d
where d.apply_id=a.apply_id))as spo_phone,
(select d1.company_name_wife  
from xndb.APPLY_CUST_SPOUSE_INFO d1 where
id_=(select max(id_) from xndb.APPLY_CUST_SPOUSE_INFO d
where d.apply_id=a.apply_id))as spo_corp,
(select d1.wife_com_province||d1.wife_com_city||d1.wife_com_distinct||d1.wife_com_details 
from xndb.APPLY_CUST_SPOUSE_INFO d1 where
id_=(select max(id_) from xndb.APPLY_CUST_SPOUSE_INFO d
where d.apply_id=a.apply_id))as spo_corp_addr,
(select d1.wife_com_phone_ar||d1.wife_com_phone_ex||d1.wife_com_phone_sb 
from xndb.APPLY_CUST_SPOUSE_INFO d1 where
id_=(select max(id_) from xndb.APPLY_CUST_SPOUSE_INFO d
where d.apply_id=a.apply_id))as spo_corp_pho,
(select d1.post_name_wife  
from xndb.APPLY_CUST_SPOUSE_INFO d1 where
id_=(select max(id_) from xndb.APPLY_CUST_SPOUSE_INFO d
where d.apply_id=a.apply_id))as spo_corp_pos,

(select e1.contact_name 
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select min��id_�� from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_name1,
(select e1.kinship_sub 
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select min��id_�� from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_rel1,
(select e1.con_mobil 
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select min��id_�� from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_pho1,
(select e1.conta_home_province||e1.conta_home_city||e1.conta_home_distinct||e1.conta_home_details
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select min��id_�� from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_addr1,
(select e1.dept_name
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select min��id_�� from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_corp_name1,
(select e1.post_
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select min��id_�� from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_com_pos1,
(select e1.conta_com_phone_ar||e1.conta_com_phoneex||e1.conta_com_phone_sb
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select min��id_�� from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_com_pho1,

(select e1.contact_name 
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id and id_<(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id))) as con_name2,
(select e1.kinship_sub 
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id and id_<(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id))) as con_rel2,
(select e2.con_mobil 
from xndb.APPLY_CUST_CONTACT e2 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id and id_<(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id))) as con_pho2,
(select e1.conta_home_province||e1.conta_home_city||e1.conta_home_distinct||e1.conta_home_details
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id and id_<(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id))) as con_addr2,
(select e1.dept_name
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id and id_<(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id))) as con_corp_name2,
(select e1.post_
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id and id_<(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id))) as con_corp_pos2,
(select e1.conta_com_phone_ar||e1.conta_com_phoneex||e1.conta_com_phone_sb
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id and id_<(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id))) as con_corp_pho2,

(select e1.contact_name 
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_name3,
(select e1.kinship_sub 
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_rel3,
(select e.con_mobil 
from xndb.APPLY_CUST_CONTACT e where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e1
where e1.apply_id=a.apply_id)) as con_pho3,
(select e1.conta_home_province||e1.conta_home_city||e1.conta_home_distinct||e1.conta_home_details
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_addr3,
(select e1.dept_name
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_corp_name3,
(select e1.post_
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_corp_pos3,
(select e1.conta_com_phone_ar||e1.conta_com_phoneex||e1.conta_com_phone_sb
from xndb.APPLY_CUST_CONTACT e1 where 
id_=(select max��id_) from xndb.APPLY_CUST_CONTACT e
where e.apply_id=a.apply_id)) as con_corp_pho3,
f.sales_code,
f.business_unit_source as syb,
case when f.channel_id='DA600D001' then 'ֱ��'
     when f.channel_id='DA600D002' then '������'
     when f.channel_id='DA600D003' then '��������'
     when f.channel_id='DA600D004' then '΢��'
     when f.channel_id='DA600D005' then 'APP'
     when f.channel_id='DA600D006' then '����' end as customer_sources,
f.src_institution as ws_ins,
a.kind_loan,
f.team_manager,
(select 
 case when c1.INDUSTRy='01' then 'ũ���֡�������ҵ' when c1.INDUSTRy='02' then '�ɿ�ҵ' when c1.INDUSTRy='03' then '����ҵ'
      when c1.INDUSTRy='04' then '������ȼ����ˮ�������͹�Ӧҵ' when c1.INDUSTRy='05' then '����ҵ' when c1.INDUSTRy='06' then '����ҵ'
      when c1.INDUSTRy='07' then '����ҵ'  when c1.INDUSTRy='08' then '��ͨ����ҵ'  when c1.INDUSTRy='09' then '�ִ�ҵ'
      when c1.INDUSTRy='10' then '����/���ҵ'  when c1.INDUSTRy='11' then 'ס��ҵ'  when c1.INDUSTRy='12' then '����ҵ'
      when c1.INDUSTRy='13' then '��Ϣ����ҵ'  when c1.INDUSTRy='14' then '�������Ϣ��������ҵ'  when c1.INDUSTRy='15' then '���ز�������Ӫ'
      when c1.INDUSTRy='16' then '��ҵ����'  when c1.INDUSTRy='17' then '���޺��������ҵ'  when c1.INDUSTRy='18' then '����ҵ'
      when c1.INDUSTRy='19' then '����ҵ'  when c1.INDUSTRy='20' then '����ҵ' end 
 from xndb.APPLY_CUST_COMPANY_INFO c1 where
id_=(select max(id_) from xndb.APPLY_CUST_COMPANY_INFO c
where c.apply_id=a.apply_id)) as INDUSTRY,
case when b.education='01' then '��ʿ'
    when b.education='02' then '˶ʿ'
    when b.education='03' then '��ѧ����'
    when b.education='04' then '��ѧר��' 
    when b.education='05' then '���м���ר'
    when b.education='06' then '���м�����' else '��' end  as EDUCATION 
from xndb.APPLY_CONTRACT a
left join xndb.APPLY_CUST_info b
on a.apply_id=b.apply_id
left join xndb.apply_info f
on a.apply_id=f.id_
where a.contract_state='PASS'or a.contract_state='STPASS' or a.contract_state='STFAILER'
