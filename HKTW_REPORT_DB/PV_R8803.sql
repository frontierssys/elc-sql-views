-- dbo.PV_R8803 source


CREATE   view PV_R8803 as
select
    prs.COMPANY_CODE ,
    prs.BRAND_CODE ,
    prs.BRAND_DESC ,
    prs.LOCATION_CODE ,
    prs.LOCATION_DESC ,
    prs.STAFF_NO ,
    prs.FIRST_NAME ,
    prs.F_TX_DT ,
    prs.WEEK_NAME ,
    prs.TG_AMT ,
    prs.NET_LINE_AMT ,
    case
        when TG_AMT = 0 and prs.NET_LINE_AMT > 0 then 100
        when TG_AMT = 0 and prs.NET_LINE_AMT = 0 then 100
        else prs.NET_LINE_AMT /prs.TG_AMT
    end as DAILY_COMP_PCT,
    0 as CUMULATIVE_COMP_PCT,
    0 as CUMULATIVE_ADD,
    prs.PERSON_COUNT ,
    prs.SAL_QTY ,
    0 as CUST_UNIT_PRICE,
    0 as CUST_QTY,
    0 as CUMULATIVE_TG_AMT,
    0 as CUMULATIVE_LINE_AMT
    --	sum(prs.TG_AMT) over(partition by prs.COMPANY_CODE ,prs.BRAND_CODE ,prs.LOCATION_CODE , prs.FIRST_NAME order by prs.F_TX_DT) as CUMULATIVE_TG_AMT,
    --	sum(prs.NET_LINE_AMT) over(partition by prs.COMPANY_CODE ,prs.BRAND_CODE ,prs.LOCATION_CODE , prs.FIRST_NAME order by prs.F_TX_DT)  as CUMULATIVE_LINE_AMT
from
    PV_R8803_SUB prs;
