CREATE View [dbo].[BI_Vw_Dim_Establishment_Town]
As
Select *,[Town Name] + ',' + Province as [Town Full Name]  from [dbo].[Establishment_Town]
union all
select -100 as [TownId], 'UNDEFINED' as [Town Name],'UNDEFINED' as [Province],0 as [Latitude],0 as [Longitude],0 as IsNorth, 'UNDEFINDED,UNDEFINDED' as [Town Full Name] 
