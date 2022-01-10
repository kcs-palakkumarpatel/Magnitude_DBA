-- =============================================
-- Author:		<Author,,Sunil Vaghasiya>
-- Create date: <Create Date,, 06 Jan 2017>
-- Description:	<Description,,InsertOrUpdateSeenClientAnswerMaster>
-- Call SP    :		UpdateSeenClientAnswerMaster 86592, 13474,609,1548,23.031807999999998,72.5721088,32186,false,null,0,Neutral,null,true,0
-- =============================================
CREATE PROCEDURE [dbo].[UpdateSeenClientAnswerMasterTemp]
    @Id BIGINT ,
    @EstablishmentId BIGINT ,
    @SeenClientId BIGINT ,
    @AppUserId BIGINT ,
    @Latitude NVARCHAR(50) = NULL ,
    @Longitude NVARCHAR(50) = NULL ,
    @ContactMasterId BIGINT = NULL ,
    @IsSubmittedForGroup BIT ,
    @ContactGroupId BIGINT = NULL ,
    @EI DECIMAL(18, 2) ,
    @IsPositive NVARCHAR(50) ,
    @MobileDate DATETIME = NULL ,
    @DraftEntry BIT = 0,
    @DraftSave INT = NULL
AS
    BEGIN
	 IF ( @DraftSave IS NULL )
            BEGIN
                SET @DraftSave = 0;     
            END;
      
        DECLARE @TimeOffSet INT ,
            @IsDeleted BIT = 1 ,
            @IsResolved NVARCHAR(50) = 'Unresolved';

        IF @DraftEntry = 0
            SET @IsDeleted = 0;

        IF @Latitude = ''
            OR @Latitude IS NULL
            SET @Latitude = '0.00';

        IF @Longitude = ''
            OR @Longitude IS NULL
            SET @Longitude = '0.00';

        IF @AppUserId = ''
            OR @AppUserId IS NULL
            SET @AppUserId = 0;

        IF @ContactGroupId > 0
            OR @ContactGroupId IS NOT NULL
            SET @IsSubmittedForGroup = 1;
	       
        SELECT  @TimeOffSet = TimeOffSet
        FROM    dbo.Establishment
        WHERE   Id = @EstablishmentId;
		DECLARE @CreateOn DATETIME = GETUTCDATE();
		
		       
IF EXISTS (SELECT Id FROM dbo.SeenClientAnswerMasterTemp WHERE IsDeleted = 1 AND Id = @Id)
BEGIN
        UPDATE  dbo.SeenClientAnswerMasterTemp
        SET     UpdatedOn = GETUTCDATE() ,
				CreatedOn = @CreateOn,
                UpdatedBy = @AppUserId ,
                TimeOffSet = @TimeOffSet ,
                ContactMasterId = @ContactMasterId ,
                IsSubmittedForGroup = @IsSubmittedForGroup ,
                ContactGroupId = @ContactGroupId ,
                EI = @EI ,
                IsPositive = @IsPositive ,
                IsResolved = @IsResolved ,
                DraftEntry = @DraftEntry ,
                IsDeleted = @IsDeleted,
				DraftSave = @DraftSave
        WHERE   Id = @Id;
END
        SELECT  ISNULL(@Id, 0) AS UpdatedID;

    END;
