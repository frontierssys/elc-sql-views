CREATE   VIEW PV_R0041 as
select
    COMPANY_CODE,
    GC_SEQ_NO,
    CARD_NO,
    GIFT_CARD_STATUS,
    FACE_VALUE,
    BALANCE,
    EXPIRY_DATE,
    case
        when ACTIVATE_DATE is null then CRE_DATET
        else TX_DATE
    end as TX_DATE,
    case
        when ACTIVATE_DATE is null then 'NOT_ISSUED'
        when ACTIVATE_DATE is not null and row_num = 1 then 'PURCHASE'
        when ACTIVATE_DATE is not null and row_num > 1 then 'REDEMPTION'
        else null
    end as TX_TYPE,
    ISNULL(GIFT_CARD_LOG_LOCATION_CODE, GIFT_CARD_MASTER_LOCATION_CODE) AS LOCATION_CODE,
    ISNULL(GIFT_CARD_LOG_STORE_TYPE_NAME, GIFT_CARD_MASTER_STORE_TYPE_NAME) AS STORE_TYPE_NAME,
    ORDER_NUMBER,
    case
        when row_num = cnt then 'YES'
        else null
    end as LATEST_TX
from
    PV_R0041_SUB
