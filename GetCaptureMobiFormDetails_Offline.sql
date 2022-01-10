-- =============================================
-- Author:		<Author,,Mittal>
-- Create date: <Create Date,,25 May 2021>
-- Description:	<Description,,>
CREATE PROCEDURE dbo.GetCaptureMobiFormDetails_Offline
    @SeenClientId BIGINT,
    @ContactMasterId BIGINT,
    @IsContactGroup BIT,
    @ContactMasterIdList NVARCHAR(MAX),
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00',
    @QuestionnaireId BIGINT,
    @SeenClientAnswerMasterId BIGINT,
    @SeenClientAnswerChildId BIGINT,
    @AnswerMasterId BIGINT = 0
AS
BEGIN
    EXEC dbo.WSGetSeenClientQuestionsBySeenClientId_OfflineAPI @SeenClientId = @SeenClientId,               -- bigint
                                                               @ContactMasterId = @ContactMasterId,         -- bigint
                                                               @IsContactGroup = @IsContactGroup,           -- bit
                                                               @ContactMasterIdList = @ContactMasterIdList, -- nvarchar(max)
                                                               @LastServerDate = @LastServerDate;           -- datetime

    EXEC dbo.WSGetSeenClientOptionsBySeenClientId_OfflineAPI @SeenClientId = @SeenClientId,     -- bigint
                                                             @LastServerDate = @LastServerDate; -- datetime

    EXEC dbo.GetMobiForm_OfflineAPI @QuestionnaireId = @QuestionnaireId,                   -- bigint
                                    @SeenClientAnswerMasterId = @SeenClientAnswerMasterId, -- bigint
                                    @SeenClientAnswerChildId = @SeenClientAnswerChildId,   -- bigint
                                    @AnswerMasterId = @AnswerMasterId,                     -- bigint
                                    @LastServerDate = @LastServerDate;                     -- datetime

    EXEC dbo.WSGetOptionsByQuestionnaireId_OfflineAPI @QuestionnaireId = @QuestionnaireId, -- bigint
                                                      @LastServerDate = @LastServerDate;   -- datetime


END;

