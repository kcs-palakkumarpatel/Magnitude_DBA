-- =============================================
-- Author:		Rushin
-- Create date: 16-12-15
-- Description:	Return table to comma separated value
-- =============================================
CREATE FUNCTION [dbo].[TableToCommaSeparatedValue](@tmp delimiterTableType READONLY)
	RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @listStr NVARCHAR(MAX)

	SELECT @listStr = COALESCE(@listStr+', ' ,'') + value
	FROM    @tmp  AS awe

	RETURN @listStr
END