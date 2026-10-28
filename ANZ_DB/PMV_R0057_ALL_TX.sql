CREATE   VIEW  PMV_R0057_ALL_TX
as
select
    psm.COMPANY_CODE,
    pc.COMPANY_DESC as DIVISION,
    pst.STORE_TYPE_CODE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME ,
    pl.ADDRESS1 + pl.ADDRESS2 + pl.ADDRESS3 as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME,
    CAST (psm.TX_DT as date) as TX_DATE,
    count(DISTINCT psm.MEMO_NO ) as MEMO_COUNT,
    sum(psm.TOTAL_NET_AMT ) as TOTAL_AMOUNT
from PT_SALES_MEMO psm
inner join PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_COMPANY pc
    on psm.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    --where psmt.TYPE_CODE = '09'
where
--psmt.TYPE_CODE not in ('03','04','05','06','07','10','11','99','08')
--and psm.MEMO_STATUS not in ('VOIDED')
    psm.MEMO_KIND not in ('RESERVE', 'handoff')
group by
    psm.COMPANY_CODE,
    pc.COMPANY_DESC ,
    pst.STORE_TYPE_CODE,
    pst.STORE_TYPE_NAME ,
    pl.ADDRESS1 + pl.ADDRESS2 + pl.ADDRESS3 ,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    CAST (psm.TX_DT as date)
