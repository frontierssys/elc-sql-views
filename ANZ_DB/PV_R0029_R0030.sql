CREATE   VIEW dbo.PV_R0029_R0030 AS
SELECT
    [Customer Type] ,
    COMPANY_CODE,
    COMPANY_DESC,
    location_code,
    LOCATION_DESC,
    Address ,
    STORE_TYPE_NAME,
    DEMOGRAPHIC,
    TX_DATE,
    SALES_NET_AMT as SALES_AMT,
    QTY,
    MEMO_COUNT
From PV_R0001_STORE prs
where prs.IS_REVENUE_ITEM ='Y'
--and TX_DATE>='2021-02-01' and TX_DATE <='2021-02-28'
--and location_code like 'HKCM%';


-- dbo.PV_R0029_R0030_BAK source
