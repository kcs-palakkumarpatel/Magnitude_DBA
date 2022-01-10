-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <18 Oct 2016>
-- Description:	<Insert Contact Role Details>
-- =============================================
CREATE PROCEDURE [dbo].[InsertContactRoleDetails]
	@ContactRole NVARCHAR(500),
	@CreatedBy BIGINT,
	@AppUserId BIGINT
AS
BEGIN

DELETE dbo.ContactRoleDetails WHERE AppUserId = @AppUserId --AND ContactRoleId IN (SELECT data FROM dbo.Split(@ContactRole,','))
INSERT INTO ContactRoleDetails (
		[ContactRoleId],
		[AppUserId],
		[AppEstablishmentUserId],
		[CreatedOn],
		[CreatedBy]
		)
        SELECT  ContactRoleId ,
				@AppUserId,
                AppUserId,
                GETUTCDATE() ,
                @CreatedBy
        FROM    dbo.AppUserEstablishment
                 INNER JOIN dbo.ContactRoleEstablishment ON ContactRoleEstablishment.EstablishmentId = AppUserEstablishment.EstablishmentId
        WHERE   ContactRoleId IN (SELECT data FROM dbo.Split(@ContactRole,','))
                AND AppUserEstablishment.IsDeleted = 0
        GROUP BY AppUserId,ContactRoleId;
END