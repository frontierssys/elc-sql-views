-- dbo.PV_R8803_SUB source

-- dbo.PV_R8803_SUB_bk20220728 source

-- dbo.PV_R8803_SUB source

-- dbo.PV_R8803_SUB_BA_CN_NAME source

CREATE   view [dbo].[PV_R8803_SUB] as
select
    pst.TG_COMPANY_CODE COMPANY_CODE,
    pst.TG_COMPANY_CODE BRAND_CODE,
    pst.COMPANY_DESC BRAND_DESC,
    pst.TG_LOCATION_CODE LOCATION_CODE,
    pst.TG_LOCATION_DESC LOCATION_DESC,
    pst.STAFF_NO STAFF_NO,
    TG_FIRST_NAME FIRST_NAME,
    TG_TARGET_DATE F_TX_DT,
    isnull(bs.WEEK_NAME, datename(weekday, CONVERT(varchar(100), pst.DATE_FROM, 111))) WEEK_NAME,
    isnull( pst.TARGET_AMOUNT, 0) as TG_AMT,
    isnull(bs.NET_LINE_AMT, 0) NET_LINE_AMT,
    isnull(bs.PERSON_COUNT, 0) PERSON_COUNT,
    isnull(bs.SAL_QTY, 0) SAL_QTY
from
    (
        select
            psm.COMPANY_CODE ,
            --	pc.EXT_DIVISION_CODE as BRAND_CODE,
            psm.COMPANY_CODE as BRAND_CODE, pc.COMPANY_DESC as BRAND_DESC, pl.LOCATION_CODE , pl.LOCATION_DESC , pu.USER_CODE as STAFF_NO , pu.NAME as FIRST_NAME, psm.TX_DATE as F_TX_DT, psm.LOCATION_ID_FK, pu.USER_CODE , datename(weekday, CONVERT(varchar(100), psm.TX_DT, 111)) WEEK_NAME,
            --isnull(	pst.TARGET_AMOUNT,0) as TG_AMT,
            sum(psmih.NET_LINE_AMT) as NET_LINE_AMT,
            count(distinct (
                case
                    when psm.TXN_MODE <> 'IOU' then  MEMO_NO
                end)) as PERSON_COUNT,
            sum(psmih.qty) as SAL_QTY
        from
            PT_SALES_MEMO psm
        inner join PT_SALES_MEMO_ITEM_H psmih on
            psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
        left join PT_MEMO_ITEM_STAFF_SET pmiss on
            psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
        left join PT_SALES_MEMO_ITEM_STAFF psmis on
            psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
        inner join PM_COMPANY pc on
            psm.COMPANY_CODE = pc.COMPANY_CODE
        inner join PM_LOCATION pl on
            pl.LOCATION_ID = psm.LOCATION_ID_FK
        inner join PM_USER pu on
            psmis.STAFF_NO = pu.USER_CODE
            and psm.COMPANY_CODE = pu.COMPANY_CODE
        inner join PM_SALES_MEMO_TYPE psmt on
            psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
        left join PT_SALES_MEMO_PAYMENT psmp on
            psmp.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
            and psmp.DEPOSIT_NO is not null
        where
            psmt.TYPE_CODE not in ('05', '06', '07', '09', '10', '11', '99', '08')
            and psm.MEMO_STATUS not in ('VOIDED')
            and psm.MEMO_KIND not in ('RESERVE', 'handoff')
            and psm.PICKUP_STATUS <> 'PICKUPED'
            and psmp.DEPOSIT_NO is null
        group by psm.COMPANY_CODE ,
        --pc.EXT_DIVISION_CODE ,
            pc.COMPANY_DESC , pl.LOCATION_CODE , pl.LOCATION_DESC , pu.USER_CODE, pu.NAME , psm.LOCATION_ID_FK, psm.TX_DATE , datename(weekday, CONVERT(varchar(100), psm.TX_DT, 111)) ) bs
right join (
    select
        t.*,
        --CONVERT(varchar(100), t.DATE_FROM , 111) TG_TARGET_DATE,
        t.DATE_FROM TG_TARGET_DATE,
        C.COMPANY_CODE AS TG_COMPANY_CODE ,
        c.COMPANY_DESC, l.LOCATION_CODE as TG_LOCATION_CODE,
        l.LOCATION_DESC AS TG_LOCATION_DESC,
        pu.NAME as TG_FIRST_NAME
    from
        PM_SALES_TARGET t
    inner join PM_COMPANY c on
        t.COMPANY_CODE = c.COMPANY_CODE
    inner join PM_LOCATION l on
        l.COMPANY_CODE = t.COMPANY_CODE
        and t.LOCATION_ID_FK = l.LOCATION_ID
    inner join PM_STAFF staff on
        t.STAFF_NO = staff.STAFF_CODE
        and t.COMPANY_CODE = staff.COMPANY_CODE
    left join PM_USER pu on  pu.STAFF_ID_FK =staff.STAFF_ID
    where
        t.SALES_TARGET_TYPE = 'DAILY'
        and t.STAFF_NO is not null ) pst on
    pst.COMPANY_CODE = bs.COMPANY_CODE
    and pst.LOCATION_ID_FK = bs.LOCATION_ID_FK
    and pst.SALES_TARGET_TYPE = 'DAILY'
    and pst.STAFF_NO = bs.USER_CODE
    and pst.DATE_FROM = bs.F_TX_DT
