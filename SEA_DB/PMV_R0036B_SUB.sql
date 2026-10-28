CREATE VIEW PMV_R0036B_SUB as
select
    COMPANY_CODE ,
    VIP_GRADE_CODE,
    MOVEMENT_DT as MOVEMENT_DT,
    isnull(sum([NEW]), 0) as NEW_CUST,
    isnull(sum([EXPIRED]), 0) as EXPIRED_CUST
from
    (
        Select ppmdb.COMPANY_CODE , ppmdb.VIP_GRADE_CODE , ppmdb.MOVEMENT_DT , ppmdb.MOVEMENT_TYPE , ppmdb.CONSUMER_COUNT
        from PV_MEMBERSHIP_BY_TIER_MOVEMENT_BY_DAY ppmdb
    ) d
PIVOT
    (
        SUM(CONSUMER_COUNT)
        for MOVEMENT_TYPE in ([NEW], [EXPIRED])
    ) piv
group by
    COMPANY_CODE ,
    VIP_GRADE_CODE ,
    MOVEMENT_DT
