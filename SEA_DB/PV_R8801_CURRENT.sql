-- dbo.PV_R8801_CURRENT source

-- dbo.PV_R8801_CURRENT source

create   view [dbo].[PV_R8801_CURRENT] as
select
    psm.COMPANY_CODE ,
    psm.TX_DATE ,
    psm.LOCATION_ID_FK ,
    psmih.SKU ,
    sum(psmih.QTY ) QTY,
    sum(psmih.NET_LINE_AMT) AMOUNT
from PT_SALES_MEMO psm
inner join PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
inner join PM_SALES_MEMO_TYPE psmt on
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
left join PT_SALES_MEMO_PAYMENT psmp
    on psmp.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
    and psmp.DEPOSIT_NO is not null
where
    psmt.TYPE_CODE not in ('05', '06', '07', '09', '10', '11', '99', '08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.PICKUP_STATUS <> 'PICKUPED'
    and psmp.DEPOSIT_NO is null
group by
    psm.COMPANY_CODE ,
    psm.TX_DATE ,
    psm.LOCATION_ID_FK ,
    psmih.SKU
