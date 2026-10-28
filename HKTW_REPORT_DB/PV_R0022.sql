-- dbo.PV_R0022 source

CREATE  view [dbo].[PV_R0022] as
select *
from PV_R0022_ASN pra
UNION ALL
select *
from PV_R0022_TRANSFER prt;
