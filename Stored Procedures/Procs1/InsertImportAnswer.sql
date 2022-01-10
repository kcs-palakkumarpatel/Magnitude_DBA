
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,18 Apr 2015>
-- Description:	<Description,,>
-- Call SP:		InsertImportAnswer
-- =============================================
CREATE PROCEDURE [dbo].[InsertImportAnswer]
    @AnswerMasterId BIGINT ,
    @QuestionId BIGINT ,
    @QuestionTypeId BIGINT ,
    @Detail NVARCHAR(MAX) ,
    @AppUserId BIGINT
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
            AND @Detail <> ''
            BEGIN
                SELECT  @OptionId = COALESCE(@OptionId + ',', '')
                        + CONVERT(NVARCHAR(50), Id)
                FROM    dbo.Options
                WHERE   Name IN ( SELECT  DISTINCT
                                            Data
                                  FROM      dbo.Split(@Detail, ',') )
                        AND QuestionId = @QuestionId
                ORDER BY Position;
            END;
        ELSE
            IF ( @QuestionTypeId = 1 )
                AND @Detail <> ''
                BEGIN
                    SELECT  @OptionId = Id
                    FROM    dbo.Options
                    WHERE   Value = @Detail
                            AND QuestionId = @QuestionId;
                END;

        IF @QuestionTypeId = 19
            AND ( @Detail = ''
                  OR @Detail IS NULL
                )
            SET @Detail = '0';

        IF @QuestionTypeId = 7
            OR @QuestionTypeId = 14
            OR @QuestionTypeId = 15
            BEGIN
                DECLARE @YesNoWeight DECIMAL(18, 2);
                SELECT  @YesNoWeight = CASE WHEN @Detail = 'Yes'
                                                 OR @Detail LIKE 'Yes,%'
                                            THEN Q.[WeightForYes]
                                            WHEN @Detail = 'No'
                                                 OR @Detail LIKE 'No,%'
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
                AND @Detail <> ''
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
                    AND @Detail <> ''
                    BEGIN
                        SELECT  @FinalWeight = SUM(O.Weight)
                        FROM    dbo.Options AS O
                        WHERE   QuestionId = @QuestionId
                                AND O.Value = @Detail;
                    END;
                ELSE
                    IF ( @QuestionTypeId = 2 )
                        AND @Detail <> ''
                        BEGIN
                            SET @FinalWeight = @Detail;
                        END;

        IF @MaxWeight > 0
            BEGIN
                SET @QPI = ISNULL(@FinalWeight, 0) * 100.00 / @MaxWeight;
            END;
	
        IF EXISTS ( SELECT  *
                    FROM    dbo.Options
                    WHERE   QuestionId = @QuestionId )
            BEGIN
                SELECT  @OptionId = Id
                FROM    dbo.Options
                WHERE   QuestionId = @QuestionId
                        AND Value = @Detail;
            END;

        INSERT  INTO dbo.Answers
                ( AnswerMasterId ,
                  QuestionId ,
                  OptionId ,
                  QuestionTypeId ,
                  Detail ,
				  [Weight],
				  [QPI],
                  CreatedBy ,
                  CreatedOn ,
                  IsDeleted
				)
        VALUES  ( @AnswerMasterId ,
                  @QuestionId ,
                  @OptionId ,
                  @QuestionTypeId ,
                  @Detail ,
				  ISNULL(@FinalWeight, 0) ,
                  @QPI ,
                  0 ,
                  GETUTCDATE() ,
                  0  
				);

			

        DECLARE @AnsterId BIGINT;
        SET @AnsterId = SCOPE_IDENTITY();

		--EXEC CalculatePerformanceIndex @AnswerMasterId,0

        SELECT  ISNULL(@AnsterId, 0) AS InsertedId;
    END;