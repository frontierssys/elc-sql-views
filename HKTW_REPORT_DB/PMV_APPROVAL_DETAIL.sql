create     view [dbo].[PMV_APPROVAL_DETAIL] as
select
    a.DOC_APPROVAL_FLOW_H_ID_FK,
    MAX(
        CASE
            when a.STEP_NO = 1 then a.APPROVED_BY_ID
        end) as APPROVER_EMPLOYEE_ID_1,
    MAX(
        CASE
            when a.STEP_NO = 1 then a.APPROVED_BY_NAME
        end) as APPROVER_EMPLOYEE_NAME_1,
    MAX(
        CASE
            when a.STEP_NO = 1 then a.APPROVE_DT
        end) as APPOVE_DATE_1,
    MAX(
        CASE
            when a.STEP_NO = 2 then a.APPROVED_BY_ID
        end) as APPROVER_EMPLOYEE_ID_2,
    MAX(
        CASE
            when a.STEP_NO = 2 then a.APPROVED_BY_NAME
        end) as APPROVER_EMPLOYEE_NAME_2,
    MAX(
        CASE
            when a.STEP_NO = 2 then a.APPROVE_DT
        end) as APPOVE_DATE_2,
    MAX(
        CASE
            when a.STEP_NO = 3 then a.APPROVED_BY_ID
        end) as APPROVER_EMPLOYEE_ID_3,
    MAX(
        CASE
            when a.STEP_NO = 3 then a.APPROVED_BY_NAME
        end) as APPROVER_EMPLOYEE_NAME_3,
    MAX(
        CASE
            when a.STEP_NO = 3 then a.APPROVE_DT
        end) as APPOVE_DATE_3,
    MAX(
        CASE
            when a.STEP_NO = 4 then a.APPROVED_BY_ID
        end) as APPROVER_EMPLOYEE_ID_4,
    MAX(
        CASE
            when a.STEP_NO = 4 then a.APPROVED_BY_NAME
        end) as APPROVER_EMPLOYEE_NAME_4,
    MAX(
        CASE
            when a.STEP_NO = 4 then a.APPROVE_DT
        end) as APPOVE_DATE_4,
    MAX(
        CASE
            when a.STEP_NO = 5 then a.APPROVED_BY_ID
        end) as APPROVER_EMPLOYEE_ID_5,
    MAX(
        CASE
            when a.STEP_NO = 5 then a.APPROVED_BY_NAME
        end) as APPROVER_EMPLOYEE_NAME_5,
    MAX(
        CASE
            when a.STEP_NO = 5 then a.APPROVE_DT
        end) as APPOVE_DATE_5,
    MAX(
        CASE
            when a.STEP_NO = 6 then a.APPROVED_BY_ID
        end) as APPROVER_EMPLOYEE_ID_6,
    MAX(
        CASE
            when a.STEP_NO = 6 then a.APPROVED_BY_NAME
        end) as APPROVER_EMPLOYEE_NAME_6,
    MAX(
        CASE
            when a.STEP_NO = 6 then a.APPROVE_DT
        end) as APPOVE_DATE_6
from
    (
        select
            idafd.DOC_APPROVAL_FLOW_H_ID_FK as DOC_APPROVAL_FLOW_H_ID_FK,
            idafd.APPROVED_BY as APPROVED_BY_ID,
            ps.FIRST_NAME as APPROVED_BY_NAME,
            idafd.APPROVE_DT as APPROVE_DT ,
            idafd.APPROVAL_STATUS as APPROVAL_STATUS ,
            idafd.STEP_NO as STEP_NO
        from IT_DOC_APPROVAL_FLOW_D idafd
        inner join PM_USER pu
            on idafd.COMPANY_CODE = pu.COMPANY_CODE
            and idafd.APPROVED_BY = pu.USER_CODE
        inner join PM_STAFF ps
            on pu.STAFF_ID_FK = ps.STAFF_ID
    ) a
group by a.DOC_APPROVAL_FLOW_H_ID_FK
