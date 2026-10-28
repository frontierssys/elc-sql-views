CREATE   VIEW  [dbo].[PV_R0051_ITEM_MULTIPLE] AS
select  DISTINCT PSM.MEMO_NO,psm.VIP_NO,pl.location_id,pl.LOCATION_CODE,count(psd.SKU_4) as SKUCount,
    psd.SKU_4,psd.SKU_10
FROM
    PL_AUTHORIZATION_LOG pal
inner join PT_SALES_MEMO psm
    on psm.COMPANY_CODE = pal.COMPANY_CODE
    and psm.MEMO_NO = pal.AUTH_REF_NO
inner join PM_LOCATION pl
    on pl.LOCATION_ID = psm.LOCATION_ID_FK
inner join PT_SALES_MEMO_ITEM_H psmih
    on psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join PV_SKU_DETAIL psd
    on psmih.COMPANY_CODE = psd.COMPANY_CODE
    and psmih.SKU = psd.SKU_10
where pal.AUTH_FUNCTION = 'authorizeOverPurchaseAmt' and psm.VIP_NO in (
    select  psm.VIP_NO
    FROM
        PL_AUTHORIZATION_LOG pal
    inner join PT_SALES_MEMO psm
        on psm.COMPANY_CODE = pal.COMPANY_CODE
        and psm.MEMO_NO = pal.AUTH_REF_NO
    inner join PM_LOCATION pl
        on pl.LOCATION_ID = psm.LOCATION_ID_FK
    where pal.AUTH_FUNCTION = 'authorizeOverPurchaseAmt' --and psm.VIP_NO in ('HQ000004187')
    group by psm.VIP_NO, pl.LOCATION_CODE,pal.COMPANY_CODE
    HAVING count(DISTINCT PSM.MEMO_NO)>1)
group by PSM.MEMO_NO,psm.VIP_NO,pl.LOCATION_CODE,psd.SKU_4,pl.location_id,psd.SKU_10
having count(psd.SKU_4)>8
