-- =============================================
-- Author:		Mittal Patel
-- Create date:	19-12-2019
-- Updateby:		
-- UpdatedOn:		
-- Description:	Get  AnswerMaster status by SeenClient AnswerMaster Id
-- Call SP:			dbo.GetAnswerMasterStatusBySeenClientAnswerMasterId 117369,0
-- =============================================
CREATE PROCEDURE [dbo].[GetAnswerMasterStatusBySeenClientAnswerMasterId]
    @SeenClientAnswerMasterId BIGINT,
    @IsOut BIT
AS
BEGIN
    IF @IsOut = 0
    BEGIN
        SELECT IsResolved
        FROM dbo.AnswerMaster
        WHERE Id = @SeenClientAnswerMasterId;
    END;
    ELSE
    BEGIN
        SELECT IsResolved
        FROM dbo.SeenClientAnswerMaster
        WHERE Id = @SeenClientAnswerMasterId;
    END;
END;
