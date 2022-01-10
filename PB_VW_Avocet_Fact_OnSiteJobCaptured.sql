
CREATE view [dbo].[PB_VW_Avocet_Fact_OnSiteJobCaptured] as

WITH cte AS (
SELECT ResponseDate,P.[Response User], ResponseReferenceNo,RepeatCount,
SeenClientAnswerMasterId,[Experience Issues],
[Issues],
[Service Complete],
[Still to do],
[Charges to],
[Onsite Service],
[Verification Type],
[Ref Number],
[Job Complete],
[Description],
[How Many Pages],
[Login Option],
[Problem],
[Resolution],
[Installation Check],
[Product],
[Loan Service Number],
[Comments],
[Service Attachment],
[In case of Repair ],
[Certificate Number],
[Service Type],
[Job / Work Done],
[Serial Number ],
[Quantity],
[Unit Price],
[Total Price],
[Machine],
[Stock Code],
[Attachments - Imag],
[Acknowledge ],
[TECHNICIAN Sign],
[Confirmation],
[CUSTOMER Signature],
[CUSTOMER NAME],Latitude as ResponseLatitude, Longitude as ResponseLongitude from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,A.RepeatCount,
Q.shortname as Question,A.Detail as Answer,
((SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE SAM.ContactMasterId END )AND CD.ContactQuestionid=2868) + ' ' +
(SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE SAM.ContactMasterId END )AND CD.ContactQuestionid=2869))AS [Response User]
,AM.Latitude,AM.Longitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN AM.SeenClientAnswerChildId ELSE NULL END)

Where (G.Id=469 and EG.Id =4089 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.id in(35426,19715,25663,25664,25981,31867,31868,31869,31881,31882,31883,31884,31885,31886,31901,31902,31903,
31887,31870,31904,25665,25666,25668,25669,25670,25671,25672,31889,35442,35443,25674,25675,25683,25684,31888)
) S
Pivot (
Max(Answer)
For  Question In (
[Experience Issues],
[Issues],
[Service Complete],
[Still to do],
[Charges to],
[Onsite Service],
[Verification Type],
[Ref Number],
[Job Complete],
[Description],
[How Many Pages],
[Login Option],
[Problem],
[Resolution],
[Installation Check],
[Product],
[Loan Service Number],
[Comments],
[Service Attachment],
[In case of Repair ],
[Certificate Number],
[Service Type],
[Job / Work Done],
[Serial Number ],
[Quantity],
[Unit Price],
[Total Price],
[Machine],
[Stock Code],
[Attachments - Imag],
[Acknowledge ],
[TECHNICIAN Sign],
[Confirmation],
[CUSTOMER Signature],
[CUSTOMER NAME]
))P
)

SELECT AA.EstablishmentName,
	   AA.[Technician],
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.IsPositive,
       AA.Status,
       AA.UserName,
       AA.[Name and Surname],
       AA.[Contact Number],
       AA.[Contact Email],
       AA.CapturedServiceType,
       AA.[Incident Reference],
       AA.[Comments | Faults ],
       AA.[Company Name],
       AA.[Store Name],
       AA.[INV No.],
       AA.Latitude,
       AA.Longitude,
       AA.ResolvedDate,
       BB.ResponseDate,
       BB.[Response User],
       BB.ResponseReferenceNo,
       BB.RepeatCount,
       BB.SeenClientAnswerMasterId,
       BB.[Experience Issues],
       BB.Issues,
       BB.[Service Complete],
       BB.[Still to do],
       BB.[Charges to],
       BB.[Onsite Service],
       BB.[Verification Type],
       BB.[Ref Number],
       BB.[Job Complete],
       BB.Description,
       BB.[How Many Pages],
       BB.[Login Option],
       BB.Problem,
       BB.Resolution,
       BB.[Installation Check],
       BB.Product,
       BB.[Loan Service Number],
       BB.Comments,
       BB.[Service Attachment],
       BB.[In case of Repair ],
       BB.[Certificate Number],
       BB.[Service Type],
       BB.[Job / Work Done],
       BB.[Serial Number ],
       BB.Quantity,
       BB.[Unit Price],
       BB.[Total Price],
       BB.Machine,
       BB.[Stock Code],
       BB.[Attachments - Imag],
       BB.[Acknowledge ],
       BB.[TECHNICIAN Sign],
       BB.Confirmation,
       BB.[CUSTOMER Signature],
       BB.[CUSTOMER NAME],
       BB.ResponseLatitude,
       BB.ResponseLongitude FROM 
(select EstablishmentName,
CapturedDate,ReferenceNo,
Technician,
IsPositive,Status,
UserName,
[Name and Surname],
[Contact Number],
[Contact Email],
[Service Type] as CapturedServiceType,
[Incident Reference],
[Comments | Faults ],
[Company Name],
[Store Name],
[INV No.],
Latitude,
Longitude,ResolvedDate
from(
select E.EstablishmentName,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,A.RepeatCount,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2868
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2869
) as Technician,
A.Detail as Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,AM.Latitude,AM.Longitude,ResolvedDate
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
	) as RD on rD.ReferenceNo = Am.Id
Where (G.Id=469 and EG.Id =4089 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(32192,32193,32194,74253,50045,38993,50216,32196,38991,32197)

) S
Pivot (
Max(Answer)
For  Question In (
[Name and Surname],
[Contact Number],
[Contact Email],
[Service Type],
[Incident Reference],
[Comments | Faults ],
[Company Name],
[Store Name],
[INV No.]
))P 
)AA

LEFT JOIN 

(SELECT B.ResponseDate,
       B.[Response User],
       B.ResponseReferenceNo,
       A.RepeatCount,
       B.SeenClientAnswerMasterId,
       B.[Experience Issues],
       B.Issues,
       B.[Service Complete],
       B.[Still to do],
       Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(B.[Charges to],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),'')))as[Charges to],
       Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(B.[Onsite Service],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),'')))as[Onsite Service],
       Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(B.[Verification Type],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),'')))as [Verification Type],
       B.[Ref Number],
       B.[Job Complete],
       B.Description,
       B.[How Many Pages],
       B.[Login Option],
       B.Problem,
       B.Resolution,
       B.[Installation Check],
       B.Product,
       B.[Loan Service Number],
       B.Comments,
       B.[Service Attachment],
       B.[In case of Repair ],
       B.[Certificate Number],
       A.[Service Type],
       A.[Job / Work Done],
       A.[Serial Number ],
       A.Quantity,
       A.[Unit Price],
       A.[Total Price],
       A.Machine,
       A.[Stock Code],
       'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+A.[Attachments - Imag] as [Attachments - Imag],
       A.[Acknowledge ],
       'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+A.[TECHNICIAN Sign]as [TECHNICIAN Sign],
       A.Confirmation,
       'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+A.[CUSTOMER Signature]as [CUSTOMER Signature],
       A.[CUSTOMER NAME],
       B.ResponseLatitude,
       B.ResponseLongitude
        FROM 
(Select * from cte where repeatcount=0)B left outer join (Select * from cte where repeatcount<>0)A on A.ResponseReferenceNo=B.ResponseReferenceNo
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId and AA.Technician=BB.[Response User]
--where AA.Referenceno=867903
--where AA.Username='Sebastien Nijs' and capturedDate>='2020-11-03 ' and establishmentname='Onsite Job - JHB South'
--order by 3 desc

