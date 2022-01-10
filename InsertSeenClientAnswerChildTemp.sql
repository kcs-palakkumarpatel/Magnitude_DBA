-- =============================================
-- Author:		Rushin
-- Create date: 16-12-15
-- Description:	Insert group users in child table "[SeenClientAnswerChild]"
-- Call SP    :	InsertSeenClientAnswerChild
-- =============================================
CREATE PROCEDURE [dbo].[InsertSeenClientAnswerChildTemp]
    @SeenClientAnswerMasterId BIGINT ,
    @ContactMasterId BIGINT
AS
    BEGIN
        INSERT  INTO dbo.SeenClientAnswerChildTemp(
			SeenClientAnswerMasterId
			,ContactMasterId)
		OUTPUT Inserted.Id
        VALUES  ( @SeenClientAnswerMasterId ,
                  @ContactMasterId
                );
        --SELECT  @Id = SCOPE_IDENTITY();
        --SELECT  ISNULL(@Id, 0) AS InsertedId;
    END;
