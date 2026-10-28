CREATE   view [dbo].[PV_VIP_CURR_TIER_SP_OPENING_BALANCE_DT] as
select pv.COMPANY_CODE , pv.VIP_ID , pv.VIP_CLUSTER_ID_FK , pv.VIP_NO , isnull(max(pvsb.BALANCE_DT ), '2000-01-01') as MAX_BALANCE_DT
from PM_VIP pv
left join PL_VIP_SP_BALANCE pvsb
    on pvsb.VIP_ID_FK = pv.VIP_ID
    and pvsb.BALANCE_DT >= pv.START_DT
    and pvsb.BALANCE_DT <= pv.EXPIRY_DT
group by pv.COMPANY_CODE , pv.VIP_ID , pv.VIP_CLUSTER_ID_FK , pv.VIP_NO
