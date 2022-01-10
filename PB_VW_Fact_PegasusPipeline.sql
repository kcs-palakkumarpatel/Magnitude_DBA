
CREATE view [dbo].[PB_VW_Fact_PegasusPipeline] as
select *, case when [Status:]='Quote Sent' then 1
			  when [Status:]='Only quoting purposes' then 2
			  when [Status:]='Follow up' then 3
			  when [Status:]='Received purchase order' then 4
			  when [Status:]='Lost deal' then 5
			  else 6
			  end as sortorder
from
(
select a.*,b.CustomerName,b.CustomerMobile,b.CustomerEmail,b.ResponseDate,b.ReferenceNo as Refno,b.[%PI] as response_pi,b.[Status:],b.[Reason for lost sale:],b.[Who did we loose the sale to?],b.[Percentage price difference on lost deal? (%)],b.[General comments:],b.[What was the full value of the purchase order (ZAR):]
from
(
select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,Longitude,Latitude,
[Is this a:],[Company name:],[Quote number:],replace([Value of quote (ZAR):],',','.') as [Value of quote (ZAR):],[General comments:] as cap_comments,[Full name:],[Mobile number:],[Email:],[Type of account:]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName, 
AM.Longitude ,AM.Latitude

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 477 and eg.id=4877 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (36866,36867,36868,36869,36870,36872,36873,36874,37497)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Is this a:],[Company name:],[Quote number:],[Value of quote (ZAR):],[General comments:],[Full name:],[Mobile number:],[Email:],[Type of account:]
))p
)a
left join
(
select EstablishmentName,CapturedDate,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude,[%PI],
CustomerName,CustomerMobile,CustomerEmail,

Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Status:],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) as [Status:],
[Reason for lost sale:],
[Who did we loose the sale to?],[Percentage price difference on lost deal? (%)],[General comments:],
replace([What was the full value of the purchase order (ZAR):],',','.') as [What was the full value of the purchase order (ZAR):]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
am.IsPositive,am.IsResolved as Status,
a.Detail as Answer,q.Questiontitle as Question,(am.pi/100) as "%PI",u.id as UserId, u.name as UserName, 
am.Longitude ,am.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2913
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2912
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2910
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2911
) as CustomerName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 477 and eg.id=4877 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (24475,24453,24466,24467,24356,25137,25139)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on Am.SeenClientAnswerChildId=SAC.Id 
) s
pivot(
Max(Answer)
For  Question In (
[Status:],[Reason for lost sale:],[Who did we loose the sale to?],[Percentage price difference on lost deal? (%)],[General comments:],[What was the full value of the purchase order (ZAR):]
))P 
)b on a.ReferenceNo=b.SeenClientAnswerMasterId 

union all

select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,Longitude,Latitude,
[Is this a:],[Company name:],[Quote number:],replace([Value of quote (ZAR):],',','.') as [Value of quote (ZAR):],[General comments:],[Full name:],[Mobile number:],[Email:],[Type of account:],CustomerName,CustomerMobile,CustomerEmail,
NULL as ResponseDate,NULL as Refno,0.00 as response_pi,'Quote Sent' as [Status:],NULL as [Reason for lost sale:],NULL as [Who did we loose the sale to?],NULL as [Percentage price difference on lost deal? (%)],NULL as [General comments:],
'' as[What was the full value of the purchase order (ZAR):]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName, 
AM.Longitude ,AM.Latitude,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2913
--)
'' as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2912
--) 
'' as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2910
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2911
--)
'' as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 477 and eg.id=4877 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (36866,36867,36868,36869,36870,36872,36873,36874,37497)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Is this a:],[Company name:],[Quote number:],[Value of quote (ZAR):],[General comments:],[Full name:],[Mobile number:],[Email:],[Type of account:]
))p
)d where ReferenceNo<>381169 and [Status:] is not null


