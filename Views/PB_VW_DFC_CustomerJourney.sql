CREATE VIEW PB_VW_DFC_CustomerJourney AS

SELECT AA.CapturedDate,
	   CAST(AA.CapturedDate AS DATE) AS [Capture Date],
       AA.ReferenceNo,
       AA.UserName,
       AA.CustomerCompany,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.CustomerName,
       BB.ResponseDate,
	   CAST(BB.ResponseDate AS DATE) AS [Response Date],
       --BB.SeenClientAnswerMasterId,
       BB.ResponseNo,
       BB.Responsename,
       BB.Responsemail,
       BB.PI,
       BB.[How responsive are we to your needs:],
       BB.[How well do we communicate on the status of your orders],
       BB.ATVAL,
       BB.BIMAN,
       BB.INSAMCOR,
       BB.SKG,
       BB.SAUNDERS,
       BB.VOM,
       BB.VOSA,
       BB.[How are we on fulfilling our promise date on the completion of your orders:],
       BB.[How are we on getting your order right first time:],
       BB.[Rate the quality of our brands],
       BB.[Which brands commonly result in quality issues?],
       BB.[Tell us which aspects of our product quality must improve?],
       REPLACE(BB.[Where you have quality issues with our valves you are likely to…..],'Buy somewhere else?','Buy somewhere else…') AS [Where you have quality issues with our valves you are likely to…..],
       BB.[Rate our pricing],
       BB.[Select from the below which brand causes you the most pricing anxiety.],
       BB.[Rate our invoice accuracy] 
	   FROM
(SELECT
cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2283
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2287
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2286
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2284
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2285
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 366 and eg.id=7223 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)AA

LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,ResponseNo,Responsename,P.Responsemail,P.PI,
[How responsive are we to your needs:],[How well do we communicate on the status of your orders],[ATVAL],[BIMAN],[INSAMCOR],[SKG],[SAUNDERS],[VOM],[VOSA],[How are we on fulfilling our promise date on the completion of your orders:],[How are we on getting your order right first time:],[Rate the quality of our brands],[Which brands commonly result in quality issues?],[Tell us which aspects of our product quality must improve?],[Where you have quality issues with our valves you are likely to…..],[Rate our pricing],[Select from the below which brand causes you the most pricing anxiety.],[Rate our invoice accuracy]
from (
SELECT
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,am.PI,
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(a.Detail,'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS Answer,
CASE WHEN q.Id=59085 THEN 'Where you have quality issues with our valves you are likely to…..' ELSE q.Questiontitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2284
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2285
) as Responsename,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2287
) as Responsemail
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 366 and eg.id=7223
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (51403,52505,52775,52776,52777,52778,52779,52780,52781,51411,51412,52495,51414,52742,52743,52744,51417,51418,59085)
left outer join dbo.[Appuser] u on u.id=am.AppUserId
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
LEFT JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id=am.SeenClientAnswerChildId
) s
pivot(
Max(Answer)
For  Question In (
[How responsive are we to your needs:],[How well do we communicate on the status of your orders],[ATVAL],[BIMAN],[INSAMCOR],[SKG],[SAUNDERS],[VOM],[VOSA],[How are we on fulfilling our promise date on the completion of your orders:],[How are we on getting your order right first time:],[Rate the quality of our brands],[Which brands commonly result in quality issues?],[Tell us which aspects of our product quality must improve?],[Where you have quality issues with our valves you are likely to…..],[Rate our pricing],[Select from the below which brand causes you the most pricing anxiety.],[Rate our invoice accuracy]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId AND AA.CustomerName=BB.Responsename AND AA.CustomerEmail=BB.Responsemail

