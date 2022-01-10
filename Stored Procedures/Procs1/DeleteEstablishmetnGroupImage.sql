
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,25 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		DeleteEstablishmetnGroupImage
-- =============================================
CREATE PROCEDURE [dbo].[DeleteEstablishmetnGroupImage]
    @EstablishmentGroupId BIGINT ,
    @Resolution NVARCHAR(50)
AS 
    BEGIN
        DELETE  FROM dbo.EstablishmentGroupImage
        WHERE   EstablishmentGroupId = @EstablishmentGroupId
                AND Resolution = @Resolution
    END