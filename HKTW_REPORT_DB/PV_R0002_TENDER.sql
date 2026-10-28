CREATE   view [dbo].[PV_R0002_TENDER] as
SELECT
    psm.company_code AS 'COMPANY_CODE',
    PC2.COMPANY_DESC AS company_desc,
    pl.location_code,
    PL.LOCATION_DESC,
    PL.CITY_TXT AS address,
    PST.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pt2.TERMINAL_NO,
    psm.TX_DATE  AS 'TX_DATE',
    pt.TENDER_CODE ,
    pt.TENDER_NAME ,
    sum(psmp.AMOUNT ) as SALES_AMOUNT,
    count(DISTINCT SALES_MEMO_ID ) as MEMO_COUNT,
    sum(
        case
            when psmp.seq = 1 then skucount.QTY
            else 0
        end ) as QTY
        --	psmp.SEQ ,
        --	psmp.AMOUNT as SALES_AMOUNT,
        --	SALES_MEMO_ID as MEMO_COUNT,
        --	skucount.QTY as QTY
        --COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT'
FROM dbo.PT_SALES_MEMO psm
INNER JOIN dbo.PM_SALES_MEMO_TYPE psmt ON
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PT_SALES_MEMO_PAYMENT psmp ON
    psmp.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join dbo.PM_TENDER pt on
    psmp.TENDER_ID_FK = pt.TENDER_ID
inner join dbo.PM_LOCATION pl on
    pl.LOCATION_ID = psm.LOCATION_ID_FK
INNER JOIN dbo.PM_STORE_TYPE pst ON
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join PM_TERMINAL pt2
    on psm.TERMINAL_ID_FK = pt2.TERMINAL_ID
inner join
    (
        select psmih.SALES_MEMO_ID_FK , sum(qty) as QTY
        from PT_SALES_MEMO_ITEM_H psmih
        where psmih.NET_LINE_AMT <> 0
        group by psmih.SALES_MEMO_ID_FK ) skucount
    on skucount.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
WHERE
    psmt.TYPE_CODE NOT IN (
        '06',
        '07',
        '09',
        '10',
        '11',
        '99',
        '08')
    AND psm.MEMO_STATUS NOT IN ('VOIDED')
    AND psm.MEMO_KIND NOT IN ('RESERVE',
        'handoff')
    AND pst.STORE_TYPE_NAME <> 'ONLINE'
    --	AND psm.LOCATION_ID_FK = 'HKDAHKDA0005'
    --	AND psm.TX_DATE = '2021-02-23'
GROUP BY
    psm.company_code ,
    PC2.COMPANY_DESC ,
    pl.location_code,
    PL.LOCATION_DESC,
    PL.CITY_TXT ,
    PST.STORE_TYPE_CODE,
    pt2.TERMINAL_NO,
    psm.TX_DATE ,
    pt.TENDER_CODE ,
    pt.TENDER_NAME
