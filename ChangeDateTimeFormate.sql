
-- =============================================
-- Author:		<Author,,Ghanshyam Dhanani>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ChangeDateTimeFormate]
(
	@DateTime Datetime
)
RETURNS nvarchar(50)
AS
BEGIN
	Declare @ResultSet varchar(50)
	select @ResultSet = convert(varchar(20),@DateTime,103)+ ' '+RIGHT('0' + LTRIM(STUFF(RIGHT(CONVERT(CHAR(26), @DateTime, 109), 14),9, 4, ' ')),11)--+ ' ' +right(convert(varchar(30),@DateTime,109),2)
	-- Return the result of the function
	RETURN @ResultSet

END