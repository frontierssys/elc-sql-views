CREATE   view [dbo].[TW_TOTAL_PTS_BY_VIP] as
select pvj.*, pvj.ISSUED_PTS+pvj.REDEEM_PTS+pvj.EXPIRED_PTS+pvj.ADJUSTMENT_PTS as tot_pts
from (
    select COMPANY_CODE, VIP_GRADE_CODE,VIP_NO ,
        isnull(sum([REDEEM]), 0) as REDEEM_PTS,
        isnull(sum([EXPIRED]), 0) as EXPIRED_PTS,
        isnull(sum([ADJUSTMENT]), 0) as ADJUSTMENT_PTS,
        isnull(sum([ISSUED]), 0) as ISSUED_PTS
    from (
        SELECT pvbm.COMPANY_CODE, pvg.VIP_GRADE_CODE, pvbm.VIP_NO,
            CONVERT(DATE, pvbm.MOVEMENT_DT) as MOVEMENT_DT, pvbm.POINT_MOVEMENT,
            CASE
                WHEN pvbm.MOVEMENT_TYPE ='GIFT' then 'REDEEM'
                WHEN pvbm.MOVEMENT_TYPE ='EXPIRE_DATE_RESET' then 'EXPIRED'
                WHEN pvbm.MOVEMENT_TYPE ='ADJUSTMENT' then 'ADJUSTMENT'
                ELSE 'ISSUED'
            END as TRANS_TYPE
        FROM PL_VIP_BP_MOVEMENT pvbm
        LEFT JOIN PV_VIP_GRADE pvg ON pvg.COMPANY_CODE=pvbm.COMPANY_CODE and pvg.VIP_NO=pvbm.VIP_NO
        --where pvbm.VIP_NO in ('01000050343','01000050737')
        UNION ALL
        SELECT DISTINCT pvbm.COMPANY_CODE, pvg.VIP_GRADE_CODE, pvbm.VIP_NO,CONVERT(DATE, pvb.BALANCE_DT) as MOVEMENT_DT,
            pvb.BALANCE as POINT_MOVEMENT, 'ISSUED' as TRANS_TYPE
        FROM PL_VIP_BP_MOVEMENT pvbm
        LEFT JOIN PV_VIP_GRADE pvg ON pvg.COMPANY_CODE=pvbm.COMPANY_CODE and pvg.VIP_NO=pvbm.VIP_NO
        LEFT JOIN PM_VIP pv on pv.COMPANY_CODE =pvbm.COMPANY_CODE and pv.VIP_NO =pvbm.VIP_NO
        INNER JOIN PL_VIP_BP_BALANCE pvb on pv.COMPANY_CODE = pvb.COMPANY_CODE
            and pv.VIP_ID = pvb.VIP_ID_FK and pvb.BALANCE_DT <= pvbm.MOVEMENT_DT
            --where pvbm.VIP_NO in ('01000050343','01000050737')
    ) d
    PIVOT (	SUM(POINT_MOVEMENT)
        for TRANS_TYPE in ([REDEEM], [EXPIRED], [ADJUSTMENT], [ISSUED])
    ) piv
    group by COMPANY_CODE, VIP_GRADE_CODE, VIP_NO
) pvj
