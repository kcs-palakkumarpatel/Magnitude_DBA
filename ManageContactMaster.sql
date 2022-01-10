-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,19 Jun 2015>
-- Description:	<Description,bhavik patel,>
-- Call SP:		ManageContactMasterContactMaster
-- =============================================
--drop procedure [ManageContactMaster]
CREATE PROCEDURE [dbo].[ManageContactMaster]
(
   @SaveContactMasterTableType SaveContactMasterTableType Readonly,
   @SaveContactMasterAnswerTableType SaveContactMasterAnswerTableType Readonly
)
AS 
BEGIN
	DECLARE @ContactRowCount int = 0,@TotalRowCount int  = 0,@AnswerRowCount int =0,@TotalAnswerRowCount int = 0;
	IF OBJECT_ID('tempdb..#SaveContactMasterTable','U') IS NOT NULL
	DROP TABLE #SaveContactMasterTable
	create table #SaveContactMasterTable 
	(

			RowNumber int NULL,
			PkContactMasterId int null,
			ContactFormId bigint NULL,
			ContactGroupId bigint NULL,
			FormData nvarchar(MAX) NULL,
			FormDetailsData nvarchar(MAX) NULL,
			ExistingContactId nvarchar(MAX) NULL,
			ListExistingContactId nvarchar(MAX) NULL,
			ExistingContactIdList nvarchar(MAX) NULL,
			DeletedData nvarchar(MAX) NULL,
			GroupId  bigint NULL,
			ContactMasterId  bigint NULL,
			AppUserId  bigint NULL,
			ForceUpdate  bit NULL,
			SeenClientId   bigint NULL,
			HasContactGroup  bit NULL,
			ActivityId bigint NULL,
			PageMasterContact int null
			
	);

	IF OBJECT_ID('tempdb..#SaveAnswerTable','U') IS NOT NULL
	DROP TABLE #SaveAnswerTable
	create table #SaveAnswerTable 
	(
			RowNumber int NULL,
			lgContactMasterId bigint NULL,
			QuestionId bigint NULL,
			QuestionTypeId bigint NULL,
			Detail nvarchar(MAX) NULL,
			UserId int NULL,
			Contact int NULL,
			FKContactMasterId int NULL
	);
	

	IF OBJECT_ID('tempdb..#lgContactMasterIdTable','U') IS NOT NULL
	DROP TABLE #lgContactMasterIdTable
	create table #lgContactMasterIdTable
	(
		lgContactMasterId nvarchar(max)
	);

	declare @lgContactMasterIdComma nvarchar(max)
	
	insert into #SaveContactMasterTable
	select * from @SaveContactMasterTableType

	insert into #SaveAnswerTable
	select * from @SaveContactMasterAnswerTableType

	Declare @CurrentContactId BIGINT = 0;
	Declare @CurrentPkContactId BIGINT =0;
	Declare @Id BIGINT =0;
    Declare @ContactId BIGINT;
    Declare @GroupId BIGINT;
    Declare @AppUserId BIGINT; 
	Declare @PageId BIGINT = 0;


	declare @ContactMasterId BIGINT;
    declare @ContactQuestionId BIGINT;
    declare @QuestionTypeId BIGINT;
    declare @Detail NVARCHAR(MAX);
    declare @AnswerAppUserId BIGINT;
    declare @AnswerPageId BIGINT = 0;

	set @TotalRowCount = (select COUNT(*) from #SaveContactMasterTable)

	set @ContactRowCount = 1;
	WHILE @ContactRowCount <= @TotalRowCount
	BEGIN
		
			set @Id =  (select ContactMasterId from #SaveContactMasterTable where RowNumber = @ContactRowCount)
			set @ContactId =  (select ContactFormId from #SaveContactMasterTable where RowNumber = @ContactRowCount)
			set @GroupId =  (select GroupId from #SaveContactMasterTable where RowNumber = @ContactRowCount)
			set @AppUserId =  (select AppUserId from #SaveContactMasterTable where RowNumber = @ContactRowCount)
			set @PageId =  (select PageMasterContact from #SaveContactMasterTable where RowNumber = @ContactRowCount)
			set @CurrentPkContactId = (select PkContactMasterId from #SaveContactMasterTable where RowNumber = @ContactRowCount)
			--exec @CurrentContactId = InsertOrUpdateContactMaster @Id,@ContactId,@GroupId,@AppUserId,@PageId

			exec InsertOrUpdateContactMaster_With_outputparam @Id,@ContactId,@GroupId,@AppUserId,@PageId, @CurrentContactId OUTPUT

			IF @CurrentContactId > 0
			BEGIN
				set @AnswerRowCount = 1;
				set @TotalAnswerRowCount = (select count(*) from #SaveAnswerTable where FKContactMasterId = @CurrentPkContactId )
				WHILE @AnswerRowCount <= @TotalAnswerRowCount
				BEGIN
				
					set @ContactMasterId =  @CurrentContactId --(select ContactMasterId from #SaveContactMasterTable where RowNumber = @ContactRowCount)
					set @ContactQuestionId =  (select QuestionId from #SaveAnswerTable where FKContactMasterId = @CurrentPkContactId and RowNumber = @AnswerRowCount)
					set @QuestionTypeId =  (select QuestionTypeId from #SaveAnswerTable where FKContactMasterId = @CurrentPkContactId and  RowNumber = @AnswerRowCount)
					set @Detail =  (select Detail from #SaveAnswerTable where FKContactMasterId = @CurrentPkContactId and  RowNumber = @AnswerRowCount)
					set @AnswerAppUserId =  (select UserId from #SaveAnswerTable where FKContactMasterId = @CurrentPkContactId and  RowNumber = @AnswerRowCount)
					set @AnswerPageId = (select Contact from #SaveAnswerTable where FKContactMasterId = @CurrentPkContactId and  RowNumber = @AnswerRowCount)

					exec InsertOrUpdateContactDetails_With_outputparam @ContactMasterId,@ContactQuestionId,@QuestionTypeId,@Detail,@AnswerAppUserId,@AnswerPageId

					set @AnswerRowCount = @AnswerRowCount + 1;
					CONTINUE
				END
			END

		insert into #lgContactMasterIdTable (lgContactMasterId) values (@CurrentContactId)
		set @ContactRowCount = @ContactRowCount + 1
		CONTINUE			
	END
	

	declare @strCommasId nvarchar(max)
		set @strCommasId = (SELECT  STUFF((SELECT  ',' + lgContactMasterId
							FROM #lgContactMasterIdTable E
							FOR XML PATH('')), 1, 1, '') AS listStr)
	select @strCommasId as ReturnValue

	--select lgContactMasterId from #lgContactMasterIdTable
END