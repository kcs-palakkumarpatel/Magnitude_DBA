CREATE FUNCTION [dbo].[TRIM](@string NVARCHAR(max))
    RETURNS NVARCHAR(max)
     BEGIN
      RETURN LTRIM(RTRIM(@string))
     END
