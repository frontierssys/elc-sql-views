create   VIEW [dbo].[PIV_SALES_STORE_DEMOGRAPHIC_WALKIN]
--WITH SCHEMABINDING
AS
SELECT
    psm.company_code as 'COMPANY_CODE',
    pl.location_code,
    CONVERT(varchar(10),
        psm.TX_DT,
        126) as 'TX_DATE',
    pn.DEMOGRAPHIC as 'DEMOGRAPHIC',
    CASE
        WHEN psmt.SALES_MEMO_TYPE_ID in ('03', '04') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END AS 'IS_REVENUE_ITEM',
    CASE
        When psmih.QTY > 0 then 'SALE'
        when psmt.SALES_MEMO_TYPE_ID in ('03', '04') THEN 'SALE'
        When psmih.IS_SALES_KIT_ITEM = 'Y' then 'SALE'
        else 'RETURN'
    end as 'SALE_OR_RETURN',
    sum(psmih.CUR_RETAIL_PRICE * qty) as 'SALES_GROSS_AMT',
    sum(psmih.NET_LINE_AMT) as 'SALES_NET_AMT',
    sum(psmih.QTY) as 'QTY',
    COUNT_BIG(*) as RECORD_COUNT
    --COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT'
From dbo.PT_SALES_MEMO psm
inner join dbo.PT_SALES_MEMO_ITEM_H psmih on
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
inner join dbo.PM_SALES_MEMO_TYPE psmt on
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PM_SKU ps on
    psmih.COMPANY_CODE = ps.COMPANY_CODE
    and psmih.SKU = ps.SKU_CODE
inner join dbo.PM_ITEM pi2 on
    pi2.ITEM_ID = ps.ITEM_ID_FK
inner join dbo.PM_ITEM_ATTR pia on
    pia.ITEM_ATTR_ID = pi2.ITEM_ATTR_ID_FK
inner join dbo.PM_SKU_ATTR psa on
    ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    -----
inner join dbo.PM_COMPANY pc2 on
    pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl on
    psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_NATION pn on
    psm.NATION_ID_FK = pn.NATION_ID
INNER JOIN dbo.PR_REPORT_DATES prd on
    psm.REPORT_DT = prd.REPORT_DATE
where
    psmt.TYPE_CODE not in (
        '05',
        '06',
        '07',
        '09',
        '10',
        '11',
        '99',
        '08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE',
        'handoff')
        --and psm.TX_DT < pprs.MV_DT
    and pst.STORE_TYPE_NAME <> 'ONLINE'
    and psm.VIP_NO is NULL
    --and pia.IS_PLASTIC_BAG = 'N'
GROUP BY psm.company_code,
    pl.location_code,
    CONVERT(varchar(10),
        psm.TX_DT,
        126),
    pn.DEMOGRAPHIC,
    CASE
        WHEN psmt.SALES_MEMO_TYPE_ID in ('03', '04') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END ,
    CASE
        When psmih.QTY > 0 then 'SALE'
        when psmt.SALES_MEMO_TYPE_ID in ('03', '04') THEN 'SALE'
        When psmih.IS_SALES_KIT_ITEM = 'Y' then 'SALE'
        else 'RETURN'
    end
