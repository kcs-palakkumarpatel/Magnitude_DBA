
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,25 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		InsertOrUpdateEstablishmentGroupImage
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateEstablishmentGroupImage]
    @EstablishmentGroupId BIGINT ,
    @Resolution NVARCHAR(50) ,
    @ImageName NVARCHAR(50)
AS 
    BEGIN
        INSERT  INTO dbo.EstablishmentGroupImage
                ( EstablishmentGroupId ,
                  Resolution ,
                  [FileName]
                )
        VALUES  ( @EstablishmentGroupId , -- EstablishmentGroupId - bigint
                  @Resolution , -- Resolution - nvarchar(50)
                  @ImageName -- FileName - nvarchar(50)
                )
    END