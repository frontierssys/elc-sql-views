CREATE   VIEW  PV_STORE_BP_REDEEMED_LOG_BAK
--WITH SCHEMABINDING
AS
select pvl.COMPANY_CODE, pc.COMPANY_DESC,  pl.LOCATION_NAME, pl.LOCATION_DESC,  pl.LOCATION_CODE, pst.STORE_TYPE_NAME, CONVERT(varchar(10), pvl.MOVEMENT_DT, 126) as TX_DT, sum(bpm.POINT_MOVEMENT) totalPoints, count_big(*) c
from dbo.PL_VIP_BP_MOVEMENT bpm, dbo.PR_POS_REPORT_SUP pprs, dbo.PL_VIP_GIFT_LOG pvl, dbo.PM_LOCATION pl, dbo.PM_STORE_TYPE pst, dbo.PM_COMPANY pc
where bpm.ORDER_TYPE = 'REDEEM' and bpm.ORDER_NO = pvl.ORDER_NO and pc.COMPANY_CODE = pvl.COMPANY_CODE
    and pvl.MOVEMENT_DT > pprs.MV_DT and pl.LOCATION_CODE = pvl.LOCATION_CODE and pvl.COMPANY_CODE = pl.COMPANY_CODE
    and pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
group by pvl.COMPANY_CODE, pc.COMPANY_DESC, pl.LOCATION_NAME, pl.LOCATION_DESC,  pl.LOCATION_CODE, pst.STORE_TYPE_NAME,CONVERT(varchar(10), pvl.MOVEMENT_DT, 126)
union
select company_code, COMPANY_DESC, location_name, location_desc, location_code, store_type_name, tx_dt, totalPoints, c
from dbo.PMV_STORE_BP_REDEEMED_LOG
