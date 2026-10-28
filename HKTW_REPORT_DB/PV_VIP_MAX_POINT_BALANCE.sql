CREATE    view PV_VIP_MAX_POINT_BALANCE as
select
    pv.COMPANY_CODE ,
    pv.VIP_ID,
    --pvbb.BALANCE_DT ,
    --pvbb.BALANCE ,
    --ROW_NUMBER() over (PARTITION by pv.VIP_ID order by pvbb.BALANCE_DT desc) as RN
    --max(pvbb.BALANCE_DT ) over (PARTITION by pv.VIP_ID )
    max(pvbb.BALANCE_DT ) as BALANCE_DT
from
    PM_VIP pv
left join PL_VIP_BP_BALANCE pvbb
    on pvbb.VIP_ID_FK = pv.VIP_ID
    --where pv.COMPANY_CODE = 'HKOR'
group by pv.COMPANY_CODE , pv.VIP_ID
