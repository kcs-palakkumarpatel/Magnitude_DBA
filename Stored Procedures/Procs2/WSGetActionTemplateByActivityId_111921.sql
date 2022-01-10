-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetActionTemplateByActivityId 1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetActionTemplateByActivityId_111921] @ActivityId BIGINT
AS 
    BEGIN
        SELECT  Id ,
                TemplateText
        FROM    dbo.CloseLoopTemplate
        WHERE   EstablishmentGroupId = @ActivityId
                AND IsDeleted = 0
    END