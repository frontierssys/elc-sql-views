-- dbo.PV_R8801 source

-- dbo.PV_R8801 source

create     view [dbo].[PV_R8801] as
select
    prc.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    pl.LOCATION_CODE + '-' + pl.LOCATION_DESC as LOCATION_DESC,
    prc.TX_DATE,
    ps.SKU_CODE ,
    ps.SKU_DESC ,
    prc.QTY as CURRENT_YEAR_QTY,
    prc.AMOUNT as CURRENT_YEAR_AMT,
    isnull(prc2.QTY,0) as LAST_YEAR_QTY,
    isnull(prc2.AMOUNT,0) as LAST_YEAR_AMT
from PV_R8801_CURRENT prc
inner join PM_LOCATION pl
    on pl.LOCATION_ID = prc.LOCATION_ID_FK
inner join PM_SKU ps
    on prc.COMPANY_CODE = ps.COMPANY_CODE
    and prc.SKU = ps.SKU_CODE
left join PV_R8801_CURRENT prc2
    on prc.COMPANY_CODE = prc2.COMPANY_CODE
    and prc.LOCATION_ID_FK = prc2.LOCATION_ID_FK
    and prc.SKU = prc2.SKU
    and prc.TX_DATE = dateadd(year, 1, prc2.TX_DATE )
    --and prc2.TX_DATE = '2019-01-01';
