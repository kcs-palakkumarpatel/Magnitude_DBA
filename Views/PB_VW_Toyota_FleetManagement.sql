CREATE VIEW PB_VW_Toyota_FleetManagement AS

SELECT CapturedDate,ReferenceNo,IsResolved,UserName,p.Customer,p.Company,p.Latitude,p.Longitude,
[Is this a new or existing client?],[What type of customer is this ?],[Customer Engagement activity],[Fleet cost analysis],
--[Comment],
[Fleet hours utilisation],[Comments],
--[Attachment],
[Fleet contract status],
--[Attachment1],
[Date of visit],[Area],[Site location],[Service Due],[Load tests due forecast],
IIF(p.[Fleet Current Status] LIKE ',%',STUFF([Fleet Current Status],1,1,''),p.[Fleet Current Status]) AS [Fleet Current Status],
[Comments1],[Industry],[Follow up date],[Attachments],
--[Comments2],
[Fleet monitoring],[Comments3],[General comments]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved ,A.Detail as Answer,u.name as UserName,AM.Latitude,AM.Longitude,
CASE WHEN q.Id=75674 THEN 'Comments1'
	 WHEN q.Id=43261 THEN 'Comments2'
	 WHEN q.Id=75677 THEN 'Comments3'
	 WHEN q.Id=75673 THEN 'Attachment1' ELSE Q.QuestionTitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3071
) +' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3072
)  as Customer ,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
)  as Company
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5385 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (44390,43249,74942,75678,74946,75671,74948,75672,74943,75673,43245,43247,43248,74949,74950,75675,75674,43251,43259,43260,43261,75676,75677,78897)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE u.Id<>5201
)s
pivot(
Max(Answer)
For  Question In (
[Is this a new or existing client?],[What type of customer is this ?],[Customer Engagement activity],[Fleet cost analysis],[Comment],[Fleet hours utilisation],[Comments],[Attachment],[Fleet contract status],[Attachment1],[Date of visit],[Area],[Site location],[Service Due],[Load tests due forecast],[Fleet Current Status],[Comments1],[Industry],[Follow up date],[Attachments],[Comments2],[Fleet monitoring],[Comments3],[General comments]
))p

