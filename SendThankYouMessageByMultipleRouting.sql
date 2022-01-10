
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <15 Mar 2016>
-- Description:	<SeenClient and Feedback IsPossitive Logic as per Escalation PI>
-- Call:- SendThankYouMessageByMultipleRouting 330604
-- =============================================
CREATE PROCEDURE [dbo].[SendThankYouMessageByMultipleRouting]
    @AnswerMasterId BIGINT 

AS
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        DECLARE @ResultSet AS TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              QuestionId BIGINT ,
              QPi DECIMAL(18, 2)
            );

        DECLARE @MultipleRoutingValue DECIMAL(18,2);
        DECLARE @smile NVARCHAR(255);
        DECLARE @QuestionnaireId BIGINT;
        DECLARE @MultipleRoutingEstablishValue DECIMAL(18,2);
        DECLARE @PI DECIMAL(18, 2);
        DECLARE @Start BIGINT = 1;
        DECLARE @End BIGINT;
        DECLARE @QuestionId BIGINT;
        DECLARE @QPI DECIMAL(18, 2);
        DECLARE @Establishment BIGINT;
        DECLARE @IsMultipleRouting BIT;

		SELECT @Establishment = EstablishmentId FROM dbo.AnswerMaster WHERE id = @AnswerMasterId
	
        SELECT  @MultipleRoutingEstablishValue = MultipleRoutingValue ,
                @IsMultipleRouting = IsMultipleRouting
        FROM    dbo.Establishment
        WHERE   Id = @Establishment;

        IF ( @IsMultipleRouting = 1 )
            BEGIN
                INSERT  INTO @ResultSet
                        ( QuestionId ,
                          QPi
                        )
                        SELECT  QuestionId ,
                                QPI
                        FROM    dbo.Answers
                        WHERE   AnswerMasterId = @AnswerMasterId;

                SELECT  @End = COUNT(1)
                FROM    @ResultSet;

                SELECT  @smile = IsPositive,
                        @PI = [PI] ,
                        @Establishment = EstablishmentId
                FROM    dbo.AnswerMaster
                WHERE   Id = @AnswerMasterId;
                WHILE ( @Start <= @End )
                    BEGIN
                        SELECT  @QuestionId = QuestionId ,
                                @QPI = QPi
                        FROM    @ResultSet
                        WHERE   Id = @Start;        
                        SELECT  @MultipleRoutingValue = MultipleRoutingValue ,
                                @QuestionnaireId = QuestionnaireId
                        FROM    dbo.Questions
                        WHERE   Id = @QuestionId;

						PRINT @MultipleRoutingValue
						PRINT @QPI
						PRINT @smile

                        IF ( --@MultipleRoutingValue > 0 AND 
							@MultipleRoutingValue > @QPI
                             AND @smile != 'Negative'
                           )
                            BEGIN
								PRINT '1'
                                SET @smile = 'Negative';
                            END;
                        ELSE
                            IF ( --@MultipleRoutingValue > 0 AND 
								@MultipleRoutingValue < @QPI
                                 AND @smile != 'Negative'
                               )
                                BEGIN
								PRINT '2'
                                    SET @smile = 'Positive';
                                END;
                            ELSE
                                IF ( --@MultipleRoutingValue > 0 AND 
									 @MultipleRoutingValue = @QPI
                                     AND @smile != 'Negative'
                                   )
                                    BEGIN
									PRINT '3'
                                        SET @smile = 'Positive';
                                    END;
                        SET @Start += 1;
                    END;
                IF ( --@MultipleRoutingEstablishValue > 0 AND 
					 @MultipleRoutingEstablishValue > @PI
                     AND @smile != 'Negative'
                   )
                    BEGIN
					PRINT '4'
                        SET @smile = 'Negative';
                    END;
            END;
        ELSE
            SET @smile = 'NA';
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
         'dbo.SendThankYouMessageByMultipleRouting',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
        @AnswerMasterId,
	    GETUTCDATE(),
         N''
        );
END CATCH
    END;
			SELECT @smile AS ThankYouMessageType
