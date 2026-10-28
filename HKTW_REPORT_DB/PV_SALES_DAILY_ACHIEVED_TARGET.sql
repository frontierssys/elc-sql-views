CREATE   view [dbo].[PV_SALES_DAILY_ACHIEVED_TARGET] as
select
    pst.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    CAST( pst.DATE_FROM as DATE) as TX_DATE,
    isnull(pst.TARGET_AMOUNT,0) as TARGET_AMOUNT,
    sum(isnull(psmih.NET_LINE_AMT, 0)) as ACHIEVED_AMOUNT
from
    PM_SALES_TARGET pst
left join PT_SALES_MEMO psm on
    psm.COMPANY_CODE = pst.COMPANY_CODE
    and psm.LOCATION_ID_FK = pst.LOCATION_ID_FK
    and psm.TX_DT >= pst.DATE_FROM
    and psm.TX_DT < DATEADD(day, 1, pst.DATE_FROM )
left join PT_SALES_MEMO_ITEM_H psmih on
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
left join PM_LOCATION pl on
    pl.LOCATION_ID = pst.LOCATION_ID_FK
left join PM_SALES_MEMO_TYPE psmt on
    psmt.SALES_MEMO_TYPE_ID = psm.SALES_MEMO_TYPE_ID_FK
left join PM_SKU ps
    on ps.COMPANY_CODE = psmih.COMPANY_CODE
    and ps.SKU_CODE = psmih.SKU
left join PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
where
    SALES_TARGET_TYPE = 'DAILY'
    and pst.STAFF_NO is null
    and (psmt.TYPE_CODE is null or psmt.TYPE_CODE in ('01', '02'))
    and (psm.MEMO_STATUS is null or  psm.MEMO_STATUS = 'COMPLETED')
    and (
        psm.SALES_MEMO_ID is null
            or psa.IH_L1 = '110'
            or (psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N')
            or psmih.IS_REDEEM_SERVICE_ITEM = 'Y'
    )
group by
    pst.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    CAST( pst.DATE_FROM as DATE),
    TARGET_AMOUNT
