
create view PB_VW_Dim_DFC_SM_Template as


select 
CLA.SeenClientAnswerMasterId,
case when Conversation like '%Deal Closed%' then     'Deal Closed'
when Conversation like '%Issue has been Resolved%' then  'Issue has been Resolved'
when Conversation like '%We are getting closer to reaching our objects%' then  'We are getting closer to reaching our objects'
when Conversation like '%Resolved - Ref%' and  Conversation not like '%Unresolved -Ref%' then 'Resolved'
 
end as Template ,
dateadd(minute,AM.TimeOffSet,CLA.CreatedOn) as Date,
U.Name
from 
EstablishmentGroup EG 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join CloseLoopAction CLA on CLA.SeenClientAnswerMasterId=AM.Id
left outer join dbo.[Appuser] u on u.id=CLA.AppuserId

Where (EG.Id =3547
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) )



