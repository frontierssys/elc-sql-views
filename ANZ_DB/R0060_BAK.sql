CREATE   VIEW  [dbo].[R0060_BAK] AS
select
    psd.SKU_10 ,
    psd.SKU_6 ,
    psd.SKU_4 ,
    psd.PRODUCT_NAME ,
    psd.UPC ,
    psd.COMPANY_CODE ,
    psd.PRODUCT_BRAND ,
    psd.MAJOR_CATEGORY ,
    psd.APPLICATION ,
    psd.CATEGORY ,
    psd.SUB_CATEGORY ,
    psd.INVENTORY_HIER ,
    psd.RETAIL_PRICE ,
    pp.CUR_RETAIL_PRICE ,
    CONVERT(varchar(10), pp.EFFECTIVE_DT, 126) as EFFECTIVE_DT,
    'HKTF0013' as LOCATION_CODE,
    '' as FUTURE_PRICE,
    getdate() as FUTURE_EFFECTIVE_DATE
from
    PM_PRICE pp
inner join PV_SKU_DETAIL psd
    on pp.SKU_ID_FK = psd.SKU_ID
inner join
    PM_PRICE_BOOK ppb
    on pp.PRICE_BOOK_ID_FK = ppb.PRICE_BOOK_ID
where ppb.DESCRIPTION <> 'DEFAULT'
