-- =============================================  
-- Author:  Disha Patel
-- Create date: 05-AUG-2015
-- Description: Get Comma Separated Name by Comma Separated Id   
-- GetCommaSeparatedNamebyIdForPdf '314','919','1356,11647,11648,11649,11650,1357,1313,12700','undefined','true'  
-- =============================================  
CREATE PROCEDURE [dbo].[GetCommaSeparatedNameByIdForPdf]
    @UserId NVARCHAR(MAX) ,
    @ActivityId NVARCHAR(MAX) ,
    @EstablishmentId NVARCHAR(MAX),
	@ReportId NVARCHAR(15),
	@IsOut VARCHAR(10)
AS
    BEGIN  
        DECLARE @ResultSet TABLE
            (
              [KeyName] VARCHAR(MAX) ,
              [KeyValue] VARCHAR(MAX)
            )  
      IF (@ReportId = 'undefined')
	  BEGIN
		SET @ReportId = '0';
	  END
      
      IF ( @IsOut = 'true' )
        BEGIN
            IF (@ReportId != '0')
                BEGIN
				PRINT @ReportId
                    SELECT  @EstablishmentId = EstablishmentId
                    FROM    dbo.SeenClientAnswerMaster
                    WHERE   Id = @ReportId;
                END;
        END;
      ELSE
        BEGIN
		 IF ( @ReportId != '0')
		 BEGIN
            SELECT  @EstablishmentId = EstablishmentId
            FROM    dbo.AnswerMaster
            WHERE   Id = @ReportId;
			END
        END;

        IF ( @UserId <> '0' )
            BEGIN  
                IF ( @UserId = '1' )
                    BEGIN
                        INSERT  INTO @ResultSet
                                ( [KeyName], [KeyValue] )
                        VALUES  ( 'User', 'N/A' )   
                    END
                ELSE
                    BEGIN
                        DECLARE @listStr NVARCHAR(MAX)    
                        SELECT  @listStr = COALESCE(@listStr + ' , ', '')
                                + Name
                        FROM    AppUser
                        WHERE   Id IN ( SELECT  Data
                                        FROM    dbo.Split(@UserId, ',') )   
                        INSERT  INTO @ResultSet
                                ( [KeyName], [KeyValue] )
                        VALUES  ( 'User', @listStr )    
                    END
            END  
        ELSE
            BEGIN  
                INSERT  INTO @ResultSet
                        ( [KeyName], [KeyValue] )
                VALUES  ( 'User', 'All' )    
            END
			    
        IF @ActivityId <> '0'
            BEGIN  
   
                DECLARE @listGrpStr NVARCHAR(MAX)    
                SELECT  @listGrpStr = COALESCE(@listGrpStr + ' , ', '')
                        + EstablishmentGroupName
                FROM    dbo.EstablishmentGroup
                WHERE   Id IN ( SELECT  Data
                                FROM    dbo.Split(@ActivityId, ',') )   
                INSERT  INTO @ResultSet
                        ( [KeyName], [KeyValue] )
                VALUES  ( 'Activity', @listGrpStr )    
            END  
        ELSE
            BEGIN  
                INSERT  INTO @ResultSet
                        ( [KeyName], [KeyValue] )
                VALUES  ( 'Activity', 'All' )    
            END         
        IF @EstablishmentId <> '0'
            BEGIN  
   
                DECLARE @listEstStr NVARCHAR(MAX)    
                SELECT  @listEstStr = COALESCE(@listEstStr + ' , ', '')
                        + EstablishmentName
                FROM    dbo.Establishment
                WHERE   Id IN ( SELECT  Data
                                FROM    dbo.Split(@EstablishmentId, ',') )   
                  
                INSERT  INTO @ResultSet
                        ( [KeyName], [KeyValue] )
                VALUES  ( 'Establishment', @listEstStr )    
            END  
        ELSE
            BEGIN  
                INSERT  INTO @ResultSet
                        ( [KeyName], [KeyValue] )
                VALUES  ( 'Establishment', 'All' )    
            END                   
  
        SELECT  [KeyName] ,
                [KeyValue]
        FROM    @ResultSet   
    END
