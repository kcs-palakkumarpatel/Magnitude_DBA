-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,GetCloseLoopTemplateById>
-- Call SP    :	GetCloseLoopTemplateById
-- =============================================
CREATE PROCEDURE [dbo].[GetCloseLoopTemplateById] @Id BIGINT
AS 
    BEGIN
        SELECT  [Id] AS Id ,
                [EstablishmentGroupId] AS EstablishmentGroupId ,
                [TemplateText] AS TemplateText
        FROM    dbo.[CloseLoopTemplate]
        WHERE   [Id] = @Id
    END