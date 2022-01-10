
CREATE View [dbo].[BI_Vw_DimCompany]
As 
select 27 as [CompanyId],'AFGRI NORTH' as [Company]

Union All
select -1001 as [CompanyId],'AFGRI SOUTH' as [Company]


