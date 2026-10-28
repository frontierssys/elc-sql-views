create     view [dbo].[PMV_DB_VIP_VISIT_HIGJEST_SPENDING]
--WITH SCHEMABINDING
as
SELECT
    pv.COMPANY_CODE ,
    pv.VIP_CLUSTER_ID_FK ,
    pv.VIP_NO,
    sum(psm.TOTAL_NET_AMT) / count(psm.COMPANY_CODE ) as AVERAGE_SPENDING,
    Max(psm.TOTAL_NET_AMT ) as HIGHEST_SPEND,
    Max(psm.MEMO_NO ) as MEMO_NO
from dbo.PM_VIP pv
inner join dbo.PT_SALES_MEMO psm
    on psm.COMPANY_CODE = pv.COMPANY_CODE
    and psm.VIP_NO = pv.VIP_NO
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.VIP_NO is not NULL
group by
    pv.COMPANY_CODE ,
    pv.VIP_CLUSTER_ID_FK,
    pv.VIP_NO
