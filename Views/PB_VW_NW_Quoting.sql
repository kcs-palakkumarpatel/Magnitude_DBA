CREATE VIEW dbo.PB_VW_NW_Quoting AS

SELECT EstablishmentName,
       CapturedDate,
       ReferenceNo,
       IsPositive,
       IsResolved,
       UserId,
       UserName,
       Longitude,
       Latitude,
       CustomerName,
       CustomerMobile,
       CustomerEmail,
       RepeatCount,
       IIF(Area='' OR Area IS NULL,'N/A',Area) AS Area,
	   IIF([O2 Province]='' OR [O2 Province] IS NULL,'N/A',[O2 Province]) AS [O2 Province],
	   [Contact person],
       [Contact number],
       [Email address],
       [Are you logging an opportunity?],
	   IIF([Is this a hot prospect?]='' OR [Is this a hot prospect?] IS NULL,'N/A',[Is this a hot prospect?]) AS [Is this a hot prospect?],
	   [What is the opportunity spotted?],
	   IIF([Are you speaking to ..]='' OR [Are you speaking to ..] IS NULL,'N/A',[Are you speaking to ..]) AS [Are you speaking to ..],
       IIF([Company name]='' OR [Company name] IS NULL,'N/A',[Company name]) AS [Company name],
	   IIF([Is this a Quote or Tender]='' OR [Is this a Quote or Tender] IS NULL,'N/A',[Is this a Quote or Tender]) AS [Is this a Quote or Tender],
	   IIF([What is the customer interested in?]='' OR [What is the customer interested in?] IS NULL,'N/A',[What is the customer interested in?]) AS [What is the customer interested in?],
	   [Price value of opportunity (ZAR)],
	   IIF(Accessories='' OR Accessories IS NULL,'N/A',Accessories) AS Accessories,
       [If other, what?],
       IIF([kVA/Equipement]='' OR [kVA/Equipement] IS NULL,'N/A',[kVA/Equipement]) AS [kVA/Equipement],
       Quantity,
       [Full price value of opportunity (ZAR) Amount Excl. VAT],
       IIF([Is this long term or short term?]='' OR [Is this long term or short term?] IS NULL,'N/A',[Is this long term or short term?]) AS [Is this long term or short term?],
       ResponseDate,
       Refno,
       [%PI],
       Status,
       Comments,
	   [Brand chosen],
	   [Full Value of quote (ZAR)],
	   IIF([Reason for lost deal]='' OR [Reason for lost deal] IS NULL,'N/A',[Reason for lost deal]) AS [Reason for lost deal],
       IIF([Follow up]='' OR [Follow up] IS NULL,'N/A',[Follow up]) AS [Follow up],
       [Who did we loose the deal to?],
	   [Who was the competitor?],
	   [Reason for cancellation],
       [Price (ZAR)],
       [Deviation in original price (ZAR)],
       [Reason for deviation],
       [Has this become a hot quote?],
       [General comments], 
	   sortorder 
	   FROM 
/*Genmatic Quotes*/
(SELECT 
	   d.EstablishmentName,
       d.CapturedDate,
       d.ReferenceNo,
       d.IsPositive,
       d.IsResolved,
       d.UserId,
       d.UserName,
       d.Longitude,
       d.Latitude,
       d.CustomerName,
       d.CustomerMobile,
       d.CustomerEmail,
       d.RepeatCount,
       d.Area,
	   NULL AS [O2 Province],
	   CONCAT(d.name,' ',d.surname) AS [Contact person],
       d.Mobile AS [Contact number],
       d.Email AS [Email address],
       d.[Are you logging an opportunity?],
	   d.[Is this a hot prospect?],
	   d.[What is the opportunity?] AS [What is the opportunity spotted?],
	   d.[Who are you engaging with?] AS [Are you speaking to ..],
       d.[Company name],
	   NULL AS [Is this a Quote or Tender],
	   NULL AS [What is the customer interested in?],
	   NULL AS [Price value of opportunity (ZAR)],
	   d.Accessories,
       d.[If other, what?],
       d.[kVA/Equipement],
       d.Quantity,
       REPLACE(d.[Full price value of opportunity (ZAR) Amount Excl. VAT],',','.') AS [Full price value of opportunity (ZAR) Amount Excl. VAT],
       d.[Is this long term or short term?],  
       d.ResponseDate,
       d.Refno,
       d.[%PI],
       LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(d.Status,'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS Status,
       d.Comments,
	   NULL AS [Brand chosen],
	   REPLACE(d.[Full value of quote (ZAR) Amount Excl. VAT],',','.') AS [Full Value of quote (ZAR)],
	   LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(d.[Reason for lost deal],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Reason for lost deal],
       d.[Follow up],     
       d.[Who did we loose the deal to?],
	   d.[Who is other?] AS [Who was the competitor?],
	   NULL AS [Reason for cancellation],
       REPLACE(d.[Price (ZAR)],',','.') AS [Price (ZAR)],
       REPLACE(d.[Deviation in original price (ZAR) Amount Excl. VAT],',','.') AS [Deviation in original price (ZAR)],
       d.[Reason for deviation],
       d.[Has this become a hot prospect?] AS [Has this become a hot quote?],
       d.[General comments], 
	   CASE when [Status]='Captured' then 1
			  when [Status]='Only for quoting purposes' then 2
			  when [Status]='Acceptance of positive feedback' then 3
			  when [Status]='Follow up' then 4
			  when [Status]='Re-quoted' then 5
			  when [Status]='Purchase order received' then 6
			  when [Status]='Lost deal' then 7
			  else 8
			  end as sortorder
FROM
(SELECT 
	   z.EstablishmentName,
       z.CapturedDate,
       z.ReferenceNo,
       z.IsPositive,
       z.IsResolved,
       z.UserId,
       z.UserName,
       z.Longitude,
       z.Latitude,
       z.CustomerName,
       z.CustomerMobile,
       z.CustomerEmail,
       z.RepeatCount,
       z.Area,
       z.[Are you logging an opportunity?],
       z.[Company name],
       z.[Is this a hot prospect?],
       z.[Is this long term or short term?],
       z.[What is the opportunity?],
       z.[Who are you engaging with?],
       z.Name,
       z.Surname,
       z.Mobile,
       z.Email,
       z.Accessories,
       z.[If other, what?],
       z.[kVA/Equipement],
       z.Quantity,
       z.[Full price value of opportunity (ZAR) Amount Excl. VAT],
       z.ResponseDate,
       z.Refno,
       z.[%PI],
       z.Status,
       z.Comments,
       z.[Follow up],
       z.[Full value of quote (ZAR) Amount Excl. VAT],
       LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(z.[Reason for lost deal],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Reason for lost deal],
       z.[Price (ZAR)],
       z.[Deviation in original price (ZAR) Amount Excl. VAT],
       z.[Reason for deviation],
       z.[Has this become a hot prospect?],
       z.[General comments],
       z.[Who did we loose the deal to?],
	   z.[Who is other?]
       FROM	
(SELECT aa.*,
            BB.ResponseDate,
            BB.ReferenceNo AS Refno,
            BB.[%PI],
            BB.Status,
            BB.Comments,
            BB.[Follow up],
            BB.[Full value of quote (ZAR) Amount Excl. VAT],
            LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(BB.[Reason for lost deal],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Reason for lost deal],
            BB.[Price (ZAR)],
            BB.[Deviation in original price (ZAR) Amount Excl. VAT],
            BB.[Reason for deviation],
            BB.[Has this become a hot prospect?],
            BB.[General comments],
            BB.[Who did we loose the deal to?],
			BB.[Who is other?]
FROM 
(SELECT 
	   k.EstablishmentName,
       k.CapturedDate,
       k.ReferenceNo,
       k.IsPositive,
       k.IsResolved,
       k.UserId,
       k.UserName,
       k.Longitude,
       k.Latitude,
       k.CustomerName,
       k.CustomerMobile,
       k.CustomerEmail,
       j.RepeatCount,
       k.Area,
       k.[Are you logging an opportunity?],
       k.[Company name],
       k.[Is this a hot prospect?],
       k.[Is this long term or short term?],
       k.[What is the opportunity?],
       k.[Who are you engaging with?],
       k.Name,
       k.Surname,
       k.Mobile,
       k.Email,
       k.Accessories,
       k.[If other, what?],
       j.[kVA/Equipement],
       j.Quantity,
       k.[Full price value of opportunity (ZAR) Amount Excl. VAT]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Area],[Are you logging an opportunity?],[Company name],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5285 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (41947,41948,41949,41951,41950,41952,41953,41955,41956,41957,41958,41960,41961,41969,41963,42057)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount<>0
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Are you logging an opportunity?],[Company name],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT]
))p
)J

FULL JOIN 

(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Area],[Are you logging an opportunity?],[Company name],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5285 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (41947,41948,41949,41951,41950,41952,41953,41955,41956,41957,41958,41960,41961,41969,41963,42057)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount=0
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Are you logging an opportunity?],[Company name],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT]
))p
)K ON j.ReferenceNo=k.ReferenceNo
)AA
LEFT JOIN 

(
select EstablishmentName,CapturedDate,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,IsPositive,IsResolved,UserId, UserName, Longitude,Latitude,[%PI],
[Status],[Comments],[Follow up],[Full value of quote (ZAR) Amount Excl. VAT],
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Reason for lost deal],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Reason for lost deal],
[Price (ZAR)],[Deviation in original price (ZAR) Amount Excl. VAT],[Reason for deviation],[Has this become a hot prospect?],[General comments],[Who did we loose the deal to?],[Who is other?]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
am.IsPositive,am.IsResolved,
a.Detail as Answer,q.Questiontitle as Question,(am.pi/100) as "%PI",u.id as UserId, u.name as UserName, 
am.Longitude ,am.Latitude
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 497 and eg.id=5285 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (27710,27711,27712,27714,27776,27746,27747,27720,27719,27721,27722,27723,27724,27725)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Status],[Comments],[Follow up],[Full value of quote (ZAR) Amount Excl. VAT],[Reason for lost deal],[Price (ZAR)],[Deviation in original price (ZAR) Amount Excl. VAT],[Reason for deviation],[Has this become a hot prospect?],[General comments],[Who did we loose the deal to?],[Who is other?]
))P
)BB ON aa.ReferenceNo=BB.SeenClientAnswerMasterId
)z


UNION ALL

SELECT 
	   k.EstablishmentName,
       k.CapturedDate,
       k.ReferenceNo,
       k.IsPositive,
       k.IsResolved,
       k.UserId,
       k.UserName,
       k.Longitude,
       k.Latitude,
       k.CustomerName,
       k.CustomerMobile,
       k.CustomerEmail,
       j.RepeatCount,
       k.Area,
       k.[Are you logging an opportunity?],
       k.[Company name],
       k.[Is this a hot prospect?],
       k.[Is this long term or short term?],
       k.[What is the opportunity?],
       k.[Who are you engaging with?],
       k.Name,
       k.Surname,
       k.Mobile,
       k.Email,
       k.Accessories,
       k.[If other, what?],
       j.[kVA/Equipement],
       j.Quantity,
       k.[Full price value of opportunity (ZAR) Amount Excl. VAT],
	   NULL AS ResponseDate,
	   NULL AS Refno,
	   0.00 AS [%PI],
	   'Captured' AS Status,
	   NULL AS Comments,
	   NULL AS [Follow up],
	   NULL AS [Full value of quote (ZAR) Amount Excl. VAT],
	   NULL AS [Reason for lost deal],
	   NULL AS [Price (ZAR)],
	   NULL AS [Deviation in original price (ZAR) Amount Excl. VAT],
	   NULL AS [Reason for deviation],
	   NULL AS [Has this become a hot prospect?],
	   NULL AS [General comments],
	   NULL AS [Who did we loose the deal to?],
	   NULL AS [Who is other?]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Area],[Are you logging an opportunity?],[Company name],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5285 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (41947,41948,41949,41951,41950,41952,41953,41955,41956,41957,41958,41960,41961,41969,41963,42057)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount<>0
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Are you logging an opportunity?],[Company name],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT]
))p
)J

FULL JOIN 

(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Area],[Are you logging an opportunity?],[Company name],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5285 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (41947,41948,41949,41951,41950,41952,41953,41955,41956,41957,41958,41960,41961,41969,41963,42057)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount=0
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Are you logging an opportunity?],[Company name],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT]
))p
)K ON j.ReferenceNo=k.ReferenceNo
)d WHERE d.Status IS NOT NULL AND d.UserName<>'New Way Admin' 

/*NW Quoting / Outright Tenders*/

UNION ALL

select [EstablishmentName],
[CapturedDate],
[ReferenceNo],
[IsPositive],
[IsResolved],
[UserId],
[UserName],
[Longitude],
[Latitude],
[CustomerName],
[CustomerMobile],
[CustomerEmail],
[RepeatCount],
[Area],
NULL AS [O2 Province],
[Contact person],
[Contact number],
[Email address],
[Are you logging an opportunity?],
[Is this a hot prospect?],
[What is the opportunity spotted?],
[Are you speaking to ..],
[Company name],
[Is this a Quote or Tender],
[What is the customer interested in?],
REPLACE([Price value of opportunity (ZAR)],',','.') AS [Price value of opportunity (ZAR)],
NULL as Accessories,
null as [If other, what?],
[kVA rating] as [kVA/Equipement],
null as Quantity,
null as [Full price value of opportunity (ZAR) Amount Excl. VAT],
NULL AS [Is this long term or short term?],
[ResponseDate],
[Refno],
[%PI],
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Status],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS Status,
--[Status],
[Comments],
[Brand chosen],
REPLACE([Full Value of quote (ZAR)],',','.') AS [Full Value of quote (ZAR)],
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Reason for lost deal],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Reason for lost deal],
[Follow up],
[Who did we loose the deal to?],
[Who was the competitor?],
[Reason for cancellation],
REPLACE([Price (ZAR)],',','.') AS [Price (ZAR)],
REPLACE([Deviation in original price (ZAR)],',','.') AS [Deviation in original price (ZAR)],
[Reason for deviation],
[Has this become a hot quote?],
[General comments],
				CASE	when [Status]='Captured' then 1
						when [Status]='Only for quoting purposes' then 2
						when [Status]='Acceptance of positive feedback' then 3
						when [Status]='Follow up' then 4
						when [Status]='Re-quoted' then 5
						when [Status]='Purchase order received' then 6
						when [Status]='Lost deal' then 7
						else 8
						end as sortorder
FROM
(
SELECT 
	   AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.IsPositive,
       AA.IsResolved,
       AA.UserId,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.RepeatCount,
       AA.[Contact person],
       AA.[Contact number],
       AA.[Email address],
       AA.[Are you logging an opportunity?],
	   AA.Area,
       AA.[Is this a hot prospect?],
       AA.[What is the opportunity spotted?],
       AA.[Are you speaking to ..],
       AA.[Company name],
       AA.[Is this a Quote or Tender],
       AA.[What is the customer interested in?],
       AA.[Price value of opportunity (ZAR)],
	   AA.[kVA rating],
	   (Case When Ltrim(RTrim(bb.ResponseDate)) = '' THEN NULL ELSE bb.ResponseDate END) AS ResponseDate,
       (Case When Ltrim(RTrim(bb.ReferenceNo)) = '' THEN NULL ELSE bb.ReferenceNo END) AS Refno,
       (Case When Ltrim(RTrim(bb.[%PI])) = '' THEN NULL ELSE [%PI] END) AS [%PI],
	   bb.Status,
       (Case When Ltrim(RTrim(bb.Comments)) = '' THEN NULL ELSE Comments END) AS Comments,
	   bb.[Brand chosen],
       bb.[Full Value of quote (ZAR)],
       LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(bb.[Reason for lost deal],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Reason for lost deal],
       bb.[Follow up],
	   bb.[Who did we loose the deal to?],
       bb.[Who was the competitor?],
       bb.[Reason for cancellation],
       bb.[Price (ZAR)],
	   bb.[Deviation in original price (ZAR)],
       bb.[Reason for deviation],
       bb.[Has this become a hot quote?],
       bb.[General comments] 

FROM (
	SELECT 
	   k.EstablishmentName,
       k.CapturedDate,
       k.ReferenceNo,
       k.IsPositive,
       k.IsResolved,
       k.UserId,
       k.UserName,
       k.Longitude,
       k.Latitude,
       k.CustomerName,
       k.CustomerMobile,
       k.CustomerEmail,
       J.RepeatCount,
       k.[Contact person],
       k.[Contact number],
       k.[Email address],
       k.[Are you logging an opportunity?],
	   k.Area,
       k.[Is this a hot prospect?],
       k.[What is the opportunity spotted?],
       k.[Are you speaking to ..],
       k.[Company name],
       k.[Is this a Quote or Tender],
       J.[What is the customer interested in?],
       J.[Price value of opportunity (ZAR)],
	   J.[kVA rating]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Area],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[kVA rating]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer,
CASE WHEN q.Id=48860 THEN 'What is the customer interested in?' ELSE Q.Questiontitle END AS Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5063 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (40133,40488,40377,40135,40136,40139,39610,39611,39612,41728,41729,42012,48860,48825)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount<>0
)s
pivot(
Max(Answer)
For  Question In (
[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Area],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[kVA rating]
))p
)J

FULL JOIN 

(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Area],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[kVA rating]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer,
CASE WHEN q.Id=48860 THEN 'What is the customer interested in?' ELSE Q.Questiontitle END AS Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5063 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (40133,40488,40377,40135,40136,40139,39610,39611,39612,41728,41729,42012,48860,48825)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount=0
)s
pivot(
Max(Answer)
For  Question In (
[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Area],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[kVA rating]
))p
)K ON j.ReferenceNo=k.ReferenceNo
)AA
LEFT JOIN 
(
select EstablishmentName,CapturedDate,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,IsPositive,IsResolved,UserId, UserName, Longitude,Latitude,[%PI],
[Comments],[Reason for cancellation],[Brand chosen],[Full Value of quote (ZAR)],[General comments],[Price (ZAR)],[Deviation in original price (ZAR)],[Has this become a hot quote?],[Reason for deviation],[Who did we loose the deal to?],[Who was the competitor?],
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Status],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Status],
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Reason for lost deal],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Reason for lost deal],
[Follow up]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
am.IsPositive,am.IsResolved,
a.Detail as Answer,q.Questiontitle as Question,(am.pi/100) as "%PI",u.id as UserId, u.name as UserName, 
am.Longitude ,am.Latitude
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 497 and eg.id=5063 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (26908,26216,26218,28116,26219,26909,26835,26836,26223,26217,26578,26579,26833,26580,26222,27704)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
--WHERE cam.CreatedOn >= '2019-11-01'
) s
pivot(
Max(Answer)
For  Question In (
[Comments],[Reason for cancellation],[Brand chosen],[Full Value of quote (ZAR)],[General comments],[Price (ZAR)],[Deviation in original price (ZAR)],[Has this become a hot quote?],[Reason for deviation],[Who did we loose the deal to?],[Who was the competitor?],[Status],[Reason for lost deal],[Follow up]
))P
)BB ON aa.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT 
	   k.EstablishmentName,
       k.CapturedDate,
       k.ReferenceNo,
       k.IsPositive,
       k.IsResolved,
       k.UserId,
       k.UserName,
       k.Longitude,
       k.Latitude,
       k.CustomerName,
       k.CustomerMobile,
       k.CustomerEmail,
       J.RepeatCount,
       k.[Contact person],
       k.[Contact number],
       k.[Email address],
       k.[Are you logging an opportunity?],
	   k.Area,
       k.[Is this a hot prospect?],
       k.[What is the opportunity spotted?],
       k.[Are you speaking to ..],
       k.[Company name],
       k.[Is this a Quote or Tender],
       J.[What is the customer interested in?],
       J.[Price value of opportunity (ZAR)],
	   J.[kVA rating],
	   NULL AS ResponseDate,
	   NULL AS Refno,
	   0.00 AS [%PI],
	   'Captured' AS Status,
	   NULL AS Comments,
	   NULL AS [Brand chosen],
	   NULL AS [Full Value of quote (ZAR)],
	   NULL AS [Reason for lost deal],
	   NULL AS [Follow up],
	   NULL AS [Who did we loose the deal to?],
	   NULL AS [Who was the competitor?],
	   NULL AS [Reason for cancellation],
	   NULL AS [Price (ZAR)],
	   NULL AS [Deviation in original price (ZAR)],
	   NULL AS [Reason for deviation],
	   NULL AS [Has this become a hot quote?],
	   NULL AS [General comments]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Area],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[kVA rating]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,CASE WHEN q.Id=48860 THEN 'What is the customer interested in?' ELSE Q.Questiontitle END AS Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5063 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (40133,40488,40377,40135,40136,40139,39610,39611,39612,41728,41729,42012,48860,48825)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount<>0
)s
pivot(
Max(Answer)
For  Question In (
[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Area],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[kVA rating]
))p
)J

FULL JOIN 

(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Area],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[kVA rating]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,CASE WHEN q.Id=48860 THEN 'What is the customer interested in?' ELSE Q.Questiontitle END AS Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5063 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (40133,40488,40377,40135,40136,40139,39610,39611,39612,41728,41729,42012,48860,48825)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount=0
)s
pivot(
Max(Answer)
For  Question In (
[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Area],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[kVA rating]
))p
)K ON j.ReferenceNo=k.ReferenceNo
)d WHERE d.Status IS NOT NULL AND d.UserName<>'New Way Admin'


UNION ALL/*PWR02 Quotes*/

select 
[EstablishmentName],
[CapturedDate],
[ReferenceNo],
[IsPositive],
[IsResolved],
[UserId],
[UserName],
[Longitude],
[Latitude],
[CustomerName],
[CustomerMobile],
[CustomerEmail],
[RepeatCount],
NULL AS [Area],
[O2 Province],
CONCAT(d.name,' ',d.surname) AS [Contact person],
d.Mobile AS [Contact number],
d.Email AS [Email address],
[Are you logging an opportunity?],
[Is this a hot prospect?],
d.[What is the opportunity?] AS [What is the opportunity spotted?],
d.[Who are you engaging with?] AS [Are you speaking to ..],
[Company name],
NULL AS [Is this a Quote or Tender],
d.Brands AS [What is the customer interested in?],
NULL AS [Price value of opportunity (ZAR)],
d.[Client interested in] as Accessories,
null as [If other, what?],
null as [kVA/Equipement],
null as Quantity,
REPLACE(d.[Full price value of quote (ZAR) Amount Excl. VAT],',','.') as [Full price value of opportunity (ZAR) Amount Excl. VAT],
[Is this long term or short term?],
[ResponseDate],
[Refno],
[%PI],
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Status],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS Status,
--[Status],
[Comments],
[Brand chosen],
REPLACE(d.[Full value of quote (ZAR) Excl. VAT],',','.') AS [Full Value of quote (ZAR)],
[Reason for lost deal],
[Follow up],
NULL AS [Who did we loose the deal to?],
NULL AS [Who was the competitor?],
NULL AS [Reason for cancellation],
REPLACE([Price (ZAR)],',','.') AS [Price (ZAR)],
REPLACE(d.[Deviation in original price (ZAR) Amount Excl. VAT],',','.') AS [Deviation in original price (ZAR)],
[Reason for deviation],
d.[Has this become a hot prospect?] AS [Has this become a hot quote?],
[General comments],
				CASE	when [Status]='Captured' then 1
						when [Status]='Only for quoting purposes' then 2
						when [Status]='Acceptance of positive feedback' then 3
						when [Status]='Follow up' then 4
						when [Status]='Re-quoted' then 5
						when [Status]='Purchase order received' then 6
						when [Status]='Lost deal' then 7
						else 8
						end as sortorder
FROM
(
SELECT 
	   AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.IsPositive,
       AA.IsResolved,
       AA.UserId,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.RepeatCount,
       AA.[Company name],
       AA.Area AS [O2 Province],
       AA.[Are you logging an opportunity?],
       AA.[Is this a hot prospect?],
       AA.[Is this long term or short term?],
       AA.[What is the opportunity?],
       AA.[Who are you engaging with?],
       AA.Name,
       AA.Surname,
       AA.Mobile,
       AA.Email,
       AA.[Full price value of quote (ZAR) Amount Excl. VAT],
       AA.[Client interested in],
       AA.Brands,
	   NULL AS [Engine Models],
       BB.ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[%PI],
       BB.[Status],
       BB.[Has this become a hot prospect?],
       BB.[Follow up],
       BB.[Full value of quote (ZAR) Excl. VAT],
       BB.[Reason for lost deal],
       BB.[Price (ZAR)],
       BB.[Deviation in original price (ZAR) Amount Excl. VAT],
       BB.[Reason for deviation],
       BB.Comments,
       BB.[General Comments],
	   BB.[Brand chosen] 

FROM (
	SELECT K.EstablishmentName,
           K.CapturedDate,
           K.ReferenceNo,
           K.IsPositive,
           K.IsResolved,
           K.UserId,
           K.UserName,
           K.Longitude,
           K.Latitude,
           K.CustomerName,
           K.CustomerMobile,
           K.CustomerEmail,
           J.RepeatCount,
           K.[Company name],
           K.Area,
           K.[Are you logging an opportunity?],
           K.[Is this a hot prospect?],
           K.[Is this long term or short term?],
           K.[What is the opportunity?],
           K.[Who are you engaging with?],
           K.Name,
           K.Surname,
           K.Mobile,
           K.Email,
           K.[Full price value of quote (ZAR) Amount Excl. VAT],
           J.[Client interested in],
           J.Brands,
		   J.[Engine Models]
	   
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Company name],[Area],[Are you logging an opportunity?],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Full price value of quote (ZAR) Amount Excl. VAT],[Client interested in],[Brands],[Engine Models]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5473 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44580,44827,44582,44583,44584,44585,44586,44588,44589,44590,44591,44595,44596,44597,44799)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount<>0
)s
pivot(
Max(Answer)
For  Question In (
[Company name],[Area],[Are you logging an opportunity?],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Full price value of quote (ZAR) Amount Excl. VAT],[Client interested in],[Brands],[Engine Models]
))p
)J

FULL JOIN 

(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Company name],[Area],[Are you logging an opportunity?],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Full price value of quote (ZAR) Amount Excl. VAT],[Client interested in],[Brands],[Engine Models]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5473 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44580,44827,44582,44583,44584,44585,44586,44588,44589,44590,44591,44595,44596,44597,44799)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount=0
)s
pivot(
Max(Answer)
For  Question In (
[Company name],[Area],[Are you logging an opportunity?],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Full price value of quote (ZAR) Amount Excl. VAT],[Client interested in],[Brands],[Engine Models]
))p
)K ON j.ReferenceNo=k.ReferenceNo
)AA

LEFT JOIN 

(
select EstablishmentName,CapturedDate,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,IsPositive,IsResolved,UserId, UserName, Longitude,Latitude,[%PI],
[Status],[Has this become a hot prospect?],[Follow up],[Full value of quote (ZAR) Excl. VAT],[Reason for lost deal],[Price (ZAR)],[Deviation in original price (ZAR) Amount Excl. VAT],[Reason for deviation],[Comments],[General Comments],[Brand chosen]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
am.IsPositive,am.IsResolved,
a.Detail as Answer,q.Questiontitle as Question,(am.pi/100) as "%PI",u.id as UserId, u.name as UserName, 
am.Longitude ,am.Latitude
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 497 and eg.id=5473 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (29529,29530,29531,29532,29533,29534,29535,29536,29537,29538,29762)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Status],[Has this become a hot prospect?],[Follow up],[Full value of quote (ZAR) Excl. VAT],[Reason for lost deal],[Price (ZAR)],[Deviation in original price (ZAR) Amount Excl. VAT],[Reason for deviation],[Comments],[General Comments],[Brand chosen]
))P
)BB ON aa.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT     K.EstablishmentName,
           K.CapturedDate,
           K.ReferenceNo,
           K.IsPositive,
           K.IsResolved,
           K.UserId,
           K.UserName,
           K.Longitude,
           K.Latitude,
           K.CustomerName,
           K.CustomerMobile,
           K.CustomerEmail,
           J.RepeatCount,
           K.[Company name],
           K.Area AS [O2 Province],
           K.[Are you logging an opportunity?],
           K.[Is this a hot prospect?],
           K.[Is this long term or short term?],
           K.[What is the opportunity?],
           K.[Who are you engaging with?],
           K.Name,
           K.Surname,
           K.Mobile,
           K.Email,
           K.[Full price value of quote (ZAR) Amount Excl. VAT],
           J.[Client interested in],
           J.Brands,
		   J.[Engine Models],
		   NULL AS ResponseDate,
           NULL AS Refno,
           0.00 AS [%PI],
           'Captured' AS [Status],
           NULL as [Has this become a hot prospect?],
           NULL as [Follow up],
           NULL as [Full value of quote (ZAR) Excl. VAT],
           NULL as [Reason for lost deal],
           NULL as [Price (ZAR)],
           NULL as [Deviation in original price (ZAR) Amount Excl. VAT],
           NULL as [Reason for deviation],
           NULL as Comments,
           NULL as [General Comments],
		   NULL AS [Brand chosen]
	   
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Company name],[Area],[Are you logging an opportunity?],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Full price value of quote (ZAR) Amount Excl. VAT],[Client interested in],[Brands],[Engine Models]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5473 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44580,44827,44582,44583,44584,44585,44586,44588,44589,44590,44591,44595,44596,44597,44799)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount<>0
)s
pivot(
Max(Answer)
For  Question In (
[Company name],[Area],[Are you logging an opportunity?],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Full price value of quote (ZAR) Amount Excl. VAT],[Client interested in],[Brands],[Engine Models]
))p
)J

FULL JOIN 

(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Company name],[Area],[Are you logging an opportunity?],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Full price value of quote (ZAR) Amount Excl. VAT],[Client interested in],[Brands],[Engine Models]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved ,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5473 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44580,44827,44582,44583,44584,44585,44586,44588,44589,44590,44591,44595,44596,44597,44799)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE a.RepeatCount=0
)s
pivot(
Max(Answer)
For  Question In (
[Company name],[Area],[Are you logging an opportunity?],[Is this a hot prospect?],[Is this long term or short term?],[What is the opportunity?],[Who are you engaging with?],[Name],[Surname],[Mobile],[Email],[Full price value of quote (ZAR) Amount Excl. VAT],[Client interested in],[Brands],[Engine Models]
))p
)K ON j.ReferenceNo=k.ReferenceNo
)d WHERE d.[Status] IS NOT NULL 
)FF

