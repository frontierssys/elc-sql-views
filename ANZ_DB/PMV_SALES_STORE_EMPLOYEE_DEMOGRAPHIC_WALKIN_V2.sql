CREATE   VIEW  [dbo].[PMV_SALES_STORE_EMPLOYEE_DEMOGRAPHIC_WALKIN_V2]
--WITH SCHEMABINDING
AS
SELECT
    psm.company_code as 'COMPANY_CODE',
    pc2.COMPANY_DESC as 'COMPANY_DESC',
    pl.location_code,
    pl.LOCATION_DESC,
    pl.LOCATION_NAME,
    CONCAT( pl.ADDRESS1,
        pl.ADDRESS2,
        pl.ADDRESS3) as 'Address',
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    ps22.STAFF_CODE as EMPLOYEE_ID,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME  as EMPLOYEE_NAME,
    CASE
        when psa.IH_L1='110' then 'Y'
        else 'N'
    end as 'IS_REVENUE_ITEM',
    psm.TX_DATE  as 'TX_DATE',
    sum(pst2.TARGET_AMOUNT) as 'TARGET_AMOUNT',
    CASE
        When psmih.QTY > 0 then 'SALE'
        else 'RETURN'
    end as 'SALE_OR_RETURN',
    pn.DEMOGRAPHIC as 'DEMOGRAPHIC',
    sum(psmih.CUR_RETAIL_PRICE * qty) as 'SALES_GROSS_AMT',
    sum(psmih.NET_LINE_AMT) as 'SALES_NET_AMT',
    sum(psmih.QTY) as 'QTY',
    COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT',
    sum(psmih.NET_LINE_AMT - (psmih.CUR_RETAIL_PRICE * qty)) as DISCOUNT
From dbo.PT_SALES_MEMO psm
inner join dbo.PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PM_SKU ps
    on psmih.COMPANY_CODE = ps.COMPANY_CODE
    and psmih.SKU = ps.SKU_CODE
inner join dbo.PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    --------------------------------
inner join dbo.PT_MEMO_ITEM_STAFF_SET pmiss
    on psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
inner join dbo.PT_SALES_MEMO_ITEM_STAFF psmis
    on psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
inner join dbo.PM_STAFF ps22
    on ps22.COMPANY_CODE = psmis.COMPANY_CODE
    and ps22.STAFF_CODE = psmis.STAFF_NO
    -----
inner join dbo.PM_ITEM pi2
    on ps.ITEM_ID_FK = pi2.ITEM_ID
inner join dbo.PM_CLASS pc3
    on pi2.CLASS_ID_FK = pc3.CLASS_ID
inner join dbo.PM_SUBCLASS ps2
    on pi2.SUBCLASS_ID_FK = ps2.SUBCLASS_ID
inner join dbo.PM_BRAND pb
    on pi2.BRAND_ID_FK = pb.BRAND_ID
    -----
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_NATION pn
    on psm.NATION_ID_FK = pn.NATION_ID
left join dbo.PM_SALES_TARGET pst2
    on pl.LOCATION_ID = pst2.LOCATION_ID_FK AND CONVERT(varchar(100), psm.TX_DT, 23) = CONVERT(varchar(100), pst2.DATE_FROM, 23)
left join dbo.PM_USER pu
    on pu.USER_CODE = psm.CASHIER_CODE
    and pu.COMPANY_CODE = psm.COMPANY_CODE
left join dbo.PM_STAFF ps3
    on pu.STAFF_ID_FK = ps3.STAFF_ID
inner join
    (
        select
            psm_s.SALES_MEMO_ID as 'SALES_MEMO_ID',
            sum(psmih_s.qty) as 'TX_QTY'
        from dbo.PT_SALES_MEMO psm_s
        inner join dbo.PT_SALES_MEMO_ITEM_H psmih_s
            on psm_s.SALES_MEMO_ID = psmih_s.SALES_MEMO_ID_FK
            --	where psm.SALES_MEMO_ID = psm_s.SALES_MEMO_ID
        group by psm_s.SALES_MEMO_ID
    ) s on psm.SALES_MEMO_ID = s.SALES_MEMO_ID
inner join dbo.PR_POS_REPORT_SUP pprs
    on 1 = 1
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.TX_DT < pprs.MV_DT
    and pst.STORE_TYPE_NAME <> 'ONLINE'
    and psm.VIP_NO is NULL
    --and pl.LOCATION_CODE = 'HKEL0099'
    --and psm.TX_DT >= '2019-07-11'
    --and psm.TX_DT < '2019-07-12'
GROUP BY
    psm.company_code,
    pc2.COMPANY_DESC,
    pl.location_code,
    pl.LOCATION_DESC,
    pl.LOCATION_NAME,
    pl.ADDRESS1,
    pl.ADDRESS2,
    pl.ADDRESS3,
    pst.STORE_TYPE_CODE,
    ps22.STAFF_CODE,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME,
    CASE
        when psa.IH_L1='110' then 'Y'
        else 'N'
    end,
    psm.TX_DATE ,
    CASE
        When psmih.QTY > 0 then 'SALE'
        else 'RETURN'
    end,
    pn.DEMOGRAPHIC
