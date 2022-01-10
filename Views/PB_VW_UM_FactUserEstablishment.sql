
Create view PB_VW_UM_FactUserEstablishment
 as
 
SELECT G.ID As GroupId,G.GroupName,EG.Id as EstablishmentGroupId,EG.EstablishmentGroupName, AUE.AppUserId,E.EstablishmentName,E.Id,EstablishmentType
                        FROM    [Group] G
						inner join EstablishmentGroup EG on EG.Groupid= G.Id
						inner join Establishment AS E  on E.EstablishmentGroupId=EG.Id
						left outer join dbo.AppUserEstablishment AUE ON E.id = AUE.EstablishmentId 
                        left outer join dbo.AppUser  U ON U.Id = AUE.AppUserId 
						 
                        WHERE   AUE.IsDeleted = 0 
                       and (G.IsDeleted=0 or G.IsDeleted is null)
					    and (EG.isdeleted=0 or EG.IsDeleted is null)
						and (E.IsDeleted=0 or E.IsDeleted is null)
						AND IsActive = 1

