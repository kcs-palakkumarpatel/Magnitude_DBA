CREATE VIEW dbo.[PB_VW_NW_LeadDelegation] AS 

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.IsResolved,
       AA.UserId,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.[Company name],
       --AA.Name,
       --AA.Surname,
	   CONCAT(aa.Name,' ',aa.Surname) AS [Contact person],
       AA.[Contact number],
       AA.[Source of lead],
       AA.[If other, please state],
       AA.[Type of lead],
       AA.[Potential price value of lead (ZAR)],
       AA.[About the lead],
       AA.Brand,
       AA.kVA,
       AA.[If other, please specify],
       AA.[Email address],
       AA.[Type of Product],
       AA.[Lead specific too],
       BB.ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[Have you contacted the lead?],
       BB.[Why haven't you contacted the lead?],
       LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(BB.[How did you contact the lead?],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [How did you contact the lead?],
       BB.[Have you set up the meeting?],
       BB.[When is the meeting?],
	   LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(BB.[Who did you speak to?],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Who did you speak to?],
       --BB.[Who did you speak to?],
       LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(BB.[Outcome of contact],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Outcome of contact],
	   BB.[Outcome of contact.],
       LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(BB.[What was the prospect interested in?],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [What was the prospect interested in?],
       BB.[Value of lead (ZAR)] 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,
[Company name],[Name],[Surname],[Contact number],[Source of lead],[If other, please state],[Type of lead],[Potential price value of lead (ZAR)],[About the lead],[Brand],[kVA],[If other, please specify],[Email address],[Type of Product],[Lead specific too]
from (
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved,A.Detail as Answer,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3024
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3023
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3021
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3022
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=4951 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (41900,37609,37611,37612,37613,40608,37616,37617,37618,40016,40017,40949,40407,37619,37620)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Company name],[Name],[Surname],[Contact number],[Source of lead],[If other, please state],[Type of lead],[Potential price value of lead (ZAR)],[About the lead],[Brand],[kVA],[If other, please specify],[Email address],[Type of Product],[Lead specific too]
))p
)AA

LEFT JOIN 

(select EstablishmentName,CapturedDate,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,IsResolved,UserId, UserName, Longitude,Latitude,
[Have you contacted the lead?],[Why haven't you contacted the lead?],[How did you contact the lead?],[Have you set up the meeting?],[When is the meeting?],[Who did you speak to?],[Outcome of contact],[Outcome of contact.],[What was the prospect interested in?],[Value of lead (ZAR)]
from (
select
E.EstablishmentName,dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 497 and eg.id=4951 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (25152,25160,25153,25154,25155,25156,26541,25157,25158,25159)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
--WHERE am.CreatedOn > '2019-11-01'
) s
pivot(
Max(Answer)
For  Question In (
[Have you contacted the lead?],[Why haven't you contacted the lead?],[How did you contact the lead?],[Have you set up the meeting?],[When is the meeting?],[Who did you speak to?],[Outcome of contact],[Outcome of contact.],[What was the prospect interested in?],[Value of lead (ZAR)]
))P
)BB ON aa.ReferenceNo=bb.SeenClientAnswerMasterId 

