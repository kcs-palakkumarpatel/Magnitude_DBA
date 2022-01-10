-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,06 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSValidateMobileForFeedback
-- =============================================
CREATE PROCEDURE [dbo].[WSValidateMobileForFeedback]
    @MobileNo NVARCHAR(50) ,
    @EstablishmentId BIGINT
AS 
    BEGIN
        DECLARE @TimeInterval INT ,
            @FeedbackSubmitted BIT = 0
        
        SELECT  @TimeInterval = FeedbackTimeSpan
        FROM    dbo.Establishment
        WHERE   Id = @EstablishmentId      
        IF @TimeInterval > 0
            AND EXISTS ( SELECT *
                         FROM   dbo.AnswerMaster AS Am
                                INNER JOIN dbo.Answers AS A ON Am.Id = A.AnswerMasterId
                         WHERE  QuestionTypeId = 11
                                AND A.Detail = @MobileNo
                                AND Am.IsDeleted = 0
                                AND A.IsDeleted = 0
                                AND CAST(Am.CreatedOn AS DATE) = CAST(GETUTCDATE() AS DATE)
                                AND DATEDIFF(MINUTE, Am.CreatedOn,
                                             GETUTCDATE()) <= @TimeInterval ) 
            BEGIN
                SET @FeedbackSubmitted = 1
            END
        SELECT  ISNULL(@FeedbackSubmitted, 0) AS FeedbackSubmitted ,
                ISNULL(@TimeInterval, 0) AS FeedbackTimeSpan
    END