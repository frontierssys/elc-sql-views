create   view [dbo].[PV_R0051_MULTIPLE] as
select psi.TX_DATE ,psi.MATERIAL_CODE_10 ,psi.VIP_NO,psi.LOCATION_ID_FK , sum(psi.QUANTITY) as QUANTITY
from PV_SALES_ITEM psi
where SALEABLE ='Y'
group by psi.TX_DATE ,psi.MATERIAL_CODE_10 ,psi.VIP_NO,psi.LOCATION_ID_FK
having count(DISTINCT SALES_MEMO_ID)>1;
