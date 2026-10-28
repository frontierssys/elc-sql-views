CREATE   VIEW  PMV_USER_LAST_LOGIN
as
select
    pu.COMPANY_CODE ,
    pu.USER_CODE ,
    pu.USER_ID ,
    max(pul.ACTION_DT ) as LAST_LOGIN_TIME
FROM
    PM_USER_LOG pul
inner join PM_USER pu
    on pu.USER_ID = pul.USER_ID_FK
where pul.ACTION_TYPE = 'LOGIN'
group by
    pu.COMPANY_CODE ,
    pu.USER_CODE ,
    pu.USER_ID
