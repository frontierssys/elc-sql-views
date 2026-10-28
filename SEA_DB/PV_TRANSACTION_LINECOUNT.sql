-- dbo.PV_TODAY_ITEM_PRICE source

-- CREATE   VIEW [dbo].[PV_TODAY_ITEM_PRICE] as
-- with TODAY_PRICE AS
-- (
-- select
-- 	TOP 100 PERCENT
-- --	pp.COMPANY_CODE ,
-- 	pp.SKU_ID_FK,
-- 	pp.EFFECTIVE_DT ,
-- 	pp.CRE_DATET ,
-- 	pp.EXPIRY_DT ,
-- 	pp.CUR_RETAIL_PRICE ,
-- 	pp.D_CHAIN ,
-- 	ROW_NUMBER() OVER (PARTITION BY pp.SKU_ID_FK order by pp.EFFECTIVE_DT DESC, pp.EXPIRY_DT ASC, pp.CRE_DATET DESC) AS rn
-- from
-- 	PM_PRICE pp
-- inner join PM_PRICE_BOOK ppb
-- on pp.PRICE_BOOK_ID_FK = ppb.PRICE_BOOK_ID
-- where
-- 	pp.EFFECTIVE_DT <= GETDATE()
-- 	and (pp.EXPIRY_DT is null
-- 	or pp.EXPIRY_DT >= GETDATE())
-- 	--and ppb.PRICE_ZONE IN  ( case when pp.COMPANY_CODE IN  ('AUCS','NZCS') then ('6035-10')
-- 		--						when pp.COMPANY_CODE NOT IN  ('AUCS','NZCS') AND pp.COMPANY_CODE like  'AU%' then '6030-10'
-- 			--					when pp.COMPANY_CODE NOT IN  ('AUCS','NZCS') AND pp.COMPANY_CODE like  'NZ%' then '6250-10'
-- 				--				else '6030-10' end)
-- )
-- select
-- 	*
-- from
-- 	TODAY_PRICE
-- where
-- 	rn = 1;
CREATE view [dbo].[PV_TRANSACTION_LINECOUNT] as
select psm.SALES_MEMO_ID , count(psmih.SALES_MEMO_ITEM_H_ID) as LINECOUNT
from PT_SALES_MEMO psm
inner join PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
group by psm.SALES_MEMO_ID
