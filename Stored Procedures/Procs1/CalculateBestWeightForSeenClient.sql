-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,18 Nov 2015>
-- Description:	<Description,,>
-- Call SP:		CalculateBestWeightForSeenClient 2
-- =============================================
CREATE PROCEDURE [dbo].[CalculateBestWeightForSeenClient] @SeenClientId BIGINT
AS
BEGIN
    DECLARE @BestWeight DECIMAL(18, 2);

    SELECT @BestWeight = ISNULL(SUM(R.TotalWeight), 0)
    FROM
    (
        SELECT CASE
                   WHEN Q.QuestionTypeId IN ( 1, 6, 21 ) THEN
                       MAX(O.Weight)
                   ELSE
                       SUM(O.Weight)
               END AS TotalWeight
        FROM dbo.SeenClientQuestions AS Q
            INNER JOIN dbo.SeenClientOptions AS O
                ON O.QuestionId = Q.Id
        WHERE Q.SeenClientId = @SeenClientId
              AND Q.QuestionTypeId IN ( 1, 5, 6, 18, 21 )
              AND Q.IsDeleted = 0
              AND Q.IsActive = 1
        GROUP BY Q.Id,
                 Q.QuestionTypeId
    ) AS R;

    UPDATE dbo.SeenClientQuestions
    SET MaxWeight = ISNULL(
                    (
                        SELECT CASE
                                   WHEN QuestionTypeId IN ( 1, 6, 21 ) THEN
                                       MAX(O.Weight)
                                   ELSE
                                       SUM(O.Weight)
                               END
                        FROM dbo.SeenClientOptions AS O
                        WHERE QuestionId = SeenClientQuestions.Id
                    ),
                    0
                          )
    WHERE SeenClientId = @SeenClientId
          AND QuestionTypeId IN ( 1, 5, 6, 18, 21 )
          AND IsDeleted = 0;

    SELECT @BestWeight += COUNT(Q.Id) * 10
    FROM dbo.SeenClientQuestions AS Q
    WHERE Q.SeenClientId = @SeenClientId
          AND Q.IsDeleted = 0
          AND Q.IsActive = 1
          AND Q.QuestionTypeId IN ( 2 );

    UPDATE dbo.SeenClientQuestions
    SET MaxWeight = 10
    WHERE SeenClientId = @SeenClientId
          AND IsDeleted = 0
          AND QuestionTypeId = 2;

    SELECT @BestWeight += ISNULL(SUM(R.TotalWeight), 0)
    FROM
    (
        SELECT CASE
                   WHEN Q.WeightForYes > Q.WeightForNo THEN
                       Q.WeightForYes
                   ELSE
                       Q.WeightForNo
               END AS TotalWeight
        FROM dbo.SeenClientQuestions AS Q
        WHERE Q.SeenClientId = @SeenClientId
              AND Q.QuestionTypeId IN ( 7, 14, 15 )
              AND Q.IsDeleted = 0
              AND Q.IsActive = 1
        GROUP BY Q.Id,
                 Q.WeightForYes,
                 Q.WeightForNo
    ) AS R;

    UPDATE dbo.SeenClientQuestions
    SET MaxWeight = ISNULL(   (CASE
                                   WHEN WeightForYes > WeightForNo THEN
                                       WeightForYes
                                   ELSE
                                       WeightForNo
                               END
                              ),
                              0
                          )
    WHERE SeenClientId = @SeenClientId
          AND IsDeleted = 0
          AND QuestionTypeId IN ( 7, 14, 15 );

    PRINT @BestWeight;

    UPDATE dbo.SeenClient
    SET BestWeight = @BestWeight
    WHERE Id = @SeenClientId;
END;
