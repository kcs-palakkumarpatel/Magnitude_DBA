
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 25 May 2015>
-- Description:	<Description,,GetUserById>
-- Call SP    :	GetUserById
-- =============================================
CREATE PROCEDURE [dbo].[GetSetChangelanguage]
@Id BIGINT,
@Language BIGINT
AS
BEGIN
 
Update dbo.[User] Set LanguageMasterId = @Language where Id = @Id

SELECT ISNULL(LANG.LanguageName, 'en') AS [Language]  FROM dbo.[User] as U LEFT JOIN dbo.LanguageMaster AS LANG
            ON U.LanguageMasterId = LANG.Id WHERE U.Id = @Id
END