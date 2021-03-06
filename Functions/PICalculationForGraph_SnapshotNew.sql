-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <19 Mar 2016>
-- Description:	<Total Weigth calculation>
-- Call:  select dbo.PICalculationForGraph_Snapshot(1207,'01 jan 2017','21 Jul 2017',770,1,'449','1640,1669,1670',0,0)
-- =============================================
CREATE FUNCTION [dbo].[PICalculationForGraph_SnapshotNew]
   (
     @ActivityId BIGINT ,						
     @FromDate DATETIME ,
     @EndDate DATETIME ,
     @QuestionnaireId BIGINT ,
     @IsOut BIT ,
     @UserId NVARCHAR(MAX) ,
     @EstablishmentId NVARCHAR(MAX) ,
     @QuestionId BIGINT ,
	 @AnswerMasterId BIGINT,
	 @FormStatus VARCHAR(50) , --- Resolve and Unresole
     @ReadUnread VARCHAR(50) ,
     @isAction VARCHAR(50) ,
	 @isTransfer BIT 
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
        DECLARE @FinalResult DECIMAL(18, 0);
		Declare	@NonMandetoryWeight DECIMAL(18,2);
        DECLARE @Tbl TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              ReportId BIGINT ,
              [PI] DECIMAL(18, 2) ,
              [Count] BIGINT
            );

			 DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter INT = 0 ,
            @isPositive NVARCHAR(50) = '' ,
            @IsOutStanding BIT = 0;

        IF ( @FormStatus = 'Resolved'
             OR @FormStatus = 'Unresolved'
           )
            BEGIN
                SET @AnsStatus = @FormStatus;
            END;
		IF (@ReadUnread = 'Unread')
		BEGIN
			     SET @IsOutStanding = 1;
		END
		   IF @isAction = 'Action'
                        BEGIN
                            SET @ActionFilter = 1;
                        END;
		         IF @isTransfer = 1
                    BEGIN
                        SET @TranferFilter = 1;
                    END;

        IF (@IsOut = 0)
            BEGIN
			IF(@AnswerMasterId <> 0)
			BEGIN
			           INSERT  INTO @Tbl
                        (ReportId ,
                          PI ,
                          Count
                        )
                        SELECT  Am.ReportId ,
                                0 ,
                                1
                        FROM    dbo.View_AnswerMaster AS Am
                        WHERE   ISNULL(Am.IsDisabled, 0) = 0
                                AND am.ReportId = @AnswerMasterId;
            END;
			ELSE
            BEGIN
			 INSERT  INTO @Tbl
                        ( ReportId ,
                          PI ,
                          Count
                        )
                        SELECT  Am.ReportId ,
                                0 ,
                                1
                        FROM    dbo.View_AnswerMaster AS Am
                        WHERE   ActivityId = @ActivityId
                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                AND Am.AppUserId IN (
                                SELECT  Data
                                FROM    dbo.Split(@UserId, ',') )
                                AND ISNULL(Am.IsDisabled, 0) = 0
                                AND Am.EstablishmentId IN (
                                SELECT  Data
                                FROM    dbo.Split(@EstablishmentId, ',') )
								 AND ( IsResolved = @AnsStatus
                                                      OR @AnsStatus = ''
                                                    )
                                                AND ( @TranferFilter = 0
                                                      OR Am.IsTransferred = 1
                                                    )
                                                AND ( @ActionFilter = 0
                                                      OR ( ( @ActionFilter = 1
                                                             AND Am.IsActioned = 1
                                                           )
                                                           OR ( @ActionFilter = 2
                                                              AND Am.IsActioned = 0
                                                              AND Am.IsResolved = 'Unresolved'
                                                              )
                                                         )
                                                    )
                                                AND ( @IsOutStanding = 0
                                                      OR Am.IsOutStanding = 1
                                                    )
			END
			END
            
        ELSE
            BEGIN
			IF (@AnswerMasterId <> 0)
			BEGIN
                INSERT  INTO @Tbl
                        ( ReportId ,
                          PI ,
                          Count
                        )
                        SELECT  Am.ReportId ,
                                0 ,
                                CASE Am.IsSubmittedForGroup
                                  WHEN 0 THEN 1
                                  ELSE ( 
										SELECT COUNT(DISTINCT SeenClientAnswerChildId) FROM dbo.SeenClientAnswers 
										WHERE SeenClientAnswerMasterId = am.ReportId 
                                       )
                                END
                        FROM    View_SeenClientAnswerMaster Am
		                    WHERE   ISNULL(Am.IsDisabled, 0) = 0
                                AND am.ReportId = @AnswerMasterId;
								END
								ELSE
								 BEGIN
                INSERT  INTO @Tbl
                        ( ReportId ,
                          PI ,
                          Count
                        )
                        SELECT  Am.ReportId ,
                                0 ,
                                CASE Am.IsSubmittedForGroup
                                  WHEN 0 THEN 1
                                  ELSE (SELECT COUNT(DISTINCT SeenClientAnswerChildId) FROM dbo.SeenClientAnswers 
										WHERE SeenClientAnswerMasterId = am.ReportId 
                                       )
                                END
                        FROM    View_SeenClientAnswerMaster Am
                        WHERE   ActivityId = @ActivityId
                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                AND Am.AppUserId IN (
                                SELECT  Data
                                FROM    dbo.Split(@UserId, ',') )
                                AND ISNULL(Am.IsDisabled, 0) = 0
                                AND Am.EstablishmentId IN (
                                SELECT  Data
                                FROM    dbo.Split(@EstablishmentId, ',') )
								 AND ( IsResolved = @AnsStatus
                                                      OR @AnsStatus = ''
                                                    )
                                                AND ( @TranferFilter = 0
                                                      OR Am.IsTransferred = 1
                                                    )
                                                AND ( @ActionFilter = 0
                                                      OR ( ( @ActionFilter = 1
                                                             AND Am.IsActioned = 1
                                                           )
                                                           OR ( @ActionFilter = 2
                                                              AND Am.IsActioned = 0
                                                              AND Am.IsResolved = 'Unresolved'
                                                              )
                                                         )
                                                    )
                                                AND ( @IsOutStanding = 0
                                                      OR Am.IsOutStanding = 1
                                                    );
            END; 
								 
            END; 

        SELECT  @End = COUNT(1)
        FROM    @Tbl;

        WHILE ( @Start <= @End )
            BEGIN

                SELECT  @ReportId = ReportId
                FROM    @Tbl
                WHERE   Id = @Start;

				/* Added Vasu Patel 16 Mar 2017
				Following logic for Nonmadetory Field not selected then This is not effect on PI Calculation */

				IF(@IsOut = 0)
				BEGIN
				  SELECT   @NonMandetoryWeight = ISNULL(SUM(R.TotalWeight), 0)
                   FROM     (SELECT CASE WHEN Q.QuestionTypeId IN ( 1, 6,
                                                              21 )
                                             THEN MAX(O.Weight)
                                             ELSE SUM(O.Weight)
                                        END AS TotalWeight
                              FROM      dbo.Questions AS Q
                                        LEFT JOIN dbo.Options AS O ON O.QuestionId = Q.Id
                                        INNER JOIN dbo.Answers AS A ON A.QuestionId = Q.Id
                                                              AND Q.[Required] = 0
                                                              AND ISNULL(A.Detail,
                                                              '') = ''
										INNER JOIN dbo.AnswerMaster AS AM ON AM.id = A.AnswerMasterId
                              WHERE     Q.QuestionnaireId = AM.QuestionnaireId
                                        AND Q.QuestionTypeId IN ( 1, 5, 6, 18, 21 )
                                        AND Q.IsDeleted = 0
                                        AND Q.IsActive = 1
										AND A.RepetitiveGroupId = 0
                                        AND A.AnswerMasterId = @ReportId
                              GROUP BY  Q.Id ,
                                        Q.QuestionTypeId
                            ) AS R;

                   SELECT   @NonMandetoryWeight += ISNULL(SUM(R.TotalWeight),
                                                          0)
                   FROM     (SELECT CASE WHEN Q.WeightForYes > Q.WeightForNo
                                             THEN Q.WeightForYes
                                             ELSE Q.WeightForNo
                                        END AS TotalWeight
                              FROM      dbo.Questions AS Q
                                        INNER JOIN dbo.Answers AS A ON A.QuestionId = Q.Id
                                                              AND Q.[Required] = 0
                                                              AND ISNULL(A.Detail,
                                                              '') = ''
										INNER JOIN dbo.AnswerMaster AS AM ON AM.Id = A.AnswerMasterId
                              WHERE     Q.QuestionnaireId = AM.QuestionnaireId
                                        AND Q.QuestionTypeId IN ( 7 )
                                        AND Q.IsDeleted = 0
                                        AND Q.IsActive = 1
                                        AND A.AnswerMasterId = @ReportId
										AND A.RepetitiveGroupId = 0
                              GROUP BY  Q.Id ,
                                        Q.WeightForYes ,
                                        Q.WeightForNo
                            ) AS R;

						
					SELECT   @NonMandetoryWeight +=  CASE WHEN ISNULL(Details,'') != '' THEN 0
								   ELSE T.MaxWeight
											END
									FROM    ( SELECT    MAX(A.Detail) AS Details ,
														A.QuestionId ,
														Q.MaxWeight
											  FROM      dbo.Questions AS Q
														LEFT JOIN dbo.Options AS O ON O.QuestionId = Q.Id
														INNER JOIN dbo.Answers AS A ON A.QuestionId = Q.Id
											  WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 18, 21,7 )
														AND Q.IsDeleted = 0
														AND Q.IsActive = 1
														AND A.AnswerMasterId = @ReportId
														AND A.RepetitiveGroupId != 0
											  GROUP BY  A.QuestionId ,
														Q.MaxWeight
											) AS T;
				
				END
                ELSE
				BEGIN
				 SELECT   @NonMandetoryWeight = ISNULL(SUM(R.TotalWeight), 0)
                   FROM     ( SELECT    CASE WHEN Q.QuestionTypeId IN ( 1, 6,
                                                              21 )
                                             THEN MAX(O.Weight)
                                             ELSE SUM(O.Weight)
                                        END AS TotalWeight
                              FROM      dbo.SeenClientQuestions AS Q
                                        LEFT JOIN dbo.SeenClientOptions AS O ON O.QuestionId = Q.Id
                                        INNER JOIN dbo.SeenClientAnswers AS SA ON SA.QuestionId = Q.Id
                                                              AND Q.[Required] = 0
                                                              AND ISNULL(SA.Detail,
                                                              '') = ''
										INNER JOIN dbo.SeenClientAnswerMaster AS SCA ON SCA.id = @ReportId
                              WHERE     Q.SeenClientId = SCA.SeenClientId
                                        AND Q.QuestionTypeId IN ( 1, 5, 6, 18, 21 )
                                        AND Q.IsDeleted = 0
                                        AND Q.IsActive = 1
                                        AND SA.SeenClientAnswerMasterId = @ReportId
										AND SA.RepetitiveGroupId = 0
                              GROUP BY  Q.Id ,
                                        Q.QuestionTypeId
                            ) AS R;

                   SELECT   @NonMandetoryWeight += ISNULL(SUM(R.TotalWeight),
                                                          0)
                   FROM     ( SELECT    CASE WHEN Q.WeightForYes > Q.WeightForNo
                                             THEN Q.WeightForYes
                                             ELSE Q.WeightForNo
                                        END AS TotalWeight
                              FROM      dbo.SeenClientQuestions AS Q
                                        INNER JOIN dbo.SeenClientAnswers AS SA ON SA.QuestionId = Q.Id
                                                              AND Q.[Required] = 0
                                                              AND ISNULL(SA.Detail,
                                                              '') = ''
										INNER JOIN dbo.SeenClientAnswerMaster AS SCA ON SCA.id = @ReportId
                              WHERE     Q.SeenClientId = SCA.SeenClientId
                                        AND Q.QuestionTypeId IN ( 7 )
                                        AND Q.IsDeleted = 0
                                        AND Q.IsActive = 1
										AND SA.RepetitiveGroupId = 0
                                        AND SA.SeenClientAnswerMasterId = @ReportId
                              GROUP BY  Q.Id ,
                                        Q.WeightForYes ,
                                        Q.WeightForNo
                            ) AS R;
				
				 SELECT   @NonMandetoryWeight +=  CASE WHEN ISNULL(Details,'') != '' THEN 0
								   ELSE T.MaxWeight
											END
									FROM    ( SELECT    MAX(SA.Detail) AS Details ,
														SA.QuestionId ,
														Q.MaxWeight
											  FROM      dbo.SeenClientQuestions AS Q
														LEFT JOIN dbo.SeenClientOptions AS O ON O.QuestionId = Q.Id
														INNER JOIN dbo.SeenClientAnswers AS SA ON SA.QuestionId = Q.Id
											  WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 18, 21,7 )
														AND Q.IsDeleted = 0
														AND Q.IsActive = 1
														AND SA.SeenClientAnswerMasterId = @ReportId
														AND SA.RepetitiveGroupId != 0
											  GROUP BY  SA.QuestionId ,
														Q.MaxWeight
											) AS T;

				/* Added Vasu Patel 16 Mar 2017
				Following logic for Nonmadetory Field not selected then This is not effect on PI Calculation */

                END
                IF ( @IsOut = 0
                     AND @QuestionId = 0
                   )
                    BEGIN
                       SELECT  @TotalWeight = SUM(MaxWeight)
                        FROM    dbo.Questions
                        WHERE   QuestionnaireId = @QuestionnaireId
                                AND IsDeleted = 0
                                AND DisplayInGraphs = 1;

                        SELECT  @Weight = SUM(T.Weight) FROM (SELECT AVG(A.weight) AS Weight
                        FROM    dbo.Answers AS A
                                INNER JOIN dbo.Questions AS Q ON A.QuestionId = Q.Id
                        WHERE   A.AnswerMasterId = @ReportId
                                AND A.IsDeleted = 0
                                AND Q.DisplayInGraphs = 1 GROUP BY A.QuestionId) AS T;
                    END;
                ELSE
                    IF ( @IsOut = 0
                         AND @QuestionId > 0
                       )
                        BEGIN
                            SELECT  @TotalWeight = SUM(MaxWeight)
                            FROM    dbo.Questions
                            WHERE   id = @QuestionId
                                    AND IsDeleted = 0
                                    AND DisplayInGraphs = 1
									AND IsActive = 1;

                            SELECT  @Weight = SUM(T.Weight) FROM (SELECT AVG(A.weight) AS Weight
                            FROM    dbo.Answers AS A
                                    INNER JOIN dbo.Questions AS Q ON A.QuestionId = Q.Id
                            WHERE   A.AnswerMasterId = @ReportId
                                    AND A.QuestionId = @QuestionId
                                    AND A.IsDeleted = 0
                                    AND Q.DisplayInGraphs = 1 GROUP BY A.QuestionId) AS T;
                        END;
                    ELSE
                        IF ( @IsOut = 1
                             AND @QuestionId = 0
                           )
                            BEGIN
                                SELECT  @TotalWeight = SUM(MaxWeight)
                                FROM    dbo.SeenClientQuestions
                                WHERE   SeenClientId = @QuestionnaireId
                                        AND IsDeleted = 0
                                        AND DisplayInGraphs = 1
										AND IsActive = 1;

                                SELECT  @Weight = SUM(T.Weight) FROM (SELECT AVG(A.weight) AS Weight
                                FROM    dbo.SeenClientAnswers AS A
                                        INNER JOIN dbo.SeenClientQuestions AS Q ON A.QuestionId = Q.Id
                                WHERE   SeenClientAnswerMasterId = @ReportId
                                        AND A.IsDeleted = 0
                                        AND Q.DisplayInGraphs = 1 GROUP BY A.SeenClientAnswerChildId,A.QuestionId) AS T;
                            END;
                        ELSE
                            BEGIN
                                SELECT  @TotalWeight = SUM(MaxWeight)
                                FROM    dbo.SeenClientQuestions
                                WHERE   id = @QuestionId
                                        AND IsDeleted = 0
                                        AND DisplayInGraphs = 1;

                                SELECT  @Weight = SUM(T.Weight) FROM (SELECT AVG(A.weight) AS Weight
                                FROM    dbo.SeenClientAnswers AS A
                                        INNER JOIN dbo.SeenClientQuestions AS Q ON A.QuestionId = Q.Id
                                WHERE   SeenClientAnswerMasterId = @ReportId
                                        AND A.QuestionId = @QuestionId
                                        AND A.IsDeleted = 0
                                        AND Q.DisplayInGraphs = 1 GROUP BY A.SeenClientAnswerChildId, A.QuestionId) AS T;
                            END;
                
	
				SET @TotalWeight = @TotalWeight - @NonMandetoryWeight
			
                SELECT  @Result = @Weight * 100 / CASE ISNULL(@TotalWeight,0) WHEN 0 THEN 1 ELSE @TotalWeight end;
                SELECT  @Result = @Result / CASE ISNULL([Count],0) WHEN 0 THEN 1 ELSE [Count] END 
                FROM    @Tbl
                WHERE   Id = @Start;

                UPDATE  @Tbl
                SET     [PI] = @Result
                WHERE   Id = @Start;
                SET @Start = @Start + 1;
            END;

        SELECT  @FinalResult = ( SUM([PI]) / CASE COUNT(ReportId)
                                               WHEN 0 THEN 1
                                               ELSE COUNT(ReportId)
                                             END )
        FROM    @Tbl;
		RETURN @FinalResult;
    END;





