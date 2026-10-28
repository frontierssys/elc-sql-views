create   view [dbo].[PV_R0011] AS
select *
from PMV_SALES_STORE_SKU_DEMOGRAPHIC_VIP pssdv
union all
select *
from PMV_SALES_STORE_SKU_DEMOGRAPHIC_WALKIN pssdw
where 1 = 1
