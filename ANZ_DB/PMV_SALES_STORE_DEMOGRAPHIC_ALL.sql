CREATE   VIEW  PMV_SALES_STORE_DEMOGRAPHIC_ALL as
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
    isnull(pstd.TARGET_AMOUNT,0) as TARGET_AMOUNT,
    pssdvv.SALE_OR_RETURN ,
    pssdvv.[Customer Type] ,
    pssdvv.DEMOGRAPHIC ,
    pssdvv.SALES_GROSS_AMT ,
    pssdvv.SALES_NET_AMT ,
    pssdvv.QTY ,
    pssdvv.MEMO_COUNT
FROM
    PCV_SALES_STORE_DEMOGRAPHIC_ALL pssdvv
LEFT JOIN PV_COMPANY_LOCATION_DETAIL pcld ON
    pssdvv.COMPANY_CODE = pcld.COMPANY_CODE
    AND pssdvv.location_code = pcld.location_code
left join PV_SALES_TARGET_DAILY pstd on
    pstd.LOCATION_CODE = pssdvv.location_code
    and pstd.COMPANY_CODE = pssdvv.company_code
    and pstd.TX_DATE = pssdvv.tx_date
    --where pssdvv.COMPANY_CODE = 'HKMC'
    --and pssdvv.TX_DATE >= '2021-04-01';






    -- dbo.PMV_SALES_STORE_DEMOGRAPHIC_VIP source
