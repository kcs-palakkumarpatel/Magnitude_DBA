
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,InsertOrUpdateClient>
-- Call SP    :	InsertOrUpdateClient
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateClient]
    @Id BIGINT ,
    @ClientName VARCHAR(50) ,
    @SurName VARCHAR(50) ,
    @NickName VARCHAR(50) ,
    @EmailId VARCHAR(50) ,
    @CountryCode VARCHAR(10) ,
    @MobileNo VARCHAR(50) ,
    @Password VARCHAR(50) ,
    @BirthDate DATETIME ,
    @AnniversaryDate DATETIME ,
    @Address NVARCHAR(500) ,
    @City VARCHAR(50) ,
    @MeasurementDate DATETIME ,
    @PreferredCallTime VARCHAR(50) ,
    @ImageName VARCHAR(100) ,
    @SignName VARCHAR(50) ,
    @UserId INT ,
    @IsActive BIT ,
    @IsVerified BIT ,
    @TimeOffSet INT ,
    @Gender BIT ,
    @IsPromotionalSMS BIT ,
    @LoginUserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[Client]
                        ( [ClientName] ,
                          [SurName] ,
                          [NickName] ,
                          [EmailId] ,
                          [CountryCode] ,
                          [MobileNo] ,
                          [Password] ,
                          [BirthDate] ,
                          [AnniversaryDate] ,
                          [Address] ,
                          [City] ,
                          [MeasurementDate] ,
                          [PreferredCallTime] ,
                          [ImageName] ,
                          [SignName] ,
                          [UserId] ,
                          [IsActive] ,
                          [IsVerified] ,
                          [TimeOffSet] ,
                          [Gender] ,
                          [IsPromotionalSMS] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @ClientName ,
                          @SurName ,
                          @NickName ,
                          @EmailId ,
                          @CountryCode ,
                          @MobileNo ,
                          @Password ,
                          @BirthDate ,
                          @AnniversaryDate ,
                          @Address ,
                          @City ,
                          @MeasurementDate ,
                          @PreferredCallTime ,
                          @ImageName ,
                          @SignName ,
                          @UserId ,
                          @IsActive ,
                          @IsVerified ,
                          @TimeOffSet ,
                          @Gender ,
                          @IsPromotionalSMS ,
                          GETUTCDATE() ,
                          @LoginUserId ,
                          0
                        )
                SELECT  @Id = SCOPE_IDENTITY()
                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted 
                        )
                VALUES  ( @LoginUserId ,
                          @PageId ,
                          'Insert record in table Client' ,
                          'Client' ,
                          @Id ,
                          GETUTCDATE() ,
                          @LoginUserId ,
                          0
                        )
            END
        ELSE 
            BEGIN
                UPDATE  dbo.[Client]
                SET     [ClientName] = @ClientName ,
                        [SurName] = @SurName ,
                        [NickName] = @NickName ,
                        [EmailId] = @EmailId ,
                        [CountryCode] = @CountryCode ,
                        [MobileNo] = @MobileNo ,
                        [Password] = @Password ,
                        [BirthDate] = @BirthDate ,
                        [AnniversaryDate] = @AnniversaryDate ,
                        [Address] = @Address ,
                        [City] = @City ,
                        [MeasurementDate] = @MeasurementDate ,
                        [PreferredCallTime] = @PreferredCallTime ,
                        [ImageName] = @ImageName ,
                        [SignName] = @SignName ,
                        [UserId] = @UserId ,
                        [IsActive] = @IsActive ,
                        [IsVerified] = @IsVerified ,
                        [TimeOffSet] = @TimeOffSet ,
                        [Gender] = @Gender ,
                        [IsPromotionalSMS] = @IsPromotionalSMS ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @LoginUserId
                WHERE   [Id] = @Id
                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted 
                        )
                VALUES  ( @LoginUserId ,
                          @PageId ,
                          'Update record in table Client' ,
                          'Client' ,
                          @Id ,
                          GETUTCDATE() ,
                          @LoginUserId ,
                          0
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END