
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 09 Jun 2015>
-- Description:	<Description,,DeleteAppUser>
-- Call SP    :	DeleteAppUser
-- =============================================
alter PROCEDURE [dbo].[ResendHoussResponseForm]
    @ReportId BIGINT
AS 
    BEGIN
   DECLARE  @NewAppUserId BIGINT, @AMID BIGINT, @NewAMID BIGINT;

   SET @NewAppUserId = (Select AppUserId from SeenClientAnswerMaster where Id = @ReportID);
EXEC WSTransferFeedBack @ReportID, @NewAppUserId,@NewAppUserId , 1, 28412
SET @NewAMID = (Select top 1 ID from SeenClientAnswerMaster where SeenClientAnswerMasterId = @ReportID order by Id desc)
Update AnswerMaster set EstablishmentId = 28412 where SeenClientAnswerMasterId = @NewAMID;
SET @AMID = (Select ID from AnswerMaster where SeenClientAnswerMasterId = @NewAMID)
EXEC dbo.AdditionalRegisterFeedBackEmailSMS @AMID, 2974, 28412, @NewAppUserId
    END
