-- dbo.PV_R0078_BK source

CREATE   view PV_R0078_BK AS
select
    pl.SAP_CUSTOMER_CODE ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    plcs.TX_DATE ,
    datepart(WEEKDAY, plcs.TX_DATE ) as TX_WEEKDAY,
    datepart(wk, plcs.TX_DATE ) as TX_WEEKNUMBER,
    pci.BRAND_CODE ,
    pci.IS_ELCA,
    pci.BRAND_NAME ,
    plcs.TOTAL_SALES_AMT
from
    PL_LOC_COMPETITOR_SALES plcs
inner join PM_LOC_COMPETITOR plc
    on plcs.LOC_COMPETITOR_ID_FK = plc.LOC_COMPETITOR_ID
inner join PM_LOCATION pl
    on plc.LOCATION_ID_FK = pl.LOCATION_ID
inner join (
    SELECT pci.*,(
        case
            when com.COMPANY_CODE is null then 'N'
            ELSE 'Y'
        END) IS_ELCA
    from PM_COMPETITOR_INFO pci
    left join PM_COMPANY com on RIGHT(com.COMPANY_CODE,2)=pci.BRAND_CODE and LEFT(com.COMPANY_CODE,2)='TW') pci
    on plc.COMPETITOR_INFO_ID_FK = pci.COMPETITOR_INFO_ID;
