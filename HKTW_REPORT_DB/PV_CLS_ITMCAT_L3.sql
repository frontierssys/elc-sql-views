CREATE   view PV_CLS_ITMCAT_L3 as
select
    distinct psa.COMPANY_CODE ,
    CASE
        when charindex('-', psa.LH_L3) > 0 then left(psa.LH_L3, charindex('-', psa.LH_L3) - 1)
        else psa.LH_L3
    end as ITCAT_L3_CODE,
    --psa.LH_L3 as ITCAT_L3_DESC
    LEFT(REPLACE( LH_L3 , ',', ''),50) as ITCAT_L3_DESC
from
    PM_SKU_ATTR psa
where psa.LH_L3 is not null and psa.LH_L3  <> ''
    and psa.COMPANY_CODE in (
        select COMPANY_CODE
        from CLS_BRAND_SCOPE)
        --union all
        --select 'NIL4' as ITCAT_L3_CODE,
        --'NIL4-NIL4' as ITCAT_L3_DESC;
