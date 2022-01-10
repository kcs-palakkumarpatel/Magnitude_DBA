



CREATE view [dbo].[PB_VW_Masslift_Fact_SiteAssessment]
as
select X.* ,Y.CapturedDate as ResponseDate,
Y.Name as CustomerName,Y.Surname as CustomerSurname,Y.Company as CustomerCompany,Y.Email as CustomerEmail,Y.Mobile as CustomerMobile,
Y.[Correct Information],
Y.[If no, please corr] from(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,

[Mast type:],
[Height (mm)],
[Length (mm)],
[Width (mm)],
[Load centre (mm)],
[Weight (kg)],
[Stacking height (m],
[Pallet Handling (S],
[OL Mast type:],
[OL height (mm)],
[OL length (mm)],
[OL width],
[OL load centre],
[OL Weight (kg)],
[OL stacking height],
[OL Pallet Handling (S],
[Description ],
[Mast height ],
[Fork dimensions],
[Brand],
[Type ],
[Capacity ],
[Kg at ...],
[mm],
[Lost load ],
[Dead weight (kg)],
[Residual carrying ],
[Centre of gravity ],
[Applications Detai],
[Max rise (mm)],
[Max length (mm)],
[Drive through (mm)],
[Handling loads (mm],
[Narrowest drive th],
[Towing trailer etc],
[Floor / yard condi],
[Environment ],
[Max C],
[Min C],
[Specifications of ],
[Days per week],
[Shifts per day],
[Hours per shift],
[Seasonal ],
[High cycle],
[Estimated operatin],
[Operator(s)],
[On incentive ],
[Superviser ],
[Good Maintenance ],
[Customer mechanic],
[Familiar Equipment],
[Daily inspection],
[Maintenance superv],
[Kms ],
[Hrs],
[Dealer branch ],
[Dealer mechanic ]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 and EG.Id =3963
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
/*Where (G.Id=463 and EG.Id =3963
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(33862,33929,33930,33931,33932,30928,33933,30930,33861,33934,33935,33936,33937,30936,33938,30938,30939,33829,33703,30944,30945,30946,33943,33944,30949,33945,33946,33947,30955,
33948,33949,33950,33951,33952,30963,30964,30965,33953,33954,30971,33704,33705,30975,30976,30977,30978,30980,30981,30982,30984,30985,30986,30987,30988,33955,33971,30993,30994,34718,34719)
*/


) S
Pivot (
Max(Answer)
For  Question In (
[Mast type:],
[Height (mm)],
[Length (mm)],
[Width (mm)],
[Load centre (mm)],
[Weight (kg)],
[Stacking height (m],
[Pallet Handling (S],
[OL Mast type:],
[OL height (mm)],
[OL length (mm)],
[OL width],
[OL load centre],
[OL Weight (kg)],
[OL stacking height],
[OL Pallet Handling (S],
[Description ],
[Mast height ],
[Fork dimensions],
[Brand],
[Type ],
[Capacity ],
[Kg at ...],
[mm],
[Lost load ],
[Dead weight (kg)],
[Residual carrying ],
[Centre of gravity ],
[Applications Detai],
[Max rise (mm)],
[Max length (mm)],
[Drive through (mm)],
[Handling loads (mm],
[Narrowest drive th],
[Towing trailer etc],
[Floor / yard condi],
[Environment ],
[Max C],
[Min C],
[Specifications of ],
[Days per week],
[Shifts per day],
[Hours per shift],
[Seasonal ],
[High cycle],
[Estimated operatin],
[Operator(s)],
[On incentive ],
[Superviser ],
[Good Maintenance ],
[Customer mechanic],
[Familiar Equipment],
[Daily inspection],
[Maintenance superv],
[Kms ],
[Hrs],
[Dealer branch ],
[Dealer mechanic ]
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
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 and EG.Id =3963
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
/*Where (G.Id=463 and EG.Id =3963
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(18886,19055)*/
) S
Pivot (
Max(Answer)
For  Question In (
[Correct Information],
[If no, please corr])
)P

)Y on X.ReferenceNo=Y.seenclientanswermasterid

