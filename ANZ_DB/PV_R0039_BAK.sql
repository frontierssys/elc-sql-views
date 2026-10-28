CREATE   VIEW PV_R0039_BAK as
select
    pr.COMPANY_CODE as BRAND,
    pr.COMPANY_CODE ,
    pr.LOCATION_CODE ,
    pr.DIVISION ,
    datediff(day, pr.EXPIRATION_DATE, getdate() ) as DAYS_AGING,
    pr.STORE_TYPE_NAME ,
    pr.STORE_LOCATION ,
    pr.STORE_ID ,
    pr.STORE_NAME ,
    pr.ORDER_TYPE ,
    pr.TRANSACTION_NUMBER as TYPE_ID,
    pr.STATUS ,
    pr.TRANSACTION_NUMBER as TRAN_NUMBER,
    pr.TX_DATE ,
    pr.ORIGINAL_PURCHASE_DATE as PURCHASE_DATE,
    pr.EXPIRATION_DATE ,
    pr.EXPIRED ,
    pr.CUSTOMER_ID ,
    pr.CUSTOMER_NAME ,
    pr.SKU10 ,
    pr.SKU6 ,
    pr.SKU4 ,
    pr.PRODUCT_DESCRIPTION ,
    pr.SALES_AMOUNT as AMOUNT_PAID,
    pr.REMAINING_BALANCE as OPEN_LIABILITY,
    getdate() as TODAY,
    pr.DAYS_SINCE_POURCHASE_DATE
from PV_R0038 pr
where pr.STATUS = 'OPEN'
--and pr.COMPANY_CODE = 'HKEL';


-- dbo.PV_R0051 source
