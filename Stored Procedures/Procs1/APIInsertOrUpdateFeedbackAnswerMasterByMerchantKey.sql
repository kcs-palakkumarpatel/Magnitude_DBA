-- =============================================
-- Author:			Developer D3
-- Create date:	30-09-2016
-- Description:	Insert Or Update Feedbacks AnswerMaster  Table for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIInsertOrUpdateFeedbackAnswerMasterByMerchantKey 293
-- =============================================
CREATE PROCEDURE [dbo].[APIInsertOrUpdateFeedbackAnswerMasterByMerchantKey]
    (
      @MerchantKey BIGINT = 0 ,
      @EstablishmentId BIGINT = 0 ,
      @QuestionnaireId BIGINT = 0 ,
      @AppUserId BIGINT = 0 
	)
AS
    BEGIN

        SET NOCOUNT OFF;

        DECLARE @TimeOffSet INT ,
            @AnswerMasterId BIGINT ,
            @Latitude NVARCHAR(50)  = NULL ,
            @Longitude NVARCHAR(50) = NULL ,
            @AUserId BIGINT = 0;

        SELECT TOP 1
                @AUserId = AppUserId
        FROM    dbo.AppUserEstablishment
        WHERE   EstablishmentId = @EstablishmentId;

        IF @Latitude = ''
            OR @Latitude IS NULL
            SET @Latitude = '0.00';

        IF @Longitude = ''
            OR @Longitude IS NULL
            SET @Longitude = '0.00';
        
        SELECT  @TimeOffSet = TimeOffSet
        FROM    dbo.Establishment
        WHERE   Id = @EstablishmentId;      

        INSERT  INTO dbo.AnswerMaster
                ( EstablishmentId ,
                  QuestionnaireId ,
                  AppUserId ,
				  IsOutStanding,
                  TimeOffSet ,
                  EscalationSendDate ,
                  ImportTypeId ,
                  Latitude ,
                  Longitude ,
                  CreatedBy ,
                  CreatedOn
                )
        VALUES  ( @EstablishmentId , -- EstablishmentId - bigint
                  @QuestionnaireId , -- QuestionnaireId - bigint
                  @AUserId , -- AppUserId - bigint         
				  1,	-- IsOutStanding - bit                
                  ISNULL(@TimeOffSet, 120) , -- TimeOffSet - int         
                  GETUTCDATE() , -- EscalationSendDate - datetime
                  1 , -- ImportTypeId - bigint                
                  @Latitude ,
                  @Longitude ,
                  @AppUserId ,  -- CreatedBy - bigint
                  GETUTCDATE()
                );
        SELECT  @AnswerMasterId = ISNULL(CAST(SCOPE_IDENTITY() AS BIGINT), 0); 

        --IF @OnceHistoryId > 0
        --    BEGIN
        --        UPDATE  dbo.FeedbackOnceHistory
        --        SET     IsFeedBackSubmitted = 1 ,
        --                AnswerMasterId = @AnswerMasterId
        --        WHERE   Id = @OnceHistoryId;
        --    END;

        SELECT  ISNULL(@AnswerMasterId, 0) AS InsertedId;

    END;