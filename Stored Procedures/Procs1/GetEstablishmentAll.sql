-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 08 Jun 2015>
-- Description:	<Description,,GetEstablishmentAll>
-- Call SP    :	GetEstablishmentAll
-- =============================================
CREATE PROCEDURE [dbo].[GetEstablishmentAll]
AS 
    BEGIN
        SELECT  dbo.[Establishment].[Id] AS Id ,
                dbo.[Establishment].[GroupId] AS GroupId ,
                dbo.[Group].GroupName ,
                dbo.[Establishment].[EstablishmentGroupId] AS EstablishmentGroupId ,
                dbo.[EstablishmentGroup].EstablishmentGroupName ,
                dbo.[Establishment].[EstablishmentName] AS EstablishmentName ,
                dbo.[Establishment].[GeographicalLocation] AS GeographicalLocation ,
                dbo.[Establishment].[TimeOffSetId] AS TimeOffSetId ,
                dbo.[Establishment].[TimeOffSet] AS TimeOffSet ,
                dbo.[Establishment].[IncludedMonthlyReports] AS IncludedMonthlyReports ,
                dbo.[Establishment].[UniqueSMSKeyword] AS UniqueSMSKeyword 
        FROM    dbo.[Establishment]
                INNER JOIN dbo.[EstablishmentGroup] ON dbo.[EstablishmentGroup].Id = dbo.[Establishment].EstablishmentGroupId
                INNER JOIN dbo.[Group] ON dbo.[Group].Id = dbo.[Establishment].GroupId
        WHERE   dbo.[Establishment].IsDeleted = 0
    END