
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	06-Mar-2017
-- Updateby:		Vasudev Patel
-- UpdatedOn:		12-Mar-2017
-- Description:	Get All AnswerMaster by SeenClient AnswerMaster Id
-- Call SP:			dbo.GetAnswerMastersBySeenClientAnswerMasterId 38151,0
-- =============================================
CREATE PROCEDURE [dbo].[GetAnswerMastersBySeenClientAnswerMasterId_111721]
    @AnswerMasterId BIGINT ,
    @IsOut BIT
AS
    BEGIN
        DECLARE @TEMP TABLE
            (
              AnswerMasterId BIGINT ,
              IsOut BIT,
			  AnswerStatus VARCHAR(20)
            );
        DECLARE @SeenClientAnswerMasterId BIGINT = 0;

        IF @IsOut = 0
            BEGIN

                SELECT  @SeenClientAnswerMasterId = SeenClientAnswerMasterId
                FROM    dbo.AnswerMaster
                WHERE   Id = @AnswerMasterId;
				
                INSERT  @TEMP
                        ( AnswerMasterId ,
                          IsOut,
						  AnswerStatus
                        )
                        SELECT  Id ,
                                1,
								IsResolved
                        FROM    dbo.SeenClientAnswerMaster
                        WHERE   Id = @SeenClientAnswerMasterId;

                INSERT  @TEMP
                        ( AnswerMasterId ,
                          IsOut,
						  AnswerStatus
                        )
                        SELECT  Id ,
                                0,
								IsResolved
                        FROM    dbo.AnswerMaster
                        WHERE   SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                                AND Id NOT IN ( @AnswerMasterId );
            END;
        ELSE
            BEGIN
                INSERT  @TEMP
                        ( AnswerMasterId ,
                          IsOut,
						  AnswerStatus
                        )
                        SELECT  Id ,
                                0,
								IsResolved
                        FROM    dbo.AnswerMaster
                        WHERE   SeenClientAnswerMasterId = @AnswerMasterId;
            END;

        SELECT  *
        FROM    @TEMP;
    END;
