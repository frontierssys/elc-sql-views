CREATE   view PV_VIP_DOWNGRADE_MAX_SPENDING as
select
    pvcts.COMPANY_CODE ,
    pvcts.VIP_ID ,
    pvcts.VIP_NO ,
    pvcts.CURR_TIER_SPENDING ,
    CASE
        when max(pvdr.SPENDING) >= 0 then max(pvdr.SPENDING)
        else 0
    end as MAX_SPENDING
from
    PV_VIP_CURR_TIER_SPENDING pvcts
inner join PM_VIP pv
    on pv.VIP_ID = pvcts.VIP_ID
inner join PM_VIP_TYPE pvt
    on pvt.VIP_TYPE_ID = pv.VIP_TYPE_ID_FK
inner join PM_VIP_GRADE pvg
    on pvg.VIP_GRADE_ID = pvt.VIP_GRADE_ID_FK
inner join PM_VIP_DOWNGRADE_RULE pvdr on
    pvdr.COMPANY_CODE = pvcts.COMPANY_CODE
    and pvdr.VIP_GRADE_FROM = pvg.VIP_GRADE_CODE
    and pvdr.SPENDING <= pvcts.CURR_TIER_SPENDING
    --where
    --	pvcts.COMPANY_CODE = 'TWEL'
    --	and pvcts.VIP_ID in ( 'TWEL6B000000110', 'TWELHQ000017610', 'TWELHQ000031638')
group by
    pvcts.COMPANY_CODE ,
    pvcts.VIP_ID ,
    pvcts.VIP_NO ,
    pvcts.CURR_TIER_SPENDING
