select distinct a.REGION_CITYY_ as city,count(a.APPLY_ID) as num from XNDB.APPLY_INFO a where a.STATUS='SUBMIT' GROUP BY a.REGION_CITYY_
