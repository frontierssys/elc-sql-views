CREATE   VIEW  PV_STORE_SALES_AND_BP_ISSUED_BAK
--WITH SCHEMABINDING
AS
select psm.COMPANY_CODE, pl.LOCATION_NAME, pl.LOCATION_DESC,  pl.LOCATION_CODE, pst.STORE_TYPE_NAME, CONVERT(varchar(10), psm.TX_DT, 126) as TX_DT, sum(psm.TOTAL_NET_AMT) totalSales , sum(bpm.POINT_MOVEMENT) totalPoints, count_big(*) c
from dbo.PL_VIP_BP_MOVEMENT bpm, dbo.PR_POS_REPORT_SUP pprs, dbo.PT_SALES_MEMO psm, dbo.PM_LOCATION pl, dbo.PM_STORE_TYPE pst
where bpm.ORDER_TYPE in ('SALES')  and bpm.ORDER_NO = psm.MEMO_NO
    and psm.TX_DT >  pprs.MV_DT and pl.LOCATION_ID = psm.LOCATION_ID_FK and pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
group by psm.COMPANY_CODE, pl.LOCATION_NAME, pl.LOCATION_DESC,  pl.LOCATION_CODE, pst.STORE_TYPE_NAME,CONVERT(varchar(10), psm.TX_DT, 126)
union
select company_code, location_name, location_desc, location_code, store_type_name, tx_dt, totalSales, totalPoints, c
from dbo.PMV_STORE_SALES_AND_BP_ISSUED
