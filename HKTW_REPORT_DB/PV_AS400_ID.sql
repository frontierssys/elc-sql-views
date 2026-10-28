CREATE   view [dbo].[PV_AS400_ID]
AS
select
    psmih.VIP_ID ,
    stuff((
        SELECT
            DISTINCT ',' + pva.VIP_ALT_KEY
        FROM
            PM_VIP_ALT pva
        WHERE
            pva.VIP_ALT_SYSTEM ='UNDTWNUNDAS400UND' and pva.VIP_ID = psmih.VIP_ID
        FOR XML PATH('')), 1, 1, '') as AS400_ID
from PM_VIP psmih
--where psmih .VIP_NO ='7L000000010' and psmih .COMPANY_CODE ='TWBB';
