CREATE FUNCTION [dbo].[fn_SummaryQuestionsList_Mittal]  
(  
    @Table NVARCHAR(50), -- OUT       
    @FilterValue BIGINT  
)  
RETURNS NVARCHAR(MAX)  
BEGIN  
    DECLARE @listStr NVARCHAR(MAX);  
    DECLARE @AppndChars NVARCHAR(10);  
    --  DECLARE @NewLineChar AS CHAR(2);      
    DECLARE @listStrQuestion NVARCHAR(MAX);  
    DECLARE @Top BIGINT = 50;  
    DECLARE @IsRecurring NVARCHAR(100) = '';  
  
    -- SET @NewLineChar = CHAR(13) + CHAR(10);      
    IF (  
    --@Table = 'AnswersDetail'        
    --           OR       
    @Table = 'Answers'  
       )  
    BEGIN  
        SET @AppndChars = '';  
    END;  
    ELSE  
    BEGIN  
        SET @AppndChars = ', ';  
    END;  
  
    --  SELECT * FROM @TempTable      
    --DECLARE @TempTable TABLE      
    --IF OBJECT_ID('tempdb..#TempTable', 'u') IS NOT NULL      
    --    DROP TABLE #TempTable;      
    --CREATE TABLE #TempTable      
    DECLARE @TempTable TABLE  
    (  
        shortName NVARCHAR(MAX),  
        value NVARCHAR(MAX),  
        position INT,  
        questionId BIGINT,
		id INT  
    );  
  
    DECLARE @TempTableFinal TABLE  
    (  
        shortName NVARCHAR(MAX),  
        value NVARCHAR(MAX)  
    );  
    DECLARE @TempTableFinal1 TABLE  
    (  
        shortName NVARCHAR(MAX),  
        value NVARCHAR(MAX)  
    );  
  
    IF (@Table = 'SeenClientAnswers')  
    BEGIN  
        INSERT INTO @TempTable  
        (  
            shortName,  
            value,  
            position,  
            questionId ,
			id 
        )  
        SELECT DISTINCT  
            CASE Q.QuestionTypeId  
                WHEN 16 THEN  
                    Q.QuestionTitle  
                ELSE  
                    ShortName  
            END AS ShortName,  
            CASE Q.QuestionTypeId  
                WHEN 8 THEN  
            (CASE  
                 WHEN A.Detail IS NULL  
                      OR A.Detail = '' THEN  
                     ISNULL(A.Detail, '')  
                 ELSE  
                     dbo.ChangeDateFormat(CAST(A.Detail AS DATETIME), 'dd/MMM/yyyy')  
             END  
            )  
                WHEN 9 THEN  
            (CASE  
                 WHEN A.Detail IS NULL  
                      OR A.Detail = '' THEN  
                     ISNULL(A.Detail, '')  
                 ELSE  
                     dbo.ChangeDateFormat(A.Detail, 'hh:mm AM/PM')  
             -- FORMAT(CAST(A.Detail AS DATETIME), 'hh:mm tt')      
             END  
            )  
                WHEN 22 THEN  
            (CASE  
                 WHEN A.Detail IS NULL  
                      OR A.Detail = '' THEN  
                     ISNULL(A.Detail, '')  
                 ELSE  
                     dbo.ChangeDateFormat(A.Detail, 'dd/MMM/yyyy hh:mm AM/PM')  
             --FORMAT(CAST(A.Detail AS DATETIME), 'dd/MMM/yyyy hh:mm tt')      
             END  
            )  
                WHEN 1 THEN  
                -- dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, 1)      
                (  
                    SELECT ISNULL(Name, '')  
                    FROM dbo.SeenClientOptions  
                    WHERE QuestionId = A.QuestionId  
                          AND Value = A.Detail  
                )  
                ELSE  
                    ISNULL(Detail, '')  
            END + @AppndChars,  
            Q.Position,  
            Q.Id  ,
			a.SeenClientAnswerChildId
        FROM dbo.SeenClientAnswerMaster AS AM WITH (NOLOCK)  
            INNER JOIN dbo.SeenClient AS Qr WITH (NOLOCK)  
                ON AM.SeenClientId = Qr.Id  
                   AND AM.Id = @FilterValue  
            INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)  
                ON Qr.Id = Q.SeenClientId  
                   AND Q.IsDisplayInSummary = 1  
                   AND Q.IsDeleted = 0  
                   AND Q.IsDeleted IS NOT NULL  
            LEFT OUTER JOIN dbo.SeenClientAnswers AS A WITH (NOLOCK)  
                ON AM.Id = A.SeenClientAnswerMasterId  
                   AND Q.Id = A.QuestionId;  
    END;  
  
    --ELSE        
    --    IF ( @Table = 'SeenClientAnswersDetail' )        
    --        BEGIN         
    --            INSERT  INTO @TempTable        
    --                    ( shortName ,        
    --                      value ,        
    --                      position ,        
    --                      questionId        
    --                    )        
    --                    SELECT  DISTINCT        
    --                            ShortName ,        
    --                            CASE Q.QuestionTypeId        
    --                              WHEN 8        
    --                              THEN ( CASE WHEN A.Detail IS NULL        
    --                                               OR A.Detail = ''        
    --                                          THEN ISNULL(A.Detail, '')        
    --                                          ELSE dbo.ChangeDateFormat(A.Detail,        
    --                                                      'dd/MMM/yyyy')        
    --                                     END )        
    --                              WHEN 9        
    --                              THEN ( CASE WHEN A.Detail IS NULL        
    --                                               OR A.Detail = ''        
    --                                          THEN ISNULL(A.Detail, '')        
    --                                          ELSE dbo.ChangeDateFormat(A.Detail,        
    --                                                      'hh:mm AM/PM')        
    --                                     END )        
    --                              WHEN 22        
    --                              THEN ( CASE WHEN A.Detail IS NULL        
    --                                               OR A.Detail = ''        
    --                                          THEN ISNULL(A.Detail, '')        
    --                                          ELSE dbo.ChangeDateFormat(A.Detail,        
    --                                                      'dd/MMM/yyyy hh:mm AM/PM')        
    --                                     END )        
    --                              WHEN 1        
    --                              THEN dbo.GetOptionNameByQuestionId(A.QuestionId,        
    --                                                      A.Detail, 1)        
    --                              ELSE ISNULL(Detail, '')        
    --                            END + @AppndChars ,        
    --                            Q.Position ,        
    --                            Q.Id        
    --                    FROM    dbo.SeenClientAnswerMaster AS AM        
    --                            INNER JOIN dbo.SeenClient AS Qr ON AM.SeenClientId = Qr.Id        
    --                            INNER JOIN dbo.SeenClientQuestions AS Q ON Qr.Id = Q.SeenClientId        
    --                            LEFT OUTER JOIN dbo.SeenClientAnswers AS A ON AM.Id = A.SeenClientAnswerMasterId        
    --                                                      AND Q.Id = A.QuestionId        
    --                    WHERE   Q.IsDisplayInDetail = 1        
    --                            AND Q.QuestionTypeId <> 16        
    --                            AND AM.Id = @FilterValue        
    --                            AND ISNULL(Q.IsDeleted, 0) = 0        
    --                            AND ISNULL(A.IsDeleted, 0) = 0;        
    --        END;          
  
    ELSE IF (@Table = 'Answers')  
    BEGIN  
        DECLARE @QuestionnaireFormType NVARCHAR(20) = '';  
        SELECT @QuestionnaireFormType = QUE.QuestionnaireFormType  
        FROM dbo.Questionnaire QUE WITH (NOLOCK)  
            INNER JOIN dbo.AnswerMaster AM WITH (NOLOCK)  
                ON AM.QuestionnaireId = QUE.Id  
                   AND AM.Id = @FilterValue;  
        IF @QuestionnaireFormType = 'Customer'  
        BEGIN  
            INSERT INTO @TempTable  
            (  
                shortName,  
                value,  
                position,  
                questionId  
            )  
            SELECT DISTINCT  
                CASE Q.QuestionTypeId  
               WHEN 16 THEN  
                        Q.QuestionTitle  
                    ELSE  
                        ShortName  
                END AS ShortName,  
                CASE Q.QuestionTypeId  
                    WHEN 8 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, '')  
                     ELSE  
                         dbo.ChangeDateFormat(A.Detail, 'dd/MMM/yyyy')  
                 -- FORMAT(CAST(A.Detail AS DATETIME),'dd/MMM/yyyy')      
                 END  
                )  
                    WHEN 9 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, '')  
                     ELSE  
                         dbo.ChangeDateFormat(A.Detail, 'hh:mm AM/PM')  
                 --  FORMAT(CAST(A.Detail AS DATETIME),'hh:mm tt')      
                 END  
                )  
                    WHEN 22 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, '')  
                     ELSE  
                         dbo.ChangeDateFormat(A.Detail, 'dd/MMM/yyyy hh:mm AM/PM')  
                 -- FORMAT(CAST(A.Detail AS DATETIME),'dd/MMM/yyyy hh:mm AM/PM')      
                 END  
                )  
                    WHEN 1 THEN  
                    dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, 0)      
                    --(  
                      --  SELECT ISNULL(Name, '')  
                       -- FROM dbo.Options  
                       -- WHERE QuestionId = A.QuestionId  
                        --      AND Value = A.Detail  
                   -- )  
                    WHEN 10 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, 'Anonymous')  
                     ELSE  
                         A.Detail  
                 END  
                )  
                    WHEN 11 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, 'Anonymous')  
                     ELSE  
                         A.Detail  
                 END  
                )  
                    ELSE  
                        ISNULL(A.Detail,'')  
                END + @AppndChars,  
                Q.Position,  
                Q.Id  
            FROM dbo.AnswerMaster AS AM WITH (NOLOCK)  
                INNER JOIN dbo.Questionnaire AS Qr WITH (NOLOCK)  
                    ON AM.QuestionnaireId = Qr.Id  
                       AND AM.Id = @FilterValue   
                INNER JOIN dbo.Questions AS Q WITH (NOLOCK)  
                    ON Qr.Id = Q.QuestionnaireId  
                LEFT OUTER JOIN dbo.Answers AS A  
                    ON AM.Id = A.AnswerMasterId  
                       AND Q.Id = A.QuestionId   
          WHERE Am.Id = @FilterValue  
          AND Q.IsDisplayInSummary = 1  
          AND Q.QuestionTypeId NOT IN ( 25 )  
          AND (  
                  A.Id IS NOT NULL  
                  OR (  
                         Q.QuestionTypeId IN ( 16, 23 )  
                         AND Q.IsDeleted = 0  
       AND Q.IsDeleted IS NOT NULL  
                     )  
              )  
        END;  
        ELSE  
        BEGIN  
            INSERT INTO @TempTable  
            (  
                shortName,  
                value,  
                position,  
                questionId  
            )  
            SELECT DISTINCT  
                CASE Q.QuestionTypeId  
                    WHEN 16 THEN  
                        Q.QuestionTitle  
                    ELSE  
                        ShortName  
                END AS ShortName,  
                CASE Q.QuestionTypeId  
                    WHEN 8 THEN  
            (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, '')  
                     ELSE  
                         dbo.ChangeDateFormat(A.Detail, 'dd/MMM/yyyy')  
                 --FORMAT(CAST(a.Detail AS DATETIME),'dd/MMM/yyyy')      
                 END  
                )  
                    WHEN 9 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, '')  
                     ELSE  
                         dbo.ChangeDateFormat(A.Detail, 'hh:mm AM/PM')  
                 --FORMAT(CAST(a.Detail AS DATETIME),'hh:mm tt')      
                 END  
                )  
                    WHEN 22 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, '')  
                     ELSE  
                         dbo.ChangeDateFormat(A.Detail, 'dd/MMM/yyyy hh:mm AM/PM')  
                 --FORMAT(CAST(a.Detail AS DATETIME),'dd/MMM/yyyy hh:mm AM/PM')      
                 END  
                )  
                    WHEN 1 THEN  
                    --dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, 0)      
                    (  
                        SELECT Name  
                        FROM dbo.Options  
                        WHERE QuestionId = A.QuestionId  
                              AND Value = A.Detail  
                    )  
                    WHEN 10 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, 'Anonymous')  
                     ELSE  
                         A.Detail  
                 END  
                )  
                    WHEN 11 THEN  
                (CASE  
                     WHEN A.Detail IS NULL  
                          OR A.Detail = '' THEN  
                         ISNULL(A.Detail, 'Anonymous')  
                     ELSE  
                         A.Detail  
                 END  
                )  
                    ELSE  
                        A.Detail  
                END + @AppndChars,  
                Q.Position,  
                Q.Id  
            FROM dbo.AnswerMaster AS AM  
                INNER JOIN dbo.Questionnaire AS Qr  
                    ON AM.QuestionnaireId = Qr.Id  
                       AND AM.Id = @FilterValue  
                INNER JOIN dbo.Questions AS Q  
                    ON Qr.Id = Q.QuestionnaireId  
                       AND Q.IsDisplayInSummary = 1  
                       AND Q.IsDeleted = 0  
                       AND Q.IsDeleted IS NOT NULL  
                       AND (  
                               Q.QuestionTypeId <> 10  
                               OR Q.SeenClientQuestionIdRef IS NOT NULL  
                           )  
                       AND (  
                               Q.QuestionTypeId <> 11  
                               OR Q.SeenClientQuestionIdRef IS NOT NULL  
                           )  
                       AND (Q.IsActive = 1)  
                LEFT OUTER JOIN dbo.Answers AS A  
                    ON AM.Id = A.AnswerMasterId  
                       AND Q.Id = A.QuestionId  
               WHERE Am.Id = @FilterValue  
          AND Q.IsDisplayInSummary = 1  
          AND Q.QuestionTypeId NOT IN ( 25 )  
          AND (  
                  A.Id IS NOT NULL  
                  OR (  
                         Q.QuestionTypeId IN ( 16, 23 )  
                         AND Q.IsDeleted = 0  
       AND Q.IsDeleted IS NOT NULL  
                     )  
              )  
        END;  
  
        DECLARE @shortName NVARCHAR(MAX);  
        DECLARE @Possition BIGINT;  
        DECLARE @Questionnierid BIGINT;  
        DECLARE @QuestionId BIGINT;  
        DECLARE @Start BIGINT = 1,  
                @End BIGINT;  
  
        SELECT @Questionnierid = QuestionnaireId  
        FROM dbo.AnswerMaster WITH (NOLOCK)  
        WHERE Id = @FilterValue;  
  
        DECLARE @Reftable TABLE  
        (  
            Id BIGINT IDENTITY(1, 1),  
            SeenclientQuestionId BIGINT,  
            QuestionId BIGINT,  
            possition BIGINT,  
            shortName NVARCHAR(500)  
        );  
        INSERT @Reftable  
        (  
            SeenclientQuestionId,  
            QuestionId,  
            possition,  
            shortName  
        )  
        SELECT SeenClientQuestionIdRef,  
               Id,  
               Position,  
               ShortName  
        FROM dbo.Questions WITH (NOLOCK)  
        WHERE QuestionnaireId = @Questionnierid  
              AND SeenClientQuestionIdRef IS NOT NULL  
              AND IsDisplayInSummary = 1  
              AND (  
                      QuestionTypeId <> 10  
                      OR SeenClientQuestionIdRef IS NOT NULL  
                  )  
              AND (  
                      QuestionTypeId <> 11  
                      OR SeenClientQuestionIdRef IS NOT NULL  
                  )  
              AND IsDeleted = 0  
              AND IsActive = 0;  
  
        --      SELECT * FROM #TempTable      
        --      SELECT @End = COUNT(1)      
        --      FROM #Reftable;      
        --      WHILE (@Start <= @End)      
        --      BEGIN      
        ----PRINT 1      
        --          SELECT @QuestionId = QuestionId,      
        --                 @shortName = shortName,      
        --                 @Possition = possition      
        --          FROM #Reftable      
        --          WHERE Id = @Start;      
  
        UPDATE @TempTable  
        SET value = ''  
        WHERE value = 'Anonymous';  
  
        INSERT INTO @TempTable  
        (  
            shortName,  
            value,  
            position,  
            questionId  
        )  
        SELECT B.shortName,  
               A.Detail + @AppndChars,  
               B.possition,  
               A.QuestionId  
        FROM dbo.SeenClientAnswers A WITH (NOLOCK)  
            INNER JOIN @Reftable B  
                ON A.QuestionId = B.SeenclientQuestionId  
        WHERE SeenClientAnswerMasterId IN (  
                                              SELECT SeenClientAnswerMasterId  
                                              FROM dbo.AnswerMaster WITH (NOLOCK)  
                                              WHERE Id = @FilterValue  
                                          )  
              AND (  
                      (ISNULL(SeenClientAnswerChildId, 0) = 0)  
                      OR SeenClientAnswerChildId IN (  
                                                        SELECT SeenClientAnswerChildId  
                                                        FROM dbo.AnswerMaster WITH (NOLOCK)  
                                                        WHERE Id = @FilterValue  
                                                    )  
                  );  
    --AND   QuestionId IN      
    --               (      
    --                   SELECT SeenclientQuestionId FROM #Reftable --WHERE Id = @Start      
    --               );      
  
    --SELECT @shortName,      
    --       Detail + @AppndChars,      
    --       @Possition,      
    --       QuestionId      
    --FROM dbo.SeenClientAnswers WITH (NOLOCK)      
    --WHERE SeenClientAnswerMasterId IN (      
    --                                      SELECT SeenClientAnswerMasterId      
    --                                      FROM dbo.AnswerMaster WITH (NOLOCK)      
    --                                      WHERE Id = @FilterValue      
    --                                  )      
    --      AND (      
    --              (ISNULL(SeenClientAnswerChildId, 0) = 0)      
    --              OR SeenClientAnswerChildId IN (      
    --                                                SELECT SeenClientAnswerChildId      
    --                                                FROM dbo.AnswerMaster WITH (NOLOCK)      
    --                    WHERE Id = @FilterValue      
    --                                            )      
    --          )      
    --      AND QuestionId =      
    --      (      
    --          SELECT SeenclientQuestionId FROM #Reftable WHERE Id = @Start      
    --      );      
    --SET @Start = @Start + 1;      
    --END;      
    END;  
    --  ELSE      
    --                    IF ( @Table = 'AnswersDetail' )        
    --                        BEGIN        
    --                            INSERT  INTO @TempTable        
    --                                    ( shortName ,        
    --                                      value ,        
    --                                      position ,        
    --                                      questionId        
    --                              )        
    --                                    SELECT DISTINCT        
    --                                            Q.ShortName ,        
    --                                            CASE Q.QuestionTypeId        
    --                                              WHEN 8        
    --                                              THEN ( CASE WHEN A.Detail IS NULL        
    --                                                              OR A.Detail = ''        
    --                                                          THEN ISNULL(A.Detail,        
    --                                                              '')        
    --                                                          ELSE dbo.ChangeDateFormat(A.Detail,        
    --                                                              'dd/MMM/yyyy')        
    --                                                     END )        
    --                                              WHEN 9        
    --                                              THEN ( CASE WHEN A.Detail IS NULL        
    --                                                              OR A.Detail = ''        
    --                                                          THEN ISNULL(A.Detail,        
    --                                                              '')        
    --                                                          ELSE dbo.ChangeDateFormat(A.Detail,        
    --                                                              'hh:mm AM/PM')        
    --                                                     END )        
    --                                              WHEN 22        
    --                                              THEN ( CASE WHEN A.Detail IS NULL        
    --                                                              OR A.Detail = ''        
    --                                                          THEN ISNULL(A.Detail,        
    --                                                              '')        
    --                                                          ELSE dbo.ChangeDateFormat(A.Detail,        
    --                                                              'dd/MMM/yyyy hh:mm AM/PM')        
    --                                                     END )        
    --                                              WHEN 1        
    --                                              THEN dbo.GetOptionNameByQuestionId(A.QuestionId,        
    --                                                              A.Detail, 0)        
    --                                              WHEN 10        
    --                                              THEN CASE A.Detail        
    --                                                     WHEN '' THEN 'Anonymous'        
    --                                                   END        
    --                                              WHEN 11        
    --                                              THEN CASE A.Detail        
    --                                                     WHEN '' THEN 'Anonymous'        
    --                                                   END            --                                              ELSE ISNULL(Detail, '')        
    --                                            END + @AppndChars ,        
    --                                            Q.Position ,        
    --                                            Q.Id        
    --                                    FROM    dbo.AnswerMaster AS AM        
    --                                            INNER JOIN dbo.Questionnaire AS Qr ON AM.QuestionnaireId = Qr.Id        
    --                                            INNER JOIN dbo.Questions AS Q ON Qr.Id = Q.QuestionnaireId        
    --                                            LEFT OUTER JOIN dbo.Answers AS A ON AM.Id = A.AnswerMasterId        
    --                                       AND Q.Id = A.QuestionId        
    --                                    WHERE   Q.IsDisplayInDetail = 1        
    --                                            AND Q.QuestionTypeId <> 16        
    --                                            AND AM.Id = @FilterValue        
    --                                            AND ISNULL(Q.IsDeleted, 0) = 0        
    --                                            AND ISNULL(A.IsDeleted, 0) = 0;         
  
    --                            SET @Start = 1;         
  
    --                            SELECT  @Questionnierid = QuestionnaireId        
    --                            FROM    dbo.AnswerMaster        
    --                            WHERE   Id = @FilterValue;        
  
    --                            INSERT  @Reftable        
    --                                    ( SeenclientQuestionId ,        
    --                                      QuestionId ,        
    --                                      possition ,        
    --                                      shortName        
    --               )        
    --                                    SELECT  SeenClientQuestionIdRef ,        
    --                                            Id ,        
    --                                            Position ,        
    --                                            ShortName        
    --                                    FROM    dbo.Questions        
    --                                    WHERE   QuestionnaireId = @Questionnierid        
    --                                            AND SeenClientQuestionIdRef IS NOT NULL        
    --                                            AND IsDeleted = 0        
    --                                            AND IsActive = 0        
    --                                            AND IsDisplayInDetail = 1        
    --                                            AND ( QuestionTypeId <> 10        
    --                                                  OR SeenClientQuestionIdRef IS NOT NULL        
    --                                                )        
    --                                            AND ( QuestionTypeId <> 11        
    --                                                  OR SeenClientQuestionIdRef IS NOT NULL        
    --                                                );        
  
    --                            SELECT  @End = COUNT(*)        
    --                            FROM    @Reftable;        
    --                            WHILE ( @Start <= @End )        
    --                                BEGIN        
    --                                    SELECT  @QuestionId = QuestionId ,        
    --                                            @shortName = shortName ,        
    --                                            @Possition = possition        
    --                                    FROM    @Reftable        
    --                                    WHERE   Id = @Start;        
    --                                    INSERT  INTO @TempTable        
    --                                            ( shortName ,        
    --                                              value ,        
    --                   position ,        
    --                                              questionId        
    --                 )        
    --                                            SELECT  @shortName ,        
    --                                                    Detail + @AppndChars ,        
    --                                                    @Possition ,        
    --                                                    QuestionId        
    --                                            FROM    dbo.SeenClientAnswers        
    --                                            WHERE   SeenClientAnswerMasterId IN (        
    --                                                    SELECT  SeenClientAnswerMasterId        
    --            FROM    dbo.AnswerMaster        
    --                                                    WHERE   Id = @FilterValue )        
    --                                                    AND ( ( ISNULL(SeenClientAnswerChildId,        
    --                                                              0) = 0 )        
    --                                                          OR SeenClientAnswerChildId IN (        
    --                                                          SELECT        
    --                                                              SeenClientAnswerChildId        
    --                                                          FROM        
    --                                                           dbo.AnswerMaster        
    --                                                          WHERE        
    --                                                              Id = @FilterValue )        
    --                                                        )        
    --                                                    AND QuestionId = ( SELECT        
    --                                                              SeenclientQuestionId        
    --                                                              FROM        
    --                                                              @Reftable        
    --                                                              WHERE        
    --                                                              Id = @Start        
    --                                                              );        
    --                                    SET @Start = @Start + 1;        
    --                                END;        
    ----------------------------------------------------        
    --                        END;        
  
    INSERT INTO @TempTableFinal  
    (  
        shortName,  
        value  
    )  
    SELECT shortName,  
           value  
    FROM @TempTable  
    GROUP BY shortName,  
             value,  
             position  
    ORDER BY position;  
    INSERT INTO @TempTableFinal1  
    (  
        shortName,  
        value  
    )  
    SELECT Main.shortName,  
           CASE  
               WHEN (  
           -- @Table = 'AnswersDetail'        
           --         OR       
           @Table = 'Answers'  
                    ) THEN  
                   LTRIM(RTRIM(Main.Students)) + '\n'  
               ELSE  
                   LEFT(Main.Students, LEN(Main.Students) - 1) + '\n'  
           END AS "Students"  
    FROM  
    (  
        SELECT DISTINCT  
            ST2.position,  
            ST2.shortName,  
            (  
                SELECT ST1.value + ' ' AS [text()]  
                FROM @TempTable ST1  
                WHERE ST1.questionId = ST2.questionId  
                ORDER BY ST1.id,ST1.position  
                FOR XML PATH(''), TYPE  
            ).value('.[1]', 'nvarchar(max)') [Students]  
        FROM @TempTable ST2  
    ) [Main]  
    ORDER BY Main.position;  
  
  
    --DECLARE @Conversation VARCHAR(2000);        
    DECLARE @FinalConversation VARCHAR(2000);  
    --DECLARE @UserName VARCHAR(500);        
    --DECLARE @Attachment VARCHAR(1000);        
  
    --* Create Temp Table for Last Action Display from In-Out with reference. *        
    DECLARE @ReportId BIGINT;  
    DECLARE @Isout BIT;  
    DECLARE @ReportIDTable TABLE  
    (  
        ReportId BIGINT,  
        Id BIGINT,  
        IsOut BIT  
    );  
  
    IF (@Table = 'SeenClientAnswers'  
       --OR @Table = 'SeenClientAnswersDetail'        
       )  
    BEGIN  
  
        INSERT INTO @ReportIDTable  
        (  
            ReportId,  
            Id,  
            IsOut  
        )  
        SELECT Am.Id,  
               LA.Id,  
               1  
        FROM dbo.CloseLoopAction AS LA WITH (NOLOCK)  
            INNER JOIN dbo.AppUser AS U WITH (NOLOCK)  
                ON LA.AppUserId = U.Id  
                   AND LA.SeenClientAnswerMasterId = @FilterValue  
                   AND LA.IsNote = 0  
            INNER JOIN dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)  
                ON Am.Id = LA.SeenClientAnswerMasterId  
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)  
                ON E.Id = Am.EstablishmentId  
        UNION  
        SELECT Am.Id,  
               LA.Id,  
               0  
        FROM dbo.CloseLoopAction AS LA WITH (NOLOCK)  
            INNER JOIN dbo.AppUser AS U WITH (NOLOCK)  
                ON LA.AppUserId = U.Id  
                   AND LA.IsNote = 0  
            INNER JOIN dbo.AnswerMaster AS Am WITH (NOLOCK)  
                ON Am.Id = LA.AnswerMasterId  
                   AND Am.SeenClientAnswerMasterId = @FilterValue  
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)  
                ON E.Id = Am.EstablishmentId;  
  
  
  
        SELECT TOP 1  
            @ReportId = ReportId,  
            @Isout = IsOut  
        FROM @ReportIDTable  
        ORDER BY Id DESC;  
  
    --SELECT TOP 1        
    --        @Conversation = [Conversation] ,        
    --        @UserName = AU.Name ,        
    --        @Attachment = CLA.Attachment        
    --FROM    dbo.CloseLoopAction AS CLA        
    --        INNER JOIN dbo.AppUser AS AU ON AU.Id = CLA.AppUserId        
    --WHERE   ( CASE @Isout        
    --            WHEN 1 THEN CLA.SeenClientAnswerMasterId        
    --            ELSE CLA.AnswerMasterId        
    --          END ) = @ReportId AND CLA.IsNote = 0        
    --ORDER BY CLA.Id DESC;         
    --IF ( ISNULL(@Conversation, '') = ''        
    --     AND @Attachment != ''        
    --   )        
    --    BEGIN        
    --         SELECT  @FinalConversation =  '*' + @UserName + ': '+ 'Attachment'+ @Conversation;        
    --    END;        
    --ELSE        
    --    IF ( @Conversation IS NOT NULL )        
    --        BEGIN        
    --             SELECT  @FinalConversation =  '*' + @UserName + ': '+ @Conversation;        
    --        END;        
    --    ELSE        
    --        BEGIN        
    --            SELECT  @FinalConversation = NULL;        
    --        END;        
    END;  
    ELSE  
    BEGIN  
  
        INSERT INTO @ReportIDTable  
        (  
            ReportId,  
            Id,  
            IsOut  
        )  
        SELECT Am.Id,  
               LA.Id,  
               0  
        FROM dbo.CloseLoopAction AS LA WITH (NOLOCK)  
            INNER JOIN dbo.AppUser AS U WITH (NOLOCK)  
                ON LA.AppUserId = U.Id  
                   AND LA.AnswerMasterId = @FilterValue  
                   AND LA.IsNote = 0  
            INNER JOIN dbo.AnswerMaster AS Am WITH (NOLOCK)  
                ON Am.Id = LA.AnswerMasterId  
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)  
                ON E.Id = Am.EstablishmentId  
        UNION  
        SELECT Am.Id,  
               LA.Id,  
               0  
        FROM dbo.CloseLoopAction AS LA WITH (NOLOCK)  
            INNER JOIN dbo.AppUser AS U WITH (NOLOCK)  
                ON LA.AppUserId = U.Id  
                   AND LA.IsNote = 0  
            INNER JOIN dbo.AnswerMaster AS Am WITH (NOLOCK)  
                ON Am.Id = LA.AnswerMasterId  
                   AND Am.SeenClientAnswerMasterId =  
                   (  
                       SELECT ISNULL(SeenClientAnswerMasterId, 0)  
                       FROM AnswerMaster WITH (NOLOCK)  
                       WHERE Id = @FilterValue  
                   )  
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)  
                ON E.Id = Am.EstablishmentId  
        UNION  
        SELECT Am.Id,  
               LA.Id,  
               1  
        FROM dbo.CloseLoopAction AS LA WITH (NOLOCK)  
            INNER JOIN dbo.AppUser AS U WITH (NOLOCK)  
                ON LA.AppUserId = U.Id  
                   AND LA.SeenClientAnswerMasterId =  
                   (  
                       SELECT ISNULL(SeenClientAnswerMasterId, 0)  
                       FROM dbo.AnswerMaster WITH (NOLOCK)  
                       WHERE Id = @FilterValue  
                   )  
                   AND LA.IsNote = 0  
            INNER JOIN dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)  
                ON Am.Id = LA.SeenClientAnswerMasterId  
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)  
                ON E.Id = Am.EstablishmentId  
    ORDER BY Am.Id ASC;  
  
  
        SELECT TOP 1  
            @ReportId = ReportId,  
            @Isout = IsOut  
        FROM @ReportIDTable  
        ORDER BY Id ASC;  
  
  
    --SELECT TOP 1        
    --        @Conversation = [Conversation] ,        
    --        @UserName = AU.Name ,        
    --        @Attachment = CLA.Attachment        
    --FROM    dbo.CloseLoopAction AS CLA        
    --        INNER JOIN dbo.AppUser AS AU ON AU.Id = CLA.AppUserId        
    --WHERE   ( CASE @Isout        
    --            WHEN 1 THEN CLA.SeenClientAnswerMasterId        
    --            ELSE CLA.AnswerMasterId        
    --          END ) = @ReportId AND CLA.IsNote = 0        
    --ORDER BY CLA.Id DESC;        
    --IF ( ISNULL(@Conversation, '') = ''        
    --     AND @Attachment != ''        
    --   )        
    --    BEGIN        
    --        SELECT  @FinalConversation =  '*' + @UserName + ': '+ 'Attachment'+ @Conversation;        
    --    END;         
    --ELSE        
    --    IF ( @Conversation IS NOT NULL )        
    --        BEGIN        
    --            SELECT  @FinalConversation =  '*' + @UserName + ': '+ @Conversation;        
    --        END;        
    --    ELSE        
    --        BEGIN        
    --            SELECT  @FinalConversation = NULL;        
    --        END;        
    END;  
  
    IF (@Table = 'SeenClientAnswers')  
    BEGIN  
        IF EXISTS  
        (  
            SELECT 1  
            FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)  
            WHERE Id = @FilterValue  
                  AND IsRecursion = 1  
        )  
        BEGIN  
            SET @IsRecurring = '\nRecurring\n';  
        END;  
    END;  
  
    IF (@FinalConversation IS NOT NULL)  
    BEGIN  
        SELECT @listStr = COALESCE(@listStr, '') + shortName + ': ' + T.value + ''  
        FROM @TempTableFinal1 AS T;  
        SELECT @listStr = @listStr + @IsRecurring + '\n' + @FinalConversation + '\n';  
        IF @listStr IS NULL  
        BEGIN  
            SELECT @listStr = @IsRecurring + '\n' + @FinalConversation + '\n';  
        END;  
    END;  
    ELSE  
    BEGIN  
        SELECT @listStr = COALESCE(@listStr, '') + shortName + ': ' + T.value + ''  
        FROM @TempTableFinal1  
AS          T;  
        SELECT @listStr = @listStr + @IsRecurring + '\n';  
    END;  
  
   
    --SELECT ISNULL(@listStr, ' ');      
    RETURN ISNULL(@listStr, ' ');  
--END;      
END;  