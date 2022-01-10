-- =============================================
-- Author:		Vasudev Patel
-- Create date: 22 Sep 2016
-- Description:	Resend Capture from By Capture Id
-- Call: GetCaptureDetailsByIDForResend 42377
-- =============================================
CREATE PROCEDURE [dbo].[GetCaptureDetailsByIDForResend] 
	-- Add the parameters for the stored procedure here
    @SeenclientAnswerMasterId BIGINT
AS
    BEGIN
        DECLARE @ChildId NVARCHAR(500);
        IF NOT EXISTS ( SELECT  1
                        FROM    dbo.AnswerMaster
                        WHERE   SeenClientAnswerMasterId = @SeenclientAnswerMasterId )
            BEGIN

	
                SELECT  @ChildId = STUFF((SELECT    ','
                                                    + CAST(ISNULL(Id, 0) AS NVARCHAR(10))
                                          FROM      dbo.SeenClientAnswerChild
                                          WHERE     SeenClientAnswerMasterId = @SeenclientAnswerMasterId
                        FOR              XML PATH('') ,
                                             TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 1, '');


                SELECT  SeenClientId ,
                        EstablishmentId ,
                        AppUserId ,
                        ISNULL(@ChildId, 0) AS SeenclientChildId
                FROM    dbo.SeenClientAnswerMaster
                WHERE   Id = @SeenclientAnswerMasterId;
            END;
        ELSE
            BEGIN
                SELECT  SeenClientId ,
                        EstablishmentId ,
                        AppUserId ,
                        ISNULL(@ChildId, 0) AS SeenclientChildId
                FROM    dbo.SeenClientAnswerMaster
                WHERE   1 = 2;
            END;

    END;