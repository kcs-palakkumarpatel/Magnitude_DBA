
create view PB_VW_RB_Fact_CovidCaptured as
select CapturedDate,Count(ReferenceNo) as TotalSent from(
select 
convert(date,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)) as CapturedDate,AM.id ReferenceNo,
(select top 1 detail from ContactDetails CD where CD.ContactMasterID=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId
 else Am.ContactMasterId end))as Name
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=534 and EG.Id =6101
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on SAC.SeenclientAnswerMasterid=AM.id
) A group by CapturedDate

