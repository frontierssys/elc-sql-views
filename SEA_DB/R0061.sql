CREATE    view [dbo].[R0061] AS
select
    ppb.DESCRIPTION,
    psd.SKU_10 ,
    psd.SKU_6 ,
    psd.SKU_4 ,
    psd.PRODUCT_NAME ,
    psd.UPC ,
    psd.COMPANY_CODE ,
    psd.PRODUCT_BRAND ,
    psd.MAJOR_CATEGORY + ' ' + psd.MAJOR_CATEGORY_DESC as MAJOR_CATEGORY,
    psd.APPLICATION + ' ' + psd.APPLICATION_DESC as APPLICATION,
    psd.CATEGORY +' ' + psd.CATEGORY_DESC as CATEGORY,
    psd.SUB_CATEGORY + ' ' + psd.SUB_CATEGORY_DESC as SUB_CATEGORY,
    psd.INVENTORY_HIER ,
    pp.EFFECTIVE_DT as PRIOR_EFFECTIVE_DATE,
    pp.CUR_RETAIL_PRICE as PRIOR_PRICE,
    CONVERT(varchar(10), pp3.EFFECTIVE_DT, 126) as DATE_CHANGE,
    pp3.CUR_RETAIL_PRICE as UPDATED_PRICE_PRICE,
    count(1) as DUP_CNT
from
    PM_PRICE pp
inner join PV_SKU_DETAIL_NOPRICE psd
    on pp.SKU_ID_FK = psd.SKU_ID
inner join
    PM_PRICE_BOOK ppb
    on pp.PRICE_BOOK_ID_FK = ppb.PRICE_BOOK_ID
left join PM_PRICE pp3
    on pp3.SKU_ID_FK = pp.SKU_ID_FK
    and pp3.EFFECTIVE_DT = (
        select min(pp2.EFFECTIVE_DT )
        from PM_PRICE pp2
        where pp2.SKU_ID_FK = pp3.SKU_ID_FK and pp2.EFFECTIVE_DT > pp.EFFECTIVE_DT and ppb.DESCRIPTION <> 'DEFAULT')
left join PM_PRICE_BOOK ppb2
    on pp3.PRICE_BOOK_ID_FK = ppb2.PRICE_BOOK_ID
    and ppb2.DESCRIPTION <> 'DEFAULT'
where ppb.DESCRIPTION <> 'DEFAULT'
    and pp.CUR_RETAIL_PRICE <> pp3.CUR_RETAIL_PRICE
group by
    ppb.DESCRIPTION,
    psd.SKU_10 ,
    psd.SKU_6 ,
    psd.SKU_4 ,
    psd.PRODUCT_NAME ,
    psd.UPC ,
    psd.COMPANY_CODE ,
    psd.PRODUCT_BRAND ,
    psd.MAJOR_CATEGORY + ' ' + psd.MAJOR_CATEGORY_DESC ,
    psd.APPLICATION + ' ' + psd.APPLICATION_DESC ,
    psd.CATEGORY +' ' + psd.CATEGORY_DESC ,
    psd.SUB_CATEGORY + ' ' + psd.SUB_CATEGORY_DESC ,
    psd.INVENTORY_HIER ,
    pp.EFFECTIVE_DT ,
    pp.CUR_RETAIL_PRICE ,
    CONVERT(varchar(10), pp3.EFFECTIVE_DT, 126) ,
    pp3.CUR_RETAIL_PRICE
