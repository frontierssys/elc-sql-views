CREATE   view PV_CLS_SALADY as
select
    pu.COMPANY_CODE as COMPANY_CODE,
    pu.USER_CODE as CODE,
    LEFT(REPLACE( CONCAT( ps.LAST_NAME, ' ', ps.FIRST_NAME), ',', ''),50) as NAME,
    left(pu.STATUS,1) as STS
from PM_USER pu
inner join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
where pu.USER_CODE not in ('it', 'rdiuser')
    and ISNUMERIC(pu.USER_CODE ) > 0
    and pu.COMPANY_CODE in (
        select COMPANY_CODE
        from CLS_BRAND_SCOPE);
