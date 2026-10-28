-- CREATE   view [dbo].[PV_INVENTORY_MOVEMENT] as
-- select
-- pil.COMPANY_CODE ,
-- pil.LOCATION_ID ,
-- pil.SKU_GROUP_CODE ,
-- pil.SKU ,
-- pil.MOVEMENT_DT ,
-- pil.MOVEMENT_DATE ,
-- pil.ORDER_NUMBER ,
-- case
-- --	when pil.ORDER_TYPE in ('SALES') and  pil.MOVEMENT_TYPE not in ('RETURN') THEN 'ONHAND'
-- --	when pil.ORDER_TYPE in ('SALES') and  pil.MOVEMENT_TYPE in ('RETURN') THEN 'RETURN'
-- 	when pil.ORDER_TYPE in ('SALES') THEN 'ONHAND'
-- 	when pil.ORDER_TYPE in ('RETURN') THEN 'RETURN'
-- 	when pil.ORDER_TYPE in ('GIFT') THEN 'GIFT'
-- 	When pil.ORDER_TYPE in ('TESTER') THEN 'TESTER'
-- 	when pil.ORDER_TYPE in ('IN_TRANSIT') THEN 'INTRANSIT'
-- 	when pil.ORDER_TYPE in ('RESERVE') THEN 'RESERVE'
-- 	end as BUCKET_TYPE,
-- pil.MOVEMENT_TYPE ,
-- pil.MOVEMENT_QTY
-- from PL_INVENTORY_LOG pil
-- --where SKU = '20RP010000' and LOCATION_ID = 'HKCM0006';
-- ;
-- dbo.PV_INVENTORY_MOVEMENT_BY_DAY_V2 source

-- CREATE   view [dbo].[PV_INVENTORY_MOVEMENT_BY_DAY_V2] as
-- select
-- coalesce (pib.BALANCE_DT, '2018-01-01') as OPEN_BALANCE_DT,
-- coalesce (pib.BALANCE , 0) as BALANCE,
-- coalesce (pil.COMPANY_CODE, pib.COMPANY_CODE) as COMPANY_CODE ,
-- coalesce (pil.MOVEMENT_DATE , '2018-01-01') as MOVEMENT_DATE ,
-- --coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE , 'ONHAND') as BALANCE_TYPE,
-- coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE ) as BALANCE_TYPE,
-- coalesce (pil.LOCATION_ID , pib.LOCATION_ID ) as LOCATION_CODE,
-- coalesce (pil.SKU , pib.SKU ) as SKU,
-- --pil.MOVEMENT_QTY
-- sum(coalesce (MOVEMENT_QTY,0) ) as MOVEMENT_QTY
-- from
-- 	PL_INVENTORY_LOG pil
-- full outer join PL_INVENTORY_BALANCE pib
-- on pil.COMPANY_CODE = pib.COMPANY_CODE
-- and pil.LOCATION_ID = pib.LOCATION_ID
-- and pil.MOVEMENT_DT >= pib.BALANCE_DT
-- and pil.BALANCE_TYPE = pib.BALANCE_TYPE
-- and pil.SKU = pib.SKU
-- where --len(pib.SKU ) = 10
-- len(coalesce (pil.SKU , pib.SKU ))=10
-- --and (pil.LOCATION_ID  = 'HKOR0027' or pib.LOCATION_ID = 'HKOR0027')
-- --and (pil.SKU ='048E010000' or  pib.SKU = '048E010000')
-- --and pil.MOVEMENT_DATE  <= '2021-04-04'
-- group by
-- coalesce (pib.BALANCE_DT, '2018-01-01') ,
-- coalesce (pib.BALANCE , 0) ,
-- coalesce (pil.COMPANY_CODE, pib.COMPANY_CODE)  ,
-- coalesce (pil.MOVEMENT_DATE , '2018-01-01')  ,
-- coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE ) ,
-- coalesce (pil.LOCATION_ID , pib.LOCATION_ID ) ,
-- coalesce (pil.SKU , pib.SKU )
-- union ALL
-- select
-- pib.BALANCE_DT as OPEN_BALANCE_DT,
-- pib.BALANCE  as BALANCE,
-- pib.COMPANY_CODE as COMPANY_CODE ,
-- pib.BALANCE_DT as MOVEMENT_DATE,
-- --'2000-01-01' as MOVEMENT_DATE ,
-- --coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE , 'ONHAND') as BALANCE_TYPE,
-- pib.BALANCE_TYPE  as BALANCE_TYPE,
-- pib.LOCATION_ID  as LOCATION_CODE,
-- pib.SKU  as SKU,
-- --pil.MOVEMENT_QTY
-- 0 as MOVEMENT_QTY
-- from
-- 	PL_INVENTORY_BALANCE pib
-- where len(pib.SKU ) = 10;
CREATE   view [dbo].[PV_INVENTORY_MOVEMENT_LOG]
--WITH SCHEMABINDING
AS
select
    pc2.company_desc,
    pst.store_type_name,
    pl.location_desc,
    pl.location_code,
    pl.location_name,
    ps.sku_Code,
    concat( pi2.item_desc_1,pi2.item_desc_2) item_desc,
    pi2.item_id,
    pb2.brand_desc,
    pb.bu_desc,
    pd.dept_name,
    psub.subclass_desc,
    pc.class_desc,
    pc.company_code,
    CASE
        when il.ORDER_TYPE = 'SALES'
        then 'OHAND'
        when   il.MOVEMENT_TYPE = 'ONHAND'
        then
            case
                when il.ORDER_TYPE = 'ASN_RECEIVE'
                    or  il.ORDER_TYPE = 'RTW'
                    or  il.ORDER_TYPE = 'TRANSTER_IN'
                    or  il.ORDER_TYPE = 'TRANSTER_OUT'
                    or  il.ORDER_TYPE = 'ADJUSTMENT'     then 'OHAND'
            end
        when il.ORDER_TYPE = 'RESERVE'
            or  (il.MOVEMENT_TYPE = 'RESERVE' and il.ORDER_TYPE = 'ADJUSTMENT' ) then 'RESERVE'
        when (il.ORDER_TYPE = 'RTW' and il.MOVEMENT_TYPE = 'RETURN')
            or (il.ORDER_TYPE = 'RETURN' and il.MOVEMENT_TYPE = 'RETURN_FROM_CUSTOMER')
            or (il.ORDER_TYPE = 'ADJUSTMENT' and il.MOVEMENT_TYPE = 'RETURN') then 'RETURN'
        when (il.ORDER_TYPE = 'ASN_RECEIVE' and il.MOVEMENT_TYPE = 'GIFT')
            or (il.ORDER_TYPE= 'ADJUSTMENT' and il.MOVEMENT_TYPE  = 'GIFT' ) then 'GIFT'
        when (il.ORDER_TYPE = 'ASN_RECEIVE' and il.MOVEMENT_TYPE = 'TESTER')
            or (il.ORDER_TYPE = 'ADJUSTMENT' and il.MOVEMENT_TYPE  = 'TESTER' ) then 'TESTER'
        when (il.ORDER_TYPE = 'TRANSFER_IN' and il.MOVEMENT_TYPE = 'IN_TRANSIT')
            or (il.ORDER_TYPE = 'TRANSFER_OUT' and il.MOVEMENT_TYPE  = 'IN_TRANSIT' ) then 'IN_TRANSIT'
        else 'NA'
    end as inventory_bucket,
    case
        when il.ORDER_TYPE = 'SALES' or il.ORDER_TYPE = 'RESERVE' then 'SALES'
        when il.ORDER_TYPE = 'ASN_RECEIVE' then 'RECEIVING'
        when il.ORDER_TYPE = 'RTW' then 'RTW'
        when il.ORDER_TYPE = 'RETURN' then 'RETURN'
        when il.ORDER_TYPE = 'TRANSTER_IN' then 'TRASFET_IN'
        when il.ORDER_TYPE = 'TRANSTER_OUT' then 'TRASFET_OUT'
        when il.ORDER_TYPE = 'ADJUSTMENT' then 'ADJUSTMENT'
        else 'NA'
    end as movement_Type,
    CONVERT(varchar(10), il.movement_dt, 126) as movement_DATE,
    SUM(il.movement_qty) qty,
    count_big(*) c
from dbo.PL_INVENTORY_LOG il, dbo.PM_LOCATION pl, dbo.PM_ITEM pi2
left join dbo.PM_SUBCLASS psub on psub.subclass_id = pi2.subclass_id_fk
    , dbo.PM_ITEM_ATTR pia, dbo.PM_SKU ps, dbo.pm_sku_attr psa,
    dbo.PM_CLASS pc, dbo.PM_BU pb, dbo.PM_BRAND pb2, dbo.PM_DEPT pd, dbo.PM_COMPANY pc2, dbo.PM_STORE_TYPE pst, dbo.PR_POS_REPORT_SUP pprs
where
    il.LOCATION_ID = pl.LOCATION_CODE
    and il.COMPANY_CODE = pl.COMPANY_CODE
    and il.SKU = ps.SKU_CODE
    and il.COMPANY_CODE = ps.COMPANY_CODE
    and pb.BU_CODE = pi2.BUSINESS_UNIT_CODE
    and pb.COMPANY_CODE  = pi2.COMPANY_CODE
    and pd.dept_code = pi2.dept_code
    and pd.company_code =pi2.company_code
    and pc.class_id = pi2.class_id_fk
    and pb2.brand_id = pi2.brand_id_fk
    and pi2.ITEM_ATTR_ID_FK = pia.ITEM_ATTR_ID
    and pi2.item_id = ps.item_id_fk
    and pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
    and pc2.COMPANY_CODE = il.COMPANY_CODE
    and psa.sku_attr_id = ps.sku_attr_id_fk
    and pia.IS_PLASTIC_BAG = 'N'
    and il.MOVEMENT_DT > pprs.MV_DT
group by
    CASE
        when il.ORDER_TYPE = 'SALES'
        then 'OHAND'
        when   il.MOVEMENT_TYPE = 'ONHAND'
        then
            case
                when il.ORDER_TYPE = 'ASN_RECEIVE'
                    or  il.ORDER_TYPE = 'RTW'
                    or  il.ORDER_TYPE = 'TRANSTER_IN'
                    or  il.ORDER_TYPE = 'TRANSTER_OUT'
                    or  il.ORDER_TYPE = 'ADJUSTMENT'     then 'OHAND'
            end
        when il.ORDER_TYPE = 'RESERVE'
            or  (il.MOVEMENT_TYPE = 'RESERVE' and il.ORDER_TYPE = 'ADJUSTMENT' ) then 'RESERVE'
        when (il.ORDER_TYPE = 'RTW' and il.MOVEMENT_TYPE = 'RETURN')
            or (il.ORDER_TYPE = 'RETURN' and il.MOVEMENT_TYPE = 'RETURN_FROM_CUSTOMER')
            or (il.ORDER_TYPE = 'ADJUSTMENT' and il.MOVEMENT_TYPE = 'RETURN') then 'RETURN'
        when (il.ORDER_TYPE = 'ASN_RECEIVE' and il.MOVEMENT_TYPE = 'GIFT')
            or (il.ORDER_TYPE= 'ADJUSTMENT' and il.MOVEMENT_TYPE  = 'GIFT' ) then 'GIFT'
        when (il.ORDER_TYPE = 'ASN_RECEIVE' and il.MOVEMENT_TYPE = 'TESTER')
            or (il.ORDER_TYPE = 'ADJUSTMENT' and il.MOVEMENT_TYPE  = 'TESTER' ) then 'TESTER'
        when (il.ORDER_TYPE = 'TRANSFER_IN' and il.MOVEMENT_TYPE = 'IN_TRANSIT')
            or (il.ORDER_TYPE = 'TRANSFER_OUT' and il.MOVEMENT_TYPE  = 'IN_TRANSIT' ) then 'IN_TRANSIT'
        else 'NA'
    end ,
    case
        when il.ORDER_TYPE = 'SALES' or il.ORDER_TYPE = 'RESERVE' then 'SALES'
        when il.ORDER_TYPE = 'ASN_RECEIVE' then 'RECEIVING'
        when il.ORDER_TYPE = 'RTW' then 'RTW'
        when il.ORDER_TYPE = 'RETURN' then 'RETURN'
        when il.ORDER_TYPE = 'TRANSTER_IN' then 'TRASFET_IN'
        when il.ORDER_TYPE = 'TRANSTER_OUT' then 'TRASFET_OUT'
        when il.ORDER_TYPE = 'ADJUSTMENT' then 'ADJUSTMENT'
        else 'NA'
    end ,
    CONVERT(varchar(10), il.movement_dt, 126),
    pc2.company_desc,
    pst.store_type_name,
    pl.location_desc,
    pl.location_code,
    pl.location_name,
    ps.sku_Code,
    concat( pi2.item_desc_1,pi2.item_desc_2) ,
    pi2.item_id,
    pb2.brand_desc,
    pb.bu_desc,
    pd.dept_name,
    psub.subclass_desc,
    pc.company_code,
    pc.class_desc
union
    (
        select piml.company_desc, piml.store_type_name, piml.location_desc, piml.location_code, piml.location_name,
            piml.sku_Code, piml.item_desc, piml.item_id, piml.brand_desc, piml.bu_desc, piml.dept_name, piml.class_desc, piml.company_code,
            piml.inventory_bucket, piml.movement_Type, piml.movement_DATE, piml.qty, psub.subclass_desc , piml.c
        from dbo.PMV_INVENTORY_MOVEMENT_LOG piml
        left join dbo.PM_SUBCLASS psub on psub.subclass_id = piml.subclass_id_fk
    )
