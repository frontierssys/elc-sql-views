CREATE   view [dbo].[PMV_SALES_GROSS_BY_TRANSACTION]
--WITH SCHEMABINDING
AS
select
    psm.SALES_MEMO_ID as SALES_MEMO_ID,
    sum(psmih.CUR_RETAIL_PRICE * psmih.qty) as 'SALES_GROSS_AMT'
from dbo.PT_SALES_MEMO_ITEM_H psmih
inner join dbo.PT_SALES_MEMO psm
    on psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join dbo.PM_SKU ps
    on psmih.SKU = ps.SKU_CODE
    and psmih.COMPANY_CODE = ps.COMPANY_CODE
group by
    psm.SALES_MEMO_ID
