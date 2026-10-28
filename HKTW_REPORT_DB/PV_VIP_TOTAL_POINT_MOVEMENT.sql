CREATE   view PV_VIP_TOTAL_POINT_MOVEMENT
as
select
    pv.COMPANY_CODE , pv.VIP_ID , pv.VIP_NO , sum(pvbm.POINT_MOVEMENT ) as PT_MOVEMENT
from PM_VIP pv
inner join PM_VIP_ATTR pva
    on pva.VIP_ATTR_ID = pv.VIP_ATTR_ID_FK
left join PV_VIP_MAX_POINT_BALANCE_DT a
    on a.VIP_ID = pv.VIP_ID
left join PL_VIP_BP_MOVEMENT pvbm
    on pvbm.COMPANY_CODE = pv.COMPANY_CODE
    and pvbm.VIP_NO = pv.VIP_NO
    --and pvbm.MOVEMENT_DT >= pvt.START_DATE
    --and pvbm.MOVEMENT_DT <= pvt.EXPIRY_DAY
    and pvbm.MOVEMENT_DT >= pva.BONUS_START_DT
    and pvbm.MOVEMENT_DT <= dateadd(day, 1, pva.BONUS_EXP_DT )
    and pvbm.MOVEMENT_DT >= a.MAX_BALANCE_DT
    --where pv.COMPANY_CODE = 'TWCL'
group by pv.COMPANY_CODE , pv.VIP_ID , pv.VIP_NO
