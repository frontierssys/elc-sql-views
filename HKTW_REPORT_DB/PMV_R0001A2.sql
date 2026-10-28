create     view [dbo].[PMV_R0001A2] AS
select 'Consumer' as 'Customer Type', *
from PMV_SALES_STORE_SKU_EMPLOYEE_DEMOGRAPHIC_VIP prrv
union
select 'Walk-in' as 'Customer Type', *
from PMV_SALES_STORE_SKU_EMPLOYEE_DEMOGRAPHIC_WALKIN prrw
