-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 Nov 2015>
-- Description:	<Description,,>
-- Call SP:		CalculatePerformanceIndex 364304,1
-- =============================================
CREATE PROCEDURE [dbo].[CalculatePerformanceIndex]
    @ReportId BIGINT,
    @IsOut BIT
AS
BEGIN
    SET DEADLOCK_PRIORITY NORMAL;

    BEGIN TRY
        DECLARE @PI DECIMAL(18, 2) = 0,
                @BestWeight DECIMAL(18, 2),
                @TotalWeight DECIMAL(18, 2),
                @NonMandetoryWeight DECIMAL(18, 2),
                @EscalationBasedOnForm BIGINT,
                @QuestionMaxWeight INT,
                @SeenClientId BIGINT,
                @QuestionnarieId BIGINT;

        IF @IsOut = 0
        BEGIN
            SELECT @BestWeight = Q.BestWeight,
                   @EscalationBasedOnForm = Q.EscalationValue,
                   @QuestionnarieId = Am.QuestionnaireId
            FROM dbo.AnswerMaster AS Am
                INNER JOIN dbo.Questionnaire AS Q
                    ON Q.Id = Am.QuestionnaireId
            WHERE Am.Id = @ReportId;

            SELECT TOP 1
                @QuestionMaxWeight = Sq.MaxWeight
            FROM dbo.Questions AS Sq
            WHERE Sq.QuestionnaireId = @QuestionnarieId
                  AND Sq.MaxWeight > 0
                  AND ISNULL(Sq.IsDeleted, 0) = 0;

            /* Added Vasu Patel 08 Mar 2017
				Following logic for Nonmadetory Field not selected then This is not effect on PI Calculation */

            SELECT @NonMandetoryWeight = ISNULL(SUM(R.TotalWeight), 0)
            FROM
            (
                SELECT CASE
                           WHEN Q.QuestionTypeId IN ( 1, 6, 21 ) THEN
                               MAX(O.Weight)
                           ELSE
                               SUM(O.Weight)
                       END AS TotalWeight
                FROM dbo.Questions AS Q
                    LEFT JOIN dbo.Options AS O
                        ON O.QuestionId = Q.Id
                    INNER JOIN dbo.Answers AS A
                        ON A.QuestionId = Q.Id
                           AND ISNULL(A.IsNA, 0) = 0
                           AND Q.[Required] = 0
                           AND (
                                   ISNULL(A.Detail, '') = ''
                                   OR A.Detail = '-- Select --'
                               )
                    INNER JOIN dbo.AnswerMaster AS AM
                        ON AM.Id = A.AnswerMasterId
                WHERE Q.QuestionnaireId = AM.QuestionnaireId
                      AND A.RepetitiveGroupId = 0
                      AND Q.QuestionTypeId IN ( 1, 5, 6, 18, 21 )
                      AND Q.IsDeleted = 0
                      AND Q.IsActive = 1
                      AND A.AnswerMasterId = @ReportId
                GROUP BY Q.Id,
                         Q.QuestionTypeId
            ) AS R;

            SELECT @NonMandetoryWeight += ISNULL(SUM(R.TotalWeight), 0)
            FROM
            (
                SELECT CASE
                           WHEN Q.WeightForYes > Q.WeightForNo THEN
                               Q.WeightForYes
                           ELSE
                               Q.WeightForNo
                       END AS TotalWeight
                FROM dbo.Questions AS Q
                    INNER JOIN dbo.Answers AS A
                        ON A.QuestionId = Q.Id
                           AND ISNULL(A.IsNA, 0) = 0
                           AND Q.[Required] = 0
                           AND (
                                   ISNULL(A.Detail, '') = ''
                                   OR A.Detail = '-- Select --'
                               )
                    INNER JOIN dbo.AnswerMaster AS AM
                        ON AM.Id = A.AnswerMasterId
                WHERE Q.QuestionnaireId = AM.QuestionnaireId
                      AND A.RepetitiveGroupId = 0
                      AND Q.QuestionTypeId IN ( 7 )
                      AND Q.IsDeleted = 0
                      AND Q.IsActive = 1
                      AND A.AnswerMasterId = @ReportId
                GROUP BY Q.Id,
                         Q.WeightForYes,
                         Q.WeightForNo
            ) AS R;

            SELECT @NonMandetoryWeight += CASE
                                              WHEN ISNULL(Details, '') ! = '' THEN
                                                  CASE
                                                      WHEN (ISNULL(Details, '-- Select --') != '-- Select --') THEN
                                                          0
                                                      ELSE
                                                          T.MaxWeight
                                                  END
                                              ELSE
                                                  T.MaxWeight
                                          END
            FROM
            (
                SELECT MAX(A.Detail) AS Details,
                       A.QuestionId,
                       Q.MaxWeight
                FROM dbo.Questions AS Q
                    LEFT JOIN dbo.Options AS O
                        ON O.QuestionId = Q.Id
                    INNER JOIN dbo.Answers AS A
                        ON A.QuestionId = Q.Id
                           AND ISNULL(A.IsNA, 0) = 0
                WHERE Q.QuestionTypeId IN ( 1, 5, 6, 18, 21, 7 )
                      AND Q.IsDeleted = 0
                      AND Q.IsActive = 1
                      AND A.AnswerMasterId = @ReportId
                      AND A.RepetitiveGroupId != 0
                GROUP BY A.QuestionId,
                         Q.MaxWeight
            ) AS T;

            SET @BestWeight = @BestWeight - @NonMandetoryWeight;

            /* Added Vasu Patel 08 Mar 2017
				Following logic for Nonmadetory Field not selected then This is not effect on PI Calculation */

            --SELECT  @TotalWeight = SUM(Weight) --/ COUNT(DISTINCT Id)
            --            FROM    dbo.Answers
            --            WHERE   AnswerMasterId = @ReportId
            --                    AND QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 );

            SELECT TOP 1
                @TotalWeight = SUM(weight)
            FROM
            (
                SELECT AVG(Weight) AS weight
                FROM dbo.Answers
                WHERE AnswerMasterId = @ReportId
                      AND ISNULL(IsNA, 0) = 0
                      AND QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 )
                GROUP BY QuestionId
            ) AS T;

            IF @BestWeight > 0
                SET @PI = 100.00 * @TotalWeight / @BestWeight;
            ELSE
                SET @PI = 0;

            IF @EscalationBasedOnForm = 0
               AND (
                       @QuestionMaxWeight = 0
                       OR @QuestionMaxWeight IS NULL
                   )
            BEGIN
                SET @PI = -1;
            END;

            UPDATE dbo.AnswerMaster
            SET [PI] = @PI
            WHERE Id = @ReportId
                  AND @PI > -2;
        END;
        ELSE
        BEGIN
            SELECT @BestWeight = Q.BestWeight,
                   @EscalationBasedOnForm = Q.EscalationValue,
                   @SeenClientId = Am.SeenClientId
            FROM dbo.SeenClientAnswerMaster AS Am
                INNER JOIN dbo.SeenClient AS Q
                    ON Q.Id = Am.SeenClientId
            WHERE Am.Id = @ReportId;

            SELECT TOP 1
                @QuestionMaxWeight = Sq.MaxWeight
            FROM dbo.SeenClientQuestions AS Sq
            WHERE Sq.SeenClientId = @SeenClientId
                  AND ISNULL(Sq.IsDeleted, 0) = 0
                  AND Sq.MaxWeight > 0;

            /* Added Vasu Patel 08 Mar 2017
				Following logic for Nonmadetory Field not selected then This is not effect on PI Calculation */

            SELECT @NonMandetoryWeight = ISNULL(SUM(R.TotalWeight), 0)
            FROM
            (
                SELECT CASE
                           WHEN Q.QuestionTypeId IN ( 1, 6, 21 ) THEN
                               MAX(O.Weight)
                           ELSE
                               SUM(O.Weight)
                       END AS TotalWeight
                FROM dbo.SeenClientQuestions AS Q
                    LEFT JOIN dbo.SeenClientOptions AS O
                        ON O.QuestionId = Q.Id
                    INNER JOIN dbo.SeenClientAnswers AS SA
                        ON SA.QuestionId = Q.Id
                           AND ISNULL(SA.IsNA, 0) = 0
                           AND Q.[Required] = 0
                           AND ISNULL(SA.Detail, '') = ''
                    INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                        ON SCA.Id = @ReportId
                WHERE Q.SeenClientId = SCA.SeenClientId
                      AND Q.QuestionTypeId IN ( 1, 5, 6, 18, 21 )
                      AND Q.IsDeleted = 0
                      AND Q.IsActive = 1
                      AND SA.RepetitiveGroupId = 0
                      AND SA.SeenClientAnswerMasterId = @ReportId
                GROUP BY Q.Id,
                         Q.QuestionTypeId
            ) AS R;

            SELECT @NonMandetoryWeight += ISNULL(SUM(R.TotalWeight), 0)
            FROM
            (
                SELECT CASE
                           WHEN Q.WeightForYes > Q.WeightForNo THEN
                               Q.WeightForYes
                           ELSE
                               Q.WeightForNo
                       END AS TotalWeight
                FROM dbo.SeenClientQuestions AS Q
                    INNER JOIN dbo.SeenClientAnswers AS SA
                        ON SA.QuestionId = Q.Id
                           AND ISNULL(SA.IsNA, 0) = 0
                           AND Q.[Required] = 0
                           AND ISNULL(SA.Detail, '') = ''
                    INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                        ON SCA.Id = @ReportId
                WHERE Q.SeenClientId = SCA.SeenClientId
                      AND Q.QuestionTypeId IN ( 7 )
                      AND Q.IsDeleted = 0
                      AND Q.IsActive = 1
                      AND SA.RepetitiveGroupId = 0
                      AND SA.SeenClientAnswerMasterId = @ReportId
                GROUP BY Q.Id,
                         Q.WeightForYes,
                         Q.WeightForNo
            ) AS R;

            SELECT @NonMandetoryWeight += CASE
                                              WHEN ISNULL(Details, '') ! = '' THEN
                                                  0
                                              ELSE
                                                  T.MaxWeight
                                          END
            FROM
            (
                SELECT MAX(SA.Detail) AS Details,
                       SA.QuestionId,
                       Q.MaxWeight
                FROM dbo.SeenClientQuestions AS Q
                    LEFT JOIN dbo.SeenClientOptions AS O
                        ON O.QuestionId = Q.Id
                    INNER JOIN dbo.SeenClientAnswers AS SA
                        ON SA.QuestionId = Q.Id
                           AND ISNULL(SA.IsNA, 0) = 0
                WHERE Q.QuestionTypeId IN ( 1, 5, 6, 18, 21, 7 )
                      AND Q.IsDeleted = 0
                      AND Q.IsActive = 1
                      AND SA.SeenClientAnswerMasterId = @ReportId
                      AND SA.RepetitiveGroupId != 0
                GROUP BY SA.QuestionId,
                         Q.MaxWeight
            ) AS T;

            SET @BestWeight = @BestWeight - @NonMandetoryWeight;
            /* Added Vasu Patel 08 Mar 2017
				Following logic for Nonmadetory Field not selected then This is not effect on PI Calculation */


            --SELECT TOP 1  @TotalWeight = SUM(Weight) --/ COUNT(DISTINCT Id)
            --FROM    dbo.SeenClientAnswers
            --WHERE   SeenClientAnswerMasterId = @ReportId
            --        AND QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 ) GROUP BY SeenClientAnswerChildId;

            SELECT TOP 1
                @TotalWeight = SUM(weight)
            FROM
            (
                SELECT AVG(Weight) AS weight
                FROM dbo.SeenClientAnswers
                WHERE SeenClientAnswerMasterId = @ReportId
                      AND ISNULL(IsNA, 0) = 0
                      AND QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 )
                GROUP BY QuestionId
            ) AS T; --GROUP BY SeenClientAnswerChildId

            SELECT TOP 1
                @TotalWeight = SUM(weight)
            FROM
            (
                SELECT AVG(Weight) AS weight
                FROM dbo.SeenClientAnswers
                WHERE SeenClientAnswerMasterId = @ReportId
                      AND ISNULL(IsNA, 0) = 0
                      AND (CASE
                               WHEN QuestionTypeId IN ( 7, 14, 15 ) THEN
                                   ISNULL(OptionId, 0)
                               ELSE
                                   OptionId
                           END
                          ) IS NOT NULL
                      AND QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 )
                GROUP BY QuestionId
            ) AS T;

            IF (@TotalWeight IS NOT NULL)
            BEGIN
                IF @BestWeight > 0
                    SET @PI = 100.00 * @TotalWeight / @BestWeight;
                ELSE
                    SET @PI = 0;
            ----SELECT  @PI = SUM(Weight) / COUNT(DISTINCT Id)
            ----FROM    dbo.SeenClientAnswers
            ----WHERE   SeenClientAnswerMasterId = @ReportId
            ----        AND QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 );
            END;
            ELSE
            BEGIN
                SET @PI = -1;
            END;

            IF @EscalationBasedOnForm = 0
               AND (
                       @QuestionMaxWeight = 0
                       OR @QuestionMaxWeight IS NULL
                   )
            BEGIN
                SET @PI = -1;
            END;

            UPDATE dbo.SeenClientAnswerMaster
            SET [PI] = @PI
            WHERE Id = @ReportId
                  AND @PI > -2;

            EXEC CalculateSectionPI @ReportId, @IsOut;
        END;

        --DECLARE @stsusHistoryId BIGINT;
        --SELECT @stsusHistoryId = MAX(Id)
        --FROM dbo.StatusHistory
        --WHERE ReferenceNo = @ReportId;

        --UPDATE dbo.SeenClientAnswerMaster
        --SET StatusHistoryId = @stsusHistoryId
        --WHERE Id = @ReportId;

        DECLARE @TimeOffSet INT;

        SELECT @TimeOffSet = TimeOffSet
        FROM dbo.SeenClientAnswerMaster
        WHERE Id = @ReportId;

        --UPDATE dbo.StatusHistory
        --SET StatusDateTime = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE())
        --WHERE Id = @stsusHistoryId;

        PRINT 'Best';
        PRINT @BestWeight;
        PRINT 'Total';
        PRINT @TotalWeight;
        PRINT 'PI';
        PRINT @PI;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.CalculatePerformanceIndex',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @ReportId + ',' + @IsOut,
         GETUTCDATE(),
         N''
        );
    END CATCH;

END;
