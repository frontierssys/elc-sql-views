CREATE   VIEW [dbo].[PV_STORE_BP_REDEEMED_LOG] AS
Select a.company_code,a.COMPANY_DESC,a.LOCATION_NAME,a.LOCATION_DESC,a.location_code,a.STORE_TYPE_NAME ,a.STORE_LOCATION, CONVERT(varchar(10), a.TX_DATE, 126) as TX_DT,
    SUM(LOYALTY_POINTS_REDEEMED) as totalPoints
from (
    SELECT
        pvbm.COMPANY_CODE ,
        pc.COMPANY_DESC,
        pl.LOCATION_NAME ,
        pl.LOCATION_DESC,
        pvbm.LOCATION_CODE ,
        pst.STORE_TYPE_NAME  as STORE_TYPE_NAME,
        pl.CITY_TXT as STORE_LOCATION,
        CAST(pvbm.CRE_DATET as date) as TX_DATE,
        pvbm.ORDER_NO ,
        SUM(pvbm.GIFT_REDEEM_POINT) as LOYALTY_POINTS_REDEEMED
    from PL_VIP_GIFT_LOG pvbm
    inner join PM_LOCATION pl
        on pvbm.COMPANY_CODE = pl.COMPANY_CODE
        and pvbm.LOCATION_CODE = pl.LOCATION_CODE
    inner join PM_STORE_TYPE pst
        on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
    inner join PM_COMPANY pc ON pc.COMPANY_CODE =pvbm.COMPANY_CODE
    --where pvbm.location_code like 'HKOR%' --and pvgl.ORDER_NO ='HKOR00210120210401191538'
    --and pvbm.CRE_DATET<='2021-04-30 23:59:56' and pvbm.CRE_DATET>='2021-04-01 00:00:00'
    GROUP BY
        pvbm.COMPANY_CODE ,
        pc.COMPANY_DESC,
        pl.LOCATION_NAME ,
        pl.LOCATION_DESC,
        pvbm.LOCATION_CODE ,
        pst.STORE_TYPE_NAME ,
        pl.CITY_TXT ,
        pvbm.ORDER_NO ,
        CAST(pvbm.CRE_DATET as date)
) a
group by a.company_code,a.COMPANY_DESC, a.LOCATION_NAME,a.LOCATION_DESC,a.location_code,a.STORE_TYPE_NAME ,a.STORE_LOCATION, CONVERT(varchar(10), a.TX_DATE, 126)
