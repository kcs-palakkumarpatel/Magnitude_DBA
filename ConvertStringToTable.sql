
-- =============================================
-- Author:		Prerana parmar
-- Create date: 24 dec 2012
-- Description:	Convert string array
-- Calls : select  * from dbo.ConvertStringToTable('1,2,3,3',',')
-- =============================================

CREATE FUNCTION [dbo].[ConvertStringToTable]
(
	-- Add the parameters for the function here
	@Parameterstr NVARCHAR(4000), 
	@Seprator VARCHAR(4)
)
RETURNS 
@Result TABLE(ColumnValue NVARCHAR(100))
AS
BEGIN
	-- Fill the table variable with the rows for your result set
; WITH CTE(Start, [Stop]) AS
(
  SELECT  1, CHARINDEX(',' , @Parameterstr )
  UNION ALL
  SELECT  [Stop] + 1, CHARINDEX(',' ,@Parameterstr  , [Stop] + 1)
  FROM CTE
  WHERE [Stop] > 0
)
INSERT INTO @Result
SELECT  SUBSTRING(@Parameterstr , Start, CASE WHEN stop > 0 THEN [Stop]-Start ELSE 4000 END) AS stringValue
FROM CTE
option (maxrecursion 0)
	RETURN 
END