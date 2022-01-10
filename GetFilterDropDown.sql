-- =============================================
-- Author:		<Anant,,ADMIN>
-- Create date: <10 Jun 2019,10 Jun 2019>
-- Description:	<Description,Get All Dashboard filter Values>
-- Call SP    :	GetFilterDropDown
-- =============================================
CREATE PROCEDURE [dbo].[GetFilterDropDown]
AS 
    BEGIN
        SELECT  dbo.FilterDropDown.Id AS Id ,
                dbo.FilterDropDown.FilterName AS FilterName
        FROM    dbo.FilterDropDown
        WHERE   dbo.FilterDropDown.IsDelete = 0 ORDER BY OrderBy ASC
    END
