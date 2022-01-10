-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,18 Nov 2015>
-- Description:	<Description,,>
-- Call SP:		CalculateBestWeightForQuestionnaire
-- =============================================
CREATE PROCEDURE [dbo].[CalculateBestWeightForQuestionnaire]
    @QuestionnaireId BIGINT
AS
    BEGIN
        DECLARE @BestWeight DECIMAL(18, 2);

        SELECT  @BestWeight = ISNULL(SUM(R.TotalWeight), 0)
        FROM    ( SELECT    CASE WHEN Q.QuestionTypeId IN ( 1, 6, 21 )
                                 THEN MAX(O.Weight)
                                 ELSE SUM(O.Weight)
                            END AS TotalWeight
                  FROM      dbo.Questions AS Q
                            INNER JOIN dbo.Options AS O ON O.QuestionId = Q.Id
                  WHERE     Q.QuestionnaireId = @QuestionnaireId
                            AND Q.IsDeleted = 0
                            AND Q.IsActive = 1
                            AND Q.QuestionTypeId IN ( 1, 5, 6, 18, 21 )
                  GROUP BY  Q.Id ,
                            Q.QuestionTypeId
                ) AS R;

        UPDATE  dbo.Questions
        SET     MaxWeight = ( SELECT    CASE WHEN QuestionTypeId IN ( 1, 6, 21 )
                                             THEN MAX(O.Weight)
                                             ELSE SUM(O.Weight)
                                        END
                              FROM      dbo.Options AS O
                              WHERE     QuestionId = Questions.Id
                            )
        WHERE   QuestionnaireId = @QuestionnaireId
                AND QuestionTypeId IN ( 1, 5, 6, 18, 21 )
                AND IsDeleted = 0;

        SELECT  @BestWeight += COUNT(Q.Id) * 10
        FROM    dbo.Questions AS Q
        WHERE   Q.QuestionnaireId = @QuestionnaireId
                AND Q.IsDeleted = 0
                AND Q.IsActive = 1
                AND Q.QuestionTypeId IN ( 2 );

        UPDATE  dbo.Questions
        SET     MaxWeight = 10
        WHERE   QuestionnaireId = @QuestionnaireId
                AND IsDeleted = 0
                AND QuestionTypeId = 2;

        SELECT  @BestWeight += ISNULL(SUM(R.TotalWeight), 0)
        FROM    ( SELECT    CASE WHEN Q.WeightForYes > Q.WeightForNo
                                 THEN Q.WeightForYes
                                 ELSE Q.WeightForNo
                            END AS TotalWeight
                  FROM      dbo.Questions AS Q
                  WHERE     Q.QuestionnaireId = @QuestionnaireId
                            AND Q.IsDeleted = 0
                            AND Q.IsActive = 1
                            AND Q.QuestionTypeId IN ( 7, 14, 15 )
                  GROUP BY  Q.Id ,
                            Q.WeightForYes ,
                            Q.WeightForNo
                ) AS R;

        UPDATE  dbo.Questions
        SET     MaxWeight = CASE WHEN WeightForYes > WeightForNo
                                 THEN WeightForYes
                                 ELSE WeightForNo
                            END
        WHERE   QuestionnaireId = @QuestionnaireId
                AND IsDeleted = 0
                AND QuestionTypeId IN ( 7, 14, 15 );

        PRINT @BestWeight;

        UPDATE  dbo.Questionnaire
        SET     BestWeight = @BestWeight
        WHERE   Id = @QuestionnaireId;

    END;