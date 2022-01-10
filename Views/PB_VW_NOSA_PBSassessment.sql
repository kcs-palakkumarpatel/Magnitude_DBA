﻿CREATE VIEW PB_VW_NOSA_PBSassessment AS

SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,p.PI,--p.CustomerName,
[Customer],[Drivers name and surname],[Drivers Identity Number],[PDP Expiry Date],[License Expiry Date],[Make],[Model/Trailer],[Engine Type],[Gearbox make],[Gearbox speed],[Mesh Type],[Configuration],[Truck Registration Number],[Trailer Number 1],[Trailer Number 2],[Trailer Number 3],[Town/City/Suburb],[1.1 Valid PrDP],[1.1 Comments],[1.2 SAB License],[1.2 Comments],[1.3 SAB Permits and Certificates],[1.3 Comments],[2.1 Body work, bonnet, grill and bumper],[2.1 Comments],[2.2 RTMS Diamond],[2.2 Comments],[2.3 Windscreen wipers],[2.3 Comments],[2.4 Lenses and reflectors are intact],[2.4 Comments],[2.5 Abnormal vehicle strobe light is in place],[2.5 Comments],[2.6 Abnormal sticker is in place and in tact],[2.6 Comments],[2.7 Front number plate],[2.7 Comments],[2.8 License, permits & certificates of fitness as per PBS compliance],[2.8 Comments],[2.9 Side mirrors],[2.9 Comments],[2.10 Doors and windows],[2.10 Comments],[2.11 Wheels & tyres, dust caps, wheel nuts],[2.11 Comments],[2.12 Virgin castings on each wheel],[2.12 Comments],[2.13 All wheels are same make and model],[2.13 Comments],[2.14 4 torque indicators are in place],[2.14 Comments],[2.15 Matching tyres at each axle],[2.15 Comments],[2.16 Inner and outer valve extensions],[2.16 Comments],[2.17 Steel valve caps],[2.17 Comments],[2.18 Batteries and holders],[2.18 Comments],[2.19 Air tanks],[2.19 Comments],[2.20 Spare wheel],[2.20 Comments],[2.21 Rear Chevron, number plate],[2.21 Comments],[2.22 Rear lenses and reflectors],[2.22 Comments],[2.23 Fuel tank and fuel cap],[2.23 Comments],[3.1 Body work in order],[3.1 Comments],[3.2 License discs and number plates all according to PBS permits],[3.2 Comments],[3.3 Information plates all in order according to PBS permits],[3.3 Comments],[3.4 Couplings and service lines – Electrical Suzie all in place],[3.4 Comments],[3.5 ABS braking system connections],[3.5 Comments],[3.6 Lights],[3.6 Comments],[3.7 Front and rear reflectors including front green and rear marker lights],[3.7 Comments],[3.8 Yellow reflective tape],[3.8 Comments],[3.9 Side Underruns],[3.9 Comments],[3.10 Fifth wheel],[3.10 Comments],[3.11 Towbar and pins],[3.11 Comments],[3.12 Rear Chevron],[3.12 Comments],[3.13 Two fit for purpose trolley brackets],[3.13 Comments],[3.14 Wheels and tyres],[3.14 Comments],[3.15 Ratchets operating correctly],[3.15 Comments],[3.16 Tarps in good condition and free from decals],[3.16 Comments],[3.17 Governing 80km/h sticker on the rear of the trailer],[3.17 Comments],[4.1 Parking brake must be applied],[4.1 Comments],[4.2 Gear lever (or selector)],[4.2 Comments],[4.3 Driver’s cab clean and neat and free from loose objects],[4.3 Comments],[4.4 Emergency triangles (1 set per vehicle)],[4.4 Comments],[4.5 Fire extinguisher – serviced and in date],[4.5 Comments],[4.6 Oasis printer – handheld operating correctly and has good battery life],[4.6 Comments],[4.7 Seat correctly positioned],[4.7 Comments],[4.8 Steering free of excessive play],[4.8 Comments],[4.9 Mirrors],[4.9 Comments],[4.10 Ignition in “ON” position – check instruments],[4.10 Comments],[4.11 Start engine – Instruments/gauges all in working order],[4.11 Comments],[4.12 Sufficient fuel for trip],[4.12 Comments],[4.13 Head and brake lights, indicators, hooter, wiper all in good working order],[4.13 Comments],[4.14 Hand and footbrakes free of airleaks],[4.14 Comments],[4.15 Brake and clutch pedals in working order],[4.15 Comments],[4.16 Doors fully operational],[4.16 Comments],[ASSESSOR ADVICE AND FEEDBACK ON VEHICLE PRE-TRIP INSPECTIONS:],[5.1 Place the gear shift lever into the neutral position],[5.2 Check around the vehicle to see if it was safe to start],[5.3 Pre-heat the engine (if applicable)],[5.4 Crank the starter motor for less than 30 seconds],[5.5 Allow starter to cool before trying again (if applicable)],[5.6 Allow engine to warm up without revving the engine],[5.7 Allow the brake air pressure to build up gradually],[5.8 Check all the gauges and instruments for functionality],[ASSESSOR ADVICE AND FEEDBACK ON VEHICLE START UP PROCEDURES],[6.1 Mounting and Dismounting],[6.2 Vehicle Sympathy],[6.3 Observations],[6.4 Use of Controls],[6.5 Clutch Control],[6.6 System of vehicle control knowledge],[6.7 Uncontrolled Dangerous Actions],[7.1 Rough Handling],[7.2 Alignment of truck],[7.3 Handbrake applied],[7.4 Gearlever neutral],[7.5 Observations],[7.6 Use of indicators],[7.7 Correct gear selection],[7.8 Clutch control],[7.9 Mirror/Blind spot while cornering],[7.10 Progress trailers],[7.11 Squares Corner],[7.12 Touch road markings],[7.13 Number of attempts],[7.14 Rolls/coasts],[8.1 Rough Handling],[8.2 Alignment of truck],[8.3 Handbrake applied],[8.4 Gearlever neutral],[8.5 Observations],[8.6 Use of indicators],[8.7 Correct gear selection],[8.8 Clutch control],[8.9 Mirror/Blind spot while cornering],[8.10 Progress trailers],[8.11 Squares Corner],[8.12 Touch road markings],[8.13 Number of attempts],[8.14 Rolls/coasts],[ASSESSOR ADVICE AND FEEDBACK ON YARD TEST:],[1.1 Changes excessively],[1.2 Grates gears],[1.3 Slips gears],[1.4 Hand rests on top of gear lever],[1.5 Eyes on gears],[1.6 Fails to change up / down],[1.7 Select neutral while driving],[2.1 Slips clutch],[2.2 Rides clutch],[2.3 De-clutch too early],[2.4 Keeps clutch depressed while stopped],[2.5 Selects neutral too early],[3.1 Planning ahead],[3.2 Mirror / Blind Spot],[3.3 Brakes too early],[3.4 Brakes too late],[3.5 Brakes not smooth],[3.6 No clear space in front],[3.7 Handbrake not properly utilised],[3.8 Brake used unnecessarily],[3.9 Incorrect negotiation of the decline],[4.1 Wanders],[4.2 Positioning/seating],[5.1 Planning ahead],[5.2 Does not maintain constant speed],[5.3 Too fast],[5.4 Too slow],[5.5 Greenband driving],[6.1 Not according to specification],[6.2 Not used when required],[7.1 Not vehicle friendly/too hard],[7.2 Mounts the kerb],[7.3 Bump objects],[8.1 Alley docking from right],[8.2 Reversing in a straight line],[1.1 Observations/left and right],[1.2 Wrong gear],[1.3 Stalls],[1.4 Waits too long],[2.1 Planning ahead],[2.2 Mirror],[2.3 Blind spots],[2.4 Rolling back],[2.5 Indicators],[2.6 Indicator not cancelled],[2.7 Fails to check trailer],[2.8 Position for turn/wheels straight],[2.9 Brake while cornering],[2.10 Too fast],[2.11 Cuts corners],[2.12 Too wide],[2.13 Changing gears on corners],[3.1 Ignore change in road surface and conditions],[3.2 Ignores actions of other road users],[3.3 Ignores weather conditions],[3.4 No observations],[3.5 Use of mirrors],[3.6 Ignores road signs / markings],[3.7 Moves into blind spots of other drivers],[4.1 Travels Too close to crown of road],[4.2 Fails to maintain following distance],[4.3 Straddling],[5.1 Fails to notice hazards],[5.2 Fails to react to hazards],[5.3 Incorrect use of hooter],[6.1 Mirror],[6.2 Blind spots],[6.3 Indicators],[6.4 Indicators not cancelled],[6.5 Fails to check safety ahead/rear],[6.6 Fails to back down],[6.7 Accelerates when being overtaken],[6.8 Fails to check safety ahead/rear],[6.9 Entry and Exit onto freeways],[End],[Start],[Total],[Time started],[Time ended],[REMARKS AND FEEDBACK],[Please upload a picture of the driver in the yard],[Please upload a picture of the driver driving on the road],[Please upload pictures of the form you filled out]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,am.Latitude,am.Longitude,A.Detail as Answer,Q.QuestionTitle as Question,u.name as UserName,AM.PI
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=1909
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=1910
--) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2511
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (72773,16864,16865,16866,16867,16869,16870,16871,16872,16873,16874,16875,16876,16877,16878,16879,17148,16882,16883,16884,16885,16886,16887,16889,16890,16891,16892,16893,16894,16895,16896,16897,16898,16899,16900,16901,16902,16903,16904,16905,16906,16907,16908,16909,16910,16911,16912,16913,16914,16915,16916,16917,16918,16919,16920,16921,16922,16923,16924,16925,16926,16927,16928,16929,16930,16931,16932,16933,16934,16936,16937,16938,16939,16940,16941,16942,16943,16944,16945,16946,16947,16948,16949,16950,16951,16952,16953,16954,16955,16956,16957,16958,16959,16960,16961,16962,16963,16964,16965,16966,16967,16968,16969,16971,16972,16973,16974,16975,16976,16977,16978,16979,17160,16980,16981,16982,16983,16984,16985,16986,16987,16989,16990,16991,16992,16993,16994,16995,16996,16997,16998,16999,17000,17001,17002,17003,17006,17007,17008,17009,17010,17011,17012,17013,17014,17017,17018,17019,17020,17021,17022,17023,17025,17026,17027,17028,17029,17030,17031,17032,17033,17034,17035,17036,17037,17038,17040,17041,17042,17043,17044,17045,17046,17047,17048,17049,17050,17051,17052,17053,17055,17060,17061,17161,17063,17064,17065,17066,17068,17069,17070,17071,17072,17074,17075,17076,17077,17078,17079,17080,17081,17082,17084,17085,17087,17088,17089,17090,17091,17093,17094,17096,17097,17098,17100,17101,17104,17105,17106,17107,17109,17110,17111,17112,17113,17114,17115,17116,17117,17118,17119,17120,17121,17123,17124,17125,17126,17127,17128,17129,17131,17132,17133,17135,17136,17137,17139,17140,17141,17142,17143,17144,17145,17146,17147,17150,17151,17152,17153,17154,17155,17157,17158,17159)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId	
)s
pivot(
Max(Answer)
For  Question In (
[Customer],[Drivers name and surname],[Drivers Identity Number],[PDP Expiry Date],[License Expiry Date],[Make],[Model/Trailer],[Engine Type],[Gearbox make],[Gearbox speed],[Mesh Type],[Configuration],[Truck Registration Number],[Trailer Number 1],[Trailer Number 2],[Trailer Number 3],[Town/City/Suburb],[1.1 Valid PrDP],[1.1 Comments],[1.2 SAB License],[1.2 Comments],[1.3 SAB Permits and Certificates],[1.3 Comments],[2.1 Body work, bonnet, grill and bumper],[2.1 Comments],[2.2 RTMS Diamond],[2.2 Comments],[2.3 Windscreen wipers],[2.3 Comments],[2.4 Lenses and reflectors are intact],[2.4 Comments],[2.5 Abnormal vehicle strobe light is in place],[2.5 Comments],[2.6 Abnormal sticker is in place and in tact],[2.6 Comments],[2.7 Front number plate],[2.7 Comments],[2.8 License, permits & certificates of fitness as per PBS compliance],[2.8 Comments],[2.9 Side mirrors],[2.9 Comments],[2.10 Doors and windows],[2.10 Comments],[2.11 Wheels & tyres, dust caps, wheel nuts],[2.11 Comments],[2.12 Virgin castings on each wheel],[2.12 Comments],[2.13 All wheels are same make and model],[2.13 Comments],[2.14 4 torque indicators are in place],[2.14 Comments],[2.15 Matching tyres at each axle],[2.15 Comments],[2.16 Inner and outer valve extensions],[2.16 Comments],[2.17 Steel valve caps],[2.17 Comments],[2.18 Batteries and holders],[2.18 Comments],[2.19 Air tanks],[2.19 Comments],[2.20 Spare wheel],[2.20 Comments],[2.21 Rear Chevron, number plate],[2.21 Comments],[2.22 Rear lenses and reflectors],[2.22 Comments],[2.23 Fuel tank and fuel cap],[2.23 Comments],[3.1 Body work in order],[3.1 Comments],[3.2 License discs and number plates all according to PBS permits],[3.2 Comments],[3.3 Information plates all in order according to PBS permits],[3.3 Comments],[3.4 Couplings and service lines – Electrical Suzie all in place],[3.4 Comments],[3.5 ABS braking system connections],[3.5 Comments],[3.6 Lights],[3.6 Comments],[3.7 Front and rear reflectors including front green and rear marker lights],[3.7 Comments],[3.8 Yellow reflective tape],[3.8 Comments],[3.9 Side Underruns],[3.9 Comments],[3.10 Fifth wheel],[3.10 Comments],[3.11 Towbar and pins],[3.11 Comments],[3.12 Rear Chevron],[3.12 Comments],[3.13 Two fit for purpose trolley brackets],[3.13 Comments],[3.14 Wheels and tyres],[3.14 Comments],[3.15 Ratchets operating correctly],[3.15 Comments],[3.16 Tarps in good condition and free from decals],[3.16 Comments],[3.17 Governing 80km/h sticker on the rear of the trailer],[3.17 Comments],[4.1 Parking brake must be applied],[4.1 Comments],[4.2 Gear lever (or selector)],[4.2 Comments],[4.3 Driver’s cab clean and neat and free from loose objects],[4.3 Comments],[4.4 Emergency triangles (1 set per vehicle)],[4.4 Comments],[4.5 Fire extinguisher – serviced and in date],[4.5 Comments],[4.6 Oasis printer – handheld operating correctly and has good battery life],[4.6 Comments],[4.7 Seat correctly positioned],[4.7 Comments],[4.8 Steering free of excessive play],[4.8 Comments],[4.9 Mirrors],[4.9 Comments],[4.10 Ignition in “ON” position – check instruments],[4.10 Comments],[4.11 Start engine – Instruments/gauges all in working order],[4.11 Comments],[4.12 Sufficient fuel for trip],[4.12 Comments],[4.13 Head and brake lights, indicators, hooter, wiper all in good working order],[4.13 Comments],[4.14 Hand and footbrakes free of airleaks],[4.14 Comments],[4.15 Brake and clutch pedals in working order],[4.15 Comments],[4.16 Doors fully operational],[4.16 Comments],[ASSESSOR ADVICE AND FEEDBACK ON VEHICLE PRE-TRIP INSPECTIONS:],[5.1 Place the gear shift lever into the neutral position],[5.2 Check around the vehicle to see if it was safe to start],[5.3 Pre-heat the engine (if applicable)],[5.4 Crank the starter motor for less than 30 seconds],[5.5 Allow starter to cool before trying again (if applicable)],[5.6 Allow engine to warm up without revving the engine],[5.7 Allow the brake air pressure to build up gradually],[5.8 Check all the gauges and instruments for functionality],[ASSESSOR ADVICE AND FEEDBACK ON VEHICLE START UP PROCEDURES],[6.1 Mounting and Dismounting],[6.2 Vehicle Sympathy],[6.3 Observations],[6.4 Use of Controls],[6.5 Clutch Control],[6.6 System of vehicle control knowledge],[6.7 Uncontrolled Dangerous Actions],[7.1 Rough Handling],[7.2 Alignment of truck],[7.3 Handbrake applied],[7.4 Gearlever neutral],[7.5 Observations],[7.6 Use of indicators],[7.7 Correct gear selection],[7.8 Clutch control],[7.9 Mirror/Blind spot while cornering],[7.10 Progress trailers],[7.11 Squares Corner],[7.12 Touch road markings],[7.13 Number of attempts],[7.14 Rolls/coasts],[8.1 Rough Handling],[8.2 Alignment of truck],[8.3 Handbrake applied],[8.4 Gearlever neutral],[8.5 Observations],[8.6 Use of indicators],[8.7 Correct gear selection],[8.8 Clutch control],[8.9 Mirror/Blind spot while cornering],[8.10 Progress trailers],[8.11 Squares Corner],[8.12 Touch road markings],[8.13 Number of attempts],[8.14 Rolls/coasts],[ASSESSOR ADVICE AND FEEDBACK ON YARD TEST:],[1.1 Changes excessively],[1.2 Grates gears],[1.3 Slips gears],[1.4 Hand rests on top of gear lever],[1.5 Eyes on gears],[1.6 Fails to change up / down],[1.7 Select neutral while driving],[2.1 Slips clutch],[2.2 Rides clutch],[2.3 De-clutch too early],[2.4 Keeps clutch depressed while stopped],[2.5 Selects neutral too early],[3.1 Planning ahead],[3.2 Mirror / Blind Spot],[3.3 Brakes too early],[3.4 Brakes too late],[3.5 Brakes not smooth],[3.6 No clear space in front],[3.7 Handbrake not properly utilised],[3.8 Brake used unnecessarily],[3.9 Incorrect negotiation of the decline],[4.1 Wanders],[4.2 Positioning/seating],[5.1 Planning ahead],[5.2 Does not maintain constant speed],[5.3 Too fast],[5.4 Too slow],[5.5 Greenband driving],[6.1 Not according to specification],[6.2 Not used when required],[7.1 Not vehicle friendly/too hard],[7.2 Mounts the kerb],[7.3 Bump objects],[8.1 Alley docking from right],[8.2 Reversing in a straight line],[1.1 Observations/left and right],[1.2 Wrong gear],[1.3 Stalls],[1.4 Waits too long],[2.1 Planning ahead],[2.2 Mirror],[2.3 Blind spots],[2.4 Rolling back],[2.5 Indicators],[2.6 Indicator not cancelled],[2.7 Fails to check trailer],[2.8 Position for turn/wheels straight],[2.9 Brake while cornering],[2.10 Too fast],[2.11 Cuts corners],[2.12 Too wide],[2.13 Changing gears on corners],[3.1 Ignore change in road surface and conditions],[3.2 Ignores actions of other road users],[3.3 Ignores weather conditions],[3.4 No observations],[3.5 Use of mirrors],[3.6 Ignores road signs / markings],[3.7 Moves into blind spots of other drivers],[4.1 Travels Too close to crown of road],[4.2 Fails to maintain following distance],[4.3 Straddling],[5.1 Fails to notice hazards],[5.2 Fails to react to hazards],[5.3 Incorrect use of hooter],[6.1 Mirror],[6.2 Blind spots],[6.3 Indicators],[6.4 Indicators not cancelled],[6.5 Fails to check safety ahead/rear],[6.6 Fails to back down],[6.7 Accelerates when being overtaken],[6.8 Fails to check safety ahead/rear],[6.9 Entry and Exit onto freeways],[End],[Start],[Total],[Time started],[Time ended],[REMARKS AND FEEDBACK],[Please upload a picture of the driver in the yard],[Please upload a picture of the driver driving on the road],[Please upload pictures of the form you filled out]
))p 
