
Create View PB_VW_UM_FactChats
as
select Isnull(U.Id,0) As UserId,U.username as Username,Isnull(CLA.Id,0) as Id,Isnull(G.Id,0) as GroupId, G.GroupName,Isnull(SCAM.EstablishmentId,0) as EstablishmentId,E.EstablishmentName,isnull(EG.Id,0) As ActivityId,EG.EstablishmentGroupName as Activity,CLA.CreatedOn as ChatDate from Appuser U
left Outer Join CloseLoopAction CLA On U.id=CLA.AppUserId
left outer join seenClientAnswermaster SCAM on CLA.seenclientanswermasterid=SCAM.id
left outer join Establishment E on E.id=SCAm.EstablishmentId
left outer join EstablishmentGroup EG on EG.id=E.EstablishmentGroupId
left outer join [Group] G on G.id=EG.GroupId
