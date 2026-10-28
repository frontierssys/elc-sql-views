-- dbo.PV_R8801_SUB source

-- dbo.PV_R8801_SUB source

create   VIEW [dbo].[PV_R8801_SUB] AS
select
    psm.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    pl.LOCATION_CODE + '-' + pl.LOCATION_DESC as LOCATION_DESC,
    --  pc.EXT_DIVISION_CODE as BRAND_CODE,
    psm.COMPANY_CODE as BRAND_CODE,
    pc.COMPANY_DESC as BRAND_DESC,
    psm.TX_DATE ,
    psmih.SKU as SKU_CODE,
    ps.SKU_DESC ,
    sum(psmih.QTY ) as QTY,
    sum(psmih.NET_LINE_AMT) as AMOUNT
from
    PT_SALES_MEMO psm
inner join PT_SALES_MEMO_ITEM_H psmih
    on psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join PM_SKU ps
    on ps.COMPANY_CODE = psmih.COMPANY_CODE
    and ps.SKU_CODE = psmih.SKU
inner join PM_COMPANY pc on
    psm.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl on
    pl.LOCATION_ID = psm.LOCATION_ID_FK
left join PM_SALES_TARGET pst on
    pst.COMPANY_CODE = psm.COMPANY_CODE
    and pst.LOCATION_ID_FK = psm.LOCATION_ID_FK
    and pst.SALES_TARGET_TYPE = 'DAILY'
    and pst.STAFF_NO = psm.STAFF_NO
    and pst.DATE_FROM = psm.TX_DATE
inner join PM_SALES_MEMO_TYPE psmt on
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
left join PT_SALES_MEMO_PAYMENT psmp
    on psmp.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
    and psmp.DEPOSIT_NO is not null
where
    psmt.TYPE_CODE not in ('05', '06', '07', '09', '10', '11', '99', '08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.PICKUP_STATUS <> 'PICKUPED'
    and psmih.ORG_RETAIL_PRICE <> 0
    and psmp.DEPOSIT_NO is null
    --	and psm.COMPANY_CODE = 'TWMC'
    --	and psm.TX_DATE = '2021-12-09'
group by
    psm.COMPANY_CODE ,
    pl.LOCATION_CODE ,
    pl.LOCATION_CODE + '-' + pl.LOCATION_DESC ,
    psm.TX_DATE ,
    psmih.SKU ,
    ps.SKU_DESC,
    --  pc.EXT_DIVISION_CODE,
    pc.COMPANY_DESC
