CREATE    view PV_CLS_IMCAT_CAT as
select COMPANY_CODE, BU_CODE ,
    BU_CODE +'-'+  REPLACE( BU_DESC , ',', '') as BU_DESC
from PM_BU pb
where COMPANY_CODE in (
    select COMPANY_CODE
    from CLS_BRAND_SCOPE);
