


Create view VW_PB_DFC_DimTemplate
as

select 
CLA.SeenClientAnswerMasterId,
case when Conversation like '%Issues has been resolved%' then     'Issues has been resolved'
when Conversation like '%In Procurement%' then  'In Procurement'
when Conversation like '%In Planning%' then  'In Planning'
when Conversation like '%In Production%' then  'In Production'
when Conversation like '%In Stock%' then 'In Stock' 
when Conversation like '%Forecast Loaded%' then  'Forecast Loaded'
when Conversation like '%PO Recieved - CLOSED THE DEAL%' then  'PO Recieved - CLOSED THE DEAL'
when Conversation like '%LOST THE DEAL%' then  'LOST THE DEAL'
when Conversation like '%OPPORTUNITY STILL IN PIPELINE BUILD%' then  'OPPORTUNITY STILL IN PIPELINE BUILD'
when Conversation like '%OPPORTUNITY STILL IN FORECAST%' then 'OPPORTUNITY STILL IN FORECAST' 
end as Template,
CLA.CreatedOn as Date,
U.Name
from 
EstablishmentGroup EG 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join CloseLoopAction CLA on CLA.SeenClientAnswerMasterId=AM.Id
left outer join dbo.[Appuser] u on u.id=CLA.AppuserId

Where (EG.Id =3803 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null) And Am.istransferred=0 ) 
