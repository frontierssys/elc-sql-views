CREATE   VIEW  [dbo].[PV_R0001_STORE_NEW] AS
select
    pssda.[Customer Type] ,
    COMPANY_CODE,
    COMPANY_DESC,
    location_code,
    LOCATION_DESC,
    LOCATION_NAME,
    Address,
    STORE_TYPE_NAME,
    IS_REVENUE_ITEM,
    TX_DATE,
    TARGET_AMOUNT,
    SALE_OR_RETURN,
    DEMOGRAPHIC,
    case
        when SALE_OR_RETURN = 'RETURN' then 0
        else SALES_GROSS_AMT
    end as SALES_GROSS_AMT,
    SALES_NET_AMT,
    QTY,
    MEMO_COUNT,
    SALES_NET_AMT - SALES_GROSS_AMT as DISCOUNT
from
    PMV_SALES_STORE_DEMOGRAPHIC_ALL pssda
