
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,CountIndustry>
-- Call SP    :	CountIndustry
-- =============================================
CREATE PROCEDURE [dbo].[CountIndustry]
AS
BEGIN
SELECT COUNT(1) as Result FROM dbo.[Industry] 
 WHERE IsDeleted = 0
END