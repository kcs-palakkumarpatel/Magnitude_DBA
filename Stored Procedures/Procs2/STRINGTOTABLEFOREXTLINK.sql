--CALL EXEC STRINGTOTABLEFOREXTLINK '18438$vasudev,28935$Jatin',',','$'
CREATE PROCEDURE dbo.STRINGTOTABLEFOREXTLINK
(    
    @STR VARCHAR(500),@DELIM1 VARCHAR(10),@DELIM2 VARCHAR(10)    
)    
AS    
BEGIN    
    IF OBJECT_ID('TempDb..#TEMP') IS NOT NULL    
    DROP TABLE #TEMP    
        
    CREATE TABLE #TEMP( ContactId VARCHAR(50),    
                        EncryptedId VARCHAR(50),
						MobileNo varchar(20),
						EmailId varchar(100),
						URL nvarchar(200)
                      )     
    DECLARE @SUBSTR VARCHAR(50)       
    SET @SUBSTR=''      
    WHILE(CHARINDEX(@DELIM1,@STR)!=0)    
    BEGIN    
        SELECT @SUBSTR=SUBSTRING(@STR,1,CHARINDEX(@DELIM1,@STR)-1)    
        SELECT @STR=SUBSTRING(@STR,CHARINDEX(@DELIM1,@STR)+1,LEN(@STR))    
                    
        DECLARE @VAL1 VARCHAR(50)    
        SELECT @VAL1=SUBSTRING(@SUBSTR,1,CHARINDEX(@DELIM2,@SUBSTR)-1)    
        SELECT @SUBSTR=SUBSTRING(@SUBSTR,CHARINDEX(@DELIM2,@SUBSTR)+1,LEN(@SUBSTR))    
    
        DECLARE @VAL2 VARCHAR(50)    
        SELECT @VAL2= @SUBSTR --SUBSTRING(@SUBSTR,1,CHARINDEX(@DELIM2,@SUBSTR)-1)    
        --SELECT @SUBSTR=SUBSTRING(@SUBSTR,CHARINDEX(@DELIM2,@SUBSTR)+1,LEN(@SUBSTR))    
            
        --DECLARE @VAL3 VARCHAR(10)    
        --SET @VAL3=@SUBSTR    
            
        INSERT INTO #TEMP VALUES(@VAL1,@VAL2,null,null,null)    
    END    
    IF @STR IS NOT NULL    
    BEGIN    
        SELECT @VAL1=SUBSTRING(@STR,1,CHARINDEX(@DELIM2,@STR)-1)    
        SELECT @STR=SUBSTRING(@STR,CHARINDEX(@DELIM2,@STR)+1,LEN(@STR))    
    
        SELECT @VAL2= @STR --SUBSTRING(@STR,1,CHARINDEX(@DELIM2,@STR)-1)    
        --SELECT @STR=SUBSTRING(@STR,CHARINDEX(@DELIM2,@STR)+1,LEN(@STR))    
            
        --SET @VAL3=@STR    
            
        INSERT INTO #TEMP VALUES(@VAL1,@VAL2,null, null,null)
		UPDATE #TEMP SET MobileNo =  (SELECT DETAIL FROM ContactDetails WHERE ContactMasterId = T.ContactId AND QuestionTypeId = 11),
		EmailId =  (SELECT TOP 1 DETAIL FROM ContactDetails WHERE ContactMasterId = T.ContactId AND QuestionTypeId = 10) from #TEMP as T
    END    
    SELECT * FROM #TEMP  
END  
