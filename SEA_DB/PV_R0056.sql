-- dbo.PV_R0056 source

CREATE view [dbo].[PV_R0056] as
select
    psm.COMPANY_CODE as COMPANY_CODE,
    Cast(psm.TX_DT as date) as TX_DATE,
    pl.LOCATION_CODE as LOCATION_CODE,
    pl.LOCATION_NAME as LOCATION_NAME,
    psm.CRE_BY as EMPLOYEE_CODE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    psm.CRE_BY as BA_ID_VOID,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as BA_NAME_VOID,
    psm.AUTH_BY as AUTH_ROLE_ID,
    ps2.FIRST_NAME + ' ' + ps2.LAST_NAME  as AUTH_ROLE_NAME,
    ps3.STAFF_CODE as BA_ID_ORIGINAL,
    ps3.FIRST_NAME + ' ' + ps2.LAST_NAME  as BA_NAME_ORIGINAL,
    pr.REASON_DESC as REASON_CODE,
    COUNT(1) as REASON_CODE_COUNT     -- This is the count under each reason (In the report template, Reason Code 1, Reason Code 2, ....)
FROM
    PT_SALES_MEMO psm
inner join PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join PT_SALES_MEMO psmori on
    psmori.SALES_MEMO_ID = psm.ORI_SALES_MEMO_ID_PK
inner join PM_LOCATION pl on
    pl.LOCATION_ID = psm.LOCATION_ID_FK
inner join PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_REASON pr
    on psm.VOID_REASON = pr.REASON_CODE
    and psm.COMPANY_CODE = pr.COMPANY_CODE
left join PM_STAFF ps on
    ps.COMPANY_CODE =psm.COMPANY_CODE
    and psm.CRE_BY = ps.STAFF_CODE
left join PM_STAFF ps2 on
    ps2.COMPANY_CODE = psm.COMPANY_CODE
    and ps2.STAFF_CODE = psm.AUTH_BY
left join PM_STAFF ps3 on
    ps3.COMPANY_CODE = psm.COMPANY_CODE
    and ps3.STAFF_CODE = psmori.CRE_BY
where psmt.TYPE_CODE = '09'
group by
    psm.COMPANY_CODE ,
    Cast(psm.TX_DT as date) ,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    psm.CRE_BY ,
    pst.STORE_TYPE_CODE ,
    psm.CRE_BY ,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME ,
    psm.AUTH_BY ,
    ps2.FIRST_NAME + ' ' + ps2.LAST_NAME  ,
    ps3.STAFF_CODE ,
    ps3.FIRST_NAME + ' ' + ps2.LAST_NAME  ,
    pr.REASON_DESC
