create     view [dbo].[PMV_R0001A] AS
select 'Consumer' as 'Customer Type', *
from PMV_R0001A_2_VIP prrv
union
select 'Walk-in' as 'Customer Type', *
from PMV_R0001A_2_WALKIN prrw
