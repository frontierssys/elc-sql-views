-- dbo.PV_R9002_FSS source

create   view [dbo].[PV_R9002_FSS] as
select
    psm.COMPANY_CODE ,
    psm.TX_DATE,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    count(
        case
            when psmt.TYPE_CODE in ( '01', '02') then 1
            else null
        end) as NUMBER_FSS_ORDER_PLACED,
    sum(
        case
            when psmt.TYPE_CODE in ( '01', '02') then psm.TOTAL_NET_AMT
            else 0
        end ) as VALUE_FSS_ORDER_PLACED
from PT_SALES_MEMO psm
inner join PM_SALES_MEMO_TYPE psmt
    on psmt.SALES_MEMO_TYPE_ID = psm.SALES_MEMO_TYPE_ID_FK
inner join PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
    --left join PT_SALES_MEMO_BOPIS_INFO bopis
    --on psm.SALES_MEMO_BOPIS_INFO_ID_FK = bopis.SALES_MEMO_BOPIS_INFO_ID
    --left join PT_SALES_MEMO_OOFIS_INFO oofis
    --on oofis.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
where
--psmt.TYPE_CODE in ( '01', '02') AND
    psm.MEMO_STATUS NOT IN ('VOIDED')
    AND psm.MEMO_KIND NOT IN ('RESERVE',
        'handoff')
        -- and psm.COMPANY_CODE = 'HKCS'
        -- and psm.TX_DATE >= '2022-10-01'
        -- and pl.LOCATION_CODE = 'HKEL0026'
group by
    psm.COMPANY_CODE ,
    psm.TX_DATE,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC
