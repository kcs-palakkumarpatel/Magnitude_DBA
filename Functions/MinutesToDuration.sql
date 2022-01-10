
    
-- =============================================    
-- Author:  <Disha>    
-- Create date: <13-SEP-2014>    
-- Description: <get concated string values>    
-- Calls: select dbo.MinutesToDuration (320)
-- =============================================

CREATE FUNCTION [dbo].[MinutesToDuration] ( @minutes BIGINT )
RETURNS NVARCHAR(30)
AS
    BEGIN
        DECLARE @hours NVARCHAR(30);

        SET @hours = CASE WHEN @minutes >= 60
                          THEN ( SELECT CAST(( @minutes / 60 ) AS NVARCHAR(30))
                                        + ' hour(s)'
                                        + CASE WHEN ( @minutes % 60 ) > 0
                                               THEN CAST(( @minutes % 60 ) AS NVARCHAR(30))
                                                    + ' minute(s)'
                                               ELSE ''
                                          END
                               )
                          ELSE CAST(( @minutes % 60 ) AS NVARCHAR(30))
                               + ' minute(s)'
                     END;

        RETURN @hours;
    END;
