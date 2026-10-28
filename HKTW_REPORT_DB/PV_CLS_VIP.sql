CREATE   view PV_CLS_VIP as
select
    pv.VIP_NO as VIPNO,
    pv.COMPANY_CODE as BRAND,
    case
        when pcs.BIRTH_M is not null and pcs.BIRTH_D is not null
        then
            CONCAT(isnull(pcs.BIRTH_Y , '1900'), RIGHT('0' + CONVERT(VARCHAR, pcs.BIRTH_M), 2 ), RIGHT('0' + CONVERT(VARCHAR, pcs.BIRTH_D ), 2 ) )
        else
            NULL
    end as DOB,
    LEFT(REPLACE( CONCAT(pc.SURNAME ,' ', pc.FIRSTNAME ), ',', ''),50) as VIPNAME,
    LEFT(REPLACE(pc.SURNAME, ',', ''),50) as L_NAME,
    LEFT(REPLACE(pc.FIRSTNAME, ',', ''), 50) as F_NAME,
    LEFT(pc.TITLE,10) as VIP_TITLE,
    null as IDNO,
    null as ADD_AREA,
    --LEFT(pa.STREET1, 50) as ADDR1,
    --LEFT(pa.STREET2, 50) as ADDR2,
    --LEFT(pa.STREET3, 50) as ADDR3,
    LEFT( REPLACE(pa.STREET1, ',', ''), 50) as ADDR1,
    LEFT( REPLACE(pa.STREET2, ',', ''), 50) as ADDR2,
    LEFT( REPLACE(pa.STREET3, ',', ''), 50) as ADDR3,
    pa.PRIMARY_ADDRESS ,
    pv.JOIN_DT as IDATE,
    pv.APPLY_LOCATION as I_SHOP,
    case
        when pv.STATUS = 'ACTIVE' then 'A'
        else 'I'
    end as VIP_STS,
    pcs.TEL1 as TEL1,
    pcs.TEL2 as TEL2,
    left(pc.GENDER,1) as SEX,
    --pn.CODE as NATION,
    isnull(cnm.CLS_CODE, '56') as NATION,
    LEFT(REPLACE(pcs.EMAIL,',',''), 50) as EMAIL,
    right(pv.COMPANY_CODE , 2 ) + pv.VIP_NO as CARDID,
    null as VIP_CARD_D,
    --pv.UPDATE_DATET as LAST_DATE,
    RIGHT('0' + CAST(datepart(month, pv.UPDATE_DATET ) as varchar), 2) +'/'+ RIGHT('0' + CAST(datepart(DAY, pv.UPDATE_DATET ) as varchar), 2) +'/' + CAST(datepart(YEAR, pv.UPDATE_DATET ) as varchar) + ' ' + RIGHT('0' + CAST(datepart(HOUR, pv.UPDATE_DATET ) as varchar),2) +':'+ RIGHT('0' + CAST(datepart(MINUTE, pv.UPDATE_DATET ) as varchar),2) as LAST_DATE,
    null as VIP_CARD_TYPE,
    null as VIP_CARD_PGM,
    null as PTS_ACQUIRED,
    LEFT(pv.STATUS,1) as VIP_CARD_STS,
    null as VIP_REQUIRE_CLEANING,
    pcs.AGE_GRP as VIP_AGE_GRP,
    null as KANJI_FNAME,
    null as KANJI_LNAME,
    null as NO_INDICATIOIN,
    null as OPTOUT_INDICATOR,
    null as PRINT_MAILING_LABEL,
    null as REACH_SUCCESS,
    REPLACE(pcvsr.SKIN_TYPE_OPTION1,',', '') as SKIN_TYPE,
    REPLACE(pcvsr.SKIN_CONCERN_OPTION1,',', '') as SKIN_CARE_CONCERN,
    REPLACE(pcvsr.SKIN_CONCERN_OPTION2,',', '') as SKIN_CARE_CONCERN_2,
    REPLACE(pcvsr.SKIN_CONCERN_OPTION3,',', '') as SKIN_CARE_CONCERN_3,
    REPLACE(pc.LANG,',', '') as LANGUAGE_PREFERENCE,
    CASE
        when Datepart(month, pv.APPLY_DATE) = Datepart(month, getdate())
            and Datepart(year, pv.JOIN_DT) = Datepart(year, getdate()) then 'NEW VIP'
        else 'VIP'
    end as VIP_TYPE,  ----------------------------------------------------------------<<<<<<<<
    null as STAFF_NAME,
    CASE
        WHEN PC.ALLOW_MAIL = 'Y' then 'N'
        ELSE 'Y'
    END as OPT_OUT_MAIL,
    CASE
        WHEN PC.ALLOW_EMAIL = 'Y' then 'N'
        ELSE 'Y'
    END as OPT_OUT_EMAIL,
    CASE
        WHEN pc.ALLOW_CALL = 'Y' then 'N'
        ELSE 'Y'
    END as OPT_OUT_PHONE,
    CASE
        WHEN pc.ALLOW_SMS = 'Y' then 'N'
        ELSE 'Y'
    END as OPT_OUT_SMS,
    null as DEAD_MAIL,
    pv.VIP_NO as MEMBERSHIP_NUMBER,
    null as VISIT_HK,
    null as INVALID_HOME_PHONE,
    null as INVALID_MOBILE,
    null as SOUTH_CHINESE,
    REPLACE(pcvsr.MAKEUP_AREA_OPTION1,',', '') as MAKEUP_CONCERN_1,
    REPLACE(pcvsr.MAKEUP_AREA_OPTION2,',', '') as MAKEUP_CONCERN_2,
    REPLACE(pcvsr.MAKEUP_AREA_OPTION3,',', '') as MAKEUP_CONCERN_3,
    pc.OPT_OUT_AFF_BRAND as OPT_OUT_AFFILIATE_BRAND,
    null as LLCUSTGRP,
    null as P12MCUSTPURCHASE,
    REPLACE(pcvsr.FRAGRANCE_OPTION1,',', '') as FRAG_INSPIRATION_1,
    REPLACE(pcvsr.FRAGRANCE_OPTION2,',', '') as FRAG_INSPIRATION_2,
    REPLACE(pcvsr.FRAGRANCE_OPTION3,',', '') as FRAG_INSPIRATION_3,
    null as CONSUMERSUBCLASSCODE,
    pc.CRE_DATET ,
    pc.UPDATE_DATET
from PM_VIP pv
inner join dbo.PM_CUSTOMER pc
    on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
inner join dbo.PM_CUSTOMER_SECRET pcs
    on pc.CUSTOMER_ID = pcs.CUSTOMER_ID_FK
left join dbo.PM_NATION pn
    on pcs.COMPANY_CODE = pn.COMPANY_CODE
    and pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
left join PM_ADDRESS pa
    on pc.CUSTOMER_ID = pa.CUSTOMER_ID_FK
    and (pa.PRIMARY_ADDRESS = 'Y' or pa.PRIMARY_ADDRESS is null)
left join PV_CLS_VIP_SURVEY_RESULT pcvsr
    on pv.VIP_ID = pcvsr.VIP_ID_FK
left join CLS_NATION_MAPPING cnm
    on pn.CODE = cnm.CODE
    --WHERE pv.VIP_ID = 'HKCM00100000018';
WHERE pv.COMPANY_CODE in (
    select COMPANY_CODE
    from CLS_BRAND_SCOPE)
    --and pv.cre_by <> 'it';
