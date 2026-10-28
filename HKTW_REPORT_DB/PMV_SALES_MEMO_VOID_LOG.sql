CREATE   view [dbo].[PMV_SALES_MEMO_VOID_LOG]
--WITH SCHEMABINDING
AS
select oripsm.COMPANY_CODE, pc.COMPANY_DESC, pst.STORE_TYPE_NAME, pl.LOCATION_DESC, pl.LOCATION_CODE, pl.LOCATION_NAME, oripsm.SALES_MEMO_ID,
    oripsm.CRE_BY ORI_CRE_BY , CONVERT(varchar(10), oripsm.TX_DT, 126) tx_dt, oripsm.TOTAL_NET_AMT,count_big(*) c
from dbo.PT_SALES_MEMO oripsm ,   dbo.PM_LOCATION pl, dbo.PM_STORE_TYPE pst, dbo.PM_COMPANY pc, dbo.PR_POS_REPORT_SUP pprs
where oripsm.MEMO_STATUS  ='VOIDED'  and pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
    and pc.COMPANY_CODE = oripsm.COMPANY_CODE and pl.LOCATION_ID = oripsm.LOCATION_ID_FK and oripsm.TX_DT < pprs.MV_DT
group by oripsm.COMPANY_CODE, pc.COMPANY_DESC, pst.STORE_TYPE_NAME, pl.LOCATION_DESC, pl.LOCATION_CODE, pl.LOCATION_NAME,
    pl.LOCATION_CODE,CONVERT(varchar(10), oripsm.TX_DT, 126), oripsm.CRE_BY ,oripsm.SALES_MEMO_ID,oripsm.TOTAL_NET_AMT
