CREATE   VIEW  PV_CLS_VIP_SURVEY_RESULT as
select
    sq.VIP_ID_FK,
    --sq.VIP_SURVEY_GROUP,
    REPLACE(MAX(
        CASE
            WHEN RN = 1 and VIP_SURVEY_GROUP = 'SKIN_TYPE' THEN sq.BUSINESS_DESC
        END), ',', '') AS SKIN_TYPE_OPTION1,
    REPLACE(MAX(
        CASE
            WHEN RN = 1 and VIP_SURVEY_GROUP = 'FRAGRANCE' THEN sq.BUSINESS_DESC
        END), ',', '') AS FRAGRANCE_OPTION1,
    REPLACE(MAX(
        CASE
            WHEN RN = 2 and VIP_SURVEY_GROUP = 'FRAGRANCE' THEN sq.BUSINESS_DESC
        END), ',', '') AS FRAGRANCE_OPTION2,
    REPLACE(MAX(
        CASE
            WHEN RN = 3 and VIP_SURVEY_GROUP = 'FRAGRANCE' THEN sq.BUSINESS_DESC
        END), ',', '') AS FRAGRANCE_OPTION3,
    REPLACE(MAX(
        CASE
            WHEN RN = 1 and VIP_SURVEY_GROUP = 'MAKEUP_AREA' THEN sq.BUSINESS_DESC
        END), ',', '') AS MAKEUP_AREA_OPTION1,
    REPLACE(MAX(
        CASE
            WHEN RN = 2 and VIP_SURVEY_GROUP = 'MAKEUP_AREA' THEN sq.BUSINESS_DESC
        END), ',', '') AS MAKEUP_AREA_OPTION2,
    REPLACE(MAX(
        CASE
            WHEN RN = 3 and VIP_SURVEY_GROUP = 'MAKEUP_AREA' THEN sq.BUSINESS_DESC
        END), ',', '') AS MAKEUP_AREA_OPTION3,
    REPLACE(MAX(
        CASE
            WHEN RN = 1 and VIP_SURVEY_GROUP = 'SKIN_CONCERN' THEN sq.BUSINESS_DESC
        END), ',', '') AS SKIN_CONCERN_OPTION1,
    REPLACE(MAX(
        CASE
            WHEN RN = 2 and VIP_SURVEY_GROUP = 'SKIN_CONCERN' THEN sq.BUSINESS_DESC
        END), ',', '') AS SKIN_CONCERN_OPTION2,
    REPLACE(MAX(
        CASE
            WHEN RN = 3 and VIP_SURVEY_GROUP = 'SKIN_CONCERN' THEN sq.BUSINESS_DESC
        END), ',', '') AS SKIN_CONCERN_OPTION3
From
    (
        select
            VIP_ID_FK,
            VIP_SURVEY_GROUP,
            ROW_NUMBER () OVER (
                PARTITION by VIP_ID_FK, VIP_SURVEY_GROUP
                order by BUSINESS_DESC)AS RN,
            BUSINESS_DESC
        from PM_VIP_SURVEY_RESULT_H pvsrh
        inner join PM_VIP_SURVEY_RESULT_D pvsrd
            on pvsrd.VIP_SURVEY_RESULT_H_ID_FK = pvsrh.VIP_SURVEY_RESULT_H_ID
            --	where pvsrh.VIP_SURVEY_GROUP
    ) sq
group by sq.VIP_ID_FK
