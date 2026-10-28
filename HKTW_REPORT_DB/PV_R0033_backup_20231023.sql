CREATE    view [dbo].[PV_R0033_backup_20231023] as
select
    pc.COMPANY_CODE as COMPANY_CODE ,
    pc.COMPANY_DESC as COMPANY_NAME,
    pst.STORE_TYPE_CODE as STORE_TYPE,
    --CONCAT( pl.ADDRESS1, ' ', pl.ADDRESS2 , ' ', pl.ADDRESS3 ) as STORE_LOCATION,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_ID as LOCATION_ID,
    pl.LOCATION_CODE as STORE_NUMBER,
    pl.LOCATION_DESC as STORE_NAME,
    cast(pvbm.CRE_DATET as date) as TRANSACTION_DATE,
    cast(pvbm.CRE_DATET as time) as TRANSACTION_TIME,
    pvbm.ORDER_NO as TRANSACTION_NUMBER,
    pu.USER_CODE as EMPLOYEE_ID,
    CONCAT( ps.FIRST_NAME , ' ', LEFT (ps.LAST_NAME,1) ) as EMPLOYEE_NAME,
    null as COMMISSIONED_ASSOCIATE_ID ,
    null as COMMISSIONED_ASSOCIATE_NAME,
    pv.VIP_NO as CONSUMER_ID,
    concat(pc2.FIRSTNAME , ' ' , PC2.SURNAME ) as CONSUMER_NAME,
    pn.NAME as CONSUMER_LOCATION,
    pn.DEMOGRAPHIC as WALKIN_LOCATION,
    pv.APPLY_DATE as CREATION_DATE,
    pvbm.MOVEMENT_TYPE as REDEMPTION_TYPE,
    null as TRANSACTION_VALUE,
    pvbm.GIFT_CODE as PRODUCT_SKU,
    --pi2.ITEM_DESC_1 as PRODUCT_DESCRIPTION,
    isnull(ps2.SKU_DESC, pi2.ITEM_DESC_1 ) as PRODUCT_DESCRIPTION,
    pvbm.QTY as REDEEMED_QTY,
    pvbm.GIFT_REDEEM_POINT * -1 as POINTS_DEDUCTED,
    pvpb.POINTS as POINT_BALANCE
from PL_VIP_GIFT_LOG pvbm
inner join PM_COMPANY pc
    on pvbm.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl
    on pvbm.COMPANY_CODE = pl.COMPANY_CODE
    and pvbm.LOCATION_CODE = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_VIP pv
    on pvbm.VIP_ID_FK = pv.VIP_ID
inner join PM_CUSTOMER pc2
    on pv.CUSTOMER_ID_FK = pc2.CUSTOMER_ID
inner join PM_CUSTOMER_SECRET pcs
    on pcs.CUSTOMER_ID_FK = pc2.CUSTOMER_ID
left join PM_NATION pn
    on pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
    and pcs.COMPANY_CODE = pn.COMPANY_CODE
left join PM_SKU ps2
    on pvbm.GIFT_CODE = ps2.SKU_CODE
    and pvbm.COMPANY_CODE = ps2.COMPANY_CODE
left join PM_ITEM pi2
    on ps2.ITEM_ID_FK = pi2.ITEM_ID
left join PV_VIP_POINTS_BALANCE pvpb
    on pvbm.VIP_ID_FK = pvpb.VIP_ID
left join PM_USER pu
    on pvbm.CRE_BY = pu.USER_CODE
    and pvbm.COMPANY_CODE = pu.COMPANY_CODE
left join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID;
