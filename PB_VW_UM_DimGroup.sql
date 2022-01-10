Create View PB_VW_UM_DimGroup
as
Select Id, GroupName From [Group] where IsDeleted= 0
