CREATE    view PV_R0001_STAFF_PRODUCT_OVERVIEW as
select
    0 as MTD_RETAIL_NET_SALES,
    psssdvv.CUSTOMER_TYPE ,
    psssdvv.COMPANY_CODE ,  --DIVISION
    pc.COMPANY_DESC ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    pl.LOCATION_NAME ,
    pl.CITY_TXT as ADDRESS,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    psssdvv.TX_DATE ,
    psssdvv.STAFF_NO as EMPLOYEE_ID,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as EMPLOYEE_NAME,
    psd.SKU_10 as SKU,
    psd.PRODUCT_NAME ,
    psd.RETAIL_PRICE as SUGGESTED_RETAIL_PRICE,
    psd.PRODUCT_BRAND as SUB_BRAND,
    psd.MAJOR_CATEGORY + ' ' + psd.MAJOR_CATEGORY_DESC as CLASS,
    psd.MAJOR_CATEGORY_DESC as CLASS_DESC,
    psd.APPLICATION + ' ' + psd.APPLICATION_DESC as DEPARTMENT,
    psd.APPLICATION_DESC as DEPARTMENT_DESC,
    psd.CATEGORY +' ' + psd.CATEGORY_DESC as SUB_DEPARTMENT,
    psd.CATEGORY_DESC as SUB_DEPARTMENT_DESC,
    psd.SUB_CATEGORY + ' ' + psd.SUB_CATEGORY_DESC as DIVISION,
    psd.SUB_CATEGORY_DESC as DIVISION_DESC,
    psd.INVENTORY_HIER ,
    psd.LH_L1 as L1,
    psd.LH_L2 as L2,
    psd.LH_L3 as L3,
    psd.LH_L4 as L4,
    psd.LH_L5 as L5,
    pstd.TARGET_AMOUNT as TARGET_AMOUNT,
    psssdvv.IS_REVENUE_ITEM ,
    psssdvv.SALE_OR_RETURN ,
    psssdvv.DEMOGRAPHIC ,
    case
        when psssdvv.SALE_OR_RETURN = 'RETURN' then 0
        else psssdvv.SALES_GROSS_AMT
    end as SALES_GROSS_AMT,
    psssdvv.SALES_NET_AMT ,
    psssdvv.QTY ,
    psssdvv.TX_COUNT as MEMO_COUNT,
    psssdvv.ITEM_COUNT as TX_QTY,
    psssdvv.SALES_NET_AMT - psssdvv.SALES_GROSS_AMT as DISCOUNT
from
    PMV_SALES_STORE_STAFF_SKU_DEMOGRAPHIC_VIP_V2 psssdvv
inner join PM_COMPANY pc on
    psssdvv.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl on
    psssdvv.COMPANY_CODE = pl.COMPANY_CODE
    and psssdvv.location_code = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_STAFF ps on
    ps.COMPANY_CODE = psssdvv.COMPANY_CODE
    and ps.STAFF_CODE = psssdvv.STAFF_NO
inner join PV_SKU_DETAIL psd
    on psssdvv.COMPANY_CODE = psd.COMPANY_CODE
    and psssdvv.SKU = psd.SKU_10
left join PV_SALES_TARGET_DAILY_STAFF pstd
    on pstd.COMPANY_CODE = psssdvv.COMPANY_CODE
    and pstd.LOCATION_CODE = psssdvv.location_code
    and psssdvv.TX_DATE = pstd.TX_DATE
    and psssdvv.STAFF_NO = pstd.STAFF_NO
union all
select
    0 as MTD_RETAIL_NET_SALES,
    psssdvv.CUSTOMER_TYPE ,
    psssdvv.COMPANY_CODE ,  --DIVISION
    pc.COMPANY_DESC ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    pl.LOCATION_NAME ,
    pl.CITY_TXT as ADDRESS,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    psssdvv.TX_DATE ,
    psssdvv.STAFF_NO as EMPLOYEE_ID,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as EMPLOYEE_NAME,
    psd.SKU_10 as SKU,
    psd.PRODUCT_NAME ,
    psd.RETAIL_PRICE as SUGGESTED_RETAIL_PRICE,
    psd.PRODUCT_BRAND as SUB_BRAND,
    psd.MAJOR_CATEGORY + ' ' + psd.MAJOR_CATEGORY_DESC as CLASS,
    psd.MAJOR_CATEGORY_DESC as CLASS_DESC,
    psd.APPLICATION + ' ' + psd.APPLICATION_DESC as DEPARTMENT,
    psd.APPLICATION_DESC as DEPARTMENT_DESC,
    psd.CATEGORY +' ' + psd.CATEGORY_DESC as SUB_DEPARTMENT,
    psd.CATEGORY_DESC as SUB_DEPARTMENT_DESC,
    psd.SUB_CATEGORY + ' ' + psd.SUB_CATEGORY_DESC as DIVISION,
    psd.SUB_CATEGORY_DESC as DIVISION_DESC,
    psd.INVENTORY_HIER ,
    psd.LH_L1 as L1,
    psd.LH_L2 as L2,
    psd.LH_L3 as L3,
    psd.LH_L4 as L4,
    psd.LH_L5 as L5,
    pstd.TARGET_AMOUNT as TARGET_AMOUNT,
    psssdvv.IS_REVENUE_ITEM ,
    psssdvv.SALE_OR_RETURN ,
    psssdvv.DEMOGRAPHIC ,
    case
        when psssdvv.SALE_OR_RETURN = 'RETURN' then 0
        else psssdvv.SALES_GROSS_AMT
    end as SALES_GROSS_AMT,
    psssdvv.SALES_NET_AMT ,
    psssdvv.QTY ,
    psssdvv.TX_COUNT as MEMO_COUNT,
    psssdvv.ITEM_COUNT as TX_QTY,
    psssdvv.SALES_NET_AMT - psssdvv.SALES_GROSS_AMT as DISCOUNT
from
    PMV_SALES_STORE_STAFF_SKU_DEMOGRAPHIC_WALKIN_V2 psssdvv
inner join PM_COMPANY pc on
    psssdvv.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl on
    psssdvv.COMPANY_CODE = pl.COMPANY_CODE
    and psssdvv.location_code = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_STAFF ps on
    ps.COMPANY_CODE = psssdvv.COMPANY_CODE
    and ps.STAFF_CODE = psssdvv.STAFF_NO
inner join PV_SKU_DETAIL psd
    on psssdvv.COMPANY_CODE = psd.COMPANY_CODE
    and psssdvv.SKU = psd.SKU_10
left join PV_SALES_TARGET_DAILY_STAFF pstd
    on pstd.COMPANY_CODE = psssdvv.COMPANY_CODE
    and pstd.LOCATION_CODE = psssdvv.location_code
    and psssdvv.TX_DATE = pstd.TX_DATE
    and psssdvv.STAFF_NO = pstd.STAFF_NO;
