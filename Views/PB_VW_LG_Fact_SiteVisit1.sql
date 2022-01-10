Create view PB_VW_LG_Fact_SiteVisit1
as
Select X.*,Y.ResponseDate,Y.ReferenceNo as ResponseRef,Y.SeenClientAnswerMasterId,
Y.Longitude as ResponseLongitude,Y.Latitude as ResponseLatitude,
Y.[Any plant diseases],
Y.[Picture of Plant],
Y.[Describe Disease],
Y.[Replacing Plant],
Y.[Plant Description],
Y.[Location],
Y.[Image of New plant],
Y.[Require Replace],
Y.[Replacement Type],
Y.[Type of plant],
Y.[Quantity],
Y.[Size],
Y.[Picture of Replaced plant],
Y.[Client signature],
Y.[Client name] from
(
select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
Isnull([Client],'') as[Company Name],
[Site Address],
[Unit Count],
[Contact Person],
[Person Mobile],
[Week Number],
replace([Scheduled Week],';',',') as[Scheduled Week],
replace([Scheduled Day],';',',') as[Scheduled Day],
[VisitedDay],
[Visited Week],
Longitude,
Latitude
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.Isresolved as Status,AM.Longitude,AM.Latitude

,Q.shortname as Question ,U.id as UserId, u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 --and EG.Id =5829
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=514 and EG.Id =6459
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.id in (56109,56107,56236,56103,56104,56108,56155,56101,56110,56154,64749)

)S
pivot(
Max(Answer)
For  Question In (
[Site Address],
[Unit Count],
[Contact Person],
[Person Mobile],
[Week Number],
[Scheduled Week],
[Scheduled Day],
[VisitedDay],
[Visited Week],
[Client]
))P

)X

left outer join
(

select  
 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
UserName,Longitude,Latitude,
[Any plant diseases],
'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+substring([Picture of plant],1,case when CHARINDEX(',',[Picture of plant])=0 then len([Picture of plant])+1 else charindex(',',[Picture of plant]) end -1)as[Picture of Plant],
[Describe Disease],
[Replacing Plant],
[Plant Description],
[Location],
'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+substring([Image of New plant],1,case when CHARINDEX(',',[Image of New plant])=0 then len([Image of New plant])+1 else charindex(',',[Image of New plant]) end -1)as[Image of New plant],
[Require Replace],
[Replacement Type],
[Type of plant],
[Quantity],
[Size],
'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+substring([Picture of Replaced plant],1,case when CHARINDEX(',',[Picture of Replaced plant])=0 then len([Picture of Replaced plant])+1 else charindex(',',[Picture of Replaced plant]) end -1)as[Picture of Replaced plant],
'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+substring([Client signature],1,case when CHARINDEX(',',[Client signature])=0 then len([Client signature])+1 else charindex(',',[Client signature]) end -1)as[Client signature],
[Client name]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.SeenClientAnswerMasterId,AM.Longitude,AM.Latitude

,Q.shortname as Question ,U.id as UserId, (SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3124
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3125
) AS UserName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId

Where (G.Id=514 and EG.Id =6459
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.id in (40621,40625,40626,40627,40629,40630,40631,40634,40635,40637,40638,40683,40640,40716,40714)

)S
pivot(
Max(Answer)
For  Question In (
[Any plant diseases],
[Picture of Plant],
[Describe Disease],
[Replacing Plant],
[Plant Description],
[Location],
[Image of New plant],
[Require Replace],
[Replacement Type],
[Type of plant],
[Quantity],
[Size],
[Picture of Replaced plant],
[Client signature],
[Client name]
))P

)Y on X.referenceNo=Y.SeenclientAnswerMasterid
