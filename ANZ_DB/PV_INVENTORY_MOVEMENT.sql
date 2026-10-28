CREATE   VIEW  PV_INVENTORY_MOVEMENT as
select
    pil.COMPANY_CODE ,
    pil.LOCATION_ID ,
    pil.SKU_GROUP_CODE ,
    pil.SKU ,
    pil.MOVEMENT_DT ,
    pil.MOVEMENT_DATE ,
    pil.ORDER_NUMBER ,
    case
    --	when pil.ORDER_TYPE in ('SALES') and  pil.MOVEMENT_TYPE not in ('RETURN') THEN 'ONHAND'
    --	when pil.ORDER_TYPE in ('SALES') and  pil.MOVEMENT_TYPE in ('RETURN') THEN 'RETURN'
        when pil.ORDER_TYPE in ('SALES') THEN 'ONHAND'
        when pil.ORDER_TYPE in ('RETURN') THEN 'RETURN'
        when pil.ORDER_TYPE in ('GIFT') THEN 'GIFT'
        When pil.ORDER_TYPE in ('TESTER') THEN 'TESTER'
        when pil.ORDER_TYPE in ('IN_TRANSIT') THEN 'INTRANSIT'
        when pil.ORDER_TYPE in ('RESERVE') THEN 'RESERVE'
    end as BUCKET_TYPE,
    pil.MOVEMENT_TYPE ,
    pil.MOVEMENT_QTY
from PL_INVENTORY_LOG pil
--where SKU = '20RP010000' and LOCATION_ID = 'HKCM0006';


-- dbo.PV_INVENTORY_BY_DAY source
