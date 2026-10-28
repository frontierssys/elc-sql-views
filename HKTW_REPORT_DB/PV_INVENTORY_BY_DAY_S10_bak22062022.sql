-- dbo.PV_INVENTORY_BY_DAY_S10 source

-- dbo.PV_INVENTORY_BY_DAY_S10_21062022 source

-- dbo.PV_INVENTORY_BY_DAY_S10 source

CREATE   view PV_INVENTORY_BY_DAY_S10_bak22062022 as
SELECT
    pswb.COMPANY_CODE,
    pswb.SKU_10,
    pswb.SKU_9,
    pswb.SKU_6 ,
    pswb.SKU_4 ,
    pswb.PRODUCT_NAME,
    pb.BRAND_DESC as PRODUCT_BRAND,
    pi2.BUSINESS_UNIT_CODE as MAJOR_CATEGORY,
    pi2.DEPT_CODE as APPLICATION,
    pc3.CLASS_CODE as CATEGORY,
    ps2.SUBCLASS_CODE as SUB_CATEGORY,
    --pvu.VENDOR_UPC_CODE as UPC,
    ps.DEFAULT_UPC as UPC,
    concat(psa.IH_L1,psa.IH_L2,psa.IH_L3) as INVENTORY_HIER,
    isnull(psa.LH_L1, 'NA') as LH_L1,
    isnull(psa.LH_L2, 'NA') as LH_L2,
    isnull(psa.LH_L3, 'NA') as LH_L3,
    isnull(psa.LH_L4, 'NA') as LH_L4,
    isnull(psa.IS_HERO_PRODUCT, 'N') as LH_L5,
    --isnull(pswb.BUCKET_TYPE, inv.BUCKET_TYPE ) as BUCKET_TYPE ,
    ptip.CUR_RETAIL_PRICE as RETAIL_PRICE,
    inv.BUCKET_TYPE as BUCKET_TYPE ,
    inv.LOCATION_ID as LOCATION_ID,
    pl.LOCATION_DESC,
    pl.CITY_TXT as 'Address',
    pst.STORE_TYPE_NAME,
    ISNULL(CAST(inv.BALANCE_DT as DATE), '2020-01-01') as BALANCE_DATE,
    ISNULL(inv.balance, 0) as OPENING_BALANCE,
    --CAST(inv.MOVEMENT_DT as DATE) as MOVEMENT_DATE,
    inv.MOVEMENT_DATE,
    ISNULL(sum(inv.MOVEMENT_QTY), 0) as MOVEMENT_QTY
FROM PV_SKU_WITH_BUCKET pswb
inner join PM_SKU ps
    on pswb.SKU_ID = ps.SKU_ID
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
    --inner join PM_VENDOR_UPC pvu
    --on pvu.SKU = ps.SKU_CODE
    --and pvu.COMPANY_CODE = ps.COMPANY_CODE
left join PV_TODAY_ITEM_PRICE ptip
    on pswb.SKU_ID = ptip.SKU_ID_FK
inner join
    (
        select
            isnull(pim.COMPANY_CODE , pib.COMPANY_CODE ) as COMPANY_CODE ,
            isnull(pim.LOCATION_ID, pib.LOCATION_ID ) as LOCATION_ID ,
            --	pl.LOCATION_DESC,
            --	CONCAT( pl.ADDRESS1,
            --	pl.ADDRESS2,
            --	pl.ADDRESS3) as 'Address',
            --	pst.STORE_TYPE_NAME,
            isnull(pim.SKU, pib.SKU ) as SKU_10,
            pim.MOVEMENT_DT as MOVEMENT_DT,
            pim.MOVEMENT_DATE,
            isnull(pim.BUCKET_TYPE, pib.BALANCE_TYPE  ) as BUCKET_TYPE,
            pim.MOVEMENT_QTY as MOVEMENT_QTY,
            isnull(pib.BALANCE_DT, '2000-01-01') as BALANCE_DT ,
            isnull(pib.BALANCE, 0) as BALANCE
        from PL_INVENTORY_BALANCE pib
        full outer join PV_INVENTORY_MOVEMENT pim
            on pib.SKU = pim.SKU
            and pim.BUCKET_TYPE = pib.BALANCE_TYPE
            and pim.LOCATION_ID = pib.LOCATION_ID
            and pim.MOVEMENT_DT >= pib.BALANCE_DT
            --where len(isnull(pim.SKU, pib.SKU )) = 10
            --where pib.BALANCE_DT IN (select max(BALANCE_DT) from PL_INVENTORY_BALANCE pibi where pibi.sku=pib.SKU and pibi.LOCATION_ID =
            --pib.LOCATION_ID and pibi.BALANCE_TYPE=pib.BALANCE_TYPE)
            --	left join dbo.PM_LOCATION pl
            --	on pl.LOCATION_ID = pim.LOCATION_ID or pl.LOCATION_ID = pib.LOCATION_ID
            --	left join dbo.PM_STORE_TYPE pst
            --	on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
            --where pim.SKU = 'T1M6Y20001' or pib.SKU = 'T1M6Y2000'
        union ALL
        Select
            pib.COMPANY_CODE  as COMPANY_CODE ,
            pib.LOCATION_ID  as LOCATION_ID ,
            pib.SKU  as SKU_10,
            pib.BALANCE_DT as MOVEMENT_DT,
            CAST(pib.BALANCE_DT as DATE) as MOVEMENT_DATE,
            pib.BALANCE_TYPE as BUCKET_TYPE,
            0 as MOVEMENT_QTY,
            pib.BALANCE_DT as BALANCE_DT ,
            pib.BALANCE as BALANCE
        from
            PL_INVENTORY_BALANCE pib
        where len(pib.SKU ) = 10
    ) as inv
    on pswb.COMPANY_CODE = inv.COMPANY_CODE
    and pswb.SKU_10 = inv.SKU_10
    and pswb.BUCKET_TYPE = inv.BUCKET_TYPE
left join dbo.PM_LOCATION pl
    on pl.LOCATION_CODE = inv.LOCATION_ID
    and pl.COMPANY_CODE = inv.COMPANY_CODE
left join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
    --where inv.bucket_type is not null
    --where (inv.LOCATION_ID in ('HKTF0013'))
    --and (inv.SKU_9 = 'T1M6Y2000')
GROUP BY
    pswb.COMPANY_CODE,
    pswb.SKU_10 ,
    pswb.SKU_9,
    pswb.SKU_6 ,
    pswb.SKU_4 ,
    pswb.PRODUCT_NAME,
    pb.BRAND_DESC,
    pi2.BUSINESS_UNIT_CODE,
    pi2.DEPT_CODE,
    pc3.CLASS_CODE ,
    ps2.SUBCLASS_CODE ,
    --pvu.VENDOR_UPC_CODE,
    ps.DEFAULT_UPC ,
    concat(psa.IH_L1,psa.IH_L2,psa.IH_L3),
    psa.LH_L1,
    psa.LH_L2,
    psa.LH_L3,
    psa.LH_L4,
    psa.IS_HERO_PRODUCT,
    ptip.CUR_RETAIL_PRICE,
    inv.BUCKET_TYPE  ,
    inv.LOCATION_ID ,
    pl.LOCATION_DESC,
    pl.CITY_TXT ,
    pst.STORE_TYPE_NAME,
    --ISNULL(inv.BALANCE_DT, '2020-01-01') ,
    ISNULL(CAST(inv.BALANCE_DT as DATE), '2020-01-01'),
    ISNULL(inv.balance, 0),
    inv.MOVEMENT_DATE
    --inv.MOVEMENT_DT;
