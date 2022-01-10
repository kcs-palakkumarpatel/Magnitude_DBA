CREATE VIEW dbo.PB_VW_Macsteel_Covid19 AS

SELECT AA.Type,
       CAST(AA.CapturedDate AS DATE) AS CapturedDate,
       AA.ReferenceNo,
       AA.UserName,
       AA.PI,
	   IIF(AA.PI=100,'Pass','Fail') AS Result,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.[Full Name],
       AA.[Vistor mobile number],
       AA.Address,
       AA.[Identity Number],
       AA.[Company Name],
       AA.[Vehicle Registration],
       AA.[Time in],
       AA.[Have you been in contact with someone who has travelled internationally?],
       AA.Comments,
       AA.[Have you been in contact with a laboratory to confirm a case of COVID-19?],
       AA.Comments1,
       AA.[Have you been in contact with a person that is a confirmed COVID-19 case or is currently awaiting test results for COVID-19?],
       AA.Comments2,
       AA.[Temperature of 37.3°C or above],
       AA.Comments3,
       AA.[Employee temperature °C],
       AA.[Loss of smell or taste],
       AA.Comments4,
       AA.[Flu-like symptoms or coughing],
       AA.Comments5,
       AA.[Sore throat or diarrhea],
       AA.Comments6,
       AA.[Shortness of breath],
       AA.Comments7,
       AA.Pneumonia,
       AA.Comments8,
       AA.[Muscle pain or chills],
       AA.Comments9,
       AA.[Headaches or vomiting],
       AA.Comments10,
       AA.[Redness of eyes],
       AA.Comments11,
       AA.[Fatigue, weakness, or tiredness],
       AA.Comments12,
       AA.[Do you have any chronic diseases?],
       AA.Comments13,
       AA.[Reason for visit],
       AA.[Employee signature],
       AA.[Security name],
       AA.Date,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ResponseNo,
       BB.[Time out],
       BB.[Is employee's temperature above 37.5 °C],
       BB.[Temperature reading],
	   CONCAT(AA.CustomerName,AA.[Full Name]) AS [Emp&Visitor]
	   FROM 
(SELECT 'Employee Screening' AS [Type],CapturedDate,ReferenceNo,UserName,p.PI,CustomerName,CustomerMobile,CustomerEmail,
NULL AS [Full Name],NULL AS [Vistor mobile number],NULL AS [Address],NULL AS [Identity Number],NULL AS [Company Name],NULL AS [Vehicle Registration],NULL AS [Time in],
[Have you been in contact with someone who has travelled internationally?],[Comments],[Have you been in contact with a laboratory to confirm a case of COVID-19?],[Comments1],[Have you been in contact with a person that is a confirmed COVID-19 case or is currently awaiting test results for COVID-19?],[Comments2],[Temperature of 37.3°C or above],[Comments3],[Employee temperature °C],[Loss of smell or taste],[Comments4],[Flu-like symptoms or coughing],[Comments5],[Sore throat or diarrhea],[Comments6],[Shortness of breath],[Comments7],[Pneumonia],[Comments8],[Muscle pain or chills],[Comments9],[Headaches or vomiting],[Comments10],[Redness of eyes],[Comments11],[Fatigue, weakness, or tiredness],[Comments12],[Do you have any chronic diseases?],[Comments13],NULL AS [Reason for visit],
IIF([Employee signature]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Employee signature])) AS [Employee signature],[Security name],[Date]
FROM
(
SELECT
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,u.name as UserName,AM.PI,
CASE WHEN Q.Id=54881 THEN 'Comments'
WHEN Q.Id=54883	THEN 'Comments1'
WHEN Q.Id=54885	THEN 'Comments2'
WHEN Q.Id=54888	THEN 'Comments3'
WHEN Q.Id=54890	THEN 'Comments4'
WHEN Q.Id=54892	THEN 'Comments5'
WHEN Q.Id=54894	THEN 'Comments6'
WHEN Q.Id=54896	THEN 'Comments7'
WHEN Q.Id=54898	THEN 'Comments8'
WHEN Q.Id=54900	THEN 'Comments9'
WHEN Q.Id=54902	THEN 'Comments10'
WHEN Q.Id=54904	THEN 'Comments11'
WHEN Q.Id=54906	THEN 'Comments12'
WHEN Q.Id=54908	THEN 'Comments13'
WHEN Q.Id=54907 THEN 'Do you have any chronic diseases?' ELSE Q.Questiontitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2783
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2782
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2780
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2781
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=6353 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (54880,54881,54882,54883,54884,54885,54887,54888,56240,54889,54890,54891,54892,54893,54894,54895,54896,54897,54898,54899,54900,54901,54902,54903,54904,54905,54906,54907,54908,54910,69603,54911)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Have you been in contact with someone who has travelled internationally?],[Comments],[Have you been in contact with a laboratory to confirm a case of COVID-19?],[Comments1],[Have you been in contact with a person that is a confirmed COVID-19 case or is currently awaiting test results for COVID-19?],[Comments2],[Temperature of 37.3°C or above],[Comments3],[Employee temperature °C],[Loss of smell or taste],[Comments4],[Flu-like symptoms or coughing],[Comments5],[Sore throat or diarrhea],[Comments6],[Shortness of breath],[Comments7],[Pneumonia],[Comments8],[Muscle pain or chills],[Comments9],[Headaches or vomiting],[Comments10],[Redness of eyes],[Comments11],[Fatigue, weakness, or tiredness],[Comments12],[Do you have any chronic diseases?],[Comments13],[Employee signature],[Security name],[Date]
))p

UNION ALL

SELECT 'Visitor Screening' AS [Type],CapturedDate,ReferenceNo,UserName,p.PI,CustomerName,CustomerMobile,CustomerEmail,
[Full Name],[Vistor mobile number],[Address],[Identity Number],[Company Name],[Vehicle Registration],[Time in],
NULL AS [Have you been in contact with someone who has travelled internationally?],NULL AS [Comments],NULL AS [Have you been in contact with a laboratory to confirm a case of COVID-19?],NULL AS [Comments1],NULL AS [Have you been in contact with a person that is a confirmed COVID-19 case or is currently awaiting test results for COVID-19?],NULL AS [Comments2],
[Temperature of 37.3 °C or above],NULL AS [Comments3],[Temperature (°C)],[Loss of smell or taste],[Comments4],[Flu-like symptoms or coughing],[Comments6],[Sore throat or diarrhea],[Comments5],[Shortness of breath],[Comments12],[Pneumonia],[Comments7],[Muscle pains or aches],[Comments8],[Headache or vomiting],[Comments9],[Redness of eyes],[Comments10],[Fatigue, weakness, or tiredness],[Comments11],NULL AS [Do you have any chronic diseases?],NULL AS [Comments13],[Reason for visit],
IIF([Visitor Signature]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Visitor Signature])) AS [Visitor Signature],[Security name],[Date]
FROM
(
SELECT
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,u.name as UserName,AM.PI,
CASE WHEN Q.Id=69585 THEN 'Comments4'
WHEN Q.Id=69587	THEN 'Comments5'
WHEN Q.Id=69589	THEN 'Comments6'
WHEN Q.Id=69593	THEN 'Comments7'
WHEN Q.Id=69595	THEN 'Comments8'
WHEN Q.Id=69597	THEN 'Comments9'
WHEN Q.Id=69599	THEN 'Comments10'
WHEN Q.Id=69601	THEN 'Comments11'
WHEN q.Id=71296 THEN 'Comments12' ELSE Q.Questiontitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2783
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2782
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2780
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2781
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=6359 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (54982,54983,56237,54984,54985,54986,54987,54989,56239,54990,69584,69585,69586,69587,69588,69589,69592,69593,69594,69595,69596,69597,69598,69599,69600,69601,54991,54992,56238,71295,71296)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Date],[Full Name],[Vistor mobile number],[Address],[Identity Number],[Company Name],[Vehicle Registration],[Time in],[Temperature of 37.3 °C or above],[Temperature (°C)],[Loss of smell or taste],[Comments4],[Sore throat or diarrhea],[Comments5],[Shortness of breath],[Comments12],[Flu-like symptoms or coughing],[Comments6],[Pneumonia],[Comments7],[Muscle pains or aches],[Comments8],[Headache or vomiting],[Comments9],[Redness of eyes],[Comments10],[Fatigue, weakness, or tiredness],[Comments11],[Reason for visit],[Visitor Signature],[Security name]
))p
)AA

LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,ResponseNo,
[Time out],[Is employee's temperature above 37.5 °C],[Temperature reading]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=6353 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (52861,52862,52863)
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Time out],[Is employee's temperature above 37.5 °C],[Temperature reading]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

