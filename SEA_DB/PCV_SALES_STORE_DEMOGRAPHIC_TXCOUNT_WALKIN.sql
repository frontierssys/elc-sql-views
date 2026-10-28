CREATE     VIEW [dbo].[PCV_SALES_STORE_DEMOGRAPHIC_TXCOUNT_WALKIN] as
--WITH SCHEMABINDING AS
SELECT
    psm.company_code as 'COMPANY_CODE',
    pl.location_code,
    psm.TX_DATE  as 'TX_DATE',
    pn.DEMOGRAPHIC as 'DEMOGRAPHIC',
    CASE
        when psm.TOTAL_NET_AMT >= 0 then 'SALE'
        else 'RETURN'
    end as SALE_OR_RETURN,
    CASE
    --WHEN psmt.TYPE_CODE in ('03', '04') THEN 'N'
        WHEN psmt.TYPE_CODE in ('03', '04','12','13','14') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END AS 'IS_REVENUE_ITEM',
    COUNT(DISTINCT psm.MEMO_NO) AS 'MEMO_COUNT'
    --COUNT_BIG(*) as 'MEMO_COUNT'
From dbo.PT_SALES_MEMO psm
INNER JOIN dbo.PT_SALES_MEMO_ITEM_H psmih ON
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    -----
INNER JOIN dbo.PM_SKU ps ON
    psmih.COMPANY_CODE = ps.COMPANY_CODE
    AND psmih.SKU = ps.SKU_CODE
INNER JOIN dbo.PM_SKU_ATTR psa ON
    ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_NATION pn
    on psm.NATION_ID_FK = pn.NATION_ID
INNER JOIN (
    select min(prd.REPORT_DATE) as REPORT_DATE
    from PR_REPORT_DATES prd) a on
    psm.REPORT_DT > a.REPORT_DATE
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    --and psm.TX_DT >= pprs.MV_DT
    and pst.STORE_TYPE_NAME <> 'ONLINE'
    and psm.VIP_NO is NULL
    --and psm.TOTAL_NET_AMT <> 0
GROUP BY
    psm.company_code,
    pl.location_code,
    psm.TX_DATE ,
    pn.DEMOGRAPHIC,
    CASE
        when psm.TOTAL_NET_AMT >= 0 then 'SALE'
        else 'RETURN'
    end,
    CASE
    --WHEN psmt.TYPE_CODE in ('03', '04') THEN 'N'
        WHEN psmt.TYPE_CODE in ('03', '04','12','13','14') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END
