CREATE   VIEW [dbo].[PMV_SALES_STORE_DEMOGRAPHIC_WALKIN_V2] AS
select
    pssdvv.COMPANY_CODE as COMPANY_CODE,
    pcld.COMPANY_DESC ,
    pssdvv.location_code ,
    pcld.LOCATION_DESC ,
    pcld.LOCATION_NAME ,
    pcld.Address ,
    pcld.STORE_TYPE_NAME,
    pssdvv.IS_REVENUE_ITEM ,
    cast(pssdvv.TX_DATE as date) as TX_DATE,
    0 as TARGET_AMOUNT,
    pssdvv.SALE_OR_RETURN ,
    pssdvv.DEMOGRAPHIC ,
    pssdvv.SALES_GROSS_AMT ,
    pssdvv.SALES_NET_AMT ,
    pssdvv.QTY ,
    isnull(pssdtvv.MEMO_COUNT, 0) as MEMO_COUNT
from
    PXV_SALES_STORE_DEMOGRAPHIC_WALKIN pssdvv
left join PXV_SALES_STORE_DEMOGRAPHIC_TXCOUNT_WALKIN pssdtvv on
    pssdvv.COMPANY_CODE = pssdtvv.COMPANY_CODE
    and pssdvv.location_code = pssdtvv.location_code
    and pssdvv.TX_DATE = pssdtvv.TX_DATE
    and pssdvv.DEMOGRAPHIC = pssdtvv.DEMOGRAPHIC
    and pssdvv.SALE_OR_RETURN = pssdtvv.SALE_OR_RETURN
    and pssdvv.IS_REVENUE_ITEM = 'Y'
left join PV_COMPANY_LOCATION_DETAIL pcld on
    pssdvv.COMPANY_CODE = pcld.COMPANY_CODE
    and pssdvv.location_code = pcld.location_code
where 1=2
UNION ALL
select
    pssdvv.COMPANY_CODE as COMPANY_CODE,
    pcld.COMPANY_DESC ,
    pssdvv.location_code ,
    pcld.LOCATION_DESC ,
    pcld.LOCATION_NAME ,
    pcld.Address ,
    pcld.STORE_TYPE_NAME,
    pssdvv.IS_REVENUE_ITEM ,
    pssdvv.TX_DATE as TX_DATE,
    isnull(pstd.TARGET_AMOUNT, 0) as TARGET_AMOUNT,
    pssdvv.SALE_OR_RETURN ,
    pssdvv.DEMOGRAPHIC ,
    pssdvv.SALES_GROSS_AMT ,
    pssdvv.SALES_NET_AMT ,
    pssdvv.QTY ,
    isnull(pssdtvv.MEMO_COUNT, 0) as MEMO_COUNT
from
    PCV_SALES_STORE_DEMOGRAPHIC_WALKIN pssdvv
left join PCV_SALES_STORE_DEMOGRAPHIC_TXCOUNT_WALKIN pssdtvv on
    pssdvv.COMPANY_CODE = pssdtvv.COMPANY_CODE
    and pssdvv.location_code = pssdtvv.location_code
    and pssdvv.TX_DATE = pssdtvv.TX_DATE
    and pssdvv.DEMOGRAPHIC = pssdtvv.DEMOGRAPHIC
    and pssdvv.SALE_OR_RETURN = pssdtvv.SALE_OR_RETURN
    and pssdvv.IS_REVENUE_ITEM = 'Y'
    AND pssdtvv.IS_REVENUE_ITEM = 'Y'
left join PV_COMPANY_LOCATION_DETAIL pcld on
    pssdvv.COMPANY_CODE = pcld.COMPANY_CODE
    and pssdvv.location_code = pcld.location_code
left join PV_SALES_TARGET_DAILY pstd on
    pstd.LOCATION_CODE = pssdvv.location_code
    and pstd.COMPANY_CODE = pssdvv.company_code
    and pstd.TX_DATE =pssdvv.tx_date
