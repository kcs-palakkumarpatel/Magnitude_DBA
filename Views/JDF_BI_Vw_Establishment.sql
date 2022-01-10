CREATE View [dbo].[JDF_BI_Vw_Establishment]  
As  
Select E.Id as [Establishment Id],  
Upper(IsNull(EstablishmentName,'UNDEFINED')) as [Establishment Name]  
From dbo.Establishment E  
Where E.EstablishmentGroupId In (963,2315,2661,2667,2729,2727,2731,2733)  
And E.IsDeleted = 0  
And CreatedBy Not In (363,54)  
