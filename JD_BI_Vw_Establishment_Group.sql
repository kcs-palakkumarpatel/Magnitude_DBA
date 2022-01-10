



CREATE View [dbo].[JD_BI_Vw_Establishment_Group]
As

Select X.*,(
Case When [Establishment Group Name] Like '%FIRST%' then 'FIRST CONTACT'
Else
(Case When [Establishment Group Name]  Like '%SALES%' then ' SALES CALL'
Else
	(Case When [Establishment Group Name]  Like '%DELIVERY%' then '  DELIVERY' End)
End)
End) as [Group Name]

From (
	Select EG.Id as [Establishment Group Id],
	IsNull(UPPER(LTRIM(RTRIM(Substring(EG.EstablishmentGroupName, patindex('%[^0-9]%',EG.EstablishmentGroupName), 100)))),'UNDEFINED') as [Establishment Group Name],
	IsNull(UPPER(EG.EstablishmentGroupType),'UNDEFINED') as [Establishment Group Type]
	From dbo.EstablishmentGroup EG 
	Left Outer Join dbo.[Group] G on G.Id = EG.GroupId  And G.IsDeleted = 0
	Where EG.Id in (961,963,965,2661,2663,2665) 
	And EG.IsDeleted = 0 
) X
Union All

Select -100 as [Establishment Group Id],	'LIKEIHOOD' as [Establishment Group Name],	'SALES' as [Establishment Group Type],'LIKEIHOOD' as [Group Name]



