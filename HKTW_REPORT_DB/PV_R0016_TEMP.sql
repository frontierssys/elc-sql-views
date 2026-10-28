CREATE   view [dbo].[PV_R0016_TEMP] as
select
    psfdv.COMPANY_CODE,
    psfdv.COMPANY_DESC,
    psfdv.STORE_TYPE_CODE,
    psfdv.STORE_TYPE_CODE as STORE_TYPE_NAME,
    psfdv.STORE_LOCATION,
    psfdv.STORE_ID,
    psfdv.STORE_NAME,
    psfdv.SALES_TYPE,
    psfdv.TERMINAL_ID,
    psfdv.SALES_MEMO_ID,
    psfdv.TRANSACTION_ID,
    psfdv.TRANSACTION_DATE,
    psfdv.TRANSACTION_TIME,
    psfdv.EMPLOYEE_ID,
    psfdv.EMPLOYEE_NAME,
    psfdv.COMMISSION_EMPLOYEE_ID,
    psfdv.COMMISSION_EMPLOYEE_NAME,
    psfdv.CONSUMER_ID,
    psfdv.CONSUMER_NAME,
    pv.JOIN_DT as CONSUMER_CREATE_DATE,
    pc.FIRST_PURCHASE_DT as FIRST_PURCHASE_DATE,
    psfdv.CONSUMER_LOCATION,
    null as WALKIN_LOCATION,
    psfdv.CLASS,
    psfdv.MAJOR_CATEGORY,
    psfdv.DEPARTMENT,
    psfdv.APPLICATION,
    psfdv.SUB_DEPARTMENT,
    psfdv.CATEGORY,
    psfdv.DIVISION,
    psfdv.SUB_CATEGORY,
    psfdv.INVENTORY_HIERARCHY,
    psfdv.LOCAL_L1,
    psfdv.LOCAL_L2,
    psfdv.LOCAL_L3,
    psfdv.LOCAL_L4,
    psfdv.LOCAL_L5,
    psfdv.MATERIAL_CODE_10,
    psfdv.MATERIAL_CODE_6,
    psfdv.MATERIAL_CODE_4,
    psfdv.PRODUCT_NAME,
    psfdv.PRODUCT_BRAND,
    psfdv.SALEABLE,
    psfdv.SAMPLE,
    psfdv.GIFT,
    psfdv.GLOBAL_HERO,
    psfdv.SALES_MEMO_ITEM_H_ID,
    psfdv.SUGGESTED_RETAIL_PRICE,
    psfdv.QUANTITY,
    --psfdv.SALES_VALUE,
    psfdv.NET_SALES,
    --CASE WHEN psfdv.SALES_TYPE = 'Void Original' then psfdv.NET_SALES*-1 ELSE psfdv.NET_SALES END as NET_SALES,
    psfdv.SUGGESTED_RETAIL_PRICE * psfdv.QUANTITY as SALES_VALUE,
    psfdv.TOTAL_TRANSACTION_NET_SALES,
    pstbt.TENDERS as TENDERS,
    psfdv.VIRTUAL_SET_ID,
    psfdv.VIRTUAL_SET_DESC,
    psfdv.POST_VOID,
    psdbih.DISCOUNT_AMOUNT as DISCOUNT_AMT,
    psdbih.DISCOUNT_CODE as DISCOUNT_CODE,
    psdbih.DISCOUNT_DESC as DISCOUNT_DESC,
    pslmbt.LOYALTY_POINTS as LOYALTY_POINTS,
    'N' as LOYALTY_REDEM_FLAG
from PMV_SALES_FULL_DETAIL_TEMP psfdv
inner join PMV_SALES_GROSS_BY_TRANSACTION psgbt
    on psfdv.SALES_MEMO_ID = psgbt.SALES_MEMO_ID
inner join PM_VIP pv
    on psfdv.CONSUMER_ID = pv.VIP_NO
    and psfdv.COMPANY_CODE = pv.COMPANY_CODE
inner join PM_CUSTOMER pc
    on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
inner join PV_SALES_TENDER_BY_TRANSACTION pstbt
    on psfdv.SALES_MEMO_ID = pstbt.SALES_MEMO_ID
left join PMV_SALES_DISCOUNT_BY_ITEM_H psdbih
    on psdbih.SALES_MEMO_ITEM_H_ID = psfdv.SALES_MEMO_ITEM_H_ID
left join PMV_SALES_LOYALTY_MOVEMENT_BY_TRANSACTION pslmbt
    on psfdv.COMPANY_CODE = pslmbt.COMPANY_CODE
    and psfdv.TRANSACTION_ID = pslmbt.POS_MEMO_NO
union all
select
    pvgl.COMPANY_CODE ,
    pc.COMPANY_DESC ,
    pst.STORE_TYPE_CODE ,
    pst.STORE_TYPE_CODE  as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    'GIFT '+ pvgl.MOVEMENT_TYPE as SALES_TYPE,
    pvgl.TERMINAL_NO as TERMINAL_ID,
    pvgl.ORDER_NO as SALES_MEMO_ID,
    pvgl.ORDER_NO as TRANSACTION_ID,
    CAST(pvgl.MOVEMENT_DT as date) as TRANSACTION_DATE,
    CAST(pvgl.MOVEMENT_DT as time) as TRANSACTION_TIME,
    pvgl.CRE_BY as EMPLOYEE_ID,
    ps.FIRST_NAME +' ' + ps.LAST_NAME as EMPLOYEE_NAME,
    '' as COMMISSION_EMPLOYEE_ID,
    '' as COMMISSION_EMPLOYEE_NAME,
    pv.VIP_NO as CONSUMER_ID,
    pc2.FIRSTNAME + ' ' + pc2.SURNAME as CUSTOMER_NAME,
    pv.JOIN_DT as CONSUMER_CREATE_DATE,
    pc2.FIRST_PURCHASE_DT as FIRST_PURCHASE_DATE,
    pn.NAME as CONSUMER_LOCATION,
    ' ' as WALKIN_LOCATION,
    psdn.MAJOR_CATEGORY + ' ' + psdn.MAJOR_CATEGORY_DESC as CLASS,
    psdn.MAJOR_CATEGORY + ' ' + psdn.MAJOR_CATEGORY_DESC as MAJOR_CATEGORY,
    psdn.APPLICATION + ' ' + psdn.APPLICATION_DESC as DEPARTMENT,
    psdn.APPLICATION + ' ' + psdn.APPLICATION_DESC as APPLICATION,
    psdn.CATEGORY + ' '+ psdn.CATEGORY_DESC as SUB_DEPARTMENT,
    psdn.CATEGORY + ' '+ psdn.CATEGORY_DESC as CATEGORY,
    psdn.SUB_CATEGORY + ' ' + psdn.SUB_CATEGORY_DESC as DIVISION,
    psdn.SUB_CATEGORY + ' ' + psdn.SUB_CATEGORY_DESC as SUB_CATEGORY,
    psdn.INVENTORY_HIER as INVENTORY_HIERARCHY,
    psdn.LH_L1 as LOCAL_L1,
    psdn.LH_L2 as LOCAL_L2,
    psdn.LH_L3 as LOCAL_L3,
    psdn.LH_L4 as LOCAL_L4,
    psdn.LH_L5 as LOCAL_L5,
    psdn.SKU_10 as MATERIAL_CODE_10,
    psdn.SKU_6 as MATERIAL_CODE_6,
    psdn.SKU_4 as MATERIAL_CODE_4,
    psdn.PRODUCT_NAME as PRODUCT_NAME,
    psdn.PRODUCT_BRAND as PRODUCT_BRAND,
    'N' as SALEABLE,
    'N' as SAMPLE,
    'Y' as GIFT,
    psdn.LH_L5 as GLOBAL_HERO,
    null as SALES_MEMO_ITEM_H_ID,
    0 as SUGGESTED_RETAIL_PRICE,
    pvgl.QTY QUANTITY,
    --psfdw.SALES_VALUE,
    0 as NET_SALES,
    0 as SALES_VALUE,
    0 as TOTAL_TRANSACTION_NET_SALES,
    'Loyalty Points' as TENDERS,
    '' as VIRTUAL_SET_ID,
    '' as VIRTUAL_SET_DESC,
    'N' as POST_VOID,
    0 as DISCOUNT_AMT,
    '' as DISCOUNT_CODE,
    '' as DISCOUNT_DESC,
    pvgl.GIFT_REDEEM_POINT as LOYALTY_POINTS,
    'Y' as LOYALTY_REDEM_FLAG
from PL_VIP_GIFT_LOG pvgl
inner join PM_VIP pv on
    pvgl.VIP_ID_FK = pv.VIP_ID
inner join PM_CUSTOMER pc2
    on pc2.CUSTOMER_ID = pv.CUSTOMER_ID_FK
inner join PM_CUSTOMER_SECRET pcs
    on pcs.CUSTOMER_ID_FK = pc2.CUSTOMER_ID
inner join PM_COMPANY pc
    on pvgl.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl
    on pvgl.LOCATION_CODE = pl.LOCATION_CODE
    and pl.COMPANY_CODE = pvgl.COMPANY_CODE
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
left join PM_STAFF ps
    on pvgl.CRE_BY = ps.STAFF_CODE
    and pvgl.COMPANY_CODE = ps.COMPANY_CODE
left join PV_SKU_DETAIL_NOPRICE psdn
    on pvgl.GIFT_CODE = psdn.SKU_10
    and pvgl.COMPANY_CODE = psdn.COMPANY_CODE
left join dbo.PM_NATION pn
    on pcs.COMPANY_CODE = pn.COMPANY_CODE
    and pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
