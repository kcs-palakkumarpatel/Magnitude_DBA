


create view PB_VW_Fact_AustroDailyPlanCaptured as
Select 

A.EstablishmentName,A.CapturedDate,A.ReferenceNo,
A.IsPositive,A.Status,A.PI,
A.UserId,A.UserName,A.ResolvedDate,
A.Longitude,A.Latitude,A.RepeatCount,
B.[Name],
B.[Mobile],
B.[Email ],
B.[Company ],
A.[Client Company],
A.[Name of person you],
A.[Position],
A.[Type of visit: ],
A.[Type of industry:], 
A.[Company Spend ],
A.[Contingency Commen],
A.[General Comment ],
B.[Requires Help],
B.[If yes, outline wh],
A.[Region],
A.[NonClient Company],
A.[NonClient Comment],
A.[Client Time Planned],
A.[Client Type of Task],
A.[NonClient Time Planned],
B.[Clients today],
A.[NonClient Task Type],
B.[Client Facing Time],
B.[Non-Client Time],
A.[Client Other Task Type],
A.[Non Client Other Task Type]
From (
	Select * 
	from AustroDailyPlanCaptured
	where repeatcount <> 0
) A
inner Join (
	Select * 
	from AustroDailyPlanCaptured
	where repeatcount = 0
) B On A.referenceno=B.referenceno
