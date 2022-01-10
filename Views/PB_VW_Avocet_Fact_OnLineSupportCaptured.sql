Create view [dbo].[PB_VW_Avocet_Fact_OnLineSupportCaptured] as


select X.*,Y.*
 from
 (
select 
case when EstablishmentName='Online Support - JHB North' then 'JHB North' 
when EstablishmentName='Online Support - BLM' then 'Bloemfontein' 
when EstablishmentName='Online Support - Cape Town' then 'Cape Town' 
when EstablishmentName='Online Support - EL' then 'East London'
when EstablishmentName='Online Support - George' then 'George'
when EstablishmentName='Online Support - JHB South' then 'JHB South'
when EstablishmentName='Online Support - KZN' then 'Durban / Kzn'
when EstablishmentName='Online Support - Nelspruit' then 'Nelspruit'
when EstablishmentName='Online Support - PE' then 'Port Elizabeth'
when EstablishmentName='Online Support - Polokwane' then 'Polokwane' else EstablishmentName end as EstablishmentName,
CapturedDate,ReferenceNo,
IsPositive,Status,RepeatCount,
UserName,
Technician,
[Email],
[Mobile],
[Company],
Latitude,
Longitude,
ResolvedDate


from(
select E.EstablishmentName,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,A.RepeatCount,
A.Detail as Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,AM.Latitude,AM.Longitude,ResolvedDate,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2868
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2869
) as Technician


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
	) as RD on rD.ReferenceNo = Am.Id


Where (G.Id=469 and EG.Id =7347 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(69945,69946,69947,69948,69949)



) S
Pivot (
Max(Answer)
For  Question In (
[Name],
[Surname],
[Email],
[Mobile],
[Company]

))P 

)X
left join( select ResponseDate, ResponseReferenceNo,P.[Response User],
SeenClientAnswerMasterId,
[Issue],
[Remote Support App],
[Which Application],
[Your Application I],
[Your Application P],
[Supporting Image |],Latitude as ResponseLatitude,Longitude as ResponseLongitude from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,((SELECT TOP 1 detail FROM
dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE SAM.ContactMasterId END )AND CD.ContactQuestionid=2868)+' '+(SELECT TOP 1 detail FROM
dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE SAM.ContactMasterId END )AND CD.ContactQuestionid=2869)) AS [Response User],
Q.shortname as Question,A.Detail as Answer,Am.Latitude,AM.Longitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN AM.SeenClientAnswerChildId ELSE NULL END)


Where (G.Id=469 and EG.Id =7347 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(53077,53078,53079,53080,53081,53082)

) S
Pivot (
Max(Answer)
For  Question In (
[Issue],
[Remote Support App],
[Which Application],
[Your Application I],
[Your Application P],
[Supporting Image |]
))P



)Y on X.ReferenceNo=Y.SeenClientAnswerMasterId and X.Technician=Y.[Response User]
--where Status='Resolved'
--order by 3 desc

