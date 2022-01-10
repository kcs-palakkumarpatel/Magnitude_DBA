


CREATE view [dbo].[PB_VW_Masslift_Dim_Company]
as
select Distinct Company From(


select distinct
CD.Detail as Company
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3943 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0  and isnull(AM.IsDisabled,0)=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843 and CD.Detail is not null
/*Where (G.Id=463 and EG.Id =3943
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and CD.Detail is not null */

union all
select
distinct
A.Detail as Company



from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3961
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0  and isnull(AM.IsDisabled,0)=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id and (A.Detail <>'' or A.detail is not NULL)
inner join SeenClientQuestions Q on Q.id=A.QuestionId and  Q.id =30902
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
/*Where (G.Id=463 and EG.Id =3961
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(30902) and (A.Detail <>'' or A.detail is not NULL)*/




union all


select distinct
CD.Detail as Company
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4031
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0  and isnull(AM.IsDisabled,0)=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843 and CD.Detail is not null
/*Where (G.Id=463 and EG.Id =4031
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and CD.Detail is not null */


union all

select distinct
CD.Detail as Company
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3929
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id  ANd isnull(AM.IsDeleted,0)=0  and isnull(AM.IsDisabled,0)=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843 and CD.Detail is not null
/*Where (G.Id=463 and EG.Id =3929
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and CD.Detail is not null */


union all


select
distinct
A.Detail as Company



from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3855
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id  ANd isnull(AM.IsDeleted,0)=0  and isnull(AM.IsDisabled,0)=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id and (A.Detail <>'' or A.detail is not NULL)
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id =32320 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
/*Where (G.Id=463 and EG.Id =3855
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id =32320 and (A.Detail <>'' or A.detail is not NULL)*/




union all


select
distinct
A.Detail as Company



from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4409
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0  and isnull(AM.IsDisabled,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id and (A.Detail <>'' or A.detail is not NULL)
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id =34569 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
/*Where (G.Id=463 and EG.Id =4409
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id =34569 and (A.Detail <>'' or A.detail is not NULL) */

)X

