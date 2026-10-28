create   view [dbo].[PV_R001A_STORE_STAFF_DEMOGRAPHIC] as
select 'Consumer' as 'Customer Type', *
from PMV_SALES_STORE_EMPLOYEE_DEMOGRAPHIC_VIP prav
union
select 'Walk-in' as 'Customer Type', *
from PMV_SALES_STORE_EMPLOYEE_DEMOGRAPHIC_WALKIN praw
