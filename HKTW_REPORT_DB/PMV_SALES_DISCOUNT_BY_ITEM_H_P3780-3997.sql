-- dbo.[PMV_SALES_DISCOUNT_BY_ITEM_H_P3780-3997] source

CREATE   view [PMV_SALES_DISCOUNT_BY_ITEM_H_P3780-3997]
AS
select
    psmih.SALES_MEMO_ITEM_H_ID ,
    stuff((
        SELECT
            DISTINCT ',' + psdh.PROM_CODE_ID
        FROM
            PT_SALES_DISCOUNT_H psdh
        left join PT_SALES_DISCOUNT_D psdd on
            psdd.SALES_DISCOUNT_H_ID_FK = psdh.SALES_DISCOUNT_H_ID
        WHERE
            psdd.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID
        FOR XML PATH('')), 1, 1, '') as DISCOUNT_CODE,
    stuff((
        SELECT
            DISTINCT ',' + psdh.PROM_DESC
        FROM
            PT_SALES_DISCOUNT_D psdd
        left join PT_SALES_DISCOUNT_H psdh on
            psdd.SALES_DISCOUNT_H_ID_FK = psdh.SALES_DISCOUNT_H_ID
        WHERE
            psdd.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID
        FOR XML PATH('')), 1, 1, '') as DISCOUNT_DESC,
        --psmih.NET_LINE_AMT - (psmih.CUR_RETAIL_PRICE * qty) as DISCOUNT_AMOUNT
    CASE
        WHEN psmih.CUR_RETAIL_PRICE <0 and qty <0 THEN ABS(psmih.NET_LINE_AMT) - (psmih.CUR_RETAIL_PRICE * qty)
        ELSE psmih.NET_LINE_AMT - (psmih.CUR_RETAIL_PRICE * qty)
    END as DISCOUNT_AMOUNT
from PT_SALES_MEMO_ITEM_H psmih
--where psmih.CRE_DATET >= '2021-01-20'
--and psmih.SALES_MEMO_ITEM_H_ID = 'HKBB08000000000000059874';
