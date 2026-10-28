CREATE   VIEW  [dbo].[PV_R0004] AS
select
    prrv.COMPANY_CODE ,
    prrv.COMPANY_DESC ,
    prrv.location_code ,
    prrv.LOCATION_DESC ,
    prrv.Address ,
    prrv.STORE_TYPE_NAME ,
    prrv.TX_DATE ,
    prrv.DEMOGRAPHIC ,
    prrv.IS_REVENUE_ITEM ,
    prrv.SALE_OR_RETURN ,
    --SALES_GROSS_AMT ,
    case
        when prrv.SALE_OR_RETURN = 'RETURN' then 0
        else prrv.SALES_GROSS_AMT
    end as SALES_GROSS_AMT,
    prrv.SALES_NET_AMT as SALES_AMT,
    prrv.QTY ,
    prrv.MEMO_COUNT ,
    prrv.SALES_NET_AMT - prrv.SALES_GROSS_AMT as DISCOUNT,
    pstm.TARGET_AMOUNT as SALES_TARGET
from
    PMV_SALES_STORE_DEMOGRAPHIC_VIP_V2 prrv
left join PV_SALES_TARGET_MONTHLY pstm
    on pstm.COMPANY_CODE = prrv.COMPANY_CODE
    and pstm.LOCATION_CODE = prrv.location_code
    and pstm.TX_MONTH = datepart(month, prrv.TX_DATE )
    and pstm.TX_YEAR = datepart(year, prrv.TX_DATE )
union
select
    prrw.COMPANY_CODE ,
    prrw.COMPANY_DESC ,
    prrw.location_code ,
    prrw.LOCATION_DESC ,
    prrw.Address ,
    prrw.STORE_TYPE_NAME ,
    prrw.TX_DATE ,
    prrw.DEMOGRAPHIC ,
    prrw.IS_REVENUE_ITEM ,
    prrw.SALE_OR_RETURN ,
    --	SALES_GROSS_AMT ,
    case
        when prrw.SALE_OR_RETURN = 'RETURN' then 0
        else prrw.SALES_GROSS_AMT
    end as SALES_GROSS_AMT,
    prrw.SALES_NET_AMT as SALES_AMT,
    prrw.QTY ,
    prrw.MEMO_COUNT ,
    prrw.SALES_NET_AMT - prrw.SALES_GROSS_AMT as DISCOUNT,
    pstm.TARGET_AMOUNT as SALES_TARGET
from
    PMV_SALES_STORE_DEMOGRAPHIC_WALKIN_V2 prrw
left join PV_SALES_TARGET_MONTHLY pstm
    on pstm.COMPANY_CODE = prrw.COMPANY_CODE
    and pstm.LOCATION_CODE = prrw.location_code
    and pstm.TX_MONTH = datepart(month, prrw.TX_DATE )
    and pstm.TX_YEAR = datepart(year, prrw.TX_DATE );
