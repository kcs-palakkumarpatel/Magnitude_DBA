CREATE PROCEDURE [dbo].[GetContactRoleById]	@Id bigintASSET NOCOUNT ONDECLARE @ActivityId VARCHAR(500);DECLARE @EstablishmentId VARCHAR(500);SELECT  @ActivityId = COALESCE(@ActivityId + ',', '')
        + CONVERT(NVARCHAR(10), dbo.ContactRoleActivity.ActivityId)
FROM    dbo.ContactRoleActivity
WHERE   ContactRoleId = @Id;SELECT  @EstablishmentId = COALESCE(@EstablishmentId + ',', '')
        + CONVERT(NVARCHAR(10), dbo.ContactRoleEstablishment.EstablishmentId)
FROM    dbo.ContactRoleEstablishment
WHERE   ContactRoleId = @Id;SELECT [Id], 	[RoleName], 	[Descriptions],	[GroupId], 	[CreatedOn], 	[CreatedBy], 	[UpdatedOn], 	[UpdatedBy], 	[DeletedOn], 	[DeletedBy], 	[IsDeleted],	@ActivityId AS ActivityId,	@EstablishmentId AS EstablishmentIdFROM ContactRoleWHERE [Id] = @Id