-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,14 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		spAnalysisQuestions '0', 3, '0', 0
-- =============================================
CREATE PROCEDURE [dbo].[spAnalysisQuestions]
    @EstablishmentId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @UserId NVARCHAR(MAX) ,
    @IsOut BIT
AS 
    BEGIN
        DECLARE @Result TABLE
            (
              Id BIGINT NOT NULL ,
              QuestionTitle NVARCHAR(250) NOT NULL ,
              [Count] BIGINT NOT NULL ,
              QuestionId BIGINT NOT NULL ,
              CurrentDate DATETIME NOT NULL
            )
		

		      DECLARE @listStr NVARCHAR(MAX);
     IF ( @EstablishmentId = '0' )
            BEGIN
            SELECT  @listStr = COALESCE(@listStr + ', ', '')
                    + CONVERT(NVARCHAR(50), ISNULL(Id, ''))
            FROM    dbo.Establishment
            WHERE   EstablishmentGroupId = @ActivityId;
			
			SET @EstablishmentId = @listStr;
            END;

						     SET @listStr = '';
            DECLARE @ActivityType NVARCHAR(50);
            SELECT  @ActivityType = EstablishmentGroupType
            FROM    dbo.EstablishmentGroup
            WHERE   Id = @ActivityId;
            IF ( @UserId = '0'
                 AND @ActivityType != 'Customer'
               )
                BEGIN
                    SELECT  @listStr = COALESCE(@listStr + ', ', '')
                            + CONVERT(NVARCHAR(50), ISNULL(AppUserId, ''))
                    FROM    dbo.AppUserEstablishment
                    WHERE   EstablishmentId IN (SELECT data FROM dbo.Split(@EstablishmentId,','));

                    SET @UserId = @listStr;
                END;

        DECLARE @QuestionnaireId BIGINT ,
            @SeenClientId BIGINT ,
            @QuestionnaireType NVARCHAR(10) ,
            @TotalEntry BIGINT ,
            @CurrnetDate DATETIME ,
            @EstablishmentGroupType NVARCHAR(10)

        SELECT TOP 1
                @QuestionnaireId = QuestionnaireId ,
                @SeenClientId = SeenClientId ,
                @QuestionnaireType = CASE @IsOut
                                       WHEN 0 THEN Q.QuestionnaireType
                                       ELSE S.SeenClientType
                                     END ,
                @CurrnetDate = DATEADD(MINUTE, E.TimeOffSet, @CurrnetDate) ,
                @EstablishmentGroupType = Eg.EstablishmentGroupType
        FROM    dbo.EstablishmentGroup AS Eg
                LEFT OUTER JOIN dbo.Establishment AS E ON Eg.Id = E.EstablishmentGroupId
                                                     AND ISNULL(E.IsDeleted, 0) = 0
                INNER JOIN dbo.Questionnaire AS Q ON Eg.QuestionnaireId = Q.Id
                LEFT OUTER JOIN dbo.SeenClient AS S ON Eg.SeenClientId = S.Id
        WHERE   Eg.Id = @ActivityId

		SET @CurrnetDate = ISNULL(@CurrnetDate, CAST(GETUTCDATE() AS DATE))

        IF @IsOut = 1 
            BEGIN
                SELECT  @TotalEntry = COUNT(1)
                FROM    dbo.View_SeenClientAnswerMaster AS Am
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@EstablishmentId, ',')
                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                OR @EstablishmentId = '0'
                                              )
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@UserId, ',')
                                   ) AS RU ON RU.Data = AM.AppUserId
                                              OR @UserId = '0'
                WHERE   CAST(CreatedOn AS DATE) = CAST(@CurrnetDate AS DATE)
                        AND ActivityId = @ActivityId
						AND ISNULL(Am.IsDisabled,0) = 0
            END
        ELSE 
            BEGIN
                SELECT  @TotalEntry = COUNT(1)
                FROM    dbo.View_AnswerMaster AS Am
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@EstablishmentId, ',')
                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                OR @EstablishmentId = '0'
                                              )
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@UserId, ',')
                                   ) AS RU ON RU.Data = AM.AppUserId
                                              OR @UserId = '0'
                WHERE   CAST(CreatedOn AS DATE) = CAST(@CurrnetDate AS DATE)
                        AND ActivityId = @ActivityId
						AND ISNULL(Am.IsDisabled,0) = 0
            END          

        IF ( @QuestionnaireType = 'NPS' ) 
            BEGIN
                --INSERT  INTO @Result
                --        ( Id ,
                --          QuestionTitle ,
                --          [Count] ,
                --          QuestionId ,
                --          CurrentDate
                --        )
                --        SELECT  -2 ,
                --                'Activity Barometer' ,
                --                @TotalEntry ,
                --                -2 ,
                --                @CurrnetDate

                IF @IsOut = 0 
                    BEGIN
                        INSERT  INTO @Result
                                ( Id ,
                                  QuestionTitle ,
                                  [Count] ,
                                  QuestionId ,
                                  CurrentDate
                                )
                                SELECT  Opt.Id AS Id ,
                                        Name AS QuestionTitle ,
                                        @TotalEntry AS [COUNT] ,
                                        QuestionId ,
                                        @CurrnetDate
                                FROM    dbo.Options AS Opt
                                        INNER JOIN dbo.Questions AS Q ON Opt.QuestionId = Q.Id
                                                              AND QuestionnaireId = @QuestionnaireId
                                WHERE   QuestionTypeId IN ( 5, 18 )
                                        --AND Q.IsActive = 1
                                        AND Q.IsDeleted = 0
                                        AND Opt.IsDeleted = 0
                    END
                ELSE 
                    BEGIN
                        INSERT  INTO @Result
                                ( Id ,
                                  QuestionTitle ,
                                  [Count] ,
                                  QuestionId ,
                                  CurrentDate
                                )
                                SELECT  Opt.Id AS Id ,
                                        Name AS QuestionTitle ,
                                        @TotalEntry AS [COUNT] ,
                                        QuestionId ,
                                        @CurrnetDate
                                FROM    dbo.SeenClientOptions AS Opt
                                        INNER JOIN dbo.SeenClientQuestions AS Q ON Opt.QuestionId = Q.Id
                                                              AND SeenClientId = @SeenClientId
                                WHERE   QuestionTypeId IN ( 5, 18 )
                                        AND Q.IsDeleted = 0
                                        AND Opt.IsDeleted = 0
                    END                  
            END
        ELSE 
            BEGIN
                INSERT  INTO @Result
                        ( Id ,
                          QuestionTitle ,
                          [Count] ,
                          QuestionId ,
                          CurrentDate
                        )
                        SELECT  -1 ,
                                'Performance Index' ,
                                @TotalEntry ,
                                -1 ,
                                @CurrnetDate
                --IF @EstablishmentGroupType <> 'Customer' 
                --    BEGIN
                --        INSERT  INTO @Result
                --                ( Id ,
                --                  QuestionTitle ,
                --                  [Count] ,
                --                  QuestionId ,
                --                  CurrentDate
                --                )
                --                SELECT  -2 ,
                --                        'Activity Barometer' ,
                --                        @TotalEntry ,
                --                        -2 ,
                --                        @CurrnetDate
                --    END
                IF @IsOut = 0 
                    BEGIN
                        INSERT  INTO @Result
                                ( Id ,
                                  QuestionTitle ,
                                  [Count] ,
                                  QuestionId ,
                                  CurrentDate
                                )
                                SELECT  Id ,
                                        ShortName ,
                                        @TotalEntry ,
                                        Id ,
                                        @CurrnetDate
                                FROM    dbo.Questions
                                WHERE   QuestionnaireId = @QuestionnaireId
                                        --AND QuestionTypeId = 1
                                        --AND IsActive = 1
                                        AND IsDeleted = 0
										AND DisplayInGraphs = 1
								ORDER BY Position ASC /* Added By Disha - 03-OCT-2016 */
                    END
                ELSE 
                    BEGIN
                        INSERT  INTO @Result
                                ( Id ,
                                  QuestionTitle ,
                                  [Count] ,
                                  QuestionId ,
                                  CurrentDate
                                )
                                SELECT  Id ,
                                        ShortName ,
                                        @TotalEntry ,
                                        Id ,
                                        @CurrnetDate
                                FROM    dbo.SeenClientQuestions
                                WHERE   SeenClientId = @SeenClientId
                                        --AND QuestionTypeId = 1
                                        AND IsDeleted = 0
										AND DisplayInGraphs = 1
								ORDER BY Position ASC /* Added By Disha - 03-OCT-2016 */
                    END                  
            END
		
		
        SELECT  *
        FROM    @Result          
    END