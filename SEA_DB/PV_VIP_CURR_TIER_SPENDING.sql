--Step 2: create this view
CREATE   view  PV_VIP_CURR_TIER_SPENDING as
select
    pv.COMPANY_CODE ,
    pv.VIP_ID ,
    pv.VIP_CLUSTER_ID_FK ,
    pv.VIP_NO ,
    pv.START_DT ,
    pv.EXPIRY_DT ,
    case
        when isnull(sum(pvsm.POINT_MOVEMENT),0) + isnull(pvbb.BALANCE, 0) >= 0 then isnull(sum(pvsm.POINT_MOVEMENT),0) + isnull(pvbb.BALANCE, 0)
        else 0
    end as CURR_TIER_SPENDING
from
    PM_VIP pv
inner join PM_VIP_TYPE pvt
    on pv.VIP_TYPE_ID_FK =pvt.VIP_TYPE_ID
left join PV_VIP_CURR_TIER_SP_OPENING_BALANCE_DT pvctsobd on
    pvctsobd.VIP_ID = pv.VIP_ID
left join PL_VIP_SP_BALANCE pvbb on
    pvbb.VIP_ID_FK = pv.VIP_ID
    and pvbb.BALANCE_DT = pvctsobd.MAX_BALANCE_DT
left join PL_VIP_SP_MOVEMENT pvsm on
    pvsm.COMPANY_CODE = pv.COMPANY_CODE
    and pvsm.VIP_NO = pv.VIP_NO
    and pvsm.MOVEMENT_DT >= pvt.START_DATE
    and (pvt.EXPIRY_DAY is null OR pvsm.MOVEMENT_DT <= dateadd(day, 1, pvt.EXPIRY_DAY))
    and pvsm.MOVEMENT_DT >= pvctsobd.MAX_BALANCE_DT
    and (pvsm.OLD_VIP_GRADE_CODE is null OR pvsm.OLD_VIP_GRADE_CODE =pvt.TYPE_CODE)
group by
    pv.COMPANY_CODE ,
    pv.VIP_ID ,
    pv.VIP_CLUSTER_ID_FK ,
    pv.VIP_NO,
    pv.START_DT ,
    pv.EXPIRY_DT ,
    pvctsobd.MAX_BALANCE_DT ,
    pvbb.BALANCE
