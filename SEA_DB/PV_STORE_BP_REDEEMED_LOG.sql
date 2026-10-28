-- CREATE   view [dbo].[PV_SKU_WITH_BUCKET] as
-- select
-- ps.COMPANY_CODE as COMPANY_CODE ,
-- ps.SKU_ID as SKU_ID ,
-- ps.SKU_CODE as SKU_10,
-- LEFT(ps.SKU_CODE,9) as SKU_9,
-- LEFT(ps.SKU_CODE, 6) as SKU_6,
-- pi2.ITEM_CODE as SKU_4,
-- isnull(ps.SKU_DESC , pi2.ITEM_DESC_1) as PRODUCT_NAME,
-- --ptip.CUR_RETAIL_PRICE as RETAIL_PRICE,
-- bk.BUCKET_TYPE
-- from PM_SKU ps
-- inner join PM_SKU_ATTR psa
-- on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
-- inner join PM_ITEM pi2
-- on ps.ITEM_ID_FK = pi2.ITEM_ID
-- --inner join PV_TODAY_ITEM_PRICE ptip
-- --on ps.SKU_ID = ptip.SKU_ID_FK
-- CROSS join (select DISTINCT DISPLAY_VALUE as BUCKET_TYPE from PC_INVENTORY_LOV where lov_code = 'BalanceType') bk;
CREATE   VIEW dbo.PV_STORE_BP_REDEEMED_LOG AS
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
