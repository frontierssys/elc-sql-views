-- dbo.PV_R0023 source

CREATE   view [dbo].[PV_R0023] AS
select *
from PV_R0023_TRANSFER
UNION ALL
select *
from PV_R0023_RTW;
