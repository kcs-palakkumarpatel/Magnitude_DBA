

CREATE view [dbo].[PB_VW_TseboCleaning_Fact_CovidIsolationTracker]  AS

 
 Select A.*,B.* from(
Select DISTINCT * from(
select E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.IsResolved as Status,
AM.id as ReferenceNo,A.Detail as Answer,Q.shortname as Question 
,U.Name as UserName,SH.StatusDateTime, es.StatusName,AUE.Name as HR,RD.ResolvedDate
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
left outer join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id and E.IsDeleted=0 and Am.isdeleted=0
left outer join SeenclientAnswers A on A.SeenClientAnswerMasterId=AM.Id
left outer join SeenClientQuestions Q on A.Questionid=Q.Id and Q.id in(52829,52830,52831,67939,67940,67941,67942,67943)
left outer join AppUser U on U.id=AM.CreatedBy
left outer join(Select AE.EstablishmentId,au.Name from AppUserEstablishment AE inner join Appuser au on Au.id=AE.AppUserId and au.id<>6333 and Au.id<>6604 and AE.IsDeleted=0)AUE on AUE.EstablishmentId=E.Id
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join 
 (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id
where G.id=503 and EG.id=6231 and Am.IsDeleted=0 
)S
pivot(
Max(Answer)
For  Question In (
[Employee Name],
[Employee ID],
[Employee Mobile],
[Employee address],
[Next of Kin NAME],
[Next of Kin Mobile],
[Alternative Mobile],
[Relationship]
))P
)A
left outer Join

(
Select dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,
AM.id as ResponseRef,AM.SeenClientAnswerMasterId
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
left outer join AnswerMaster AM on AM.EstablishmentId=E.id and E.IsDeleted=0 and Am.isdeleted=0
where G.id=503 and EG.id=6231 and Am.IsDeleted=0 
)B on A.ReferenceNo=B.SeenClientAnswerMasterId

