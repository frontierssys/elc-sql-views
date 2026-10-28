CREATE   VIEW [dbo].[PV_PROMO_DATE] AS
select DISTINCT pp.COMPANY_CODE,pp.code,pp.layer,pc2.CAMPAIGN_CODE,CAST(min(pppp.START_DATE) as date) as FROMDATE,CAST(max(pppp.END_DATE) as date) as TODATE
from (
    select pp.COMPANY_CODE,pp.code,pp.layer,pp.PROMOTION_ID,pp.COMPAIGN_ID_FK
    from PM_PROMO pp
    inner join (
        select COMPANY_CODE, code, max(REVISION_NO) max_rev
        from PM_PROMO
        group by COMPANY_CODE, code) ppMax on pp.COMPANY_CODE = ppMax.COMPANY_CODE and pp.CODE = ppMax.code and pp.REVISION_NO = ppMax.max_rev) pp
left join PM_PROMO_PREREQ_PERIOD pppp on pppp.PROMOTION_ID_FK = pp.PROMOTION_ID
left join PM_CAMPAIGN pc2 on pp.COMPAIGN_ID_FK = pc2.CAMPAIGN_ID
group by pp.COMPANY_CODE,pp.code,pp.layer,pc2.CAMPAIGN_CODE
