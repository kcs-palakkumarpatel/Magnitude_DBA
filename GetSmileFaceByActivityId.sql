-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,29 Jul 2015>
-- Description:	<Description, ,Get Activity wise Smile Type>
-- GetSmileFaceByActivityId 50111,1,10006
-- =============================================
CREATE FUNCTION [dbo].[GetSmileFaceByActivityId]
    (
      @ActivityId BIGINT ,
      @SmileOn INT ,
      @AppUserId BIGINT
    )
RETURNS NVARCHAR(10)
AS
    BEGIN
	-- Declare the return variable here
        DECLARE @SmileType NVARCHAR(10)= '' ,
            @TotalWeight DECIMAL(18, 2) ,
            @Weight DECIMAL(18, 2) = 0 ,
            @Count INT = 0 ,
            @FromDate DATE = GETUTCDATE(),
            @Todate DATE = DATEADD(DAY, 1, GETUTCDATE()) ,
            @ActivitySmilePeriod INT;

        SELECT  @ActivitySmilePeriod = ActivitySmilePeriod
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;

        IF @ActivitySmilePeriod = 1
            SET @FromDate = DATEADD(DAY, -1, @Todate);
        ELSE
            IF @ActivitySmilePeriod = 2
                SET @FromDate = DATEADD(DAY, -6, @Todate);
            ELSE
                IF @ActivitySmilePeriod = 3
                    SET @FromDate = DATEADD(MONTH, -1, @Todate);
                ELSE
                    IF @ActivitySmilePeriod = 4
                        SET @FromDate = DATEADD(YEAR, -1, @Todate);
                    ELSE
                        IF @ActivitySmilePeriod = 5
                            SET @FromDate = DATEADD(YEAR, -50, @Todate);
	-- Add the T-SQL statements to compute the return value here
        IF @SmileOn = 1
            OR @SmileOn = 3
            BEGIN
                ----SELECT  @Weight += ISNULL(SUM(A.[Weight]), 0) ,
                ----        @Count += COUNT(DISTINCT A.Id)
                ----FROM    dbo.Answers AS A
                ----        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = A.AnswerMasterId
                ----        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                ----WHERE   E.EstablishmentGroupId = @ActivityId
                ----        AND A.QuestionTypeId IN ( 1, 2, 5, 6, 7, 14, 15, 18,
                ----                                  21 )
                ----        AND Am.IsDeleted = 0
                ----        AND A.IsDeleted = 0
                ----        AND Am.CreatedOn BETWEEN @FromDate AND @Todate;

                SELECT  @Weight += ISNULL(SUM(Am.PI), 0) ,
                        @Count += COUNT(Am.Id)
                FROM    dbo.AnswerMaster AS Am
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                WHERE   E.EstablishmentGroupId = @ActivityId
                        AND Am.IsDeleted = 0
                        AND Am.CreatedOn BETWEEN @FromDate AND @Todate
						AND ISNULL(AM.IsDisabled,0)=0;
            END;

        IF @SmileOn = 2
            OR @SmileOn = 3
            BEGIN
                ----SELECT  @Weight += ISNULL(SUM(A.[Weight]), 0) ,
                ----        @Count += COUNT(DISTINCT A.Id)
                ----FROM    dbo.SeenClientAnswers AS A
                ----        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = A.SeenClientAnswerMasterId
                ----        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                ----WHERE   E.EstablishmentGroupId = @ActivityId
                ----        AND A.QuestionTypeId IN ( 1, 2, 5, 6, 7, 14, 15, 18,
                ----                                  21 )
                ----        AND Am.IsDeleted = 0
                ----        AND A.IsDeleted = 0
                ----        AND Am.CreatedOn BETWEEN @FromDate AND @Todate;

                SELECT  @Weight += ISNULL(SUM(Am.PI), 0) ,
                        @Count += COUNT(Am.Id)
                FROM    dbo.SeenClientAnswerMaster AS Am
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                WHERE   E.EstablishmentGroupId = @ActivityId
                        AND Am.IsDeleted = 0
                        AND Am.CreatedOn BETWEEN @FromDate AND @Todate
						AND ISNULL(AM.IsDisabled,0)=0;
            END;

        IF @Count > 0
            BEGIN
                SET @TotalWeight = @Weight / @Count;

                SELECT  @SmileType = CASE WHEN @TotalWeight BETWEEN SadFrom AND SadTo
                                          THEN 'Negative'
                                          WHEN @TotalWeight BETWEEN NeutralFrom AND NeutralTo
                                          THEN 'Neutral'
                                          WHEN @TotalWeight BETWEEN HappyFrom AND HappyTo
                                          THEN 'Positive'
                                          ELSE ''
                                     END
                FROM    dbo.EstablishmentGroup
                WHERE   Id = @ActivityId;
            END;
        ELSE
            BEGIN
                SET @SmileType = '';
            END;

	-- Return the result of the function
        RETURN @SmileType;

    END;