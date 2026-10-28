CREATE   view [dbo].[PV_SALES_MEMO_VOID_LOG]
--WITH SCHEMABINDING
AS
select oripsm.COMPANY_CODE, pc.COMPANY_DESC, pst.STORE_TYPE_NAME, pl.LOCATION_DESC, pl.LOCATION_CODE,
    pl.LOCATION_NAME,  voidpsm.CRE_BY VOID_CRE_BY, voidpsm.AUTH_BY, oripsm.CRE_BY ORI_CRE_BY,
    voidpsm.VOID_REASON , CONVERT(varchar(10), oripsm.TX_DT, 126) tx_dt, count_big(*) c ,
    count_BIG (voidpsm.VOID_REASON) COUNT_VOID_REASON
from dbo.PT_SALES_MEMO oripsm ,   dbo.PT_SALES_MEMO voidpsm,  dbo.PM_LOCATION pl, dbo.PM_STORE_TYPE pst, dbo.PM_COMPANY pc, dbo.PR_POS_REPORT_SUP pprs
where oripsm.MEMO_STATUS  ='VOIDED'  and pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID and oripsm.SALES_MEMO_ID = voidpsm.ORI_SALES_MEMO_ID_PK
    and pc.COMPANY_CODE = oripsm.COMPANY_CODE and pl.LOCATION_ID = oripsm.LOCATION_ID_FK and oripsm.TX_DT > pprs.MV_DT
group by oripsm.COMPANY_CODE, pc.COMPANY_DESC, pst.STORE_TYPE_NAME, pl.LOCATION_DESC, pl.LOCATION_CODE, pl.LOCATION_NAME,
    pl.LOCATION_CODE,CONVERT(varchar(10), oripsm.TX_DT, 126), oripsm.CRE_BY , voidpsm.VOID_REASON, voidpsm.CRE_BY, voidpsm.AUTH_BY
union
select oripsm.COMPANY_CODE, oripsm.COMPANY_DESC, oripsm.STORE_TYPE_NAME, oripsm.LOCATION_DESC, oripsm.LOCATION_CODE,
    oripsm.LOCATION_NAME,  voidpsm.CRE_BY VOID_CRE_BY, voidpsm.AUTH_BY, oripsm.ORI_CRE_BY  ,
    voidpsm.VOID_REASON ,  oripsm.TX_DT, oripsm.c ,
    count_BIG (voidpsm.VOID_REASON) COUNT_VOID_REASON
from dbo.PMV_SALES_MEMO_VOID_LOG oripsm, dbo.PT_SALES_MEMO voidpsm
where oripsm.SALES_MEMO_ID = voidpsm.ORI_SALES_MEMO_ID_PK
GROUP by  oripsm.COMPANY_CODE, oripsm.COMPANY_DESC, oripsm.STORE_TYPE_NAME, oripsm.LOCATION_DESC, oripsm.LOCATION_CODE,
    oripsm.LOCATION_NAME,  voidpsm.CRE_BY  , voidpsm.AUTH_BY, oripsm.ORI_CRE_BY  ,
    voidpsm.VOID_REASON,   oripsm.ORI_CRE_BY  ,  oripsm.TX_DT, oripsm.c
