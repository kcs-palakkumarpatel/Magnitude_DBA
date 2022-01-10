-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,12 Sep 2015>
-- Description:	<Description, ,>
-- SELECT dbo.ConvertTimeIntervalStringToMinute('10:20')
-- =============================================
CREATE FUNCTION [dbo].[ConvertTimeIntervalStringToMinute]
    (
      @IntervalString NVARCHAR(10)
    )
RETURNS INT
AS
    BEGIN
        DECLARE @TimeOffSet INT = 0;

        SELECT  @TimeOffSet = ISNULL(CAST(Data AS INT), 0) * 60
        FROM    dbo.Split(@IntervalString, ':')
        WHERE   Id = 1;
		
        SELECT  @TimeOffSet += ISNULL(CAST(Data AS INT), 0)
        FROM    dbo.Split(@IntervalString, ':')
        WHERE   Id = 2;

        RETURN @TimeOffSet;
    END;