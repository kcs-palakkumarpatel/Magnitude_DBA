-- =============================================
-- Author:		Vasu Patel
-- Create date:	31-Jan-2018
-- Description:	Get OUT and IN count
-- Call:		select dbo.GetBadgeCountUnresolve_1608(1615,2011,'Sales')
-- Call:		select dbo.GetBadgeCountUnresolve(1615,2011,'Sales')
-- =============================================
CREATE FUNCTION dbo.GetBadgeCountUnresolve_1608
    (
      @AppuserId INT ,
      @ActivityId INT ,
      @ActivityType VARCHAR(10)
    )
RETURNS INT
AS
    BEGIN

        DECLARE  @Last30DaysDate DATETIME;
		SET @Last30DaysDate = CONVERT(DATE,DATEADD(DAY,-(SELECT  TOP 1 CAST(KeyValue AS BIGINT) FROM dbo.AAAAConfigSettings WHERE KeyName = 'LastFormDays'),GETUTCDATE()));

        DECLARE @UserId VARCHAR(MAX); 
        SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,0,@ActivityId));

        DECLARE @Result INT;
        IF ( @ActivityType = 'Sales' )
            BEGIN
                SELECT  @Result = COUNT(1)
                FROM    dbo.SeenClientAnswerMaster AS SCA
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@UserId, ',')
                                   ) AS U ON U.Data = SCA.AppUserId
						INNER JOIN dbo.Establishment ON Establishment.Id = SCA.EstablishmentId AND EstablishmentGroupId = @ActivityId AND Establishment.IsDeleted = 0
						INNER JOIN dbo.AppUserEstablishment ON AppUserEstablishment.EstablishmentId = Establishment.Id AND  AppUserEstablishment.AppUserId = @AppuserId AND dbo.AppUserEstablishment.IsDeleted = 0
                WHERE  SCA.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
                        AND SCA.IsDeleted = 0
                        AND SCA.IsResolved = 'Unresolved';
            END;
        ELSE
            BEGIN     
                SELECT  @Result = COUNT(1)
                FROM    dbo.AnswerMaster AS AM
					INNER JOIN dbo.Establishment ON Establishment.Id = AM.EstablishmentId AND EstablishmentGroupId = @ActivityId AND Establishment.IsDeleted = 0
						INNER JOIN dbo.AppUserEstablishment ON AppUserEstablishment.EstablishmentId = Establishment.Id AND  AppUserEstablishment.AppUserId = @AppuserId AND dbo.AppUserEstablishment.IsDeleted = 0
                WHERE   AM.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
                        AND AM.IsDeleted = 0
                        AND AM.IsResolved = 'Unresolved';
            END;
        RETURN @Result;
    END;





