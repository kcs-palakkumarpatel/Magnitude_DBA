

CREATE view [dbo].[PB_VW_Masslift_Fact_ContractExpiry]
as
/*select X.* ,Y.CapturedDate as ResponseDate,
Y.Name as CustomerName,
y.Company as CustomerCompany,Y.Email as CustomerEmail,Y.Mobile as CustomerMobile,
Y.[Alert] from(
*/


select null as EstablishmentName,CapturedDate,
Id as ReferenceNo,
 'Resolved' as Status, 
null as UserName,null as Longitude,null as Latitude,
replace([Sales Manager],'?','') as [Salesmen:],
[Contracts Manager] as [Contact manager:],
Location as[Location:],
 [Customer Name] as [Customer name:],
[Contract Type] as [Contract type:],
[Forklift Model] as [Forklift Model:],
[Serial Number] as [Serial Number:],
[Unit Location] as [Unit location:],
Agree as [Agree:],
[Current Hours] as [Current Hours:],
case when Used =1 then 'Used' when STH=1 then 'STH' when Extend=1 then 'Extend' end as [Post contract:],
 [Start date] as [Starting Date:],
[RV Due] as [RV due:],
 --[Masslift Term:],
Term as [Term:],
[Current GP]*100.00 as [Current GP%:],
Finance as [Finance :],
Maintenance as [Maintenance:],
[Line total] as [Line total:],
[Condition Report Complete] as [Condition Report Complete],
Ownership as [Ownership:],
[Finance Type] as [Finance:],
[Finance Comp.] as [Finance comp:],
[Residual %]*100.00 as [Residual %:],
Residual as [Residual (ZAR):],
[Bank Residual]as [Bank residual:],
case when [Retention %]='N/A' then  '0.00' end as [Retention %:],
case when Retention='N/A' then '0.00' end as [Retention:],
[Settlement From Bank] as [Settlement from bank:],
[Finance / Bank Settlement Comments] as [Finance/bank settlement:],
[Billing Comments] as [Billing comment:],
[Sales Comments] as [Sales comment:],
 null as[6 Month Expiry Date:],
 null as[3 Month Expiry Date:],
 null as [1 Month Expiry Date:],
[Masslift Term] as [Contract Expiry Date:] from MassliftContractExpiry
union all
select 
EstablishmentName,CapturedDate,ReferenceNo,
Status,
UserName,Longitude,Latitude,
[Salesmen:],
[Contact manager:],
[Location:],
[Customer name:],
[Contract type:],
[Forklift Model:],
[Serial Number:],
[Unit location:],
[Agree:],
[Current Hours:],
[Post contract:],
[Starting Date:],
[RV due:],
--[Masslift Term:],
[Term:],
[Current GP%:],
[Finance :],
[Maintenance:],
[Line total:],
[Condition Report Complete],
[Ownership:],
[Finance:],
[Finance comp:],
[Residual %:],
[Residual (ZAR):],
[Bank residual:],
[Retention %:],
[Retention:],
[Settlement from bank:],
[Finance/bank settlement:],
[Billing comment:],
[Sales comment:],
[6 Month Expiry Date:],
[3 Month Expiry Date:],
[1 Month Expiry Date:],
[Contract Expiry/Masslift Term Date:] as[Contract Expiry Date:]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.QuestionTitle as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4033
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
Where --(G.Id=463 and EG.Id =4033
--ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and
 U.id<>3722
and convert(date,Am.createdon,104)> convert(date,'05-09-2019',104)
--and Q.id in(
--33841,37369,31736,31737,37370,31738,31739,37371,37372,31740,37373,
--31741,37374,31742,31743,37375,31744,37376,37377,31746,37378,37379,37380,37394,37395,37396,37397,37398,37399,37400,37401,37402,36057,36058,36059,32039)



) S
Pivot (
Max(Answer)
For  Question In (

[Salesmen:],
[Contact manager:],
[Location:],
[Customer name:],
[Contract type:],
[Forklift Model:],
[Serial Number:],
[Unit location:],
[Agree:],
[Current Hours:],
[Post contract:],
[Starting Date:],
[RV due:],
[Masslift Term:],
[Term:],
[Current GP%:],
[Finance :],
[Maintenance:],
[Line total:],
[Condition Report Complete],
[Ownership:],
[Finance:],
[Finance comp:],
[Residual %:],
[Residual (ZAR):],
[Bank residual:],
[Retention %:],
[Retention:],
[Settlement from bank:],
[Finance/bank settlement:],
[Billing comment:],
[Sales comment:],
[6 Month Expiry Date:],
[3 Month Expiry Date:],
[1 Month Expiry Date:],
[Contract Expiry/Masslift Term Date:]
))P

/*)X 
left outer join

(

select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenclientAnswerMasterid,
A.Detail as Alert,

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
) +' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as Name,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
Where (G.Id=463 and EG.Id =4033
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(19296)



)Y on X.ReferenceNo=Y.seenclientanswermasterid

*/

