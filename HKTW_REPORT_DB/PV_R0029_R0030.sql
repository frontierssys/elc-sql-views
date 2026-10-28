CREATE   VIEW dbo.PV_R0029_R0030 AS
/*SELECT
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
    where prs.IS_REVENUE_ITEM ='Y'*/
    --and TX_DATE>='2021-02-01' and TX_DATE <='2021-02-28'
    --and location_code like 'HKCM%'
    /*select
    --	a.CUSTOMER_TYPE ,
        a.COMPANY_CODE ,
        a.CUSTOMER_TYPE as [Customer Type],
        pc.COMPANY_DESC ,
        pl.LOCATION_CODE ,
        pl.LOCATION_DESC ,
        pl.LOCATION_NAME ,
        pl.CITY_TXT as ADDRESS,
        pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
        a.IS_REVENUE_ITEM ,
        a.TX_DATE ,
        a.SALE_OR_RETURN ,
        a.DEMOGRAPHIC ,
    --	a.SALES_GROSS_AMT ,
        case when a.SALE_OR_RETURN = 'RETURN' then 0 else a.SALES_GROSS_AMT end as SALES_GROSS_AMT ,
        a.SALES_NET_AMT as SALES_AMT,
        a.QTY ,
        a.MEMO_COUNT,
        a.TX_QTY,
        a.TX_AMT,
        a.SALES_NET_AMT- a.SALES_GROSS_AMT as DISCOUNT
    from
        (
        select
            psssdvv.CUSTOMER_TYPE , psssdvv.COMPANY_CODE , psssdvv.location_code , psssdvv.SKU, psssdvv.IS_REVENUE_ITEM , psssdvv.TX_DATE , 0 as TARGET_AMOUNT,
            --    isnull(psd.RETAIL_PRICE, 0) as SUGGESTED_RETAIL_PRICE,
     psssdvv.SALE_OR_RETURN , psssdvv.DEMOGRAPHIC , psssdvv.SALES_GROSS_AMT , psssdvv.SALES_NET_AMT , psssdvv.QTY , psssdvv.MEMO_COUNT as MEMO_COUNT, psssdvv.QTY as TX_QTY, psssdvv.SALES_NET_AMT as TX_AMT
        from
            PMV_SALES_STORE_SKU_DEMOGRAPHIC_ALL psssdvv ) a
    inner join PM_COMPANY pc on
        a.COMPANY_CODE = pc.COMPANY_CODE
    inner join PM_LOCATION pl on
        a.COMPANY_CODE = pl.COMPANY_CODE
        and a.location_code = pl.LOCATION_CODE
    inner join PM_STORE_TYPE pst on
        pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID*/

select pr.sales_net_amt as SALES_AMT,pr.*
from PMV_R0003 pr
