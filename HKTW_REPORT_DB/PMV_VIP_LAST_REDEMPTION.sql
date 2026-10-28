CREATE view [dbo].[PMV_VIP_LAST_REDEMPTION]
as
select pv.VIP_ID as VIP_ID, a.MOVEMENT_DT, pvbm.POINT_MOVEMENT
from PM_VIP pv
inner join PL_VIP_BP_MOVEMENT pvbm
    on pv.VIP_NO = pvbm.VIP_NO and pv.COMPANY_CODE=pvbm.COMPANY_CODE
inner join
    (
        select pv2.VIP_ID as VIP_ID, MAX(pvbm2.MOVEMENT_DT ) as MOVEMENT_DT
        from PM_VIP pv2
        inner join PL_VIP_BP_MOVEMENT pvbm2
            on pv2.VIP_NO = pvbm2.VIP_NO and pv2.COMPANY_CODE=pvbm2.COMPANY_CODE
        where pvbm2.MOVEMENT_TYPE = 'GIFT'
            and pvbm2.POINT_MOVEMENT < 0
        group by pv2.VIP_ID
    ) a
    on a.VIP_ID = pv.VIP_ID
    and pvbm.MOVEMENT_DT = a.MOVEMENT_DT
where pvbm.MOVEMENT_TYPE = 'GIFT'
    and pvbm.POINT_MOVEMENT < 0
    --group by pv.VIP_ID
