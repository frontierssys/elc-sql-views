CREATE   view [dbo].[PV_DATADUMP_SALES_DEMOGRAPHIC] as
select *
from
    (
        select psm.SALES_MEMO_ID as SALES_MEMO_ID ,
            'WALKIN' as WALKIN_OR_CONSUMER,
            pn.DEMOGRAPHIC
        from PT_SALES_MEMO psm
        inner join PM_NATION pn
            on psm.NATION_ID_FK = pn.NATION_ID
        where psm.VIP_NO is null
    ) as a
UNION ALL
    (
        select psm2.SALES_MEMO_ID as SALES_MEMO_ID,
            'CONSUMER' as WALKIN_OR_CONSUMER,
            pn2.DEMOGRAPHIC
        from PT_SALES_MEMO psm2
        inner join PM_VIP pv
            on pv.VIP_NO = psm2.VIP_NO
            and psm2.VIP_CLUSTER_ID_FK = pv.VIP_CLUSTER_ID_FK
        inner join PM_CUSTOMER pc
            on pc.CUSTOMER_ID = pv.CUSTOMER_ID_FK
        inner join PM_CUSTOMER_SECRET pcs
            on pcs.CUSTOMER_ID_FK = pc.CUSTOMER_ID
        left join PM_NATION pn2
            on pcs.COMPANY_CODE = pn2.COMPANY_CODE
            and pcs.COUNTRY_RESIDENCE = pn2.ISO3_CODE
        where psm2.VIP_NO is not null
    )
