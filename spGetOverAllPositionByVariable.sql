-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Sep 2015>
-- Description:	<Description,,>
-- Call SP:		spGetOverAllPositionByVariable 1, '2', '01 Jan 2015', '10 Sep 2015', 0
-- =============================================
CREATE PROCEDURE [dbo].[spGetOverAllPositionByVariable]
    @EstablishmentId BIGINT ,
    @GroupId NVARCHAR(MAX) ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @IsOut BIT
AS
    BEGIN
        DECLARE @QuestionnaireId BIGINT ,
            @SeenClientId BIGINT;

        DECLARE @MaxPosition INT;

        SELECT  @QuestionnaireId = Eg.QuestionnaireId ,
                @SeenClientId = Eg.SeenClientId
        FROM    dbo.Establishment AS E
                INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
        WHERE   E.Id = @EstablishmentId;

        SET @GroupId += ',' + CONVERT(NVARCHAR(10), @EstablishmentId);

        DECLARE @Result TABLE
            (
              QuestionId BIGINT NOT NULL ,
              QuestionTitle NVARCHAR(500) NOT NULL ,
              Position INT NOT NULL ,
              EstablishmentId BIGINT NOT NULL
            );

        DECLARE @Questions TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              QuestionTitle NVARCHAR(500) ,
              QuestionId BIGINT
            );
        IF @IsOut = 0
            BEGIN
                INSERT  INTO @Questions
                        ( QuestionTitle ,
                          QuestionId
                        )
                        SELECT  ShortName ,
                                Id
                        FROM    dbo.Questions
                        WHERE   QuestionnaireId = @QuestionnaireId
                                AND QuestionTypeId = 1
                                AND IsDeleted = 0;
            END;
        ELSE
            BEGIN
                INSERT  INTO @Questions
                        ( QuestionTitle ,
                          QuestionId
                        )
                        SELECT  ShortName ,
                                Id
                        FROM    dbo.SeenClientQuestions
                        WHERE   SeenClientId = @SeenClientId
                                AND QuestionTypeId = 1
                                AND IsDeleted = 0;
            END;


        DECLARE @Start INT = 1 ,
            @End INT;

        DECLARE @QuestionId BIGINT ,
            @QuestionTitle NVARCHAR(500);

        SELECT  @End = COUNT(1)
        FROM    @Questions;

        WHILE ( @Start <= @End )
            BEGIN
                SELECT  @QuestionId = QuestionId ,
                        @QuestionTitle = QuestionTitle
                FROM    @Questions
                WHERE   Id = @Start;
                IF @IsOut = 0
                    BEGIN
                        INSERT  INTO @Result
                                ( QuestionId ,
                                  QuestionTitle ,
                                  Position ,
                                  EstablishmentId
				                )
                                SELECT  @QuestionId ,
                                        @QuestionTitle ,
                                        ROW_NUMBER() OVER ( ORDER BY [R].[Count] DESC ) AS [Rank] ,
                                        R.EstablishmentId
                                FROM    ( SELECT    Am.EstablishmentId ,
                                                    SUM(CAST(A.Detail AS INT))
                                                    * 1.0 / COUNT(1) AS [Count]
                                          FROM      dbo.Answers AS A
                                                    INNER JOIN dbo.AnswerMaster
                                                    AS Am ON Am.Id = A.AnswerMasterId
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@GroupId,
                                                              ',')
                                                              ) AS E ON E.Data = Am.EstablishmentId
                                          WHERE     A.QuestionId = @QuestionId
                                                    AND A.IsDeleted = 0
                                                    AND Am.IsDeleted = 0
                                                    AND CAST(DATEADD(MINUTE,
                                                              Am.TimeOffSet,
                                                              Am.CreatedOn) AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @ToDate
                                          GROUP BY  Am.EstablishmentId
                                        ) AS R;
                    END;
                ELSE
                    BEGIN
                        INSERT  INTO @Result
                                ( QuestionId ,
                                  QuestionTitle ,
                                  Position ,
                                  EstablishmentId
				                )
                                SELECT  @QuestionId ,
                                        @QuestionTitle ,
                                        ROW_NUMBER() OVER ( ORDER BY [R].[Count] DESC ) AS [Rank] ,
                                        R.EstablishmentId
                                FROM    ( SELECT    Am.EstablishmentId ,
                                                    SUM(CAST(A.Detail AS INT))
                                                    * 1.0 / COUNT(1) AS [Count]
                                          FROM      dbo.SeenClientAnswers AS A
                                                    INNER JOIN dbo.SeenClientAnswerMaster
                                                    AS Am ON Am.Id = A.SeenClientAnswerMasterId
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@GroupId,
                                                              ',')
                                                              ) AS E ON E.Data = Am.EstablishmentId
                                          WHERE     A.QuestionId = @QuestionId
                                                    AND A.IsDeleted = 0
                                                    AND Am.IsDeleted = 0
                                                    AND CAST(DATEADD(MINUTE,
                                                              Am.TimeOffSet,
                                                              Am.CreatedOn) AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @ToDate
                                          GROUP BY  Am.EstablishmentId
                                        ) AS R;
                    END;
                SET @Start += 1;
            END;

        SELECT  @MaxPosition = MAX(Position)
        FROM    @Result;

        SELECT  * ,
                @MaxPosition + 1 - Position AS [Rank]
        FROM    @Result
        WHERE   EstablishmentId = @EstablishmentId;
    END;