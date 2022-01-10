-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,01 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		GetFormDataCountByStatus '2', '10010,1,20014', 3, '28 Jan 2016', '28 jan 2016',''
-- 				GetFormDataCountByStatus '0', '0', 1941, '01 Jan 2017', '07 nov 2017','',467
-- =============================================
CREATE PROCEDURE [dbo].[GetFormDataCountByStatus]
    @EstablishmentId NVARCHAR(MAX) ,
    @UserId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @FilterOn NVARCHAR(50),
	@AppUserId BIGINT
AS
    BEGIN
	
        DECLARE @InOutFilter BIT = 0 ,
            @IsOut BIT = 1;

        IF @FilterOn = 'In'
            BEGIN
                SET @InOutFilter = 1;
                SET @IsOut = 0;
            END;
        ELSE
            IF @FilterOn = 'Out'
                BEGIN
                    SET @InOutFilter = 1;
                    SET @IsOut = 1;
                END;

        DECLARE @Establishment TABLE
            (
              EstablishemtnId BIGINT
            );

		IF(@EstablishmentId = '0')
		BEGIN
			SET @EstablishmentId = (SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,@ActivityId))
		END

        INSERT  INTO @Establishment
                ( EstablishemtnId 
                )
                SELECT  Data
                FROM    dbo.Split(@EstablishmentId, ',')
                WHERE   Data <> '';

        DECLARE @AppUser TABLE ( AppUserId BIGINT );
		DECLARE @ActivityType NVARCHAR(50)
		SELECT @ActivityType = EstablishmentGroupType FROM dbo.EstablishmentGroup WHERE id = @ActivityId
		  IF ( @UserId = '0' AND @ActivityType != 'Customer')
            BEGIN
			SET @UserId = (SELECT dbo.AllUserSelected(@AppuserId,@EstablishmentId,@ActivityId))
            END

			PRINT @EstablishmentId
						PRINT @UserId
        INSERT  INTO @AppUser
                ( AppUserId 
                )
                SELECT  Data
                FROM    dbo.Split(@UserId, ',')
                WHERE   Data <> '';

        DECLARE @Result TABLE
            (
              SmileType NVARCHAR(50) ,
              TotalCount INT
            );
        INSERT  INTO @Result
                ( 
					SmileType ,
                  TotalCount 
                )
                SELECT  A.SmileType ,
                        COUNT(1) AS Total
                FROM    dbo.View_AllAnswerMaster AS A
                        INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                          OR @EstablishmentId = '0'
                        INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                                    OR @UserId = '0'
                WHERE   CAST(A.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                                  AND     CAST(@ToDate AS DATE)
                        AND A.ActivityId = @ActivityId
                        AND ( @InOutFilter = 0
                              OR A.IsOut = @IsOut
                            )
                GROUP BY SmileType;
        DECLARE @PositiveCount BIGINT ,
            @PassiveCount BIGINT ,
            @NegativeCount BIGINT ,
            @UnResolvedCount BIGINT ,
            @QuestionnaireType NVARCHAR(10) ,
            @ResolvedCount BIGINT ,
            @UnActioned BIGINT ,
            @Actioned BIGINT ,
            @Transferred BIGINT,
			@OutStanding BIGINT,
			@AlertunreadCount BIGINT,
			@AllCount BIGINT;
			
			
        SELECT  @PositiveCount = TotalCount
        FROM    @Result
        WHERE   SmileType = 'Positive';
        
        SELECT  @NegativeCount = TotalCount
        FROM    @Result
        WHERE   SmileType = 'Negative';
        
        SELECT  @PassiveCount = TotalCount
        FROM    @Result
        WHERE   SmileType NOT IN ( 'Positive', 'Negative' );

		--------  UnResolved Count -----------------


        SELECT  @UnResolvedCount = COUNT(1)
        FROM    dbo.View_AllAnswerMaster AS A
                INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                  OR @EstablishmentId = '0'
                INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                            OR @UserId = '0'
                                            OR A.UserId = 0
        WHERE   CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE)
                AND A.ActivityId = @ActivityId
                AND AnswerStatus = 'Unresolved'
                --AND ( @InOutFilter = 0
                --      OR A.IsOut = @IsOut
                --    );
				AND A.IsOut = CASE @IsOut WHEN 0 THEN @IsOut ELSE 1 END 

	SELECT  @AllCount = COUNT(1)
        FROM    dbo.View_AllAnswerMaster AS A
                INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                  OR @EstablishmentId = '0'
                INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                            OR @UserId = '0'
                                            OR A.UserId = 0
        WHERE   CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE)
                AND A.ActivityId = @ActivityId
				AND A.IsOut = CASE @IsOut WHEN 0 THEN @IsOut ELSE 1 END 

					  SELECT  @OutStanding = COUNT(1)
        FROM    dbo.View_AllAnswerMaster AS A
                INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                  OR @EstablishmentId = '0'
                INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                            OR @UserId = '0'
                                            OR A.UserId = 0
        WHERE   CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE)
                AND A.ActivityId = @ActivityId
                AND A.IsOutStanding = 1
                AND ( @InOutFilter = 0
                      OR A.IsOut = @IsOut
                    );

					--------  Resolved Count -----------------

        SELECT  @ResolvedCount = COUNT(1)
        FROM    dbo.View_AllAnswerMaster AS A
                INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                  OR @EstablishmentId = '0'
                INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                            OR @UserId = '0'
                                            OR A.UserId = 0
        WHERE   CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE)
                AND A.ActivityId = @ActivityId
                AND AnswerStatus = 'Resolved'
                AND ( @InOutFilter = 0
                      OR A.IsOut = @IsOut
                    );

					--------  UnActioned Count -----------------
                
        SELECT  @UnActioned = COUNT(1)
        FROM    dbo.View_AllAnswerMaster AS A
                INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                  OR @EstablishmentId = '0'
                INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                            OR @UserId = '0'
                                            OR A.UserId = 0
        WHERE   CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE)
                AND A.ActivityId = @ActivityId
                AND (A.IsActioned = 0) and A.AnswerStatus= 'UnResolved'
                AND ( @InOutFilter = 0
                      OR A.IsOut = @IsOut
                    );

			--------  Actioned Count -----------------

        SELECT  @Actioned = COUNT(1)
        FROM    dbo.View_AllAnswerMaster AS A
                INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                  OR @EstablishmentId = '0'
                INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                            OR @UserId = '0'
                                            OR A.UserId = 0
        WHERE   CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE)
                AND A.ActivityId = @ActivityId
                AND (A.IsActioned = 1) 
                AND ( @InOutFilter = 0
                      OR A.IsOut = @IsOut
                    );


					--------  Transferred Count -----------------

        SELECT  @Transferred = COUNT(1)
        FROM    dbo.View_AllAnswerMaster AS A
                INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                  OR @EstablishmentId = '0'
                INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                            OR @UserId = '0'
                                            OR A.UserId = 0
        WHERE   CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE)
                AND A.ActivityId = @ActivityId
                 AND (A.IsTransferred = 1) 
                AND ( @InOutFilter = 0
                      OR A.IsOut = @IsOut
                    );
		
		----------------------------------------------------------- UnreadAction -----------------------------------------
		SELECT @AlertunreadCount = (SELECT  COUNT(DISTINCT p.RefId)
                                            FROM    dbo.PendingNotificationWeb AS P
													INNER JOIN dbo.View_AllAnswerMaster A ON p.RefId = a.ReportId 
													INNER JOIN @AppUser U ON U.AppUserId = a.UserId
                                            WHERE   IsRead = 0
                                                    AND RefId = A.ReportId
                                                    AND ModuleId = 11
													AND CAST(p.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE))
                                          +
						(SELECT COUNT(DISTINCT p.RefId)
                                     FROM   dbo.PendingNotificationWeb AS p
									 INNER JOIN dbo.View_AllAnswerMaster A ON p.RefId = a.ReportId 
									 INNER JOIN @AppUser U ON U.AppUserId = A.UserId
                                     WHERE  IsRead = 0
                                            AND RefId = A.ReportId
                                            AND ModuleId = 12
											AND CAST(p.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                        AND     CAST(@ToDate AS DATE))
		------------------------------------------------------------------------------------------------------------------

        SELECT  @QuestionnaireType = Q.QuestionnaireType
        FROM    dbo.EstablishmentGroup AS Eg
                INNER JOIN dbo.Questionnaire AS Q ON Eg.QuestionnaireId = Q.Id
        WHERE   Eg.Id = @ActivityId;
		

        SELECT  ISNULL(@PositiveCount, 0) AS Positive ,
                ISNULL(@PassiveCount, 0) AS Passive ,
                ISNULL(@NegativeCount, 0) AS Negative ,
                ISNULL(@UnResolvedCount, 0) AS Unresolved ,
                ISNULL(@QuestionnaireType, '') AS QuestionnaireType ,
                ISNULL(@ResolvedCount, 0) AS Resolved,
				ISNULL(@UnActioned,0) as UnActioned,
				ISNULL(@Actioned,0) as Actioned,
				ISNULL(@Transferred,0) as Transferred,
				ISNULL(@OutStanding,0) AS Outstanding,
				ISNULL(@AlertunreadCount,0) AS AlertUnreadCount,
				ISNULL(@AllCount,0) AS AllCount
    END;
