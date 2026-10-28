CREATE   VIEW  PMV_VIP_YTD_SPENDING
as
SELECT pv.VIP_ID , sum(psm.TOTAL_NET_AMT) as LIFETIME_SPEND, COUNT(psm.MEMO_NO ) as LIFETIME_TX_COUNT
from PM_VIP pv
inner join PT_SALES_MEMO psm
    on psm.VIP_NO = pv.VIP_NO
    and psm.COMPANY_CODE= pv.COMPANY_CODE
inner join PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join PR_POS_REPORT_SUP pprs
    on 1 = 1
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.VIP_NO is not NULL
    and psm.TX_DT >= pprs.CURRENT_FY_START_DT
group by pv.VIP_ID
