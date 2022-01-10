CREATE Procedure [dbo].[PB_Proc_BsiSteel_Fact_StaffTemperature]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'BsiSteel_Fact_StaffTemperature','BsiSteel_Fact_StaffTemperature Start','Bsi Steel'

	Truncate table dbo.BsiSteel_Fact_StaffTemperature

	
	Insert INTO BsiSteel_Fact_StaffTemperature(EstablishmentName,[ReferenceNo],Latitude,Longitude,[Form Status],
[Captured Date],ResponsibleUser,[UserName],[Name],[Surname],
[Mobile],[Email],[Temperature],[Fever],Activity)
	select EstablishmentName,[ReferenceNo],Latitude,Longitude,[Form Status],
[Captured Date],ResponsibleUser,[UserName],[Name],[Surname],
[Mobile],[Email],[Temperature],[Fever],Activity

	 from [PB_VW_BsiSteel_Fact_StaffTemperature]

	Select @Desc = 'BsiSteel_Fact_StaffTemperature Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.BsiSteel_Fact_StaffTemperature(NoLock) 
	Exec dbo.PB_Log_Insert 'BsiSteel_Fact_StaffTemperature',@Desc,'Bsi Steel'

	Set NoCount OFF;
END
