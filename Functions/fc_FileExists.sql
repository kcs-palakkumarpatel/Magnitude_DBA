CREATE FUNCTION [dbo].[fc_FileExists](@path varchar(8000))
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
    
     RETURN cast(@result as bit)
END;