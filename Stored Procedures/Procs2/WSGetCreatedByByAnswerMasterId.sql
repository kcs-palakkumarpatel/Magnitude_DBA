-- =============================================
-- Author:		GD
-- Create date: 03 Sep 2015
-- Description:	WSGetCreatedByByAnswerMasterId 230122222,1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetCreatedByByAnswerMasterId] 
@CaptureID BIGINT,
@isCaptureForm INT
AS
	Declare @CreatedByUserId INT = -1;

    BEGIN
	IF(@isCaptureForm = 1)
	BEGIN
		SET @CreatedByUserId =  (Select CreatedBy from SeenClientAnswerMaster where id = @CaptureID);
	END
	ELSE
	    SET @CreatedByUserId =  (Select CreatedBy from AnswerMaster where id = @CaptureID);  

	SELECT ISNULL(@CreatedByUserId,-1)
END
