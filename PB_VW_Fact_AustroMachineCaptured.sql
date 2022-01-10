




CREATE View [dbo].[PB_VW_Fact_AustroMachineCaptured] as

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,ResolvedDate,
Longitude,Latitude,
[Meeting Perception],
[Opportunities],
[If yes, what is it]  as [What Opportunity],
[Resistance ],
[Resistance Type],
[If other, please s] as [Other Resistance Type],
[Application of the],
[Today you met with],
[Meeting Chemistry ],
[Meeting Summary ],
[Next steps agreed], 
[Target date for ne],
[Quote],
[Fit Requirements ],
[Explain how you pl] as [Plan],
[General Comments ],
[Quote Description ],
[New Customer],
[Company OR private],
[Company VAT No.],
[Company Registrati],
[Identification Num],
[Postal Address ],
[Delivery Address], 
[Postal Code ],
[Email Address], 
[Tel Number ],
[Fax Number],
[Website address (I] as [Web address],
[Nature of business],
[Materials Used ],
[Business Size ],
[Referred to Austro],
[Value (ZAR) ],
[Price (ZAR) ],
[Product],
[Name],
[Mobile],
[Email],
case when [Company]='' or Company is null  then customer else company end as Company,
[Industry:],
case when [Biesse Callout]='' then 'Blank' else [Biesse Callout] end as [Biesse Callout],

[Trevor Present ],
Customer
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,A.RepeatCount,
AM.Longitude,AM.Latitude, (SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
)  as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4029
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.isdeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left join SeenClientAnswerChild SAC on SAC.SeenClientAnswerMasterId=AM.id
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where /*(G.Id=462 and EG.Id =4029
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.IsRequiredInBI=1/* Q.Id in(31673,31674,31675,32307,31677,31679,31683,31685,31686,31696,31697,31698,31692,32161,31688,31689,31690,32095,32098,32101,32102,32103,32104,
32105,32106,32107,32108,32109,32110,32111,32112,32113,32114,32115,31665,31667,31668,31669,32053,33576)*/
and */U.id<>3724
union all
select EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,
IsPositive,Status,PI,
replace(Split.a.value('.','varchar(100)') ,'&amp;','&') as Answer

, Question ,UserId, UserName,ResolvedDate,RepeatCount,
Longitude,Latitude ,Customer
from (
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
CAST ('<M>' + REPLACE(replace(A.detail,'&','&amp;'), ',', '</M><M>') + '</M>' AS XML) AS Split_Detail

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,A.RepeatCount,
AM.Longitude,AM.Latitude, (SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
)  as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4029
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id in(32631,33575,31678)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left join SeenClientAnswerChild SAC on SAC.SeenClientAnswerMasterId=AM.Id
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where/* (G.Id=462 and EG.Id =4029
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.Id in(32631,33575,31678)
and */U.id<>3724
)AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 

) S
Pivot (
Max(Answer)
For  Question In (
[Meeting Perception],
[Opportunities],
[If yes, what is it] ,
[Resistance ],
[Resistance Type],
[If other, please s],
[Application of the],
[Today you met with],
[Meeting Chemistry ],
[Meeting Summary ],
[Next steps agreed], 
[Target date for ne],
[Quote],
[Fit Requirements ],
[Explain how you pl],
[General Comments ],
[Quote Description ],
[New Customer],
[Company OR private],
[Company VAT No.],
[Company Registrati],
[Identification Num],
[Postal Address ],
[Delivery Address], 
[Postal Code ],
[Email Address], 
[Tel Number ],
[Fax Number],
[Website address (I],
[Nature of business],
[Materials Used ],
[Business Size ],
[Referred to Austro],
[Value (ZAR) ],
[Price (ZAR) ],
[Product],
[Name],
[Mobile],
[Email],
[Company],
[Industry:],
[Biesse Callout],
[Trevor Present ]
))P

