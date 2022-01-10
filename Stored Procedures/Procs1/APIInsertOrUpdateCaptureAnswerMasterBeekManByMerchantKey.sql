-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Insert Or Update Capture AnswerMaster  Table for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIInsertOrUpdateCaptureAnswerMasterByMerchantKey
-- =============================================
-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Insert Or Update Capture AnswerMaster  Table for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIInsertOrUpdateCaptureAnswerMasterByMerchantKey
-- =============================================
CREATE PROCEDURE [dbo].[APIInsertOrUpdateCaptureAnswerMasterBeekManByMerchantKey]
    (
      @MerchantKey BIGINT = 0 ,
      @CopyReferenceId BIGINT = NULL ,
      @DraftEntry BIT = 0 ,
      @EstablishmentId BIGINT = 0 ,
      @CaptureId BIGINT = 0 ,
      @AppUserId BIGINT = 0 ,
      @Latitude NVARCHAR(50) = NULL ,
      @Longitude NVARCHAR(50) = NULL ,
      @ContactMasterId BIGINT = NULL ,
      @IsSubmittedForGroup BIT ,
      @ContactGroupId BIGINT = NULL ,
      @EI DECIMAL(18, 2) ,
      @IsPositive NVARCHAR(50) ,
      @MobileDate DATETIME = NULL,
	  @CreateDate DATETIME = NULL
	)
AS
    BEGIN
	SET NOCOUNT ON;
        DECLARE @TimeOffSet INT ,
            @Id BIGINT ,
            @IsDelete BIT = 0 ,
            @IsResolved NVARCHAR(50) = 'Unresolved',
			@StatusHistoryId BIGINT;

        IF @CopyReferenceId = 0
            SET @CopyReferenceId = NULL;

        IF @DraftEntry = 1
            SET @IsDelete = 1;

        IF @Latitude = ''
            OR @Latitude IS NULL
            SET @Latitude = '0.00';

        IF @Longitude = ''
            OR @Longitude IS NULL
            SET @Longitude = '0.00';


        IF @AppUserId = ''
            OR @AppUserId IS NULL
            SET @AppUserId = 0;

			IF @ContactGroupId > 0 OR @ContactGroupId IS NOT NULL
            SET @IsSubmittedForGroup = 1;
	
            
        SELECT  @TimeOffSet = TimeOffSet
        FROM    dbo.Establishment WITH (NOLOCK)
        WHERE   Id = @EstablishmentId;

        INSERT  INTO dbo.[SeenClientAnswerMaster]
                ( [EstablishmentId] ,
                  [SeenClientId] ,
                  [AppUserId] ,
                  [Latitude] ,
                  [Longitude] ,
                  [TimeOffSet] ,
                  [ContactMasterId] ,
                  [IsSubmittedForGroup] ,
                  [ContactGroupId] ,
				  [CreatedOn],
                  [CreatedBy] ,
                  [EI] ,
                  [IsPositive] ,
                  [IsResolved] ,
                  [MobileDate] ,
                  [CopyReferenceID] ,
                  [DraftEntry] ,
                  [IsDeleted]
				)
        VALUES  ( @EstablishmentId ,
                  @CaptureId ,
                  @AppUserId ,
                  @Latitude ,
                  @Longitude ,
                  @TimeOffSet ,
                  @ContactMasterId ,
                  @IsSubmittedForGroup ,
                  @ContactGroupId ,
				  GETUTCDATE(),
                  @AppUserId ,
                  @EI ,
                  @IsPositive ,
                  @IsResolved ,
                  @MobileDate ,
                  @CopyReferenceId ,
                  @DraftEntry ,
                  @IsDelete
                );

        SELECT  @Id = SCOPE_IDENTITY();

		IF EXISTS
    (
        SELECT StatusIconEstablishment
        FROM dbo.Establishment WITH (NOLOCK)
        WHERE Id = @EstablishmentId
    )
    BEGIN
        INSERT INTO dbo.StatusHistory
        (
            ReferenceNo,
            EstablishmentStatusId,
            UserId,
            StatusDateTime,
            Latitude,
            IsOut,
            Longitude,
            CreatedOn,
            CreatedBy,
            UpdatedOn,
            UpdatedBy,
            DeletedOn,
            DeletedBy,
            IsDeleted
        )
        VALUES
        (   @Id,                                        -- ReferenceNo - bigint
            (
                SELECT Id
                FROM dbo.EstablishmentStatus
                WHERE EstablishmentId = @EstablishmentId
                      AND DefaultStartStatus = 1
                      AND IsDeleted = 0
            ),                                          -- EstablishmentStautId - bigint
            @AppUserId,                                 -- UserId - bigint
            DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()), --StatusDateTime   
            @Latitude,                                  -- Latitude - nvarchar(50)
            1,                                          -- IsOut - bit
            @Longitude,                                 -- Longitude - nvarchar(50)
            GETUTCDATE(),                               -- CreatedOn - datetime
            @AppUserId,                                 -- CreatedBy - bigint
            NULL,                                       -- UpdatedOn - datetime
            0,                                          -- UpdatedBy - bigint
            NULL,                                       -- DeletedOn - datetime
            0,                                          -- DeletedBy - bigint
            0                                           -- IsDeleted - bit		
        );
		
        SELECT  @StatusHistoryId = SCOPE_IDENTITY();

		IF(@StatusHistoryId > 0)
		BEGIN
			Update dbo.SeenClientAnswerMaster Set StatusHistoryId = @StatusHistoryId where Id = @Id;
		END
    END;

        SELECT  ISNULL(@Id, 0) AS InsertedId;
SET NOCOUNT OFF;
    END;
