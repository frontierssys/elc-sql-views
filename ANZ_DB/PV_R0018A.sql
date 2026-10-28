CREATE   VIEW PV_R0018A AS (
-- modified by rmohamed on 2025-03-07
-- Key change: added 2 Union to current selection
-- 1st part: Target Sales Related from PT_SALES_MEMO
-- 2nd part: Target BOM Related in PL_INVENTORY_LOG
-- 3rd part: Target Non Sales and Non BOM Related
-- PT_SALES_MEMO_SECTION
    SELECT
        LEFT(pil.COMPANY_CODE,2) as AFFILIATE_CODE,
        pil.COMPANY_CODE ,
        pil.LOCATION_ID ,
        pil.MOVEMENT_TYPE,
        pil.ORDER_TYPE ,
        pil.ORDER_NUMBER,
        ppcs.CHILD_SKU as SKU,
        psd.PRODUCT_NAME as SKU_DESC,
        pil.MOVEMENT_QTY,
        psd.RETAIL_PRICE ,
        COALESCE (pu.NAME, pil.CRE_BY) as CRE_BY,
        pil.MOVEMENT_DT,
        Case
            when pil.ORDER_TYPE = 'GIFT' then 'SALES'
            when pil.MOVEMENT_TYPE = 'RETURN' then 'RETURN'
            ELSE pil.ORDER_TYPE
        END as TRANS_TYPE,
        pil.BALANCE_TYPE as BUCKET,
        psa.DEFAULT_UOM_CODE as UOM,
        pil.ORDER_NUMBER as MEMO_NO,
        ppcs.PARENT_SKU as PARENT_SKU,
        ppcs.PARENT_PRODUCT_NAME as PRODUCT_NAME
    FROM PT_SALES_MEMO psm
    LEFT JOIN PT_SALES_MEMO_ITEM_H psmih on
        psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
    LEFT JOIN PV_PARENT_CHILD_SKU ppcs on
        ppcs.PARENT_SKU = psmih.SKU
        AND ppcs.COMPANY_CODE = psmih.COMPANY_CODE
    LEFT JOIN PL_INVENTORY_LOG pil on
        psm.MEMO_NO = pil.ORDER_NUMBER
        and pil.SKU = ppcs.CHILD_SKU
        and psmih.SKU = ppcs.PARENT_SKU
    left join PV_SKU_DETAIL psd on
        psd.COMPANY_CODE = ppcs.COMPANY_CODE
        and psd.SKU_10 = ppcs.CHILD_SKU
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
    GROUP BY
        LEFT(pil.COMPANY_CODE,2),
        pil.LOG_NO,
        pil.COMPANY_CODE ,
        pil.LOCATION_ID ,
        pil.MOVEMENT_TYPE,
        pil.ORDER_TYPE ,
        pil.ORDER_NUMBER,
        ppcs.CHILD_SKU,
        psd.PRODUCT_NAME,
        pil.MOVEMENT_QTY,
        psd.RETAIL_PRICE,
        COALESCE (pu.NAME, pil.CRE_BY),
        pil.MOVEMENT_DT,
        pil.BALANCE_TYPE,
        psa.DEFAULT_UOM_CODE,
        ppcs.PARENT_SKU,
        ppcs.PARENT_PRODUCT_NAME
        -- PL_INVENTORY_LOG FOR BOM SECTION
    UNION ALL
    SELECT
        LEFT(pil.COMPANY_CODE,
            2) as AFFILIATE_CODE,
        pil.COMPANY_CODE ,
        pil.LOCATION_ID ,
        pil.MOVEMENT_TYPE,
        pil.ORDER_TYPE ,
        pil.ORDER_NUMBER,
        isNULL(pbid.SKU_CODE, pil.SKU) as SKU ,
        psd.PRODUCT_NAME as SKU_DESC,
        CASE
            WHEN pbid.SKU_CODE is NULL then pil.MOVEMENT_QTY
            ELSE pbid.QTY * pil.MOVEMENT_QTY
        END AS MOVEMENT_QTY,
        psd.RETAIL_PRICE ,
        COALESCE (pu.NAME,
            pil.CRE_BY) as CRE_BY,
        pil.MOVEMENT_DT,
        /*For HKTW. All of their location code is 8 in length. So this logic can persists.*/
        /*
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
        --*/
        /*
        * For others. Location code length varied. Hence, checking if the flag exists only.
        * Also note that if at any point we have <companycode>AR as order number, please refactor this section.
        */
        -- /*
        Case
            when CHARINDEX('BT', pil.ORDER_NUMBER) > 0 then 'ADJUSTMENT'
            when CHARINDEX('TR', pil.ORDER_NUMBER) > 0
                and pil.MOVEMENT_QTY < 0 then 'TRANSFER_OUT'
            when CHARINDEX('TR', pil.ORDER_NUMBER) > 0
                and pil.MOVEMENT_QTY >= 0 then 'TRANSFER_IN'
            when CHARINDEX('IA', pil.ORDER_NUMBER) > 0 then 'ADJUSTMENT'
            when CHARINDEX('AR', pil.ORDER_NUMBER) > 0 then 'ASN'
            when CHARINDEX('RW', pil.ORDER_NUMBER) > 0 then 'RTW'
            when pil.ORDER_TYPE = 'GIFT' then 'SALES'
            when pil.MOVEMENT_TYPE = 'RETURN' then 'RETURN'
            ELSE pil.ORDER_TYPE
        END as TRANS_TYPE,
        --*/
        pil.BALANCE_TYPE as BUCKET,
        psa.DEFAULT_UOM_CODE as UOM,
        pil.ORDER_NUMBER as MEMO_NO,
        isNULL(pbih.SKU_CODE, pil.SKU) as PARENT_SKU,
        parentSku.SKU_DESC as PRODUCT_NAME
    FROM PL_INVENTORY_LOG pil
    LEFT JOIN PM_BOM_ITEM_H pbih on pbih.SKU_CODE = pil.SKU AND pil.COMPANY_CODE = pbih.COMPANY_CODE
    LEFT JOIN PM_BOM_ITEM_D pbid on pbih.BOM_ITEM_H_ID = pbid.BOM_ITEM_H_ID_FK
    left join PV_SKU_DETAIL psd on
        psd.COMPANY_CODE = pil.COMPANY_CODE
        and psd.SKU_10 = pbid.SKU_CODE
    LEFT JOIN PV_SKU_DETAIL psdParent on
        psd.COMPANY_CODE = pil.COMPANY_CODE
        and psd.SKU_10 = pil.SKU
    left join PM_USER pu on
        pu.COMPANY_CODE = pil.COMPANY_CODE
        and pu.NAME = pil.CRE_BY
    LEFT JOIN PM_SKU parentSKU on parentSKU.sku_code = pbih.SKU_CODE and pbih.COMPANY_CODE = parentSku.company_code
    LEFT join PM_SKU ps21 on
        pil.COMPANY_CODE = ps21.COMPANY_CODE
        and pbid.SKU_CODE = ps21.SKU_CODE
    LEFT join PM_SKU_ATTR psa on
        pil.COMPANY_CODE = psa.COMPANY_CODE
        and psa.SKU_ATTR_ID = ps21.SKU_ATTR_ID_FK
    where
        pil.MOVEMENT_TYPE not in ('IN_TRANSIT', 'RESERVE', 'RESERVE_RELEASE')
        AND pbid.SKU_CODE is not NULL
        ---- Non Sales and Non BOM section
    UNION ALL
    SELECT
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
        /*For HKTW. All of their location code is 8 in length. So this logic can persists.*/
        /*
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
        -- */
        /*
         * For others. Location code length varied. Hence, checking if the flag exists only.
         * Also note that if at any point we have <companycode>AR as order number, please refactor this section.
         */
         -- /*
        Case
            when CHARINDEX('BT', pil.ORDER_NUMBER) > 0 then 'ADJUSTMENT'
            when CHARINDEX('TR', pil.ORDER_NUMBER) > 0
                and pil.MOVEMENT_QTY < 0 then 'TRANSFER_OUT'
            when CHARINDEX('TR', pil.ORDER_NUMBER) > 0
                and pil.MOVEMENT_QTY >= 0 then 'TRANSFER_IN'
            when CHARINDEX('IA', pil.ORDER_NUMBER) > 0 then 'ADJUSTMENT'
            when CHARINDEX('AR', pil.ORDER_NUMBER) > 0 then 'ASN'
            when CHARINDEX('RW', pil.ORDER_NUMBER) > 0 then 'RTW'
            when pil.ORDER_TYPE = 'GIFT' then 'SALES'
            when pil.MOVEMENT_TYPE = 'RETURN' then 'RETURN'
            ELSE pil.ORDER_TYPE
        END as TRANS_TYPE,
        -- */
        pil.BALANCE_TYPE as BUCKET,
        psa.DEFAULT_UOM_CODE as UOM,
        pil.ORDER_NUMBER as MEMO_NO,
        ps21.SKU_CODE as PARENT_SKU,
        ps21.SKU_DESC as PRODUCT_NAME
    FROM
        PL_INVENTORY_LOG pil
    LEFT JOIN PT_SALES_MEMO psm on
        psm.MEMO_NO = pil.ORDER_NUMBER
    LEFT JOIN PT_SALES_MEMO_ITEM_H psmih on
        psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
    LEFT JOIN PM_BOM_ITEM_H pbih on
        pbih.SKU_CODE = pil.SKU
        and pbih.COMPANY_CODE = pil.COMPANY_CODE
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
        -- Filter out PT_SALES_MEMO and BOM item
        AND pbih.BOM_ITEM_H_ID is NULL
        AND psm.SALES_MEMO_ID is NULL
);
