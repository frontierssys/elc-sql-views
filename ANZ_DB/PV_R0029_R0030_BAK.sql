CREATE   VIEW  PV_R0029_R0030_BAK as
select 'Consumer' as 'Customer Type', *
from PMV_R0029_R0030_VIP prrv
union
select 'Walk-in' as 'Customer Type', *
from PMV_R0029_R0030_WALKIN prrw
where 1 = 1
