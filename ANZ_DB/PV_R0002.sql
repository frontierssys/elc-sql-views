CREATE   VIEW [dbo].[PV_R0002] AS
SELECT
    psm.company_code as 'COMPANY_CODE',
    pc2.COMPANY_DESC as 'COMPANY_DESC',
    pl.location_code,
    pl.LOCATION_DESC,
    CONCAT( pl.ADDRESS1,
        pl.ADDRESS2,
        pl.ADDRESS3) as 'Address',
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    psm.TX_DATE  as 'TX_DATE',
    CASE
        WHEN psmt.TYPE_CODE in ('03', '04', '05') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.COMPANY_CODE IN ('AUCS','NZCS') and psa.IH_L1 = '120' THEN 'Y' -- To include CS STORE Saleable Sample
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END AS 'IS_REVENUE_ITEM',
    sum(psmih.CUR_RETAIL_PRICE * qty) as 'SALES_GROSS_AMT',
    sum(psmih.GROSS_LINE_AMT_EXCLUDE_TAX) as 'SALES_GROSS_AMT_EXCL_TAX',
    sum(psmih.NET_LINE_AMT) as 'SALES_AMT',
    sum(psmih.NET_LINE_AMT_EXCLUDE_TAX) as 'SALES_AMT_EXCL_TAX',
    sum(psmih.NET_LINE_AMT - psmih.CUR_RETAIL_PRICE * qty) as 'MARK_DOWNN',
    sum(psmih.NET_LINE_AMT_EXCLUDE_TAX - psmih.GROSS_LINE_AMT_EXCLUDE_TAX) as 'MARK_DOWN_EXCL_TAX',
    sum(psmih.QTY) as 'QTY',
    COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT',
    CASE
        WHEN psm.TOTAL_NET_AMT >=0 then 'SALE'
        When psmih.QTY > 0 then 'SALE'
        when psmt.TYPE_CODE in ('03', '04', '05') THEN 'SALE'
        When psmih.IS_SALES_KIT_ITEM = 'Y' then 'SALE'
        else 'RETURN'
    end as 'SALE_OR_RETURN',
    pt.TERMINAL_NO,
    sum(
        CASE
            when abs(psmih.NET_LINE_AMT) <> abs(psmih.CUR_RETAIL_PRICE * psmih.qty) THEN psmih.qty
            ELSE 0
        END ) as DISCOUNTED_QTY,
        --COUNT(DISTINCT (CASE when psa.IH_L1 = '110' and psmih.NET_LINE_AMT - psmih.CUR_RETAIL_PRICE <> 0 and psmih.QTY > 0 then psm.MEMO_NO WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' and psmih.NET_LINE_AMT - psmih.CUR_RETAIL_PRICE <> 0 and psmih.QTY > 0 then psm.MEMO_NO end ) )as DISCOUNTED_MEMO_COUNT
    COUNT(DISTINCT (
        CASE
            when abs(psmih.NET_LINE_AMT) <> abs(psmih.CUR_RETAIL_PRICE * psmih.qty) then psm.MEMO_NO
        end ) )as DISCOUNTED_MEMO_COUNT,
    SUM(psmih.LINE_TAX1_AMT) as TAX_AMT
From dbo.PT_SALES_MEMO psm
inner join dbo.PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PM_SKU ps
    on ps.COMPANY_CODE = psm.COMPANY_CODE
    and psmih.SKU = ps.SKU_CODE
inner join dbo.PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    -----
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_TERMINAL pt
    on psm.TERMINAL_ID_FK = pt.TERMINAL_ID
where psmt.TYPE_CODE not in ('06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psmih.NET_LINE_AMT <> 0
    --and psm.LOCATION_ID_FK = 'HKCMHKCM0016'
    --and psm.TX_DT >= '2020-12-30'
    --and psm.TX_DT < '2020-12-31'
GROUP BY
    psm.company_code,
    pc2.COMPANY_DESC,
    pl.LOCATION_DESC,
    pl.ADDRESS1,
    pl.ADDRESS2,
    pl.ADDRESS3,
    pst.STORE_TYPE_CODE,
    pl.LOCATION_CODE,
    pt.TERMINAL_NO,
    psm.TX_DATE ,
    CASE
        WHEN psmt.TYPE_CODE in ('03', '04', '05') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.COMPANY_CODE IN ('AUCS','NZCS') and psa.IH_L1 = '120' THEN 'Y' -- To include CS STORE Saleable Sample
        WHEN psmih.IS_SERVICE_ITEM = 'Y'and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END,
    CASE
        WHEN psm.TOTAL_NET_AMT >=0 then 'SALE'
        When psmih.QTY > 0 then 'SALE'
        when psmt.TYPE_CODE in ('03', '04', '05') THEN 'SALE'
        When psmih.IS_SALES_KIT_ITEM = 'Y' then 'SALE'
        else 'RETURN'
    end;
