CREATE view PMV_MTD_SALES_STORE_STAFF as
select
    psssdv.COMPANY_CODE ,
    psssdv.location_code,
    psssdv.STAFF_NO ,
    psssdv.TX_DATE ,
    psssdv.SALES_NET_AMT ,
    sum(pa.SALES_NET_AMT ) as MTD_SALES
from PMV_SALES_STORE_STAFF psssdv
inner join PMV_SALES_STORE_STAFF pa on
    psssdv.COMPANY_CODE = pa.COMPANY_CODE
    and psssdv.location_code = pa.location_code
    and psssdv.STAFF_NO = pa.STAFF_NO
    and pa.TX_DATE <= psssdv.TX_DATE
    and pa.TX_DATE >= cast( cast(datepart(year, psssdv.TX_DATE ) as varchar) + '-' + cast(datepart(month, psssdv.TX_DATE ) as varchar) + '-01' as date)
where psssdv.SALES_NET_AMT <> 0
group by
    psssdv.COMPANY_CODE ,
    psssdv.location_code,
    psssdv.STAFF_NO ,
    psssdv.TX_DATE ,
    psssdv.SALES_NET_AMT
