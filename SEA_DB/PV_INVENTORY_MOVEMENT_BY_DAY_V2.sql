-- dbo.PV_INVENTORY_MOVEMENT_BY_DAY_V2 source

CREATE   view [dbo].[PV_INVENTORY_MOVEMENT_BY_DAY_V2] as
select
    coalesce (pib.BALANCE_DT, '2018-01-01') as OPEN_BALANCE_DT,
    coalesce (pib.BALANCE , 0) as BALANCE,
    coalesce (pil.COMPANY_CODE, pib.COMPANY_CODE) as COMPANY_CODE ,
    coalesce (pil.MOVEMENT_DATE , '2018-01-01') as MOVEMENT_DATE ,
    --coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE , 'ONHAND') as BALANCE_TYPE,
    coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE ) as BALANCE_TYPE,
    coalesce (pil.LOCATION_ID , pib.LOCATION_ID ) as LOCATION_CODE,
    coalesce (pil.SKU , pib.SKU ) as SKU,
    --pil.MOVEMENT_QTY
    sum(coalesce (MOVEMENT_QTY,0) ) as MOVEMENT_QTY
from
    PL_INVENTORY_LOG pil
full outer join PL_INVENTORY_BALANCE pib
    on pil.COMPANY_CODE = pib.COMPANY_CODE
    and pil.LOCATION_ID = pib.LOCATION_ID
    and pil.MOVEMENT_DT >= pib.BALANCE_DT
    and pil.BALANCE_TYPE = pib.BALANCE_TYPE
    and pil.SKU = pib.SKU
where --len(pib.SKU ) = 10
    len(coalesce (pil.SKU , pib.SKU ))=10
    --and (pil.LOCATION_ID  = 'HKOR0027' or pib.LOCATION_ID = 'HKOR0027')
    --and (pil.SKU ='048E010000' or  pib.SKU = '048E010000')
    --and pil.MOVEMENT_DATE  <= '2021-04-04'
group by
    coalesce (pib.BALANCE_DT, '2018-01-01') ,
    coalesce (pib.BALANCE , 0) ,
    coalesce (pil.COMPANY_CODE, pib.COMPANY_CODE)  ,
    coalesce (pil.MOVEMENT_DATE , '2018-01-01')  ,
    coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE ) ,
    coalesce (pil.LOCATION_ID , pib.LOCATION_ID ) ,
    coalesce (pil.SKU , pib.SKU )
union ALL
select
    pib.BALANCE_DT as OPEN_BALANCE_DT,
    pib.BALANCE  as BALANCE,
    pib.COMPANY_CODE as COMPANY_CODE ,
    pib.BALANCE_DT as MOVEMENT_DATE,
    --'2000-01-01' as MOVEMENT_DATE ,
    --coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE , 'ONHAND') as BALANCE_TYPE,
    pib.BALANCE_TYPE  as BALANCE_TYPE,
    pib.LOCATION_ID  as LOCATION_CODE,
    pib.SKU  as SKU,
    --pil.MOVEMENT_QTY
    0 as MOVEMENT_QTY
from
    PL_INVENTORY_BALANCE pib
where len(pib.SKU ) = 10
