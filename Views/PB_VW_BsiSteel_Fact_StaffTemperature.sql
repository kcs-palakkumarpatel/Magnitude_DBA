Create view PB_VW_BsiSteel_Fact_StaffTemperature as

SELECT DISTINCT *,'Staff Temperature' as Activity FROM (
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

WHERE g.id=657 AND eg.Id =7315
AND (scm.IsDeleted=0 OR scm.IsDeleted IS NULL)
AND sq.id IN (69551,69552,69553,69554,69549,69550)
)s

PIVOT(MAX(answers)
FOR questions IN
(
[Name],
[Surname],
[Mobile],
[Email],
[Temperature],
[Fever]

))P




