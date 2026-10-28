CREATE    view [dbo].[PV_R0002_NON_REV] AS
SELECT
    psm.company_code as 'COMPANY_CODE',
    pl.location_code,
    psm.TX_DATE as 'TX_DATE',
    psmt.TYPE_CODE ,
    Case
        when psmt.TYPE_CODE = '03' then 'Deposit'
        when psmt.TYPE_CODE = '04' then 'Deposit Refund'
        when pia.IS_PLASTIC_BAG = 'Y' then 'Shopping Bag'
        when psmih.IS_SALES_KIT_ITEM = 'Y' then 'Service Package'
        else 'Others'
    end as NON_REVENUE_PRODUCT_TYPE,
    --	psm.MEMO_NO ,
    sum(psmih.CUR_RETAIL_PRICE * qty) as 'SALES_GROSS_AMT',
    sum(psmih.NET_LINE_AMT) as 'SALES_NET_AMT',
    sum(psmih.CUR_RETAIL_PRICE * qty - psmih.NET_LINE_AMT) as MARKDOWN,
    sum(psmih.QTY) as 'QTY',
    COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT',
    pt.TERMINAL_NO
    ----------------
    --------------
From dbo.PT_SALES_MEMO psm
--------------------------------
inner join dbo.PT_SALES_MEMO_ITEM_H psmih on
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    --------------------------------
inner join dbo.PM_SALES_MEMO_TYPE psmt on
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    ----------------------------------------
inner join dbo.PM_SKU ps on
    psmih.COMPANY_CODE = ps.COMPANY_CODE
    and psmih.SKU = ps.SKU_CODE
inner join dbo.PM_SKU_ATTR psa
-------------------------------------------
    on
    ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    -----
inner join dbo.PM_ITEM pi2 on
    ps.ITEM_ID_FK = pi2.ITEM_ID
inner join PM_ITEM_ATTR pia on
    pia.ITEM_ATTR_ID = pi2.ITEM_ATTR_ID_FK
    -----------------------------------------
inner join dbo.PM_COMPANY pc2 on
    pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl on
    psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_TERMINAL pt on
    psm.TERMINAL_ID_FK = pt.TERMINAL_ID
inner join dbo.PR_POS_REPORT_SUP pprs on
    1 = 1
    --where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
where psmt.TYPE_CODE not in (
    '05',
    '06',
    '07',
    '09',
    '10',
    '11',
    '99',
    '08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.MEMO_STATUS= 'COMPLETED'
    and (
        pia.IS_PLASTIC_BAG = 'Y'
            or psmt.TYPE_CODE in ('03','04')
            or (( psa.IH_L1 = '110' and psmih.IS_SALES_KIT_ITEM = 'Y')
                    or (psmih.IS_SERVICE_ITEM = 'N' and psa.IH_L1 <> '110'))
    )
    and psmih.NET_LINE_AMT <> 0
    and pst.STORE_TYPE_NAME <> 'ONLINE'
    --	and psm.LOCATION_ID_FK = 'HKCMHKCM0012'
    --	and psm.TX_DT >= '2021-01-12'
    --	and psm.TX_DT < '2021-01-13'
GROUP BY
    psm.company_code,
    pl.location_code,
    pt.TERMINAL_NO,
    psm.TX_DATE ,
    psmt.TYPE_CODE ,
    Case
        when psmt.TYPE_CODE = '03' then 'Deposit'
        when psmt.TYPE_CODE = '04' then 'Deposit Refund'
        when pia.IS_PLASTIC_BAG = 'Y' then 'Shopping Bag'
        when psmih.IS_SALES_KIT_ITEM = 'Y' then 'Service Package'
        else 'Others'
    end;
