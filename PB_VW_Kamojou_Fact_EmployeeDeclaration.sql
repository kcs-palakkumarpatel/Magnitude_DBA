Create view PB_VW_Kamojou_Fact_EmployeeDeclaration as
SELECT DISTINCT X.*,Y.* 
FROM 
(
SELECT *,'Employee Declaration' as Activity,[P].[Cell] AS[Mobile] FROM (
SELECT e.EstablishmentName,scm.Id AS[ReferenceNo],scm.Latitude,scm.Longitude,scm.IsResolved AS[Form Status],
DATEADD(MINUTE,scm.TimeOffSet,scm.CreatedOn) AS[Captured Date],sa.Detail AS [answers],sq.ShortName AS [questions],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when scm.IsSubmittedForGroup=1 then SAC.ContactMasterId else scm.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4215
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when scm.IsSubmittedForGroup=1 then SAC.ContactMasterId else scm.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4216
) as ResponsibleUser


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

WHERE g.id=637 AND eg.Id =7019
AND (scm.IsDeleted=0 OR scm.IsDeleted IS NULL)
AND sq.id IN (65341,65342,65343,65344,65345,65346,65347,65348)
)s

PIVOT(MAX(answers)
FOR questions IN
(

[Name],
[Surname],
[Cell],
[Email],
[Title],
[Department],
[Employee ID],
[Address]

))P

)X

LEFT OUTER JOIN
(
SELECT * FROM (
SELECT am.Id AS[ResponseReferenceNo],am.IsPositive,am.PI,DATEADD(MINUTE,am.TimeOffSet,am.CreatedOn) AS [ResponseDate],am.Latitude AS[Response Lat],am.Longitude AS[ Response Long],scm.id AS[ SeenClientMasterId],a.Detail AS[answers],q.ShortName AS[questions],
((SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN scm.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE scm.ContactMasterId END )AND CD.ContactQuestionid=4215) 
+' '+(SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN scm.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE scm.ContactMasterId END )AND CD.ContactQuestionid=4216)
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

 WHERE g.id=637 AND eg.Id =7019
AND (am.IsDeleted=0 OR am.IsDeleted IS NULL)
AND q.id IN (48309,48310,48312,48313,48314,48315,48316,48317,48318,48319,48320,48321,48322,48323,48324,48325,48326,50679,48327)

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
[Household members],
[Temperature],
[Anything to tell]
))P

)Y ON X.[ReferenceNo]=Y.[ SeenClientMasterId]

UNION ALL
SELECT DISTINCT X.*,Y.* 
FROM 
(
SELECT *,'Supervisor Check' as Activity,P.[Mobile] AS [Cell] FROM (
SELECT e.EstablishmentName,scm.Id AS[ReferenceNo],scm.Latitude,scm.Longitude,scm.IsResolved AS[Form Status],
DATEADD(MINUTE,scm.TimeOffSet,scm.CreatedOn) AS[Captured Date],sa.Detail AS [answers],sq.ShortName AS [questions],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when scm.IsSubmittedForGroup=1 then SAC.ContactMasterId else scm.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4215
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when scm.IsSubmittedForGroup=1 then SAC.ContactMasterId else scm.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4216
) as ResponsibleUser

FROM 
dbo.[Group] g
INNER JOIN
dbo.EstablishmentGroup eg ON g.Id=eg.GroupId
INNER JOIN 
dbo.Establishment e ON e.EstablishmentGroupId=eg.Id
INNER JOIN
dbo.SeenClientAnswerMaster scm ON scm.EstablishmentId=e.Id
left outer join SeenclientAnswerChild SAC on scM.id=SAC.SeenClientAnswerMasterId
INNER JOIN
dbo.SeenClientAnswers sa ON sa.SeenClientAnswerMasterId=scm.Id
INNER JOIN
dbo.SeenClientQuestions sq ON sq.Id=sa.QuestionId
INNER JOIN
dbo.AppUser ap ON scm.AppUserId=ap.Id

WHERE g.id=637 AND eg.Id =7283
AND (scm.IsDeleted=0 OR scm.IsDeleted IS NULL)
AND sq.id IN (69307,69308,69309,69310,69311,69312,69313,69314)
)s

PIVOT(MAX(answers)
FOR questions IN
(

[Name],
[Surname],
[Mobile],
[Email],
[Title],
[Department],
[Employee ID],
[Address]

))P

)X

LEFT OUTER JOIN
(
SELECT * FROM (
SELECT am.Id AS[ResponseReferenceNo],am.IsPositive,am.PI,DATEADD(MINUTE,am.TimeOffSet,am.CreatedOn) AS [ResponseDate],am.Latitude AS[Response Lat],am.Longitude AS[ Response Long],scm.id AS[ SeenClientMasterId],a.Detail AS[answers],q.ShortName AS[questions],
((SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN scm.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE scm.ContactMasterId END )AND CD.ContactQuestionid=4215) 
+' '+(SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN scm.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE scm.ContactMasterId END )AND CD.ContactQuestionid=4216)
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

 WHERE g.id=637 AND eg.Id =7283
AND (am.IsDeleted=0 OR am.IsDeleted IS NULL)
AND q.id IN (52188,52189,52191,52192,52193,52194,52195,52196,52197,52198,52199,52200,52201,52202,52203,52204,52205,52847,52206)

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
[Household members],
[Temperature],
[Anything to tell]
))P

)Y ON X.[ReferenceNo]=Y.[ SeenClientMasterId]
