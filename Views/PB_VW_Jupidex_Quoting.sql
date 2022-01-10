CREATE VIEW dbo.PB_VW_Jupidex_Quoting AS

SELECT d.EstablishmentName,
       CAST(d.CapturedDate AS DATE) AS CapturedDate,
       d.ReferenceNo,
       d.IsResolved,
       d.UserName,
       d.[Is this a OTP or a Quotation ?],
       d.Customer,
       d.[Name & Surname],
       d.[Contact number],
       d.[Email Address],
       d.Date,
       d.[Full address],
       d.[VAT Number],
	   d.[What currency are you quoting on?],
       d.[Product1 information],
       REPLACE(d.[Price1 EXCL VAT (R)],' ','') AS [Price1 EXCL VAT (R)],
       d.[Product2 information],
       REPLACE(d.[Price2 EXCL VAT (R)],' ','') AS [Price2 EXCL VAT (R)],
       d.[Product3 information],
       REPLACE(d.[Price3 EXCL VAT (R)],' ','') AS [Price3 EXCL VAT (R)],
       d.[Product4 information],
       REPLACE(d.[Price4 EXCL VAT (R)],' ','') AS [Price4 EXCL VAT (R)],
       d.[Product5 information],
       REPLACE(d.[Price5 EXCL VAT (R)],' ','') AS [Price5 EXCL VAT (R)],
       d.[Product6 information],
       REPLACE(d.[Price6 EXCL VAT (R)],' ','') AS [Price6 EXCL VAT (R)],
       d.[Product7 information],
       REPLACE(d.[Price7 EXCL VAT (R)],' ','') AS [Price7 EXCL VAT (R)],
       d.[Product8 information],
       REPLACE(d.[Price8 EXCL VAT (R)],' ','') AS [Price8 EXCL VAT (R)],
       d.[Product9 information],
       REPLACE(d.[Price9 EXCL VAT (R)],' ','') AS [Price9 EXCL VAT (R)],
       d.[Product10 information],
       REPLACE(d.[Price10 EXCL VAT (R)],' ','') AS [Price10 EXCL VAT (R)],
       d.Comments,
       d.[I do hereby accept the attached quotation and the conditions as set out in the Terms and Conditions stated on the reverse side.],
       IIF(d.[Client Signature]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',d.[Client Signature])) AS [Client Signature],
       IIF(d.[Jupidex Representative Signature]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',d.[Jupidex Representative Signature])) AS [Jupidex Representative Signature],
       d.ResponseDate,
       d.Responseno,
       d.Status,
       d.[Type of follow up:],
       d.[Reason for lost deal],
       d.[Who is the competitor?],
       d.[What products?],
	   CASE WHEN d.Status='Captured' THEN 1
			WHEN d.Status='Follow up' THEN 2
			WHEN d.Status='Purchase order received' THEN 3
			WHEN d.Status='Lost deal' THEN 4
			ELSE 5 END AS sortorder
	   FROM 
(SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.IsResolved,
       AA.UserName,
       AA.[Is this a OTP or a Quotation ?],
       AA.Customer,
       AA.[Name & Surname],
       AA.[Contact number],
       AA.[Email Address],
       AA.Date,
       AA.[Full address],
       AA.[VAT Number],
	   AA.[What currency are you quoting on?],
       AA.[Product1 information],
       AA.[Price1 EXCL VAT (R)],
       AA.[Product2 information],
       AA.[Price2 EXCL VAT (R)],
       AA.[Product3 information],
       AA.[Price3 EXCL VAT (R)],
       AA.[Product4 information],
       AA.[Price4 EXCL VAT (R)],
       AA.[Product5 information],
       AA.[Price5 EXCL VAT (R)],
       AA.[Product6 information],
       AA.[Price6 EXCL VAT (R)],
       AA.[Product7 information],
       AA.[Price7 EXCL VAT (R)],
       AA.[Product8 information],
       AA.[Price8 EXCL VAT (R)],
       AA.[Product9 information],
       AA.[Price9 EXCL VAT (R)],
       AA.[Product10 information],
       AA.[Price10 EXCL VAT (R)],
       AA.Comments,
       AA.[I do hereby accept the attached quotation and the conditions as set out in the Terms and Conditions stated on the reverse side.],
       AA.[Client Signature],
       AA.[Jupidex Representative Signature],
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.Responseno,
       BB.Status,
       BB.[Type of follow up:],
       BB.[Reason for lost deal],
       BB.[Who is the competitor?],
       BB.[What products?] 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsResolved,UserName,
[Is this a OTP or a Quotation ?],[Customer],[Name & Surname],[Contact number],[Email Address],[Date],[Full address],[VAT Number],
IIF([What currency are you quoting on?] IS NULL,'Rand – ZAR – (R)',p.[What currency are you quoting on?]) AS [What currency are you quoting on?],
[Product1 information],[Price1 EXCL VAT (R)],[Product2 information],[Price2 EXCL VAT (R)],[Product3 information],[Price3 EXCL VAT (R)],[Product4 information],[Price4 EXCL VAT (R)],[Product5 information],[Price5 EXCL VAT (R)],[Product6 information],[Price6 EXCL VAT (R)],[Product7 information],[Price7 EXCL VAT (R)],[Product8 information],[Price8 EXCL VAT (R)],[Product9 information],[Price9 EXCL VAT (R)],[Product10 information],[Price10 EXCL VAT (R)],[Comments],[I do hereby accept the attached quotation and the conditions as set out in the Terms and Conditions stated on the reverse side.],[Client Signature],[Jupidex Representative Signature]
FROM
(SELECT
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved,A.Detail as Answer,
CASE 
when q.id=52946	then 'Product1 information'
when q.id=51764	then 'Price1 EXCL VAT (R)'
when q.id=52945	then 'Product2 information'
when q.id=51766	then 'Price2 EXCL VAT (R)'
when q.id=52939	then 'Product3 information'
when q.id=51768	then 'Price3 EXCL VAT (R)'
when q.id=52943	then 'Product4 information'
when q.id=51770	then 'Price4 EXCL VAT (R)'
when q.id=52944	then 'Product5 information'
when q.id=51772	then 'Price5 EXCL VAT (R)'
when q.id=52942	then 'Product6 information'
when q.id=51774	then 'Price6 EXCL VAT (R)'
when q.id=52941	then 'Product7 information'
when q.id=51778	then 'Price7 EXCL VAT (R)'
when q.id=52940	then 'Product8 information'
when q.id=51780	then 'Price8 EXCL VAT (R)'
when q.id=52938	then 'Product9 information'
when q.id=51782	then 'Price9 EXCL VAT (R)'
when q.id=52937	then 'Product10 information'
when q.id=51784	then 'Price10 EXCL VAT (R)' ELSE Q.Questiontitle END AS Question,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2359
) as [Email Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2358
) as [Contact number],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2356
) as [Name & Surname]
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 373 and eg.id=6177 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (51754,52947,51756,51757,51758,51759,51760,51761,52946,51764,52945,51766,52939,51768,52943,51770,52944,51772,52942,51774,52941,51778,52940,51780,52938,51782,52937,51784,51786,51789,51790,51791,71200)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s 
pivot(
Max(Answer)
For  Question In (
[Is this a OTP or a Quotation ?],[Customer],[Date],[Full address],[VAT Number],[What currency are you quoting on?],[Product1 information],[Price1 EXCL VAT (R)],[Product2 information],[Price2 EXCL VAT (R)],[Product3 information],[Price3 EXCL VAT (R)],[Product4 information],[Price4 EXCL VAT (R)],[Product5 information],[Price5 EXCL VAT (R)],[Product6 information],[Price6 EXCL VAT (R)],[Product7 information],[Price7 EXCL VAT (R)],[Product8 information],[Price8 EXCL VAT (R)],[Product9 information],[Price9 EXCL VAT (R)],[Product10 information],[Price10 EXCL VAT (R)],[Comments],[I do hereby accept the attached quotation and the conditions as set out in the Terms and Conditions stated on the reverse side.],[Client Signature],[Jupidex Representative Signature]
))p
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,Responseno,
[Status],[Type of follow up:],[Reason for lost deal],[Who is the competitor?],[What products?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as Responseno,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 373 and eg.id=6177 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (37619,36919,37170,37617,37618)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Status],[Type of follow up:],[Reason for lost deal],[Who is the competitor?],[What products?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT EstablishmentName,CapturedDate,ReferenceNo,IsResolved,UserName,--CustomerName,CustomerMobile,CustomerEmail,
[Is this a OTP or a Quotation ?],[Customer],[Name & Surname],[Contact number],[Email Address],[Date],[Full address],[VAT Number],
IIF([What currency are you quoting on?] IS NULL,'Rand – ZAR – (R)',p.[What currency are you quoting on?]) AS [What currency are you quoting on?],
[Product1 information],[Price1 EXCL VAT (R)],[Product2 information],[Price2 EXCL VAT (R)],[Product3 information],[Price3 EXCL VAT (R)],[Product4 information],[Price4 EXCL VAT (R)],[Product5 information],[Price5 EXCL VAT (R)],[Product6 information],[Price6 EXCL VAT (R)],[Product7 information],[Price7 EXCL VAT (R)],[Product8 information],[Price8 EXCL VAT (R)],[Product9 information],[Price9 EXCL VAT (R)],[Product10 information],[Price10 EXCL VAT (R)],[Comments],[I do hereby accept the attached quotation and the conditions as set out in the Terms and Conditions stated on the reverse side.],[Client Signature],[Jupidex Representative Signature],
NULL AS ResponseDate,
NULL AS Responseno,
'Captured' AS Status,
NULL AS [Type of follow up:],
NULL AS [Reason for lost deal],
NULL AS [Who is the competitor?],
NULL AS [What products?]
FROM
(SELECT
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved,A.Detail as Answer,
CASE 
when q.id=52946	then 'Product1 information'
when q.id=51764	then 'Price1 EXCL VAT (R)'
when q.id=52945	then 'Product2 information'
when q.id=51766	then 'Price2 EXCL VAT (R)'
when q.id=52939	then 'Product3 information'
when q.id=51768	then 'Price3 EXCL VAT (R)'
when q.id=52943	then 'Product4 information'
when q.id=51770	then 'Price4 EXCL VAT (R)'
when q.id=52944	then 'Product5 information'
when q.id=51772	then 'Price5 EXCL VAT (R)'
when q.id=52942	then 'Product6 information'
when q.id=51774	then 'Price6 EXCL VAT (R)'
when q.id=52941	then 'Product7 information'
when q.id=51778	then 'Price7 EXCL VAT (R)'
when q.id=52940	then 'Product8 information'
when q.id=51780	then 'Price8 EXCL VAT (R)'
when q.id=52938	then 'Product9 information'
when q.id=51782	then 'Price9 EXCL VAT (R)'
when q.id=52937	then 'Product10 information'
when q.id=51784	then 'Price10 EXCL VAT (R)' ELSE Q.Questiontitle END AS Question,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2359
) as [Email Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2358
) as [Contact number],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2356
) as [Name & Surname]
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 373 and eg.id=6177 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (51754,52947,51756,51757,51758,51759,51760,51761,52946,51764,52945,51766,52939,51768,52943,51770,52944,51772,52942,51774,52941,51778,52940,51780,52938,51782,52937,51784,51786,51789,51790,51791,71200)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s 
pivot(
Max(Answer)
For  Question In (
[Is this a OTP or a Quotation ?],[Customer],[Date],[Full address],[VAT Number],[What currency are you quoting on?],[Product1 information],[Price1 EXCL VAT (R)],[Product2 information],[Price2 EXCL VAT (R)],[Product3 information],[Price3 EXCL VAT (R)],[Product4 information],[Price4 EXCL VAT (R)],[Product5 information],[Price5 EXCL VAT (R)],[Product6 information],[Price6 EXCL VAT (R)],[Product7 information],[Price7 EXCL VAT (R)],[Product8 information],[Price8 EXCL VAT (R)],[Product9 information],[Price9 EXCL VAT (R)],[Product10 information],[Price10 EXCL VAT (R)],[Comments],[I do hereby accept the attached quotation and the conditions as set out in the Terms and Conditions stated on the reverse side.],[Client Signature],[Jupidex Representative Signature]
))p
)d WHERE d.Status IS NOT NULL

