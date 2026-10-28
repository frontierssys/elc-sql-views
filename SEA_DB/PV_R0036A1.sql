CREATE    view PV_R0036A1 as
-- View to get the points movement report by COMPANY_CODE,VIP_GRADE_CODE and MOVEMENT_DT
-- PV_R0036VJ is the only view that is being called inside this view
select
    LEFT(pvj1.COMPANY_CODE,	2) as AFFILIATE_CODE,
    pvj1.COMPANY_CODE,
    pvj1.VIP_GRADE_CODE,
    pvj1.MOVEMENT_DT,
    pvj1.CLOSING_PTS_BAL-pvj2.ISSUED_PTS-pvj2.REDEEM_PTS-pvj2.EXPIRED_PTS-pvj2.ADJUSTMENT_PTS as BEGIN_PTS_BAL,
    pvj2.REDEEM_PTS,
    pvj2.EXPIRED_PTS,
    pvj2.ADJUSTMENT_PTS,
    pvj2.ISSUED_PTS,
    pvj1.CLOSING_PTS_BAL
from
    (
        select
            a.COMPANY_CODE,
            a.VIP_GRADE_CODE,
            a.MOVEMENT_DT,
            sum(b.tot_pts) as CLOSING_PTS_BAL
        from
            PV_R0036A1_SUB a
        inner join PV_R0036A1_SUB b on
            a.COMPANY_CODE = b.COMPANY_CODE
            and a.VIP_GRADE_CODE = b.VIP_GRADE_CODE
            and b.MOVEMENT_DT <= a.MOVEMENT_DT
        group by
            a.COMPANY_CODE,
            a.VIP_GRADE_CODE,
            a.MOVEMENT_DT
    ) pvj1
LEFT JOIN PV_R0036A1_SUB pvj2 on
    pvj1.COMPANY_CODE = pvj2.COMPANY_CODE
    and pvj1.VIP_GRADE_CODE = pvj2.VIP_GRADE_CODE
    and pvj1.MOVEMENT_DT = pvj2.MOVEMENT_DT;
