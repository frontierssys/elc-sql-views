CREATE   VIEW PV_VIP_BP_CURRENT_BALANCE as
select
    pv.VIP_ID ,
    isnull(pvbb.BALANCE, 0) + sum(pvbm.POINT_MOVEMENT) as CURRENT_POINT_BALANCE
    --isnull(pvbb.BALANCE, 0),
    --pvbm.POINT_MOVEMENT
from PM_VIP pv
inner join PM_VIP_TYPE pvt
    on pvt.VIP_TYPE_ID = pv.VIP_TYPE_ID_FK
inner join PM_VIP_ATTR pva
    on pva.VIP_ATTR_ID = pv.VIP_ATTR_ID_FK
left join PV_VIP_MAX_POINT_BALANCE pvmpb
    on pvmpb.VIP_ID = pv.VIP_ID
    and pvmpb.BALANCE_DT <= pva.BONUS_EXP_DT
    and pvmpb.BALANCE_DT >= pva.BONUS_START_DT
left join PL_VIP_BP_BALANCE pvbb
    on pvbb.VIP_ID_FK = pvmpb.VIP_ID
    and pvbb.BALANCE_DT = pvmpb.BALANCE_DT
left join PL_VIP_BP_MOVEMENT pvbm
    on pvbm.COMPANY_CODE = pv.COMPANY_CODE
    and pvbm.VIP_NO = pv.VIP_NO
    and (pvbm.MOVEMENT_DT <= pva.BONUS_EXP_DT or pva.BONUS_EXP_DT is null)
    and pvbm.MOVEMENT_DT >= pva.BONUS_START_DT
    and (pvbm.MOVEMENT_DT >= pvmpb.BALANCE_DT or pvmpb.BALANCE_DT is null)
where 1 = 1
--and pv.COMPANY_CODE = 'HKOR'
--and pv.VIP_ID = 'HKORHQ000001104'
--and pvmpb.BALANCE > 0
--and pv.COMPANY_CODE = 'HKOR'
group by
    pv.VIP_ID ,
    pvbb.BALANCE
