


CREATE view [dbo].[PB_VW_LG_Fact_SiteVisitFeedback] as

with cte as(

select  ROW_NUMBER() over (PARTITION BY SeenClientAnswerMasterId,Username ORDER BY responsedate ASC) AS rn,
 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
UserName,Longitude,Latitude,
[Select what you are doing] as [Proceed with],
Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Select Day],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) as [Select day],
Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Week],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) as[Week],

[Do you require a plant replacement?] as[Plant replacement],
[Select TYPE of replacement] as[Replacement type],
[Type of plant],
[Quantity (how many)] as [Quantity],
[Size],
[Area of replacement] as[Replacement area],
[Reason for replacement] as[Replacement reason],
[Select what needs replacing] as[What to replace],
[Material Replacement area],
[Material Replacement reason],
[Client name],
[Picture of plant] ,
 [Client Signature],
 [Any plant diseases to report?],
[Picture of the plant],
[Please describe what the disease looks like],
[Are you Replacing a plant today?],
[Plant Description],
[Location],
[Image of New plant]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.SeenClientAnswerMasterId,Am.Longitude,AM.Latitude

,Q.QuestionTitle as Question ,U.id as UserId, (SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3124
)+' '+Isnull((SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3125
),'') AS UserName 
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 and EG.Id =5829
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId

Where (G.Id=514 and EG.Id =5829
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.id in (32838,32837,32474,32475,32476,32478,32479,32480,32481,32483,32513,32514,32516,32539,32482,32619,34077,34078,34079,38394,38396,38397,38398)

)S
pivot(
Max(Answer)
For  Question In (
[Select what you are doing],
[Select day],
[Week],
[Do you require a plant replacement?],
[Select TYPE of replacement],
[Type of plant],
[Quantity (how many)],
[Size],
[Area of replacement],
[Reason for replacement],
[Select what needs replacing],
[Material Replacement area],
[Material Replacement reason],
[Client name],
[Picture of plant],
[Client Signature],
[Any plant diseases to report?],
[Picture of the plant],
[Please describe what the disease looks like],
[Are you Replacing a plant today?],
[Plant Description],
[Location],
[Image of New plant]

))P
)


select B.EstablishmentName,B.ResponseDate,B.ReferenceNo,B.SeenClientAnswerMasterId,
B.UserName,
B.Longitude,B.Latitude,
B.[Proceed with],
B.[Select day],
case when B.[Select day]='Monday' then 1 when B.[Select day]='Tuesday' then 2 when B.[Select day]='Wednesday' then 1
when B.[Select day]='Thursday' then 1 when B.[Select day]='Friday' then 1 else 0 end as DaySort,

B.[Week],
B.[Plant replacement],
B.[Replacement type],
B.[Type of plant],
B.[Quantity],
B.[Size],
B.[Replacement area],
B.[Replacement reason],
B.[What to replace],
B.[Material Replacement area],
B.[Material Replacement reason],B.[Client name],B.[Picture of plant],
B.[Client Signature],
B.[Any plant diseases to report?],
B.[Picture of the plant],
B.[Please describe what the disease looks like],
B.[Are you Replacing a plant today?],
B.[Plant Description],
B.[Location],
B.[Image of New plant],B.CompleteSiteVisit,A.TotalTime from 
(select  c3.EstablishmentName,c3.ResponseDate,c3.ReferenceNo,c3.SeenClientAnswerMasterId,
c3.UserName,
c3.Longitude,c3.Latitude,
c3.[Proceed with],
c3.[Select day],c3.[Week],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Plant replacement] else c3.[Plant replacement] end as[Plant replacement] ,
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Replacement type] else c3.[Replacement type]end as [Replacement type],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Type of plant] else c3.[Type of plant]end as [Type of plant],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Quantity] else c3.[Quantity]end as [Quantity],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Size] else c3.[Size]end as [Size],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Replacement area] else c3.[Replacement area]end as [Replacement area],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Replacement reason] else c3.[Replacement reason]end as [Replacement reason],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[What to replace] else c3.[What to replace]end as [What to replace],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Material Replacement area]else c3.[Material Replacement area]end as [Material Replacement area],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Material Replacement reason]else c3.[Material Replacement reason]end as [Material Replacement reason],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Client name]else c3.[Client name]end as [Client name],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Picture of plant]else c3.[Picture of plant]end as [Picture of plant],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Client Signature]else c3.[Client Signature]end as [Client Signature],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Any plant diseases to report?] else c3.[Any plant diseases to report?] end as [Any plant diseases to report?],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Picture of the plant] else c3.[Picture of the plant] end as [Picture of the plant],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Please describe what the disease looks like]else c3.[Please describe what the disease looks like]end as [Please describe what the disease looks like],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Are you Replacing a plant today?]else c3.[Are you Replacing a plant today?] end as [Are you Replacing a plant today?],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Plant Description]else c3.[Plant Description] end as [Plant Description],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Location]else c3.Location end as [Location],
case when c3.[Proceed with] = 'Start Site Visit' then c4.[Image of New plant] else c3.[Image of New plant] end as [Image of New plant],

c4.ResponseDate as CompleteSiteVisit 
from cte c3
left JOIN cte c4
  ON c3.SeenClientAnswerMasterId = c4.SeenClientAnswerMasterId 
  AND c3.rn = c4.rn - 1
  and  convert(Date,c3.ResponseDate)=convert(Date,c3.ResponseDate)
  and c3.UserName=c4.UserName
  and (c3.[Proceed with] = 'Start Site Visit' and c4.[Proceed with] ='Complete Site Visit')
  )B left outer join
(SELECT 
    c1.SeenClientAnswerMasterId,convert(date,c1.ResponseDate) as ResponseDate1 ,c1.UserName
   , SUM(DATEDIFF(MINUTE, c1.ResponseDate, c2.ResponseDate)) AS [TotalTime]
FROM cte c1
JOIN cte c2
  ON c1.SeenClientAnswerMasterId = c2.SeenClientAnswerMasterId 
  AND c1.rn = c2.rn - 1
  and convert(Date,c1.ResponseDate)=convert(Date,c2.ResponseDate)
  and c1.UserName=c2.UserName
WHERE c1.[Proceed with] = 'Start Site Visit' and c2.[Proceed with] ='Complete Site Visit'
GROUP BY c1.SeenClientAnswerMasterId, C1.Username,convert(date,c1.ResponseDate))A

 on A.SeenClientAnswerMasterId=B.SeenClientAnswerMasterId and A.ResponseDate1=convert(Date,B.ResponseDate) and A.Username=B.UserName  
