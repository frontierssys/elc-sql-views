CREATE   VIEW PV_R0001_STAFF_OVERVIEW as
select
    psssdvv.CUSTOMER_TYPE ,
    psssdvv.COMPANY_CODE ,
    pc.COMPANY_DESC ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    pl.LOCATION_NAME ,
    pl.CITY_TXT as ADDRESS,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    psssdvv.STAFF_NO as EMPLOYEE_ID,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as EMPLOYEE_NAME,
    psssdvv.TX_DATE ,
    0 as TARGET_AMOUNT,
    psssdvv.SALE_OR_RETURN ,
    psssdvv.DEMOGRAPHIC ,
    psssdvv.SALES_GROSS_AMT ,
    psssdvv.SALES_NET_AMT ,
    psssdvv.QTY ,
    psssdvv.TX_COUNT as MEMO_COUNT,
    psssdvv.ITEM_COUNT as TX_QTY
from
    PMV_SALES_STORE_STAFF_DEMOGRAPHIC_VIP_V2 psssdvv
inner join PM_COMPANY pc on
    psssdvv.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl on
    psssdvv.COMPANY_CODE = pl.COMPANY_CODE
    and psssdvv.location_code = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_STAFF ps on
    ps.COMPANY_CODE = psssdvv.COMPANY_CODE
    and ps.STAFF_CODE = psssdvv.STAFF_NO
where psssdvv.IS_REVENUE_ITEM = 'Y'
UNION ALL
select
    psssdvv.CUSTOMER_TYPE ,
    psssdvv.COMPANY_CODE ,
    pc.COMPANY_DESC ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    pl.LOCATION_NAME ,
    pl.CITY_TXT as ADDRESS,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    psssdvv.STAFF_NO as EMPLOYEE_ID,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as EMPLOYEE_NAME,
    psssdvv.TX_DATE ,
    0 as TARGET_AMOUNT,
    psssdvv.SALE_OR_RETURN ,
    psssdvv.DEMOGRAPHIC ,
    psssdvv.SALES_GROSS_AMT ,
    psssdvv.SALES_NET_AMT ,
    psssdvv.QTY ,
    psssdvv.TX_COUNT as MEMO_COUNT,
    psssdvv.ITEM_COUNT as TX_QTY
from
    PMV_SALES_STORE_STAFF_DEMOGRAPHIC_WALKIN_V2 psssdvv
inner join PM_COMPANY pc on
    psssdvv.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl on
    psssdvv.COMPANY_CODE = pl.COMPANY_CODE
    and psssdvv.location_code = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_STAFF ps on
    ps.COMPANY_CODE = psssdvv.COMPANY_CODE
    and ps.STAFF_CODE = psssdvv.STAFF_NO
where psssdvv.IS_REVENUE_ITEM = 'Y';
