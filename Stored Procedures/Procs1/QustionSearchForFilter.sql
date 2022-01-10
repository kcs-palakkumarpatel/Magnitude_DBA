-- =============================================
-- Author:			Vasudev
-- Create date:	17-Nov-2017
-- Description:	<Question Search for Analytics filter>
-- Call:					Exec dbo.QustionSearchForFilter '11601','12742~6~yes|11789~3~no', 1
-- =============================================
CREATE PROCEDURE dbo.QustionSearchForFilter
    @EstablishmentId VARCHAR(1000) ,
    @QuestionSearch VARCHAR(1000) ,
    @Isout BIT
AS
    BEGIN

        DECLARE @MainTable TABLE
            (
              id INT IDENTITY(1, 1) ,
              Details VARCHAR(1000)
            );

        INSERT  @MainTable
                ( Details
                )
                SELECT  Data
                FROM    dbo.Split(@QuestionSearch, '|');

        DECLARE @S INT ,
            @E INT;

        SELECT  @E = COUNT(1)
        FROM    @MainTable;

        DECLARE @AdvanceQuestionId TABLE
            (
              Id INT IDENTITY(1, 1) ,
              QuestionId BIGINT ,
              QuestionTypeId BIGINT ,
              Search VARCHAR(1000) ,
              Operator VARCHAR(20)
            );
        
        DECLARE @AdvanceQuestionOperator TABLE
            (
              Id INT IDENTITY(1, 1) ,
              Operator NVARCHAR(10)
            );
        
        DECLARE @AdvanceQuestionSearch TABLE
            (
              Id INT IDENTITY(1, 1) ,
              Search NVARCHAR(MAX)
            );
        DECLARE @QuestionId NVARCHAR(10); 
        DECLARE @Operator NVARCHAR(10); 
        DECLARE @SearchText NVARCHAR(MAX); 
        DECLARE @QuestionTypeId BIGINT;
        DECLARE @SqlSelect VARCHAR(MAX);
        DECLARE @Filter VARCHAR(1000);
        SET @Filter = ' where 1=1 ';
       
        SET @SqlSelect = 'Select distinct A.ReportId from dbo.View_AllAnswerMaster As A';
				
        SET @S = 1;

        WHILE @S <= @E
            BEGIN
                IF ( @QuestionSearch <> ''
                     AND @QuestionSearch IS NOT NULL
                   )
                    BEGIN
                        INSERT  INTO @AdvanceQuestionId
                                ( QuestionId
                                )
                                SELECT TOP 1  Data
                                FROM    dbo.Split(( SELECT  Details
                                                    FROM    @MainTable
                                                    WHERE   id = @S
                                                  ), '~')
                                WHERE   Id % 3 = 1;

                        INSERT  INTO @AdvanceQuestionOperator
                                ( Operator
                                )
                                SELECT  TOP 1   Data
                                FROM    dbo.Split(( SELECT  Details
                                                    FROM    @MainTable
                                                    WHERE   id = @S
                                                  ), '~')
                                WHERE   Id % 3 = 2;


                        INSERT  INTO @AdvanceQuestionSearch
                                ( Search
                                )
                                SELECT  Data
                                FROM    dbo.Split(( SELECT  Details
                                                    FROM    @MainTable
                                                    WHERE   id = @S
                                                  ), '~')
                                WHERE   Id % 3 = 0;

                        IF @Isout = 0
                            BEGIN
                                UPDATE  AQ
                                SET     AQ.QuestionTypeId = Q.QuestionTypeId
                                FROM    @AdvanceQuestionId AS AQ
                                        INNER JOIN dbo.Questions AS Q ON Q.Id = AQ.QuestionId;
                            END;
                        ELSE
                            IF @Isout = 1
                                BEGIN
                                    UPDATE  AQ
                                    SET     AQ.QuestionTypeId = Q.QuestionTypeId
                                    FROM    @AdvanceQuestionId AS AQ
                                            INNER JOIN dbo.SeenClientQuestions
                                            AS Q ON Q.Id = AQ.QuestionId;
                                END;


                        BEGIN
                            SELECT  @QuestionId = QuestionId
                            FROM    @AdvanceQuestionId
                            WHERE   Id = @S;
                        
                            IF @Isout = 0
                                BEGIN
                                    SET @SqlSelect += ' LEFT OUTER JOIN dbo.Answers AS Ans'
                                        + @QuestionId + ' ON Ans'
                                        + @QuestionId
                                        + '.AnswerMasterId = A.ReportId AND A.IsOut = 0 AND Ans'
                                        + @QuestionId + '.QuestionId = '
                                        + @QuestionId;
                                    SET @SqlSelect += 'OUTER APPLY dbo.Split(ISNULL(Ans'
                                        + @QuestionId
                                        + '.Detail, ''''), '','') AS OAns'
                                        + @QuestionId;
                                END;
                            ELSE
                                BEGIN
                                    SET @SqlSelect += ' LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns'
                                        + @QuestionId + ' ON SeenAns'
                                        + @QuestionId
                                        + '.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1 AND SeenAns'
                                        + @QuestionId + '.QuestionId = '
                                        + @QuestionId;
                                    SET @SqlSelect += 'OUTER APPLY dbo.Split(ISNULL(SeenAns'
                                        + @QuestionId
                                        + '.Detail, ''''), '','') AS OSeenAns'
                                        + @QuestionId;
                                END;
                        END;
                    END;
                SET @S += 1;
            END;
            
								

        UPDATE  AQ
        SET     AQ.Search = S.Search
        FROM    @AdvanceQuestionId AS AQ
                INNER JOIN @AdvanceQuestionSearch AS S ON AQ.Id = S.Id;
                    
        UPDATE  AQ
        SET     AQ.Operator = AO.Operator
        FROM    @AdvanceQuestionId AS AQ
                INNER JOIN @AdvanceQuestionOperator AS AO ON AQ.Id = AO.Id;						
							


        IF ( @QuestionSearch <> ''
             AND @QuestionSearch IS NOT NULL
           )
            BEGIN
                SET @S = 1;
                WHILE @S <= @E
                    BEGIN
                        SELECT  @QuestionId = QuestionId ,
                                @QuestionTypeId = QuestionTypeId
                        FROM    @AdvanceQuestionId
                        WHERE   Id = @S;

                        SELECT  @Operator = Operator
                        FROM    @AdvanceQuestionId
                        WHERE   Id = @S;

                        SELECT  @SearchText = Search
                        FROM    @AdvanceQuestionId
                        WHERE   Id = @S;

                        IF @QuestionTypeId IN ( 1, 2, 19 )
                            BEGIN
                                SET @Filter += ' AND ('
                                    + ( CASE @Isout
                                          WHEN 0 THEN 'Ans'
                                          ELSE 'SeenAns'
                                        END ) + @QuestionId + '.Detail = ' + @SearchText + ' )';
                            END;
                        ELSE
                            IF @QuestionTypeId IN ( 5, 6, 18, 21 )
                                BEGIN
                                    SET @Filter += 'AND ('
                                        + ( CASE @Isout
                                              WHEN 0 THEN 'OAns'
                                              ELSE ' OSeenAns'
                                            END ) + @QuestionId
                                        + '.Data IN ( SELECT Data FROM dbo.Split('''
                                        + @SearchText + ''', '','')) )';
                                END;
                            ELSE
                                BEGIN
                                    SET @Filter += ' AND ('',''+'
                                        + ( CASE @Isout
                                              WHEN 0 THEN 'ISNULL(Ans'
                                              ELSE 'ISNULL(SeenAns'
                                            END ) + @QuestionId
                                        + '.Detail,'' '')+'','' LIKE ''%'
                                        + CASE @QuestionTypeId
                                            WHEN 22
                                            THEN dbo.ChangeDateFormat(@SearchText,
                                                              'yyyy-MM-dd HH:MM')
                                            ELSE ( CASE @SearchText
                                                     WHEN '' THEN ' '
                                                     ELSE @SearchText
                                                   END )
                                          END + '%'' )';
                                END;
								
                        SET @S += 1;
                    END;

            END;

        EXEC (@SqlSelect + @Filter);

    END;
