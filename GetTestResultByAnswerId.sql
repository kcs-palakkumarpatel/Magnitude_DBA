-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <05 Jan 2016>
-- Description:	<Get PI From Answermaster and result>
-- Call: GetTestResultByAnswerId 1138, 75.00
-- =============================================
CREATE PROCEDURE [dbo].[GetTestResultByAnswerId]
    @AnswerId BIGINT ,
    @FixBenchMark BIGINT
AS
    BEGIN
        SELECT  PI ,
                Result = CASE WHEN PI >= @FixBenchMark THEN 'Pass'
                              ELSE 'Fail'
                         END
        FROM    dbo.AnswerMaster
        WHERE   Id = @AnswerId;

        IF (( SELECT   pi
               FROM     dbo.AnswerMaster
               WHERE    Id = @AnswerId
             ) >= @FixBenchMark )
            BEGIN
                UPDATE  dbo.AnswerMaster
                SET     IsPositive = 'Positive'
                WHERE   Id = @AnswerId;
            END;
        ELSE
            BEGIN
                UPDATE  dbo.AnswerMaster
                SET     IsPositive = 'Negative'
                WHERE   Id = @AnswerId;
            END;
    END;