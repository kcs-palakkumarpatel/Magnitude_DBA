
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <15 Mar 2016>
-- Description:	<SeenClient and Feedback IsPossitive Logic as per Escalation PI>
-- Call:- SeenclientandFeedbackIspositiveUpdate_8thJune2021 364962,1
-- =============================================
CREATE PROCEDURE [dbo].[SeenclientandFeedbackIspositiveUpdate_8thJune2021]
    @AnswerMasterId BIGINT,
    @Isout BIT
AS
BEGIN
SET NOCOUNT ON
    DECLARE @ResultSet AS TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        QuestionId BIGINT,
        QPi DECIMAL(18, 2)
    );
    DECLARE @PIEscalationValue BIGINT;
    DECLARE @smile NVARCHAR(255);
    DECLARE @QuestionnaireId BIGINT;
    DECLARE @EscalationValue BIGINT;
    DECLARE @PI DECIMAL(18, 2);
    DECLARE @Start BIGINT = 1;
    DECLARE @End BIGINT;
    DECLARE @QuestionId BIGINT;
    DECLARE @QPI DECIMAL(18, 2);
    DECLARE @IsAutoResolved BIT;
    DECLARE @AppUserId BIGINT;
    DECLARE @SeenClientAnswerMasterId BIGINT;
	DECLARE @ResolvedFromOut BIT;
    DECLARE @Offset INT;
    DECLARE @LastStatusId INT;
    DECLARE @CurrentStatusId INT;
    DECLARE @LastStatusName VARCHAR(15);
    DECLARE @ResolvedStatusName VARCHAR(15);
	DECLARE @Longitude NVARCHAR(20);
	DECLARE @Latitude NVARCHAR(20);
    DECLARE @EstablishmentId INT;
    IF (@Isout = 1)
    BEGIN
        SELECT @IsAutoResolved = Eg.IsAutoResolved,
               @AppUserId = Am.AppUserId,
               @SeenClientAnswerMasterId = Am.SeenClientAnswerMasterId
        FROM dbo.SeenClientAnswerMaster Am WITH(NOLOCK)
            INNER JOIN dbo.Establishment E WITH(NOLOCK)
                ON Am.EstablishmentId = E.Id
            INNER JOIN dbo.EstablishmentGroup Eg WITH(NOLOCK)
                ON E.EstablishmentGroupId = Eg.Id
        WHERE Am.Id = @AnswerMasterId;

        INSERT INTO @ResultSet
        (
            QuestionId,
            QPi
        )
        SELECT QuestionId,
               QPI
        FROM dbo.SeenClientAnswers WITH(NOLOCK)
        WHERE SeenClientAnswerMasterId = @AnswerMasterId
              AND QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 );

        SELECT @End = COUNT(1)
        FROM @ResultSet;

        PRINT @Start;
        PRINT @End;

        SELECT @smile = IsPositive,
               @PI = [PI]
        FROM dbo.SeenClientAnswerMaster WITH(NOLOCK)
        WHERE Id = @AnswerMasterId;
        WHILE (@Start <= @End)
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @QPI = QPi
            FROM @ResultSet
            WHERE Id = @Start;
            SELECT @PIEscalationValue = EscalationValue,
                   @QuestionnaireId = SeenClientId
            FROM dbo.SeenClientQuestions WITH(NOLOCK)
            WHERE Id = @QuestionId;
            SELECT @EscalationValue = EscalationValue
            FROM dbo.SeenClient WITH(NOLOCK)
            WHERE Id = @QuestionnaireId;
            PRINT @PIEscalationValue;
            PRINT @QPI;
            PRINT @smile;
            PRINT @EscalationValue;
            PRINT @PI;
            IF (
                   @PIEscalationValue > 0
                   AND @PIEscalationValue > @QPI
                   AND @smile != 'Negative'
               )
            BEGIN
                PRINT 1;
                UPDATE dbo.SeenClientAnswerMaster
                SET IsPositive = 'Negative'
                WHERE Id = @AnswerMasterId;
                SET @smile = 'Negative';

            END;
            ELSE IF (
                        @PIEscalationValue >= 0
                        AND @PIEscalationValue < @QPI
                        AND @smile != 'Negative'
                    )
            BEGIN
                PRINT 2;
                UPDATE dbo.SeenClientAnswerMaster
                SET IsPositive = 'Positive'
                WHERE Id = @AnswerMasterId;
                SET @smile = 'Positive';

            END;
            ELSE IF (
                        @PIEscalationValue >= 0
                        AND @PIEscalationValue = @QPI
                        AND @smile != 'Negative'
                    )
            BEGIN
                PRINT 'Print 3';
                PRINT @PIEscalationValue;
                PRINT @QPI;
                UPDATE dbo.SeenClientAnswerMaster
                SET IsPositive = 'Neutral'
                WHERE Id = @AnswerMasterId;
                SET @smile = 'Neutral';

            END;

            SET @Start += 1;
        END;
        IF (
               @EscalationValue > 0
               AND @EscalationValue > @PI
               AND @smile != 'Negative'
           )
        BEGIN
            PRINT 4;
            UPDATE dbo.SeenClientAnswerMaster
            SET IsPositive = 'Negative'
            WHERE Id = @AnswerMasterId;
            SET @smile = 'Negative';

        END;
        IF (
               @EscalationValue >= 0
               AND @EscalationValue < @PI
               AND @smile != 'Negative'
           )
        BEGIN
            PRINT 4;
            UPDATE dbo.SeenClientAnswerMaster
            SET IsPositive = 'Positive'
            WHERE Id = @AnswerMasterId;
            SET @smile = 'Positive';

        END;
        IF (
               @EscalationValue > 0
               AND @EscalationValue = @PI
               AND @smile != 'Negative'
           )
        BEGIN
            PRINT 4;
            UPDATE dbo.SeenClientAnswerMaster
            SET IsPositive = 'Neutral'
            WHERE Id = @AnswerMasterId;
            SET @smile = 'Neutral';

        END;
    END;

    IF (@IsAutoResolved = 1 AND @EscalationValue <= ROUND(@PI, 0))
	BEGIN
	PRINT'abc'
        UPDATE dbo.SeenClientAnswerMaster
        SET IsResolved = 'Resolved',
            Narration = 'Auto Resolved [EscalationValue = ' + CONVERT(NVARCHAR(10), @EscalationValue) + ']',
            EscalationSendDate = NULL,
            IsOutStanding = 0,
            ReadBy = @AppUserId
        WHERE Id = @AnswerMasterId;

		 DECLARE @EstablishmentStatusId BIGINT,
		  @StatusDate DATETIME;
         SELECT @StatusDate = GETUTCDATE();

		   SELECT @EstablishmentStatusId = es.Id,
		   @Latitude =SA.Latitude,
		   @Longitude = SA.Longitude
         FROM dbo.EstablishmentStatus AS es WITH(NOLOCK)
             INNER JOIN dbo.SeenClientAnswerMaster AS SA WITH(NOLOCK)
                 ON es.EstablishmentId = SA.EstablishmentId
         WHERE SA.Id = @AnswerMasterId
               AND DefaultEndStatus = 1
               AND es.IsDeleted = 0

		SELECT @Offset = SA.TimeOffSet,
           @LastStatusId = SA.StatusHistoryId,
           @EstablishmentId = SA.EstablishmentId
		FROM dbo.SeenClientAnswerMaster AS SA WITH(NOLOCK)
		WHERE SA.Id = @AnswerMasterId;
		  IF (
       (
           SELECT StatusIconEstablishment
           FROM dbo.Establishment WITH(NOLOCK)
           WHERE id = @EstablishmentId
                 AND IsDeleted = 0
       ) = 1
       )
    BEGIN
        PRINT '13242342';
        SELECT @LastStatusName = ES.StatusName
        FROM dbo.StatusHistory AS SH WITH(NOLOCK)
            INNER JOIN dbo.EstablishmentStatus AS ES WITH(NOLOCK)
                ON SH.EstablishmentStatusId = ES.Id
            INNER JOIN SeenClientAnswerMaster AS SA WITH(NOLOCK)
                ON SH.Id = SA.StatusHistoryId
        WHERE SH.id = @LastStatusId;


        EXEC dbo.InsertStatusHistory @ReferenceNo = @AnswerMasterId,                        -- bigint
                                     @EstablishmentStatusId = @EstablishmentStatusId, -- bigint
                                     @UserId = @AppUserId,                            -- bigint
                                     @Latitude = @Latitude,                           -- nvarchar(50)
                                     @Longitude = @Longitude,                         -- nvarchar(50)
                                     @StatusDateTime = @StatusDate,                   -- datetime
                                     @isWeb = NULL;

        IF @Isout = 1
        BEGIN
		PRINT '23'
            UPDATE dbo.SeenClientAnswerMaster
            SET statusHistoryId =
                (
                    SELECT TOP 1
                        id
                    FROM dbo.StatusHistory
                    WHERE ReferenceNo = @AnswerMasterId
                    ORDER BY id DESC
                )
            WHERE Id = @AnswerMasterId;
        END;
    END;
    END;
    ELSE
    BEGIN
	 PRINT 'xyz'
        SELECT @IsAutoResolved = Eg.IsAutoResolved,
               @AppUserId = Am.AppUserId
        FROM dbo.AnswerMaster Am WITH(NOLOCK)
            INNER JOIN dbo.Establishment E WITH(NOLOCK)
                ON Am.EstablishmentId = E.Id
            INNER JOIN dbo.EstablishmentGroup Eg WITH(NOLOCK)
                ON E.EstablishmentGroupId = Eg.Id
        WHERE Am.Id = @AnswerMasterId;

        INSERT INTO @ResultSet
        (
            QuestionId,
            QPi
        )
        SELECT QuestionId,
               QPI
        FROM dbo.Answers WITH(NOLOCK)
        WHERE AnswerMasterId = @AnswerMasterId
              AND QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 );

        SELECT @End = COUNT(1)
        FROM @ResultSet;

        SELECT @smile = IsPositive,
               @PI = [PI]
        FROM dbo.AnswerMaster WITH(NOLOCK)
        WHERE Id = @AnswerMasterId;
        WHILE (@Start <= @End)
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @QPI = QPi
            FROM @ResultSet
            WHERE Id = @Start;
            SELECT @PIEscalationValue = EscalationValue,
                   @QuestionnaireId = QuestionnaireId
            FROM dbo.Questions WITH(NOLOCK)
            WHERE Id = @QuestionId;
            SELECT @EscalationValue = EscalationValue
            FROM dbo.Questionnaire WITH(NOLOCK)
            WHERE Id = @QuestionnaireId;
            PRINT @PIEscalationValue;
            PRINT @QPI;
            PRINT @smile;
            PRINT @EscalationValue;
            PRINT @PI;
            IF (
                   @PIEscalationValue > 0
                   AND @PIEscalationValue > @QPI
                   AND @smile != 'Negative'
               )
            BEGIN
                UPDATE dbo.AnswerMaster
                SET IsPositive = 'Negative'
                WHERE Id = @AnswerMasterId;
                SET @smile = 'Negative';
            END;
            ELSE IF (
                        @PIEscalationValue >= 0
                        AND @PIEscalationValue < @QPI
                        AND @smile != 'Negative'
                    )
            BEGIN
                UPDATE dbo.AnswerMaster
                SET IsPositive = 'Positive'
                WHERE Id = @AnswerMasterId;
                SET @smile = 'Positive';
            END;
            ELSE IF (
                        @PIEscalationValue >= 0
                        AND @PIEscalationValue = @QPI
                        AND @smile != 'Negative'
                    )
            BEGIN
                UPDATE dbo.AnswerMaster
                SET IsPositive = 'Neutral'
                WHERE Id = @AnswerMasterId;
                SET @smile = 'Neutral';
            END;
            --IF ( @EscalationValue > 0
            --     AND @EscalationValue > @PI
            --     AND @smile != 'Negative'
            --   )
            --    BEGIN
            --        UPDATE  dbo.AnswerMaster
            --        SET     IsPositive = 'Negative'
            --        WHERE   Id = @AnswerMasterId;
            --        SET @smile = 'Negative';
            --    END;
            SET @Start += 1;
        END;
        IF (
               @EscalationValue > 0
               AND @EscalationValue > @PI
               AND @smile != 'Negative'
           )
        BEGIN
            PRINT 1;
            UPDATE dbo.AnswerMaster
            SET IsPositive = 'Negative'
            WHERE Id = @AnswerMasterId;
            SET @smile = 'Negative';

        END;
        IF (
               @EscalationValue >= 0
               AND @EscalationValue < @PI
               AND @smile != 'Negative'
           )
        BEGIN
            PRINT 2;
            PRINT @smile;
            UPDATE dbo.AnswerMaster
            SET IsPositive = 'Positive'
            WHERE Id = @AnswerMasterId;
            SET @smile = 'Positive';
            PRINT @smile;
        END;
        IF (
               @EscalationValue > 0
               AND @EscalationValue = @PI
               AND @smile != 'Negative'
           )
        BEGIN
            PRINT 3;
            UPDATE dbo.AnswerMaster
            SET IsPositive = 'Neutral'
            WHERE Id = @AnswerMasterId;
            SET @smile = 'Neutral';

        END;
        IF (@IsAutoResolved = 1 AND @EscalationValue <= ROUND(@PI, 0))
        BEGIN
		PRINT 'pqr'
            UPDATE dbo.AnswerMaster
            SET IsResolved = 'Resolved',
                Narration = 'Auto Resolved [EscalationValue = ' + CONVERT(NVARCHAR(10), @EscalationValue) + ']',
                EscalationSendDate = NULL,
                IsOutStanding = 0,
                ReadBy = @AppUserId
            WHERE Id = @AnswerMasterId;

            UPDATE dbo.SeenClientAnswerMaster
            SET IsResolved = 'Resolved'
            , Narration = 'Auto Resolved [EscalationValue = ' + CONVERT(NVARCHAR(10), @EscalationValue) + ']'
            --            EscalationSendDate = NULL,
            --            IsOutStanding = 0,
            --            ReadBy = @AppUserId
            FROM dbo.SeenClientAnswerMaster SCAM
                INNER JOIN dbo.AnswerMaster AM
                    ON SCAM.Id = AM.SeenClientAnswerMasterId
                INNER JOIN dbo.Establishment E
                    ON SCAM.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup Eg
                    ON E.EstablishmentGroupId = Eg.Id
            WHERE AM.Id = @AnswerMasterId;
        END;
    END;
SET NOCOUNT OFF
END;
