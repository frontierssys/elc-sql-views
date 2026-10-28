CREATE   view PV_RDI_LOYALTY_TRANSACTION as
select
    pvbm.COMPANY_CODE ,
    case
        when pc.COUNTRY_CODE_ISO3 is not null then pc.COUNTRY_CODE_ISO3
        else
            case
                when left(pvbm.COMPANY_CODE,2) = 'HK' then 'HKG'
                else 'TWN'
            end
    end as COUNTRY_CODE_ISO3,
    pvbm.ORDER_NO ,
    pvbm.VIP_NO ,
    plp.PROGRAM_CODE ,
    pvbm.LOCATION_CODE,
    pvbm.MOVEMENT_DT ,
    pvbm.EXPIRY_DATE ,
    isnull(psm.STAFF_NO, pvbm.CRE_BY ) as BA_NO,
    count( pvbm.VIP_BP_MOVEMENT_ID ) over (
        PARTITION by ORDER_NO  ) as LINE_CNT,
    pvbm.MOVEMENT_TYPE ,
    pvbm.ORDER_TYPE ,
    case
        when  pvbm.LOYALTY_POINT_TYPE in ('BASIC', 'ADJUSTMENT') then 'BASE'
        else 'BONUS'
    end as POINT_TYPE,
    pvbm.LOYALTY_POINT_TYPE as ORIG_POINT_TYPE,
    pvbm.LOYALTY_POINT_RULE_CODE as RULE_CODE,
    POINT_MOVEMENT as POINT,
    psm.POS_MEMO_NO,
    pvbm.REMARKS as REMARK
from PL_VIP_BP_MOVEMENT pvbm
left join PM_LOCATION pl
    on pl.COMPANY_CODE = pvbm.COMPANY_CODE
    and pl.LOCATION_CODE = pvbm.LOCATION_CODE
inner join PM_COMPANY pcomp
    on pvbm.COMPANY_CODE = pcomp.COMPANY_CODE
left join PM_COUNTRY pc
    on pl.COUNTRY_ID_FK = pc.COUNTRY_ID
    and pvbm.LOCATION_CODE = pl.LOCATION_CODE
inner join PM_VIP pv
    on pvbm.COMPANY_CODE = pv.COMPANY_CODE
    and pvbm.VIP_NO = pv.VIP_NO
inner join PM_LOYALTY_PROGRAM plp
    on pv.LOYALTY_PROGRAM_ID_HK = plp.LOYALTY_PROGRAM_ID
left join PT_SALES_MEMO psm
    on pvbm.ORDER_NO = psm.MEMO_NO
