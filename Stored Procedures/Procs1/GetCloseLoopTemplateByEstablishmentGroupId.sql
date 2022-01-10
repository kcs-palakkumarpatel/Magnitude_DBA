-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,GetCloseLoopTemplateById>
-- Call SP    :	GetCloseLoopTemplateByEstablishmentGroupId 1
-- =============================================
CREATE PROCEDURE [dbo].[GetCloseLoopTemplateByEstablishmentGroupId]
    @EstablishmentGroupId BIGINT
AS 
    BEGIN
        SELECT  dbo.[CloseLoopTemplate].[Id] AS Id ,
                dbo.[CloseLoopTemplate].[EstablishmentGroupId] AS EstablishmentGroupId ,
                dbo.[EstablishmentGroup].EstablishmentGroupName ,
                dbo.[CloseLoopTemplate].[TemplateText] AS TemplateText
        FROM    dbo.[CloseLoopTemplate]
                INNER JOIN dbo.[EstablishmentGroup] ON dbo.[EstablishmentGroup].Id = dbo.[CloseLoopTemplate].EstablishmentGroupId
        WHERE   dbo.[CloseLoopTemplate].IsDeleted = 0
                AND dbo.[CloseLoopTemplate].[EstablishmentGroupId] = @EstablishmentGroupId
    END