CREATE   VIEW  [dbo].[PV_R0026] AS
SELECT
    irtwh.COMPANY_CODE ,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as LOCATION_CODE,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    CAST (irtwh.CRE_DATET as date)  as CREATED_DATE,
    CAST (irtwh.CRE_DATET as date)  as TX_DATE,
    irtwh.CRE_BY as CREATED_BY_EMPLOYEE_ID,
    ps.FIRST_NAME + ' '+ps.LAST_NAME as CREATED_BY_EMPLOYEE_NAME,
    irtwh.OVERALL_APPROVE_DT as APPROVED_DATE,
    irtwh.OVERALL_APPROVED_BY as FINAL_APPROVAL_BY_EMPLOYEE_ID,
    ps2.FIRST_NAME + ' ' + ps2.LAST_NAME as FINAL_APPROVAL_BY_EMPLOYEE_NAME,
    irtwh.OVERALL_APPROVE_DT as COMPLETED_DATE,
    irtwh.RTW_NO as RTW_ID,
    psd.SKU_10 ,
    psd.SKU_6 ,
    psd.SKU_4 ,
    psd.PRODUCT_NAME as PRODUCT_DESCRIPTION ,
    irtwd.QTY as QUANTITY,
    psd.RETAIL_PRICE as PRICE,
    irtwd.QTY * psd.RETAIL_PRICE as VALUE,
    irtwh.REASON + ' - ' + irtwh.REASON_DESC as REASON_CODE,
    irtwh.STATUS as STATUS,
    pl.SAP_CUSTOMER_CODE  as SAP_CUSTOMER_CODE
from IT_RETURN_TO_WAREHOUSE_H irtwh
inner join IT_RETURN_TO_WAREHOUSE_D irtwd
    on irtwd.RTW_H_ID_FK = irtwh.RTW_H_ID
inner JOIN IT_DOC_APPROVAL_FLOW_H idafh
    on idafh.DOC_ID = irtwh.RTW_NO
inner join PM_LOCATION pl
    on irtwh.LOCATION_CODE = pl.LOCATION_CODE
    and irtwh.COMPANY_CODE = pl.COMPANY_CODE
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
left join PV_SKU_DETAIL psd
    on psd.COMPANY_CODE = irtwd.COMPANY_CODE
    and psd.SKU_10 = irtwd.SKU_CODE
left join PM_USER pu
    on pu.COMPANY_CODE = irtwh.COMPANY_CODE
    and pu.USER_CODE = irtwh.CRE_BY
left join PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
left join PM_USER pu2
    on irtwh.COMPANY_CODE = pu2.COMPANY_CODE
    and irtwh.OVERALL_APPROVED_BY = pu2.USER_CODE
left join PM_STAFF ps2
    on pu2.STAFF_ID_FK = ps2.STAFF_ID
where idafh.OVERALL_APPROVAL_STATUS ='APPROVED'
