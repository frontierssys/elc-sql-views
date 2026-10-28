CREATE   view PV_RDI_LOYALTY_STATUS as
select
    pv.COMPANY_CODE,
    pc.COUNTRY_CODE_ISO3,
    pv.VIP_NO,
    pva.VIP_CBR_ID,
    plp.PROGRAM_CODE,
    plp.PROGRAM_DESC,
    pvg.VIP_GRADE_CODE,
    pvg.VIP_GRADE_DESCRIPTION,
    pv.APPLY_LOCATION,
    pvt.START_DATE,
    pvt.EXPIRY_DAY,
    pv.STATUS,
    case
        when pcvop.POINTS is null then 0
        else pcvop.POINTS
    end as POINT,
    pvbm.MOVEMENT_DT
FROM PM_VIP pv
left join PL_VIP_BP_MOVEMENT pvbm on pvbm.COMPANY_CODE = pv.COMPANY_CODE and pvbm.VIP_NO = pv.VIP_NO
INNER join PM_VIP_TYPE pvt on pv.VIP_TYPE_ID_FK = pvt.VIP_TYPE_ID
INNER join PM_VIP_GRADE pvg on pvt.VIP_GRADE_ID_FK = pvg.VIP_GRADE_ID
INNER join PM_LOCATION pl on   pl.COMPANY_CODE = pv.COMPANY_CODE and   pl.LOCATION_CODE = pv.APPLY_LOCATION
INNER join PM_COUNTRY pc on pl.COUNTRY_ID_FK = pc.COUNTRY_ID
INNER join PM_LOYALTY_PROGRAM plp on plp.LOYALTY_PROGRAM_ID = pv.LOYALTY_PROGRAM_ID_HK
left join PV_CLS_VIP_OUTSTANDING_POINTS pcvop on pcvop.COMPANY_CODE = pv.COMPANY_CODE and pcvop.VIP_NO = pv.VIP_NO
left join PM_VIP_ALT pva on pva.COMPANY_CODE = pv.COMPANY_CODE and pva.VIP_ALT_SYSTEM = 'FRONTIERS' and pva.VIP_ALT_KEY = pv.VIP_NO
