
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,08 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		VerifyOnceFeedbackSetting 0, 0,0,0
-- =============================================
CREATE PROCEDURE [dbo].[VerifyOnceFeedbackSetting]
    @SeenClientAnswerMasaterId BIGINT,
    @OnceHistoryId BIGINT,
    @AnswerMasterid BIGINT,
    @SeenclientChildId BIGINT = 0
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @FeedbackOnce BIT = 0,
            @EstablishmentId BIGINT = 0,
            @IsFeedbackSubmitted BIT = 0,
            @AnswerMaster BIGINT = 0,
            @AppUserId BIGINT = 0;

    IF @SeenClientAnswerMasaterId > 0
    BEGIN
        SELECT @IsFeedbackSubmitted = IsFeedBackSubmitted,
               @EstablishmentId = EstablishmentId,
               @FeedbackOnce = E.FeedbackOnce,
               @OnceHistoryId = CASE E.FeedbackOnce
                                    WHEN 0 THEN
                                        ISNULL(H.Id, 0)
                                    ELSE
                                        H.Id
                                END,
               @AnswerMaster = ISNULL(H.AnswerMasterId, 0)
        FROM dbo.FeedbackOnceHistory AS H WITH (NOLOCK)
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                ON E.Id = H.EstablishmentId
        WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasaterId
              AND ISNULL(H.SeenclientChildId, 0) = ISNULL(@SeenclientChildId, 0); --AND H.AnswerMasterId IS NOT NULL;

        SELECT @AppUserId = AppUserId
        FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)
        WHERE Id = @SeenClientAnswerMasaterId;
    END;
    ELSE IF @AnswerMasterid > 0
    BEGIN
        SELECT @IsFeedbackSubmitted = IsFeedBackSubmitted,
               @EstablishmentId = EstablishmentId,
               @FeedbackOnce = E.FeedbackOnce,
               @OnceHistoryId = CASE E.FeedbackOnce
                                    WHEN 0 THEN
                                        0
                                    ELSE
                                        H.Id
                                END
        FROM dbo.FeedbackOnceHistory AS H WITH (NOLOCK)
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                ON E.Id = H.EstablishmentId
        WHERE H.EstablishmentId = @AnswerMasterid;
    END;
    ELSE IF @OnceHistoryId > 0
    BEGIN
        SELECT @IsFeedbackSubmitted = IsFeedBackSubmitted,
               @EstablishmentId = EstablishmentId,
               @FeedbackOnce = E.FeedbackOnce
        FROM dbo.FeedbackOnceHistory AS H WITH (NOLOCK)
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                ON E.Id = H.EstablishmentId
        WHERE H.Id = @OnceHistoryId;
    END;

    SELECT ISNULL(@FeedbackOnce, 0) AS FeedbackOnce,
           ISNULL(@EstablishmentId, 0) AS EstablishmentId,
           ISNULL(@IsFeedbackSubmitted, 0) AS IsFeedbackSubmitted,
           ISNULL(@OnceHistoryId, 0) AS OnceHistoryId,
           ISNULL(@AnswerMaster, 0) AS AnwerMasterId,
           ISNULL(@AppUserId, 0) AS AppUserId;
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
         'dbo.VerifyOnceFeedbackSetting',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @SeenClientAnswerMasaterId+','+@OnceHistoryId+','+@AnswerMasterid+','+@SeenclientChildId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
    SET NOCOUNT OFF;
END;
