create    view [dbo].[PV_VIP_MAX_POINT_BALANCE_DT] as
select pv.VIP_ID , isnull(max(pvbb.BALANCE_DT), '2000-01-01') as MAX_BALANCE_DT
from PM_VIP pv
left join PL_VIP_BP_BALANCE pvbb
    on pv.VIP_ID = pvbb.VIP_ID_FK
group by pv.VIP_ID
