-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <15 Mar 2016>
-- Description:	<SeenClient and Feedback IsPossitive Logic as per Escalation PI>
-- Call:- SendThankYouMessageByMultipleRoutingForMobi 26039
-- =============================================
CREATE PROCEDURE [dbo].[SendThankYouMessageByMultipleRoutingForMobi]
    @AnswerMasterId BIGINT 

AS
    BEGIN

        DECLARE @ResultSet AS TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              QuestionId BIGINT ,
              QPi DECIMAL(18, 2)
            );
			   DECLARE @Url NVARCHAR(500);
        SELECT  @Url = KeyValue + 'Themes/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

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

		DECLARE @strThankYouMessage VARCHAR(500)
		DECLARE @strThankYouPositivePI VARCHAR(500)
		DECLARE @strThankYouNagetivePI VARCHAR(500)
		DECLARE @CommonFeedbackThankYouMessage VARCHAR(500)

		SELECT @Establishment = EstablishmentId FROM dbo.AnswerMaster WHERE id = @AnswerMasterId
	
        SELECT  @MultipleRoutingEstablishValue = MultipleRoutingValue ,
                @IsMultipleRouting = IsMultipleRouting,
				@strThankYouMessage = ThankYouMessage,
				@strThankYouNagetivePI = ThankyoumessageforLessthanPI,
				@strThankYouPositivePI = ThankyoumessageforGretareThanPI
        FROM    dbo.Establishment
        WHERE   Id = @Establishment;
		SELECT @CommonFeedbackThankYouMessage  = CommonFeedbackThankYouMessage FROM dbo.AboutUs
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

                SELECT  @smile = 'Positive' ,
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
    END;

	SELECT  @smile AS ThankYouMessageType ,@strThankYouMessage AS ThankYouMessage,
			@strThankYouNagetivePI AS ThankYouMessageForNagetive,
			@strThankYouPositivePI AS ThankYouMessageForPositive,
			@CommonFeedbackThankYouMessage AS CommonFeedbackThankYouMessage,ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponse.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponse.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouImage ,
					   ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponseNegative.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponseNegative.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouNagetiveImage ,
					   ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponsePositive.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponsePositive.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouPositiveImage 
					      FROM    dbo.Establishment AS E
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
                INNER JOIN dbo.[Group] AS G ON Eg.GroupId = G.Id
                INNER JOIN dbo.AnswerMaster AS SAM ON SAM.EstablishmentId = E.Id
        WHERE SAM.Id = @AnswerMasterId

	
