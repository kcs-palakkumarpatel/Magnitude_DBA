
Create View PB_VW_Dim_Beekman_PostStayChats as
Select CLA.AnswerMasterId as ReferenceNo,CLA.Conversation,U.Name,CLA.CreatedOn as Date
from CloseLoopAction CLA
inner join AnswerMaster SAM on CLA.answermasterid=SAM.id
inner join Establishment E on E.id=SAm.EstablishmentId
inner join EstablishmentGroup EG on EG.id=E.EstablishmentGroupId
inner join AppUser U on U.id=CLA.AppUserId
where EG.id =4801 and conversation not Like '%Resolved - Ref#%'
