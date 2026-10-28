-- dbo.PV_RDI_SKIP_IA source

CREATE   view [dbo].[PV_RDI_SKIP_IA] as
select
    ps.COMPANY_CODE ,
    ps.SKU_CODE ,
    ps.SKU_DESC ,
    psa.IH_L1 ,
    psa.IH_L2 ,
    psa.IH_L3 ,
    pia.IS_INVENTORY_ITEM ,
    case
        when ps.SKU_CODE in ('9999681361', '9999530061') then 'N'   --WATER and ALCOHOL
        when psa.IH_L1 ='110' and psa.IH_L2='13' and psa.IH_L3='13' and ps.COMPANY_CODE like '%CS' then 'Y'
        when psa.IH_L1 ='110' and psa.IH_L2='13' and psa.IH_L3='13' then 'N'
        when pia.IS_INVENTORY_ITEM = 'Y' then 'Y'
        else 'N'
    end as ALLOWED
from PM_SKU ps
inner join PM_SKU_ATTR psa
    on psa.SKU_ATTR_ID = ps.SKU_ATTR_ID_FK
inner join PM_ITEM pi2
    on pi2.ITEM_ID = ps.ITEM_ID_FK
inner join PM_ITEM_ATTR pia
    on pia.ITEM_ATTR_ID = pi2.ITEM_ATTR_ID_FK
