create view PV_GLOWPASS_VIP as
select
    'au_en' as _store,
    'aus_website' as _website,
    'No' as customer_is_staff,
    pcs.EMAIL as email,
    pc.FIRSTNAME as firstname,
    pc.SURNAME as lastname,
    pv.VIP_NO as offline_member_id,
    '7' as group_id,
    pv.CRE_DATET
from PM_VIP pv
inner join PM_CUSTOMER pc
    on pc.CUSTOMER_ID = pv.CUSTOMER_ID_FK
inner join PM_CUSTOMER_SECRET pcs
    on pcs.CUSTOMER_ID_FK = pv.CUSTOMER_ID_FK
where pv.COMPANY_CODE = 'AUCS'
