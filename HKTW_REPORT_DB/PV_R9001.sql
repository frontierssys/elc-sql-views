create   view PV_R9001 as
select
    psm.COMPANY_CODE ,
    psm.TX_DATE,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    pst.STORE_TYPE_NAME as STORE_TYPE,
    psmt.TYPE_DESC as ORDER_TYPE,
    isnull(bopis.BOPIS_ORDER_STATUS , oofis.OOFIS_STATUS ) as ORDER_STATUS,
    bopis.REASON_CODE as BOPIS_ORDER_REASON_CODE,
    isnull(bopis.TRANS_ID , psm.POS_MEMO_NO ) as ORDER_ID,
    psm.TX_DATE as ORDER_PLACED_DATE,
    CASE
        when bopis.SALES_MEMO_BOPIS_INFO_ID is not null and bopis.BOPIS_ORDER_STATUS in ('COLLECTED', 'REJECTED', 'ABANDONED') then convert(date,  bopis.STATUS_CHG_DATE )
        when oofis.SALES_MEMO_OOFIS_INFO_ID is not null and oofis.OOFIS_STATUS in ('Shipped', 'Cancelled') then convert(date,  oofis.STATUS_SYNC_DATE )
        else null
    end as ORDER_CLOSE_DATE,
    psmih.SKU as MATERIAL_CODE,
    ps.PRODUCT_NAME as PRODUCT_DESCRIPTION,
    --ps.RETAIL_PRICE ,
    psmih.ORG_RETAIL_PRICE as RETAIL_PRICE,
    psmih.NET_LINE_AMT / psmih.QTY as SELLING_PRICE,
    psmih.QTY ,
    psmih.NET_LINE_AMT as SALES_VALUE,
    'N' as FROM_UPSELL,
    CASE
        when bopis.PROXY_FIRST_NAME = 'SF Express' then 'Delivery'
        else 'Pickup'
    end as DELIVERY_OR_PICKUP
from PT_SALES_MEMO psm
inner join PM_SALES_MEMO_TYPE psmt
    on psmt.SALES_MEMO_TYPE_ID = psm.SALES_MEMO_TYPE_ID_FK
inner join PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PT_SALES_MEMO_ITEM_H psmih
    on psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
left join PV_SKU_DETAIL_NOPRICE ps
    on psmih.COMPANY_CODE = ps.COMPANY_CODE
    and psmih.SKU  = ps.SKU_10
left join PT_SALES_MEMO_BOPIS_INFO bopis
    on psm.SALES_MEMO_BOPIS_INFO_ID_FK = bopis.SALES_MEMO_BOPIS_INFO_ID
left join PT_SALES_MEMO_OOFIS_INFO oofis
    on oofis.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
where psmt.TYPE_CODE in ('12','14')
    and psm.COMPANY_CODE = 'HKCS' and psm.TX_DATE >= '2022-10-01'
