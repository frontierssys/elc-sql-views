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
