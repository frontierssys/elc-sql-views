-- dbo.PMV_SALES_LOYALTY_MOVEMENT_BY_TRANSACTION source

CREATE   view [dbo].[PMV_SALES_LOYALTY_MOVEMENT_BY_TRANSACTION]
--WITH SCHEMABINDING
AS
select
    pvbm.COMPANY_CODE as COMPANY_CODE,
    case
        when pvbm.POS_MEMO_NO is not null then pvbm.POS_MEMO_NO
        else pvbm.VIP_BP_MOVEMENT_ID
    end as POS_MEMO_NO,
    --LOYALTY_POINT_TYPE as LOYALTY_POINT_TYPE,
    sum(pvbm.POINT_MOVEMENT) as LOYALTY_POINTS
from dbo.PL_VIP_BP_MOVEMENT pvbm
WHERE pvbm.ORDER_TXN_DATE >=GETDATE() -60
group by
    pvbm.COMPANY_CODE,
    case
        when pvbm.POS_MEMO_NO is not null then pvbm.POS_MEMO_NO
        else pvbm.VIP_BP_MOVEMENT_ID
    end
    --, LOYALTY_POINT_TYPE;
