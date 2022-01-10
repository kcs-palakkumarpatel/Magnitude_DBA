
Create view PB_VW_UM_FactUserModule
as
select AppUserID,AppmoduleId,AliasName,IsSelected,AM.EstablishmentGroupId,EG.EstablishmentGroupName 
from AppUserModule AM
inner join Establishmentgroup EG on AM.establishmentgroupid=EG.Id where AM.isdeleted=0 or AM.isdeleted is null 
