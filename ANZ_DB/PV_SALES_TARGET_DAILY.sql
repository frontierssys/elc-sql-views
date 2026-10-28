CREATE   VIEW PV_SALES_TARGET_DAILY as
select
    pst.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    CAST (pst.DATE_FROM as date) as TX_DATE,
    TARGET_AMOUNT
from
    PM_SALES_TARGET pst
inner join PM_LOCATION pl on
    pl.LOCATION_ID = pst.LOCATION_ID_FK
where
    SALES_TARGET_TYPE = 'DAILY'
    and STAFF_NO is null
