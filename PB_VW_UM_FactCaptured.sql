
create view PB_VW_UM_FactCaptured
as
Select Isnull(U.Id,0) As UserId,U.username as Username,Isnull(SCAM.Id,0) as Id,isnull(G.Id,0) as GroupId, G.GroupName,isnull(SCAM.EstablishmentId,0) as EstablishmentId ,E.EstablishmentName  ,isnull(EG.id,0) As ActivityId,EG.EstablishmentGroupName as Activity, SCAM.Createdon As CapturedDate  from Appuser U 
left outer join SeenClientAnswerMaster SCAM on U.id=SCAm.CreatedBy 
left outer join Establishment E on E.id=SCAm.EstablishmentId 
left outer join EstablishmentGroup EG on EG.id=E.EstablishmentGroupId 
left outer join [Group] G on  G.Id=EG.GroupId  where SCAM.IsDeleted=0 
