

CREATE View [dbo].[BI_Vw_Establishment]
As
Select E.Id as [Establishment Id],
Upper(IsNull(EstablishmentName,'UNDEFINED')) as [Establishment Name]
From dbo.Establishment E
Where E.EstablishmentGroupId in (961,963,965) 
And E.IsDeleted = 0 
And CreatedBy Not In (363,54)
