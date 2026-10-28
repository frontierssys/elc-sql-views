CREATE   VIEW  PV_VIP_POINTS_BALANCE_BAK as
select pv.COMPANY_CODE ,
    pv.VIP_NO,
    pv.VIP_ID ,
    MAX(FORMAT(EXPIRY_DT , 'yyyyMMdd')) as EXPIRY_DATE,
    --MAX(pvbb.BALANCE_DT),
    --MAX(pvbb.BALANCE ),
    --pvbm.MOVEMENT_DT ,
    FORMAT(GETDATE(), 'yyyyMMdd') as AS_OF_DATE,
    sum(
        CASE
            when pvbm.MOVEMENT_TYPE = 'GIFT' then pvbm.POINT_MOVEMENT
            else 0
        end) as REDEEM_POINT,
    SUM(pvbm.POINT_MOVEMENT) as POINTS
from PM_VIP pv
left join PL_VIP_BP_BALANCE pvbb
    on pv.VIP_ID = pvbb.VIP_ID_FK
left join PL_VIP_BP_MOVEMENT pvbm
    on pv.VIP_NO = pvbm.VIP_NO
    and (pvbb.BALANCE_DT is null or pvbb.BALANCE_DT < pvbm.MOVEMENT_DT )
    and pv.EXPIRY_DT > getdate()
group by
    pv.COMPANY_CODE ,
    pv.VIP_NO,
    pv.VIP_ID
    --) as a;

    -- dbo.PV_VIP_POINTS_BALANCE source
