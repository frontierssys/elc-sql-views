CREATE   VIEW [dbo].[PV_R0021] AS
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
    --pi2.ITEM_DESC_1 as PRODUCT_DESCRIPTION,
    isnull(ps2.SKU_DESC, pi2.ITEM_DESC_1 ) as PRODUCT_DESCRIPTION,
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
    end as DESTINATION_PRIOR_INVENTORY,
    CASE
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='MAC' THEN 'MO'
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='HKG' THEN 'HK'
        ELSE LEFT(pl.COMPANY_CODE,2)
    END as ENTITY
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
        timbd.COMPANY_CODE ,
        timbd.LOCATION_CODE,
        -- ibth.TRANSFER_NO,
        timbd.BALANCE_TYPE ,
        timbd.SKU,
        timbd.OPEN_BALANCE_DT,
        timbd.BALANCE + sum(timbd.MOVEMENT_QTY) AS_OF_QTY
    from
        PV_INVENTORY_MOVEMENT_BY_DAY_V2 timbd
    inner join
        (
            select
                a.COMPANY_CODE  , a.LOCATION_CODE, a.BALANCE_TYPE , a.SKU, max(a.OPEN_BALANCE_DT) MAX_BALANCE_DT
            from
                PV_INVENTORY_MOVEMENT_BY_DAY_V2 a
            group by
                a.COMPANY_CODE  , a.LOCATION_CODE, a.BALANCE_TYPE , a.SKU
        ) inv
        on timbd.COMPANY_CODE = inv.COMPANY_CODE
        and timbd.LOCATION_CODE = inv.LOCATION_CODE
        and timbd.BALANCE_TYPE = inv.BALANCE_TYPE
        and timbd.SKU = inv.SKU
        and timbd.OPEN_BALANCE_DT = inv.MAX_BALANCE_DT
        /*inner join IT_BALANCE_TRANSFER_H ibth
        ON ibth.COMPANY_CODE =timbd.COMPANY_CODE
        and ibth.TRANS_LOCATION_CODE =timbd.LOCATION_CODE
        AND ibth.FROM_BALANCE =timbd.BALANCE_TYPE
        inner join IT_BALANCE_TRANSFER_D ibtd ON ibtd.BAL_TRANSFER_H_ID_FK =ibth.BAL_TRANSFER_H_ID and ibtd.SKU_CODE =timbd.SKU */
    where 1 =1
    /* and timbd.MOVEMENT_DATE <=COALESCE (DATEADD(second,30,ibth.UPDATE_DATET),DATEADD(second,30,ibth.CRE_DATET))*/
    group by
        timbd.COMPANY_CODE ,
        timbd.LOCATION_CODE,
        --ibth.TRANSFER_NO,
        timbd.BALANCE_TYPE ,
        timbd.SKU,
        timbd.OPEN_BALANCE_DT,
        timbd.BALANCE
) as sb
    on ps2.COMPANY_CODE = sb.COMPANY_CODE
    and ps2.SKU_CODE = sb.SKU
    and iiah.TRANS_LOCATION_CODE = sb.LOCATION_CODE
    and iiah.FROM_BALANCE = sb.BALANCE_TYPE
    /*and iiah.TRANSFER_NO = sb.TRANSFER_NO*/
left join (
    select
        timbd.COMPANY_CODE ,
        timbd.LOCATION_CODE,
        --ibth.TRANSFER_NO ,
        timbd.BALANCE_TYPE ,
        timbd.SKU,
        timbd.OPEN_BALANCE_DT,
        timbd.BALANCE + sum(timbd.MOVEMENT_QTY) AS_OF_QTY
    from
        PV_INVENTORY_MOVEMENT_BY_DAY_V2 timbd
    inner join
        (
            select
                a.COMPANY_CODE  , a.LOCATION_CODE, a.BALANCE_TYPE , a.SKU, max(a.OPEN_BALANCE_DT) MAX_BALANCE_DT
            from
                PV_INVENTORY_MOVEMENT_BY_DAY_V2 a
            group by
                a.COMPANY_CODE  , a.LOCATION_CODE, a.BALANCE_TYPE , a.SKU
        ) inv
        on timbd.COMPANY_CODE = inv.COMPANY_CODE
        and timbd.LOCATION_CODE = inv.LOCATION_CODE
        and timbd.BALANCE_TYPE = inv.BALANCE_TYPE
        and timbd.SKU = inv.SKU
        and timbd.OPEN_BALANCE_DT = inv.MAX_BALANCE_DT
        /*  inner join IT_BALANCE_TRANSFER_H ibth ON ibth.COMPANY_CODE =timbd.COMPANY_CODE and ibth.TRANS_LOCATION_CODE =timbd.LOCATION_CODE
            AND ibth.TO_BALANCE =timbd.BALANCE_TYPE
          inner join IT_BALANCE_TRANSFER_D ibtd ON ibtd.BAL_TRANSFER_H_ID_FK =ibth.BAL_TRANSFER_H_ID and ibtd.SKU_CODE =timbd.SKU */
    where 1 =1
    /* and timbd.MOVEMENT_DATE <=COALESCE (DATEADD(second,30,ibth.UPDATE_DATET),DATEADD(second,30,ibth.CRE_DATET))*/
    group by
        timbd.COMPANY_CODE ,
        timbd.LOCATION_CODE,
        -- ibth.TRANSFER_NO,
        timbd.BALANCE_TYPE ,
        timbd.SKU,
        timbd.OPEN_BALANCE_DT,
        timbd.BALANCE
) as sb2
    on ps2.COMPANY_CODE = sb2.COMPANY_CODE
    and ps2.SKU_CODE = sb2.SKU
    and iiah.TRANS_LOCATION_CODE = sb2.LOCATION_CODE
    and iiah.TO_BALANCE = sb2.BALANCE_TYPE
    --and iiah.TRANSFER_NO =sb2.TRANSFER_NO
    --where iiah.TRANSFER_NO in ('HKCM0012BT20210429141157','HKCM0012BT20210429141556');
