CREATE PROCEDURE [dbo].[InsertOrUpdateContactRole]

	@Id bigint,
	@RoleName nvarchar(25),
	@Descriptions nvarchar(250),
	@GroupId bigint,
	@CreatedBy bigint,
	@ActivityId NVARCHAR(500),
	@EstablishmentId NVARCHAR(500),
	@AppUserId NVARCHAR(500)
AS
SET NOCOUNT ON
IF @Id = 0 BEGIN
DECLARE @insertedId BIGINT
	INSERT INTO ContactRole (
		[RoleName],
		[Descriptions],
		[GroupId],
		[CreatedOn],
		[CreatedBy]
	)
	VALUES (
		@RoleName,
		@Descriptions,
		@GroupId,
		GETUTCDATE(),
		@CreatedBy
	)
	SELECT @insertedId = SCOPE_IDENTITY() 

	INSERT INTO ContactRoleDetails (
		[ContactRoleId],
		[AppUserId],
		[CreatedOn],
		[CreatedBy]
	)
	SELECT @insertedId,AppUserId,GETUTCDATE(),@CreatedBy  FROM dbo.AppUserEstablishment WHERE EstablishmentId IN (SELECT Data FROM dbo.Split(@EstablishmentId,',')) AND IsDeleted = 0 GROUP BY AppUserId

	INSERT INTO dbo.ContactRoleActivity
	        ( ContactRoleId, ActivityId )
	SELECT @insertedId,Data FROM split(@ActivityId,',') WHERE Data != 0;

		INSERT INTO dbo.ContactRoleEstablishment
		        ( ContactRoleId, EstablishmentId )
		SELECT @insertedId,Data FROM split(@EstablishmentId,',') WHERE Data != 0;

		SELECT @insertedId AS Insertid
END
ELSE BEGIN
	UPDATE ContactRole SET 
		[RoleName] = @RoleName,
		[Descriptions] = @Descriptions,
		[GroupId] = @GroupId,
		[UpdatedOn] = GETUTCDATE(),
		[UpdatedBy] = @CreatedBy
		WHERE [Id] = @Id

	DELETE FROM dbo.ContactRoleDetails WHERE ContactRoleId = @Id

	DELETE FROM dbo.ContactRoleActivity WHERE ContactRoleId = @Id

	DELETE FROM dbo.ContactRoleEstablishment WHERE ContactRoleId = @Id

	INSERT INTO ContactRoleDetails (
		[ContactRoleId],
		[AppUserId],
		[CreatedOn],
		[CreatedBy]
	)
	SELECT @insertedId,AppUserId,GETUTCDATE(),@CreatedBy  FROM dbo.AppUserEstablishment WHERE EstablishmentId IN (SELECT Data FROM dbo.Split(@EstablishmentId,',')) AND IsDeleted = 0 GROUP BY AppUserId

	INSERT INTO dbo.ContactRoleActivity
	        ( ContactRoleId, ActivityId )
	SELECT @Id,Data FROM split(@ActivityId,',') WHERE Data != 0;

		INSERT INTO dbo.ContactRoleEstablishment
		        ( ContactRoleId, EstablishmentId )
		SELECT @Id,Data FROM split(@EstablishmentId,',') WHERE Data != 0;

		SELECT @Id AS Insertid
END