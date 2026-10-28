CREATE   view [dbo].[PV_R0065] as
select
    LEFT(pu.COMPANY_CODE,2) as AFFILIATE_CODE,
    pu.COMPANY_CODE ,
    pu.USER_CODE ,
    FORMAT(pu.CRE_DATET,'yyyy-MM-dd hh:mm:ss') as TX_DT,
    CASE
        WHEN ps.FIRST_NAME=ps.LAST_NAME then ps.FIRST_NAME
        else ps.FIRST_NAME + ' ' + ps.LAST_NAME
    END as EMPLOYEE_NAME,
    ps.FIRST_NAME + '.'+ LEFT(ps.LAST_NAME , 1) as EMPLOYEE_PRINTED_NAME,
    pr.DESCRIPTION as  SECURITY_ROLE,
    --pu.CRE_DATET as CREATED_DAE,
    FORMAT(pu.CRE_DATET,'yyyy-MM-dd hh:mm:ss') as CREATED_DAE,
    FORMAT(pull.LAST_LOGIN_TIME,'yyyy-MM-dd hh:mm:ss') as LAST_LOGIN_DATE,
    pu.STATUS as STATUS,
    FORMAT(pu.UPDATE_DATET,'yyyy-MM-dd hh:mm:ss') as LAST_MODIFY_DATE,
    pu.UPDATE_BY as LAST_UPDATE_USER_ID,
    pu2.NAME as LAST_MODIFY_USER_NAME
FROM
    PM_USER pu
inner join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
inner join PM_USER_ROLE pur
    on pur.USER_ID_FK = pu.USER_ID
inner join PM_ROLE pr
    on pr.ROLE_ID = pur.ROLE_ID_FK
left join PMV_USER_LAST_LOGIN pull
    on pu.USER_ID = pull.USER_ID
left join PM_USER pu2
    on pu.UPDATE_BY = pu2.USER_CODE
    and pu.COMPANY_CODE = pu2.COMPANY_CODE;
