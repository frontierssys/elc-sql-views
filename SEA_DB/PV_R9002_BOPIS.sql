-- dbo.PV_R9002_BOPIS source

CREATE   view [dbo].[PV_R9002_BOPIS] as
select
    psm.COMPANY_CODE ,
    psm.TX_DATE,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    count(1) as NUMBER_BOPIS_ORDER_PLACED,
    sum(psm.TOTAL_NET_AMT ) as VALUE_BOPIS_ORDER_PLACED
    ,
    case
        when bopis.PROXY_FIRST_NAME = 'SF Express' then 'Delivery'
        else 'Pickup'
    end as DELIVERY_OR_PICKUP
from PT_SALES_MEMO psm
inner join PM_SALES_MEMO_TYPE psmt
    on psmt.SALES_MEMO_TYPE_ID = psm.SALES_MEMO_TYPE_ID_FK
inner join PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
left join PT_SALES_MEMO_BOPIS_INFO bopis
    on psm.SALES_MEMO_BOPIS_INFO_ID_FK = bopis.SALES_MEMO_BOPIS_INFO_ID
    --left join PT_SALES_MEMO_OOFIS_INFO oofis
    --on oofis.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
where psmt.TYPE_CODE in
    ( '12', '13')
    AND psm.MEMO_STATUS NOT IN ('VOIDED')
    AND psm.MEMO_KIND NOT IN ('RESERVE',
        'handoff')
    and bopis.BOPIS_ORDER_STATUS = 'COLLECTED'
    --	and psm.COMPANY_CODE = 'HKEL'
    --	and psm.TX_DATE >= '2021-12-01'
    --	and pl.LOCATION_CODE = 'HKEL0026'
group by
    psm.COMPANY_CODE ,
    psm.TX_DATE,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC
    ,
    case
        when bopis.PROXY_FIRST_NAME = 'SF Express' then 'Delivery'
        else 'Pickup'
    end
