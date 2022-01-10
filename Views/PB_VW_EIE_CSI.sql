CREATE VIEW dbo.PB_VW_EIE_CSI AS

SELECT IIF(BB.[Business unit] IS NULL OR BB.[Business unit]='','N/A',BB.[Business unit]) AS [Business unit],AA.* FROM 
(SELECT RTRIM(LTRIM(Substring(EstablishmentName, Charindex('- ',EstablishmentName)+1, LEN(EstablishmentName)))) AS Branch,
REPLACE(SUBSTRING(EstablishmentName,1,Charindex('- ',EstablishmentName)-1),'TF','EIE') AS Surveytype,
EstablishmentName,
CapturedDate,
ReferenceNo,
Refno,
IsPositive,
Status,
UserName,
[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],
ISNULL(CustomerCompany,'N/A') AS CustomerCompany,
CustomerEmail,
CustomerMobile,
CustomerName, 
Department,
[M-Technician name],
[M-WIP number],
LEFT([M-Quotation],CHARINDEX('-',[M-Quotation])-1) AS [M-Quotation],
LEFT([M-Product Support],CHARINDEX('-',[M-Product Support])-1) AS [M-Product Support],
LEFT([M-Response time],CHARINDEX('-',[M-Response time])-1) AS [M-Response time],
LEFT([M-Resolution],CHARINDEX('-',[M-Resolution])-1) AS [M-Resolution],
[M-Additional Work],
[M-Work comments],
LEFT([M-Service Quality/Referral],CHARINDEX('-',[M-Service Quality/Referral])-1) AS [M-Service Quality/Referral],
[M-Customer comments],
[Parts Salesperson],
[P-Invoice number],
[P-WIP number],
LEFT([P-Quotation],CHARINDEX('-',[P-Quotation])-1) AS [P-Quotation],
LEFT([P-Availability],CHARINDEX('-',[P-Availability])-1) AS [P-Availability],
LEFT([P-Product knowledge],CHARINDEX('-',[P-Product knowledge])-1) AS [P-Product knowledge],
LEFT([P-Invoicing & POD],CHARINDEX('-',[P-Invoicing & POD])-1) AS [P-Invoicing & POD],
[P-Service Quality/Referral],
[P-Customer comments],
[Rental Controller],
[R-Invoice number],
[R-Agreement number],
LEFT([R-Quotation],CHARINDEX('-',[R-Quotation])-1) AS [R-Quotation],
LEFT([R-Delivery],CHARINDEX('-',[R-Delivery])-1) AS [R-Delivery],
LEFT([R-Customer service],CHARINDEX('-',[R-Customer service])-1) AS [R-Customer service],
LEFT([R-Product experience],CHARINDEX('-',[R-Product experience])-1) AS [R-Product experience],
LEFT([R-Invoicing],CHARINDEX('-',[R-Invoicing])-1) AS [R-Invoicing],
[R-Referral],
[R-Customer comments],
[SL-Type of sales],
[Salesperson],
[SL-Invoiced number],
LEFT([SL-Product Knowledge],CHARINDEX('-',[SL-Product Knowledge])-1) AS [SL-Product Knowledge],
LEFT([SL-Response time],CHARINDEX('-',[SL-Response time])-1) AS [SL-Response time],
LEFT([SL-Proposal],CHARINDEX('-',[SL-Proposal])-1) AS [SL-Proposal],
LEFT([SL-Deliveries and Hand over],CHARINDEX('-',[SL-Deliveries and Hand over])-1) AS [SL-Deliveries and Hand over],
LEFT([SL-Customer buying criteria],CHARINDEX('-',[SL-Customer buying criteria])-1) AS [SL-Customer buying criteria],
[SL-What persuaded you],
[SL-Customer comment],
LEFT([SL-Referral],CHARINDEX('-',[SL-Referral])-1) AS [SL-Referral],
[SL-Customer comments],
[Ser-Technician name],
[Ser-WIP number],
LEFT([Ser-Quotation],CHARINDEX('-',[Ser-Quotation])-1) AS [Ser-Quotation],
LEFT([Ser-Response time],CHARINDEX('-',[Ser-Response time])-1) AS [Ser-Response time],
LEFT([Ser-Resolution],CHARINDEX('-',[Ser-Resolution])-1) AS [Ser-Resolution],
[Ser-Additional Work],
[Ser-Work comments],
LEFT([Ser-Product Support],CHARINDEX('-',[Ser-Product Support])-1) AS [Ser-Product Support],
LEFT([Ser-Service Quality/Referral],CHARINDEX('-',[Ser-Service Quality/Referral])-1) AS [Ser-Service Quality/Referral],
[Ser-Customer comments]
FROM 
(
SELECT EstablishmentName,CapturedDate,ReferenceNo,0 AS Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Maintenance' AS Department,[M-Technician name],[M-WIP number],[M-Quotation],[M-Product Support],[M-Response time],[M-Resolution],[M-Additional Work],[M-Work comments],[M-Service Quality/Referral],[M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS [P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS [R-Referral],NULL AS [R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer,
--Q.Id AS QueId
--,Q.Questiontitle as Question,
CASE WHEN Q.Id=44634 THEN 'M-Technician name'
WHEN Q.Id=44633 THEN 'M-WIP number'
WHEN Q.Id=44859 THEN 'M-Quotation'
WHEN Q.Id=44860 THEN 'M-Product Support'
WHEN Q.Id=44861 THEN 'M-Response time'
WHEN Q.Id=44862 THEN 'M-Resolution'
WHEN Q.Id=44602 THEN 'M-Additional Work'
WHEN Q.Id=45440 THEN 'M-Work comments'
WHEN Q.Id=44863 THEN 'M-Service Quality/Referral'
WHEN Q.Id=44193 THEN 'M-Customer comments' END AS Question1
,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5441 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id AND A.Detail!=''
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44634,44633,44859,44860,44861,44862,44602,45440,44863,44193) 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName!='TF CSI'
)S
pivot(
Max(Answer)
For  Question1 In (
[M-Technician name],[M-WIP number],[M-Quotation],[M-Product Support],[M-Response time],[M-Resolution],[M-Additional Work],[M-Work comments],[M-Service Quality/Referral],[M-Customer comments]
))P

UNION ALL

SELECT EstablishmentName,CapturedDate,ReferenceNo,0 AS Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Parts' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS [M-Additional Work],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],[Parts Salesperson],[P-Invoice number], [P-WIP number], [P-Quotation], [P-Availability], [P-Product knowledge], [P-Invoicing & POD], [P-Service Quality/Referral], [P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS [R-Referral],NULL AS [R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer,
--Q.Id AS QueId
--,Q.Questiontitle as Question,
CASE WHEN Q.Id=44636 THEN 'P-Invoice number'
WHEN Q.Id=44635 THEN 'P-WIP number'
WHEN Q.Id=44864 THEN 'P-Quotation'
WHEN Q.Id=44865 THEN 'P-Availability'
WHEN Q.Id=44866 THEN 'P-Product knowledge'
WHEN Q.Id=44867 THEN 'P-Invoicing & POD'
WHEN Q.Id=44603 THEN 'P-Service Quality/Referral'
WHEN Q.Id=44209 THEN 'P-Customer comments' 
WHEN Q.Id=50046 THEN 'Parts Salesperson' END AS Question1
,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5441 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id AND A.Detail!=''
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44636,44635,44864,44865,44866,44867,44603,44209,50046) 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName!='TF CSI'
)S
pivot(
Max(Answer)
For  Question1 In (
[Parts Salesperson],[P-Invoice number],[P-WIP number],[P-Quotation],[P-Availability],[P-Product knowledge],[P-Invoicing & POD],[P-Service Quality/Referral],[P-Customer comments]
))P

UNION ALL

SELECT EstablishmentName,CapturedDate,ReferenceNo,0 AS Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Rental' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS [M-Additional Work],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS [P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],[Rental Controller],[R-Invoice number],[R-Agreement number],[R-Quotation],[R-Delivery],[R-Customer service],[R-Product experience],[R-Invoicing],[R-Referral],[R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer,
--Q.Id AS QueId
--,Q.Questiontitle as Question,
CASE WHEN Q.Id=44637 THEN 'R-Invoice number'
WHEN Q.Id=44641 THEN 'R-Agreement number'
WHEN Q.Id=44868 THEN 'R-Quotation'
WHEN Q.Id=44869 THEN 'R-Delivery'
WHEN Q.Id=44870 THEN 'R-Customer service'
WHEN Q.Id=44871 THEN 'R-Product experience'
WHEN Q.Id=44872 THEN 'R-Invoicing'
WHEN Q.Id=44604 THEN 'R-Referral'
WHEN Q.Id=44207 THEN 'R-Customer comments' 
WHEN Q.Id=50048 THEN 'Rental Controller' END AS Question1
,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5441 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id AND A.Detail!='' AND A.Detail!='0'
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44637,44641,44868,44869,44870,44871,44872,44604,44207,50048) 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName!='TF CSI'
)S
pivot(
Max(Answer)
For  Question1 In (
[Rental Controller],[R-Invoice number],[R-Agreement number],[R-Quotation],[R-Delivery],[R-Customer service],[R-Product experience],[R-Invoicing],[R-Referral],[R-Customer comments]
))P

UNION ALL

SELECT EstablishmentName,CapturedDate,ReferenceNo,0 AS Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Sales' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS [M-Additional Work],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS [P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS [R-Referral],NULL AS [R-Customer comments],[SL-Type of sales],[Salesperson],[SL-Invoiced number],[SL-Product Knowledge],[SL-Response time],[SL-Proposal],[SL-Deliveries and Hand over],[SL-Customer buying criteria],[SL-What persuaded you],[SL-Customer comment],[SL-Referral],[SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer,
--Q.Id AS QueId
--,Q.Questiontitle as Question,
CASE WHEN Q.Id=44642 THEN 'SL-Type of sales'
WHEN Q.Id=44643 THEN 'SL-Invoiced number'
WHEN Q.Id=44873 THEN 'SL-Product Knowledge'
WHEN Q.Id=44874 THEN 'SL-Response time'
WHEN Q.Id=44875 THEN 'SL-Proposal'
WHEN Q.Id=44883 THEN 'SL-Deliveries and Hand over'
WHEN Q.Id=44876 THEN 'SL-Customer buying criteria'
WHEN Q.Id=46936 THEN 'SL-What persuaded you'
WHEN Q.Id=44877 THEN 'SL-Referral'
WHEN Q.Id=45532 THEN 'SL-Referral'
WHEN Q.Id=45650 THEN 'SL-Customer comment'
WHEN Q.Id=44216 THEN 'SL-Customer comments' 
WHEN Q.Id=50047 THEN 'Salesperson' END AS Question1
,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5441 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id AND A.Detail!=''
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44642,44643,44873,44874,44875,44883,44876,44877,45532,44216,45650,46936,50047) 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName!='TF CSI'
)S
pivot(
Max(Answer)
For  Question1 In (
[SL-Type of sales],[Salesperson],[SL-Invoiced number],[SL-Product Knowledge],[SL-Response time],[SL-Proposal],[SL-Deliveries and Hand over],[SL-Customer buying criteria],[SL-What persuaded you],[SL-Customer comment],[SL-Referral],[SL-Customer comments]
))P

UNION ALL

SELECT EstablishmentName,CapturedDate,ReferenceNo,0 AS Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Service' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS [M-Additional Work],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS [P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS [R-Referral],NULL AS [R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],[Ser-Technician name],[Ser-WIP number],[Ser-Quotation],[Ser-Response time],[Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],[Ser-Product Support],[Ser-Service Quality/Referral],[Ser-Customer comments]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer,
--Q.Id AS QueId
--,Q.Questiontitle as Question,
CASE WHEN Q.Id=44640 THEN 'Ser-Technician name'
WHEN Q.Id=44639 THEN 'Ser-WIP number'
WHEN Q.Id=44878 THEN 'Ser-Quotation'
WHEN Q.Id=44879 THEN 'Ser-Response time'
WHEN Q.Id=44880 THEN 'Ser-Resolution'
WHEN Q.Id=44881 THEN 'Ser-Product Support'
WHEN Q.Id=44882 THEN 'Ser-Service Quality/Referral'
WHEN Q.Id=44224 THEN 'Ser-Customer comments' END AS Question1
,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5441 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id AND A.Detail!=''
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44640,44639,44878,44879,44880,44881,44882,44224) 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName!='TF CSI'
)S
pivot(
Max(Answer)
For  Question1 In (
[Ser-Technician name],[Ser-WIP number],[Ser-Quotation],[Ser-Response time],[Ser-Resolution],[Ser-Product Support],[Ser-Service Quality/Referral],[Ser-Customer comments]
))P

UNION ALL

select EstablishmentName,CapturedDate,ReferenceNo,Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Maintenance' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],[M-Quotation],[M-Product Support],[M-Response time],[M-Resolution],[M-Additional Work],[M-Work comments],[M-Service Quality/Referral],[M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS[P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS[R-Referral],NULL AS [R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
from (
select 
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as CapturedDate,cam.Id as ReferenceNo,am.Id AS Refno,
am.IsPositive,am.IsResolved as Status,
a.Detail as Answer,u.name as UserName,
CASE WHEN q.id=29860 THEN 'M-Quotation'
WHEN q.id=29861 THEN 'M-Product Support'
WHEN q.id=29862 THEN 'M-Response time'
WHEN q.id=29863 THEN 'M-Resolution'
WHEN q.id=29822 THEN 'M-Additional Work'
WHEN q.id=29823 THEN 'M-Work comments'
WHEN q.id=30538 THEN 'M-Customer comments'
WHEN q.id=29864 THEN 'M-Service Quality/Referral' END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5497 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (29860,29861,29862,29863,29822,29823,29864,30538)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName LIKE '%-%'
) s
pivot(
Max(Answer)
For  Question In (
[M-Additional Work],[M-Work comments],[M-Customer comments],[M-Quotation],[M-Product Support],[M-Response time],[M-Resolution],[M-Service Quality/Referral]
))P

/*Union All Rental activity*/
UNION ALL

select EstablishmentName,CapturedDate,ReferenceNo,Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Rental' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS[M-AdditionalWork],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS[P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],[Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],[R-Quotation],[R-Delivery],NULL AS [R-Customer service],[R-Product experience],[R-Invoicing],[R-Referral],[R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
from (
select 
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as CapturedDate,cam.Id as ReferenceNo,am.Id AS Refno,
am.IsPositive,am.IsResolved as Status,
a.Detail as Answer,u.name as UserName,
CASE WHEN q.id=29856 THEN 'R-Quotation'
WHEN q.id=29857 THEN 'R-Delivery'
WHEN q.id=29858 THEN 'R-Product experience'
WHEN q.id=29859 THEN 'R-Invoicing'
WHEN q.id=29804 THEN 'R-Referral'
WHEN q.id=29805 THEN 'R-Customer comments' 
WHEN q.id=35431 THEN 'Rental Controller' END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5495 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (29856,29857,29858,29859,29804,29805,35431)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName LIKE '%-%'
) s
pivot(
Max(Answer)
For  Question In (
[Rental Controller],[R-Referral],[R-Customer comments],[R-Quotation],[R-Delivery],[R-Product experience],[R-Invoicing]
))P

/*Union All Parts activity*/
UNION ALL

select EstablishmentName,CapturedDate,ReferenceNo,Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Parts' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS[M-AdditionalWork],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],[Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],[P-Quotation],[P-Availability],[P-Product knowledge],[P-Invoicing & POD],[P-Service Quality/Referral],[P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS[R-Referral],NULL AS [R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
from (
select 
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as CapturedDate,cam.Id as ReferenceNo,am.Id AS Refno,
am.IsPositive,am.IsResolved as Status,
a.Detail as Answer,u.name as UserName,
CASE WHEN q.Id=29852 THEN 'P-Quotation'
WHEN q.Id=29853 THEN 'P-Availability'
WHEN q.Id=29854 THEN 'P-Product knowledge'
WHEN q.Id=29855 THEN 'P-Invoicing & POD'
WHEN q.Id=30556 THEN 'P-Invoicing & POD'
WHEN q.Id=29780 THEN 'P-Service Quality/Referral'
WHEN q.Id=29781 THEN 'P-Customer comments' 
WHEN q.Id=35429 THEN 'Parts Salesperson' END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5491 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (29852,29853,29854,29855,30556,29780,29781,35429)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName LIKE '%-%'
) s
pivot(
Max(Answer)
For  Question In (
[Parts Salesperson],[P-Service Quality/Referral],[P-Customer comments],[P-Quotation],[P-Availability],[P-Product knowledge],[P-Invoicing & POD]
))P

/*Union All Sales activity*/
UNION ALL

select EstablishmentName,CapturedDate,ReferenceNo,Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Sales' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS[M-AdditionalWork],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS[P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS[R-Referral],NULL AS [R-Customer comments],NULL AS [SL-Type of sales],[Salesperson],[SL-Invoiced number],[SL-Product Knowledge],[SL-Response time],[SL-Proposal],[SL-Deliveries and Hand over],[SL-Customer buying criteria],[SL-What persuaded you],NULL AS [SL-Customer comment],[SL-Referral],[SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
from (
select 
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as CapturedDate,cam.Id as ReferenceNo,am.Id AS Refno,
am.IsPositive,am.IsResolved as Status,
a.Detail as Answer,u.name as UserName,
CASE WHEN q.id=29848 THEN 'SL-Product Knowledge'
WHEN q.id=29849 THEN 'SL-Response time'
WHEN q.id=29850 THEN 'SL-Proposal'
WHEN q.id=29851 THEN 'SL-Deliveries and Hand over'
WHEN q.id=29750 THEN 'SL-Customer buying criteria'
WHEN q.id=30557 THEN 'SL-Customer buying criteria'
WHEN q.id=31720 THEN 'SL-What persuaded you'
WHEN q.id=29752 THEN 'SL-Referral'
WHEN q.id=30558 THEN 'SL-Referral'
WHEN q.id=31024 THEN 'SL-Invoiced number'
WHEN q.id=29753 THEN 'SL-Customer comments' 
WHEN q.id=35430 THEN 'Salesperson' END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5487 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (29848,29849,29850,29851,29750,29752,29753,30557,30558,31024,31720,35430)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName LIKE '%-%'
) s
pivot(
Max(Answer)
For  Question In (
[Salesperson],[SL-Invoiced number],[SL-Customer buying criteria],[SL-What persuaded you],[SL-Referral],[SL-Customer comments],[SL-Product Knowledge],[SL-Response time],[SL-Proposal],[SL-Deliveries and Hand over]
))P

/*Union All Service activity*/
UNION ALL

select EstablishmentName,CapturedDate,ReferenceNo,Refno,IsPositive,Status,UserName,[Home Phone],[Work Phone],CustomerNumber,[Company Physical Address],ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,
'Service' AS Department,NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS[M-AdditionalWork],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS[P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS[R-Referral],NULL AS [R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],[Ser-Quotation],[Ser-Response time],[Ser-Resolution],[Ser-Additional Work],[Ser-Work comments],[Ser-Product Support],[Ser-Service Quality/Referral],[Ser-Customer comments]
from (
select 
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as CapturedDate,cam.Id as ReferenceNo,am.Id AS Refno,
am.IsPositive,am.IsResolved as Status,
a.Detail as Answer,u.name as UserName,
CASE WHEN q.Id=29727 THEN 'Ser-Additional Work'
WHEN q.Id=29728 THEN 'Ser-Work comments'
WHEN q.Id=29733 THEN 'Ser-Customer comments'
WHEN q.Id=29843 THEN 'Ser-Quotation'
WHEN q.Id=29844 THEN 'Ser-Response time'
WHEN q.Id=29845 THEN 'Ser-Resolution'
WHEN q.Id=29846 THEN 'Ser-Product Support'
WHEN q.Id=29847 THEN 'Ser-Service Quality/Referral' END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5485 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (29843,29844,29845,29727,29728,29846,29847,29733)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId WHERE E.EstablishmentName LIKE '%-%'
) s
pivot(
Max(Answer)
For  Question In (
[Ser-Additional Work],[Ser-Work comments],[Ser-Customer comments],[Ser-Quotation],[Ser-Response time],[Ser-Resolution],[Ser-Product Support],[Ser-Service Quality/Referral]
))P

/*Unresponsiveness of Client*/
UNION ALL

SELECT e.EstablishmentName,dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as CapturedDate,cAM.Id AS ReferenceNo,-1 AS Refno,cam.IsPositive,cam.IsResolved as Status,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3257
) as [Home Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3258
) as [Work Phone],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3280
) as CustomerNumber,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3123
) as [Company Physical Address],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cAM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName,
RTRIM(LTRIM(REPLACE(LEFT(EstablishmentName, Charindex('-',EstablishmentName)-1),'TF CSI Email',''))) AS Department,
NULL AS [M-Technician name],NULL AS [M-WIP number],NULL AS [M-Quotation],NULL AS [M-Product Support],NULL AS [M-Response time],NULL AS [M-Resolution],NULL AS[M-AdditionalWork],NULL AS [M-Work comments],NULL AS [M-Service Quality/Referral],NULL AS [M-Customer comments],NULL AS [Parts Salesperson],NULL AS [P-Invoice number],NULL AS [P-WIP number],NULL AS [P-Quotation],NULL AS[P-Availability],NULL AS [P-Product knowledge],NULL AS [P-Invoicing & POD],NULL AS [P-Service Quality/Referral],NULL AS [P-Customer comments],NULL AS [Rental Controller],NULL AS [R-Invoice number],NULL AS [R-Agreement number],NULL AS [R-Quotation],NULL AS [R-Delivery],NULL AS [R-Customer service],NULL AS [R-Product experience],NULL AS [R-Invoicing],NULL AS[R-Referral],NULL AS [R-Customer comments],NULL AS [SL-Type of sales],NULL AS [Salesperson],NULL AS [SL-Invoiced number],NULL AS [SL-Product Knowledge],NULL AS [SL-Response time],NULL AS [SL-Proposal],NULL AS [SL-Deliveries and Hand over],NULL AS [SL-Customer buying criteria],NULL AS [SL-What persuaded you],NULL AS [SL-Customer comment],NULL AS [SL-Referral],NULL AS [SL-Customer comments],NULL AS [Ser-Technician name],NULL AS [Ser-WIP number],NULL AS [Ser-Quotation],NULL AS [Ser-Response time],NULL AS [Ser-Resolution],NULL AS [Ser-Additional Work],NULL AS [Ser-Work comments],NULL AS [Ser-Product Support],NULL AS [Ser-Service Quality/Referral],NULL AS [Ser-Customer comments]
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id IN (5497,5495,5491,5487,5485)
inner join Establishment e on  e.EstablishmentGroupId=eg.Id
inner join SeenClientAnswerMaster cAM on cAM.EstablishmentId=E.id ANd (cAM.IsDeleted=0 or cAM.IsDeleted=null) 
left outer join dbo.[Appuser] u on u.id=cam.CreatedBy
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId
LEFT join answermaster am on am.SeenClientAnswerMasterId=cam.Id and (am.IsDeleted=0 or am.IsDeleted=null) WHERE E.EstablishmentName LIKE '%-%' AND am.Id IS NULL

)L WHERE L.CustomerCompany<>'Magnitude' AND L.UserName<>'Toyota Forklift Admin' AND L.UserName<>'Joseph Lekorotsoana'
)AA
LEFT JOIN
(SELECT SeenClientAnswerMasterId,QuestionId,Detail AS [Business unit] FROM [SeenClientAnswers] WHERE QuestionId IN (68786,68785,68784,68782,68781,68783)
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

