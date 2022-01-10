-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 25 May 2015>
-- Description:	<Description,,InsertOrUpdateUser>
-- Call SP    :	InsertOrUpdateUser
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateUser]
    @Id BIGINT,
    @Name VARCHAR(50),
    @SurName VARCHAR(50),
    @MobileNo VARCHAR(50),
    @EmailId VARCHAR(50),
    @UserName VARCHAR(50),
    @Password VARCHAR(100),
    @Address VARCHAR(500),
    @RoleId BIGINT,
    @IsActive BIT,
    @IsLogin BIT,
    @UserId BIGINT,
    @PageId BIGINT
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @oldPW VARCHAR(100),
            @expireDate DATETIME;

    SELECT @oldPW = Password,
           @expireDate = PWExpireDate
    FROM dbo.[User]
    WHERE [Id] = @Id;

    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[User]
        (
            [Name],
            [SurName],
            [MobileNo],
            [EmailId],
            [UserName],
            [Password],
            [Address],
            [RoleId],
            [IsActive],
            [IsLogin],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted]
        )
        VALUES
        (@Name, @SurName, @MobileNo, @EmailId, @UserName, @Password, @Address, @RoleId, @IsActive, @IsLogin,
         GETUTCDATE(), @UserId, 0);
        SELECT @Id = SCOPE_IDENTITY();
        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@UserId, @PageId, 'Insert record in table User', 'User', @Id, GETUTCDATE(), @UserId, 0);

        INSERT INTO dbo.[UserRolePermissions]
        (
            [PageID],
            [ActualID],
            [UserID],
            [CreatedOn],
            [CreatedBy],
            [UpdatedOn],
            [UpdatedBy],
            [DeletedOn],
            [DeletedBy],
            [IsDeleted]
        )
        VALUES
        (@PageId, @Id, @UserId, GETUTCDATE(), @UserId, NULL, NULL, NULL, NULL, 0);
    END;
    ELSE
    BEGIN
	 PRINT('update');
        IF (@oldPW <> @Password)
            SET @expireDate = DATEADD(DAY, 119, GETUTCDATE());

	 PRINT(@oldPW +' - ' + @Password);

        UPDATE dbo.[User]
        SET [Name] = @Name,
            [SurName] = @SurName,
            [MobileNo] = @MobileNo,
            [EmailId] = @EmailId,
            [UserName] = @UserName,
            [Password] = @Password,
            [Address] = @Address,
            [RoleId] = @RoleId,
            [IsActive] = @IsActive,
            [IsLogin] = @IsLogin,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId,
            [PWExpireDate] = @expireDate
        WHERE [Id] = @Id;
        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@UserId, @PageId, 'Update record in table User', 'User', @Id, GETUTCDATE(), @UserId, 0);
    END;


    IF (@oldPW <> @Password)
    BEGIN
        INSERT INTO dbo.UserPasswordLog
        (
            [UserId],
            [Name],
            [Email],
            UserName,
            [PassWord],
            CreatedOn,
            CreatedBy
        )
        VALUES
        (@Id, @Name, @EmailId, @UserName, @Password, GETUTCDATE(), @UserId);
		-- Set Login Attempt true & allow to Login this User
        INSERT dbo.UserLoginLog
        (
            UserId,
            UserName,
            Attempt,
            AttemptsLeft,
            IpAddress,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (   @Id,   -- UserId - bigint
            @UserName, -- UserName - nvarchar(50)
            1,         -- Attempt - bit
            10,        --AttemptsLeft - SMALLINT 
            N'',       -- IpAddress - nvarchar(50)
            GETDATE(), -- CreatedOn - datetime
            @UserId    -- CreatedBy - bigint
            );
    END;

    SELECT ISNULL(@Id, 0) AS InsertedId;
SET NOCOUNT OFF;
END;
