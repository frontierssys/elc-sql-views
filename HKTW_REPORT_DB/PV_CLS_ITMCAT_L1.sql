CREATE   view PV_CLS_ITMCAT_L1 as
select
    distinct psa.COMPANY_CODE ,
    CASE
        when charindex('-', psa.LH_L1) > 0 then left(psa.LH_L1, charindex('-', psa.LH_L1) - 1)
        else psa.LH_L1
    end as ITCAT_L1_CODE,
    --psa.LH_L1 as ITCAT_L1_DESC
    LEFT(REPLACE( LH_L1 , ',', ''),50) as ITCAT_L1_DESC
from
    PM_SKU_ATTR psa
where psa.LH_L1 is not null and psa.LH_L1  <> ''
    and psa.COMPANY_CODE in (
        select COMPANY_CODE
        from CLS_BRAND_SCOPE)
        --union all
        --select 'NIL2' as ITCAT_L1_CODE,
        --'NIL2-NIL2' as ITCAT_L1_DESC;
