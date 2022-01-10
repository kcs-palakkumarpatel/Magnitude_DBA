-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,01 Sep 2015>
-- Description:	<Description,,Calculate Weight>
-- =============================================
CREATE PROCEDURE [dbo].[CalculateWeight]
    @ReportId BIGINT ,
    @IsOut BIT
AS
    BEGIN
        DECLARE @Tbl TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              AnsId BIGINT ,
              Details NVARCHAR(MAX) ,
              OptionId NVARCHAR(MAX) ,
              QuestionTypeId INT ,
              QuestionId BIGINT ,
              YesNoWeight INT
            );
		
        IF @IsOut = 0
            BEGIN
                INSERT  INTO @Tbl
                        ( AnsId ,
                          Details ,
                          OptionId ,
                          QuestionTypeId ,
                          QuestionId ,
                          YesNoWeight
                        )
                        SELECT  A.Id ,
                                ISNULL(A.Detail, '0') ,
                                ISNULL(A.OptionId, '0') ,
                                A.QuestionTypeId ,
                                A.QuestionId ,
                                CASE WHEN A.Detail = 'Yes'
                                          OR A.Detail LIKE 'Yes,%'
                                     THEN Q.[WeightForYes]
                                     WHEN A.Detail = 'No'
                                          OR A.Detail LIKE 'No,%'
                                     THEN Q.WeightForNo
                                     ELSE 0
                                END
                        FROM    dbo.AnswerMaster AS Am
                                INNER JOIN dbo.Answers AS A ON A.AnswerMasterId = Am.Id
                                INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
                        WHERE   Am.Id = @ReportId
                                AND A.IsDeleted = 0
                                AND Am.IsDeleted = 0
                                AND A.QuestionTypeId IN ( 1, 2, 5, 6, 7, 14,
                                                          15, 18, 21 );
            END;
        ELSE
            BEGIN
                INSERT  INTO @Tbl
                        ( AnsId ,
                          Details ,
                          OptionId ,
                          QuestionTypeId ,
                          QuestionId ,
                          YesNoWeight
                        )
                        SELECT  A.Id ,
                                ISNULL(A.Detail, '0') ,
                                ISNULL(A.OptionId, '0') ,
                                A.QuestionTypeId ,
                                A.QuestionId ,
                                CASE WHEN A.Detail = 'Yes'
                                          OR A.Detail LIKE 'Yes,%'
                                     THEN Q.[WeightForYes]
                                     WHEN A.Detail = 'No'
                                          OR A.Detail LIKE 'No,%'
                                     THEN Q.WeightForNo
                                     ELSE 0
                                END
                        FROM    dbo.SeenClientAnswerMaster AS Am
                                INNER JOIN dbo.SeenClientAnswers AS A ON A.SeenClientAnswerMasterId = Am.Id
                                INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
                        WHERE   Am.Id = @ReportId
                                AND A.IsDeleted = 0
                                AND Am.IsDeleted = 0
                                AND A.QuestionTypeId IN ( 1, 2, 5, 6, 7, 14,
                                                          15, 18, 21 );
            END;

        DECLARE @Start BIGINT = 1 ,
            @End BIGINT ,
            @AnsId BIGINT ,
            @Details NVARCHAR(MAX) ,
            @OptionId NVARCHAR(MAX) ,
            @QuestionId BIGINT ,
            @QuestionTypeId INT ,
            @YesNoWeight DECIMAL(18, 2);

        DECLARE @FinalWeight DECIMAL(18, 2) = 0;

        SELECT  @End = COUNT(1)
        FROM    @Tbl;

        WHILE ( @Start <= @End )
            BEGIN
                SELECT  @AnsId = AnsId ,
                        @Details = Details ,
                        @OptionId = OptionId ,
                        @QuestionTypeId = QuestionTypeId ,
                        @QuestionId = QuestionId ,
                        @YesNoWeight = YesNoWeight
                FROM    @Tbl
                WHERE   Id = @Start;

                SET @FinalWeight = 0;

                
                IF @QuestionTypeId = 7
                    OR @QuestionTypeId = 14
                    OR @QuestionTypeId = 15
                    BEGIN
                        SET @FinalWeight = ISNULL(@YesNoWeight, 0);
                    END;
                ELSE
                    IF ( @QuestionTypeId = 1
                         OR @QuestionTypeId = 2
                         OR @QuestionTypeId = 5
                         OR @QuestionTypeId = 6
                         OR @QuestionTypeId = 18
                         OR @QuestionTypeId = 21
                       )
                        AND @Details <> ''
                        BEGIN
                            IF @IsOut = 0
                                BEGIN
                                    SELECT  @FinalWeight = ISNULL(SUM(O.Weight),
                                                              0)
                                    FROM    dbo.Options AS O
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@OptionId,
                                                              ',')
                                                       ) AS R ON O.Id = R.Data
                                    WHERE   QuestionId = @QuestionId;
                                END;
                            ELSE
                                BEGIN
                                    SELECT  @FinalWeight = ISNULL(SUM(O.Weight),
                                                              0)
                                    FROM    dbo.SeenClientOptions AS O
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@OptionId,
                                                              ',')
                                                       ) AS R ON O.Id = R.Data
                                    WHERE   QuestionId = @QuestionId;
                                END;
                        END;

                PRINT 'Ans Id';
                PRINT @AnsId;
                PRINT 'Final Weight';
                PRINT @FinalWeight;

                IF @IsOut = 0
                    BEGIN
                        UPDATE  dbo.Answers
                        SET     [Weight] = @FinalWeight
                        WHERE   Id = @AnsId;
                    END;
                ELSE
                    BEGIN
                        UPDATE  dbo.SeenClientAnswers
                        SET     [Weight] = @FinalWeight
                        WHERE   Id = @AnsId;
                    END;

                SET @Start += 1;
            END;
    END;