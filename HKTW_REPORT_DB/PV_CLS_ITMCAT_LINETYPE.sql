CREATE    view PV_CLS_ITMCAT_LINETYPE as
select
    COMPANY_CODE ,
    IH_L2 as CODE,
    CASE
        when IH_L2 = '10' then 'SALEABLE'
        when IH_L2 = '32' then 'GIFTS'
        when IH_L2 = '11' then 'PWP'
        when IH_L2 = '30' then 'SAMPLES'
        when IH_L2 = '55' then 'NON-INVENTORIED MATERIALS'
        when IH_L2 = '12' then 'BACKBAR'
        when IH_L2 = '13' then 'SALEABLE PACKAGING'
        ELSE 'UNDEFINED'
    end as 'DESC'
from PM_SKU_ATTR psa
where COMPANY_CODE in (
    select COMPANY_CODE
    from CLS_BRAND_SCOPE) and IH_L2 is not null
group by COMPANY_CODE , IH_L2;
