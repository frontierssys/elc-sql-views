CREATE   view PV_VIP_SALES_SUMMARY_WITHIN365DAYS as
select pv.VIP_ID , count(psm.MEMO_NO ) TX_COUNT, sum(psm.TOTAL_NET_AMT ) TOTAL_SPENT
from PM_VIP pv
left join PT_SALES_MEMO psm
    on psm.COMPANY_CODE = pv.COMPANY_CODE
    and psm.VIP_NO = pv.VIP_NO
left join PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
left join PM_LOCATION pl
    on pl.LOCATION_ID = psm.LOCATION_ID_FK
left join PM_STORE_TYPE pst
    on pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
where psmt.TYPE_CODE in ( '01', '02')
    AND psm.MEMO_STATUS NOT IN ('VOIDED')
    AND psm.MEMO_KIND NOT IN ('RESERVE',
        'handoff')
    and psm.TX_DATE >= DATEADD(day, -365, GETDATE())
    AND pst.STORE_TYPE_NAME <> 'ONLINE'
    and psm.TOTAL_NET_AMT <> 0
group by pv.VIP_ID
