CREATE   view PV_CLS_LOCTAB as
select
    pl.LOCATION_CODE as CODE,
    --pl.LOCATION_NAME as NAME,
    REPLACE(pl.LOCATION_NAME , ',', '') as NAME ,
    pl.LOCATION_CODE as AS400,
    pl.RET_HIERARCHY_CODE as GRP,
    pst.STORE_TYPE_NAME as STORE_TYPE,
    pl.CITY_TXT as DISTRICT,
    case
        when pl.ACTIVE = 'Y' then 'Open'
        else 'Closed'
    end as STS
from PM_LOCATION pl
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
where pl.COMPANY_CODE in (
    select COMPANY_CODE
    from CLS_BRAND_SCOPE);
