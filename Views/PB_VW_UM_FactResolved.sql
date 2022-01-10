
Create View PB_VW_UM_FactResolved
as
select Isnull(U.Id,0) As UserId,U.username as Username,Isnull(CLA.Id,0) as Id,isnull(G.Id,0) as GroupId, G.GroupName,isnull(SCAM.EstablishmentId,0) as EstablishmentId,E.EstablishmentName,isnull(EG.id,0) As ActivityId,EG.EstablishmentGroupName as Activity , CLA.CreatedOn as ResolvedDate from Appuser U
left Outer Join CloseLoopAction CLA On U.id=CLA.AppUserId
left outer join seenClientAnswermaster SCAM on CLA.seenclientanswermasterid=SCAM.id
left outer join Establishment E on E.id=SCAm.EstablishmentId 
left outer join EstablishmentGroup EG on EG.id=E.EstablishmentGroupId 
left outer join [Group] G on  G.Id=EG.GroupId Where (CLA.Conversation Like '%Resolved - Ref#%' or CLA.Conversation Like 'Resolved')
And (CLA.Conversation Not Like '%UnResolve%')
