-- dbo.PV_R0018_NOINV source
CREATE   view PV_R0018_NOINV as
SELECT
    prs.COMPANY_CODE ,
    pst.STORE_TYPE_CODE as STORE_TYPE,
    pl.CITY_TXT as STORE_LOCATION,
    prs.LOCATION_ID ,
    pl.LOCATION_NAME as STORE_NAME,
    prs.SKU as SKU_10,
    LEFT (prs.SKU, 6) as SKU_6,
    LEFT (prs.SKU, 4) as SKU_4,
    isnull(ps.SKU_DESC, pi2.ITEM_DESC_1 )as PRODUCT_NAME,
    pvu.VENDOR_UPC_CODE as UPC,
    pb.BRAND_DESC  as SUB_BRAND,
    pi2.BUSINESS_UNIT_CODE + ' ' + pb2.BU_DESC as MAJOR_CATEGORY,
    pi2.BUSINESS_UNIT_CODE  as MAJOR_CATEGORY_CODE,
    pi2.DEPT_CODE + ' ' + pd.DEPT_NAME  as APPLICATION,
    pi2.DEPT_CODE as APPLICATION_CODE,
    pc3.CLASS_CODE + ' ' + pc3.CLASS_DESC  as CATEGORY,
    pc3.CLASS_CODE as CATEGORY_CODE,
    ps2.SUBCLASS_CODE + ' ' + ps2.SUBCLASS_DESC  as SUB_CATEGORY,
    ps2.SUBCLASS_CODE as SUB_CATEGORY_CODE,
    concat(psa.IH_L1,psa.IH_L2,psa.IH_L3)  as INVENTORY_HIERARCHY,
    isnull(psa.LH_L1, 'NA') as L1,
    isnull(psa.LH_L2, 'NA')as L2,
    isnull(psa.LH_L3, 'NA')as L3,
    isnull(psa.LH_L4, 'NA')as L4,
    isnull(psa.IS_HERO_PRODUCT, 'N') as L5,
    ptip.CUR_RETAIL_PRICE  as SUGGESTED_RETAIL_PRICE,
    prs.MOVEMENT_DT as TX_DT,
    prs.BUCKET as INVENTORY_BUCKET ,
    prs.SALES_QTY,
    prs.TRANSFER_OUT_QTY,
    prs.TRANSFER_IN_QTY,
    prs.RETURN_QTY as RTW_QUANTITY,
    prs.RECEIVE_QTY,
    prs.ADJUSTMENT_QTY as ADJUSTMENT_QUANTITY,
    prs.RTW_QTY,
    'CONFIRM' as STATUS,
    'NA' as REASON,
    psa.DEFAULT_UOM_CODE as UOM
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
left join PM_VENDOR_UPC pvu
    on pvu.SKU = ps.SKU_CODE
    and pvu.COMPANY_CODE = ps.COMPANY_CODE
inner join PM_BU pb2
    on pb2.COMPANY_CODE = ps.COMPANY_CODE
    and pb2.BU_CODE = pi2.BUSINESS_UNIT_CODE
inner join PM_DEPT pd
    on pd.COMPANY_CODE = pi2.COMPANY_CODE
    and pd.DEPT_CODE = pi2.DEPT_CODE
    and pd.BU_ID_FK = pb2.BU_ID
left join PV_TODAY_ITEM_PRICE ptip
    on ps.SKU_ID = ptip.SKU_ID_FK
inner join PV_R0018_SUB prs
    on prs.COMPANY_CODE = ps.COMPANY_CODE
    and prs.SKU = ps.SKU_CODE
inner join PM_LOCATION pl on
    prs.COMPANY_CODE = pl.COMPANY_CODE
    and prs.LOCATION_ID = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
