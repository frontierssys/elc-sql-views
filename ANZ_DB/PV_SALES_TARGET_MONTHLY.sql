CREATE   VIEW PV_SALES_TARGET_MONTHLY as
select
    pst.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    CAST (pst.DATE_FROM as date) as TX_DATE,
    datepart(month, pst.DATE_FROM) as TX_MONTH,
    datepart(year, pst.DATE_FROM) as TX_YEAR,
    TARGET_AMOUNT
from
    PM_SALES_TARGET pst
inner join PM_LOCATION pl on
    pl.LOCATION_ID = pst.LOCATION_ID_FK
where
    SALES_TARGET_TYPE = 'MONTHLY'
    and STAFF_NO is null
