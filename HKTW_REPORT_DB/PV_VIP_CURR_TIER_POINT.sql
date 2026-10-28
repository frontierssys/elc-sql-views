create view PV_VIP_CURR_TIER_POINT as
select
    pv.COMPANY_CODE ,
    pv.VIP_ID ,
    pv.VIP_CLUSTER_ID_FK ,
    pv.VIP_NO,
    pvt.START_DATE ,
    pv.EXPIRY_DT as VIP_EXPIRY_DATE,
    isnull(pvbb.BALANCE,0) + isnull(pvtpm.PT_MOVEMENT,0) as POINT_BALANCE,
    pva2.BONUS_EXP_DT as POINT_EXPIRY_DATE,
    pv.STATUS
    --	pvcp.POINTS as POINT_BALANCE ,
    --isnull(pvys.LIFETIME_SPEND,0) as SPENDING_0701_0831
from PM_VIP pv
inner join PM_VIP_TYPE pvt
    on pvt.VIP_TYPE_ID = pv.VIP_TYPE_ID_FK
inner join PM_VIP_GRADE pvg
    on pvg.VIP_GRADE_ID = pvt.VIP_GRADE_ID_FK
left join PMV_VIP_YTD_SPENDING pvys on
    pvys.VIP_ID = pv.VIP_ID
left join PM_VIP_ATTR pva2
    on pva2.VIP_ATTR_ID = pv.VIP_ATTR_ID_FK
left join PV_VIP_TOTAL_POINT_MOVEMENT pvtpm
    on pvtpm.VIP_ID = pv.VIP_ID
left join PV_VIP_MAX_POINT_BALANCE_DT pvmpbd
    on pvmpbd.VIP_ID = pv.VIP_ID
left join PL_VIP_BP_BALANCE pvbb
    on pvbb.VIP_ID_FK = pv.VIP_ID
    and pvbb.BALANCE_DT = pvmpbd.MAX_BALANCE_DT
    --where
    --	pv.COMPANY_CODE = 'HKAR'
    --	and pv.VIP_NO = 'HQ000020261'
    --	and pv.STATUS = 'ACTIVE'
    --	pvcp.COMPANY_CODE = 'HKCM'
    --	and pv.VIP_NO = 'HQ000214084'
