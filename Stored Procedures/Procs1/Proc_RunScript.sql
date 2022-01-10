
CREATE PROC Proc_RunScript
AS
    BEGIN    
        SET XACT_ABORT ON;
		
		DECLARE @DatabaseName NVARCHAR(100) = 'USE Magnitude_Gold_Demo'
		
        /*
        DECLARE @RemoveWord NVARCHAR(200) = 'sp_';
        DECLARE @FilePath NVARCHAR(200) = 'D:\Imp_Script\Important_SP\';
        DECLARE @Prefix VARCHAR(50) = 'Proc_';
		*/
		
		
        DECLARE @RemoveWord NVARCHAR(200) = '';
        DECLARE @FilePath NVARCHAR(200) = 'D:\IMP_Script\unused\';
        DECLARE @Prefix VARCHAR(50) = 'zzz_Del_';
		
		
        DECLARE @SpName NVARCHAR(500);
        DECLARE @i INT = 0;
        DECLARE @trancount INT;
        SET @trancount = @@trancount;
			
        BEGIN TRY  
            BEGIN TRANSACTION; 
	
            DECLARE CurMain CURSOR SCROLL
            FOR
                
                /*
				/*
					FOLLOWING SQL FOR FOUND OUT THE USED SP LIST
				*/
                SELECT  name
                FROM    sys.procedures
                WHERE   name IN (
					Select name from tblusedsp_final )
                ORDER BY object_id;
				*/
				
				
				
				/*
				FOLLOWING SQL FOR UNUSED SP LIST
				*/
				SELECT  Name
                FROM dbo.unusedsplist
				WHERE Id > 109
                ORDER BY Id;
				

            OPEN CurMain;    
            FETCH FIRST FROM CurMain INTO @SpName;    
    
            WHILE @@Fetch_Status = 0
                BEGIN    
                    DECLARE @ProcName VARCHAR(500) = 'PROCEDURE NAME : '
                        + @SpName;
				
                    EXEC GetScript @DatabaseName, @SpName, @Prefix, @RemoveWord, @FilePath;
				
                    FETCH NEXT FROM CurMain INTO @SpName;    
                    IF @@Fetch_Status <> 0
                        BREAK;    
                END;    
				
            CLOSE CurMain;
            DEALLOCATE CurMain;
            
				
            COMMIT;
        END TRY  
   
        BEGIN CATCH  
            CLOSE CurMain;
            DEALLOCATE CurMain;
        
            ROLLBACK; 
        
            DECLARE @error INT ,
                @Error_File VARCHAR(150);
            DECLARE @message VARCHAR(4000);
            DECLARE @xstate INT;
            DECLARE @OLE INT; 
            DECLARE @FileID INT; 
            DECLARE @LineSeparator VARCHAR(100);
            DECLARE @GetUTCDate VARCHAR(100);
            DECLARE @File VARCHAR(100) = @FilePath + 'ERRORLOG.txt';
	 
            SELECT  @error = ERROR_NUMBER() ,
                    @message = ERROR_MESSAGE() ,
                    @xstate = XACT_STATE();
            IF @xstate = -1
                ROLLBACK;
            IF @xstate = 1
                AND @trancount = 0
                ROLLBACK;
            IF @xstate = 1
                AND @trancount > 0
                ROLLBACK TRANSACTION Write_Error_In_TxtFile;

            RAISERROR ('Proc_RunScript: %d: %s', 16, 1, @error, @message);
		
            SET @LineSeparator = REPLICATE('*', 100);
            SET @GetUTCDate = 'Date & Time    : '
                + CONVERT(VARCHAR(50), GETUTCDATE());
            SET @Error_File = 'Error No       : '
                + CONVERT(VARCHAR(50), @error);
            SET @message = 'Error Message  : ' + @message;
		
            EXECUTE sp_OACreate 'Scripting.FileSystemObject', @OLE OUT; 
            EXECUTE sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, @File, 8, 1; 
            EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineSeparator;
            EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @ProcName;
            EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @GetUTCDate;
            EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @Error_File; 
            EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @message;
            EXECUTE sp_OADestroy @FileID; 
            EXECUTE sp_OADestroy @OLE; 
        END CATCH; 	
    END;