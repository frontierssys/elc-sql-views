CREATE     view [dbo].[PMV_SALES_STORE_STAFF_DEMOGRAPHIC_ALL] as
SELECT
    pssdvv.COMPANY_CODE AS COMPANY_CODE,
    pcld.COMPANY_DESC ,
    pssdvv.location_code ,
    pcld.LOCATION_DESC ,
    pcld.LOCATION_NAME ,
    pcld.Address ,
    pcld.STORE_TYPE_NAME,
    pssdvv.IS_REVENUE_ITEM ,
    pssdvv.TX_DATE AS TX_DATE,
    pssdvv.STAFF_CODE as EMPLOYEE_ID,
    ps.FIRST_NAME +' '+ps.LAST_NAME as EMPLOYEE_NAME,
    isnull(pstd.TARGET_AMOUNT,0) as TARGET_AMOUNT,
    pssdvv.SALE_OR_RETURN ,
    pssdvv.[Customer Type] as CUSTOMER_TYPE,
    pssdvv.DEMOGRAPHIC ,
    pssdvv.SALES_GROSS_AMT ,
    pssdvv.SALES_NET_AMT ,
    pssdvv.QTY ,
    isnull(psssdat.MEMO_COUNT,0) as MEMO_COUNT ,
    pssdvv.SALES_NET_AMT - pssdvv.SALES_GROSS_AMT as DISCOUNT
FROM
    PCV_SALES_STORE_STAFF_DEMOGRAPHIC_ALL pssdvv
LEFT JOIN PCV_SALES_STORE_STAFF_DEMOGRAPHIC_ALL_TXCOUNT psssdat
    ON  psssdat.location_code=pssdvv.location_code
    and psssdat.TX_DATE=pssdvv.TX_DATE
    and psssdat.SALE_OR_RETURN=pssdvv.SALE_OR_RETURN
    and psssdat.DEMOGRAPHIC=pssdvv.DEMOGRAPHIC
    and psssdat.STAFF_CODE=pssdvv.STAFF_CODE
    and psssdat.IS_REVENUE_ITEM='Y'
    and pssdvv.IS_REVENUE_ITEM='Y'
    and psssdat.[Customer Type] = pssdvv.[Customer Type]
LEFT JOIN PV_COMPANY_LOCATION_DETAIL pcld ON
    pssdvv.COMPANY_CODE = pcld.COMPANY_CODE
    AND pssdvv.location_code = pcld.location_code
left join PV_SALES_TARGET_DAILY pstd on
    pstd.LOCATION_CODE = pssdvv.location_code
    and pstd.COMPANY_CODE = pssdvv.company_code
    and pstd.TX_DATE = pssdvv.tx_date
inner join PM_STAFF ps on
    ps.COMPANY_CODE = pssdvv.COMPANY_CODE
    and ps.STAFF_CODE = pssdvv.STAFF_CODE
    /*WHERE 	pssdvv .COMPANY_CODE = 'HKCM'
    and pssdvv .LOCATION_CODE ='HKCM0012'
    and pssdvv .TX_DATE = '2021-04-08'*/
