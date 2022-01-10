



CREATE view [dbo].[PB_VW_Fact_DFC_SM_Feedback] as

select
ReferenceNo,
SeenclientAnswerMasterid,

[Customer Target],
[Target Achieved YTD],
[Month to Date Invoiced],
[Current Order Intake Value for the month (Of new order received)],
[Is there RISK in achieving the monthly Targets],
[Any other Comments],
[Status on ALL Opportunities listed for this Customer that you Qualified],
[Name & Surname],
[Job Title],
[Mobile Number],
[Email Address]
from(
select


E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenclientAnswerMasterid,Q.Questiontitle as Question,
A.Detail as Answer



from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
--	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
Where (G.Id=366 and EG.Id =3547
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.IsRequiredInBI=1 --Q.id in (16440,16441,16442,22836,22837,22838,16447,16451,16452,16453,16454)
)S
pivot(
Max(Answer)
For  Question In (

[Customer Target],
[Target Achieved YTD],
[Month to Date Invoiced],
[Current Order Intake Value for the month (Of new order received)],
[Is there RISK in achieving the monthly Targets],
[Any other Comments],
[Status on ALL Opportunities listed for this Customer that you Qualified],
[Name & Surname],
[Job Title],
[Mobile Number],
[Email Address]
))P

