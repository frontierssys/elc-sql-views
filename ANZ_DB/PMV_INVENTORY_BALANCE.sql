CREATE   VIEW  PMV_INVENTORY_BALANCE
--WITH SCHEMABINDING
AS
select
    pcomp.COMPANY_DESC COMPANY_DESC,
    pcomp.COMPANY_CODE COMPANY_CODE,
    pst.STORE_TYPE_NAME STORE_TYPE_NAME,
    pl.LOCATION_DESC LOCATION_DESC,
    pl.LOCATION_CODE LOCATION_CODE,
    pl.LOCATION_NAME LOCATION_NAME,
    ps.SKU_CODE SKU_CODE,
    left (ps.SKU_CODE, 6) sixDigitSku,
    left (ps.SKU_CODE, 4) fourDigitSku,
    concat(pi.ITEM_DESC_1, pi.ITEM_DESC_2) item_desc,
    ib.BALANCE_TYPE BALANCE_TYPE,
    ib.BALANCE BALANCE,
    pd.DEPT_CODE DEPT_CODE,
    pbu.bu_code bu_code,
    pbu.bu_desc bu_desc,
    pc.CLASS_DESC CLASS_DESC,
    ps2.SUBCLASS_DESC SUBCLASS_DESC,
    pb.BRAND_DESC BRAND_DESC,
    piattr.is_sales_item is_sales_item,
    piattr.is_sample_item is_sample_item,
    psattr.is_hero_product is_hero_product,
    psattr.ih_l1 ih_l1,
    psattr.ih_l2 ih_l2,
    psattr.ih_l3 ih_l3,
    psattr.lh_l1 lh_l1,
    psattr.lh_l2 lh_l2,
    psattr.lh_l3 lh_l3,
    psattr.lh_l4 lh_l4,
    CONVERT(varchar(10), ib.BALANCE_DT, 126) bal_date
from dbo.PL_INVENTORY_BALANCE ib,
    dbo.PM_SKU ps
left join
    dbo.PM_SKU_ATTR  psattr
    on ps.sku_attr_id_fk = psattr.sku_attr_id,
    dbo.PM_ITEM_ATTR piattr,
    dbo.PM_LOCATION pl,
    dbo.pm_company pcomp,
    dbo.PM_STORE_TYPE pst,
    dbo.PM_ITEM pi
left join
    dbo.PM_BU pbu
    on pi.BUSINESS_UNIT_CODE  = pbu.BU_CODE
    and pi.COMPANY_CODE  = pbu.COMPANY_CODE
left join
    dbo.PM_SUBCLASS ps2
    on  pi.SUBCLASS_ID_FK  = ps2.SUBCLASS_ID
left join
    dbo.PM_DEPT pd
    on pi.DEPT_CODE  = pd.DEPT_CODE
    and pi.COMPANY_CODE  = pd.COMPANY_CODE
left join
    dbo.PM_BRAND pb
    on  pi.BRAND_ID_FK  = pb.BRAND_ID
left join
    dbo.PM_CLASS pc
    on pi.CLASS_ID_FK  = pc.CLASS_ID
where
    ib.COMPANY_CODE = ps.COMPANY_CODE
    and ib.SKU =  ps.SKU_CODE
    and ib.LOCATION_ID = pl.LOCATION_CODE
    and ib.COMPANY_CODE = pl.COMPANY_CODE
    and pi.ITEM_ID  = ps.ITEM_ID_FK
    and ib.COMPANY_CODE = pcomp.COMPANY_CODE
    and pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
group by pcomp.COMPANY_DESC,
    pcomp.COMPANY_CODE,
    pst.STORE_TYPE_NAME,
    pl.LOCATION_DESC,
    pl.LOCATION_CODE,
    pl.LOCATION_NAME,
    ps.SKU_CODE,
    left (ps.SKU_CODE, 6) ,
    left (ps.SKU_CODE, 4) ,
    concat(pi.ITEM_DESC_1, pi.ITEM_DESC_2)  ,
    ib.BALANCE_TYPE,
    pd.DEPT_CODE ,
    pbu.bu_code,
    pbu.bu_desc,
    pc.CLASS_DESC ,
    ps2.SUBCLASS_DESC ,
    pb.BRAND_DESC ,
    piattr.is_sales_item,
    piattr.is_sample_item,
    psattr.is_hero_product,
    ib.balance,
    psattr.ih_l1,
    psattr.ih_l2,
    psattr.ih_l3,
    psattr.lh_l1,
    psattr.lh_l2,
    psattr.lh_l3,
    psattr.lh_l4
    ,CONVERT(varchar(10), ib.BALANCE_DT, 126)
