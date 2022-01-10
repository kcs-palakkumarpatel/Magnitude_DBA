
-- =============================================
-- Author:		Krishna Panchal
-- Create date: <04 Apr 2020>
-- Description:	Is Feedback Expired
-- Call SP:		IsFeedbackExpired 977536
-- =============================================
CREATE PROCEDURE [dbo].[IsFeedbackExpired] @SeenClientAnswerMasterId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @SeenClientChildAnswermasterId BIGINT = 0;
    SET @SeenClientChildAnswermasterId = ISNULL(
                                         (
                                             SELECT TOP 1
                                                 ISNULL(SeenClientAnswerChildId, 0)
                                             FROM SeenClientAnswers WITH (NOLOCK)
                                             WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                                         ),
                                         0
                                               );
    SELECT (CASE
                WHEN ISNULL(
                     (
                         SELECT TOP 1
                             ISNULL(SCA.Detail, '')
                         FROM dbo.SeenClientQuestions SCQ WITH (NOLOCK)
                             INNER JOIN dbo.SeenClientAnswers SCA WITH (NOLOCK)
                                 ON SCQ.Id = SCA.QuestionId
                                    AND SCA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                                    AND SCQ.TenderQuestionType = 2
                     ),
                     ''
                           ) <> '' THEN
                    CASE
                        WHEN
                        (
                            SELECT TOP 1
                                CAST(ISNULL(SCA.Detail, '1900-01-01') AS DATETIME)
                            FROM dbo.SeenClientQuestions SCQ WITH (NOLOCK)
                                INNER JOIN dbo.SeenClientAnswers SCA WITH (NOLOCK)
                                    ON SCQ.Id = SCA.QuestionId
                                       AND SCA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                                       AND SCQ.TenderQuestionType = 2
                        ) > DATEADD(   MINUTE,
                            (
                                SELECT TOP 1
                                    TimeOffSet
                                FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)
                                WHERE Id = @SeenClientAnswerMasterId
                            ),
                                       GETUTCDATE()
                                   ) THEN
                            0
                        ELSE
                            1
                    END
                ELSE
                    0
            END
           ) AS IsMobiExpired,
           ISNULL(
           (
               SELECT TOP 1
                   MobiExpiredValidationMessage
               FROM GetSeenClientAutoSMSEmailNotificationText(
                                                                 @SeenClientAnswerMasterId,
                                                                 '',
                                                                 @SeenClientChildAnswermasterId
                                                             )
           ),
           ''
                 ) AS MobiExpiredValidationMessage;
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
         'dbo.IsFeedbackExpired',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
        @SeenClientAnswerMasterId,
	    GETUTCDATE(),
         N''
        );
END CATCH
    SET NOCOUNT OFF;
END;
