-- dbo.PV_R0051 source

-- dbo.PV_R0051 source
CREATE  VIEW [dbo].[PV_R0051] AS
SELECT
    pal.COMPANY_CODE ,
    pst.STORE_TYPE_CODE ,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    pu.USER_CODE as EMPLOYEE_ID_CASHIER,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as EMPLOYEE_NAME_CASHIER,
    ps3.STAFF_CODE as EMPLOYEE_ID_COMMISSION,
    ps3.FIRST_NAME + ' ' + ps3.LAST_NAME as EMPLOYEE_NAME_COMMISSION,
    pu2.USER_CODE as MANAGER_OVERRIDE_ID,
    ps2.FIRST_NAME + ' ' + ps2.LAST_NAME MANAGER_OVERRIDE_NAME,
    psm.TX_DATE  as TX_DATE,
    CAST (psm.TX_DT as time) as TX_TIME,
    psm.MEMO_NO as TRANSACTION_NO,
    psm.VIP_NO as CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME as CUSTOMER_NAME,
    psmiha.VIRTUAL_SET_PARENT_SKU as VIRTUAL_SET_ID,
    isnull(psV.SKU_DESC , piV.ITEM_DESC_1 ) as VIRTUAL_SET_DESCRIPTION,
    CASE
        when psmiha.VIRTUAL_SET_PARENT_SKU is null then 'N'
        ELSE 'Y'
    end as IS_VIRTUAL_SET,
    pslmbt.LOYALTY_POINTS ,
    psd.SKU_4 ,
    psd.SKU_6 ,
    psd.SKU_10 as SKU_ID,
    psd.PRODUCT_NAME as PRODUCT_DESCRIPTION,
    psmih.CUR_RETAIL_PRICE ,
    psmih.QTY as QUANTITY_SOLD,
    psiq.TOTAL_QTY as QTY_OF_ITEM,
    psiq.NO_OF_ITEM as QTY_OF_INDIVIDUAL_SKU,
    psmih.CUR_RETAIL_PRICE * psmih.QTY as TOTAL_RETAIL_PRICE,
    psmih.LINE_DISC_AMT as DISCOUNT_AMOUNT,
    --CONCAT(cast(cast(psmih.LINE_DISC_AMT*100 as float)/(psmih.CUR_RETAIL_PRICE*psmih.QTY) as decimal(10,2)), '%') as DISCOUNT_PERCENTAGE,
    '0' as DISCOUNT_PERCENTAGE,
    psmih.NET_LINE_AMT as NET_SALES,
    psmih.NET_LINE_AMT as SALES_VALUE,
    psm.TOTAL_NET_AMT  as TRANSACTION_SALES_VALUE,
    CASE
        when
            (
                select SUM(psmih1.QUANTITY) as t
                from PV_SALES_ITEM psmih1
                where psmih1.SALES_MEMO_ID = psm.SALES_MEMO_ID and psmih1.MATERIAL_CODE_10 = psmih.sku AND psmih1.SALEABLE ='Y' ) > 8
        then 'Yes'
        else 'No'
    end as ITEM_LIMIT,
    CASE
        when
            (
                select SUM(psmih1.QUANTITY) as t
                from PV_SALES_ITEM psmih1
                where psmih1.SALES_MEMO_ID = psm.SALES_MEMO_ID AND psmih1.SALEABLE ='Y') > 14
        then 'Yes'
        else 'No'
    end as TRAN_LIMIT,
    CASE
        when PSM.VIP_NO IS NOT NULL then
            CASE
                when
                    (
                        SELECT QUANTITY
                        FROM PV_R0051_MULTIPLE A
                        WHERE A.TX_DATE=psm.TX_DATE AND A.MATERIAL_CODE_10 =psmih.SKU AND A.VIP_NO=psm.VIP_NO AND A.LOCATION_ID_FK=psm.location_id_fk) > 8
                then 'y'
                else 'n'
            end
        else
            'n'
    end
as ITEM_MULTIPLE,
    CASE
        when PSM.VIP_NO IS NOT NULL then
            CASE
                when
                    (
                        SELECT SUM(QUANTITY)
                        FROM PV_R0051_MULTIPLE A
                        WHERE A.TX_DATE=psm.TX_DATE AND A.VIP_NO=psm.VIP_NO AND A.LOCATION_ID_FK=psm.location_id_fk) > 14
                then 'Yes'
                ELSE 'No'
            end
        else
            'No'
    end
as TRAN_MULTIPLE
from
    PL_AUTHORIZATION_LOG pal
inner join PT_SALES_MEMO psm
    on psm.COMPANY_CODE = pal.COMPANY_CODE
    and psm.MEMO_NO = pal.AUTH_REF_NO
inner join PMV_SALES_ITEM_QTY psiq
    on psm.SALES_MEMO_ID = psiq.SALES_MEMO_ID
inner join PT_SALES_MEMO_ITEM_H psmih
    on psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join PT_SALES_MEMO_ITEM_H_ATTR psmiha
    on psmih.SALES_MEMO_ITEM_H_ATTR_ID_FK = psmiha.SALES_MEMO_ITEM_H_ATTR_ID
inner join dbo.PT_MEMO_ITEM_STAFF_SET pmiss
    on psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
inner join dbo.PT_SALES_MEMO_ITEM_STAFF psmis
    on psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
inner join dbo.PM_STAFF ps3
    on ps3.COMPANY_CODE = psmis.COMPANY_CODE
    and ps3.STAFF_CODE = psmis.STAFF_NO
inner join PV_SKU_DETAIL psd
    on psmih.COMPANY_CODE = psd.COMPANY_CODE
    and psmih.SKU = psd.SKU_10
inner join PM_LOCATION pl
    on pl.LOCATION_ID = psm.LOCATION_ID_FK
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
left join PM_USER pu
    on psm.COMPANY_CODE = pu.COMPANY_CODE
    and psm.CRE_BY = pu.USER_CODE
left join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
left join PM_USER pu2
    on pu2.COMPANY_CODE = pal.COMPANY_CODE
    and pu2.USER_CODE = pal.AUTH_BY
left join PM_STAFF ps2
    on pu2.STAFF_ID_FK = ps2.STAFF_ID
left join PM_VIP pv
    on psm.COMPANY_CODE = pv.COMPANY_CODE
    and psm.VIP_NO = pv.VIP_NO
left join PM_CUSTOMER pc
    on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
left join PM_VIRTUAL_SET_H pvsh
    on psmiha.VIRTUAL_SET_PARENT_SKU = pvsh.SKU_CODE
    and psmiha.COMPANY_CODE = pvsh.COMPANY_CODE
left join PM_SKU psV
    on psV.COMPANY_CODE = pvsh.COMPANY_CODE
    and psV.SKU_CODE = pvsh.SKU_CODE
left join PM_ITEM piV
    on piV.ITEM_ID = psV.ITEM_ID_FK
left join PMV_SALES_LOYALTY_MOVEMENT_BY_TRANSACTION pslmbt
    on pslmbt.COMPANY_CODE = psm.COMPANY_CODE
    and pslmbt.POS_MEMO_NO = psm.POS_MEMO_NO
where
    pal.AUTH_FUNCTION = 'authorizeOverPurchaseAmt'
