-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <12 Jan 2016>
-- Description:	<Error Handle for email send>
-- =============================================
CREATE PROCEDURE [dbo].[PendingEmailCounterUpdate] @Id BIGINT
AS
    BEGIN
        UPDATE  dbo.PendingEmail
        SET     Counter = Counter + 1
        WHERE   id = @Id;
    END;