-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,02 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		ExportReportSetting
-- =============================================
CREATE PROCEDURE [dbo].[ExportReportSetting_15Sept2021]
    @QuestionnaireId BIGINT ,
    @SeenClientId BIGINT
AS
    BEGIN
        DECLARE @MaxRank BIGINT = 0 ,
            @MinRank BIGINT= 0 ,
            @QuestionId NVARCHAR(MAX) ,
            @QuestionnaireType NVARCHAR(10) ,
            @SeenClientType NVARCHAR(10) ,
            @IsNPS BIT = 0 ,
            @DisplayType INT = 0;

        SELECT  @QuestionnaireType = QuestionnaireType
        FROM    Questionnaire
        WHERE   Id = @QuestionnaireId;

        SELECT  @SeenClientType = SeenClientType
        FROM    dbo.SeenClient
        WHERE   Id = @SeenClientId;

        DELETE  FROM dbo.ReportSetting
        WHERE   QuestionnaireId = @QuestionnaireId;

        DELETE  FROM dbo.ReportSetting
        WHERE   SeenClientId = @SeenClientId;

        IF @QuestionnaireId > 0
            BEGIN
                IF @QuestionnaireType = 'EI'
                    BEGIN
                        SELECT  @QuestionId = ISNULL(dbo.ConcateString('ReprotSetting',
                                                              @QuestionnaireId),
                                                     '');

                        SELECT  @MinRank = ISNULL(MIN(Position), 0)
                        FROM    dbo.Options
                        WHERE   EXISTS (
                                SELECT  Data
                                FROM    dbo.Split(@QuestionId, ',') where QuestionId = Data);
                        SELECT  @MaxRank = ISNULL(MAX(Position), 0)
                        FROM    dbo.Options
                        WHERE   EXISTS (
                                SELECT  Data
                                FROM    dbo.Split(@QuestionId, ',') where QuestionId = Data);
					END;
                ELSE
                    BEGIN
                        SELECT  @QuestionId = COALESCE(@QuestionId + ',', '')
                                + CONVERT(NVARCHAR(50), ISNULL(Questions.Id,
                                                              ''))
                        FROM    Questionnaire
                                INNER JOIN Questions ON Questionnaire.Id = Questions.QuestionnaireId
                        WHERE   ( Questions.QuestionTypeId = 2 )
                                AND ( Questionnaire.Id = @QuestionnaireId )
                                AND ( Questionnaire.IsDeleted <> 1 );

                        SET @MinRank = 0;
                        SET @MaxRank = 0;
                        SET @IsNPS = 1;
                        SET @DisplayType = 1;
                    END;
  
                DELETE  FROM dbo.ReportSetting
                WHERE   QuestionnaireId = @QuestionnaireId;

                IF NOT EXISTS ( SELECT  *
                                FROM    ReportSetting
                                WHERE   QuestionnaireId = @QuestionnaireId
                                        AND ReportType = 'SnapShot' )
                    BEGIN
                        INSERT  INTO dbo.ReportSetting
                                ( QuestionnaireId ,
                                  MinRank ,
                                  MaxRank ,
                                  QuestionId ,
                                  DisplayType ,
                                  IsNPS ,
                                  ReportType
                                )
                        VALUES  ( @QuestionnaireId , -- QuestionnaireId - bigint
                                  @MinRank , -- MinRank - int
                                  @MaxRank , -- MaxRank - int
                                  ISNULL(@QuestionId, '') , -- QuestionId - nvarchar(max)
                                  @DisplayType , -- DisplayType - int
                                  @IsNPS , -- IsNPS - bit
                                  'SnapShot'  -- ReportType - varchar(50)
                                );	
                    END;
                IF NOT EXISTS ( SELECT  *
                                FROM    ReportSetting
                                WHERE   QuestionnaireId = @QuestionnaireId
                                        AND ReportType = 'Analysis' )
                    BEGIN
                        INSERT  INTO dbo.ReportSetting
                                ( QuestionnaireId ,
                                  MinRank ,
                                  MaxRank ,
                                  QuestionId ,
                                  DisplayType ,
                                  IsNPS ,
                                  ReportType
                                )
                        VALUES  ( @QuestionnaireId , -- QuestionnaireId - bigint
                                  @MinRank , -- MinRank - int
                                  @MaxRank , -- MaxRank - int
                                  ISNULL(@QuestionId, '') , -- QuestionId - nvarchar(max)
                                  @DisplayType , -- DisplayType - int
                                  @IsNPS , -- IsNPS - bit
                                  'Analysis'  -- ReportType - varchar(50)
                                );	

                    END;
                UPDATE  dbo.Questionnaire
                SET     LastLoadedDate = DATEADD(MINUTE, 120, GETUTCDATE())
                WHERE   Id = @QuestionnaireId;
            END;
        ELSE
            BEGIN
                IF @SeenClientType = 'EI'
                    BEGIN
                        SELECT  @QuestionId = ISNULL(dbo.ConcateString('SeenClientReportSetting',
                                                              @SeenClientId),
                                                     '');

                        SELECT  @MinRank = ISNULL(MIN(Position), 0)
                        FROM    dbo.SeenClientOptions
                        WHERE   EXISTS (
                                SELECT  Data
                                FROM    dbo.Split(@QuestionId, ',') where QuestionId = Data);

                        SELECT  @MaxRank = ISNULL(MAX(Position), 0)
                        FROM    dbo.SeenClientOptions
                        WHERE   EXISTS (
                                SELECT  Data
                                FROM    dbo.Split(@QuestionId, ',') where QuestionId = Data);
                    END;
                ELSE
                    BEGIN
                        SELECT  @QuestionId = COALESCE(@QuestionId + ',', '')
                                + CONVERT(NVARCHAR(50), ISNULL(Sq.Id, ''))
                        FROM    dbo.SeenClient AS S
                                INNER JOIN dbo.SeenClientQuestions AS Sq ON S.Id = Sq.SeenClientId
                        WHERE   ( Sq.QuestionTypeId = 2 )
                                AND ( S.Id = @SeenClientId )
                                AND ( S.IsDeleted = 0 );

                        SET @MinRank = 0;
                        SET @MaxRank = 0;
                        SET @IsNPS = 1;
                        SET @DisplayType = 1;
                    END;

                DELETE  FROM dbo.ReportSetting
                WHERE   SeenClientId = @SeenClientId;
  
                IF NOT EXISTS ( SELECT  *
                                FROM    ReportSetting
                                WHERE   SeenClientId = @SeenClientId
                                        AND ReportType = 'SnapShot' )
                    BEGIN
                        INSERT  INTO dbo.ReportSetting
                                ( SeenClientId ,
                                  MinRank ,
                                  MaxRank ,
                                  QuestionId ,
                                  DisplayType ,
                                  IsNPS ,
                                  ReportType
                                )
                        VALUES  ( @SeenClientId , -- SeenClientId - bigint
                                  @MinRank , -- MinRank - int
                                  @MaxRank , -- MaxRank - int
                                  ISNULL(@QuestionId, '') , -- QuestionId - nvarchar(max)
                                  @DisplayType , -- DisplayType - int
                                  @IsNPS , -- IsNPS - bit
                                  'SnapShot'  -- ReportType - varchar(50)
                                );	
                    END;
                IF NOT EXISTS ( SELECT  *
                                FROM    ReportSetting
                                WHERE   SeenClientId = @SeenClientId
                                        AND ReportType = 'Analysis' )
                    BEGIN
                        INSERT  INTO dbo.ReportSetting
                                ( SeenClientId ,
                                  MinRank ,
                                  MaxRank ,
                                  QuestionId ,
                                  DisplayType ,
                                  IsNPS ,
                                  ReportType
                                )
                        VALUES  ( @SeenClientId , -- SeenClientId - bigint
                                  @MinRank , -- MinRank - int
                                  @MaxRank , -- MaxRank - int
                                  ISNULL(@QuestionId, '') , -- QuestionId - nvarchar(max)
                                  @DisplayType , -- DisplayType - int
                                  @IsNPS , -- IsNPS - bit
                                  'Analysis'  -- ReportType - varchar(50)
                                );
                    END;
                UPDATE  dbo.SeenClient
                SET     LastLoadedDate = DATEADD(MINUTE, 120, GETUTCDATE())
                WHERE   Id = @SeenClientId;
            END;	
        RETURN 1;
    END;