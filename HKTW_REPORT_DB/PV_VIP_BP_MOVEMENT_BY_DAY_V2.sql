CREATE   view [dbo].[PV_VIP_BP_MOVEMENT_BY_DAY_V2] as
select
    coalesce (pvbb.BALANCE_DT, '2018-01-01') as OPEN_BALANCE_DT,
    coalesce (pvbb.BALANCE , 0) as BALANCE,
    coalesce (pvbm.COMPANY_CODE, pvbb.COMPANY_CODE) as COMPANY_CODE ,
    coalesce (pvbm.MOVEMENT_DT , '2018-01-01') as MOVEMENT_DATE ,
    coalesce (pvbm.VIP_NO , pvbb.VIP_NO ) as VIP_NO,
    sum(coalesce (POINT_MOVEMENT ,0) ) as POINT_MOVEMENT
from
    PL_VIP_BP_MOVEMENT pvbm
full outer join (
    Select pvbb1.COMPANY_CODE , pvbb1.BALANCE_DT, pv.VIP_NO,pvbb1.BALANCE
    from PL_VIP_BP_BALANCE pvbb1
    inner JOIN PM_VIP pv ON pv.COMPANY_CODE =pvbb1.COMPANY_CODE and pv.VIP_ID=pvbb1.VIP_ID_FK ) pvbb
    on pvbm.COMPANY_CODE = pvbb.COMPANY_CODE
    and pvbm.MOVEMENT_DT >= pvbb.BALANCE_DT
    and pvbm.VIP_NO = pvbb.VIP_NO
    --where (pvbm.VIP_NO ='HQ001068543' or  pvbb.VIP_NO = 'HQ001068543') and pvbm.COMPANY_CODE ='HKCL'
group by
    coalesce (pvbb.BALANCE_DT, '2018-01-01'),
    coalesce (pvbb.BALANCE , 0) ,
    coalesce (pvbm.COMPANY_CODE, pvbb.COMPANY_CODE) ,
    coalesce (pvbm.MOVEMENT_DT , '2018-01-01') ,
    coalesce (pvbm.VIP_NO , pvbb.VIP_NO )
union ALL
select
    pvbb.BALANCE_DT as OPEN_BALANCE_DT,
    pvbb.BALANCE  as BALANCE,
    pvbb.COMPANY_CODE as COMPANY_CODE ,
    '2000-01-01' as MOVEMENT_DATE ,
    --coalesce (pil.BALANCE_TYPE , pib.BALANCE_TYPE , 'ONHAND') as BALANCE_TYPE,
    pvbb.VIP_NO,
    --pil.MOVEMENT_QTY
    0 as MOVEMENT_QTY
from
    (
        Select pvbb1.COMPANY_CODE , pvbb1.BALANCE_DT, pv.VIP_NO,pvbb1.BALANCE
        from PL_VIP_BP_BALANCE pvbb1
        inner JOIN PM_VIP pv ON pv.COMPANY_CODE =pvbb1.COMPANY_CODE and pv.VIP_ID=pvbb1.VIP_ID_FK ) pvbb
