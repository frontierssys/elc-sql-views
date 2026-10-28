CREATE    view PV_VIP_MAX_POINT_BALANCE as
select
    pv.COMPANY_CODE ,
    pv.VIP_ID,
    max(pvbb.CRE_DATET ) as BALANCE_DT
from
    PM_VIP pv
left join PL_VIP_BP_BALANCE pvbb
    on pvbb.VIP_ID_FK = pv.VIP_ID
group by pv.COMPANY_CODE , pv.VIP_ID;
