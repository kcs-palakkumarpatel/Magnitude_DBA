-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <19 Mar 2016>
-- Description:	<Total Weigth calculation>
-- Call:  select dbo.PIBenchmarkCalculationForGraph(919,'04 Oct 2016','04 Oct 2016',330,1,314,'1356,1357,1313',0)
-- =============================================
CREATE FUNCTION dbo.PIBenchmarkCalculationForGraph_25Jul2017
    (
      @ActivityId BIGINT ,
      @FromDate DATETIME ,
      @EndDate DATETIME ,
      @QuestionnaireId BIGINT ,
      @IsOut BIT,
	  @UserId NVARCHAR(MAX),
	  @EstablishmentId NVARCHAR(MAX),
      @QuestionId BIGINT = 0
    )
RETURNS DECIMAL(18, 0)
AS
    BEGIN

        DECLARE @TotalWeight DECIMAL(18, 2);
        DECLARE @Weight DECIMAL(18, 2);
        DECLARE @Result DECIMAL(18, 2);
        DECLARE @Start INT = 1;
        DECLARE @End INT;
        DECLARE @ReportId BIGINT;
		DECLARE @FinalResult DECIMAL(18,0)

        DECLARE @Tbl TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              ReportId BIGINT ,
              [PI] DECIMAL(18, 2),
			  [Count] BIGINT 
            );

        --IF ( @IsOut = 0 )
        --    BEGIN
        --        INSERT  INTO @Tbl
        --                ( ReportId ,
        --                  PI,
						  --Count
        --                )
        --                SELECT  Am.ReportId ,
        --                        0,
								--1
        --                FROM    dbo.View_AnswerMaster AS Am
        --                WHERE   ActivityId != @ActivityId
								--AND Am.QuestionnaireId = @QuestionnaireId
        --                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
        --                                                      AND
        --                                                      @EndDate
								--							  AND ISNULL(am.IsDisabled,0) = 0;
        --    END;
        --ELSE
        --    BEGIN
        --        INSERT  INTO @Tbl
        --                ( ReportId ,
        --                  PI,
						  --Count
        --                )
        --                SELECT  Am.ReportId ,
        --                        0,
								--CASE Am.IsSubmittedForGroup WHEN 0 THEN 1 ELSE (SELECT COUNT(*) FROM dbo.ContactGroupRelation WHERE ContactGroupId = Am.ContactGroupId) end
        --                FROM    View_SeenClientAnswerMaster Am
        --                WHERE   ActivityId != @ActivityId
								--AND Am.SeenClientId = @QuestionnaireId
        --                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
        --                                                      AND
        --                                                      @EndDate
								--							  AND ISNULL(am.IsDisabled,0) = 0;
        --    END;


		        IF ( @IsOut = 0 )
            BEGIN
                INSERT  INTO @Tbl
                        ( ReportId ,
                          PI,
						  Count
                        )
                        SELECT  Am.ReportId ,
                                0,
								1
                        FROM    dbo.View_AnswerMaster AS Am
                        WHERE   ActivityId = @ActivityId
                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate AND ISNULL(am.IsDisabled,0) = 0 AND am.EstablishmentId NOT IN (SELECT data FROM dbo.Split(@EstablishmentId,','));
            END;
        ELSE
            BEGIN
                INSERT  INTO @Tbl
                        ( ReportId ,
                          PI,
						  Count
                        )
                        SELECT  Am.ReportId ,
                                0,
								CASE Am.IsSubmittedForGroup WHEN 0 THEN 1 ELSE (SELECT COUNT(*) FROM dbo.ContactGroupRelation WHERE ContactGroupId = Am.ContactGroupId) end
                        FROM    View_SeenClientAnswerMaster Am
                        WHERE   ActivityId = @ActivityId
                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate AND Am.AppUserId Not IN (SELECT Data FROM dbo.Split(@userId,','))
															  AND ISNULL(am.IsDisabled,0) = 0 --AND am.EstablishmentId NOT IN (SELECT data FROM dbo.Split(@EstablishmentId,','));
            END; 


        SELECT  @End = COUNT(1)
        FROM    @Tbl;

        WHILE ( @Start <= @End )
            BEGIN

                SELECT  @ReportId = ReportId
                FROM    @Tbl
                WHERE   Id = @Start;

                IF ( @IsOut = 0 AND @QuestionId = 0)
                    BEGIN
                        SELECT  @TotalWeight = SUM(MaxWeight)
                        FROM    dbo.Questions
                        WHERE   QuestionnaireId = @QuestionnaireId
                                AND IsDeleted = 0
                                AND DisplayInGraphs = 1;

                        SELECT  @Weight = SUM(A.Weight)
                        FROM    dbo.Answers AS A
                                INNER JOIN dbo.Questions AS Q ON A.QuestionId = Q.Id
                        WHERE   A.AnswerMasterId = @ReportId
                                AND A.IsDeleted = 0
                                AND Q.DisplayInGraphs = 1;
                    END;
				ELSE IF ( @IsOut = 0 AND @QuestionId > 0)
                    BEGIN
                        SELECT  @TotalWeight = SUM(MaxWeight)
                        FROM    dbo.Questions
                        WHERE   id = @QuestionId
                                AND IsDeleted = 0
                                AND DisplayInGraphs = 1;

                        SELECT  @Weight = SUM(A.Weight)
                        FROM    dbo.Answers AS A
                                INNER JOIN dbo.Questions AS Q ON A.QuestionId = Q.Id
                        WHERE   A.AnswerMasterId = @ReportId
								AND A.QuestionId = @QuestionId
                                AND A.IsDeleted = 0
                                AND Q.DisplayInGraphs = 1;
                    END;
	           ELSE IF ( @IsOut = 1 AND @QuestionId = 0)
                    BEGIN
                        SELECT  @TotalWeight = SUM(MaxWeight)
                        FROM    dbo.SeenClientQuestions
                        WHERE   SeenClientId = @QuestionnaireId
                                AND IsDeleted = 0
                                AND DisplayInGraphs = 1;

                        SELECT  @Weight = SUM(A.Weight)
                        FROM    dbo.SeenClientAnswers AS A
                                INNER JOIN dbo.SeenClientQuestions AS Q ON A.QuestionId = Q.Id
                        WHERE   SeenClientAnswerMasterId = @ReportId
                                AND A.IsDeleted = 0
                                AND Q.DisplayInGraphs = 1;
                    END;
					ELSE IF ( @IsOut = 1 AND @QuestionId > 0)
                    BEGIN
                        SELECT  @TotalWeight = SUM(MaxWeight)
                        FROM    dbo.SeenClientQuestions
                        WHERE   id = @QuestionId
                                AND IsDeleted = 0
                                AND DisplayInGraphs = 1;

                        SELECT  @Weight = SUM(A.Weight)
                        FROM    dbo.SeenClientAnswers AS A
                                INNER JOIN dbo.SeenClientQuestions AS Q ON A.QuestionId = Q.Id
                        WHERE   SeenClientAnswerMasterId = @ReportId
								AND A.QuestionId = @QuestionId
                                AND A.IsDeleted = 0
                                AND Q.DisplayInGraphs = 1;
                    END;
                
                SELECT  @Result = @Weight * 100 / @TotalWeight;
					SELECT @Result = @Result / Count FROM @Tbl WHERE Id = @Start
				UPDATE @Tbl SET [PI] = @Result WHERE Id = @Start
                SET @Start = @Start+1;
            END;
			SELECT @FinalResult = ISNULL((SUM([PI]) / CASE COUNT(ReportId) WHEN 0 THEN 1 else COUNT(ReportId) END),0) FROM @Tbl
        RETURN @FinalResult;
    END;
