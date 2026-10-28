-- dbo.PV_R0055 source

CREATE   view [dbo].[PV_R0055] as
select
    psm.COMPANY_CODE,
    pst.STORE_TYPE_CODE as STORE_TYPE,
    --pl.ADDRESS1 + pl.ADDRESS2 + pl.ADDRESS3 as STORE_LOCATION,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_CODE as LOCATION_CODE,
    pl.LOCATION_NAME as STORE_NAME,
    isnull(psm.CASHIER_CODE, psm.CRE_BY ) as ORIGINAL_CASHIER_ID,
    isnull(ps_cashier.FIRST_NAME + ' ' + ps_cashier.LAST_NAME , ps_cre.FIRST_NAME + ' ' + ps_cre.LAST_NAME ) as ORIGINAL_CASHIER_NAME,
    ps3.STAFF_CODE as ORIGINAL_COMMISSIONED_ID,
    ps3.FIRST_NAME + ' '+  ps3.LAST_NAME as ORGINAL_COMMISSIONED_NAME,
    psm.MEMO_NO as ORIGINAL_TRANSACTION_ID,
    CAST(psm.TX_DT as date) as ORIGINAL_SALES_DATE,
    CAST(psm.TX_DT as time) as ORIGINAL_SALES_TIME,
    psm.TOTAL_NET_AMT as ORIGINAL_TRANSACTION_AMOUNT,
    pstbt.TENDERS as ORIGINAL_TRANSACTION_TENDER,
    psd.SKU_10 ,
    psd.SKU_6 ,
    psd.SKU_4 ,
    psd.PRODUCT_BRAND as ORIGINAL_SUB_BRAND,
    psd.PRODUCT_NAME as ORIGINAL_MATERIAL_DESC,
    psmih.CUR_RETAIL_PRICE as ORIGINAL_RETAIL_PRICE,
    psmih.QTY as ORIGINAL_QTY_SOLD,
    psmih.CUR_RETAIL_PRICE * psmih.QTY as ORIGINAL_TOTAL_RETAIL_PRICE,
    --(psmih.CUR_RETAIL_PRICE * psmih.QTY - psmih.NET_LINE_AMT)/(psmih.CUR_RETAIL_PRICE * psmih.QTY) * 100 as ORIGINAL_DISCOUNT_PERCENT,
    CASE
        WHEN psmih.CUR_RETAIL_PRICE * psmih.QTY <>0 THEN (psmih.CUR_RETAIL_PRICE * psmih.QTY - psmih.NET_LINE_AMT)/(psmih.CUR_RETAIL_PRICE * psmih.QTY) * 100
        ELSE psmih.CUR_RETAIL_PRICE * psmih.QTY
    END as ORIGINAL_DISCOUNT_PERCENT,
    psmih.CUR_RETAIL_PRICE * psmih.QTY - psmih.NET_LINE_AMT as ORIGINAL_DISCOUNT_AMT,
    psm.VIP_NO as ORIGINAL_CUSTOMER_ID,
    --pc.FIRSTNAME + ' ' + pc.SURNAME as ORIGINAL_CUSTOMER_NAME,
    ' ' as ORIGINAL_CUSTOMER_NAME,
    pal.AUTH_BY as POST_VOID_MANAGER_ID,
    ps_auth.FIRST_NAME + ' ' + ps_auth.LAST_NAME as POST_VOID_MANAGER_NAME,
    month(psmv.TX_DT) as POST_VOID_MONTH,
    cast(psmv.TX_DT as date) as POST_VOID_DATE,
    pt.TERMINAL_NO as POST_VOID_TERMINAL_ID ,
    cast(psmv.TX_DT as time) as POST_VOID_TIME,
    psmv.MEMO_NO as POST_VOID_TRANSACTION_ID,
    --psmv.VOID_REASON as POST_VOID_REASON_CODE,
    psmv.VOID_REASON +' '+PR.REASON_DESC as POST_VOID_REASON_CODE,
    psmih.QTY as POST_VOID_QTY,
    psmih.NET_LINE_AMT as POST_VOID_AMT
from
    PT_SALES_MEMO psm
inner join PT_SALES_MEMO_ITEM_H psmih
    on psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
LEFT join dbo.PT_MEMO_ITEM_STAFF_SET pmiss
    on psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
LEFT join dbo.PT_SALES_MEMO_ITEM_STAFF psmis
    on psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
LEFT join dbo.PM_STAFF ps3
    on ps3.COMPANY_CODE = psmis.COMPANY_CODE
    and ps3.STAFF_CODE = psmis.STAFF_NO
inner join PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PT_SALES_MEMO psmv
    on psmv.ORI_SALES_MEMO_ID_PK = psm.SALES_MEMO_ID
inner join PM_TERMINAL pt
    on psmv.TERMINAL_ID_FK = pt.TERMINAL_ID
inner join PL_AUTHORIZATION_LOG pal
    on pal.COMPANY_CODE = psmv.COMPANY_CODE
    and pal.AUTH_REF_NO = psmv.MEMO_NO
    and pal.AUTH_FUNCTION ='authorizeVoidTransaction'
left join PM_USER pu_auth
    on pu_auth.COMPANY_CODE = pal.COMPANY_CODE
    and pu_auth.USER_CODE = pal.AUTH_BY
left join PM_STAFF ps_auth
    on ps_auth.STAFF_ID = pu_auth.STAFF_ID_FK
left join PM_VIP pv
    on psm.COMPANY_CODE = pv.COMPANY_CODE
    and psm.VIP_NO = pv.VIP_NO
left join PM_CUSTOMER pc
    on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
left join PV_SKU_DETAIL psd
    on psd.COMPANY_CODE = psmih.COMPANY_CODE
    and psd.SKU_10 = psmih.SKU
left join PV_SALES_TENDER_BY_TRANSACTION pstbt
    on pstbt.SALES_MEMO_ID = psm.SALES_MEMO_ID
left join PM_USER pu_cashier
    on pu_cashier.COMPANY_CODE = psm.COMPANY_CODE
    and pu_cashier.USER_CODE = psm.CASHIER_CODE
left join PM_STAFF ps_cashier
    on pu_cashier.STAFF_ID_FK = ps_cashier.STAFF_ID
left join PM_USER pu_cre
    on psm.COMPANY_CODE = pu_cre.COMPANY_CODE
    and psm.CRE_BY = pu_cre.USER_CODE
left join PM_STAFF ps_cre
    on ps_cre.STAFF_ID = pu_cre.STAFF_ID_FK
LEFT JOIN PM_REASON PR
    ON PR.COMPANY_CODE=psmv.COMPANY_CODE and PR.REASON_CODE = psmv.VOID_REASON
where psm.MEMO_STATUS = 'VOIDED'
