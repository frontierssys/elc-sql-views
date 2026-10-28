CREATE   VIEW  PV_INVENTORY_BY_DAY_LITE as
SELECT
    pswb.COMPANY_CODE,
    pswb.SKU_10,
    pswb.SKU_9,
    pswb.SKU_6,
    pswb.SKU_4,
    inv.BUCKET_TYPE as BUCKET_TYPE ,
    inv.LOCATION_ID as LOCATION_ID,
    ISNULL(inv.BALANCE_DT, '2020-01-01') as BALANCE_DATE,
    ISNULL(inv.balance, 0) as OPENING_BALANCE,
    --CAST(inv.MOVEMENT_DT as date) as MOVEMENT_DATE,
    inv.MOVEMENT_DT as MOVEMENT_DATE,
    ISNULL(sum(inv.MOVEMENT_QTY), 0) as MOVEMENT_QTY
FROM PV_SKU_WITH_BUCKET pswb
inner join PM_SKU ps
    on pswb.SKU_ID = ps.SKU_ID
left join
    (
        select
            isnull(pim.COMPANY_CODE , pib.COMPANY_CODE ) as COMPANY_CODE ,
            isnull(pim.LOCATION_ID, pib.LOCATION_ID ) as LOCATION_ID ,
            --	pl.LOCATION_DESC,
            --	CONCAT( pl.ADDRESS1,
            --	pl.ADDRESS2,
            --	pl.ADDRESS3) as 'Address',
            --	pst.STORE_TYPE_NAME,
            isnull(LEFT (pim.SKU, 9), pib.SKU ) as SKU_9,
            pim.MOVEMENT_DT as MOVEMENT_DT,
            isnull(pim.BUCKET_TYPE , pib.BALANCE_TYPE ) as BUCKET_TYPE,
            pim.MOVEMENT_QTY as MOVEMENT_QTY,
            isnull(pib.BALANCE_DT, '2000-01-01') as BALANCE_DT ,
            isnull(pib.BALANCE, 0) as BALANCE
        from PL_INVENTORY_BALANCE pib
        full outer join PV_INVENTORY_MOVEMENT pim
            on pib.SKU = pim.SKU_GROUP_CODE
            AND PIM.COMPANY_CODE =PIB.COMPANY_CODE
            and pim.BUCKET_TYPE = pib.BALANCE_TYPE
            and pim.LOCATION_ID = pib.LOCATION_ID
            and pim.MOVEMENT_DT >= pib.BALANCE_DT
            --where pib.BALANCE_DT IN (select max(BALANCE_DT) from PL_INVENTORY_BALANCE pibi where pibi.sku=pib.SKU and pibi.LOCATION_ID =
            --pib.LOCATION_ID and pibi.BALANCE_TYPE=pib.BALANCE_TYPE)
            --	left join dbo.PM_LOCATION pl
            --	on pl.LOCATION_ID = pim.LOCATION_ID or pl.LOCATION_ID = pib.LOCATION_ID
            --	left join dbo.PM_STORE_TYPE pst
            --	on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
            --where pim.SKU = 'T1M6Y20001' or pib.SKU = 'T1M6Y2000'
    ) as inv
    on pswb.COMPANY_CODE = inv.COMPANY_CODE
    and pswb.SKU_9 = inv.SKU_9
    and pswb.BUCKET_TYPE = inv.BUCKET_TYPE
left join dbo.PM_LOCATION pl
    on pl.LOCATION_CODE = inv.LOCATION_ID
    and pl.COMPANY_CODE = inv.COMPANY_CODE
    --where (inv.LOCATION_ID in ('HKTF0013'))
    --and (inv.SKU_9 = 'T1M6Y2000')
GROUP BY
    pswb.COMPANY_CODE,
    pswb.SKU_10,
    pswb.SKU_9,
    pswb.SKU_6,
    pswb.SKU_4,
    inv.BUCKET_TYPE  ,
    inv.LOCATION_ID ,
    ISNULL(inv.BALANCE_DT, '2020-01-01') ,
    ISNULL(inv.balance, 0),
    --CAST(inv.MOVEMENT_DT as date)
    inv.MOVEMENT_DT;
