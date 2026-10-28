CREATE   VIEW  [dbo].[PIV_SALES_STORE_DEMOGRAPHIC_TXCOUNT_WALKIN]
--WITH SCHEMABINDING
AS
SELECT
    psm.company_code as 'COMPANY_CODE',
    pl.location_code,
    CONVERT(varchar(10),psm.TX_DT,126)  as 'TX_DATE',
    pn.DEMOGRAPHIC as 'DEMOGRAPHIC',
    CASE
        when psm.TOTAL_NET_AMT > 0 then 'SALE'
        else 'RETURN'
    end as SALE_OR_RETURN,
    COUNT_BIG(*) as 'MEMO_COUNT'
From dbo.PT_SALES_MEMO psm
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    -----
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_NATION pn
    on psm.NATION_ID_FK = pn.NATION_ID
INNER JOIN dbo.PR_REPORT_DATES prd on
    psm.REPORT_DT = prd.REPORT_DATE
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    --and psm.TX_DT < pprs.MV_DT
    and pst.STORE_TYPE_NAME <> 'ONLINE'
    and psm.VIP_NO is NULL
    and psm.TOTAL_NET_AMT <> 0
GROUP BY
    psm.company_code,
    pl.location_code,
    CONVERT(varchar(10),psm.TX_DT,126),
    pn.DEMOGRAPHIC,
    CASE
        when psm.TOTAL_NET_AMT > 0 then 'SALE'
        else 'RETURN'
    end
