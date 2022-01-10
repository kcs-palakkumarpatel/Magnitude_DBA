-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- select dbo.AllEstablishmentByAppUserAndActivity(750,1579)
-- =============================================
CREATE FUNCTION [dbo].[AllEstablishmentByAppUserAndActivity]
    (
      @AppUserId BIGINT,
	  @ActivityId BIGINT

    )
	
RETURNS NVARCHAR(max)
    
AS
    BEGIN

	  DECLARE @listStr NVARCHAR(MAX);
      
                 SELECT @listStr = COALESCE(@listStr + ', ', '')
                        + CONVERT(NVARCHAR(50), ISNULL(EST.Id,
                                                       ''))
                 FROM   dbo.Vw_Establishment AS EST
                        INNER JOIN dbo.AppUserEstablishment ON AppUserEstablishment.EstablishmentId = EST.Id
                                                              AND AppUserEstablishment.AppUserId = @AppUserId AND appuserestablishment.IsDeleted = 0
                 WHERE  EstablishmentGroupId = @ActivityId;

				RETURN @listStr;
      
    END;
