-- dbo.PV_R0020 source

-- dbo.PV_R0020 source

CREATE   view [dbo].[PV_R0020_bak21062022] as
SELECT
    iiah.ADJUSTMENT_NO ,
    iiah.COMPANY_CODE,
    pc.COMPANY_DESC ,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    iiah.CRE_BY ,
    ps.FIRST_NAME ,
    CAST(idafh.CRE_DATET as DATE) as REQUEST_DATE,
    CASE
        WHEN iiah.OVERALL_APPROVAL_STATUS IN ('APPROVED') then CAST(iiah.OVERALL_APPROVE_DT as DATE)
        WHEN iiah.OVERALL_APPROVAL_STATUS IN ('REJECTED') then CAST(iiah.OVERALL_APPROVE_DT as DATE)
    end as COMPLETED_DATE,
    CASE
        WHEN iiah.OVERALL_APPROVED_BY IN ('TRAN_VAR_AUTO_APPROVE') then 'Auto Generated'
        else iiah.OVERALL_APPROVAL_STATUS
    END  as STATUS,
    --iiah.OVERALL_APPROVAL_STATUS as STATUS,
    iiad.SKU_CODE as SKU_10,
    LEFT(iiad.SKU_CODE, 6) as SKU_6,
    LEFT(iiad.SKU_CODE, 4) as SKU_4,
    pi2.ITEM_DESC_1 as PRODUCT_DESCRIPTION,
    iiah.ADJ_BALANCE as INVENTORY_BUCKET,
    --ir.REASON_DESCRIPTION as REASON_CODE,
    iiah.reason_code+':'+iiah.reason_desc as REASON_CODE,
    isnull(iiad.ORI_RETAIL_PRICE,0) as SUGGESTED_RETAIL_PRICE,
    CASE
        when iiah.MOVEMENT_TYPE = 'ADD' then iiad.QTY
        else iiad.QTY * -1
    end as ADJ_QTY,
    isnull(sb.AS_OF_QTY,0) as UPDATED_INVENTORY,
    Case
        When iiah.MOVEMENT_TYPE = 'ADD' and iiah.OVERALL_APPROVAL_STATUS = 'APPROVED'  then isnull(sb.AS_OF_QTY,0)- iiad.QTY
        when iiah.MOVEMENT_TYPE = 'DEDUCT' and iiah.OVERALL_APPROVAL_STATUS  = 'APPROVED' then isnull(sb.AS_OF_QTY,0) + iiad.QTY
        ELSE isnull(sb.AS_OF_QTY,0)
    end as PRIOR_INVENTORY,
    isnull(sb.AS_OF_QTY,0)* iiad.ORI_RETAIL_PRICE as UPDATED_VALUE,
    Case
        When iiah.MOVEMENT_TYPE = 'ADD' and iiah.OVERALL_APPROVAL_STATUS = 'APPROVED'  then (isnull(sb.AS_OF_QTY,0)- iiad.QTY) * iiad.ORI_RETAIL_PRICE
        when iiah.MOVEMENT_TYPE = 'DEDUCT' and iiah.OVERALL_APPROVAL_STATUS  = 'APPROVED' then (isnull(sb.AS_OF_QTY,0) + iiad.QTY) * iiad.ORI_RETAIL_PRICE
        ELSE isnull(sb.AS_OF_QTY,0)*iiad.ORI_RETAIL_PRICE
    end as PRIOR_VALUE,
    iiah.REF_STOCKTAKE_NO,
    CASE
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='MAC' THEN 'MO'
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='HKG' THEN 'HK'
        ELSE LEFT(pl.COMPANY_CODE,2)
    END as ENTITY
from IT_INVENTORY_ADJUSTMENT_H iiah
inner join IT_INVENTORY_ADJUSTMENT_D iiad
    on iiah.INVENTORY_ADJ_H_ID = iiad.INVENTORY_ADJ_H_ID_FK
inner join PM_COMPANY pc
    on iiah.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl
    on pl.COMPANY_CODE = iiah.COMPANY_CODE
    and iiah.ADJUST_LOCATION_CODE = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_SKU ps2
    on iiad.COMPANY_CODE = ps2.COMPANY_CODE
    and iiad.SKU_CODE = ps2.SKU_CODE
inner join PM_ITEM pi2
    on ps2.ITEM_ID_FK = pi2.ITEM_ID
    /*left join IM_REASON ir
    on iiah.COMPANY_CODE = ir.COMPANY_CODE
    and iiah.REASON_CODE = ir.SAP_REASON_CODE */
left join IT_DOC_APPROVAL_FLOW_H idafh
    on idafh.COMPANY_CODE = iiah.COMPANY_CODE
    and idafh.DOC_ID = iiah.ADJUSTMENT_NO
    and idafh.DOC_TYPE = 'INVENTORY_ADJUSTMENT'
left join PM_USER pu
    on pu.COMPANY_CODE = iiah.COMPANY_CODE
    and pu.USER_CODE = iiah.CRE_BY
left join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
left join (
    select
        timbd.COMPANY_CODE ,
        timbd.LOCATION_CODE,
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
    where 1 =1
    group by
        timbd.COMPANY_CODE ,
        timbd.LOCATION_CODE,
        timbd.BALANCE_TYPE ,
        timbd.SKU,
        timbd.OPEN_BALANCE_DT,
        timbd.BALANCE
) as sb
    on ps2.COMPANY_CODE = sb.COMPANY_CODE
    and iiah.ADJUST_LOCATION_CODE = sb.LOCATION_CODE
    and iiah.ADJ_BALANCE = sb.BALANCE_TYPE
    and ps2.SKU_CODE = sb.sku;
