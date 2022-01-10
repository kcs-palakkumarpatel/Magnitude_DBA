
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,CountClient>
-- Call SP    :	CountClient
-- =============================================
CREATE PROCEDURE [dbo].[CountClient]
AS
BEGIN
SELECT COUNT(1) as Result FROM dbo.[Client] 
 WHERE IsDeleted = 0
END