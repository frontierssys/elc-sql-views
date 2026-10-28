create   view [dbo].[PV_R0010] as
select *
from PMV_R0010_VIP prv
union all
select *
from PMV_R0010_WALKIN prw
