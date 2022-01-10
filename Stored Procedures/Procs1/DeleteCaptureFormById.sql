--############################################################
-- For Delete Capture Form By SeenClientAnswerMasterId
-- Date: 10-01-2017 [SUNIL VAGHASIYA]
--############################################################
CREATE PROCEDURE [dbo].[DeleteCaptureFormById]
    (
      @SeenClientAnswerMasterId NVARCHAR(1000)
    )
AS
    BEGIN
        DELETE  dbo.CloseLoopAction
        WHERE   SeenClientAnswerMasterId IN (
                SELECT  Data
                FROM    dbo.Split(@SeenClientAnswerMasterId, ',') );
        DELETE  dbo.SeenClientAnswerChild
        WHERE   SeenClientAnswerMasterId IN (
                SELECT  Data
                FROM    dbo.Split(@SeenClientAnswerMasterId, ',') );

        DELETE  dbo.SeenClientAnswers
        WHERE   SeenClientAnswerMasterId IN (
                SELECT  Data
                FROM    dbo.Split(@SeenClientAnswerMasterId, ',') );

        DELETE  FROM dbo.SeenClientAnswerMaster
        WHERE   Id IN ( SELECT  Data
                        FROM    dbo.Split(@SeenClientAnswerMasterId, ',') );
    END;