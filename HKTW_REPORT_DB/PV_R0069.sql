CREATE   view [dbo].[PV_R0069] as
--REPORT CRITERIA
-- DIVISION (COMPANY_CODE )
-- STORE ID (LOCATION_CODE)
-- DATE RANGE (FROM DATE , TO DATE)
select
    psm.COMPANY_CODE as COMPANY_CODE,
    pc.FIRSTNAME as GIVEN_NAME,
    pc.SURNAME as LAST_NAME,
    pv.VIP_NO as VIP_CODE,
    --pcs.TEL1 as MOBILE,
    CONCAT((COALESCE (pc.CELLPHONE_AREA_CODE,pc.CELLPHONE_COUNTRY_CODE)),' ',pcs.TEL1) as MOBILE,
    pl.LOCATION_CODE as LOCATION_CODE,
    pl.LOCATION_CODE as STORE_CODE,
    pl.LOCATION_DESC as STORE_NAME,
    psm.COMPANY_CODE as BRAND,
    pcs.EMAIL as EMAIL,
    --cast(psm.TX_DT as date) as TX_DATE,
    FORMAT(psm.TX_DATE,'MM/dd/yyyy') as TX_DATE,
    ps22.STAFF_CODE as BA_CODE,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME as BA_NAME,
    isnull(pn.DESCRIPTION, pcs.COUNTRY_RESIDENCE ) as NATIONALITY,
    --cast(pv.APPLY_DATE as date) as REGISTRATION_DATE,
    FORMAT(pv.APPLY_DATE,'MM/dd/yyyy') as REGISTRATION_DATE,
    isnull(pcs.AGE_GRP,'') as AGE_GROUP,
    isnull(pc.LANG, '') as PREFERRED_LANGUAGE,
    --pl.LOCATION_CODE AS FROM_DATE,
    --pl.LOCATION_CODE AS TO_DATE,
    sum(psmih.QTY )as TOTAL_QTY,
    sum(psm.TOTAL_NET_AMT) as NET_SALES_AMT
from PT_SALES_MEMO psm
inner join PT_SALES_MEMO_ITEM_H psmih
    on psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join PM_VIP pv
    on pv.COMPANY_CODE = psm.COMPANY_CODE
    and pv.VIP_NO = psm.VIP_NO
inner join PM_CUSTOMER pc
    on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
inner join PM_CUSTOMER_SECRET pcs
    on pcs.CUSTOMER_ID_FK = pc.CUSTOMER_ID
inner join PM_SALES_MEMO_TYPE psmt
    on psmt.SALES_MEMO_TYPE_ID  = psm.SALES_MEMO_TYPE_ID_FK
inner join PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PT_MEMO_ITEM_STAFF_SET pmiss
    on psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
inner join dbo.PT_SALES_MEMO_ITEM_STAFF psmis
    on psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
inner join dbo.PM_STAFF ps22
    on ps22.COMPANY_CODE = psmis.COMPANY_CODE
    and ps22.STAFF_CODE = psmis.STAFF_NO
left join PM_NATION pn
    on pcs.COMPANY_CODE = pn.COMPANY_CODE
    and pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.VIP_NO is not NULL
    and psm.TOTAL_NET_AMT > 0
group by
    psm.COMPANY_CODE ,
    pc.FIRSTNAME ,
    pc.SURNAME ,
    pv.VIP_NO ,
    --pcs.TEL1 ,
    CONCAT((COALESCE (pc.CELLPHONE_AREA_CODE,pc.CELLPHONE_COUNTRY_CODE)),' ',pcs.TEL1),
    pl.LOCATION_CODE ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    psm.COMPANY_CODE ,
    pcs.EMAIL ,
    --cast(psm.TX_DT as date) ,
    FORMAT(psm.TX_DATE,'MM/dd/yyyy'),
    ps22.STAFF_CODE ,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME ,
    isnull(pn.DESCRIPTION, pcs.COUNTRY_RESIDENCE ) ,
    --cast(pv.APPLY_DATE as date) ,
    FORMAT(pv.APPLY_DATE,'MM/dd/yyyy'),
    isnull(pcs.AGE_GRP,'') ,
    isnull(pc.LANG, '')
