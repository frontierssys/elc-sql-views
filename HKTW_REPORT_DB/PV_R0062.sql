CREATE   view [dbo].[PV_R0062] as
SELECT
    putr.COMPANY_CODE ,
    -- ADD
    --pl.LOCATION_CODE,
    -- ADD
    putr.CRE_DATET as TX_DATE,
    pu.USER_CODE as EMPLOYEE_ID,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as EMPLOYEE_NAME,
    prori.DESCRIPTION as EMPLOYEE_PRIOR_ROLE,
    praft.DESCRIPTION as EMPLOYEE_NEW_ROLE,
    putr.EFFECTIVE_DT as START_DATE,
    putr.END_DT as END_DATE,
    putr.CRE_DATET as REQUEST_DATE,
    putr.CRE_BY as REQUESTER_ID,
    ps2.FIRST_NAME + ' ' + ps2.LAST_NAME as REQUESTER_NAME,
    pu3.USER_CODE as APPROVER_ID,
    ps3.FIRST_NAME + ' ' + ps3.LAST_NAME as APPROVER_NAME,
    putr.REASON as REASON,
    putr.UPDATE_DATET as APPROVAL_DATE
from PM_USER_TEMP_ROLE putr
inner join PM_USER pu
    on putr.USER_ID_FK = pu.USER_ID
inner join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
inner join PM_USER_ROLE purori
    on pu.USER_ID = purori.USER_ID_FK
inner join PM_ROLE prori
    on prori.ROLE_ID = purori.ROLE_ID_FK
inner join PM_ROLE praft
    on putr.ROLE_ID_FK = praft.ROLE_ID
    --ADD
    --left join PM_LOCATION pl
    --on pl.COMPANY_CODE = putr.COMPANY_CODE
    --ADD
left join PM_USER pu2
    on pu2.COMPANY_CODE = putr.COMPANY_CODE
    and pu2.USER_CODE = putr.CRE_BY
left join PM_STAFF ps2
    on pu2.STAFF_ID_FK = ps2.STAFF_ID
left join PM_USER pu3
    on putr.COMPANY_CODE = pu3.COMPANY_CODE
    and putr.APPROVED_BY = pu3.USER_CODE
left join PM_STAFF ps3
    on pu3.STAFF_ID_FK = ps3.STAFF_ID
