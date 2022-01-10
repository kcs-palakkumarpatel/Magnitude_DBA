CREATE VIEW PB_VW_TopTurf_ComplianceAudit AS

WITH cte AS (
SELECT ResponseDate,SeenClientAnswerMasterId,ResponseNo,P.RepeatCount,
[Have all the issues been addressed and fixed?],[Action taken],[Attachments],[Why not?],[What was done?]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question,a.RepeatCount
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 667 and eg.id=7327
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (53046,53047,53048,53049,53050)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Have all the issues been addressed and fixed?],[Action taken],[Attachments],[Why not?],[What was done?]
))P
)

SELECT AA.*,
		BB.ResponseDate,
		BB.ResponseNo,
		BB.[Have all the issues been addressed and fixed?],
		BB.[Action taken],
		BB.Attachments,
		BB.[Why not?],
		BB.[What was done?]
 FROM 
(select CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.PI,
IIF(P.PI=100,'Pass','Fail') AS Result,
[Officer Appointed],
IIF([Attachment] IS NULL OR P.Attachment='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.Attachment)) AS [Attachment],
[Comments],[Manager Appointed],
IIF([Attachment1] IS NULL OR P.Attachment1='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.Attachment1)) AS [Attachment1],
[Comments1],[Furnished Dept.],
IIF([Attachment2] IS NULL OR P.Attachment2='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.Attachment2)) AS [Attachment2],
[Comments2],[Mitigate Risk],[Comments3],[Participated],[Comments4],[Policy Implemented],[Comments5],[Assessment Conduct],[Comments6],[Crisis Established],[Comments7],[Procedure Defined],[Comments8],[Following Up],[Comments9],[Encourage Employee],[Comments10],[Health Assessment],[Comments11],[Adequate WFH],[Comments12],[Operating Business],[Comments13],[Communication],[Comments14],[Public Transport],[Comments15],[Required PPE],[Comments16],[Flammables Areas],[Comments17],[Procedure to Deal],[Comments18],[Updated Records],[Comments19],[Staggering Shifts],[Comments20],[Control Measures],[Comments21],[Sanitiser Usage],[Comments22],[Hygiene Practices],[Comments23],[Access Facilities],[Comments24],[Cleanliness],[Comments25],[Scanners Disabled],[Comments26],[Posters Displayed],[Comments27],[Areas Equipped],[Comments28],[Visits Discouraged],[Comments29],[Visitors Screened],[Comments30],[Clean & Hygienic],[Comments31],[Short Health Scan],[Comments32]
From(
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.PI,
CASE 
WHEN Q.Id=69811 THEN 'Comments'
WHEN Q.Id=69814 THEN 'Comments1'
WHEN Q.Id=69817 THEN 'Comments2'
WHEN Q.Id=69819 THEN 'Comments3'
WHEN Q.Id=69821 THEN 'Comments4'
WHEN Q.Id=69823 THEN 'Comments5'
WHEN Q.Id=69825 THEN 'Comments6'
WHEN Q.Id=69827 THEN 'Comments7'
WHEN Q.Id=69829 THEN 'Comments8'
WHEN Q.Id=69831 THEN 'Comments9'
WHEN Q.Id=69833 THEN 'Comments10'
WHEN Q.Id=69835 THEN 'Comments11'
WHEN Q.Id=69838 THEN 'Comments12'
WHEN Q.Id=69840 THEN 'Comments13'
WHEN Q.Id=69842 THEN 'Comments14'
WHEN Q.Id=69844 THEN 'Comments15'
WHEN Q.Id=69846 THEN 'Comments16'
WHEN Q.Id=69849 THEN 'Comments17'
WHEN Q.Id=69851 THEN 'Comments18'
WHEN Q.Id=69853 THEN 'Comments19'
WHEN Q.Id=69855 THEN 'Comments20'
WHEN Q.Id=69857 THEN 'Comments21'
WHEN Q.Id=69860 THEN 'Comments22'
WHEN Q.Id=69862 THEN 'Comments23'
WHEN Q.Id=69864 THEN 'Comments24'
WHEN Q.Id=69866 THEN 'Comments25'
WHEN Q.Id=69868 THEN 'Comments26'
WHEN Q.Id=69870 THEN 'Comments27'
WHEN Q.Id=69872 THEN 'Comments28'
WHEN Q.Id=69875 THEN 'Comments29'
WHEN Q.Id=69877 THEN 'Comments30'
WHEN Q.Id=69879 THEN 'Comments31'
WHEN Q.Id=69881 THEN 'Comments32'
WHEN Q.Id=69810 THEN 'Attachment'
WHEN Q.Id=69813 THEN 'Attachment1'
WHEN Q.Id=69816 THEN 'Attachment2' ELSE Q.ShortName END AS Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 667 and eg.id=7327
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (69809,69810,69811,69812,69813,69814,69815,69816,69817,69818,69819,69820,69821,69822,69823,69824,69825,69826,69827,69828,69829,69830,69831,69832,69833,69834,69835,69837,69838,69839,69840,69841,69842,69843,69844,69845,69846,69848,69849,69850,69851,69852,69853,69854,69855,69856,69857,69859,69860,69861,69862,69863,69864,69865,69866,69867,69868,69869,69870,69871,69872,69874,69875,69876,69877,69878,69879,69880,69881)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Officer Appointed],[Attachment],[Comments],[Manager Appointed],[Attachment1],[Comments1],[Furnished Dept.],[Attachment2],[Comments2],[Mitigate Risk],[Comments3],[Participated],[Comments4],[Policy Implemented],[Comments5],[Assessment Conduct],[Comments6],[Crisis Established],[Comments7],[Procedure Defined],[Comments8],[Following Up],[Comments9],[Encourage Employee],[Comments10],[Health Assessment],[Comments11],[Adequate WFH],[Comments12],[Operating Business],[Comments13],[Communication],[Comments14],[Public Transport],[Comments15],[Required PPE],[Comments16],[Flammables Areas],[Comments17],[Procedure to Deal],[Comments18],[Updated Records],[Comments19],[Staggering Shifts],[Comments20],[Control Measures],[Comments21],[Sanitiser Usage],[Comments22],[Hygiene Practices],[Comments23],[Access Facilities],[Comments24],[Cleanliness],[Comments25],[Scanners Disabled],[Comments26],[Posters Displayed],[Comments27],[Areas Equipped],[Comments28],[Visits Discouraged],[Comments29],[Visitors Screened],[Comments30],[Clean & Hygienic],[Comments31],[Short Health Scan],[Comments32]
))P
)AA

LEFT JOIN 

(SELECT B.ResponseDate,
       B.SeenClientAnswerMasterId,
       B.ResponseNo,
       A.RepeatCount,
       B.[Have all the issues been addressed and fixed?],
       A.[Action taken],
       IIF(A.Attachments IS NULL OR A.Attachments='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',A.Attachments)) AS [Attachments],
       B.[Why not?],
       B.[What was done?] 
	   FROM (SELECT * FROM cte WHERE RepeatCount <> 0)A RIGHT OUTER JOIN (SELECT * FROM cte WHERE RepeatCount = 0)B ON A.ResponseNo = B.ResponseNo
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

