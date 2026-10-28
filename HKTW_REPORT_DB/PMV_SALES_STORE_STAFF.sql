-- dbo.PMV_SALES_STORE_STAFF source

CREATE   view PMV_SALES_STORE_STAFF as
select
    a.COMPANY_CODE ,
    a.location_code,
    a.STAFF_NO ,
    a.TX_DATE ,
    sum(a.SALES_NET_AMT) as SALES_NET_AMT
from
    (
        select *
        from PXV_SALES_STORE_STAFF_DEMOGRAPHIC_VIP
        union
        select *
        from PXV_SALES_STORE_STAFF_DEMOGRAPHIC_WALKIN) a
where a.IS_REVENUE_ITEM = 'Y'
group by
    a.COMPANY_CODE ,
    a.location_code,
    a.STAFF_NO ,
    a.TX_DATE;
