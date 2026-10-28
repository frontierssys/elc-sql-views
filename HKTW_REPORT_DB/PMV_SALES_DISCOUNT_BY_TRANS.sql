CREATE   VIEW PMV_SALES_DISCOUNT_BY_TRANS AS
Select psm.COMPANY_CODE as COMPANY_CODE,
    pl.LOCATION_CODE as LOCATION_CODE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    CASE
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='MAC' THEN 'MO'
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='HKG' THEN 'HK'
        ELSE LEFT(pl.COMPANY_CODE,2)
    END as ENTITY,
    CAST (psm.TX_DT as date) as TX_DATE,
    pt.TERMINAL_NO as TERMINAL_ID,
    CAST (psm.TX_DT as time) as TRANSACTION_TIME,
    psm.MEMO_NO as TRANSACTION_ID,
    isnull(psm.CASHIER_CODE, psm.CRE_BY ) as EMPLOYEE_ID_CASHIER,
    isnull(ps_cashier.FIRST_NAME + ' ' + ps_cashier.LAST_NAME , ps_cre.FIRST_NAME + ' ' + ps_cre.LAST_NAME ) as EMPLOYEE_NAME_CASHIER,
    ps3.STAFF_CODE as EMPLOYEE_ID_COMMISSIONED_ASSOCIATE,
    ps3.FIRST_NAME + ' ' + ps3.LAST_NAME as EMPLOYEE_NAME_COMMISSIONED_ASSOCIATE,
    psm.VIP_NO as CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME as CUSTOMER_NAME,
    psdh.DISC_TYPE as DISCOUNT_TYPE,
    ppd.CAMPAIGN_CODE  as PROMOTION_CAMPAIGN,
    psdh.PROM_CODE_ID as DISCOUNT_CODE,
    psdh.PROM_DESC as DISCOUNT_DESCRIPTION,
    psdh.DISCOUNT_RATE as PERCENT_DISCOUNT,
    ppd.FROMDATE as FROMDATE,
    ppd.TODATE as TODATE,
    CAST(getdate() as date) as TODAY,
    SUM(psdd.DISCOUNT_AMOUNT) as AMOUNT_DISCOUNT,
    SUM(psdd.DISCOUNT_EXCL_TAX) as AMOUNT_DISCOUNT_EXCL_TAX,
    SUM(psdd.DISCOUNT_TAX) as AMOUNT_DISCOUNT_TAX,
    sum(psmid.QTY) as QUANTITY_DISCOUNTED,
    psm.TOTAL_NET_AMT as AMOUNT_AFTER_DISCOUNT
FROM
    PT_SALES_DISCOUNT_H psdh
inner join PT_SALES_MEMO psm
    on psdh.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join PT_SALES_DISCOUNT_D psdd
    on psdd.SALES_DISCOUNT_H_ID_FK = psdh.SALES_DISCOUNT_H_ID
LEFT join PT_SALES_MEMO_ITEM_H psmih
    on psdd.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID
LEFT join PT_SALES_MEMO_ITEM_D psmid
    ON psdd.SALES_MEMO_ITEM_H_ID_FK = psmid.SALES_MEMO_ITEM_H_ID_FK and psmid.SALES_MEMO_ITEM_DETAIL_ID =psdd.SALES_MEMO_ITEM_D_ID_FK
inner join PM_LOCATION pl
    on pl.LOCATION_ID = psm.LOCATION_ID_FK
inner join PM_TERMINAL pt
    on psm.TERMINAL_ID_FK = pt.TERMINAL_ID
inner join PM_STORE_TYPE pst
    on pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
LEFT join dbo.PT_MEMO_ITEM_STAFF_SET pmiss
    on psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
LEFT join dbo.PT_SALES_MEMO_ITEM_STAFF psmis
    on psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
LEFT join dbo.PM_STAFF ps3
    on ps3.COMPANY_CODE = psmis.COMPANY_CODE
    and ps3.STAFF_CODE = psmis.STAFF_NO
LEFT JOIN PV_PROMO_DATE ppd
    on ppd.COMPANY_CODE = psdh.COMPANY_CODE
    and psdh.DISC_TYPE  = ppd.LAYER
    and psdh.PROM_CODE_ID = ppd.CODE
left join PM_USER pu_cashier
    on pu_cashier.COMPANY_CODE = psm.COMPANY_CODE
    and pu_cashier.USER_CODE = psm.CASHIER_CODE
left join PM_STAFF ps_cashier
    on pu_cashier.STAFF_ID_FK = ps_cashier.STAFF_ID
left join PM_USER pu_cre
    on psm.COMPANY_CODE = pu_cre.COMPANY_CODE
    and psm.CRE_BY = pu_cre.USER_CODE
left join PM_STAFF ps_cre
    on ps_cre.STAFF_ID = pu_cre.STAFF_ID_FK
left join PV_SKU_DETAIL psd
    on psd.SKU_10 = psmih.SKU
    and psd.COMPANY_CODE = psmih.COMPANY_CODE
left join PM_USER pu
    on psm.CASHIER_CODE = pu.USER_CODE
    and psm.COMPANY_CODE = pu.COMPANY_CODE
left join PM_STAFF ps
    on ps.STAFF_ID = pu.STAFF_ID_FK
left join PV_SALES_TENDER_BY_TRANSACTION pstbt
    on psm.SALES_MEMO_ID = pstbt.SALES_MEMO_ID
left join PM_VIP pv
    on psm.COMPANY_CODE = pv.COMPANY_CODE
    and psm.VIP_NO = pv.VIP_NO
left join PM_CUSTOMER pc
    on pc.CUSTOMER_ID = pv.CUSTOMER_ID_FK
where psmt.TYPE_CODE not in ('05','06','07','10','11','99','08', '09')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.MEMO_STATUS <> 'VOIDED'
    --and psm.MEMO_STATUS = 'COMPLETED'
    --and psm.memo_no='HKEL0026XXHQ21000112'
group by
    psm.COMPANY_CODE,
    pl.LOCATION_CODE,
    pst.STORE_TYPE_CODE,
    pl.CITY_TXT,
    pl.LOCATION_CODE,
    pl.LOCATION_NAME,
    CASE
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='MAC' THEN 'MO'
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='HKG' THEN 'HK'
        ELSE LEFT(pl.COMPANY_CODE,2)
    END,
    CAST (psm.TX_DT as date),
    pt.TERMINAL_NO,
    CAST (psm.TX_DT as time),
    psm.MEMO_NO ,
    isnull(psm.CASHIER_CODE, psm.CRE_BY ),
    isnull(ps_cashier.FIRST_NAME + ' ' + ps_cashier.LAST_NAME , ps_cre.FIRST_NAME + ' ' + ps_cre.LAST_NAME ),
    ps3.STAFF_CODE ,
    ps3.FIRST_NAME + ' ' + ps3.LAST_NAME ,
    psm.VIP_NO ,
    pc.FIRSTNAME + ' ' + pc.SURNAME ,
    psdh.DISC_TYPE ,
    ppd.CAMPAIGN_CODE,
    psdh.PROM_CODE_ID,
    psdh.PROM_DESC,
    psdh.DISCOUNT_RATE,
    psm.TOTAL_NET_AMT,
    ppd.FROMDATE,
    ppd.TODATE;
