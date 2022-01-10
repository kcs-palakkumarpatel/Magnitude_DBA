

CREATE view [dbo].[PB_VW_Masslift_Fact_FMD]
as
select X.* ,Y.CapturedDate as ResponseDate,
Y.Name as CustomerName,Y.Surname as CustomerSurname,
y.Company as CustomerCompany,Y.Email as CustomerEmail,Y.Mobile as CustomerMobile,
Y.[Info Correct ],
Y.[If no, please corr] from(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,

[Customer Name ],
[Contact Number ],
[POP Before Deliver],
[Special terms (MD ],
[Applicable ],
[Bank ],
[Contact Name ],
[Bank Contact Number],
[Buy back option ],
[Sourced Funding Applicable],
[Customer],
[Funding period ],
[Residual Value % ],
[Audited accounts ],
[Management account],
[Company documents ],
[Director],
[Insurance ],
[PMA rate ],
[3 year service pla],
[All in maintenance],
[Period ],
[Minimum monthly ho],
[Excess hours ],
[If other, please s],
[Standard ],
[Other ],
[Inclusions/exclusi],
[Required by],
[Short term hire un],
[Loan unit rate (Ma],
[Delivery address ],
[FMX contact name &],
[SITE contact name ],
[Other delivery req]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 and EG.Id =3999
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
/*Where (G.Id=463 and EG.Id =3999
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(31381,31382,31385,31387,31389,31390,31391,31392,31393,31395,31396,31397,31398,31399,31400,31401,31402,31403,31405,31406,31407,31408,31409,31410,31411,31413,31414,31415,31417,31418,
31419,31420,31421,31422,31423)*/


) S
Pivot (
Max(Answer)
For  Question In (
[Customer Name ],
[Contact Number ],
[POP Before Deliver],
[Special terms (MD ],
[Applicable ],
[Bank ],
[Contact Name ],
[Bank Contact Number],
[Buy back option ],
[Sourced Funding Applicable],
[Customer],
[Funding period ],
[Residual Value % ],
[Audited accounts ],
[Management account],
[Company documents ],
[Director],
[Insurance ],
[PMA rate ],
[3 year service pla],
[All in maintenance],
[Period ],
[Minimum monthly ho],
[Excess hours ],
[If other, please s],
[Standard ],
[Other ],
[Inclusions/exclusi],
[Required by],
[Short term hire un],
[Loan unit rate (Ma],
[Delivery address ],
[FMX contact name &],
[SITE contact name ],
[Other delivery req]
))P

)X 
left outer join

(
select * from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenclientAnswerMasterid,
A.Detail as Answer,Q.shortname as Question,

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
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 and EG.Id =3999
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
/*Where (G.Id=463 and EG.Id =3999
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(19086,19087)*/
) S
Pivot (
Max(Answer)
For  Question In (
[Info Correct ],
[If no, please corr])
)P

)Y on X.ReferenceNo=Y.seenclientanswermasterid



