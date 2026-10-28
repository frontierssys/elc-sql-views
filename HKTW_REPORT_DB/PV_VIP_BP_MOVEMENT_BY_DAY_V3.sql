CREATE   view [dbo].[PV_VIP_BP_MOVEMENT_BY_DAY_V3] as
SELECT
    coalesce (pvbb.BALANCE_DT, '2022-08-01') as OPEN_BALANCE_DT,
    coalesce (pvbb.BALANCE , 0) as BALANCE,
    coalesce (pvbm.COMPANY_CODE, pvbb.COMPANY_CODE) as COMPANY_CODE ,
    coalesce (pvbm.MOVEMENT_DT , pvbb.BALANCE_DT) as MOVEMENT_DATE ,
    coalesce (pvbm.VIP_NO , pvbb.VIP_NO ) as VIP_NO,
    sum(coalesce (pvbm.POINT_MOVEMENT ,0) ) as MOVEMENT_PTS
from
    PL_VIP_BP_MOVEMENT pvbm
full outer join (
    SELECT pvb.*,pv.VIP_NO
    FROM PL_VIP_BP_BALANCE pvb
    INNER JOIN PM_VIP pv on pv.VIP_ID =pvb.VIP_ID_FK
    WHERE pvb.BALANCE_DT ='2022-08-01')  pvbb
    on pvbm.COMPANY_CODE = pvbb.COMPANY_CODE
    and pvbm.VIP_NO = pvbb.VIP_NO
WHERE pvbm.MOVEMENT_DT >= pvbb.BALANCE_DT
    AND coalesce (pvbm.COMPANY_CODE, pvbb.COMPANY_CODE)='HKCL'
    AND pvbm.MOVEMENT_DT <'2023-07-01' --AND coalesce (pvbm.VIP_NO , pvbb.VIP_NO )='HQ000188112'
GROUP BY
    coalesce (pvbb.BALANCE_DT, '2022-08-01'),
    coalesce (pvbb.BALANCE , 0),
    coalesce (pvbm.COMPANY_CODE, pvbb.COMPANY_CODE),
    coalesce (pvbm.MOVEMENT_DT , pvbb.BALANCE_DT),
    coalesce (pvbm.VIP_NO , pvbb.VIP_NO )
