-- dbo.PV_GIFT_CARD_MOVEMENT_BY_DAY source

CREATE   view [dbo].[PV_GIFT_CARD_MOVEMENT_BY_DAY] as
select LEFT(pgc.COMPANY_CODE,2) as AFFILIATE_CODE,
    pgc.COMPANY_CODE,
    pgcl.MOVEMENT_DT as MOVEMENT_DATE,
    pgca.GIFT_CARD_TYPE as GIFT_CARD_TYPE,
    pgc.CARD_NO as CARD_NO,
    pgc.GIFT_CARD_STATUS,
    pgc.ACTIVATE_DATE ,
    pgc.EXPIRY_DATE ,
    sum(Movement_amt) as BALANCE
from PM_GIFT_CARD pgc
inner join PM_GIFT_CARD_ATTR pgca
    on pgca.GIFT_CARD_ATTR_ID = pgc.GIFT_CARD_ATTR_ID_FK
left join PL_GIFT_CARD_LOG pgcl
    on pgcl.COMPANY_CODE = pgc.COMPANY_CODE
    and pgcl.CARD_NO = pgc.CARD_NO
where pgc.GIFT_CARD_STATUS = 'ACTIVE'
    and pgca.GIFT_CARD_TYPE NOT IN ('STORE_CREDIT')
    /*and pgc.expiry_date > getDate()
    and pgc.COMPANY_CODE = 'AULL'*/
group by pgc.COMPANY_CODE ,pgcl.MOVEMENT_DT,pgc.CARD_NO,pgc.ACTIVATE_DATE ,
    pgc.EXPIRY_DATE , pgca.GIFT_CARD_TYPE, pgc.GIFT_CARD_STATUS;
