-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,22 Jun 2015>
-- Description:	<Description,,>
-- Call: select * from AllEstablishmentSelect('123,456,789,-2,-1')
-- =============================================
CREATE FUNCTION [dbo].[AllEstablishmentSelect]
    (
      @EstablishmentId NVARCHAR(MAX)

    )
RETURNS @Result TABLE
    (
      EstablishmentId BIGINT
    )
AS
    BEGIN
		DECLARE @listStr NVARCHAR(MAX);

		DECLARE @CustomerTable TABLE
(
	RowNum BIGINT ,
                        Total DECIMAL(18,2),
                        Id BIGINT,
                        EstablishmentId  BIGINT,
                        EstablishmentName NVARCHAR(max),
                        EstablishmentType NVARCHAR(MAX),
                        EstablishmentGroupType NVARCHAR(MAX),
                        EstablishmentGroupId BIGINT
)

    --IF EXISTS ( SELECT  *
    --        FROM    (SELECT    Data
    --                  FROM      dbo.Split(@EstablishmentId, ',')
    --                ) AS T WHERE (t.Data = -1 OR t.Data = -2))
    BEGIN
        
		--INSERT INTO @CustomerTable
		--        ( RowNum ,
		--          Total ,
		--          Id ,
		--          EstablishmentId ,
		--          EstablishmentName ,
		--          EstablishmentType ,
		--          EstablishmentGroupType ,
		--          EstablishmentGroupId
		--        )
		-- EXEC dbo.GetAppUserEstablishmentByAppUserId 10000,1,'','EstablishmentType',@AppuserId,@GroupId, 'Customer', @AppuserId;

		INSERT INTO @CustomerTable
		        ( RowNum ,
		          Total ,
		          Id ,
		          EstablishmentId ,
		          EstablishmentName ,
		          EstablishmentType ,
		          EstablishmentGroupType ,
		          EstablishmentGroupId
		        )
		select    0 , -- RowNum - bigint
		          0 , -- Total - decimal
		          0 , -- Id - bigint
		          Data , -- EstablishmentId - bigint
		          N'' , -- EstablishmentName - nvarchar(max)
		          N'' , -- EstablishmentType - nvarchar(max)
		          N'' , -- EstablishmentGroupType - nvarchar(max)
		          0  -- EstablishmentGroupId - bigint
		 FROM dbo.Split(@EstablishmentId, ',')

		 END;


         

		 INSERT INTO @Result
		         ( EstablishmentId )
		 SELECT EstablishmentId FROM @CustomerTable --WHERE EstablishmentId != -1 AND EstablishmentId != -2

        RETURN 
		
    END;