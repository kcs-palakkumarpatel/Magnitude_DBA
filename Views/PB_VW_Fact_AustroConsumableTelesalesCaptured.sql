
CREATE view [dbo].[PB_VW_Fact_AustroConsumableTelesalesCaptured] as
with cte as(
select
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,ResolvedDate,
Longitude,Latitude,RepeatCount,
Customer,

[Full Name],
[Email ],
[Mobile],
[Company ], 
[Spoke With ],
[Interest ],
[Successful ],
--[Send Quote],
[Call Summary ],
[Type:],
[Products: ],
[Quantity:],
[Comments ]
from
(



select 


E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,
AM.Longitude,AM.Latitude ,A.RepeatCount, CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4211
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2928
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where /*(G.Id=462 and EG.Id =4211
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))  
and Q.IsRequiredInBI=1
--Q.id in (32829,32830,32831,32833,32834,32835,32836,32837,32839,32840,32841,32842,32845,32858,32859,32860)
and */U.id<>3724
) S
Pivot (
Max(Answer)
For  Question In (

[Full Name],
[Email ],
[Mobile],
[Company ],
[Spoke With ],
[Interest ],
[Successful ],
[Send Quote],
[Call Summary ],
[Type:],
[Products: ],
[Quantity:],
[Comments ]
))p
)

select 
A.EstablishmentName,A.CapturedDate,A.ReferenceNo,
A.IsPositive,A.Status,A.PI,
A.UserId,A.UserName,A.ResolvedDate,
A.Longitude,A.Latitude,A.RepeatCount,
B.Customer,

B.[Full Name],
B.[Email ],
B.[Mobile],
B.[Company ],
B.[Spoke With ],
B.[Interest ],
B.[Successful ],
--B.[Send Quote],
B.[Call Summary ],
A.[Type:],
A.[Products: ],
A.[Quantity:],
A.[Comments ]


from (select * from cte where RepeatCount<>0) A inner join (select * from cte where RepeatCount=0)B on A.ReferenceNo=B.ReferenceNo


