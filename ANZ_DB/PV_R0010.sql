CREATE   VIEW  PV_R0010 as
select prv.*
from PMV_R0010_VIP prv
union all
select prw.*
from PMV_R0010_WALKIN prw
