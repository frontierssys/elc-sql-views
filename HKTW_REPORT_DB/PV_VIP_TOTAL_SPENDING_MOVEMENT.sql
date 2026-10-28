CREATE view PV_VIP_TOTAL_SPENDING_MOVEMENT
as
select
    pv.COMPANY_CODE , pv.VIP_ID , pv.VIP_NO , sum(pvbm.POINT_MOVEMENT ) as SP_MOVEMENT
from PM_VIP pv
inner join PM_VIP_TYPE pvt
    on pvt.VIP_TYPE_ID = pv.VIP_TYPE_ID_FK
left join PL_VIP_SP_MOVEMENT pvbm
    on pvbm.COMPANY_CODE = pv.COMPANY_CODE
    and pvbm.VIP_NO = pv.VIP_NO
    and pvbm.MOVEMENT_DT >= pvt.START_DATE
    and pvbm.MOVEMENT_DT < pvt.EXPIRY_DAY
    --where pv.COMPANY_CODE in ('TWCM', 'TWOR')
group by pv.COMPANY_CODE, pv.VIP_ID , pv.VIP_NO
