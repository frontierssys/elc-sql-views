-- dbo.PV_R0023 source

CREATE   VIEW  [dbo].[PV_R0023] AS
select *
from PV_R0023_TRANSFER
union
select *
from PV_R0023_RTW
--where 1 = 1;
