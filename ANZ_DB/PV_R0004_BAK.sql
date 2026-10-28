CREATE   VIEW  PV_R0004_BAK as
select *
from PMV_R0004_VIP pssdv
union all
select *
from PMV_R0004_WALKIN pssdw
where 1 = 1
