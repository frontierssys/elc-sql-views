CREATE   view [dbo].[PV_R0035_backup_20231023] as
SELECT
    pvbm.ORDER_NO as ADJUSTMENT_NUMBER,
    CAST(ORDER_TXN_DATE as date) as TX_DATE,
    CAST(ORDER_TXN_DATE as date) as ADJUSTMENT_DATE,
    CAST(ORDER_TXN_DATE as time) as TIME,
    pvbm.CRE_BY as ADJUSTMENT_PERFORMED_BY_ID,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as ADJUSTMENT_PERFORMED_BY_NAME,
    pvbm.COMPANY_CODE as COMPANY_CODE,
    pv.VIP_NO as CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME as CUSTOMER_NAME,
    pvbm.REMARKS as NOTE,
    pvbm.POINT_MOVEMENT as NUMBER_OF_POINTS,
    sum(a.TOTAL_POINTS) - pvbm.POINT_MOVEMENT as POINTS_BEFORE,
    sum(a.TOTAL_POINTS) as POINTS_AFTER
FROM PL_VIP_BP_MOVEMENT pvbm
inner join PM_VIP pv
--on pvbm.VIP_ID_FK = pv.VIP_ID
    on pvbm.VIP_NO = pv.VIP_NO
    and pvbm.COMPANY_CODE =pv.COMPANY_CODE
inner join PM_CUSTOMER pc
    on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
    /*left join PV_VIP_POINTS_BALANCE pvpb
    on pvpb.VIP_ID = pv.VIP_ID
    and pvpb.EXPIRY_DATE is not null*/
left join (
    select COMPANY_CODE,VIP_NO,MOVEMENT_DT,sum(POINT_MOVEMENT) as TOTAL_POINTS
    from PL_VIP_BP_MOVEMENT pvbm --where VIP_NO ='HQ000002782'
    group by COMPANY_CODE,VIP_NO,MOVEMENT_DT) a
    ON a.VIP_NO=pvbm.VIP_NO and a.COMPANY_CODE=pvbm.COMPANY_CODE and a.MOVEMENT_DT<= pvbm.ORDER_TXN_DATE
left join PM_USER pu
    on pvbm.COMPANY_CODE = pu.COMPANY_CODE
    and pvbm.CRE_BY = pu.USER_CODE
left join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
where pvbm.MOVEMENT_TYPE = 'ADJUSTMENT'
    and pvbm.POINT_MOVEMENT<>0
group by
    pvbm.ORDER_NO ,
    CAST(ORDER_TXN_DATE as date),
    CAST(ORDER_TXN_DATE as time),
    pvbm.CRE_BY,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME,
    pvbm.COMPANY_CODE,
    pv.VIP_NO,
    pc.FIRSTNAME + ' ' + pc.SURNAME ,
    pvbm.REMARKS,
    pvbm.POINT_MOVEMENT;
