
CREATE View [dbo].[PB_VW_Fact_AustroConsumableCaptured] as
with cte as
(
select
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,ResolvedDate,
Longitude,Latitude,RepeatCount,
Customer,
[Products Using],
[Equip. at work],
[New Customer],
[Quantity],
[Comments ],
[Product Family],
[Meeting Perception],
[Additional Gaps ],
[If yes, please out],
[Potential financia],
[Branded Products ],
[Resistance ],
[Resistance Type],
[If other, please s],
[Met With ],
[Functionality/Fit ],
--[Additional Comment],
[Outline how you wi],
[Meeting Summary ],
[Agreed Next Steps],
[Type],
--[Price (ZAR) ],
[Products],
--case when [Send Quote]='' then 'Blank' else [Send Quote] end as [Send Quote],
[Name],
[Mobile],
[Email],
[Industry:],
[Type of task:],

[Description of wor]
from
(
select 
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,
AM.Longitude,AM.Latitude,A.RepeatCount , (SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
)  as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3835
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left join SeenclientAnswerChild SAC on SAC.SeenclientAnswerMasterid=AM.Id
--left outer join ContactDetails CD on CD.contactMasterid= case when (Am.IssubmittedAM.ContactMasterid and CD.contactQuestionId=2838
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where /*(G.Id=462 and EG.Id =3835
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.IsRequiredInBI=1
--Q.id in (32567,32568,32569,32570,32572,32574,32575,32578,32577,32579,32580,32581,32587,32588,32700,30076,30087,30090,30092,30069,30071,30072,36883,33273,33210)*/
 U.id<>3724
union all
select 
EstablishmentName,CapturedDate,ReferenceNo,
SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,
replace(Split.a.value('.','varchar(100)'),'&amp;','&')  as Answer

, Question ,UserId, UserName,ResolvedDate,
Longitude,Latitude ,RepeatCount,Customer
from(
select 
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
CAST ('<M>' + REPLACE(Replace(A.Detail,'&','&amp;'), ',', '</M><M>') + '</M>' AS XML) AS Split_Detail

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,
AM.Longitude,AM.Latitude ,A.RepeatCount, (SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
)  as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3835
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in (32566,30075,32571,32573,32828,33574)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left join Seenclientanswerchild SAC on SAC.Seenclientanswermasterid=Am.id
--left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.ContactQuestionId=2838
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where /* (G.Id=462 and EG.Id =3835
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and --Q.IsRequiredInBI=1
Q.id in (32566,30075,32571,32573,32828,33574)
and */ U.id<>3724
) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 

) S
Pivot (
Max(Answer)
For  Question In (
[Products Using],
[Equip. at work],
[New Customer],
[Quantity],
[Comments ],
[Product Family],
[Meeting Perception],
[Additional Gaps ],
[If yes, please out],
[Potential financia],
[Branded Products ],
[Resistance ],
[Resistance Type],
[If other, please s],
[Met With ],
[Functionality/Fit ],
[Additional Comment],
[Outline how you wi],
[Meeting Summary ],
[Agreed Next Steps],
[Type],
[Price (ZAR) ],
[Products],
[Name],
[Mobile],
[Email],
[Industry:],
[Type of task:],
[Description of wor]
))p
)
select 
A.EstablishmentName,
A.CapturedDate,A.ReferenceNo,
A.IsPositive,A.Status,A.PI,
A.UserId,A.UserName,A.ResolvedDate,
A.Longitude,A.Latitude,A.RepeatCount,
B.Customer,
B.[Products Using],
B.[Equip. at work],
B.[New Customer],
A.[Quantity],
A.[Comments ],
B.[Product Family],
B.[Meeting Perception],
B.[Additional Gaps ],
B.[If yes, please out],
B.[Potential financia],
B.[Branded Products ],
B.[Resistance ],
B.[Resistance Type],
B.[If other, please s],
B.[Met With ],
B.[Functionality/Fit ],
--B.[Additional Comment],
B.[Outline how you wi],
B.[Meeting Summary ],
B.[Agreed Next Steps],
A.[Type],
--B.[Price (ZAR) ],
A.[Products],
B.[Name],
B.[Mobile],
B.[Email],
B.[Industry:],
B.[Type of task:],
B.[Description of wor]
from (select * from cte where RepeatCount<>0)A inner join (select * from cte where RepeatCount=0)B on A.ReferenceNo=B.ReferenceNo

