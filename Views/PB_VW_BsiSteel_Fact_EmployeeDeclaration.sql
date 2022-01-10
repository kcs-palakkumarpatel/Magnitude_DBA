Create view PB_VW_BsiSteel_Fact_EmployeeDeclaration as
SELECT DISTINCT X.*,Y.* 
FROM 
(
SELECT *,'Employee Declaration' as Activity,[P].[Cell] AS[Mobile] FROM (
SELECT e.EstablishmentName,scm.Id AS[ReferenceNo],scm.Latitude,scm.Longitude,scm.IsResolved AS[Form Status],
DATEADD(MINUTE,scm.TimeOffSet,scm.CreatedOn) AS[Captured Date],sa.Detail AS [answers],sq.ShortName AS [questions],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when scm.IsSubmittedForGroup=1 then SAC.ContactMasterId else scm.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4361
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when scm.IsSubmittedForGroup=1 then SAC.ContactMasterId else scm.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4362
) as ResponsibleUser,ap.Name AS [UserName]


FROM 
dbo.[Group] g
INNER JOIN
dbo.EstablishmentGroup eg ON g.Id=eg.GroupId
INNER JOIN 
dbo.Establishment e ON e.EstablishmentGroupId=eg.Id
INNER JOIN
dbo.SeenClientAnswerMaster scm ON scm.EstablishmentId=e.Id
INNER JOIN
dbo.SeenClientAnswers sa ON sa.SeenClientAnswerMasterId=scm.Id
INNER JOIN
dbo.SeenClientQuestions sq ON sq.Id=sa.QuestionId
INNER JOIN
dbo.AppUser ap ON scm.AppUserId=ap.Id
left outer join SeenclientAnswerChild SAC on scm.id=SAC.SeenClientAnswerMasterId

WHERE g.id=657 AND eg.Id =7215
AND (scm.IsDeleted=0 OR scm.IsDeleted IS NULL)
AND sq.id IN (68708,68709,68710,68711)
)s

PIVOT(MAX(answers)
FOR questions IN
(

[Name],
[Surname],
[Cell],
[Email]

))P

)X

LEFT OUTER JOIN
(
SELECT * FROM (
SELECT am.Id AS[ResponseReferenceNo],am.IsPositive,am.PI,
DATEADD(MINUTE,am.TimeOffSet,am.CreatedOn) AS [ResponseDate],am.Latitude AS[Response Lat],
am.Longitude AS[ Response Long],scm.id AS[ SeenClientMasterId],a.Detail AS[answers],q.ShortName AS[questions],
((SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN scm.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE scm.ContactMasterId END )AND CD.ContactQuestionid=4361) 
+' '+(SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN scm.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE scm.ContactMasterId END )AND CD.ContactQuestionid=4362)
) as ResponseResponsibleUser
 FROM
dbo.[Group] g
INNER JOIN
dbo.EstablishmentGroup eg ON g.Id=eg.GroupId
INNER JOIN 
dbo.Establishment e ON e.EstablishmentGroupId=eg.Id
INNER JOIN
dbo.AnswerMaster am ON e.id=am.EstablishmentId
INNER JOIN
dbo.Answers a ON a.AnswerMasterId=am.Id
INNER JOIN
dbo.Questions q ON q.id=a.QuestionId
LEFT OUTER JOIN
dbo.SeenClientAnswerMaster scm ON scm.id=am.SeenClientAnswerMasterId
LEFT OUTER JOIN 
dbo.SeenClientAnswerChild SAC ON SAC.Id = (CASE WHEN scm.IsSubmittedForGroup = 1 THEN AM.SeenClientAnswerChildId ELSE NULL END)

 WHERE g.id=657 AND eg.Id =7215
AND (am.IsDeleted=0 OR am.IsDeleted IS NULL)
AND q.id IN (51230,51231,51233,51234,51235,51236,51237,51238,51239,51240,
51241,51242,51243,51244,51245,51246,51247)

)z

PIVOT(MAX(answers)
FOR questions IN
(
[Location],
[If other],
[Fever],
[Dry Cough],
[Sore Throat],
[Headache],
[Extreme Tiredness],
[Breath Shortness],
[Aches and Pains],
[Diarrhoea],
[Nausea],
[Runny Nose],
[Repeated Shaking],
[Chills],
[Muscle Pain],
[Lost taste/smell],
[Household members]
))P

)Y ON X.[ReferenceNo]=Y.[ SeenClientMasterId]
