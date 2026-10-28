CREATE   VIEW  [dbo].[PV_R0065_copy1] AS
select
    pu.COMPANY_CODE ,
    pu.USER_CODE ,
    CONVERT(varchar(10), d.TX_DT, 126) TX_DT,
    d.LOCATION_CODE,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as EMPLOYEE_NAME,
    ps.FIRST_NAME + '.'+ LEFT(ps.LAST_NAME , 1) as EMPLOYEE_PRINTED_NAME,
    pr.DESCRIPTION as  SECURITY_ROLE,
    pu.CRE_DATET as CREATED_DAE,
    pu.LAST_LOGIN_DT as LAST_LOGIN_DATE,
    pu.STATUS as STATUS,
    pu.UPDATE_DATET as LAST_MODIFY_DATE,
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
left join PM_USER pu2
    on pu.UPDATE_BY = pu2.USER_CODE
    and pu.COMPANY_CODE = pu2.COMPANY_CODE
left join
    (
        SELECT
            seq= ROW_NUMBER () over (
                PARTITION by psm.COMPANY_CODE , psm.CASHIER_CODE
                ORDER BY psm.TX_DT DESC ),
            psm.COMPANY_CODE ,
            psm.CASHIER_CODE ,
            pl.LOCATION_CODE ,
            psm.TX_DT
        from PT_SALES_MEMO psm
        inner join PM_LOCATION pl
            on psm.LOCATION_ID_FK = pl.LOCATION_ID
    ) d
    on d.CASHIER_CODE = pu.USER_CODE
    and d.COMPANY_CODE = pu.COMPANY_CODE
    and d.seq = 1
