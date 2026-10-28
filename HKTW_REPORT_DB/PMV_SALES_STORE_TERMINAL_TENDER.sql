create   view [dbo].[PMV_SALES_STORE_TERMINAL_TENDER] as
select
    sum(ih.QTY) as QTY,
    sum(psmp.AMOUNT ) AS SALES_AMT ,
    count(DISTINCT psm.SALES_MEMO_ID ) as MEMO_COUNT,
    psm.COMPANY_CODE ,
    cast(psm.TX_DT as date) as TX_DATE,
    pl.LOCATION_CODE ,
    pt2.TERMINAL_NO ,
    pt.TENDER_CODE ,
    pt.TENDER_NAME
from PT_SALES_MEMO psm
inner join PT_SALES_MEMO_PAYMENT psmp
    on psmp.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join
    (
        select psmih.SALES_MEMO_ID_FK , sum(psmih.qty) as QTY
        from PT_SALES_MEMO_ITEM_H psmih
        group by psmih.SALES_MEMO_ID_FK
    ) ih on ih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join PM_TENDER pt
    on psmp.TENDER_ID_FK = pt.TENDER_ID
inner join PM_LOCATION pl
    on pl.LOCATION_ID = psm.LOCATION_ID_FK
inner join PM_TERMINAL pt2
    on pt2.TERMINAL_ID = psm.TERMINAL_ID_FK
group by
    psm.COMPANY_CODE ,
    cast(psm.TX_DT as date),
    pl.LOCATION_CODE ,
    pt2.TERMINAL_NO ,
    pt.TENDER_CODE ,
    pt.TENDER_NAME
