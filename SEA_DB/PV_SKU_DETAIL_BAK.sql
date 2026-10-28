-- dbo.PV_SKU_DETAIL source

CREATE     view [dbo].[PV_SKU_DETAIL] as
SELECT
--ps.SKU_CODE
    ps.COMPANY_CODE,
    ps.SKU_ID ,
    ps.SKU_CODE as SKU_10,
    left(ps.SKU_CODE,9) as SKU_9,
    left(ps.SKU_CODE,6) as SKU_6,
    left(ps.SKU_CODE,4) as SKU_4,
    isnull(ps.SKU_DESC, pi2.ITEM_DESC_1 ) as PRODUCT_NAME,
    CASE
        when psa.IH_L1 = '110' then 'Saleable'
        when psa.IH_L1 = '120' then 'Promotional'
        when psa.IH_L1 = '130' then 'Collateral'
        when psa.IH_L1 = '140' then 'Non-Inventoried Materials'
        Else 'Others'
    end as PRODUCT_TYPE,
    pb.BRAND_DESC as PRODUCT_BRAND,
    pi2.BUSINESS_UNIT_CODE as MAJOR_CATEGORY,
    pb2.BU_DESC as MAJOR_CATEGORY_DESC,
    pi2.DEPT_CODE as APPLICATION,
    pd.DEPT_NAME as APPLICATION_DESC,
    pc3.CLASS_CODE as CATEGORY,
    pc3.CLASS_DESC as CATEGORY_DESC,
    ps2.SUBCLASS_CODE as SUB_CATEGORY,
    ps2.SUBCLASS_DESC as SUB_CATEGORY_DESC,
    --pvu.VENDOR_UPC_CODE as UPC,
    ps.DEFAULT_UPC as UPC,
    concat(psa.IH_L1,psa.IH_L2,psa.IH_L3) as INVENTORY_HIER,
    isnull(psa.LH_L1, 'NA') as LH_L1,
    isnull(psa.LH_L2, 'NA') as LH_L2,
    isnull(psa.LH_L3, 'NA') as LH_L3,
    isnull(psa.LH_L4, 'NA') as LH_L4,
    isnull(psa.IS_HERO_PRODUCT, 'N') as LH_L5,
    psa.IH_L1 as IH_L1,
    psa.IH_L2 as IH_L2,
    psa.IH_L3 as IH_L3,
    CASE
        when psa.IH_L1 = '140' and  psa.IH_L2 = '55' and psa.IH_L3 = '12' then 'Y'
        ELSE 'N'
    end as IS_SERVICE_ITEM
    ,
    ISNULL(ptip.CUR_RETAIL_PRICE,0) as RETAIL_PRICE,
    ptip.D_CHAIN as D_CHAIN
FROM  PM_SKU ps
inner join dbo.PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
inner join dbo.PM_ITEM pi2
    on ps.ITEM_ID_FK = pi2.ITEM_ID
inner join dbo.PM_CLASS pc3
    on pi2.CLASS_ID_FK = pc3.CLASS_ID
inner join dbo.PM_SUBCLASS ps2
    on pi2.SUBCLASS_ID_FK = ps2.SUBCLASS_ID
inner join dbo.PM_BRAND pb
    on pi2.BRAND_ID_FK = pb.BRAND_ID
    --left join PM_VENDOR_UPC pvu
    --on pvu.SKU = ps.SKU_CODE
    --and pvu.COMPANY_CODE = ps.COMPANY_CODE
inner join PM_BU pb2
    on pb2.COMPANY_CODE = ps.COMPANY_CODE
    and pb2.BU_CODE = pi2.BUSINESS_UNIT_CODE
inner join PM_DEPT pd
    on pd.COMPANY_CODE = pi2.COMPANY_CODE
    and pd.DEPT_CODE = pi2.DEPT_CODE
    and pd.BU_ID_FK = pb2.BU_ID
left join PV_TODAY_ITEM_PRICE ptip
    on ps.SKU_ID = ptip.SKU_ID_FK
