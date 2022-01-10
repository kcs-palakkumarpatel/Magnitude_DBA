CREATE VIEW dbo.PB_VW_Matola_Vessel AS

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.CustomerCompany,
	   AA.Contractname,
       AA.[Vessel name],
       AA.[Booking reference],
       AA.Tonnage,
       AA.[Date expected to dock],
       AA.[Time expected to dock],
       BB.ResponseDate,
       BB.ReferenceNo AS Responseno,
       BB.[Type of inspection],
       BB.[Tonnage loaded],
       BB.Customer,
       BB.[Vessel name] AS [Vessel name_1],
       BB.[Hold number],
       BB.[Temperature °C],
       BB.[Weather conditions],
       BB.[Please state other],
       BB.[Is the vessel hold clean?],
       BB.Comment,
       IIF(BB.Attachments='' OR BB.Attachments IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Attachments)) AS Attachments,
       BB.[Have you taken pictures of the slab today?],
       BB.Comments,
       IIF(BB.Attachments1='' OR BB.Attachments1 IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Attachments1)) AS Attachments1,
       BB.[Is the cargo tonnage received in line with the customer loading target?],
       BB.Comment1,
       IIF(BB.Attachments2='' OR BB.Attachments2 IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Attachments2)) AS Attachments2,
       IIF(BB.Signature='' OR BB.Signature IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Signature)) AS Signature,
       BB.Time,
       BB.[Volume (Tonnage)],
       BB.[Bill of landing number],
       IIF(BB.[Attach bill of landing]='' OR BB.[Attach bill of landing] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.[Attach bill of landing])) AS [Attach bill of landing],
       IIF(BB.Attachments3='' OR BB.Attachments3 IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Attachments3)) AS Attachments3,
       IIF(BB.Signature1='' OR BB.Signature1 IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Signature1)) AS Signature1,
	   CASE WHEN BB.[Type of inspection]='Arrival inspection' THEN 1
		    WHEN BB.[Type of inspection]='First shift inspection' THEN 2
			WHEN BB.[Type of inspection]='Second shift inspection' THEN 3
			WHEN BB.[Type of inspection]='Third shift inspection' THEN 4
			WHEN BB.[Type of inspection]='Vessel completion inspection' THEN 5
			ELSE 0 END AS sortorder
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,CustomerCompany,Contractname,
[Vessel name],[Booking reference],[Tonnage],[Date expected to dock],[Time expected to dock]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,cg.ContactGropName AS Contractname,
A.Detail as Answer
,Q.Questiontitle as Question,u.name as UserName,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3141
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3140
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3142
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3138
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3139
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 515 and eg.id=5555
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (45542,45543,45544,45545,45546)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
LEFT JOIN dbo.ContactGroup cg ON cg.Id=AM.ContactGroupId
)s
pivot(
Max(Answer)
For  Question In (
[Vessel name],[Booking reference],[Tonnage],[Date expected to dock],[Time expected to dock]
))p
)AA

LEFT JOIN 

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Type of inspection],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Type of inspection],
[Tonnage loaded],[Customer],[Vessel name],[Hold number],[Temperature °C],
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Weather conditions],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Weather conditions],
[Please state other],[Is the vessel hold clean?],[Comment],
IIF([Attachments] LIKE '%,%',LEFT([Attachments],CHARINDEX(',',[Attachments])-1),[Attachments]) AS [Attachments],
[Have you taken pictures of the slab today?],[Comments],
IIF([Attachments1] LIKE '%,%',LEFT([Attachments1],CHARINDEX(',',[Attachments1])-1),[Attachments1]) AS [Attachments1],
[Is the cargo tonnage received in line with the customer loading target?],[Comment1],
IIF([Attachments2] LIKE '%,%',LEFT([Attachments2],CHARINDEX(',',[Attachments2])-1),[Attachments2]) AS [Attachments2],
IIF(P.Signature LIKE '%,%',LEFT(Signature,CHARINDEX(',',Signature)-1),Signature) AS Signature,
[Time],[Volume (Tonnage)],[Bill of landing number],
IIF(P.[Attach bill of landing] LIKE '%,%',LEFT([Attach bill of landing],CHARINDEX(',',[Attach bill of landing])-1),[Attach bill of landing]) AS [Attach bill of landing],
IIF([Attachments3] LIKE '%,%',LEFT([Attachments3],CHARINDEX(',',[Attachments3])-1),[Attachments3]) AS [Attachments3],
IIF(P.Signature1 LIKE '%,%',LEFT(Signature1,CHARINDEX(',',Signature1)-1),Signature1) AS Signature1
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,
CASE WHEN q.Id=30577 THEN 'Attachments1'
	 WHEN q.Id=30579 THEN 'Comment1'
	 WHEN q.Id=30580 THEN 'Attachments2'
	 WHEN q.Id=30593 THEN 'Attachments3'
	 WHEN q.Id=30594 THEN 'Signature1' ELSE q.QuestionTitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 515 and eg.id=5555 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (30562,30585,30564,30565,30566,30569,30570,30571,30572,30573,30574,30575,30576,30577,30578,30579,30580,30582,30589,30590,30591,30592,30593,30594)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Type of inspection],[Tonnage loaded],[Customer],[Vessel name],[Hold number],[Temperature °C],[Weather conditions],[Please state other],[Is the vessel hold clean?],[Comment],[Attachments],[Have you taken pictures of the slab today?],[Comments],[Attachments1],[Is the cargo tonnage received in line with the customer loading target?],[Comment1],[Attachments2],[Signature],[Time],[Volume (Tonnage)],[Bill of landing number],[Attach bill of landing],[Attachments3],[Signature1]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

