-- dbo.PV_R0077 source

create view [dbo].[PV_R0077] as
select
    pl.SAP_CUSTOMER_CODE ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    plcs.TX_DATE ,
    pci.BRAND_CODE ,
    pci.BRAND_NAME ,
    plcs.TOTAL_SALES_AMT
from
    PL_LOC_COMPETITOR_SALES plcs
inner join PM_LOC_COMPETITOR plc
    on plcs.LOC_COMPETITOR_ID_FK = plc.LOC_COMPETITOR_ID
inner join PM_LOCATION pl
    on plc.LOCATION_ID_FK = pl.LOCATION_ID
inner join PM_COMPETITOR_INFO pci
    on plc.COMPETITOR_INFO_ID_FK = pci.COMPETITOR_INFO_ID
