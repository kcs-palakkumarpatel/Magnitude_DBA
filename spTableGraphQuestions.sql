-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,22 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		spTableGraphQuestions '2,10053', 3, '20014', 0
-- =============================================
CREATE PROCEDURE [dbo].[spTableGraphQuestions]
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
            );


			   DECLARE @listStr NVARCHAR(MAX);
        IF ( @EstablishmentId = '0' )
            BEGIN
                  SELECT    @listStr = COALESCE(@listStr + ', ', '')
                            + CONVERT(NVARCHAR(50), ISNULL(Id, ''))
                  FROM      dbo.Establishment
                  WHERE     EstablishmentGroupId = @ActivityId;

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
            @EstablishmentGroupType NVARCHAR(10);

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
                                                          AND ISNULL(E.IsDeleted,
                                                              0) = 0
                INNER JOIN dbo.Questionnaire AS Q ON Eg.QuestionnaireId = Q.Id
                LEFT OUTER JOIN dbo.SeenClient AS S ON Eg.SeenClientId = S.Id
        WHERE   Eg.Id = @ActivityId;
		
        PRINT 'QuestionnaireId';
        PRINT @QuestionnaireId;
        PRINT 'Seen Client Id';
        PRINT @SeenClientId;

        SET @CurrnetDate = ISNULL(@CurrnetDate, CAST(GETUTCDATE() AS DATE));
        
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
                                   ) AS RU ON RU.Data = Am.AppUserId
                                              OR @UserId = '0'
                WHERE   CAST(CreatedOn AS DATE) = CAST(@CurrnetDate AS DATE)
                        AND ActivityId = @ActivityId
						AND ISNULL(Am.IsDisabled,0) = 0;
            END;
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
                                   ) AS RU ON RU.Data = Am.AppUserId
                                              OR @UserId = '0'
                WHERE   CAST(CreatedOn AS DATE) = CAST(@CurrnetDate AS DATE)
                        AND ActivityId = @ActivityId
						AND ISNULL(Am.IsDisabled,0) = 0;
            END;
            
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
                                AND QuestionTypeId IN ( 5, 6, 7, 18, 21 )
								AND DisplayInTableView = 1
                                --AND IsActive = 1
                                AND IsDeleted = 0
								ORDER BY Position ASC /* Added By Disha - 03-OCT-2016 */

                INSERT  INTO @Result
                        ( Id ,
                          QuestionTitle ,
                          [Count] ,
                          QuestionId ,
                          CurrentDate
                        )
                        SELECT  -2 ,
                                TableGroupName ,
                                @TotalEntry ,
                                -2 ,
                                @CurrnetDate
                        FROM    dbo.Questions
                        WHERE   QuestionnaireId = @QuestionnaireId
                                AND QuestionTypeId = 19
                                --AND IsActive = 1
                                AND IsDeleted = 0
                                AND TableGroupName IS NOT NULL
                                AND TableGroupName <> ''
                        GROUP BY TableGroupName;
            END;
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
                                AND QuestionTypeId IN ( 5, 6, 7, 18, 21 )
								AND DisplayInTableView = 1
                                AND IsDeleted = 0
								ORDER BY Position ASC /* Added By Disha - 03-OCT-2016 */

                INSERT  INTO @Result
                        ( Id ,
                          QuestionTitle ,
                          [Count] ,
                          QuestionId ,
                          CurrentDate
                        )
                        SELECT  -2 ,
                                TableGroupName ,
                                @TotalEntry ,
                                -2 ,
                                @CurrnetDate
                        FROM    dbo.SeenClientQuestions
                        WHERE   SeenClientId = @SeenClientId
                                AND QuestionTypeId = 19
                                AND IsDeleted = 0
                                AND TableGroupName IS NOT NULL
                                AND TableGroupName <> ''
                        GROUP BY TableGroupName;
            END;
  
        SELECT  *
        FROM    @Result;          
    END;