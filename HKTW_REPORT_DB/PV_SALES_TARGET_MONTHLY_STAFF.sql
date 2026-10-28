CREATE   view [dbo].[PV_SALES_TARGET_MONTHLY_STAFF] as
select
    pst.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    datepart(year, pst.DATE_FROM) as TX_YEAR,
    datepart(month, pst.DATE_FROM) as TX_MONTH,
    pst.STAFF_NO ,
    TARGET_AMOUNT
from
    PM_SALES_TARGET pst
inner join PM_LOCATION pl on
    pl.LOCATION_ID = pst.LOCATION_ID_FK
where
    SALES_TARGET_TYPE = 'MONTHLY'
    and STAFF_NO is not null
