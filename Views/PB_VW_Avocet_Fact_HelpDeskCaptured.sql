
CREATE view [dbo].[PB_VW_Avocet_Fact_HelpDeskCaptured] as
WITH cte AS (
select ResponseDate, P.[Response User],ResponseReferenceNo,RepeatCount,
SeenClientAnswerMasterId,
[4hrs SLA],
[Issues],
[What Were The Issu],
[Service Complete],
[What is Outstandin],
[Charges to],
[Onsite Service Type],
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
[Loan Serial Number],
[Comments],
[Attachments - Imag],
[Service Type],
[Machine],
[Certificate Number],
[Stock Code],
[Job | Work Done],
[Serial Number],
[Quantity],
[Unit Price],
[Total Price R],
[In case of Repair],
[Acknowledge that a],
[TECHNICIAN SIGNATU],
[Please confirm tha],
[Customer Name],
[CUSTOMER SIGNATURE],Latitude as ResponseLatitude, Longitude as ResponseLongitude from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,RepeatCount,
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

Where (G.Id=469 and EG.Id =4349 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(21627,35099,35100,35101,35102,35103,35104,35105,35106,35107,35108,35109,35110,35111,35112,35113,35114,
35115,35116,35117,35120,35118,35119,35121,35122,35123,35124,35125,35126,35127,35128,35129,35130,35131,35132)

) S
Pivot (
Max(Answer)
For  Question In (
[4hrs SLA],
[Issues],
[What Were The Issu],
[Service Complete],
[What is Outstandin],
[Charges to],
[Onsite Service Type],
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
[Loan Serial Number],
[Comments],
[Attachments - Imag],
[Service Type],
[Machine],
[Certificate Number],
[Stock Code],
[Job | Work Done],
[Serial Number],
[Quantity],
[Unit Price],
[Total Price R],
[In case of Repair],
[Acknowledge that a],
[TECHNICIAN SIGNATU],
[Please confirm tha],
[Customer Name],
[CUSTOMER SIGNATURE]

))P


)

SELECT AA.EstablishmentName,
AA.Technician,
AA.CapturedDate,
AA.ReferenceNo,
AA.IsPositive,
AA.FormStatus,
AA.UserName,
AA.[Customer/Store],
AA.[Store number],
AA.[Incident Number],
AA.[Contact Person],
AA.[Contact Number],
AA.CapturedServiceType,
AA.[Category],
AA.[Type],
AA.[Priority],
AA.[Summary - Informat],
AA.[Status],
AA.[Received/Closed by],
AA.Latitude,
AA.Longitude,
AA.ResolvedDate,
BB.ResponseDate,
BB.ResponseReferenceNo, 
BB.RepeatCount,
BB.[Response User],
BB.[4hrs SLA],
BB.[Issues],
BB.[What Were The Issu],
BB.[Service Complete],
BB.[What is Outstandin],
BB.[Charges to],
BB.[Onsite Service Type],
BB.[Verification Type],
BB.[Ref Number],
BB.[Job Complete],
BB.[Description],
BB.[How Many Pages],
BB.[Login Option],
BB.[Problem],
BB.[Resolution],
BB.[Installation Check],
BB.[Product],
BB.[Loan Serial Number],
BB.[Comments],
BB.[Attachments - Imag],
BB.[Service Type],
BB.[Machine],
BB.[Certificate Number],
BB.[Stock Code],
BB.[Job | Work Done],
BB.[Serial Number],
BB.[Quantity],
BB.[Unit Price],
BB.[Total Price R],
BB.[In case of Repair],
BB.[Acknowledge that a],
BB.[TECHNICIAN SIGNATU],
BB.[Please confirm tha],
BB.[Customer Name],
BB.[CUSTOMER SIGNATURE] ,
BB.ResponseLatitude,
BB.ResponseLongitude  FROM 
(select EstablishmentName,
Technician,
CapturedDate,ReferenceNo,
IsPositive,FormStatus,
UserName,
[Customer/Store],
[Store number],
[Incident Number],
[Contact Person],
[Contact Number],
[Service Type] as CapturedServiceType,
[Category],
[Type],
[Priority],
[Summary - Informat],
[Status],
[Received/Closed by],
Latitude,
Longitude,
ResolvedDate


from(
select E.EstablishmentName,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as FormStatus,A.RepeatCount,
A.Detail as Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,AM.Latitude,AM.Longitude,RD.ResolvedDate,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2868
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2869
) as Technician


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


Where (G.Id=469 and EG.Id =4349 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(33907,33908,33911,40271,33912,70817,33913,33914,33915,50043,50044,33923,33919,33925,55032,33927)



) S
Pivot (
Max(Answer)
For  Question In (
[Name],
[Surname],
[Customer/Store],
[Store number],
[Incident Number],
[Contact Person],
[Contact Number],
[Service Type],
[Category],
[Type],
[Priority],
[Summary - Informat],
[Status],
[Received/Closed by]

))P  
)AA

LEFT JOIN 

(SELECT B.ResponseDate, B.ResponseReferenceNo, 
A.RepeatCount,B.[Response User],
B.SeenClientAnswerMasterId,
B.[4hrs SLA],
B.[Issues],
B.[What Were The Issu],
B.[Service Complete],
B.[What is Outstandin],
B.[Charges to],
Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(B.[Onsite Service Type],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),'')))as[Onsite Service Type],
Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(B.[Verification Type],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),'')))as[Verification Type],
B.[Ref Number],
B.[Job Complete],
B.[Description],
B.[How Many Pages],
B.[Login Option],
B.[Problem],
B.[Resolution],
B.[Installation Check],
B.[Product],
B.[Loan Serial Number],
B.[Comments],
B.[Attachments - Imag],
A.[Service Type],
A.[Machine],
A.[Certificate Number],
A.[Stock Code],
A.[Job | Work Done],
A.[Serial Number],
A.[Quantity],
A.[Unit Price],
A.[Total Price R],
A.[In case of Repair],
A.[Acknowledge that a],
'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+A.[TECHNICIAN SIGNATU]as [TECHNICIAN SIGNATU],
A.[Please confirm tha],
A.[Customer Name],
'https://webapi.magnitudefb.com/MGUploadData/Feedback/'+A.[CUSTOMER SIGNATURE]as [CUSTOMER SIGNATURE] ,
B.ResponseLatitude,
B.ResponseLongitude 
        FROM 
(Select * from cte where repeatcount=0)B left outer join (Select * from cte where repeatcount<>0)A on A.ResponseReferenceNo=B.ResponseReferenceNo
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId and AA.Technician=BB.[Response User]
--where Establishmentname='SCM Helpdesk - JHB South' and Username='Palesa Matsetela'and AA.referenceno=771406
--ORDER BY 4 DESC
--where [contact number]='0787557660  012 8129'

