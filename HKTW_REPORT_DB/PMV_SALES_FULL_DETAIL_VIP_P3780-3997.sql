-- dbo.[PMV_SALES_FULL_DETAIL_VIP_P3780-3997] source

CREATE   view [PMV_SALES_FULL_DETAIL_VIP_P3780-3997]
--WITH SCHEMABINDING
AS
SELECT
    pc.COMPANY_CODE as COMPANY_CODE,
    pc.COMPANY_DESC as COMPANY_DESC,
    pst.STORE_TYPE_CODE as STORE_TYPE_CODE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.LOCATION_DESC,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_DESC as STORE_NAME,
    psmt.TYPE_DESC as SALES_TYPE,
    pt.TERMINAL_NO as TERMINAL_ID,
    psm.SALES_MEMO_ID as SALES_MEMO_ID,
    psm.MEMO_NO as TRANSACTION_ID,
    psm.TX_DATE  as TRANSACTION_DATE,
    CAST(psm.TX_DT as time) as TRANSACTION_TIME,
    PSM.CRE_BY AS EMPLOYEE_ID,
    ps.FIRST_NAME as EMPLOYEE_NAME,
    COALESCE (ps2.STAFF_CODE,psmis.STAFF_NO) as COMMISSION_EMPLOYEE_ID,
    ps2.FIRST_NAME as COMMISSION_EMPLOYEE_NAME,
    psm.VIP_NO as CONSUMER_ID,
    ISNULL(pc2.FIRSTNAME,'') + ' ' + ISNULL(pc2.SURNAME,'')  as CONSUMER_NAME,
    pn.DESCRIPTION as CONSUMER_LOCATION,
    --'' as CONSUMER_LOCATION,
    pi2.BUSINESS_UNIT_CODE +' ' + pb2.BU_DESC as 'CLASS',
    pi2.BUSINESS_UNIT_CODE +' ' + pb2.BU_DESC as 'MAJOR_CATEGORY',
    pi2.DEPT_CODE + ' ' + pd.DEPT_NAME as 'DEPARTMENT',
    pi2.DEPT_CODE + ' ' + pd.DEPT_NAME as 'APPLICATION',
    pc3.CLASS_CODE +' ' + pc3.CLASS_DESC as 'SUB_DEPARTMENT',
    pc3.CLASS_CODE +' ' + pc3.CLASS_DESC as 'CATEGORY',
    ps4.SUBCLASS_CODE + ' ' + ps4.SUBCLASS_DESC as 'DIVISION',
    ps4.SUBCLASS_CODE + ' ' + ps4.SUBCLASS_DESC as 'SUB_CATEGORY',
    CONCAT(psa.IH_L1,psa.IH_L2,psa.IH_L3) as 'INVENTORY_HIERARCHY',
    isnull(psa.LH_L1, 'NA') as 'LOCAL_L1',
    isnull(psa.LH_L2, 'NA') as 'LOCAL_L2',
    isnull(psa.LH_L3, 'NA') as 'LOCAL_L3',
    isnull(psa.LH_L4, 'NA') as 'LOCAL_L4',
    isnull(psa.IS_HERO_PRODUCT , 'NA') as 'LOCAL_L5',
    psmih.SKU as 'MATERIAL_CODE_10',
    SUBSTRING(psmih.sku,1,6) as 'MATERIAL_CODE_6',
    pi2.ITEM_CODE as 'MATERIAL_CODE_4',
    ps3.SKU_DESC as 'PRODUCT_NAME',
    pb.BRAND_DESC as 'PRODUCT_BRAND',
    --case when psa.IH_L1 = '110' then 'Y' else 'N' end as 'SALEABLE',
    CASE
        WHEN psmt.SALES_MEMO_TYPE_ID in ('03', '04') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END AS 'SALEABLE',
    case
        when psa.IH_L1 = '120' and psa.IH_L2 = '30' then 'Y'
        else 'N'
    end as 'SAMPLE',
    case
        when psa.IH_L1 = '120' and psa.IH_L2 = '32' then 'Y'
        else 'N'
    end as 'GIFT',
    'N' as 'GLOBAL_HERO',
    psmih.SALES_MEMO_ITEM_H_ID as SALES_MEMO_ITEM_H_ID,
    abs(psmih.CUR_RETAIL_PRICE) as SUGGESTED_RETAIL_PRICE,
    CASE
        WHEN psmt.TYPE_CODE = '09' and psmih.NET_LINE_AMT <= 0 then psmih.QTY * -1
        ELSE psmih.QTY
    end as QUANTITY,
    psmih.CUR_RETAIL_PRICE * psmih.qty as 'SALES_VALUE',
    --psmih.NET_LINE_AMT as NET_SALES,
    CASE
        when (
            CASE
                WHEN psmt.TYPE_CODE = '09' and psmih.NET_LINE_AMT < 0 then psmih.QTY * -1
                ELSE psmih.QTY
            end) >= 0 then ABS(psmih.NET_LINE_AMT)
        when (
            CASE
                WHEN psmt.TYPE_CODE = '09' and psmih.NET_LINE_AMT < 0 then psmih.QTY * -1
                ELSE psmih.QTY
            end) < 0 then ABS(psmih.NET_LINE_AMT)*-1
        else psmih.NET_LINE_AMT
    end as NET_SALES,
    psm.TOTAL_NET_AMT as TOTAL_TRANSACTION_NET_SALES,
    psmiha.VIRTUAL_SET_PARENT_SKU as VIRTUAL_SET_ID,
    pskh.SALES_KIT_DESC as VIRTUAL_SET_DESC,
    case
        when psm.MEMO_STATUS = 'VOIDED' then 'Y'
        else 'N'
    end as 'POST_VOID',
    CASE
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='MAC' THEN 'MO'
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='HKG' THEN 'HK'
        ELSE LEFT(pl.COMPANY_CODE,2)
    END as ENTITY
from dbo.PT_SALES_MEMO psm
inner join dbo.PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
left join dbo.PT_SALES_MEMO_ITEM_H_ATTR psmiha
    on psmiha.SALES_MEMO_ITEM_H_ATTR_ID = psmih.SALES_MEMO_ITEM_H_ATTR_ID_FK
left join dbo.PM_SALES_KIT_H pskh
    on pskh.COMPANY_CODE = psmiha.COMPANY_CODE
    and pskh.SKU_CODE = psmiha.VIRTUAL_SET_PARENT_SKU
inner join dbo.PM_COMPANY pc
    on psm.COMPANY_CODE = pc.COMPANY_CODE
inner join dbo.PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PM_TERMINAL pt
    on psm.TERMINAL_ID_FK = pt.TERMINAL_ID
left join dbo.PM_USER pu
    on psm.CRE_BY = pu.USER_CODE
    and pu.COMPANY_CODE = psm.COMPANY_CODE
left join dbo.PM_STAFF ps
    on pu.STAFF_ID_FK = ps.STAFF_ID
left join dbo.PT_MEMO_ITEM_STAFF_SET pmiss
    on psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
left join dbo.PT_SALES_MEMO_ITEM_STAFF psmis
    on psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
left join dbo.PM_STAFF ps2
    on ps2.COMPANY_CODE = psmis.COMPANY_CODE
    and ps2.STAFF_CODE = psmis.STAFF_NO
inner join dbo.PM_VIP pv
    on psm.VIP_NO = pv.VIP_NO
    and psm.VIP_CLUSTER_ID_FK = pv.VIP_CLUSTER_ID_FK
inner join dbo.PM_CUSTOMER pc2
    on pv.CUSTOMER_ID_FK = pc2.CUSTOMER_ID
inner join dbo.PM_CUSTOMER_SECRET pcs
    on pc2.CUSTOMER_ID = pcs.CUSTOMER_ID_FK
left join dbo.PM_NATION pn
    on pcs.COMPANY_CODE = pn.COMPANY_CODE
    and pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
    -------------------
inner join dbo.PM_SKU ps3
    on psmih.COMPANY_CODE = ps3.COMPANY_CODE
    and psmih.SKU = ps3.SKU_CODE
inner join dbo.PM_SKU_ATTR psa
    on ps3.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
inner join dbo.PM_ITEM pi2
    on ps3.ITEM_ID_FK = pi2.ITEM_ID
inner join dbo.PM_BU pb2
    on pi2.BUSINESS_UNIT_CODE = pb2.BU_CODE
    and pi2.COMPANY_CODE = pb2.COMPANY_CODE
inner join dbo.PM_DEPT pd
    on pd.COMPANY_CODE = pi2.COMPANY_CODE
    and pd.BU_ID_FK = pb2.BU_ID
    and pd.DEPT_CODE = pi2.DEPT_CODE
inner join dbo.PM_CLASS pc3
    on pi2.CLASS_ID_FK = pc3.CLASS_ID
inner join dbo.PM_SUBCLASS ps4
    on pi2.SUBCLASS_ID_FK = ps4.SUBCLASS_ID
inner join dbo.PM_BRAND pb
    on pi2.BRAND_ID_FK = pb.BRAND_ID
    -----------------------
where psmt.TYPE_CODE not in ('05','06','07','10','11','99','08')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.VIP_NO is not null;
