-- dbo.PV_R9002 source

create   view [dbo].[PV_R9002] as
select
    fss.COMPANY_CODE ,
    fss.TX_DATE,
    fss.LOCATION_CODE ,
    fss.LOCATION_DESC ,
    fss.NUMBER_FSS_ORDER_PLACED ,
    fss.VALUE_FSS_ORDER_PLACED ,
    bopis.NUMBER_BOPIS_ORDER_PLACED ,
    bopis.VALUE_BOPIS_ORDER_PLACED ,
    oofis.NUMBER_OOFIS_ORDER_PLACED ,
    oofis.VALUE_OOFIS_ORDER_PLACED
    , bopis_delivery.NUMBER_BOPIS_ORDER_PLACED as NUMBER_BOPIS_DELIVERY_ORDER_PLACED,
    bopis_delivery.VALUE_BOPIS_ORDER_PLACED as VALUE_BOPIS_DELIVERY_ORDER_PLACED
    ,bopis_delivery.DELIVERY_OR_PICKUP
from PV_R9002_FSS fss
FULL outer join PV_R9002_BOPIS_GROUPED bopis
    on fss.COMPANY_CODE = bopis.COMPANY_CODE
    and fss.TX_DATE = bopis.TX_DATE
    and fss.LOCATION_CODE = bopis.LOCATION_CODE
    --and bopis.DELIVERY_OR_PICKUP = 'Pickup'
FULL outer join PV_R9002_BOPIS bopis_delivery
    on fss.COMPANY_CODE = bopis_delivery.COMPANY_CODE
    and fss.TX_DATE = bopis_delivery.TX_DATE
    and fss.LOCATION_CODE = bopis_delivery.LOCATION_CODE
    and bopis_delivery.DELIVERY_OR_PICKUP = 'Delivery'
FULL outer join PV_R9002_OOFIS oofis
    on fss.COMPANY_CODE = oofis.COMPANY_CODE
    and fss.TX_DATE = oofis.TX_DATE
    and fss.LOCATION_CODE = oofis.LOCATION_CODE
    --where fss.TX_DATE >= '2021-12-01' and fss.COMPANY_CODE in ('HKEL', 'HKMC')
    --where fss.COMPANY_CODE = 'HKCS'and fss.TX_DATE = '2022-11-09';
