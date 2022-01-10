CREATE PROCEDURE [dbo].[GetContactId]
@Id BIGINT,
@IsContact bit
AS
BEGIN
	IF(@IsContact!=0)
	BEGIN
		SELECT  ContactId
		FROM dbo.[Group] 
		WHERE Id=@Id AND IsDeleted=0
	END
END