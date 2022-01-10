CREATE VIEW PB_VW_StarkeAyres_Merchandising AS

SELECT DISTINCT *

From
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,ContactName,Email,MobileNumber,UserName,
[Customer group],[Customer name],[Stand Merchandised],[SM Comment],[Stock Checked ],[SC Comment],[Damaged Stock],[DS Comment],[Expired Stock],[ES Comment],[POS Implemented],[POS Comments],
IIF(x.data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',x.data)) AS [Grievance Image]

From
(SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,P.ContactName,P.Email,P.MobileNumber,P.UserName,
[Customer group],[Customer name],[Stand Merchandised],[SM Comment],[Stock Checked ],[SC Comment],[Damaged Stock],[DS Comment],[Expired Stock],[ES Comment],[POS Implemented],[POS Comments],[Grievance Image]

from(
select REPLACE(E.EstablishmentName,'SA Merchandising- ','') AS EstablishmentName,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer , u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2721

)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2722
) as ContactName,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2724
) as Email,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2723
) as MobileNumber,

CASE WHEN Q.Id =74183   THEN 'Customer group'
	 WHEN Q.Id =74188	THEN 'Customer name'
	 WHEN Q.Id =74355	then 'Stand Merchandised'
	 WHEN Q.Id =74356	then 'SM Comment'
	 WHEN Q.Id =74357	then 'Stock Checked'
	 WHEN Q.Id =74358	then 'SC Comment'
	 WHEN Q.Id =74359	then 'Damaged Stock'
	 WHEN Q.Id =74360	then 'DS Comment'
	 WHEN Q.Id =74361	then 'Expired Stock'
	 WHEN Q.Id =74362	then 'ES Comment'
	 WHEN Q.Id =74372	then 'POS Implemented'
	 WHEN Q.Id =74373	then 'POS Comments'
	 WHEN Q.Id =74363	then 'Grievance Image'
	
	 
END AS Question 

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id



Where (G.Id=438 and EG.Id =7795
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(74183,74188,74355,74356,74357,74358,74359,74360,74361,74362,74372,74373,74363)

) S
Pivot (
Max(Answer)

For  Question In (
[Customer group],[Customer name],[Stand Merchandised],[SM Comment],[Stock Checked ],[SC Comment],[Damaged Stock],[DS Comment],[Expired Stock],[ES Comment],[POS Implemented],[POS Comments],[Grievance Image]
))P 
)W CROSS APPLY (select Data from dbo.Split(W.[Grievance Image],','))x
)c 
WHERE c.UserName<>'MoxieStark Admin'

