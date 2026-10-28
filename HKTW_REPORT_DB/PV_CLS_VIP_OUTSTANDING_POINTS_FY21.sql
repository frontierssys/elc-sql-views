CREATE   view PV_CLS_VIP_OUTSTANDING_POINTS_FY21 as
select
    COMPANY_CODE ,
    VIP_NO,
    case
        when company_code in ('HKAR', 'HKCM', 'HKEL', 'HKOR' ) then '20210630'
        ELSE '20210731'
    end as EXPIRY_DATE,--MAX(EXPIRY_DATE),
    --FORMAT(GETDATE(), 'yyyyMMdd') as AS_OF_DATE,
    --	MAX()
    sum(points) as POINTS
from
    (
        select
            COMPANY_CODE , VIP_NO, EXPIRY_DATE, points
        from
            (
                select
                    pv.COMPANY_CODE , pv.VIP_NO , null as expiry_date, pvbb.BALANCE_DT , pvbb.BALANCE as points, ROW_NUMBER() over (
                        PARTITION by pvbb.VIP_ID_FK
                        order by
                            pvbb.BALANCE_DT desc) rn
                from
                    PL_VIP_BP_BALANCE pvbb
                inner join PM_VIP pv on
                    pv.VIP_ID = pvbb.VIP_ID_FK
                    and pv.STATUS = 'ACTIVE'
                inner join CLS_BRAND_SCOPE cbs on
                    pvbb.COMPANY_CODE = cbs.COMPANY_CODE
                    and cbs.HAS_LOYALTY = 'Y'
                where (pvbb.COMPANY_CODE <> 'HKCL' and pvbb.BALANCE_DT < '2021-07-01') or (pvbb.COMPANY_CODE = 'HKCL' and pvbb.BALANCE_DT < '2021-08-01')
            ) bal
        where
            bal.rn = 1
        union all
        select
            pvbm.COMPANY_CODE , pvbm.VIP_NO , pvbm.EXPIRY_DATE, sum(pvbm.POINT_MOVEMENT) as points
        from
            PL_VIP_BP_MOVEMENT pvbm
        inner join CLS_BRAND_SCOPE cbs on
            pvbm.COMPANY_CODE = cbs.COMPANY_CODE
            and cbs.HAS_LOYALTY = 'Y'
        inner join PM_VIP pv on
            pv.COMPANY_CODE = pvbm.COMPANY_CODE
            and pv.VIP_NO = pvbm.VIP_NO
            and pv.STATUS = 'ACTIVE'
        where (pvbm.COMPANY_CODE <> 'HKCL' and pvbm.MOVEMENT_DT < '2021-07-01') or (pvbm.COMPANY_CODE = 'HKCL' and pvbm.MOVEMENT_DT  < '2021-08-01')
        group by
            pvbm.COMPANY_CODE , pvbm.VIP_NO, pvbm.EXPIRY_DATE ) TOTAL
group by
    COMPANY_CODE ,
    VIP_NO;
