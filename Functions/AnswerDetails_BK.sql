    
-- =============================================    
-- Author:  <Disha>    
-- Create date: <13-SEP-2014>    
-- Description: <get concated string values>    
-- Calls : select dbo.AnswerDetails_BK('Answers',976)
-- ============================================= 
CREATE FUNCTION [dbo].[AnswerDetails_BK]
    (
      @Table NVARCHAR(50) ,
      @FilterValue BIGINT    
    )
RETURNS NVARCHAR(MAX)
AS
    BEGIN    
        DECLARE @listStr NVARCHAR(MAX);  
        DECLARE @AppndChars NVARCHAR(10);    
        DECLARE @NewLineChar AS CHAR(2);     
        DECLARE @listStrQuestion NVARCHAR(MAX);  
        DECLARE @Top BIGINT = 50;
  
        SET @NewLineChar = CHAR(13) + CHAR(10);
        SET @AppndChars = '\n';    
    
        DECLARE @TempTable TABLE
            (
              shortName NVARCHAR(MAX) ,
              value NVARCHAR(MAX),
			  position int
            );

			DECLARE @TempTableFinal TABLE
            (
              shortName NVARCHAR(MAX) ,
              value NVARCHAR(MAX)
            );

            
        IF ( @Table = 'SeenClientAnswers' )
            BEGIN
                INSERT  INTO @TempTable
                        ( shortName ,
                          value,
						  position
                        )
                        SELECT  --@listStr = COALESCE(@listStr, '') + ShortName + ': '+ CASE 
						DISTINCT
                                ShortName ,
                                CASE Q.QuestionTypeId
                                  WHEN 8
                                  THEN ( CASE WHEN A.Detail IS NULL
                                                   OR A.Detail = ''
                                              THEN ISNULL(A.Detail, '')
                                              ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'MM/dd/yyyy')
                                         END )
                                  WHEN 9
                                  THEN ( CASE WHEN A.Detail IS NULL
                                                   OR A.Detail = ''
                                              THEN ISNULL(A.Detail, '')
                                              ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'hh:mm AM/PM')
                                         END )
                                  WHEN 22
                                  THEN ( CASE WHEN A.Detail IS NULL
                                                   OR A.Detail = ''
                                              THEN ISNULL(A.Detail, '')
                                              ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'MM/dd/yyyy hh:mm AM/PM')
                                         END )
										 	  WHEN 1
                          THEN dbo.GetOptionNameByQuestionId(A.QuestionId,
                                                             A.Detail, 1)
                                  ELSE ISNULL(Detail, '')
                                END + @AppndChars,
								q.Position
                FROM    dbo.SeenClientAnswerMaster AS AM
                        INNER JOIN dbo.SeenClient AS Qr ON AM.SeenClientId = Qr.Id
                        INNER JOIN dbo.SeenClientQuestions AS Q ON Qr.Id = Q.SeenClientId
                        LEFT OUTER JOIN dbo.SeenClientAnswers AS A ON AM.Id = A.SeenClientAnswerMasterId
                                                              AND Q.Id = A.QuestionId
                        --FROM    dbo.SeenClientAnswerMaster AS AM
                        --        INNER JOIN dbo.SeenClientAnswers AS A ON AM.Id = A.SeenClientAnswerMasterId
                        --        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
                        WHERE   Q.IsDisplayInSummary = 1
								AND ISNULL(Q.IsDeleted,0) = 0
                                AND AM.Id = @FilterValue;
                --ORDER BY Q.Position ,
                --        Q.Id;
            END;    
        ELSE
            IF ( @Table = 'SeenClientAnswersDetail' )
                BEGIN 
                    INSERT  INTO @TempTable
                            ( shortName ,
                              value,
							  position
                            )   
                    --SELECT  @listStr = COALESCE(@listStr, '') + ShortName + ': ' + 
                            SELECT  DISTINCT
                                    ShortName ,
                                    CASE Q.QuestionTypeId
                                      WHEN 8
                                      THEN ( CASE WHEN A.Detail IS NULL
                                                       OR A.Detail = ''
                                                  THEN ISNULL(A.Detail, '')
                                                  ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'MM/dd/yyyy')
                                             END )
                                      WHEN 9
                                      THEN ( CASE WHEN A.Detail IS NULL
                                                       OR A.Detail = ''
                                                  THEN ISNULL(A.Detail, '')
                                                  ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'hh:mm AM/PM')
                                             END )
                                      WHEN 22
                                      THEN ( CASE WHEN A.Detail IS NULL
                                                       OR A.Detail = ''
                                                  THEN ISNULL(A.Detail, '')
                                                  ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'MM/dd/yyyy hh:mm AM/PM')
                                             END )
											 	 	  WHEN 1
                          THEN dbo.GetOptionNameByQuestionId(A.QuestionId,
                                                             A.Detail, 1)
                                      ELSE ISNULL(Detail, '')
                                    END + @AppndChars,
								q.Position
                            FROM    dbo.SeenClientAnswerMaster AS AM
                                    INNER JOIN dbo.SeenClient AS Qr ON AM.SeenClientId = Qr.Id
                                    INNER JOIN dbo.SeenClientQuestions AS Q ON Qr.Id = Q.SeenClientId
                                    LEFT OUTER JOIN dbo.SeenClientAnswers AS A ON AM.Id = A.SeenClientAnswerMasterId
                                                              AND Q.Id = A.QuestionId
                            WHERE   Q.IsDisplayInDetail = 1
                                    AND Q.QuestionTypeId <> 16
                                    AND AM.Id = @FilterValue
									AND ISNULL(Q.IsDeleted,0) = 0
                                    AND ISNULL(A.IsDeleted, 0) = 0;
                END;  
            ELSE
                IF ( @Table = 'Answers' )
                    BEGIN
                        INSERT  INTO @TempTable
                                ( shortName ,
                                  value,
								  position
                                )   
                        --SELECT @listStr = COALESCE(@listStr, '') + ShortName + ': ' + 
                                SELECT DISTINCT
                                        Q.ShortName ,
                                        CASE Q.QuestionTypeId
                                          WHEN 8
                                          THEN ( CASE WHEN A.Detail IS NULL
                                                           OR A.Detail = ''
                                                      THEN ISNULL(A.Detail, '')
                                                      ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'MM/dd/yyyy')
                                                 END )
                                          WHEN 9
                                          THEN ( CASE WHEN A.Detail IS NULL
                                                           OR A.Detail = ''
                                                      THEN ISNULL(A.Detail, '')
                                                      ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'hh:mm AM/PM')
                                                 END )
                                          WHEN 22
                                          THEN ( CASE WHEN A.Detail IS NULL
                                                           OR A.Detail = ''
                                                      THEN ISNULL(A.Detail, '')
                                                      ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'MM/dd/yyyy hh:mm AM/PM')
                                                 END )
												 	 	  WHEN 1
                          THEN dbo.GetOptionNameByQuestionId(A.QuestionId,
                                                             A.Detail, 0)
                                          ELSE ISNULL(Detail, '')
                                        END + @AppndChars,
										Position
                        FROM    dbo.AnswerMaster AS AM
                                INNER JOIN dbo.Questionnaire AS Qr ON AM.QuestionnaireId = Qr.Id
                                INNER JOIN dbo.Questions AS Q ON Qr.Id = Q.QuestionnaireId
                                LEFT OUTER JOIN dbo.Answers AS A ON AM.Id = A.AnswerMasterId
                                                              AND Q.Id = A.QuestionId
                                --FROM    dbo.AnswerMaster AS AM
                                --        INNER JOIN dbo.Answers AS A ON AM.Id = A.AnswerMasterId
                                --        INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
                                WHERE   Q.IsDisplayInSummary = 1
										AND ISNULL(Q.IsDeleted,0) = 0
                                        AND AM.Id = @FilterValue;
                    END;    
                ELSE
                    IF ( @Table = 'AnswersDetail' )
                        BEGIN
                            INSERT  INTO @TempTable
                                    ( shortName ,
                                      value,
									  position
                                    )
									  
                            --SELECT @listStr = COALESCE(@listStr, '') + ShortName + ': ' + 
                                    SELECT DISTINCT
                                            Q.ShortName ,
                                            CASE Q.QuestionTypeId
                                              WHEN 8
                                              THEN ( CASE WHEN A.Detail IS NULL
                                                              OR A.Detail = ''
                                                          THEN ISNULL(A.Detail,
                                                              '')
                                                          ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'MM/dd/yyyy')
                                                     END )
                                              WHEN 9
                                              THEN ( CASE WHEN A.Detail IS NULL
                                                              OR A.Detail = ''
                                                          THEN ISNULL(A.Detail,
                                                              '')
                                                          ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'hh:mm AM/PM')
                                                     END )
                                              WHEN 22
                                              THEN ( CASE WHEN A.Detail IS NULL
                                                              OR A.Detail = ''
                                                          THEN ISNULL(A.Detail,
                                                              '')
                                                          ELSE dbo.ChangeDateFormat(A.Detail,
                                                              'MM/dd/yyyy hh:mm AM/PM')
                                                     END )
													 	 	  WHEN 1
                          THEN dbo.GetOptionNameByQuestionId(A.QuestionId,
                                                             A.Detail, 0)
                                              ELSE ISNULL(Detail, '')
                                            END + @AppndChars,
								q.Position
                                    FROM    dbo.AnswerMaster AS AM
                                            INNER JOIN dbo.Questionnaire AS Qr ON AM.QuestionnaireId = Qr.Id
                                            INNER JOIN dbo.Questions AS Q ON Qr.Id = Q.QuestionnaireId
                                            LEFT OUTER JOIN dbo.Answers AS A ON AM.Id = A.AnswerMasterId
                                                              AND Q.Id = A.QuestionId
                                    WHERE   Q.IsDisplayInDetail = 1
                                            AND Q.QuestionTypeId <> 16
                                            AND AM.Id = @FilterValue
											AND ISNULL(Q.IsDeleted,0) = 0
                                            AND ISNULL(A.IsDeleted, 0) = 0; 
                        END;

					   INSERT  INTO @TempTableFinal
                        ( shortName ,
                          value
                        )
						
						
						SELECT shortName,value from @TempTable group by shortName,value,position order by position

        SELECT  @listStr = COALESCE(@listStr, '') + shortName + ': ' + value
                + ' '
        FROM    @TempTable order by position;
        RETURN  ISNULL(@listStr, '');
    END;