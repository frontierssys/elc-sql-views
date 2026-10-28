CREATE   VIEW PV_R8801_CURRENT as
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
group by
    psm.COMPANY_CODE ,
    psm.TX_DATE ,
    psm.LOCATION_ID_FK ,
    psmih.SKU
