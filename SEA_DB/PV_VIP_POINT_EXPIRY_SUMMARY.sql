create   view PV_VIP_POINT_EXPIRY_SUMMARY as
select
    pv.COMPANY_CODE ,
    pv.VIP_ID ,
    pv.VIP_NO ,
    pv.START_DT as START_DT ,
    pva.BONUS_EXP_DT as EXPIRY_DT ,
    isnull(max(pvbb.BALANCE),0) + sum(isnull(pvbm.POINT_MOVEMENT,0)) as POINT_BALANCE
from PM_VIP pv
inner join PM_VIP_ATTR pva
    on pva.VIP_ATTR_ID = pv.VIP_ATTR_ID_FK
inner join PM_COUNTRY pc
    on pv.COMPANY_CODE = pc.COMPANY_CODE
    --and pc.COUNTRY_CODE_ISO3 = 'TWN'
left join PL_VIP_BP_BALANCE pvbb
    on pvbb.VIP_ID_FK = pv.VIP_ID
    and pvbb.BALANCE_DT >= pva.BONUS_START_DT
    and pvbb.BALANCE_DT <= pva.BONUS_EXP_DT
left join PL_VIP_BP_MOVEMENT pvbm
    on pvbm.COMPANY_CODE = pv.COMPANY_CODE
    and pvbm.VIP_NO = pv.VIP_NO
    and pvbm.MOVEMENT_DT >= pva.BONUS_START_DT
    and pvbm.MOVEMENT_DT <= pva.BONUS_EXP_DT
where
    pva.BONUS_EXP_DT is not null
    and (pvbb.VIP_BP_BALANCE_ID is not null or pvbm.VIP_BP_MOVEMENT_ID is not null)
    and (pva.RESET_EXPIRED_BONUS_POINT_DT is null or (pv.START_DT is not null and pva.RESET_EXPIRED_BONUS_POINT_DT < pv.START_DT))
group by
    pv.COMPANY_CODE ,
    pv.VIP_ID ,
    pv.VIP_NO ,
    pv.START_DT ,
    pva.BONUS_EXP_DT
