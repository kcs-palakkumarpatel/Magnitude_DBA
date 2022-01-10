-- =============================================
-- Author:		Krishna Panchal
-- Create date: 27-Sep-2020
-- Description:	IsDefaultContact 2301
-- =============================================

CREATE PROCEDURE dbo.IsDefaultContact @AppUserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ISNULL(
           (
               SELECT ISNULL(IsDefaultContact, 0) AS IsDefaultContact
               FROM dbo.AppUser WITH (NOLOCK)
               WHERE Id = @AppUserId
           ),
           0
                 ) AS IsDefaultContact;
END;
