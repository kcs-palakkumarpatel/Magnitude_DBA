-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <17 Feb 2016>
-- Description:	<Get Timer Flag By RefId>
-- Call: GetTimerFlagByRefId 
-- =============================================
CREATE PROCEDURE [dbo].[GetTimerFlagByRefId] @RefId BIGINT, @childId BIGINT
AS
    BEGIN
        SELECT  *
        FROM    dbo.TimerFlag
        WHERE   RefId = @RefId AND ChildId = @childId;
    END;