CREATE   VIEW  PV_CLS_ITMCAT_L2 as
select
    distinct psa.COMPANY_CODE ,
    CASE
        when charindex('-', psa.LH_L2) > 0 then left(psa.LH_L2, charindex('-', psa.LH_L2) - 1)
        else psa.LH_L2
    end as ITCAT_L2_CODE,
    --psa.LH_L2 as ITCAT_L2_DESC
    LEFT(REPLACE( LH_L2 , ',', ''),50) as ITCAT_L2_DESC
from
    PM_SKU_ATTR psa
where psa.LH_L2 is not null and psa.LH_L2  <> ''
--union all
--select 'NIL3' as ITCAT_L2_CODE,
--'NIL3-NIL3' as ITCAT_L2_DESC;


-- dbo.PV_CLS_ITMCAT_L3 source
