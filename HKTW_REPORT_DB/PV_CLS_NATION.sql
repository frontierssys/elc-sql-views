CREATE   view PV_CLS_NATION as
select
    pn.COMPANY_CODE ,
    cnm.CLS_CODE as COUNTRY_ID,
    --NAME as DESCRIPTION ,
    --REPLACE(NAME, ',', '') as  DESCRIPTION
    REPLACE(cnm.CLS_NAME , ',', '') as  DESCRIPTION
from PM_NATION pn
left join CLS_NATION_MAPPING cnm
    on cnm.CODE = pn.CODE
where pn.COMPANY_CODE in (
    select COMPANY_CODE
    from CLS_BRAND_SCOPE);
