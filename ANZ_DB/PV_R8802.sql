CREATE   VIEW  PV_R8802 as
select
    prc.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    prc.TX_DATE,
    DATENAME(WEEKDAY, prc.TX_DATE) as WEEK_OF_DAY,
    --ps.SKU_CODE ,
    --ps.SKU_DESC ,
    sum(prc.customer_count) as CUSTOMER_COUNT,
    sum(prc.QTY) as CURRENT_YEAR_QTY,
    sum(prc.AMOUNT) as CURRENT_YEAR_AMT,
    sum(isnull(prc2.QTY,0)) as LAST_YEAR_QTY,
    sum(isnull(prc2.AMOUNT,0)) as LAST_YEAR_AMT
from PV_R8802_CURRENT prc
inner join PM_LOCATION pl
    on pl.LOCATION_ID = prc.LOCATION_ID_FK
inner join PM_SKU ps
    on prc.COMPANY_CODE = ps.COMPANY_CODE
left join PV_R8802_CURRENT prc2
    on prc.COMPANY_CODE = prc2.COMPANY_CODE
    and prc.LOCATION_ID_FK = prc2.LOCATION_ID_FK
    and prc2.TX_DATE = dateadd(year, -1, prc.TX_DATE )
    --and prc2.TX_DATE = '2019-01-01'
where prc.COMPANY_CODE = 'HKEL' and prc.TX_DATE = '2020-06-01'
group by
    prc.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    prc.TX_DATE
