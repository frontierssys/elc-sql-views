CREATE   VIEW  PV_R001A_STORE_LOCAL_HIER_DEMOGRAPHIC as
select 'Consumer' as 'Customer Type', *
from PMV_SALES_STORE_LHIER_DEMOGRAPHIC_VIP prav
union
select 'Walk-in' as 'Customer Type', *
from PMV_SALES_STORE_LHIER_DEMOGRAPHIC_WALKIN praw
