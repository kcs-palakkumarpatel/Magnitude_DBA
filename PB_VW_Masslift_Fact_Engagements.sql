


CREATE view [dbo].[PB_VW_Masslift_Fact_Engagements]
as

select X.*,Y.CapturedDate as ResponseDate,
Y.Name as CustomerName,Y.Surname as CustomerSurname,
Y.Company as CustomeCompany,
Y.Email as CustomerEmail,Y.Mobile as CustomerMobile,
Y.[Did we understand ],
Y.[If no, why? ],
Y.[Happy Service ] from(
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
Customer,
[Address],
[Agreed Next Steps],
[Area:],
[Client was interested in],
[Company],
[Email],
[Full Name],
[Is this a hot prospect?],
[If a hot prospect, why?],
[what is the current fleet],
[If other, please elaborate],
[If yes, what price point will get them over the link],
[The fit for Masslift],
[Mast:],
[How did you get on?],
[Perception of the meeting],
[Position of the person you met with],
[Today you met with],
[Mobile],
[Next target date],
[Have you spotted any potential opportunities?],
[Price (has this been discussed)],
[Price (Rands)],
[If yes, who must send quote?],
[Resistance],
[Send Quote],
[Specification of the equipment],
[Time Taken:],
[Type of quote],
[Unit:],
[Value of potential opportunity (ZAR)],
[If yes, what is the opportunity],
[What transpired in the meeting?]

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.QuestionTitle as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude, CD.detail as Customer


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 and EG.Id =3929  
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
Where --(G.Id=463 and EG.Id =3929 and 
u.id not in (3722,3973)
--ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

--and Q.id in(33325,33803,34674,30842,30844,31341,32877,31342,33320,30848,31344,33318,33319,32168,30849,33317,31346,31347,31343,30854,30855,30856,30857,31348,32401,30864,30861,30862,30863,31351,
--31350,30866,30867,30868)



) S
Pivot (
Max(Answer)
For  Question In (
[Address],
[Agreed Next Steps],
[Area:],
[Client was interested in],
[Company],
[Email],
[Full Name],
[Is this a hot prospect?],
[If a hot prospect, why?],
[what is the current fleet],
[If other, please elaborate],
[If yes, what price point will get them over the link],
[The fit for Masslift],
[Mast:],
[How did you get on?],
[Perception of the meeting],
[Position of the person you met with],
[Today you met with],
[Mobile],
[Next target date],
[Have you spotted any potential opportunities?],
[Price (has this been discussed)],
[Price (Rands)],
[If yes, who must send quote?],
[Resistance],
[Send Quote],
[Specification of the equipment],
[Time Taken:],
[Type of quote],
[Unit:],
[Value of potential opportunity (ZAR)],
[If yes, what is the opportunity],
[What transpired in the meeting?]

))P

)X
left outer join (
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
Name,Surname,
Company,
Email,Mobile,
[Did we understand ],
[If no, why? ],
[Happy Service ],
SeenClientAnswerMasterId

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenClientAnswerMasterId,
A.Detail as Answer
,Q.ShortName as Question ,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2843
) as Company,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2842
) as Email,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2841
) as Mobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2839
) as Name,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as Surname,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 and EG.Id =3929
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
/*Where (G.Id=463 and EG.Id =3929
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(20807,18685,19054)*/



) S
Pivot (
Max(Answer)
For  Question In (
[Did we understand ],
[If no, why? ],
[Happy Service ]

))P


)Y on X.ReferenceNo=Y.SeenClientAnswerMasterId
