-- dbo.PV_VIP_BP_CURRENT_BALANCE_REVAMP source

CREATE    VIEW PV_VIP_BP_CURRENT_BALANCE_REVAMP as
select
    pv.COMPANY_CODE ,
    pv.VIP_ID ,
    pvbb.BALANCE + sum(pvbm.POINT_MOVEMENT) as CURRENT_POINT_BALANCE
from PM_VIP pv
/*inner join PM_VIP_TYPE pvt
on pvt.VIP_TYPE_ID = pv.VIP_TYPE_ID_FK and pvt.COMPANY_CODE =pv.COMPANY_CODE */
inner join PM_VIP_ATTR pva
    on pva.VIP_ATTR_ID = pv.VIP_ATTR_ID_FK and pva.COMPANY_CODE =pv.COMPANY_CODE
left join PV_VIP_MAX_POINT_BALANCE pvmpb
    on pvmpb.VIP_ID = pv.VIP_ID and pvmpb.COMPANY_CODE =pv.COMPANY_CODE
    and pvmpb.BALANCE_DT <= pva.BONUS_EXP_DT
    and pvmpb.BALANCE_DT >= pva.BONUS_START_DT
left join PL_VIP_BP_BALANCE pvbb
    on pvbb.VIP_ID_FK = pvmpb.VIP_ID and pvbb.COMPANY_CODE =pv.COMPANY_CODE
    and pvbb.BALANCE_DT = pvmpb.BALANCE_DT
left join PL_VIP_BP_MOVEMENT pvbm
    on pvbm.COMPANY_CODE = pv.COMPANY_CODE
    and pvbm.VIP_NO = pv.VIP_NO
where 1 = 1
    and pvbm.MOVEMENT_DT <= pva.BONUS_EXP_DT
    and pvbm.MOVEMENT_DT >= pva.BONUS_START_DT
    and (pvbm.MOVEMENT_DT >= pvmpb.BALANCE_DT or pvmpb.BALANCE_DT is null)
    --and pv.COMPANY_CODE = 'HKCM'
    --and pv.VIP_ID = 'HKCM05000019000'
    --and pvmpb.BALANCE > 0
    --and pv.COMPANY_CODE = 'HKOR'
group by
    pv.COMPANY_CODE ,
    pv.VIP_ID ,
    pvbb.BALANCE;
