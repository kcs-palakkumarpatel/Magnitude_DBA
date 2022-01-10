-- =============================================
-- Author:			Developer D3
-- Create date: 31-May-2017
-- Description:	Insert group users in child table "[SeenClientAnswerChild]"
-- Call SP    :	APIInsertSeenClientAnswerChild
-- =============================================
CREATE PROCEDURE [dbo].[APIInsertSeenClientAnswerChild]
    @SeenClientAnswerMasterId BIGINT ,
    @ContactMasterId BIGINT
AS
    BEGIN
        INSERT  INTO dbo.SeenClientAnswerChild
                ( SeenClientAnswerMasterId ,
                  ContactMasterId
                )
        OUTPUT  Inserted.Id
        VALUES  ( @SeenClientAnswerMasterId ,
                  @ContactMasterId
                );
    END;
