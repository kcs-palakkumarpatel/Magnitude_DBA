

CREATE view [dbo].[PB_VW_Fact_Pegasus_CourtseyCall] as
/*select A.*,

B.referenceno as ResponseReference,
B.[Accurate Notes ],
B.[If no, what did we],
B.[Happy Service],
B.[Value],
B.[General Comments ]
from(*/
select * from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer

,Q.ShortName as Question ,U.id as UserId, u.name as UserName,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2929
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2913
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2912
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2910
)  + ''+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2911
) as CustomerName,
AM.Longitude, AM.Latitude

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=477 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4289
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
/*Where (G.Id=477 and EG.Id =4289
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.IsRequiredInBI=1--Q.id in (35008,33623,33624,33448,33449,33450,33557,33451,33453)*/
)S
pivot(
Max(Answer)
For  Question In (
[Company],
[Time taken],
[Opportunities ],
[If yes, please out],
[Value of additiona],
[General notes]
))P
/*)A
left outer join
(select 
ReferenceNo,
SeenclientAnswerMasterid,
[Accurate Notes ],
[If no, what did we],
[Happy Service],
[Value],
[General Comments ]
from(
select

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenclientAnswerMasterid,Q.ShortName as Question,
A.Detail as Answer


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=477 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4289
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
/*Where (G.Id=477 and EG.Id =4289
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.IsRequiredInBI=1--Q.id in(21215,21216,21376,21217,21218)*/
)S
pivot(
Max(Answer)
For  Question In (
[Accurate Notes ],
[If no, what did we],
[Happy Service],
[Value],
[General Comments ]
))P

) B on A.referenceno=B.Seenclientanswermasterid */

