CREATE   view [dbo].[PV_INVENTORY_BALANCE] as
Select
    pib.COMPANY_CODE,
    pib.LOCATION_ID,
    pib.SKU,
    pib.BALANCE_DT,
    pib.BALANCE_TYPE,
    pib.BALANCE
From PL_INVENTORY_BALANCE pib
