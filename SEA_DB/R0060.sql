CREATE   view [dbo].[R0060] as
select
    psdn.SKU_10 ,
    psdn.SKU_6 ,
    psdn.SKU_4 ,
    psdn.PRODUCT_NAME ,
    psdn.UPC ,
    psdn.COMPANY_CODE ,
    psdn.PRODUCT_BRAND ,
    --psdn.MAJOR_CATEGORY ,
    --psdn.APPLICATION ,
    --psdn.CATEGORY ,
    --psdn.SUB_CATEGORY ,
    psdn.INVENTORY_HIER ,
    psdn.MAJOR_CATEGORY + ' ' + psdn.MAJOR_CATEGORY_DESC as MAJOR_CATEGORY,
    psdn.APPLICATION + ' ' + psdn.APPLICATION_DESC as APPLICATION,
    psdn.CATEGORY +' ' + psdn.CATEGORY_DESC as CATEGORY,
    psdn.SUB_CATEGORY + ' ' + psdn.SUB_CATEGORY_DESC as SUB_CATEGORY,
    d.CUR_RETAIL_PRICE as RETAIL_PRICE ,
    d.CUR_RETAIL_PRICE as CUR_RETAIL_PRICE ,
    prd.REPORT_DATE as EFFECTIVE_DT,
    pp.EXPIRY_DT as EXPIRY_DT,
    pp.CUR_RETAIL_PRICE as FUTURE_PRICE,
    pp.EFFECTIVE_DT as FUTURE_EFFECTIVE_DATE,
    COUNT(1) as DUP_COUNT
from PV_PRICE_DATES prd
cross join PV_SKU_DETAIL_NOPRICE psdn
outer apply getprice(psdn.SKU_ID , prd.REPORT_DATE ) d
left join PM_PRICE pp
    on pp.SKU_ID_FK = psdn.SKU_ID
    and pp.EFFECTIVE_DT = (
        select min(pp2.EFFECTIVE_DT )
        from PM_PRICE pp2
        where pp2.SKU_ID_FK = psdn.SKU_ID and pp2.EFFECTIVE_DT > prd.REPORT_DATE)
        --and (d.CUR_RETAIL_PRICE is null or pp.CUR_RETAIL_PRICE > d.CUR_RETAIL_PRICE)
where pp.CUR_RETAIL_PRICE is not null or d.CUR_RETAIL_PRICE is not null
--and prd.REPORT_DATE = '2021-01-01'
--and psdn.COMPANY_CODE = 'HKEL'
group by
    psdn.SKU_10 ,
    psdn.SKU_6 ,
    psdn.SKU_4 ,
    psdn.PRODUCT_NAME ,
    psdn.UPC ,
    psdn.COMPANY_CODE ,
    psdn.PRODUCT_BRAND ,
    --psdn.MAJOR_CATEGORY ,
    --psdn.APPLICATION ,
    --psdn.CATEGORY ,
    --psdn.SUB_CATEGORY ,
    psdn.INVENTORY_HIER ,
    psdn.MAJOR_CATEGORY + ' ' + psdn.MAJOR_CATEGORY_DESC ,
    psdn.APPLICATION + ' ' + psdn.APPLICATION_DESC ,
    psdn.CATEGORY +' ' + psdn.CATEGORY_DESC ,
    psdn.SUB_CATEGORY + ' ' + psdn.SUB_CATEGORY_DESC ,
    d.CUR_RETAIL_PRICE  ,
    d.CUR_RETAIL_PRICE  ,
    prd.REPORT_DATE ,
    pp.EXPIRY_DT ,
    pp.CUR_RETAIL_PRICE ,
    pp.EFFECTIVE_DT
