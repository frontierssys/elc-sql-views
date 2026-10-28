CREATE   VIEW [dbo].[PV_R0005] as
select
--	a.CUSTOMER_TYPE ,
    a.COMPANY_CODE ,
    pc.COMPANY_DESC ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    pl.LOCATION_NAME ,
    pl.CITY_TXT as ADDRESS,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    psd.SKU_10 as SKU,
    psd.PRODUCT_NAME ,
    psd.PRODUCT_TYPE ,
    psd.PRODUCT_BRAND ,
    psd.MAJOR_CATEGORY + ' ' + psd.MAJOR_CATEGORY_DESC as CLASS,
    psd.MAJOR_CATEGORY_DESC as CLASS_DESC,
    psd.APPLICATION + ' ' + psd.APPLICATION_DESC as DEPARTMENT,
    psd.APPLICATION_DESC as DEPARTMENT_DESC,
    psd.CATEGORY +' ' + psd.CATEGORY_DESC as SUB_DEPARTMENT,
    psd.CATEGORY_DESC as SUB_DEPARTMENT_DESC,
    psd.SUB_CATEGORY + ' ' + psd.SUB_CATEGORY_DESC as DIVISION,
    psd.SUB_CATEGORY_DESC as DIVISION_DESC,
    psd.INVENTORY_HIER as INVENTORY_HIER,
    psd.LH_L1 as L1,
    psd.LH_L2 as L2,
    psd.LH_L3 as L3,
    psd.LH_L4 as L4,
    psd.LH_L5 as L5,
    a.IS_REVENUE_ITEM ,
    a.TX_DATE ,
    isnull(psd.RETAIL_PRICE, 0) as SUGGESTED_RETAIL_PRICE,
    a.SALE_OR_RETURN ,
    a.DEMOGRAPHIC ,
    --	a.SALES_GROSS_AMT ,
    case
        when a.SALE_OR_RETURN = 'RETURN' then 0
        else a.SALES_GROSS_AMT
    end as SALES_GROSS_AMT ,
    a.SALES_NET_AMT ,
    a.QTY ,
    a.MEMO_COUNT,
    a.TX_QTY,
    a.TX_AMT,
    a.SALES_NET_AMT- a.SALES_GROSS_AMT as DISCOUNT
from
    (
        select
            psssdvv.CUSTOMER_TYPE , psssdvv.COMPANY_CODE , psssdvv.location_code , psssdvv.SKU, psssdvv.IS_REVENUE_ITEM , psssdvv.TX_DATE , 0 as TARGET_AMOUNT,
            --    isnull(psd.RETAIL_PRICE, 0) as SUGGESTED_RETAIL_PRICE,
            psssdvv.SALE_OR_RETURN , psssdvv.DEMOGRAPHIC , psssdvv.SALES_GROSS_AMT , psssdvv.SALES_NET_AMT , psssdvv.QTY , psssdvv.MEMO_COUNT as MEMO_COUNT, psssdvv.QTY as TX_QTY, psssdvv.SALES_NET_AMT as TX_AMT
        from
            PMV_SALES_STORE_SKU_DEMOGRAPHIC_ALL psssdvv ) a
inner join PM_COMPANY pc on
    a.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl on
    a.COMPANY_CODE = pl.COMPANY_CODE
    and a.location_code = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PV_SKU_DETAIL psd on
    psd.COMPANY_CODE = a.COMPANY_CODE
    and psd.SKU_10 = a.SKU
    --where a.TX_DATE = '2019-07-01'
    --and a.COMPANY_CODE = 'HKEL'
