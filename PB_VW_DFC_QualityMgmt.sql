CREATE VIEW PB_VW_DFC_QualityMgmt AS

SELECT z.ResponseDate,
       z.ResponseNo,
	   z.IsResolved,
       z.[Company Name],
       z.Name,
       z.Surname,
       z.[Mobile number],
       z.Email,
       z.Role,
       z.[1.Original purchase order number],
       --z.[2. DFC Original delivery note],
	   IIF(x.Data='' OR x.Data IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',x.Data)) AS [2. DFC Original delivery note],
       z.[Do you want to return these valves?],
       --z.[Select from the below which product category this falls under],
	   y.Data AS [Select from the below which product category this falls under],
       z.[Provide a description of the Quality Control you are raising],
       --z.[Upload a picture of the issues],
	   IIF(w.Data='' OR w.Data IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',w.Data)) AS [Upload a picture of the issues]
	   FROM 
(select CAST(ResponseDate AS DATE) AS ResponseDate,ResponseNo,P.IsResolved,
[Company Name],[Name],[Surname],[Mobile number],[Email],[Role],[1.Original purchase order number],[2. DFC Original delivery note],[Do you want to return these valves?],[Select from the below which product category this falls under],[Provide a description of the Quality Control you are raising],[Upload a picture of the issues]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,am.IsResolved,
a.Detail as Answer,q.Questiontitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 366 and eg.id=7397
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (54797,53485,53486,53487,53488,53490,53881,53493,53494,53808,53497,53498,53496)
) s
pivot(
Max(Answer)
For  Question In (
[Company Name],[Name],[Surname],[Mobile number],[Email],[Role],[1.Original purchase order number],[2. DFC Original delivery note],[Do you want to return these valves?],[Select from the below which product category this falls under],[Provide a description of the Quality Control you are raising],[Upload a picture of the issues]
))P
)z 
CROSS APPLY (select Data from dbo.Split(z.[2. DFC Original delivery note],',') ) x
CROSS APPLY (select Data from dbo.Split(z.[Select from the below which product category this falls under],',') ) y
CROSS APPLY (select Data from dbo.Split(z.[Upload a picture of the issues],',') ) w

