-- dbo.PMV_SALES_DISCOUNT_BY_ITEM_H source

CREATE      view [dbo].[PMV_SALES_DISCOUNT_BY_ITEM_H]
--WITH SCHEMABINDING
AS
select
    psmih.SALES_MEMO_ITEM_H_ID ,
    stuff((
        SELECT
            DISTINCT ',' + psdh.PROM_CODE_ID
        FROM
            dbo.PT_SALES_DISCOUNT_H psdh
        left join dbo.PT_SALES_DISCOUNT_D psdd on
            psdd.SALES_DISCOUNT_H_ID_FK = psdh.SALES_DISCOUNT_H_ID
        WHERE
            psdd.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID AND psdh.DISC_TYPE != 'SET'
        FOR XML PATH('')), 1, 1, '') as DISCOUNT_CODE,
    stuff((
        SELECT
            DISTINCT ',' + psdh.PROM_DESC
        FROM
            dbo.PT_SALES_DISCOUNT_D psdd
        left join dbo.PT_SALES_DISCOUNT_H psdh on
            psdd.SALES_DISCOUNT_H_ID_FK = psdh.SALES_DISCOUNT_H_ID
        WHERE
            psdd.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID AND psdh.DISC_TYPE != 'SET'
        FOR XML PATH('')), 1, 1, '') as DISCOUNT_DESC,
    psmiha.VIRTUAL_SET_PARENT_SKU AS DISCOUNT_SET_CODE,
    stuff((
        SELECT
            DISTINCT ',' + psdh.PROM_DESC
        FROM
            PT_SALES_DISCOUNT_D psdd
        left join PT_SALES_DISCOUNT_H psdh on
            psdd.SALES_DISCOUNT_H_ID_FK = psdh.SALES_DISCOUNT_H_ID
        WHERE
            psdd.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID AND psdh.DISC_TYPE = 'SET'
        FOR XML PATH('')), 1, 1, '') as DISCOUNT_SET_DESC,
        --psmih.NET_LINE_AMT - (psmih.CUR_RETAIL_PRICE * qty) as DISCOUNT_AMOUNT
    CASE
        WHEN psmih.CUR_RETAIL_PRICE <0 and qty <0 THEN ABS(psmih.NET_LINE_AMT) - (psmih.CUR_RETAIL_PRICE * qty)
        ELSE psmih.NET_LINE_AMT - (psmih.CUR_RETAIL_PRICE * qty)
    END as DISCOUNT_AMOUNT
from dbo.PT_SALES_MEMO_ITEM_H psmih
LEFT JOIN PT_SALES_MEMO_ITEM_H_ATTR psmiha ON psmiha.SALES_MEMO_ITEM_H_ATTR_ID = psmih.SALES_MEMO_ITEM_H_ATTR_ID_FK
--where psmih.CRE_DATET >= '2021-01-20'
--and psmih.SALES_MEMO_ITEM_H_ID = 'HKBB08000000000000059874'
    ;
