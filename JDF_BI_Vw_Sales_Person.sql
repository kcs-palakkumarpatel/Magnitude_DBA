


CREATE View [dbo].[JDF_BI_Vw_Sales_Person]
As

Select Distinct U.Id as [Sales Person Id],Upper(U.[Name]) as [Sales Person]
/*,U.Email,U.Mobile, Convert(Varchar,U.CreatedOn,105) as [Join Date],
(Case when U.IsAreaManager = 1 then 'YES' Else 'NO' End) as [Area Manager] */
From AppUser U
Left Outer Join dbo.SeenClientAnswerMaster AS SAM On SAM.AppUserId = U.Id And U.IsDeleted = 0
Left Outer Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.IsDeleted = 0
Left Outer Join dbo.EstablishmentGroup EG on EG.Id = E.Establishmentgroupid And EG.IsDeleted = 0
Left Outer Join dbo.[group] G on G.Id = EG.Groupid And G.IsDeleted = 0
Where U.IsDeleted = 0  
And G.Id In (27,353,358,360,359,361)  --AFGRI & JOHN DEERE
And EG.Id in (963,2315,2661,2667,2729,2727,2731,2733)
AND SAM.IsDeleted = 0 
And U.Id Not In (363,54)


Union All

Select 100 as [Sales Person Id],'UNDEFINED' as [Sales Person]/*, '' as Email,'' as 	Mobile,'01-Jan-2010' as [Join Date],'NO' as  [Area Manager]*/
