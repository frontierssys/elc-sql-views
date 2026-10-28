CREATE   VIEW dbo.PV_PROMO_DATE AS
select DISTINCT pp.COMPANY_CODE,pp.code,pp.layer,pc2.CAMPAIGN_CODE,CAST(min(pppp.START_DATE) as date) as FROMDATE,CAST(max(pppp.END_DATE) as date) as TODATE
from  PM_PROMO pp
left join PM_PROMO_PREREQ_PERIOD pppp
    on pppp.PROMOTION_ID_FK = pp.PROMOTION_ID
left join PM_CAMPAIGN pc2
    on pp.COMPAIGN_ID_FK = pc2.CAMPAIGN_ID
group by
    pp.COMPANY_CODE,pp.code,pp.layer,pc2.CAMPAIGN_CODE
