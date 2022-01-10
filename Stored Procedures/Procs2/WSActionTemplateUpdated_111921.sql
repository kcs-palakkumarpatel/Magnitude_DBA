
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,04 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSActionTemplateUpdated 1, '01 Jan 2015'
-- =============================================
CREATE PROCEDURE [dbo].[WSActionTemplateUpdated_111921]
    @ActivityId BIGINT ,
    @LastDate DATETIME
AS 
    BEGIN
        SELECT  COUNT(1) AS UpdatedCount, GETUTCDATE() AS ServerDate
        FROM    dbo.CloseLoopTemplate
        WHERE   EstablishmentGroupId = @ActivityId
                AND ISNULL(UpdatedOn, CreatedOn) > @LastDate
    END
