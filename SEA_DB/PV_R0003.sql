create   view [dbo].[PV_R0003] as
select *
from PMV_SALES_STORE_DEMOGRAPHIC_VIP pssdv
union all
select *
from PMV_SALES_STORE_DEMOGRAPHIC_WALKIN pssdw
where 1 = 1
