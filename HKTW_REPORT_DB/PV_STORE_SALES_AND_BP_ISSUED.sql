CREATE   VIEW [dbo].[PV_STORE_SALES_AND_BP_ISSUED] AS
Select a.company_code, a.LOCATION_NAME,a.LOCATION_DESC,a.location_code,a.STORE_TYPE_NAME ,a.STORE_LOCATION,CONVERT(varchar(10), a.TX_DATE, 126) as TX_DT,
    SUM(SALES_AMT) as totalSales,SUM(LOYALTY_POINTS_ISSUED) as totalPoints
from (
    SELECT
        pvbm.COMPANY_CODE ,
        pl.LOCATION_NAME ,
        pl.LOCATION_DESC,
        pvbm.LOCATION_CODE ,
        pst.STORE_TYPE_NAME  as STORE_TYPE_NAME,
        pl.CITY_TXT as STORE_LOCATION,
        --pvbm.ORDER_TXN_DATE as TX_DATE,
        CAST(psm.TX_DATE as date) as TX_DATE,
        psm.POS_MEMO_NO ,
        psm.TOTAL_NET_AMT as SALES_AMT,
        SUM(pvbm.POINT_MOVEMENT)  as LOYALTY_POINTS_ISSUED
    from PT_SALES_MEMO psm
    inner join PL_VIP_BP_MOVEMENT pvbm
        on pvbm.COMPANY_CODE = psm.COMPANY_CODE
        and pvbm.POS_MEMO_NO = psm.POS_MEMO_NO
    inner join PM_LOCATION pl
        on pvbm.COMPANY_CODE = pl.COMPANY_CODE
        and psm.LOCATION_ID_FK = pl.LOCATION_ID
    inner join PM_STORE_TYPE pst
        on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
        --where pvbm.location_code like 'HKOR%' --and psm.MEMO_NO ='HKOR0021011X21000199'
        --and psm.TX_DATE <='2021-04-30 23:59:56' and psm.TX_DATE >='2021-04-01 00:00:00'
    GROUP BY
        pvbm.COMPANY_CODE ,
        pl.LOCATION_NAME ,
        pl.LOCATION_DESC,
        pvbm.LOCATION_CODE ,
        pst.STORE_TYPE_NAME ,
        pl.CITY_TXT ,
        CAST(psm.TX_DATE as date),
        psm.POS_MEMO_NO ,
        psm.TOTAL_NET_AMT) a
group by a.company_code, a.LOCATION_NAME,a.LOCATION_DESC,a.location_code,a.STORE_TYPE_NAME ,a.STORE_LOCATION, CONVERT(varchar(10), a.TX_DATE, 126)
