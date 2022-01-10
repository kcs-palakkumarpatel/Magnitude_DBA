
CREATE View [dbo].[JDF_BI_Vw_DimCompany]
As

Select Id as [CompanyId],Upper(Ltrim(RTrim(Replace(GroupName,'DEMO','')))) as [Company]
From [dbo].[Group]  where Id in (27,353,358,360,359,361)
--Union All
--select 27 as [CompanyId],'AFGRI NORTH' as [Company]
--Union All
--select -1001 as [CompanyId],'AFGRI SOUTH' as [Company]
