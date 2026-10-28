CREATE   view [dbo].[PV_OPENBAL_EXTRACT] as
select
    timbd.COMPANY_CODE ,
    timbd.LOCATION_ID,
    timbd.BALANCE_TYPE as BUCKET ,
    timbd.SKU,
    timbd.BALANCE_DT,
    timbd.BALANCE
from
    PL_INVENTORY_BALANCE timbd
inner join
    (
        select
            a.COMPANY_CODE  , a.LOCATION_ID, a.BALANCE_TYPE , a.SKU, max(a.BALANCE_DT) MAX_BALANCE_DT
        from
            PL_INVENTORY_BALANCE a
        group by
            a.COMPANY_CODE  , a.LOCATION_ID, a.BALANCE_TYPE , a.SKU
    ) inv
    on timbd.COMPANY_CODE = inv.COMPANY_CODE
    and timbd.LOCATION_ID = inv.LOCATION_ID
    and timbd.BALANCE_TYPE = inv.BALANCE_TYPE
    and timbd.SKU = inv.SKU
    and timbd.BALANCE_DT = inv.MAX_BALANCE_DT
where 1 =1
--and timbd.LOCATION_ID='HKMC0002'
    and len(timbd.SKU) =10
    /*and ((timbd.MOVEMENT_DATE <='2021-03-23' and timbd.LOCATION_CODE='HKMC0002')
    OR (timbd.MOVEMENT_DATE <='2021-03-17' and timbd.LOCATION_CODE='HKBB0017'))*/
group by
    timbd.COMPANY_CODE ,
    timbd.LOCATION_ID,
    timbd.BALANCE_TYPE ,
    timbd.SKU,
    timbd.BALANCE_DT,
    timbd.BALANCE
