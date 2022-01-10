
CREATE FUNCTION dbo.GetBadgeCountUnresolve_DBA1
    (
      @AppuserId INT ,
      @ActivityId INT ,
      @ActivityType VARCHAR(10)
    )
RETURNS INT
AS
    BEGIN

       
		DECLARE  @Last30DaysDate DATETIME;
		SET @Last30DaysDate = DATEADD(DAY,-(SELECT  TOP 1 CAST(KeyValue AS BIGINT) FROM dbo.AAAAConfigSettings WHERE KeyName = 'LastFormDays'),GETUTCDATE());


        DECLARE @UserId VARCHAR(MAX); 
        SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
                                                    0,
                                                    @ActivityId)
                      );

        DECLARE @Result INT;
        SELECT  @Result = CASE WHEN @ActivityType = 'Sales'
                               THEN ( SELECT    COUNT(1)
                                      FROM   dbo.Establishment E WITH(NOLOCK)
									  INNER JOIN dbo.AppUserEstablishment Aue WITH(NOLOCK) ON Aue.EstablishmentId=E.Id AND Aue.IsDeleted = 0 
									  INNER JOIN  dbo.SeenClientAnswerMaster AS SCA WITH(NOLOCK) on E.Id = SCA.EstablishmentId
									  AND SCA.IsDeleted = 0 AND SCA.IsResolved = 'Unresolved'	 AND E.IsDeleted = 0
									  INNER JOIN (SELECT  Data FROM    dbo.Split(@UserId, ',')) AS U ON U.Data = SCA.AppUserId
									  
                                                --INNER JOIN dbo.Establishment E WITH(NOLOCK) ON E.Id = Aue.EstablishmentId
												WHERE Aue.AppUserId = @AppuserId AND EstablishmentGroupId = @ActivityId 
												AND CAST(SCA.CreatedOn AS DATE) BETWEEN CAST(@Last30DaysDate AS DATE) AND CAST(GETUTCDATE() AS DATE)
														 
												--WHERE     DATEFROMPARTS(DATEPART(YEAR,
            --                                                  SCA.CreatedOn),
            --                                                  DATEPART(MONTH,
            --                                                  SCA.CreatedOn),
            --                                                  DATEPART(DAY,
            --                                                  SCA.CreatedOn)) BETWEEN DATEFROMPARTS(DATEPART(YEAR, @Last30DaysDate), DATEPART(MONTH, @Last30DaysDate), DATEPART(DAY, @Last30DaysDate))
            --                                                  AND
            --                                                  DATEFROMPARTS(DATEPART(YEAR,
            --                                                  GETUTCDATE()),
            --                                                  DATEPART(MONTH,
            --                                                  GETUTCDATE()),
            --                                                  DATEPART(DAY,
            --                                                  GETUTCDATE()))
                                                --AND SCA.EstablishmentId IN (
                                                --SELECT  EstablishmentId
                                                --FROM    dbo.AppUserEstablishment
                                                --        INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
                                                --WHERE   AppUserId = @AppuserId
                                                --        AND EstablishmentGroupId = @ActivityId
                                                --        AND Establishment.IsDeleted = 0
                                                --        AND dbo.AppUserEstablishment.IsDeleted = 0 )
                                                --AND SCA.IsDeleted = 0
                                                --AND SCA.IsResolved = 'Unresolved'
                                             
                                    )
                               ELSE ( SELECT    COUNT(1)
                                      FROM dbo.Establishment E WITH	(NOLOCK)
									  INNER JOIN dbo.AnswerMaster AS AM WITH(NOLOCK) ON E.Id=Am.EstablishmentId 
									  AND E.IsDeleted = 0 AND AM.IsDeleted = 0 AND AM.IsResolved = 'Unresolved'
									  INNER JOIN dbo.AppUserEstablishment Aue ON Aue.EstablishmentId=E.Id AND Aue.IsDeleted = 0 
                                      --INNER JOIN dbo.Establishment ON Establishment.Id = Aue.EstablishmentId
                                      WHERE Aue.AppUserId = @AppuserId AND EstablishmentGroupId = @ActivityId
									  AND CAST(AM.CreatedOn AS DATE) BETWEEN CAST(@Last30DaysDate AS DATE) AND CAST(GETUTCDATE() AS DATE)
                                      --WHERE     DATEFROMPARTS(DATEPART(YEAR,
                                      --                        AM.CreatedOn),
                                      --                        DATEPART(MONTH,
                                      --                        AM.CreatedOn),
                                      --                        DATEPART(DAY,
                                      --                        AM.CreatedOn)) BETWEEN DATEFROMPARTS(DATEPART(YEAR, @Last30DaysDate), DATEPART(MONTH, @Last30DaysDate), DATEPART(DAY, @Last30DaysDate))
                                      --                        AND
                                      --                        DATEFROMPARTS(DATEPART(YEAR,
                                      --                        GETUTCDATE()),
                                      --                        DATEPART(MONTH,
                                      --                        GETUTCDATE()),
                                      --                        DATEPART(DAY,
                                      --                        GETUTCDATE()))
                                      --          AND AM.EstablishmentId IN (
                                      --          SELECT  EstablishmentId
                                      --          FROM    dbo.AppUserEstablishment
                                      --                  INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
                                      --          WHERE   AppUserId = @AppuserId
                                      --                  AND EstablishmentGroupId = @ActivityId
                                      --                  AND Establishment.IsDeleted = 0
                                      --                  AND dbo.AppUserEstablishment.IsDeleted = 0 )
                                      --          AND AM.IsDeleted = 0
                                      --          AND AM.IsResolved = 'Unresolved'
                                    )
                          END; 
	
        RETURN @Result;
    END;





