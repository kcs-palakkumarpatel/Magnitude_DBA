

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[SplitOld] 
(
	@CommaSeparatedString nvarchar(max)
)
RETURNS 
@retval TABLE(
	[id] varchar(50)
)
AS
BEGIN
	declare @string varchar(500)
	SET @string = @CommaSeparatedString
	declare @pos numeric(20)
	declare @piece varchar(50)
	SET @pos = charindex(',' , @string)
	while @pos <> 0
	begin
		SET @piece = LEFT(@string, @pos-1)
		insert into @retval ([id])values (@piece)
		SET @string = stuff(@string, 1, @pos, NULL)
		SET @pos = charindex(',' , @string)
	end
	insert into @retval ([id])values (@string)
	
	RETURN 
END