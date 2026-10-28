CREATE   VIEW  [dbo].[PV_R0009] AS
select *
from PMV_R0008_VIP prv
union all
select *
from PMV_R0008_WALKIN prw
where 1 = 1
