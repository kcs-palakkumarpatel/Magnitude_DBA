
create view PB_VW_UM_FactManager
as
select UserId, Name,UserName,EstablishmentId,ManagerUserId,(select Name from Appuser where Id=ManagerUserId)as ManagerName from AppManagerUserRights AMR
inner join AppUser U on AMR.UserId=U.Id where U.IsActive=1 and U.isdeleted=0
