
Create View PB_VW_UM_DimActivity
as
select Id, EstablishmentGroupName as ActivityName From [EstablishmentGroup] where IsDeleted=0 and EstablishmentGroupId is not null
