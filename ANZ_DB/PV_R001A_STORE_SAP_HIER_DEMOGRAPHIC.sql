CREATE   VIEW  PV_R001A_STORE_SAP_HIER_DEMOGRAPHIC as
select 'Consumer' as 'Customer Type', *
from PMV_SALES_STORE_SHIER_DEMOGRAPHIC_VIP prav
union
select 'Walk-in' as 'Customer Type', *
from PMV_SALES_STORE_SHIER_DEMOGRAPHIC_WALKIN praw
