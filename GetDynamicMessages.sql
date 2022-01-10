-- =============================================
-- Author:			Krishna Panchal
-- Create date:		28-Apr-2021
--	Description:	Get Dynamic Messages
--	Call SP:	GetDynamicMessages 12365
--	=============================================
CREATE PROCEDURE [dbo].[GetDynamicMessages] @ReportId BIGINT
AS
BEGIN
DECLARE @SeenClientChildAnswermasterId BIGINT = 0;
    SET @SeenClientChildAnswermasterId = ISNULL(
                                         (
                                             SELECT TOP 1
                                                    ISNULL(SeenClientAnswerChildId, 0)
                                             FROM SeenClientAnswers
                                             WHERE SeenClientAnswerMasterId = @ReportId
                                         ),
                                         0
                                               );

    SELECT ISNULL(
           (
               SELECT TOP 1
                      ReleaseDateValidationMessage
               FROM GetSeenClientAutoSMSEmailNotificationText(@ReportId, '', @SeenClientChildAnswermasterId)
           ),
           'Form is not released yet'
                 ) AS ReleaseDateValidationMessage,
           ISNULL(
           (
               SELECT TOP 1
                      MobiExpiredValidationMessage
               FROM GetSeenClientAutoSMSEmailNotificationText(@ReportId, '', @SeenClientChildAnswermasterId)
           ),
           'Form has been expired'
                 ) AS MobiExpiredValidationMessage;

END;
