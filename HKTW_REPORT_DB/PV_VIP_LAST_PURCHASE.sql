CREATE   view PV_VIP_LAST_PURCHASE as
select *
from (
    select pv.VIP_ID , psm.MEMO_NO , psm.TOTAL_NET_AMT , psm.TX_DATE , ROW_NUMBER() over(
        PARTITION by pv.VIP_ID
        order by psm.TX_DT desc) rn
    from PM_VIP pv
    left join PT_SALES_MEMO psm
        on psm.COMPANY_CODE = pv.COMPANY_CODE
        and psm.VIP_NO = pv.VIP_NO
    left join PM_SALES_MEMO_TYPE psmt
        on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    where psmt.TYPE_CODE in ( '01', '02', '03', '04')
        AND psm.MEMO_STATUS NOT IN ('VOIDED')
        AND psm.MEMO_KIND NOT IN ('RESERVE',
            'handoff')
        and psm.TOTAL_NET_AMT > 0
) a
where a.rn = 1
