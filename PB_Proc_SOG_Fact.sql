

CREATE Procedure [dbo].[PB_Proc_SOG_Fact]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'SOG_Fact_Branding','SOG_Fact_Branding Start','SOG'

	Truncate table dbo.SOG_Fact_Branding

	
	Insert into SOG_Fact_Branding(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Client/Site Name],
[Suburb],[Size of Board],[Board Type],[Number of Boards],ResponseDate,[Allocated To],Completed)
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Client/Site Name],
[Suburb],[Size of Board],[Board Type],[Number of Boards],ResponseDate,[Allocated To],Completed
	 from [PB_VW_SOG_Fact_Branding]

	Select @Desc = 'SOG_Fact_Branding Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_Branding(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_Branding',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_ClientFeedback','SOG_Fact_ClientFeedback Start','SOG'

	Truncate table dbo.SOG_Fact_ClientFeedback

	
	Insert into SOG_Fact_ClientFeedback(EstablishmentName, Captureddate,ReferenceNo,IsPositive,Status,PI,[Query Type])
	select EstablishmentName, Captureddate,ReferenceNo,IsPositive,Status,PI,[Query Type]
	 from [PB_VW_SOG_Fact_ClientFeedback]

	Select @Desc = 'SOG_Fact_ClientFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_ClientFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_ClientFeedback',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_ControlHandover','SOG_Fact_ControlHandover Start','SOG'

	Truncate table dbo.SOG_Fact_ControlHandover

	
	Insert into SOG_Fact_ControlHandover(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Dogs Fed],[Dogs Water],[Kitchen Clean],[Toilet Clean],[Control Room Neat ],[Off-Site CCTV ],
[Tracking On-Line],[New Market CCTV On],[SOP File On Desk],[FTT Handed Over],[Acknowledge Tech ],
[Issues Logged],[All Guarding Issue],[Alarms Cleared],ResponseDate,[Issue Resolved])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Dogs Fed],[Dogs Water],[Kitchen Clean],[Toilet Clean],[Control Room Neat ],[Off-Site CCTV ],
[Tracking On-Line],[New Market CCTV On],[SOP File On Desk],[FTT Handed Over],[Acknowledge Tech ],
[Issues Logged],[All Guarding Issue],[Alarms Cleared],ResponseDate,[Issue Resolved]
	 from [PB_VW_SOG_Fact_ControlHandover]

	Select @Desc = 'SOG_Fact_ControlHandover Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_ControlHandover(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_ControlHandover',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_DamageReport','SOG_Fact_DamageReport Start','SOG'

	Truncate table dbo.SOG_Fact_DamageReport

	
	Insert into SOG_Fact_DamageReport(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Equipment Type],[Site Name],[Make & Model],[Serial Number],[Asset No],[Damage Reported By],
[Date & Time Report],[Date & Time ],[How Did Damage Occ],[Description],[How Can This Be Pr],ResponseDate,
[Repair | Replace],[Sent To Supplier],[Equipment Replaced],[Name of Supplier],[Estimated Cost R],
[Loss/Damage Billed],[Who Is Responsible])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Equipment Type],[Site Name],[Make & Model],[Serial Number],[Asset No],[Damage Reported By],
[Date & Time Report],[Date & Time ],[How Did Damage Occ],[Description],[How Can This Be Pr],ResponseDate,
[Repair | Replace],[Sent To Supplier],[Equipment Replaced],[Name of Supplier],[Estimated Cost R],
[Loss/Damage Billed],[Who Is Responsible]
	 from [PB_VW_SOG_Fact_DamageReport]

	Select @Desc = 'SOG_Fact_DamageReport Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_DamageReport(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_DamageReport',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_IncidentReport','SOG_Fact_IncidentReport Start','SOG'

	Truncate table dbo.SOG_Fact_IncidentReport

	
	Insert into SOG_Fact_IncidentReport(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Site Name],
[Site Address],[Date & Time ],[Type],[Summary],[Value (ZAR)],[Victim Name],[Victim Cell],[Witness 1 Name],[Witness 1 Cell],
[Witness 2 Name],[Witness 2 Cell],[SAPS Vehicle],[SAPS Member],[SAPS Station],[CAS Number],[SOG Officer],
[If Yes - Who ],[Firearm Discharged],[Firearm Make & Mod],[Serial No],[Firearm Serial Num],[Number of Rounds],
[Report],[Corrective Action ],[Action Required By],ResponseDate,[SOG Corrective Act],[Client Corrective ],
[Security Upgrades ])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Site Name],
[Site Address],[Date & Time ],[Type],[Summary],[Value (ZAR)],[Victim Name],[Victim Cell],[Witness 1 Name],[Witness 1 Cell],
[Witness 2 Name],[Witness 2 Cell],[SAPS Vehicle],[SAPS Member],[SAPS Station],[CAS Number],[SOG Officer],
[If Yes - Who ],[Firearm Discharged],[Firearm Make & Mod],[Serial No],[Firearm Serial Num],[Number of Rounds],
[Report],[Corrective Action ],[Action Required By],ResponseDate,[SOG Corrective Act],[Client Corrective ],
[Security Upgrades ]
	 from [PB_VW_SOG_Fact_IncidentReport]

	Select @Desc = 'SOG_Fact_IncidentReport Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_IncidentReport(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_IncidentReport',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_GuardPosting','SOG_Fact_GuardPosting Start','SOG'

	Truncate table dbo.SOG_Fact_GuardPosting

	
	Insert into SOG_Fact_GuardPosting(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Site Name],[Site Address],[Site Contact Name],[Site Contact Cell ],[Site Contact Posit],[Requested Via],
[Prices Quoted],[Comments],[Payment],[If Other - Please ],[Shifts Day],[Shifts Night],[Start Date],
[Guard Booked Name],[Guard Co No],[Guard Booked Name2],[Guard Co No2],[Easyroster],ResponseDate,
[Client Invoiced],[Invoice No],[Invoice Amount],[Reason],[Additional Comment])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Site Name],[Site Address],[Site Contact Name],[Site Contact Cell ],[Site Contact Posit],[Requested Via],
[Prices Quoted],[Comments],[Payment],[If Other - Please ],[Shifts Day],[Shifts Night],[Start Date],
[Guard Booked Name],[Guard Co No],[Guard Booked Name2],[Guard Co No2],[Easyroster],ResponseDate,
[Client Invoiced],[Invoice No],[Invoice Amount],[Reason],[Additional Comment]
	 from [PB_VW_SOG_Fact_GuardPosting]

	Select @Desc = 'SOG_Fact_GuardPosting Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_GuardPosting(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_GuardPosting',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_JobManager','SOG_Fact_JobManager Start','SOG'

	Truncate table dbo.SOG_Fact_JobManager

	
	Insert into SOG_Fact_JobManager(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Task Title],[Description],[Deadline],[Comments ],ResolvedDate,ResponseDate,ResponseTaskTitle,
[Task Status], ResponseComments,[Deadline Met],[If No - When Will ])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Task Title],[Description],[Deadline],[Comments ],ResolvedDate,ResponseDate,ResponseTaskTitle,
[Task Status], ResponseComments,[Deadline Met],[If No - When Will ]
	 from [PB_VW_SOG_Fact_JobManager]

	Select @Desc = 'SOG_Fact_JobManager Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_JobManager(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_JobManager',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_LeaveRequest','SOG_Fact_LeaveRequest Start','SOG'

	Truncate table dbo.SOG_Fact_LeaveRequest

	
	Insert into SOG_Fact_LeaveRequest(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,[Leave FROM] , [Leave TO],[Total Days],[Take Over],[Additional Comment],ResponseReference,
[Total Leave Days],[Replacement],[Leave Approved],ResponseComments)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,[Leave FROM] , [Leave TO],[Total Days],[Take Over],[Additional Comment],ResponseReference,
[Total Leave Days],[Replacement],[Leave Approved],ResponseComments
	 from [PB_VW_SOG_Fact_LeaveRequest]

	Select @Desc = 'SOG_Fact_LeaveRequest Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_LeaveRequest(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_LeaveRequest',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_CCTVCheck','SOG_Fact_CCTVCheck Start','SOG'

	Truncate table dbo.SOG_Fact_CCTVCheck

	
	Insert into SOG_Fact_CCTVCheck(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[All Cameras Online],[PTZ Wimpy OK],[PTZ Gate 2 OK],[PTZ Builders OK],[Camera Comments],
[Workstation 1 OK],[Workstation 2 OK],[Server 1 OK],[Server 2 OK],[Server 3 OK],[IT/Software],
ResolvedDate,ResponseDate,Satisfied)
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[All Cameras Online],[PTZ Wimpy OK],[PTZ Gate 2 OK],[PTZ Builders OK],[Camera Comments],
[Workstation 1 OK],[Workstation 2 OK],[Server 1 OK],[Server 2 OK],[Server 3 OK],[IT/Software],
ResolvedDate,ResponseDate,Satisfied
	 from [PB_VW_SOG_Fact_CCTVCheck]

	Select @Desc = 'SOG_Fact_CCTVCheck Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_CCTVCheck(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_CCTVCheck',@Desc,'SOG'
-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_LightsAndSignage','SOG_Fact_LightsAndSignage Start','SOG'

	Truncate table dbo.SOG_Fact_LightsAndSignage

	
	Insert into SOG_Fact_LightsAndSignage(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
	[Sector A - Lights],[Sector A - Sign],[Sector A Comments],[Sector B - Lights],[Sector B - All Sig],[Sector B Comments],
[Sector C - Lights],[Sector C - Sign],[Sector C Comments],[Sector D - Lights],[Sector D - Sign],[Sector D Comments],[Sector E - Lights],
[Sector E - All Sig],[Sector E Comments],[Sector F - All Lig],[Sector F - All Sig],[Sector F Comments],[Sector G - Lights],
[Sector G - Sign],[Sector G Comments],[General Site Comme],ResolvedDate,ResponseDate,Agrees,[Will Take Care])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
	[Sector A - Lights],[Sector A - Sign],[Sector A Comments],[Sector B - Lights],[Sector B - All Sig],[Sector B Comments],
[Sector C - Lights],[Sector C - Sign],[Sector C Comments],[Sector D - Lights],[Sector D - Sign],[Sector D Comments],[Sector E - Lights],
[Sector E - All Sig],[Sector E Comments],[Sector F - All Lig],[Sector F - All Sig],[Sector F Comments],[Sector G - Lights],
[Sector G - Sign],[Sector G Comments],[General Site Comme],ResolvedDate,ResponseDate,Agrees,[Will Take Care]
	 from [PB_VW_SOG_Fact_LightsAndSignage]

	Select @Desc = 'SOG_Fact_LightsAndSignage Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_LightsAndSignage(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_LightsAndSignage',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_WeeklyCheck','SOG_Fact_WeeklyCheck Start','SOG'

	Truncate table dbo.SOG_Fact_WeeklyCheck

	
	Insert into SOG_Fact_WeeklyCheck(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Sprinkler Jockey],
[Sprinkler Pump],[Diesel level OK],[Fire Panel 1 OK],[Fire Panel 2 OK],[Fire Panel 3 OK],[Electric Fence OK],
[Fire Equipment],[Fire Equipment Out],[F.E Service >30],[Comment],[Panic System Test],[Change Rooms Neat],
[Fire Passages],[Fire Doors In Tact],[Additional Comment],ResolvedDate,ResponseDate,Satisfied)
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Sprinkler Jockey],
[Sprinkler Pump],[Diesel level OK],[Fire Panel 1 OK],[Fire Panel 2 OK],[Fire Panel 3 OK],[Electric Fence OK],
[Fire Equipment],[Fire Equipment Out],[F.E Service >30],[Comment],[Panic System Test],[Change Rooms Neat],
[Fire Passages],[Fire Doors In Tact],[Additional Comment],ResolvedDate,ResponseDate,Satisfied
	 from [PB_VW_SOG_Fact_WeeklyCheck]

	Select @Desc = 'SOG_Fact_WeeklyCheck Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_WeeklyCheck(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_WeeklyCheck',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_SiteInspection','SOG_Fact_SiteInspection Start','SOG'

	Truncate table dbo.SOG_Fact_SiteInspection

	
	Insert into SOG_Fact_SiteInspection(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Site Name],
[Radio],[Radio Serial No],[Torch],[Torch Serial No],[Patrol Baton],[Patrol Baton Serial No],
[CCTV System],[Panic Pack],[SOG Locker],[Set Of Keys],[OB Present],[Access Register],[AC Supply Good],
[Guard Room Neat],[SOG Board],[Additional Comment],ResolvedDate,ResponseDate,[Issues],[Resolved],
[How was it resolve],[What is your plan],[Comments])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Site Name],
[Radio],[Radio Serial No],[Torch],[Torch Serial No],[Patrol Baton],[Patrol Baton Serial No],
[CCTV System],[Panic Pack],[SOG Locker],[Set Of Keys],[OB Present],[Access Register],[AC Supply Good],
[Guard Room Neat],[SOG Board],[Additional Comment],ResolvedDate,ResponseDate,[Issues],[Resolved],
[How was it resolve],[What is your plan],[Comments]
	 from [PB_VW_SOG_Fact_SiteInspection]

	Select @Desc = 'SOG_Fact_SiteInspection Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_SiteInspection(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_SiteInspection',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_SuspiciousPerson','SOG_Fact_SuspiciousPerson Start','SOG'

	Truncate table dbo.SOG_Fact_SuspiciousPerson

	
	Insert into SOG_Fact_SuspiciousPerson(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Site Name],[Site Address],[Name of Suspect],[Surname of Suspect],[ID No/DOB],[Reason],
[Accomplice Name],[Banning Order],[Time Period],[Incident Reported],[Charges Laid],[Charges],[SAPS Station],
[SAPS CAS No],ResolvedDate,ResponseDate,[Action Required],[Action Taken],[Client Informed],[Additional Comment])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Site Name],[Site Address],[Name of Suspect],[Surname of Suspect],[ID No/DOB],[Reason],
[Accomplice Name],[Banning Order],[Time Period],[Incident Reported],[Charges Laid],[Charges],[SAPS Station],
[SAPS CAS No],ResolvedDate,ResponseDate,[Action Required],[Action Taken],[Client Informed],[Additional Comment]
	 from [PB_VW_SOG_Fact_SuspiciousPerson]

	Select @Desc = 'SOG_Fact_SuspiciousPerson Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_SuspiciousPerson(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_SuspiciousPerson',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_SystemCheck','SOG_Fact_SystemCheck Start','SOG'

	Truncate table dbo.SOG_Fact_SystemCheck

	
	Insert into SOG_Fact_SystemCheck(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Pre-Paid],
[Unit Reading],[Generator Test Run],[Generator Full],[Generator Power],[Two Jerry Cans],[UPS Input Voltage ],
[UPS Output Voltage],[UPS Input Frequenc],[Inverter Input Vol],[Inverter Output ],[Inverter Input ],[Inverter Output Freq],
[Inverter Battery],[Battery Bank Clear],[All Batteries Cool],[Batteries In Good],[Comments],
ResolvedDate,ResponseDate,[Happy],[Additional Comment])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Pre-Paid],
[Unit Reading],[Generator Test Run],[Generator Full],[Generator Power],[Two Jerry Cans],[UPS Input Voltage ],
[UPS Output Voltage],[UPS Input Frequenc],[Inverter Input Vol],[Inverter Output ],[Inverter Input ],[Inverter Output Freq],
[Inverter Battery],[Battery Bank Clear],[All Batteries Cool],[Batteries In Good],[Comments],
ResolvedDate,ResponseDate,[Happy],[Additional Comment]
	 from [PB_VW_SOG_Fact_SystemCheck]

	Select @Desc = 'SOG_Fact_SystemCheck Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_SystemCheck(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_SystemCheck',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_TechnicalCommissioning','SOG_Fact_TechnicalCommissioning Start','SOG'

	Truncate table dbo.SOG_Fact_TechnicalCommissioning

	
	Insert into SOG_Fact_TechnicalCommissioning(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
RepeatCount,[Client Name],[Client Cell],[Client Address],[Equipment Type],[Panel Make & Model],
[Radio Make & Type],[Radio Code],[SOG Warning Boards],[Equipment],[Comments],[Zone #],[Description],
[Tested & Ok],[Signal to Control],[Installation Bylaw],ResolvedDate,ResponseDate,[Satisfied],ResponseComments)
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
RepeatCount,[Client Name],[Client Cell],[Client Address],[Equipment Type],[Panel Make & Model],
[Radio Make & Type],[Radio Code],[SOG Warning Boards],[Equipment],[Comments],[Zone #],[Description],
[Tested & Ok],[Signal to Control],[Installation Bylaw],ResolvedDate,ResponseDate,[Satisfied],ResponseComments
	 from [PB_VW_SOG_Fact_TechnicalCommissioning]

	Select @Desc = 'SOG_Fact_TechnicalCommissioning Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_TechnicalCommissioning(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_TechnicalCommissioning',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_TrainingTracker','SOG_Fact_TrainingTracker Start','SOG'

	Truncate table dbo.SOG_Fact_TrainingTracker

	
	Insert into SOG_Fact_TrainingTracker(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Employee Name & Su],[Co No],[Training Venue],[Training Activity],[Unit Standard No],
[Firearm Type],[Target Size],[Score],[Training Result],ResolvedDate,ResponseDate,[Corrective Action ],[Deadline])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
[Employee Name & Su],[Co No],[Training Venue],[Training Activity],[Unit Standard No],
[Firearm Type],[Target Size],[Score],[Training Result],ResolvedDate,ResponseDate,[Corrective Action ],[Deadline]
	 from [PB_VW_SOG_Fact_TrainingTracker]

	Select @Desc = 'SOG_Fact_TrainingTracker Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_TrainingTracker(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_TrainingTracker',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_UniformRequest','SOG_Fact_UniformRequest Start','SOG'

	Truncate table dbo.SOG_Fact_UniformRequest

	
	Insert into SOG_Fact_UniformRequest(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
RepeatCount,[Co No],[Name & Surname],[Item],[Size],[Comments],ResolvedDate,ResponseDate,
[In Stock | Ordered],[Uniform Issued],[Submitted Payroll], ResponseComments)
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,
RepeatCount,[Co No],[Name & Surname],[Item],[Size],[Comments],ResolvedDate,ResponseDate,
[In Stock | Ordered],[Uniform Issued],[Submitted Payroll], ResponseComments
	 from [PB_VW_SOG_Fact_UniformRequest]

	Select @Desc = 'SOG_Fact_UniformRequest Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_UniformRequest(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_UniformRequest',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_VehicleHandover','SOG_Fact_VehicleHandover Start','SOG'

	Truncate table dbo.SOG_Fact_VehicleHandover

	
	Insert into SOG_Fact_VehicleHandover(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Vehicle],
[Odometer (KM)],[GPS Present],[OnBoard Camera],[FLIR Present],[Hand Radio],[Two-Way Radio],
[Aura Device ],[Aura Logged In],[Existing Issues],[Vehicle Clean],[Vehicle Roadworthy],[Comment],
ResolvedDate,ResponseDate,[Report Accepted],[Comments],[Responsibility],ResponseComment)
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Vehicle],
[Odometer (KM)],[GPS Present],[OnBoard Camera],[FLIR Present],[Hand Radio],[Two-Way Radio],
[Aura Device ],[Aura Logged In],[Existing Issues],[Vehicle Clean],[Vehicle Roadworthy],[Comment],
ResolvedDate,ResponseDate,[Report Accepted],[Comments],[Responsibility],ResponseComment
	 from [PB_VW_SOG_Fact_VehicleHandover]

	Select @Desc = 'SOG_Fact_VehicleHandover Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_VehicleHandover(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_VehicleHandover',@Desc,'SOG'
	-------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'SOG_Fact_VehicleMaintenance','SOG_Fact_VehicleMaintenance Start','SOG'

	Truncate table dbo.SOG_Fact_VehicleMaintenance

	
	Insert into SOG_Fact_VehicleMaintenance(EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Vehicle],
[Odometer (KM)],[Type],[Source],[Pump Start Reading],[Pump End Reading],[Litres (ℓ)],[Price (ZAR)],
ResolvedDate,ResponseDate,[Issue Type],[Description])
	select EstablishmentName,CapturedDate,Status,ReferenceNo,UserName,[Vehicle],
[Odometer (KM)],[Type],[Source],[Pump Start Reading],[Pump End Reading],[Litres (ℓ)],[Price (ZAR)],
ResolvedDate,ResponseDate,[Issue Type],[Description]
	 from [PB_VW_SOG_Fact_VehicleMaintenance]

	Select @Desc = 'SOG_Fact_VehicleMaintenance Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.SOG_Fact_VehicleMaintenance(NoLock) 
	Exec dbo.PB_Log_Insert 'SOG_Fact_VehicleMaintenance',@Desc,'SOG'
	Set NoCount OFF;
END
