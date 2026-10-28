CREATE   VIEW  PV_R0036 as
SELECT
    pvbm.COMPANY_CODE ,
    pvbm.LOCATION_CODE ,
    pst.STORE_TYPE_CODE  as STORE_TYPE,
    pl.ADDRESS1 + pl.ADDRESS2  + pl.ADDRESS3 as STORE_LOCATION,
    pvbm.ORDER_TXN_DATE as TX_DATE,
    psm.POS_MEMO_NO ,
    psm.TOTAL_NET_AMT as SALES_AMT,
    sum(
        CASE
            when pvbm.POINT_MOVEMENT > 0 then pvbm.POINT_MOVEMENT
            else 0
        end ) as LOYALTY_POINTS_ISSUED,
    sum(
        CASE
            when pvbm.POINT_MOVEMENT < 0 then pvbm.POINT_MOVEMENT
            else 0
        end ) as LOYALTY_POINTS_REDEEMED
from PL_VIP_BP_MOVEMENT pvbm
inner join PM_LOCATION pl
    on pvbm.COMPANY_CODE = pl.COMPANY_CODE
    and pvbm.LOCATION_CODE = pl.LOCATION_CODE
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
left join PT_SALES_MEMO psm
    on pvbm.COMPANY_CODE = psm.COMPANY_CODE
    and pvbm.POS_MEMO_NO = psm.POS_MEMO_NO
GROUP BY
    pvbm.COMPANY_CODE ,
    pvbm.LOCATION_CODE ,
    pst.STORE_TYPE_CODE ,
    pl.ADDRESS1 + pl.ADDRESS2  + pl.ADDRESS3 ,
    pvbm.ORDER_TXN_DATE ,
    psm.POS_MEMO_NO ,
    psm.TOTAL_NET_AMT
