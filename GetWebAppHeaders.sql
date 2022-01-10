-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 19 Dec 2016>
-- Description:	<Description,,>
-- Call SP    :	[GetWebAppHeaders]
-- =============================================
CREATE PROCEDURE [dbo].[GetWebAppHeaders]
AS
    BEGIN
        SELECT  Id, LabelName, IsLabel FROM dbo.WebAppHeaders WHERE IsDeleted= 0 ORDER BY Id ASC
    END;
