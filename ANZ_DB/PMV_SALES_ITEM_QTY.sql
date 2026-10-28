CREATE   VIEW  PMV_SALES_ITEM_QTY as
select
    psm.SALES_MEMO_ID ,
    sum(psmih.QTY ) as TOTAL_QTY,
    count(psmih.SALES_MEMO_ITEM_H_ID ) as NO_OF_ITEM
from
    PT_SALES_MEMO psm
inner join PT_SALES_MEMO_ITEM_H psmih
    on psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
group by psm.SALES_MEMO_ID
