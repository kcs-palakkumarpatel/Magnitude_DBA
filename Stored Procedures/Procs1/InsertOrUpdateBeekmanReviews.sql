-- =============================================
-- Author:		<Ankit,,GD>
-- Create date: <Create Date,, 21 Jun 2019>
-- Description:	<Description,,InsertOrUpdateBeekmanReviews>
-- Call SP    :	InsertOrUpdateBeekmanReviews
-- =============================================
CREATE PROCEDURE dbo.InsertOrUpdateBeekmanReviews
(
    @BeekmanCompanyReviewsTableType BeekmanCompanyReviewsTableTypeNew READONLY,
    @EstablishmentId BIGINT = NULL,
    @ContactMasterId BIGINT = NULL,
    @AppUserId BIGINT = NULL,
    @SeenClientAnswerMasterId BIGINT = NULL,
    @EncryptSeenClientAnswerMasterId NVARCHAR(MAX) = NULL,
    @SeenClientId BIGINT = NULL,
    @SeenClientAnswerChild BIGINT = NULL,
    @EncryptSeenClientAnswerChildId NVARCHAR(MAX) = NULL
)
AS
BEGIN

    --SELECT *
    --FROM @BeekmanCompanyReviewsTableType;

    --PRINT 'EstablishmentId:' + CONVERT(VARCHAR(MAX), @EstablishmentId);
    --PRINT 'ContactMasterId:' + CONVERT(VARCHAR(MAX), @ContactMasterId);
    --PRINT 'AppUserId:' + CONVERT(VARCHAR(MAX), @AppUserId);
    --PRINT 'SeenClientAnswerMasterId:' + CONVERT(VARCHAR(MAX), @SeenClientAnswerMasterId);
    --PRINT 'EncryptSeenClientAnswerMasterId: ' + CONVERT(VARCHAR(MAX), @EncryptSeenClientAnswerMasterId);
    --PRINT 'SeenClientId:' + CONVERT(VARCHAR(MAX), @SeenClientId);
    --PRINT 'SeenClientAnswerChild:' + CONVERT(VARCHAR(MAX), @SeenClientAnswerChild);
    --PRINT 'EncryptSeenClientAnswerChildId: ' + CONVERT(VARCHAR(MAX), @EncryptSeenClientAnswerChildId);

    --DECLARE @BeekmanCompanyReviewsTableTypeRunTime BeekmanCompanyReviewsTableTypeNew;

    --INSERT INTO @BeekmanCompanyReviewsTableTypeRunTime
    --SELECT *
    --FROM @BeekmanCompanyReviewsTableType;

    DECLARE @SeenclintAnswerlistTemp SeenclintAnswer;

    INSERT INTO @SeenclintAnswerlistTemp
    (
        lgAnswerMasterId,
        lgChildId,
        lgQuestionId,
        inQuestionTypeId,
        strDetail,
        RepeatCount,
        RepetitiveGroupId,
        RepetitiveGroupName,
        lgAppUserId,
        CreatedOn
    )
    SELECT @SeenClientAnswerMasterId,
           ISNULL(@SeenClientAnswerChild, 0) AS [lgChildId],
           SCQ.Id AS [lgQuestionId],
           SCQ.QuestionTypeId AS [inQuestionTypeId],
           Unpvt.Description AS [strDetail],
           0 AS [RepeatCount],
           0 AS [RepetitiveGroupId],
           '' AS [RepetitiveGroupName],
           @AppUserId AS [lgAppUserId],
           '' AS [CreatedOn]
    FROM @BeekmanCompanyReviewsTableType UNPIVOT(Description FOR detail IN(Id, AppId, Review_Id, Id_On_Review_Site, Reservation_Number, Published_Date, Published_Date_Estimated, Travel_Date, [Source], Connection_Url, review_origin, Respond_Url, [Language], Language_name, Reviewer, Travel_Type, Travel_Composition, Title, Good_Comments, Bad_Comments, General_Comments, Manager_Comments, Recommend, Overall_Rating, Room_Rating, Cleanliness_Rating, Facilities_Rating, Service_Rating, Sentiment, Sentiment_Score, Opinions, Room_Name, Created_At, Updated_At, [Name], [Cell], [Email])) AS Unpvt
        LEFT JOIN dbo.SeenClientQuestions SCQ
            ON Unpvt.[detail] = SCQ.ShortName
               AND SCQ.SeenClientId = @SeenClientId
               AND SCQ.IsDeleted = 0
    WHERE SCQ.Id IS NOT NULL;

    EXEC dbo.InsertSeenClientAnswersTableValueParameter @SeenclintAnswerlist = @SeenclintAnswerlistTemp;

    EXEC dbo.CalculatePerformanceIndex @ReportId = @SeenClientAnswerMasterId, -- bigint
                                       @IsOut = 1;                            -- bit

    EXEC dbo.SeenclientandFeedbackIspositiveUpdate @AnswerMasterId = @SeenClientAnswerMasterId, -- bigint
                                                   @Isout = 1;                                  -- bit

    DECLARE @RegisterSeenClientEmailSMSTableTypeTemp RegisterSeenClientEmailSMSTableType;

    INSERT INTO @RegisterSeenClientEmailSMSTableTypeTemp
    (
        lgAnswerMasterId,
        SeenClientAnswerChildId,
        lgSeenClientId,
        lgEstablishmentId,
        lgAppUserId,
        EncryptedId,
        lstReoccurring,
        Resend
    )
    VALUES
    (   @SeenClientAnswerMasterId, -- lgAnswerMasterId - bigint
        CASE ISNULL(@SeenClientAnswerChild, 0)
            WHEN 0 THEN
                 N''
            ELSE
                @SeenClientAnswerChild
        END,                       -- SeenClientAnswerChildId - bigint
        @SeenClientId,             -- lgSeenClientId - bigint
        @EstablishmentId,          -- lgEstablishmentId - bigint
        @AppUserId,                -- lgAppUserId - bigint
        CASE ISNULL(@SeenClientAnswerChild, 0)
            WHEN 0 THEN
                @EncryptSeenClientAnswerMasterId
            ELSE
                @EncryptSeenClientAnswerMasterId + '&Cid=' + @EncryptSeenClientAnswerChildId
        END,                       -- EncryptedId - nvarchar(100)
        N'',                       -- lstReoccurring - nvarchar(100)
        0                          -- Resend - bit
    );


DECLARE @RegisterSeenClientEmailSMS XML
SET @RegisterSeenClientEmailSMS = (SELECT lgAnswerMasterId,
       SeenClientAnswerChildId,
       lgSeenClientId,
       lgEstablishmentId,
       lgAppUserId,
       EncryptedId,
       lstReoccurring,
       Resend
FROM @RegisterSeenClientEmailSMSTableTypeTemp
FOR XML RAW('row'), ROOT('ClsAnswers'), ELEMENTS);

    --SELECT *
    --FROM @RegisterSeenClientEmailSMSTableTypeTemp;

    --EXEC dbo.RegisterSeenClientEmailSMSTableValueParameter @RegisterSeenClientEmailSMS = @RegisterSeenClientEmailSMSTableTypeTemp;

	 EXEC dbo.RegisterSeenClientEmailSMS @RegisterSeenClientEmailSMS = @RegisterSeenClientEmailSMS;

END;

