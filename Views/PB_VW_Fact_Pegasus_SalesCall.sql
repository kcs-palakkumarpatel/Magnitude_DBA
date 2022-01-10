



CREATE view [dbo].[PB_VW_Fact_Pegasus_SalesCall] as

/*select A.*,
B.Referenceno as ResponseReference,
B.[Accurate Notes],
B.[If not, what did w],
B.[Value],
B.[General comments ]
from( */
select  EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude, 
CustomerCompany,
CustomerEmail,CustomerMobile,CustomerName,AccountOpenDate,
[Company ],
[Meeting Perception],
[Time Taken],
[Opening An Account],
[Additional Gaps],
[Value Of Deal],
[Any referrals],
[Referrals],
[Resistance],
[Resistance Categor],
[If other, please s],
 Split.a.value('.','varchar(100)') as [Services ],
[Met With],
[Position Met with],
[Common interests ]

from
(
select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude, 
CustomerCompany,
CustomerEmail,CustomerMobile,CustomerName,AccountOpenDate,
[Company ],
[Meeting Perception],
[Time Taken],
[Opening An Account],
[Additional Gaps],
[Value Of Deal],
[Any referrals],
[Referrals],
[Resistance],
[Resistance Categor],
[If other, please s],
CAST ('<M>' + REPLACE([Services ], ',', '</M><M>') + '</M>' AS XML) AS Split_Detail,
[Met With],
[Position Met with],
[Common interests ]


From(
select

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AO.AccountOpenDate,
A.Detail as Answer

,Q.ShortName as Question ,U.id as UserId, u.name as UserName, 
AM.Longitude ,AM.Latitude ,
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
) +' ' +
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2911
) as CustomerName


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=477 and EG.Id =4305
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
Left Outer Join (
	select sh.ReferenceNo,min(sh.StatusDateTime) as AccountOpenDate  from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join SeenClientAnswerMaster sam on sam.id=sh.ReferenceNo
inner join AppUser AU on AU.id=Sh.Userid and AU.id<>4163
Where (es.statusname Like '%Account Opened%' )
group by sh.referenceno
	) as AO on AO.ReferenceNo = Am.Id
/*Where (G.Id=477 and EG.Id =4305
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in (35007,33470,33863,33473,33474,33475,33476,33477,33479,33480,33481,33482,33483,33485,33486,33487,33488,33492,33493)*/

)S
pivot(
Max(Answer)
For  Question In (
[Company ],
[Meeting Perception],
[Time Taken],
[Opening An Account],
[Additional Gaps],
[Value Of Deal],
[Any referrals],
[Referrals],
[Resistance],
[Resistance Categor],
[If other, please s],
[Services ],
[Met With],
[Position Met with],
[Common interests ]

))P
) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a)
/*)A
left outer join
(select
ReferenceNo,
SeenclientAnswerMasterid,
[Accurate Notes],
[If not, what did w],
[Value],
[General comments ]
from(
select


E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenclientAnswerMasterid,Q.ShortName as Question,
A.Detail as Answer



from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=477 and EG.Id =4305
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
--	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
/*Where (G.Id=477 and EG.Id =4305
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(21312,21313,21314,21315)*/
)S
pivot(
Max(Answer)
For  Question In (
[Accurate Notes],
[If not, what did w],
[Value],
[General comments ]
))P

) B on A.referenceno=B.Seenclientanswermasterid */

