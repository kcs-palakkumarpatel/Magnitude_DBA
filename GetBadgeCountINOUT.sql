-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <19 Sep 2017>
-- Description:	<Get OUT and IN count>
-- Call:		select dbo.GetBadgeCountINOUT(366,1270,30,0)
-- =============================================
CREATE FUNCTION [dbo].[GetBadgeCountINOUT]
(
   @AppuserId INT ,
	@ActivityId INT ,
	@Days INT ,
	@Type BIT 
)
RETURNS INT
AS
BEGIN
IF (@Days = 0)
BEGIN
	SET @Days = -30;
	END
    ELSE
    BEGIN
        SET @Days = @Days * -1;
    END

DECLARE @UserId VARCHAR(2000) 
SET @UserId = (SELECT dbo.AllUserSelected(@AppuserId,0,@ActivityId))
DECLARE @Result INT
    IF ( @Type = 0 )
        BEGIN
		IF((SELECT EstablishmentGroupType FROM dbo.EstablishmentGroup WHERE id = @ActivityId) = 'Sales')
		BEGIN
            SELECT  @Result = ( SELECT  COUNT(1) AS INCount
                                FROM    dbo.AnswerMaster AS AM
                                        INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                        INNER JOIN dbo.AppUser A ON ( AM.AppUserId = A.Id )
										inner JOIN (SELECT  Data FROM    dbo.Split(@UserId, ',')) AS U ON A.Id = U.Data
                                WHERE   AM.IsDeleted = 0
                                        AND ( AM.AppUserId = 0
                                              OR A.IsAreaManager = 1
                                              OR AM.AppUserId = A.Id
                                            )
                                        AND E.EstablishmentGroupId = @ActivityId
                                        AND AM.CreatedOn BETWEEN DATEADD(DAY,
                                                              ( @Days ),
                                                              GETUTCDATE())
                                                         AND  GETUTCDATE()
                              );
	END
    ELSE
    BEGIN
	SELECT @Result = 
    ( SELECT    COUNT(1) AS INCount
      FROM      dbo.AnswerMaster AS AM
                INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id
      WHERE     AM.IsDeleted = 0
                AND E.EstablishmentGroupId = @ActivityId
                AND AM.CreatedOn BETWEEN DATEADD(DAY, ( @Days  ),
                                                 GETUTCDATE())
                                 AND     GETUTCDATE()
    );
	END
    

/*(SELECT  COUNT(1)
       FROM    dbo.PendingNotificationWeb AS PNW 
		INNER JOIN dbo.AppUser A ON A.id = PNW.AppUserId
		INNER JOIN dbo.SeenClientAnswerMaster SA ON sa.Id = PNW.RefId
		INNER JOIN dbo.Establishment E ON E.Id = SA.EstablishmentId
        WHERE   PNW.AppUserId = @AppUserId
                AND IsRead = 0
				AND PNW.IsDeleted = 0
				AND SA.IsDeleted = 0
                AND ModuleId = 12 
				AND (A.IsAreaManager = 1 OR sa.AppUserId = pnw.AppUserId)
				AND E.EstablishmentGroupId = @ActivityId
				AND PNW.CreatedOn BETWEEN DATEADD(day,(@Days * -1),GETUTCDATE()) AND GETUTCDATE())*/
				
        END;
    ELSE
        BEGIN
	
            SELECT  @Result = ( SELECT  COUNT(1) AS OutCount
                                FROM    dbo.SeenClientAnswerMaster AS SAM
                                        INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
										INNER JOIN (SELECT  Data FROM    dbo.Split(@UserId, ',') ) AS U ON SAM.AppUserId = U.Data
                                WHERE   SAM.IsDeleted = 0
                                        AND E.EstablishmentGroupId = @ActivityId
                                        AND SAM.CreatedOn BETWEEN DATEADD(DAY,
                                                              ( @Days ),
                                                              GETUTCDATE())
                                                          AND GETUTCDATE()
                              );
	/*SELECT @Result = (SELECT  COUNT(1)
 --     FROM    dbo.PendingNotificationWeb AS PNW 
	--	INNER JOIN dbo.AppUser A ON A.id = PNW.AppUserId
	--	INNER JOIN dbo.AnswerMaster AM ON AM.Id = PNW.RefId
	--	INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
 --       WHERE   PNW.AppUserId = @AppUserId
 --               AND IsRead = 0
	--			AND PNW.IsDeleted = 0
	--			AND AM.IsDeleted = 0
 --               AND ModuleId = 11 
	--			AND (AM.AppUserId = 0 OR A.IsAreaManager = 1 OR AM.AppUserId = pnw.AppUserId)
	--			AND E.EstablishmentGroupId = @ActivityId
	--			AND PNW.CreatedOn BETWEEN DATEADD(day,(@Days * -1),GETUTCDATE()) AND GETUTCDATE())*/
        END;
	RETURN @Result
END










