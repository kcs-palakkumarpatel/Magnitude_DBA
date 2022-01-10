CREATE VIEW PB_VW_MascorMoxie_Coverage AS

SELECT z.Branch,
       z.CapturedDate,
       z.ReferenceNo,
       z.UserName,
       z.CustomerName,
       z.CustomerMobile,
       z.CustomerEmail,
       z.CustomerFarmName,
       z.Calltype,
       z.[Interaction Type],
       z.[Who initiated],
       z.[Meeting Perception],
       z.issues,
       z.other,
       z.[Key actions],
       IIF(x.Data='' OR x.Data IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',x.Data)) AS Attachments
	   FROM 
(SELECT REPLACE(EstablishmentName,'MM Coverage - ','') AS Branch,CapturedDate,ReferenceNo,UserName,CustomerName,CustomerMobile,CustomerEmail,CustomerFarmName,
IIF(p.Calltype IS NULL OR p.Calltype='Select one','N/A',p.Calltype) AS Calltype,
[Interaction Type],[Who initiated],[Meeting Perception],IIF([issues] IS NULL OR p.issues='Select one','N/A',p.issues) AS issues,[other],[Key actions],p.Attachments
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.ShortName as Question,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3979
) as Calltype,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3976
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3975
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3977
) as CustomerFarmName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3973
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3974
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 622 and eg.id=6983
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (64689,64690,64691,64692,64693,64695,64696)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Interaction Type],[Who initiated],[Meeting Perception],[issues],[other],[Key actions],[Attachments]
))p
)z CROSS APPLY (select Data from dbo.Split(z.Attachments,',') ) x

