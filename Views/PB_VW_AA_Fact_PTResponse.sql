create view PB_VW_AA_Fact_PTResponse
as 


SELECT 
EstablishmentName,
[SeenClientMasterId],
[ResponseReference],
[Response date],
cast([Response date] as date) as [Response date 1],
IsPositive,
[Form Status],
Latitude,
Longitude,
[Type of Project],
[Department],
[Submitted by],
[Recruitment requir] AS [Recruitment Students],
REVERSE(PARSENAME(REPLACE(REVERSE([Recruitment requir]), ',', '.'), 2)) AS [Recruit Student Name],
[Student Name] AS [QALA Students],
[Upload proof of re] AS [QALA Proof],
[Upload enrolment] as [QALA Enroll],
[Upload AOR] as [QALA AQR],
[Upload LA] as [QALA LA]
 FROM
(
SELECT e.EstablishmentName,scm.Id AS [SeenClientMasterId],am.Id AS [ResponseReference],DATEADD(MINUTE,am.TimeOffSet,am.CreatedOn)AS [Response date],
am.IsPositive,am.IsResolved AS [Form Status],am.Latitude,am.Longitude,
a.Detail AS answers,q.ShortName AS question
 FROM
 dbo.[Group] g 
 INNER JOIN
 dbo.EstablishmentGroup eg ON g.Id=eg.GroupId
 INNER JOIN
 dbo.Establishment e ON e.EstablishmentGroupId=eg.Id
 INNER JOIN
 dbo.AnswerMaster am ON am.EstablishmentId=e.Id
 INNER JOIN
 dbo.Answers a ON a.AnswerMasterId=am.Id
 INNER JOIN
 dbo.Questions q ON q.Id=a.QuestionId
 LEFT OUTER JOIN
 dbo.SeenClientAnswerMaster scm ON scm.Id=am.SeenClientAnswerMasterId

 WHERE g.Id=507 AND eg.Id=5227 AND q.Id IN (48715,27298,31555,27299,44391,27515,53087,33550,27514)
 AND (am.IsDeleted IS NULL OR am.IsDeleted=0)

 )S
 PIVOT(MAX(answers)
 FOR question IN
 (
 [Type of Project],
[Department],
[Submitted by],
[Recruitment requir],
[Student Name],
[Upload proof of re],
[Upload enrolment],
[Upload AOR],
[Upload LA]

 ))P 



