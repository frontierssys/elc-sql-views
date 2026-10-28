CREATE   VIEW PV_R0027 as
select
    pv.COMPANY_CODE ,
    lastStore.STORE_TYPE_CODE as STORE_TYPE,
    CAST(psm3.TX_DT as date) as TX_DT,
    pv.VIP_NO as CONSUMER_ID,
    pc.TITLE as SALUTATION,
    pc.SURNAME as LAST_NAME,
    pc.FIRSTNAME as FIRST_NAME,
    --pcs.TEL1,
    CONCAT((COALESCE (pc.CELLPHONE_AREA_CODE,pc.CELLPHONE_COUNTRY_CODE)),' ',pcs.TEL1) as TEL1 ,
    --pcs.TEL2 ,
    CONCAT((COALESCE (pc.HOME_PHONE_AREA_CODE,pc.HOME_PHONE_COUNTRY_CODE)),' ',pcs.TEL2) as TEL2,
    pcs.EMAIL ,
    lastStore.LOCATION_ID as PURCHASE_STORE_ID,
    lastStore.LOCATION_NAME as PURCHASE_STORE_NAME,
    pcs.BIRTH_M ,
    pcs.BIRTH_D ,
    pv.APPLY_LOCATION as CREATION_STORE_ID,
    plapply.LOCATION_NAME as CREATION_STORE_NAME,
    pv.JOIN_DT as CREATION_DATE,
    --pc.PREF_LOC_CODE as FIRST_PURCHASE_STORE_ID,
    COALESCE (pc.PREF_LOC_CODE,pv.APPLY_LOCATION) as FIRST_PURCHASE_STORE_ID,
    plfirst.LOCATION_NAME as FIRST_PURCHASE_STORE_NAME,
    pc.FIRST_PURCHASE_DT as FIRST_PURCHASE_DATE,
    lastStore.LOCATION_ID as LAST_PURCHASE_STORE_ID,
    lastStore.LOCATION_NAME as LAST_PURCHASE_STORE_NAME,
    lastStore.TX_DATE as LAST_PURCHASE_DATE,
    lastStore.LOCATION_ID as MOST_FREQUENT_STORE_ID,
    lastStore.LOCATION_NAME as MOST_FREQUENT_STORE_NAME,
    pvlr.POINT_MOVEMENT as LAST_LOYALTY_REDEMPTION ,
    pvls.LIFETIME_SPEND as LIFETIME_SPEND,
    pvls.LIFETIME_TX_COUNT as LIFETIME_TRANSACTION,
    psm3.TOTAL_NET_AMT as SPEND_WITHIN_RANGE,
    CASE
        when pvpbt.POINTS > 0 then pvpbt.POINTS
        else 0
    end as LOYALTY_POINT_GAINED_WITHIN_RANGE,
    CASE
        when pvpbt.POINTS < 0 then pvpbt.POINTS
        else 0
    end as LOYALTY_POINTS_REDEEMED_WITHIN_RANGE,
    1 as TRANSACTION_WITHIN_RANGE,
    pvys.LIFETIME_SPEND as FY_YTD_SPEND,
    pvys.LIFETIME_TX_COUNT as FY_YTD_TRANS,
    pvps.LIFETIME_SPEND as ROLLING_12_SPEND,
    pvps.LIFETIME_TX_COUNT as ROLLING_12_TRANS,
    pv.EXPIRY_DT as LOYALTY_EXPIRE_DATE,
    pvpb.POINTS as CURRENT_LOYALTY_POINTS,
    pvpr.REDEEM_POINTS as REDEEMED_POINTS,
    PC.ALLOW_SMS as OPT_IN_SMS,
    pc.ALLOW_CALL as OPT_IN_PHONE,
    pc.ALLOW_EMAIL as OPT_IN_EMAIL,
    pc.ALLOW_MAIL as OPT_IN_DIRECT_MAIL,
    pcs.AGE_GRP as AGE_GROUP,
    pvg.VIP_GRADE_CODE as LOYALTY_TIER,
    pn.DESCRIPTION as CONSUMER_LOCATION
FROM
    PM_VIP pv
inner join PM_CUSTOMER pc
    on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
inner join PM_CUSTOMER_SECRET pcs
    on pc.CUSTOMER_ID = pcs.CUSTOMER_ID_FK
LEFT JOIN PV_VIP_GRADE pvg
    on pvg.COMPANY_CODE=pv.COMPANY_CODE AND pvg.VIP_NO= pv.VIP_NO
LEFT JOIN dbo.PM_NATION pn
    on pcs.COMPANY_CODE = pn.COMPANY_CODE
    and pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
left join PT_SALES_MEMO psm3
    on pv.COMPANY_CODE = psm3.COMPANY_CODE
    and pv.VIP_NO = psm3.VIP_NO
left join PM_SALES_MEMO_TYPE psmt2
    on psm3.SALES_MEMO_TYPE_ID_FK = psmt2.SALES_MEMO_TYPE_ID
left join PM_LOCATION plapply
    on plapply.COMPANY_CODE = pv.COMPANY_CODE
    and plapply.LOCATION_CODE = pv.APPLY_LOCATION
left join PM_LOCATION plfirst
    on plfirst.COMPANY_CODE = pv.COMPANY_CODE
    and plfirst.LOCATION_CODE = COALESCE (pc.PREF_LOC_CODE,pv.APPLY_LOCATION)
left join PV_VIP_POINT_BY_TRANSACTION pvpbt
    on psm3.SALES_MEMO_ID = pvpbt.SALES_MEMO_ID
left join PMV_VIP_LIFETIME_SPENDING pvls
    on pvls.VIP_ID = pv.VIP_ID
left join PMV_VIP_YTD_SPENDING pvys
    on pvys.VIP_ID = pv.VIP_ID
left join PMV_VIP_P12_SPENDING pvps
    on pvps.VIP_ID = pv.VIP_ID
left join (
    SELECT COMPANY_CODE ,VIP_NO,sum(POINT_MOVEMENT) as POINTS
    FROM dbo.PL_VIP_BP_MOVEMENT
    Group by COMPANY_CODE,VIP_NO) pvpb
    on pvpb.VIP_NO = pv.VIP_NO and pvpb.COMPANY_CODE=pv.COMPANY_CODE
left join (
    SELECT COMPANY_CODE ,VIP_NO,sum(POINT_MOVEMENT) as REDEEM_POINTS
    FROM dbo.PL_VIP_BP_MOVEMENT
    WHERE MOVEMENT_TYPE='GIFT'
    Group by COMPANY_CODE,VIP_NO) pvpr
    on pvpr.VIP_NO = pv.VIP_NO and pvpr.COMPANY_CODE=pv.COMPANY_CODE
left join PMV_VIP_LAST_REDEMPTION pvlr
    on pvlr.VIP_ID = pv.VIP_ID
left join
    (
        select
            ROW_NUMBER() OVER(
                PARTITION BY pv2.COMPANY_CODE , pv2.VIP_NO
                ORDER BY psm.TX_DT DESC) AS "ROW_NUM",
            pv2.COMPANY_CODE ,
            pv2.VIP_NO ,
            --psm.LOCATION_ID_FK  as LOCATION_ID,
            pl.LOCATION_CODE  as LOCATION_ID,
            pl.LOCATION_NAME  as LOCATION_NAME,
            pst.STORE_TYPE_CODE ,
            psm.TX_DT as TX_DATE
        from PT_SALES_MEMO psm
        inner join PM_VIP pv2
            on psm.VIP_NO = pv2.VIP_NO
            and psm.COMPANY_CODE = pv2.COMPANY_CODE
        inner join PM_LOCATION pl
            on pl.LOCATION_ID = psm.LOCATION_ID_FK
        inner join PM_STORE_TYPE pst
            on pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
    ) lastStore
    on pv.COMPANY_CODE = lastStore.COMPANY_CODE
    and pv.VIP_NO = lastStore.VIP_NO
    and lastStore.ROW_NUM = 1
where psmt2.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm3.MEMO_STATUS not in ('VOIDED')
    and psm3.MEMO_KIND not in ('RESERVE', 'handoff')
    --and psa.IH_L1 = '110'
    and psm3.VIP_NO is not NULL
