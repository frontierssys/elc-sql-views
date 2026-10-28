CREATE   VIEW  PV_VIP_POINTS_BALANCE as
select
    COMPANY_CODE ,
    VIP_ID,
    VIP_NO,
    EXPIRY_DATE,
    --MAX(EXPIRY_DATE),
    FORMAT(GETDATE(), 'yyyyMMdd') as AS_OF_DATE,
    sum(REDEEM_POINT) as REDEEM_POINT,
    sum(points) as POINTS
from
    (
        select
            COMPANY_CODE , VIP_NO, VIP_ID, EXPIRY_DATE,REDEEM_POINT, points
        from
            (
                select
                    pv.COMPANY_CODE , pv.VIP_NO , pv.VIP_ID , null as expiry_date, 0 as REDEEM_POINT, pvbb.BALANCE as points, ROW_NUMBER() over (
                        PARTITION by pvbb.VIP_ID_FK
                        order by
                            pvbb.BALANCE_DT desc) rn
                from
                    PL_VIP_BP_BALANCE pvbb
                inner join PM_VIP pv on
                    pv.VIP_ID = pvbb.VIP_ID_FK) bal
        where
            bal.rn = 1
        union all
        select
            pvbm.COMPANY_CODE , pvbm.VIP_NO , pv.VIP_ID as VIP_ID, pvbm.EXPIRY_DATE, sum(
                CASE
                    when pvbm.MOVEMENT_TYPE = 'GIFT' then pvbm.POINT_MOVEMENT
                    else 0
                end) as REDEEM_POINT, sum(pvbm.POINT_MOVEMENT) as points
        from
            PL_VIP_BP_MOVEMENT pvbm
        INNER JOIN PM_VIP pv
            ON pv.VIP_NO=pvbm.VIP_NO AND pv.VIP_CLUSTER_ID_FK=pvbm.VIP_CLUSTER_ID_PK
        group by
            pvbm.COMPANY_CODE , pvbm.VIP_NO, pv.VIP_ID, pvbm.EXPIRY_DATE ) TOTAL
group by
    COMPANY_CODE ,
    VIP_ID,
    VIP_NO,
    EXPIRY_DATE
