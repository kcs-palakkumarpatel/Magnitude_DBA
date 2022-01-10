-- =============================================
-- Author:		Vasu Patel
-- Create date:	31-Jan-2018
-- Description:	Get OUT and IN count
-- Call:		select dbo.GetBadgeCountINOUT(1758,1941,30,1)
-- =============================================
CREATE FUNCTION dbo.GetBadgeCountUnresolve_backup3107
    (
      @AppuserId INT ,
      @ActivityId INT ,
      @ActivityType VARCHAR(10)
    )
RETURNS INT
AS
    BEGIN

        DECLARE @EstablishmentId VARCHAR(MAX), @Last30DaysDate DATETIME;
		SET @Last30DaysDate = DATEADD(DAY,-(SELECT  TOP 1 CAST(KeyValue AS BIGINT) FROM dbo.AAAAConfigSettings WHERE KeyName = 'LastFormDays'),GETUTCDATE());
        SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,
                                                              @ActivityId)
                               );

        DECLARE @UserId VARCHAR(MAX); 
        SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
                                                    @EstablishmentId,
                                                    @ActivityId)
                      );

        DECLARE @Result INT;
        SELECT  @Result = CASE WHEN @ActivityType = 'Sales'
                               THEN ( SELECT    COUNT(1)
                                      FROM      dbo.SeenClientAnswerMaster AS SCA
                                      WHERE     DATEFROMPARTS(DATEPART(YEAR,
                                                              SCA.CreatedOn),
                                                              DATEPART(MONTH,
                                                              SCA.CreatedOn),
                                                              DATEPART(DAY,
                                                              SCA.CreatedOn)) BETWEEN DATEFROMPARTS(DATEPART(YEAR, @Last30DaysDate), DATEPART(MONTH, @Last30DaysDate), DATEPART(DAY, @Last30DaysDate))
                                                              AND
                                                              DATEFROMPARTS(DATEPART(YEAR,
                                                              GETUTCDATE()),
                                                              DATEPART(MONTH,
                                                              GETUTCDATE()),
                                                              DATEPART(DAY,
                                                              GETUTCDATE()))
                                                AND SCA.EstablishmentId IN (
                                                SELECT  EstablishmentId
                                                FROM    dbo.AppUserEstablishment
                                                        INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
                                                WHERE   AppUserId = @AppuserId
                                                        AND EstablishmentGroupId = @ActivityId
                                                        AND Establishment.IsDeleted = 0
                                                        AND dbo.AppUserEstablishment.IsDeleted = 0 )
                                                AND SCA.IsDeleted = 0
                                                AND SCA.IsResolved = 'Unresolved'
                                                AND SCA.AppUserId IN (
                                                SELECT  Data
                                                FROM    dbo.Split(@UserId, ',') )
                                    )
                               ELSE ( SELECT    COUNT(1)
                                      FROM      dbo.AnswerMaster AS AM
                                      WHERE     DATEFROMPARTS(DATEPART(YEAR,
                                                              AM.CreatedOn),
                                                              DATEPART(MONTH,
                                                              AM.CreatedOn),
                                                              DATEPART(DAY,
                                                              AM.CreatedOn)) BETWEEN DATEFROMPARTS(DATEPART(YEAR, @Last30DaysDate), DATEPART(MONTH, @Last30DaysDate), DATEPART(DAY, @Last30DaysDate))
                                                              AND
                                                              DATEFROMPARTS(DATEPART(YEAR,
                                                              GETUTCDATE()),
                                                              DATEPART(MONTH,
                                                              GETUTCDATE()),
                                                              DATEPART(DAY,
                                                              GETUTCDATE()))
                                                AND AM.EstablishmentId IN (
                                                SELECT  EstablishmentId
                                                FROM    dbo.AppUserEstablishment
                                                        INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
                                                WHERE   AppUserId = @AppuserId
                                                        AND EstablishmentGroupId = @ActivityId
                                                        AND Establishment.IsDeleted = 0
                                                        AND dbo.AppUserEstablishment.IsDeleted = 0 )
                                                AND AM.IsDeleted = 0
                                                AND AM.IsResolved = 'Unresolved'
                                    )
                          END; 
	
        RETURN @Result;
    END;


