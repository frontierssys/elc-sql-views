-- dbo.PMV_INVENTORY_MOVEMENT_BY_DAY source

CREATE     view [dbo].[PMV_INVENTORY_MOVEMENT_BY_DAY]
as
SELECT
    pil.COMPANY_CODE ,
    pil.LOCATION_ID ,
    CAST (pil.MOVEMENT_DT as Date) as MOVEMENT_DT ,
    pil.MOVEMENT_TYPE,
    pil.ORDER_TYPE ,
    pil.ORDER_NUMBER,
    pil.SKU ,
    pil.MOVEMENT_QTY ,
    Case
        when substring(pil.ORDER_NUMBER , 9,2) = 'BT' then 'ADJUSTMENT'
        when substring(pil.ORDER_NUMBER , 9,2) = 'TR' and pil.MOVEMENT_QTY < 0 then 'TRANSFER_OUT'
        when substring(pil.ORDER_NUMBER , 9,2) = 'TR' and pil.MOVEMENT_QTY >= 0 then 'TRANSFER_IN'
        when substring(pil.ORDER_NUMBER , 9,2) = 'IA' then 'ADJUSTMENT'
        when substring(pil.ORDER_NUMBER , 9,2) = 'AR' then 'ASN'
        when substring(pil.ORDER_NUMBER , 9,2) = 'RW' then 'RTW'
        when pil.ORDER_TYPE = 'GIFT' then 'SALES'
        when pil.MOVEMENT_TYPE = 'RETURN' then 'RETURN'
        ELSE pil.ORDER_TYPE
    END as TRANS_TYPE,
    --Case when pil.MOVEMENT_TYPE in ('SALES', 'ONHAND') then 'ONHAND'
    --when pil.MOVEMENT_TYPE in ('RETURN', 'RETURN_FROM_CUSTOMER') then 'RETURN'
    --when pil.MOVEMENT_TYPE in ('GIFT_ISSUE', 'GIFT') then 'GIFT'
    --when pil.MOVEMENT_TYPE in ('TESTER') then 'TESTER'
    --END as BUCKET
    pil.BALANCE_TYPE as BUCKET
FROM
    PL_INVENTORY_LOG pil
where pil.MOVEMENT_TYPE not in ('IN_TRANSIT', 'RESERVE', 'RESERVE_RELEASE')
--and SKU = '20RP010000';
