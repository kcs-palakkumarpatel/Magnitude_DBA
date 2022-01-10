
CREATE view [dbo].[PB_VW_Sabrinalove_Fact_LograceCaptured] as

select * from (
select CapturedDate as ResponseDate,
cast(captureddate as date) as[Logged Date],Responsereference,
concat([Name],concat(' ',[Surname])) as [Full Name],
[Mobile],
[Age] as [Please select your],
[ID/Passport number],
[Gender],
[Race Type ],
[Trail Run],
[Mountain Bike],
[Hours],
[Minutes],
[Seconds],
cast(CONCAT([Hours],concat(':',concat([Minutes],concat(':',[Seconds])))) as text) as [Time taken to complete],
CONVERT(time(0), DATEADD(SECOND, ([Hours]*3600 + [Minutes]*60 + [Seconds]), 0)) as [Time taken in time],
--cast((CONCAT([Hours],concat(':',concat([Minutes],concat(':',[Seconds])))))as time )  as[Time taken in time],
latitude,longitude
 from
( select * from(
select
E.EstablishmentName,am.id as Responsereference,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenClientAnswerMasterId,
Q.shortname as Question,A.Detail as Answer,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as ResponseBy,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
Where (G.Id=689 and EG.Id =7813 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(59008,59009,59072,59559,59393,59492,59073,59074,59489,59015,59016,59017)

) S
Pivot (
Max(Answer)
For  Question In (
[Name],
[Surname],
[Mobile],
[Age],
[ID/Passport number],
[Gender],
[Race Type ],
[Trail Run],
[Mountain Bike],
[Hours],
[Minutes],
[Seconds]
))P
)X
)Y
where [Logged Date]<='2021-01-05' and [Logged Date]>='2020-12-25'
--order by 1 desc

