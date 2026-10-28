CREATE   view [dbo].[PV_R0021_BAK] AS
SELECT
    iiah.TRANSFER_NO as ADJUSTMENT_NO,
    iiah.TRANSFER_NO ,
    iiah.COMPANY_CODE,
    pc.COMPANY_DESC ,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    --CONCAT( pl.ADDRESS1 ,' ',  pl.ADDRESS2 ,' ', pl.ADDRESS3 ) as STORE_LOCATION,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    -- pl.CRE_BY ,
    --ps.STAFF_ID as CRE_BY,
    pu.USER_CODE as CRE_BY,
    ps.FIRST_NAME ,
    CAST(idafh.CRE_DATET as DATE) as REQUEST_DATE,
    CASE
        when iiah.OVERALL_APPROVAL_STATUS = 'APPROVED' then CAST(iiah.OVERALL_APPROVE_DT as DATE)
    end as COMPLETED_DATE,
    iiah.OVERALL_APPROVAL_STATUS as STATUS,
    iiad.SKU_CODE as SKU_10,
    LEFT(iiad.SKU_CODE, 6) as SKU_6,
    LEFT(iiad.SKU_CODE, 4) as SKU_4,
    pi2.ITEM_DESC_1 as PRODUCT_DESCRIPTION,
    ir.REASON_DESCRIPTION as REASON_CODE,
    iiad.ORI_RETAIL_PRICE as SUGGESTED_RETAIL_PRICE,
    --iiad.QTY as ADJ_QTY,
    iiad.QTY  as ADJUSTED_INVENTORY,
    iiah.FROM_BALANCE as SOURCE_INVENTORY_BUCKET,
    sb.AS_OF_QTY as SOURCE_UPDATED_INVENTORY,
    Case
        when iiah.OVERALL_APPROVAL_STATUS  = 'APPROVED' then sb.AS_OF_QTY + iiad.QTY
        ELSE sb.AS_OF_QTY
    end as SOURCE_PRIOR_INVENTORY,
    iiah.TO_BALANCE as DESTINATION_INVENTORY_BUCKET,
    sb2.AS_OF_QTY as DESTINATION_UPDATED_INVENTORY,
    Case
        WHEN iiah.OVERALL_APPROVAL_STATUS = 'APPROVED'  then sb2.AS_OF_QTY - iiad.QTY
        ELSE sb2.AS_OF_QTY
    end as DESTINATION_PRIOR_INVENTORY
from IT_BALANCE_TRANSFER_H iiah
inner join IT_BALANCE_TRANSFER_D iiad
    on iiah.BAL_TRANSFER_H_ID = iiad.BAL_TRANSFER_H_ID_FK
inner join PM_COMPANY pc
    on iiah.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl
    on pl.COMPANY_CODE = iiah.COMPANY_CODE
    and iiah.TRANS_LOCATION_CODE = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_SKU ps2
    on iiad.COMPANY_CODE = ps2.COMPANY_CODE
    and iiad.SKU_CODE = ps2.SKU_CODE
inner join PM_ITEM pi2
    on ps2.ITEM_ID_FK = pi2.ITEM_ID
left join IM_REASON ir
    on iiah.COMPANY_CODE = ir.COMPANY_CODE
    and iiah.REASON_CODE = ir.SAP_REASON_CODE
left join IT_DOC_APPROVAL_FLOW_H idafh
    on idafh.COMPANY_CODE = iiah.COMPANY_CODE
    and idafh.DOC_ID = iiah.TRANSFER_NO
    and idafh.DOC_TYPE = 'BALANCE_TRANSFER'
left join PM_USER pu
    on pu.COMPANY_CODE = iiah.COMPANY_CODE
    and pu.USER_CODE = iiah.CRE_BY
left join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
left join (
    select
    --	iiah2.ADJUSTMENT_NO ,
        pibd.COMPANY_CODE ,
        pibd.SKU_10 ,
        pibd.BUCKET_TYPE ,
        pibd.LOCATION_ID ,
        pibd.BALANCE_DATE ,
        pibd.OPENING_BALANCE ,
        --pibd.MOVEMENT_QTY,
        sum(isnull(pibd.MOVEMENT_QTY,0)) as TOTAL_MOVEMENT ,
        pibd.OPENING_BALANCE + sum(isnull(pibd.MOVEMENT_QTY,0)) as AS_OF_QTY
    from PV_INVENTORY_BY_DAY_LITE pibd
    --	inner join IT_INVENTORY_ADJUSTMENT_D iiad2
    --	on iiah2.INVENTORY_ADJ_H_ID = iiad2.INVENTORY_ADJ_H_ID_FK
    --	and iiad2.SKU_CODE = pibd.SKU_10
    --	inner join IT_INVENTORY_ADJUSTMENT_H iiah2
    --	on iiah2.COMPANY_CODE = pibd.COMPANY_CODE
    --	and iiah2.ADJUST_LOCATION_CODE = pibd.LOCATION_ID
    --	and iiah2.ADJ_BALANCE = pibd.BUCKET_TYPE
    LEFT join
        (
            select
                COMPANY_CODE as COMPANY_CODE ,
                sku_9 as SKU_9 ,
                BUCKET_TYPE  as BUCKET_TYPE ,
                LOCATION_ID  as LOCATION_ID ,
                MAX(BALANCE_DATE) as MAX_DATE
            from PV_INVENTORY_BY_DAY pibd
            where BALANCE_DATE is not null
            group by
                COMPANY_CODE ,
                sku_9,
                BUCKET_TYPE ,
                LOCATION_ID) as md
        ON pibd.COMPANY_CODE = md.COMPANY_CODE
        and pibd.SKU_9 = MD.SKU_9
        and	pibd.BUCKET_TYPE = MD.BUCKET_TYPE
        and pibd.LOCATION_ID = MD.LOCATION_ID
        and	pibd.BALANCE_DATE = MD.MAX_DATE
        and pibd.BALANCE_DATE <= GETDATE()
    where 1 = 1
        and (pibd.MOVEMENT_DATE is null or pibd.MOVEMENT_DATE <= getdate())
        and (pibd.MOVEMENT_DATE is null or pibd.MOVEMENT_DATE >= MD.MAX_DATE)
        and pibd.BALANCE_DATE = MD.MAX_DATE
        ---------------------------------------------------
        -------Change this where clause to query-----------
        ---------------------------------------------------
        -- and pibd.SKU_10 = 'L003010000'
        -- and pibd.LOCATION_ID in ('HKJM0002')
        -- and pibd.COMPANY_CODE = 'HKJM'
        --	and (pibd.MOVEMENT_DATE is null or pibd.MOVEMENT_DATE <= iiah.ADJUST_DT )
        ---------------------------------------------------
        ----------------------END--------------------------
        ---------------------------------------------------
    GROUP by
        pibd.COMPANY_CODE ,
        pibd.SKU_10 ,
        pibd.BUCKET_TYPE ,
        pibd.LOCATION_ID ,
        pibd.BALANCE_DATE ,
        pibd.OPENING_BALANCE
        --	iiah2.ADJUSTMENT_NO

        --	order by pibd.SKU_10
) as sb
    on ps2.COMPANY_CODE = sb.COMPANY_CODE
    and ps2.SKU_CODE = sb.SKU_10
    and iiah.TRANS_LOCATION_CODE = sb.LOCATION_ID
    and iiah.FROM_BALANCE = sb.BUCKET_TYPE
left join (
    select
        pibd2.COMPANY_CODE ,
        pibd2.SKU_10 ,
        pibd2.BUCKET_TYPE ,
        pibd2.LOCATION_ID ,
        pibd2.BALANCE_DATE ,
        pibd2.OPENING_BALANCE ,
        --pibd.MOVEMENT_QTY,
        sum(isnull(pibd2.MOVEMENT_QTY,0)) as TOTAL_MOVEMENT ,
        pibd2.OPENING_BALANCE + sum(isnull(pibd2.MOVEMENT_QTY,0)) as AS_OF_QTY
    from PV_INVENTORY_BY_DAY_LITE pibd2
    --	inner join IT_INVENTORY_ADJUSTMENT_D iiad2
    --	on iiah2.INVENTORY_ADJ_H_ID = iiad2.INVENTORY_ADJ_H_ID_FK
    --	and iiad2.SKU_CODE = pibd.SKU_10
    --	inner join IT_INVENTORY_ADJUSTMENT_H iiah2
    --	on iiah2.COMPANY_CODE = pibd.COMPANY_CODE
    --	and iiah2.ADJUST_LOCATION_CODE = pibd.LOCATION_ID
    --	and iiah2.ADJ_BALANCE = pibd.BUCKET_TYPE
    LEFT join
        (
            select
                COMPANY_CODE as COMPANY_CODE ,
                sku_9 as SKU_9 ,
                BUCKET_TYPE  as BUCKET_TYPE ,
                LOCATION_ID  as LOCATION_ID ,
                MAX(BALANCE_DATE) as MAX_DATE
            from PV_INVENTORY_BY_DAY pibd3
            where BALANCE_DATE is not null
            group by
                COMPANY_CODE ,
                sku_9,
                BUCKET_TYPE ,
                LOCATION_ID) as md2
        ON pibd2.COMPANY_CODE = md2.COMPANY_CODE
        and pibd2.SKU_9 = MD2.SKU_9
        and	pibd2.BUCKET_TYPE = MD2.BUCKET_TYPE
        and pibd2.LOCATION_ID = MD2.LOCATION_ID
        and	pibd2.BALANCE_DATE = MD2.MAX_DATE
        and pibd2.BALANCE_DATE <= GETDATE()
    where 1 = 1
        and (pibd2.MOVEMENT_DATE is null or pibd2.MOVEMENT_DATE <= getdate())
        and (pibd2.MOVEMENT_DATE is null or pibd2.MOVEMENT_DATE >= MD2.MAX_DATE)
        and pibd2.BALANCE_DATE = MD2.MAX_DATE
        ---------------------------------------------------
        -------Change this where clause to query-----------
        ---------------------------------------------------
        -- and pibd2.SKU_10 = 'L003010000'
        -- and pibd2.LOCATION_ID in ('HKJM0002')
        -- and pibd2.COMPANY_CODE = 'HKJM'
        --	and (pibd2.MOVEMENT_DATE is null or pibd2.MOVEMENT_DATE <= iiah.ADJUST_DT )
        ---------------------------------------------------
        ----------------------END--------------------------
        ---------------------------------------------------
    GROUP by
        pibd2.COMPANY_CODE ,
        pibd2.SKU_10 ,
        pibd2.BUCKET_TYPE ,
        pibd2.LOCATION_ID ,
        pibd2.BALANCE_DATE ,
        pibd2.OPENING_BALANCE
        --	order by pibd.SKU_10
) as sb2
    on ps2.COMPANY_CODE = sb2.COMPANY_CODE
    and ps2.SKU_CODE = sb2.SKU_10
    and iiah.TRANS_LOCATION_CODE = sb2.LOCATION_ID
    and iiah.TO_BALANCE = sb2.BUCKET_TYPE
