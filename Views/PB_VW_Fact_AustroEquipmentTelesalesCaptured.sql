


CREATE view [dbo].[PB_VW_Fact_AustroEquipmentTelesalesCaptured] as
select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude,
CustomerCompany,
CustomerEmail,CustomerMobile,CustomerName,

[Have you spoken with:],
[Was there interest?],
[In your opinion, was the cold call successful?],
[What was the client interested in?],
[Is this a Biesse callout?],
[Company name:],
[Company tier:],
[Brands presented:],
[Short feedback:],
[Long feedback:],
[What transpired during the call?]
From(
select

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer

,Q.Questiontitle as Question ,U.id as UserId, u.name as UserName, 
AM.Longitude ,AM.Latitude ,A.RepeatCount,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=4853 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1--q.id in (36612,36613,36614,36615,36616,36618,36619,36620,36621,36622,36624)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
 and U.id<>3724
)S
pivot(
Max(Answer)
For  Question In (

[Have you spoken with:],
[Was there interest?],
[In your opinion, was the cold call successful?],
[What was the client interested in?],
[Is this a Biesse callout?],
[Company name:],
[Company tier:],
[Brands presented:],
[Short feedback:],
[Long feedback:],
[What transpired during the call?]
))P


