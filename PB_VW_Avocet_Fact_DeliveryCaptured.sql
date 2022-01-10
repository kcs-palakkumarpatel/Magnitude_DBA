

CREATE view [dbo].[PB_VW_Avocet_Fact_DeliveryCaptured] as


WITH cte as(
select X.*,Y.*
 from
 (
select Technician,
case when EstablishmentName='Delivieries - BLM' then 'Delivieries - Bloemfontein'
when EstablishmentName='Delivieries - KZN' then 'Delivieries - Durban / Kzn'
when EstablishmentName='Delivieries - PE' then 'Delivieries - Port Elizabeth' else EstablishmentName end as [EstablishmentName],
CapturedDate,ReferenceNo,
IsPositive,Status,RepeatCount,
UserName,
[Customer],
[Order Type],
[Invoice | Job Card],
[Invoice | Job Card | Delivery Note Number],
[Delivery Date],
[Any additional req],
[Order Type Detail],
[Order Type - waiti],
[Labels],
[Stock Code],
[Quantity],
[Description],
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
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
	) as RD on rD.ReferenceNo = Am.Id


Where (G.Id=469 and EG.Id =4087 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(50615,50614,50616,50617,32158,32160,50618,32135,32136,50619,50620,32138)



) S
Pivot (
Max(Answer)
For  Question In (
[Customer],
[Order Type],
[Invoice | Job Card],
[Invoice | Job Card | Delivery Note Number],
[Delivery Date],
[Any additional req],
[Order Type Detail],
[Order Type - waiti],
[Labels],
[Stock Code],
[Quantity],
[Description]

))P 

)X
left outer join( select ResponseDate, ResponseReferenceNo,P.[Response User],
SeenClientAnswerMasterId,[GRV / Store Stamp ],
[Delivery Done],
[Any comments regar],
[Pricing Good],
[Issues],
[If yes, please exp],
[Please sign off],Latitude as ResponseLatitude,Longitude as ResponseLongitude from(
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


Where (G.Id=469 and EG.Id =4087 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(36783,19695,19696,19697,19698,19700,19699)

) S
Pivot (
Max(Answer)
For  Question In (
[GRV / Store Stamp ],
[Delivery Done],
[Any comments regar],
[Pricing Good],
[Issues],
[If yes, please exp],
[Please sign off]

))P



)Y on X.ReferenceNo=Y.SeenClientAnswerMasterId and X.Technician=Y.[Response User]
)

Select 

B.EstablishmentName,
B.Technician,
B.CapturedDate,B.ReferenceNo,
B.IsPositive,B.Status,
B.UserName,
B.[Customer],
B.[Order Type],
B.[Invoice | Job Card],
B.[Invoice | Job Card | Delivery Note Number],
B.[Delivery Date],
B.[Any additional req],
A.RepeatCount,
A.[Order Type Detail],
A.[Order Type - waiti],
A.[Labels],
A.[Stock Code],
A.[Quantity],
A.[Description],
B.Latitude,
B.Longitude,
B.ResolvedDate,
B.ResponseDate, B.ResponseReferenceNo,B.[Response User],
B.[GRV / Store Stamp ],
B.[Delivery Done],
B.[Any comments regar],
B.[Pricing Good],
B.[Issues],
B.[If yes, please exp],
'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+B.[Please sign off]as [Please sign off],
B.ResponseLatitude,
B.ResponseLongitude
 from

(Select * from cte where repeatcount=0)B left outer join (Select * from cte where repeatcount<>0)A on A.ReferenceNo=B.ReferenceNo

--order by 3 desc




