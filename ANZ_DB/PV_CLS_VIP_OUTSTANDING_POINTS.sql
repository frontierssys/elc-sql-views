CREATE   VIEW  PV_CLS_VIP_OUTSTANDING_POINTS as
select pv.COMPANY_CODE ,
    pv.VIP_NO,
    MAX(FORMAT(EXPIRY_DT , 'yyyyMMdd')) as EXPIRY_DATE,
    --MAX(pvbb.BALANCE_DT),
    --MAX(pvbb.BALANCE ),
    --pvbm.MOVEMENT_DT ,
    FORMAT(GETDATE(), 'yyyyMMdd') as AS_OF_DATE,
    SUM(pvbm.POINT_MOVEMENT) as POINTS
from PM_VIP pv
left join PL_VIP_BP_BALANCE pvbb on pv.VIP_ID = pvbb.VIP_ID_FK
left join PL_VIP_BP_MOVEMENT pvbm on pv.VIP_NO = pvbm.VIP_NO and pv.VIP_CLUSTER_ID_FK = pvbm.VIP_CLUSTER_ID_PK
    and (pvbb.BALANCE_DT is null or pvbb.BALANCE_DT < pvbm.MOVEMENT_DT )
    and pv.EXPIRY_DT > getdate()
group by
    pv.COMPANY_CODE ,
    pv.VIP_NO
    --) as a;











    -- dbo.PV_CUSTOMER_PURCHASE_HISTORY source
