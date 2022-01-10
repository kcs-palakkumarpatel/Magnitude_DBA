-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <19 Sep 2017>
-- Description:	<Get OUT and IN count>
-- Call:		select dbo.GetBadgeCountINOUT(1766,2967,30,0)
-- =============================================
CREATE FUNCTION [dbo].[GetBadgeCountINOUT_backup3107] 
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
	SET @Days = 30;

DECLARE @EstablishmentId NVARCHAR(2000)

--SET @EstablishmentId = (SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,@ActivityId))

DECLARE @UserId NVARCHAR(2000) 
SET @UserId = (SELECT dbo.AllUserSelected(@AppuserId,0,@ActivityId))
DECLARE @Result INT
    IF ( @Type = 0 )
        BEGIN
		IF((SELECT EstablishmentGroupType FROM dbo.EstablishmentGroup WHERE id = @ActivityId) = 'Sales')
		BEGIN
            SELECT  @Result = ( SELECT  COUNT(AM.Id) AS INCount
                                FROM    dbo.AnswerMaster AS AM
                                        INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                        INNER JOIN dbo.AppUser A ON ( AM.AppUserId = A.Id )
                                WHERE   AM.IsDeleted = 0
                                        AND ( AM.AppUserId = 0
                                              OR A.IsAreaManager = 1
                                              OR AM.AppUserId = A.Id
                                            )
                                        AND E.EstablishmentGroupId = @ActivityId
                                        AND AM.CreatedOn BETWEEN DATEADD(DAY,
                                                              ( @Days * -1 ),
                                                              GETUTCDATE())
                                                         AND  GETUTCDATE()
                                        AND A.Id IN (
                                        SELECT  Data
                                        FROM    dbo.Split(@UserId, ',') )
                              );
	END
    ELSE
    BEGIN
	SELECT @Result = 
    ( SELECT    COUNT(AM.Id) AS INCount
      FROM      dbo.AnswerMaster AS AM
                INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id
      WHERE     AM.IsDeleted = 0
                AND E.EstablishmentGroupId = @ActivityId
                AND AM.CreatedOn BETWEEN DATEADD(DAY, ( @Days * -1 ),
                                                 GETUTCDATE())
                                 AND     GETUTCDATE()
    );
	END
    

--(SELECT  COUNT(1)
--       FROM    dbo.PendingNotificationWeb AS PNW 
	--	INNER JOIN dbo.AppUser A ON A.id = PNW.AppUserId
	--	INNER JOIN dbo.SeenClientAnswerMaster SA ON sa.Id = PNW.RefId
	--	INNER JOIN dbo.Establishment E ON E.Id = SA.EstablishmentId
 --       WHERE   PNW.AppUserId = @AppUserId
 --               AND IsRead = 0
	--			AND PNW.IsDeleted = 0
	--			AND SA.IsDeleted = 0
 --               AND ModuleId = 12 
	--			AND (A.IsAreaManager = 1 OR sa.AppUserId = pnw.AppUserId)
	--			AND E.EstablishmentGroupId = @ActivityId
	--			AND PNW.CreatedOn BETWEEN DATEADD(day,(@Days * -1),GETUTCDATE()) AND GETUTCDATE())
				
        END;
    ELSE
        BEGIN
	
            SELECT  @Result = ( SELECT  COUNT(SAM.Id) AS OutCount
                                FROM    dbo.SeenClientAnswerMaster AS SAM
                                        INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
										INNER JOIN (SELECT data FROM dbo.Split(@UserId,',')) U ON SAM.AppUserId = U.Data
                                WHERE   SAM.IsDeleted = 0
                                        --AND SAM.AppUserId IN (
                                        --SELECT  Data
                                        --FROM    dbo.Split(@UserId, ',') )
                                        AND E.EstablishmentGroupId = @ActivityId
                                        AND SAM.CreatedOn BETWEEN DATEADD(DAY,
                                                              ( @Days * -1 ),
                                                              GETUTCDATE())
                                                          AND GETUTCDATE()
                              );
	--SELECT @Result = (SELECT  COUNT(1)
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
	--			AND PNW.CreatedOn BETWEEN DATEADD(day,(@Days * -1),GETUTCDATE()) AND GETUTCDATE())
        END;
	RETURN @Result
END






