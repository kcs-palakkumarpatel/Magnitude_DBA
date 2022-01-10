CREATE view PB_VW_MediPost_Fact_CovidAccessControl as
SELECT EstablishmentName,[Captured Date],[Capture Reference],Latitude,
Longitude,[Form Status],IsPositive,PI,ResponsibleUser,
[Name],
[Surname],
[Mobile],
[Email],
[Company Name],
[Department],
[Employee Number],
[ID / Passport Number],
[COVID Manager / Compliance Officer],
CASE WHEN [Wearing Mask]='Yes' THEN [Wearing Mask] ELSE 'No' END AS [Wearing Mask] ,
CASE WHEN [Washed or Sanitize]='Yes' THEN [Washed or Sanitize] ELSE 'No' END AS [Washed or Sanitize],
CASE WHEN [Fever/Chills]='Yes' THEN [Fever/Chills] ELSE 'No' END AS [Fever/Chills],
REPLACE([Temperature],',','.') AS [Temperature],
CASE WHEN [Cough]='Yes' THEN [Cough] ELSE 'No' END AS [Cough],
CASE WHEN [Sore Throat]='Yes' THEN [Sore Throat] ELSE 'No' END AS [Sore Throat],
CASE WHEN [Redness of the eye]='Yes' THEN [Redness of the eye] ELSE 'No' END AS [Redness of the eye],
CASE WHEN [Breath Shortness]='Yes' THEN [Breath Shortness] ELSE 'No' END AS [Breath Shortness],
CASE WHEN [Body aches]='Yes' THEN [Body aches] ELSE 'No' END AS [Body aches],
CASE WHEN [Smell / Taste Lost]='Yes' THEN [Smell / Taste Lost] ELSE 'No' END AS [Smell / Taste Lost],
CASE WHEN [Nausea]='Yes' THEN [Nausea] ELSE 'No' END AS [Nausea],
CASE WHEN [Vomiting]='Yes' THEN [Vomiting] ELSE 'No' END AS [Vomiting],
CASE WHEN [Diarrhoea]='Yes' THEN [Diarrhoea] ELSE 'No' END AS [Diarrhoea],
CASE WHEN [Fatigue]='Yes' THEN [Fatigue] ELSE 'No' END AS [Fatigue],
CASE WHEN [Weakness or tired]='Yes' THEN [Weakness or tired] ELSE 'No' END AS [Weakness or tired],
[DATE]
FROM (
SELECT e.EstablishmentName,DATEADD(MINUTE,scm.TimeOffSet,scm.CreatedOn) AS[Captured Date],
scm.Id AS[Capture Reference],scm.Latitude,scm.Longitude,scm.IsResolved AS[Form Status],
scm.IsPositive,scm.PI,
sa.Detail AS [answers],sq.ShortName AS [questions],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(CASE WHEN scm.IsSubmittedForGroup=1 THEN SAC.ContactMasterId ELSE scm.ContactMasterId END) AND CD.IsDeleted = 0 AND CD.Detail<>'' 
AND CD.contactQuestionId=4428

)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(CASE WHEN scm.IsSubmittedForGroup=1 THEN SAC.ContactMasterId ELSE scm.ContactMasterId END) AND CD.IsDeleted = 0 AND CD.Detail<>'' 
AND CD.contactQuestionId=4429
) AS ResponsibleUser

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
LEFT OUTER JOIN 
SeenclientAnswerChild SAC ON scm.id=SAC.SeenClientAnswerMasterId

WHERE g.id=669 AND eg.Id=7353
AND (scm.IsDeleted=0 OR scm.IsDeleted IS NULL)
AND sq.id IN (69984,69985,69986,69987,69988,69989,69990,69991,69992,
69995,69996,70000,70001,70002,70003,70004,70005,70008,70009,
70010,70011,70012,70013,70014,70017)
)s

PIVOT(MAX(answers)
FOR questions IN
(

[Name],
[Surname],
[Mobile],
[Email],
[Company Name],
[Department],
[Employee Number],
[ID / Passport Number],
[COVID Manager / Compliance Officer],
[Wearing Mask],
[Washed or Sanitize],
[Fever/Chills],
[Temperature],
[Cough],
[Sore Throat],
[Redness of the eye],
[Breath Shortness],
[Body aches],
[Smell / Taste Lost],
[Nausea],
[Vomiting],
[Diarrhoea],
[Fatigue],
[Weakness or tired],
[DATE]
))P 
