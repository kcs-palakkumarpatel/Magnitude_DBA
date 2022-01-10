CREATE VIEW dbo.PB_VW_UCT_Covid19 AS

Select AA.EstablishmentName,
	   AA.ReferenceNo,
       AA.CreatedOn,
	   AA.SubmitUser,
	   AA.IsResolved,
       AA.ResponsibleUser,
       AA.Mobile,
       AA.Email,
       AA.[Group],
       AA.[Group Name],
       AA.[Student ID number],
	   CONCAT(AA.ResponsibleUser,AA.[Student ID number]) AS [UID],
       BB.ResponseDate,
	   CAST(BB.ResponseDate AS DATE) AS [Response Date],
       BB.ResponseNo,
       BB.PI,
       BB.UserName,
       BB.UserEmail,
       BB.[Site of work],
       BB.Fever,
       BB.Cough,
       BB.[Sore Throat],
       BB.[Breath Shortness],
       BB.[Smell / taste Lost],
       BB.[Diarrhoea/ Nausea],
       BB.Longitude,
       BB.Latitude 
	   FROM
(select E.EstablishmentName,
AM.id as ReferenceNo,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CreatedOn,u.Name AS SubmitUser,AM.IsResolved,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4347
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4348
) as ResponsibleUser,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4349
) as Mobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4350
) as Email,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4351
) as [Group],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4352
) as [Group Name],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4353
) as [Student ID number]
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=655 and EG.Id=7205
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
LEFT JOIN dbo.AppUser u ON u.Id = AM.CreatedBy
left outer join SeenclientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)AA

LEFT JOIN 
(
select 
ResponseDate,ResponseNo,SeenClientAnswerMasterId,P.PI,P.UserName,P.UserEmail,
[Site of work],[Fever],[Cough],[Sore Throat],[Breath Shortness],[Smell / taste Lost],[Diarrhoea/ Nausea]
,Longitude,Latitude
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseNo,
AM.SeenClientAnswerMasterId,AM.PI,
A.Detail as Answer,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4347
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4348
) as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4350
) as UserEmail
,Q.shortname as Question ,Am.Longitude,Am.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=655 and EG.Id=7205
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (51136,51137,51138,51139,51140,51141,51142)
left Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
left outer join SeenclientAnswerChild SAC on SAC.Id=am.SeenClientAnswerChildId
)S
pivot(
Max(Answer)
For  Question In (
[Site of work],[Fever],[Cough],[Sore Throat],[Breath Shortness],[Smell / taste Lost],[Diarrhoea/ Nausea]
))P
)BB on AA.referenceno=BB.SeenclientAnswermasterid and AA.ResponsibleUser=BB.UserName AND AA.Email=BB.UserEmail

