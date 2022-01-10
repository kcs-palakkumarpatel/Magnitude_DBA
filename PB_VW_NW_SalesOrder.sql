CREATE VIEW dbo.PB_VW_NW_SalesOrder AS 

/*NW Sales Orders*/
SELECT 
EstablishmentName,
CapturedDate,
ReferenceNo,
IsPositive,
Status,
UserId,
UserName,
Longitude,
Latitude,
CustomerName,
CustomerMobile,
CustomerEmail,
0 AS RepeatCount,
[Area],
NULL AS [O2 Province],
[Sales representative on job],
[Date],
[Type],
REPLACE(REPLACE([Price of job (Excluding VAT) (ZAR)],',','.'),' ','') AS [Price of job (Excluding VAT) (ZAR)],
[Company name],
[Customer order number],
[Quote / tender ref number],
[Customer job number],
[Contact person],
[Contact number],
[Email address],
[Industry serve],
[Required delivery date],
[Delivery address],
NULL AS Accessories,
NULL AS [If other, what?],
0 AS [Full price value of opportunity (ZAR) Amount Excl. VAT],
[kVA rating],
[If other, please state],
[Engine make],
NULL AS [Engine Model],
0 AS Quantity
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5039 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (39220,39223,40424,39225,39226,39227,39228,39229,40889,39235,39236,39238,40410,39240,42547,39221,48827,48828)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
--WHERE u.Name<>'New Way Admin'
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Date],[Type],[Company name],[Customer order number],[Quote / tender ref number],[Customer job number],[Contact person],[Contact number],[Email address],[Required delivery date],[Delivery address],[kVA rating],[If other, please state],[Engine make],[Price of job (Excluding VAT) (ZAR)],[Industry serve],[Sales representative on job]
))p

UNION ALL /*Genmatics Sales Orders */

SELECT k.EstablishmentName,
       k.CapturedDate,
       k.ReferenceNo,
       k.IsPositive,
       k.Status,
       k.UserId,
       k.UserName,
       k.Longitude,
       k.Latitude,
       k.CustomerName,
       k.CustomerMobile,
       k.CustomerEmail,
       j.RepeatCount,
       k.Area,
	   NULL AS [O2 Province],
	   k.[Sales representative on job],
       k.Date,
       k.Type,
       k.[Price of job (Excluding VAT) (ZAR)],
       k.[Company name],
       k.[Customer order number],
	   NULL AS [Quote / tender ref number],
	   NULL AS [Customer job number],
       k.[Contact person],
       k.[Contact number],
       k.[Email address],
       k.[Industry serve],
       k.[Required delivery date],
       k.[Delivery address],
       k.Accessories,
       k.[If other, what?],
       k.[Full price value of opportunity (ZAR) Amount Excl. VAT],
       j.[kVA/Equipment],
	   null as [If other, please state],
	   null as [Engine make],
	   NULL AS [Engine Model],
       j.Quantity FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Area],[Date],[Sales representative on job],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Accessories],[If other, what?],[Full price value of opportunity (ZAR) Amount Excl. VAT],[kVA/Equipment],[Quantity]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,a.RepeatCount,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5379 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (43143,43144,43145,43146,43147,43149,43150,43151,43152,43153,43154,43155,43156,43158,43159,43160,43161,43162)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount<>0
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Date],[Sales representative on job],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Accessories],[If other, what?],[Full price value of opportunity (ZAR) Amount Excl. VAT],[kVA/Equipment],[Quantity]
))p
)j
FULL JOIN
(
select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Area],[Date],[Sales representative on job],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Accessories],[If other, what?],[Full price value of opportunity (ZAR) Amount Excl. VAT],[kVA/Equipment],[Quantity]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,a.RepeatCount,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5379 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (43143,43144,43145,43146,43147,43149,43150,43151,43152,43153,43154,43155,43156,43158,43159,43160,43161,43162)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount=0
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Date],[Sales representative on job],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Accessories],[If other, what?],[Full price value of opportunity (ZAR) Amount Excl. VAT],[kVA/Equipment],[Quantity]
))p
)k ON j.ReferenceNo=k.ReferenceNo

UNION ALL /*PWR02 Sales Orders*/

SELECT 
       k.EstablishmentName,
       k.CapturedDate,
       k.ReferenceNo,
       k.IsPositive,
       k.Status,
       k.UserId,
       k.UserName,
       k.Longitude,
       k.Latitude,
       k.CustomerName,
       k.CustomerMobile,
       k.CustomerEmail,
       j.RepeatCount,
	   NULL AS Area,
       k.Area AS [O2 Province],
	   k.UserName AS  [Sales representative on job],
       k.Date,    
       k.Type,
       k.[Price of job (Excluding VAT) (ZAR)],
       k.[Company name],
       k.[Customer order number],
	   NULL AS [Quote / tender ref number],
	   NULL AS [Customer job number],
       k.[Contact person],
       k.[Contact number],
       k.[Email address],
       k.[Industry serve],
       k.[Required delivery date],
       k.[Delivery address],
       j.[Client interested in] AS Accessories,
	   NULL AS [If other, what?],
	   0 AS [Full price value of opportunity (ZAR) Amount Excl. VAT],
	   NULL AS [kVA rating],
       NULL AS [If other, please state],
       j.Brands AS [Engine make],
       j.[Engine Model],
	   0 AS Quantity
FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Area],[Date],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Client interested in],[Brands],[Engine Model]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,a.RepeatCount,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5475 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44826,44618,44620,44621,44623,44624,44625,44626,44627,44628,44629,44630,44631,44632,44800)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount<>0
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Date],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Client interested in],[Brands],[Engine Model]
))p  
)j
FULL JOIN
(
select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,
[Area],[Date],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Client interested in],[Brands],[Engine Model]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,a.RepeatCount,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5475 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44826,44618,44620,44621,44623,44624,44625,44626,44627,44628,44629,44630,44631,44632,44800)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount=0
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Date],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Client interested in],[Brands],[Engine Model]
))p
)k ON j.ReferenceNo=k.ReferenceNo

