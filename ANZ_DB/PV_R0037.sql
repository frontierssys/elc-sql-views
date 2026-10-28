CREATE   VIEW  [dbo].[PV_R0037] AS
select
    pc.COMPANY_CODE ,
    pc.COMPANY_DESC ,
    pl.ADDRESS1 + ' ' + pl.ADDRESS2 + ' ' + pl.ADDRESS3 as STORE_LOCATION,
    pl.LOCATION_CODE as LOCATION_CODE,
    pl.LOCATION_NAME as STORE_NAME,
    CAST (pcpuh.CRE_DATET as date) as TX_DATE,
    pt.TENDER_NAME as TX_TYPE,
    pcpuh.TERMINAL_NO as REGISTER,
    pcpuh.TX_NO as TRAN_NO,
    CAST (pcpuh.CRE_DATET as TIME) as TX_TIME,
    pcpuh.CRE_BY as BA_NO,
    ps.FIRST_NAME as BA_NAME,
    pal.AUTH_BY as AUTH_MANAGER_ID,
    ps2.FIRST_NAME as AUTH_MANAGER_NAME,
    pcpuh.DEPOSIT_BAG_NO as DEPSOIT_BAG_NO,
    pcpud.PICK_UP_AMT as PICKUP_AMOUNT,
    pbdbd.TOTAL_USER_AMT as DEPOSIT_AMOUNT,
    CAST(pbd.TX_DT as DATE) as DEPOSIT_DATE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME
    --pbdbh.DEPOSIT_BAG_NO
FROM PT_CASH_PICK_UP_H pcpuh
inner join PT_CASH_PICK_UP_D pcpud
    on pcpud.CASH_PICK_UP_H_ID_FK = pcpuh.CASH_PICK_UP_H_ID

inner join PM_COMPANY pc
    on pcpuh.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl
    on pcpuh.COMPANY_CODE = pl.COMPANY_CODE
    and pcpuh.LOCATION_CODE = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst
    on pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
inner join PM_TENDER pt
    on pcpud.TENDER_ID_FK = pt.TENDER_ID
inner join PL_AUTHORIZATION_LOG pal
    on pcpuh.COMPANY_CODE = pal.COMPANY_CODE
    and pcpuh.TX_NO = pal.AUTH_REF_NO
    and pal.AUTH_FUNCTION = 'performCashPickUp'
left join PM_USER pu
    on pu.COMPANY_CODE = pcpuh.COMPANY_CODE
    and pu.USER_CODE = pcpuh.CRE_BY
left join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
left join PM_USER pu2
    on pu2.COMPANY_CODE = pcpuh.COMPANY_CODE
    and pu2.USER_CODE = pal.AUTH_BY
left join PM_STAFF ps2
    on pu2.STAFF_ID_FK = ps2.STAFF_ID
left join PT_BANK_DEPOSIT_BAG_H pbdbh
    on pcpuh.BANK_DEPOSIT_BAG_H_ID_FK = pbdbh.BANK_DEPOSIT_BAG_H_ID
left join PT_BANK_DEPOSIT_BAG_D pbdbd
    on pbdbd.BANK_DEPOSIT_BAG_H_ID_FK = pbdbh.BANK_DEPOSIT_BAG_H_ID
    and pbdbd.TENDER_ID_FK = pcpud.TENDER_ID_FK
left join PT_BANK_DEPOSIT pbd
    on pbdbh.BANK_DEPOSIT_ID_FK = pbd.BANK_DEPOSIT_ID
