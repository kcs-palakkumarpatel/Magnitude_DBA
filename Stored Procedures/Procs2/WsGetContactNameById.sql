-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,GetContactById>
-- Call SP    :	WsGetContactNameById 226292
-- =============================================
CREATE PROCEDURE [dbo].[WsGetContactNameById]
    @Id BIGINT,
    @isGroup INT
AS
SET NOCOUNT ON;
DECLARE @Name NVARCHAR(MAX);
BEGIN
    IF (@isGroup = 1)
    BEGIN
        SET @Name =
        (
            SELECT ContactGropName FROM dbo.ContactGroup WITH (NOLOCK) WHERE Id = @Id
        );
    END;
    ELSE
    BEGIN

        SET @Name =
        (
            SELECT TOP 1
                   Detail
            FROM dbo.ContactDetails WITH
                (NOLOCK)
            WHERE ContactMasterId = @Id
                  AND QuestionTypeId = 4
        );
    END;
    SELECT ISNULL(@Name, '') AS Name;
END;
