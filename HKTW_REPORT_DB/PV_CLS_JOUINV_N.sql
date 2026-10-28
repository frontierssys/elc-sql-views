CREATE   view PV_CLS_JOUINV_N as
select
    psm.MEMO_NO as INVNO,
    FORMAT(psm.TX_DT, 'yyyyMMdd') as JDATE,
    pl.LOCATION_CODE as LOC,
    psmih.SKU as ITEM,
    ps2.STAFF_CODE as STAFF,
    psmih.QTY as QTY,
    psmih.CUR_RETAIL_PRICE as PRICE,
    psmih.CUR_RETAIL_PRICE * psmih.qty as ITMAMT,
    psmih.NET_LINE_AMT as NET_AMT,
    case psm.MEMO_STATUS
        when 'VOIDED' then 'Y'
        else 'N'
    end as VOID_FLAG,
    DATEPART(HOUR, psm.CRE_DATET) as HH,
    DATEPART(MINUTE, psm.CRE_DATET) as MM,
    case
        when pn.CODE = '09' then '99'
        else pn.CODE
    end as NAT,
    --cnm.CLS_CODE as NAT,
    null as AGE,
    null as SEX,
    psmih.CUR_RETAIL_PRICE * qty - psmih.NET_LINE_AMT as DISCADJ,
    null as VIPNO,
    '' as POINT,
    pstbt.TENDERS,
    psmih.SEQ,
    pt.TERMINAL_NO as TERMID,
    '' as DISCOUNTS,
    psm.TX_DT
FROM PT_SALES_MEMO psm
inner join PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
inner join PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PT_MEMO_ITEM_STAFF_SET pmiss
    on psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
inner join dbo.PT_SALES_MEMO_ITEM_STAFF psmis
    on psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
inner join dbo.PM_STAFF ps2
    on ps2.COMPANY_CODE = psmis.COMPANY_CODE
    and ps2.STAFF_CODE = psmis.STAFF_NO
    --inner join dbo.PM_VIP pv
    --on psm.VIP_NO = pv.VIP_NO
    --and psm.COMPANY_CODE = pv.COMPANY_CODE
    --inner join dbo.PM_CUSTOMER pc
    --on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
    --inner join dbo.PM_CUSTOMER_SECRET pcs
    --on pc.CUSTOMER_ID = pcs.CUSTOMER_ID_FK
    --inner join dbo.PM_NATION pn
    --on pcs.COMPANY_CODE = pn.COMPANY_CODE
    --and pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
inner join PM_NATION pn
    on psm.NATION_ID_FK = pn.NATION_ID
left join CLS_NATION_MAPPING cnm
    on cnm.CODE = pn.CODE
inner join PV_SALES_TENDER_BY_TRANSACTION pstbt
    on pstbt.SALES_MEMO_ID = psm.SALES_MEMO_ID
inner join PM_TERMINAL pt
    on psm.TERMINAL_ID_FK = pt.TERMINAL_ID
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
--and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.VIP_NO is NULL
    --and psm.TX_DT < pprs.MV_DT
    --and psa.IH_L1 = '110'
    and pst.STORE_TYPE_NAME <> 'ONLINE'
    and psm.COMPANY_CODE in (
        select COMPANY_CODE
        from CLS_BRAND_SCOPE)
    and psm.TX_DATE >= '2021-02-23'
    and psm.TX_DATE < cast(SWITCHOFFSET(CAST(CURRENT_TIMESTAMP AS DATETIMEOFFSET), '+08:00') as datetime)
    and psm.POS_MEMO_NO = psm.MEMO_NO;
