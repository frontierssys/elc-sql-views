CREATE VIEW PV_R0018A_Bak_20250319 AS
SELECT
    DISTINCT
    LEFT(pil.COMPANY_CODE,
        2) as AFFILIATE_CODE,
    pil.COMPANY_CODE ,
    pil.LOCATION_ID ,
    pil.MOVEMENT_TYPE,
    pil.ORDER_TYPE ,
    pil.ORDER_NUMBER,
    pil.SKU ,
    psd.PRODUCT_NAME as SKU_DESC,
    pil.MOVEMENT_QTY ,
    psd.RETAIL_PRICE ,
    COALESCE (pu.NAME,
        pil.CRE_BY) as CRE_BY,
    pil.MOVEMENT_DT,
    Case
        when substring(pil.ORDER_NUMBER , 9, 2) = 'BT' then 'ADJUSTMENT'
        when substring(pil.ORDER_NUMBER , 9, 2) = 'TR'
            and pil.MOVEMENT_QTY < 0 then 'TRANSFER_OUT'
        when substring(pil.ORDER_NUMBER , 9, 2) = 'TR'
            and pil.MOVEMENT_QTY >= 0 then 'TRANSFER_IN'
        when substring(pil.ORDER_NUMBER , 9, 2) = 'IA' then 'ADJUSTMENT'
        when substring(pil.ORDER_NUMBER , 9, 2) = 'AR' then 'ASN'
        when substring(pil.ORDER_NUMBER , 9, 2) = 'RW' then 'RTW'
        when pil.ORDER_TYPE = 'GIFT' then 'SALES'
        when pil.MOVEMENT_TYPE = 'RETURN' then 'RETURN'
        ELSE pil.ORDER_TYPE
    END as TRANS_TYPE,
    pil.BALANCE_TYPE as BUCKET,
    psa.DEFAULT_UOM_CODE as UOM,
    pil.ORDER_NUMBER as MEMO_NO,
    ppcs.PARENT_SKU as PARENT_SKU,
    ppcs.PARENT_PRODUCT_NAME as PRODUCT_NAME
FROM
    PL_INVENTORY_LOG pil
LEFT JOIN PV_PARENT_CHILD_SKU ppcs ON
    ppcs.COMPANY_CODE = pil.COMPANY_CODE
    and ppcs.CHILD_SKU = pil.SKU
JOIN PT_SALES_MEMO psm on
    psm.MEMO_NO = pil.ORDER_NUMBER
JOIN PT_SALES_MEMO_ITEM_H psmih on
    psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
    and psmih.SKU = ppcs.PARENT_SKU
left join PV_SKU_DETAIL psd on
    psd.COMPANY_CODE = pil.COMPANY_CODE
    and psd.SKU_10 = pil.SKU
left join PM_USER pu on
    pu.COMPANY_CODE = pil.COMPANY_CODE
    and pu.NAME = pil.CRE_BY
LEFT join PM_SKU ps21 on
    pil.COMPANY_CODE = ps21.COMPANY_CODE
    and pil.SKU = ps21.SKU_CODE
LEFT join PM_SKU_ATTR psa on
    pil.COMPANY_CODE = psa.COMPANY_CODE
    and psa.SKU_ATTR_ID = ps21.SKU_ATTR_ID_FK
where
    pil.MOVEMENT_TYPE not in ('IN_TRANSIT', 'RESERVE', 'RESERVE_RELEASE')
