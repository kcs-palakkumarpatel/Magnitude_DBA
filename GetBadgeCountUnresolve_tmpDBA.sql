CREATE FUNCTION dbo.GetBadgeCountUnresolve_tmpDBA
    (
	--DECLARE
      @AppuserId INT ,
      @ActivityId INT ,
      @ActivityType VARCHAR(10),
	  @EstablishmentId_N VARCHAR(MAX)
    )
RETURNS INT
AS
    BEGIN

        ---DECLARE @EstablishmentId VARCHAR(MAX), 
		DECLARE  @Last30DaysDate DATETIME;
		SET @Last30DaysDate = DATEADD(DAY,-(SELECT  TOP 1 CAST(KeyValue AS BIGINT) FROM dbo.AAAAConfigSettings WHERE KeyName = 'LastFormDays'),GETUTCDATE());
        --SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,@ActivityId));

        --DECLARE @UserId VARCHAR(MAX); 
        --SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
        --                                            0,
        --                                            @ActivityId)
        --              );




--IF OBJECT_ID('tempdb..#EstablishmentId','U') IS NOT NULL
--DROP TABLE #EstablishmentId
--CREATE TABLE #EstablishmentId (id BIGINT)

DECLARE @EstablishmentId TABLE (id BIGINT)

IF (@EstablishmentId_N = '0')
BEGIN
    INSERT INTO @EstablishmentId
    SELECT EST.Id
	FROM   dbo.Establishment AS EST  WITH(NOLOCK)
	INNER JOIN dbo.AppUserEstablishment WITH(NOLOCK) ON est.EstablishmentGroupId = @ActivityId 
	AND AppUserEstablishment.AppUserId = @AppUserId 
	AND AppUserEstablishment.EstablishmentId = EST.Id  AND appuserestablishment.IsDeleted = 0  
END
ELSE
BEGIN
     INSERT INTO @EstablishmentId
	 SELECT data FROM dbo.Split(@EstablishmentId_N,',')
END
;

		--IF OBJECT_ID('tempdb..#UserId', 'U') IS NOT NULL
		--DROP TABLE #UserId
		--CREATE TABLE #UserId (UserId VARCHAR(MAX))
		DECLARE @UserId TABLE (UserId VARCHAR(MAX))

--IF (@UserId<>'0')
--BEGIN
--	INSERT INTO #UserId
--	SELECT Data FROM dbo.Split(@UserId,',')
--END
  
--IF (@UserId = '0' AND @ActivityType != 'Customer')
IF (@ActivityType != 'Customer')
BEGIN

		DECLARE @Count BIGINT = 0;
        DECLARE @IsManager BIT;
        
        SELECT  @IsManager = IsAreaManager
        FROM    dbo.AppUser
        WHERE   Id = @AppUserId;


			IF EXISTS ( SELECT 1
                    FROM  dbo.AppUserEstablishment
                    INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId AND  IsAreaManager = 0 AND IsActive = 1
					AND AppUser.IsDeleted = 0 and   dbo.AppUserEstablishment.IsDeleted = 0
					INNER JOIN dbo.Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId AND E.EstablishmentGroupId = @ActivityId
                    UNION
					SELECT 1
                    FROM  dbo.AppUserEstablishment
                    INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId AND  AppUserId = @AppUserId AND AppUser.IsDeleted = 0 
					AND IsActive = 1 AND   dbo.AppUserEstablishment.IsDeleted = 0
					INNER JOIN dbo.Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId AND E.EstablishmentGroupId = @ActivityId
                    
                   )
		BEGIN
			SET @Count = 1
		END

		IF @Count = 0
		BEGIN
			IF EXISTS (SELECT 1
                    FROM AppManagerUserRights
                    INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId AND AppManagerUserRights.UserId = @AppUserId
					AND AppManagerUserRights.IsDeleted = 0
					AND IsActive = 1
					INNER JOIN @EstablishmentId e ON e.id=AppManagerUserRights.EstablishmentId)
            BEGIN
                SET @Count = 1
            END
		END
	
		IF ( @IsManager = 1 )
						BEGIN
							IF (@Count > 0)
						BEGIN
							INSERT INTO @UserId
							 SELECT  AppUserId
							 FROM    dbo.AppUserEstablishment
							 INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId 
							 AND AppUserId = @AppUserId AND AppUser.IsDeleted = 0 AND dbo.AppUserEstablishment.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN @EstablishmentId e ON e.id=dbo.AppUserEstablishment.EstablishmentId
							 UNION
							 SELECT  AppUserId
							 FROM    dbo.AppUserEstablishment
							 INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId 
							 AND  IsAreaManager = 0 AND AppUser.IsDeleted = 0 AND dbo.AppUserEstablishment.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN @EstablishmentId e ON e.id=dbo.AppUserEstablishment.EstablishmentId
							 UNION
							 SELECT  ManagerUserId 
							 FROM    AppManagerUserRights
							 INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId AND AppManagerUserRights.UserId = @AppUserId AND AppUser.IsDeleted = 0
							 AND AppManagerUserRights.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN @EstablishmentId e ON e.id=AppManagerUserRights.EstablishmentId
							 INNER JOIN dbo.AppUserEstablishment ON AppManagerUserRights.EstablishmentId = AppUserEstablishment.EstablishmentId
             
						END
						ELSE
						BEGIN
                        INSERT  INTO @UserId
						SELECT DISTINCT U.Id AS UserId
                        FROM    dbo.AppUserEstablishment AS UE
						INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id AND LoginUser.Id = @AppUserId AND LoginUser.IsDeleted = 0
						AND UE.IsDeleted = 0 
                        INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id AND   E.IsDeleted = 0
                        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                        INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
						AND ( UE.EstablishmentType = AppUser.EstablishmentType OR LoginUser.IsAreaManager = 1)
                        INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id AND ( U.IsAreaManager = 0 OR U.Id = @AppUserId) AND U.IsDeleted = 0
						AND AppUser.IsDeleted = 0
                        
						END;

						END
					 ELSE
						BEGIN
INSERT  INTO @UserId 
SELECT U.Id AS UserId
FROM dbo.AppUserEstablishment AS UE
    INNER JOIN dbo.AppUser AS LoginUser
        ON UE.AppUserId = LoginUser.Id
           AND LoginUser.Id = @AppuserId
           AND LoginUser.IsDeleted = 0
    INNER JOIN dbo.Establishment AS E
        ON UE.EstablishmentId = E.Id
    INNER JOIN dbo.EstablishmentGroup AS Eg
        ON Eg.Id = E.EstablishmentGroupId
    INNER JOIN dbo.AppUserEstablishment AS AppUser
        ON E.Id = AppUser.EstablishmentId
           AND (
                   UE.EstablishmentType = AppUser.EstablishmentType
                   OR LoginUser.IsAreaManager = 1
               )
    INNER JOIN dbo.AppUser AS U
        ON AppUser.AppUserId = U.Id
           AND (
                   U.IsAreaManager = 0
                   OR U.Id = @AppuserId
               )
WHERE U.Id = @AppuserId
      AND E.IsDeleted = 0
      AND UE.IsDeleted = 0
      AND AppUser.IsDeleted = 0
      AND U.IsDeleted = 0
END;


END

        DECLARE @Result INT;
        SELECT  @Result = CASE WHEN @ActivityType = 'Sales'
                               THEN ( SELECT    COUNT(1)
                                      FROM dbo.Establishment E WITH(NOLOCK)
									  INNER JOIN dbo.AppUserEstablishment Aue WITH(NOLOCK) 
									  ON  E.id=Aue.EstablishmentId 
									  INNER JOIN dbo.SeenClientAnswerMaster AS SCA  WITH(NOLOCK)
									  ON SCA.EstablishmentId = E.Id
										   AND SCA.IsDeleted = 0 AND SCA.IsResolved = 'Unresolved'
												--INNER JOIN (SELECT  Data FROM    dbo.Split(@UserId, ',')) AS U ON U.Data = SCA.AppUserId
									 LEFT JOIN @UserId AS U ON U.UserId = @AppuserId
												WHERE     CAST(SCA.CreatedOn AS DATE) BETWEEN CAST(@Last30DaysDate AS DATE) AND CAST(GETUTCDATE() AS DATE)
												AND Aue.AppUserId = @AppuserId AND EstablishmentGroupId = @ActivityId
                                          AND E.IsDeleted = 0 AND Aue.IsDeleted = 0 
												
												--DATEFROMPARTS(
												--DATEPART(YEAR,SCA.CreatedOn),
												--DATEPART(MONTH,SCA.CreatedOn),
												--DATEPART(DAY,SCA.CreatedOn)) 
												--BETWEEN DATEFROMPARTS(DATEPART(YEAR, @Last30DaysDate), DATEPART(MONTH, @Last30DaysDate), DATEPART(DAY, @Last30DaysDate))
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
                                                --AND SCA.AppUserId IN (
                                                --SELECT  Data
                                                --FROM    dbo.Split(@UserId, ',') )
                                    )
                               ELSE ( SELECT    COUNT(1)
                                      FROM    dbo.Establishment E WITH(NOLOCK)
									  INNER JOIN   dbo.AppUserEstablishment Aue WITH(NOLOCK)
									  ON E.Id = Aue.EstablishmentId 
									  INNER JOIN dbo.AnswerMaster AS AM
									  ON AM.EstablishmentId =E.id AND  AM.IsDeleted = 0 AND AM.IsResolved = 'Unresolved'
                                      WHERE  CAST(AM.CreatedOn AS DATE) BETWEEN CAST(@Last30DaysDate AS DATE) AND CAST(GETUTCDATE() AS DATE)
									  AND Aue.AppUserId = @AppuserId
                                      AND EstablishmentGroupId = @ActivityId AND E.IsDeleted = 0 AND Aue.IsDeleted = 0   
									  
									  
									  --DATEFROMPARTS(DATEPART(YEAR,
           --                                                   AM.CreatedOn),
           --                                                   DATEPART(MONTH,
           --                                                   AM.CreatedOn),
           --                                                   DATEPART(DAY,
           --                                                   AM.CreatedOn)) BETWEEN DATEFROMPARTS(DATEPART(YEAR, @Last30DaysDate), DATEPART(MONTH, @Last30DaysDate), DATEPART(DAY, @Last30DaysDate))
           --                                                   AND
           --                                                   DATEFROMPARTS(DATEPART(YEAR,
           --                                                   GETUTCDATE()),
           --                                                   DATEPART(MONTH,
           --                                                   GETUTCDATE()),
           --                                                   DATEPART(DAY,
           --                                                   GETUTCDATE()))
                                                --AND AM.EstablishmentId IN (
                                                --SELECT  EstablishmentId
                                                --FROM    dbo.AppUserEstablishment
                                                --        INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
                                                --WHERE   AppUserId = @AppuserId
                                                --        AND EstablishmentGroupId = @ActivityId
                                                --        AND Establishment.IsDeleted = 0
                                                --        AND dbo.AppUserEstablishment.IsDeleted = 0 )
                                                --AND AM.IsDeleted = 0
                                                --AND AM.IsResolved = 'Unresolved'
                                    )
                          END; 
	
        RETURN @Result;
    END;
