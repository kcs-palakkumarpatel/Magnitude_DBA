Create View [dbo].[JD_BI_Vw_DimCompany]
As 
Select Id as [CompanyId],GroupName as [Company]
From [dbo].[Group]  where Id =353
Union All
select 27 as [CompanyId],'AFGRI NORTH' as [Company]
Union All
select -1001 as [CompanyId],'AFGRI SOUTH' as [Company]

