-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,08 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		GetEstablishmentBySMSKeyForFeedback 'WessaCC'
-- =============================================
CREATE PROCEDURE [dbo].[GetEstablishmentBySMSKeyForFeedback] @SMSKey NVARCHAR(50)
AS
BEGIN
    DECLARE @EstablishmentId BIGINT = 0,
            @FeedbackOnce BIT = 0,
            @FeedbackUrl NVARCHAR(500),
            @FeedbackOnceHistoryId BIGINT = 0,
            @AutoResponseMessage NVARCHAR(300),
            @GroupKeyword NVARCHAR(1),
            @GroupId BIGINT;

    SELECT @FeedbackUrl = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'FeedbackUrl';

    SELECT TOP 1
        @EstablishmentId = E.Id,
        @FeedbackOnce = E.FeedbackOnce,
        @AutoResponseMessage = E.AutoResponseMessage,
        @GroupId = g.Id,
        --@GroupKeyword = CASE ISNULL(g.GroupKeyword, '')
        --                    WHEN '' THEN
        --                        0
        --                    ELSE
        --                        1
        --                END,
        @GroupKeyword = CASE
                            WHEN E.UniqueSMSKeyword = @SMSKey THEN
                                0
                            WHEN E.CommonSMSKeyword = @SMSKey THEN
                                0
                            WHEN g.GroupKeyword = @SMSKey THEN
                                1
                        END
    FROM dbo.Establishment AS E
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON Eg.Id = E.EstablishmentGroupId
        INNER JOIN dbo.[Group] AS g
            ON g.Id = E.GroupId
    WHERE (
              UniqueSMSKeyword = @SMSKey
              OR E.CommonSMSKeyword = @SMSKey
              OR g.GroupKeyword = @SMSKey
          )
          AND Eg.EstablishmentGroupType = 'Customer'
          AND Eg.EstablishmentGroupId IS NOT NULL
          AND E.IsDeleted = 0;

    IF @EstablishmentId > 0
       AND @FeedbackOnce = 1
    BEGIN
        INSERT INTO dbo.FeedbackOnceHistory
        (
            EstablishmentId,
            AnswerMasterId,
            SeenClientAnswerMasterId,
            IsFeedBackSubmitted
        )
        VALUES
        (   @EstablishmentId, -- EstablishmentId - bigint
            NULL,             -- AnswerMasterId - bigint
            NULL,             -- SeenClientAnswerMasterId - bigint
            1                 -- IsFeedBackSubmitted - bit   IF FeedbackOnce then IsFeedbacksubmitted = 1
        );

        SELECT @FeedbackOnceHistoryId = SCOPE_IDENTITY();
    END;

    SELECT ISNULL(@EstablishmentId, 0) AS EstablishmentId,
           ISNULL(@FeedbackOnce, 0) AS FeedbackOnce,
           ISNULL(@FeedbackUrl, '') AS FeedbackUrl,
           ISNULL(@FeedbackOnceHistoryId, 0) AS FeedbackOnceHistoryId,
           ISNULL(@AutoResponseMessage, '') AS AutoResponseMessage,
           ISNULL(@GroupKeyword, '0') AS GroupKeyword,
           ISNULL(@GroupId, 0) AS GroupId;
END;
