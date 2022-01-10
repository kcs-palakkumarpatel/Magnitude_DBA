


-- =============================================
-- Author:			Developer D3
-- Create date:	30-09-2016
-- Description:	Insert Or Update Feedbacks Answers  Table for Web API Using AnswerMasterId
-- Call:					dbo.APIInsertOrUpdateFeedbackAnswersByAnswerMasterId 293
-- =============================================
CREATE PROCEDURE [dbo].[APIInsertOrUpdateFeedbackAnswersByAnswerMasterId]
    (
      @AnswerMasterId BIGINT = 0 ,
      @QuestionId BIGINT = 0 ,
      @QuestionTypeId BIGINT = 0 ,
      @Answer NVARCHAR(2000) = NULL ,
      @AppUserId BIGINT = 0
	)
AS
    BEGIN
        DECLARE @OptionId NVARCHAR(MAX) = NULL ,
            @FinalWeight DECIMAL(18, 2) = 0 ,
            @QPI DECIMAL(18, 2) = 0 ,
            @MaxWeight DECIMAL(18, 2) = 0;

        SELECT  @MaxWeight = Q.MaxWeight
        FROM    dbo.Questions AS Q
        WHERE   Q.Id = @QuestionId;

        IF ( @QuestionTypeId = 5
             OR @QuestionTypeId = 6
             OR @QuestionTypeId = 18
             OR @QuestionTypeId = 21
           )
            AND @Answer <> ''
            BEGIN
                SELECT  @OptionId = COALESCE(@OptionId + ',', '')
                        + CONVERT(NVARCHAR(50), Id)
                FROM    dbo.Options
                WHERE   Name IN ( SELECT  DISTINCT
                                            Data
                                  FROM      dbo.Split(@Answer, ',') )
                        AND QuestionId = @QuestionId
                ORDER BY Position;
            END;
        ELSE
            IF ( @QuestionTypeId = 1 )
                AND @Answer <> ''
                BEGIN
                    SELECT  @OptionId = Id
                    FROM    dbo.Options
                    WHERE   Value = @Answer
                            AND QuestionId = @QuestionId;
                END;

        IF @QuestionTypeId = 19
            AND ( @Answer = ''
                  OR @Answer IS NULL
                )
            SET @Answer = '0';

        IF @QuestionTypeId = 7
            OR @QuestionTypeId = 14
            OR @QuestionTypeId = 15
            BEGIN
                DECLARE @YesNoWeight DECIMAL(18, 2);
                SELECT  @YesNoWeight = CASE WHEN @Answer = 'Yes'
                                                 OR @Answer LIKE 'Yes,%'
                                            THEN Q.[WeightForYes]
                                            WHEN @Answer = 'No'
                                                 OR @Answer LIKE 'No,%'
                                            THEN Q.WeightForNo
                                            ELSE 0
                                       END ,
                        @MaxWeight = Q.MaxWeight
                FROM    dbo.Questions AS Q
                WHERE   Q.Id = @QuestionId;

                SET @FinalWeight = @YesNoWeight;
            END;
        ELSE
            IF ( @QuestionTypeId = 5
                 OR @QuestionTypeId = 6
                 OR @QuestionTypeId = 18
                 OR @QuestionTypeId = 21
               )
                AND @Answer <> ''
                BEGIN
                    SELECT  @FinalWeight = SUM(O.Weight)
                    FROM    dbo.Options AS O
                            INNER JOIN ( SELECT Data
                                         FROM   dbo.Split(@OptionId, ',')
                                       ) AS R ON O.Id = R.Data
                    WHERE   QuestionId = @QuestionId;
                END;
            ELSE
                IF ( @QuestionTypeId = 1 )
                    AND @Answer <> ''
                    BEGIN
                        SELECT  @FinalWeight = SUM(O.Weight)
                        FROM    dbo.Options AS O
                        WHERE   QuestionId = @QuestionId
                                AND O.Value = @Answer;
                    END;
                ELSE
                    IF ( @QuestionTypeId = 2 )
                        AND @Answer <> ''
                        BEGIN
                            SET @FinalWeight = @Answer;
                        END;

        IF @MaxWeight > 0
            BEGIN
                SET @QPI = ISNULL(@FinalWeight, 0) * 100.00 / @MaxWeight;
            END;

        INSERT  INTO dbo.Answers
                ( AnswerMasterId ,
                  QuestionId ,
                  OptionId ,
                  QuestionTypeId ,
                  Detail ,
                  [Weight] ,
                  [QPI] ,
                  CreatedBy
	            )
        VALUES  ( @AnswerMasterId , -- AnswerMasterId - bigint
                  @QuestionId , -- QuestionId - bigint
                  @OptionId , -- OptionId - nvarchar(max)
                  @QuestionTypeId , -- QuestionTypeId - int
                  @Answer , -- Detail - nvarchar(max)
                  ISNULL(@FinalWeight, 0) ,
                  @QPI ,
                  @AppUserId  -- CreatedBy - bigint
	            );

        SELECT  ISNULL(CAST(SCOPE_IDENTITY() AS BIGINT), 0) AS InsertedId;

        IF @QuestionTypeId = 11
            BEGIN
                UPDATE  dbo.AnswerMaster
                SET     SenderCellNo = @Answer
                WHERE   Id = @AnswerMasterId;
            END;
    END;