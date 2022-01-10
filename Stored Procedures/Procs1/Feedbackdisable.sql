-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <16 Dec 2015>
-- Description:	<FeedBack disable Enable>
-- =============================================
CREATE PROCEDURE [dbo].[Feedbackdisable]
    @Type NVARCHAR(10) ,
    @Id BIGINT ,
    @Isdisable BIT ,
    @UserId BIGINT
AS
    BEGIN

        IF ( @Type = 'OUT' )
            BEGIN
                UPDATE  dbo.SeenClientAnswerMaster
				SET     IsDisabled = @Isdisable,
						DisabledOn = GETUTCDATE(),
						DisabledBy = @UserId

                WHERE   Id = @Id;
                UPDATE  dbo.SeenClientAnswers
                SET     IsDisabled = @Isdisable,
						DisabledOn = GETUTCDATE(),
						DisabledBy = @UserId
                WHERE   SeenClientAnswerMasterId = @Id;
            END;
        ELSE
            IF ( @Type = 'IN' )
                BEGIN
                    UPDATE  dbo.AnswerMaster
                    SET     IsDisabled = @Isdisable,
							DisabledOn = GETUTCDATE(),
						DisabledBy = @UserId
                    WHERE   Id = @Id;
                    UPDATE  dbo.Answers
                    SET     IsDisabled = @Isdisable,
							DisabledOn = GETUTCDATE(),
							DisabledBy = @UserId
                    WHERE   AnswerMasterId = @Id;
                END;
    END;