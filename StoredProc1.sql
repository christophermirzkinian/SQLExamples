USE [HorseRacing]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chris
-- Create date: 29/09/2017
-- Description:	Saves Data and Clears Datatables
-- =============================================
ALTER PROCEDURE [dbo].[ClearBetfairTables]
AS

Begin
Insert Into BetfairMeetings
select Distinct  
		S.EventID,
	Convert(date,S.MarketTime) as MeetingDate,
	S.VenueName,
	S.EventName,
	S.EventTimeZone,
	S.CountryID
from DtUpcomingRaces S
left JOIN BetfairMeetings T
ON S.EventID = T.EventID
where t.EventID is null 
End
Begin
Insert Into BetfairRaces
Select Distinct --tblRace
	S.EventID,
	S.MarketID,
	S.MarketType,
	S.MarketName,
	S.MarketDistance,	S.MarketTime,
	S.MarketTimeAus
from DtUpcomingRaces S
left JOIN BetfairRaces T
ON S.EventID = T.EventID and
   S.MarketID = T.MarketID
where t.EventID is null and t.MarketID is null 
End
Begin
Insert Into BetfairStarters 
Select Distinct --tblStarters
		DtUpcomingRaces.EventID,
		S.MarketID,
		S.SelectionID,
		DtHorses.RunnerID,
		DtHorses.Form, 
		dbo.RemoveAlphaCharacters(DtHorses.Form) as FormCleaned,
		DtHorses.DaySinceLastRun,
		DtHorses.Bred,
		dthorses.Age,
		DtHorses.Gender,
		S.HorseSaddleCloth,
		DtHorses.StallDraw,
		S.HorseName,
		FinishBool = Case when Result = 'WINNER' then 1
					  when Result = 'LOSER' then 0
					  else -1
					  end,
		S.BSPActual,
		DtHorses.JockeyName,
		DtHorses.JockeyClaim,
		DtHorses.Weight,
		DtHorses.WeightUnits,
		DtHorses.TrainerName,
		DtHorses.DamName,
		DtHorses.DamBred,
		DtHorses.DamYearBorn,
		DtHorses.SireName,
		DtHorses.SireBred,
		DtHorses.SireYearBorn,
		DtHorses.Wearing
		  
from DtStarters S
inner join DtUpcomingRaces on 
DtUpcomingRaces.MarketID = S.MarketID 
inner join DtHorses on 
DtHorses.SelectionID = S.SelectionID

left JOIN BetfairStarters T
ON S.MarketID = T.MarketID and
   S.SelectionID = T.SelectionID

where S.Result != 'REMOVED'  and  t.EventID is null and t.MarketID is null 
End
Begin --No BSPActual Delete
Delete from DtStarters  where ISNUMERIC(BSPActual) = 0
End
Begin --Late Scratching Delete
Delete From BetfairStarters where BetfairStarters.SelectionID in (
Select 
	T.SelectionID
from DtStarters S
Inner JOIN BetfairStarters T
ON T.MarketID = S.MarketID
and t.SelectionID = S.SelectionID 
where T.FinishBool = -1 and S.Result ='REMOVED')
End
Begin
Update BetfairStarters Set  --tblStarters

		BetfairStarters.FinishBool =  Case when Result = 'WINNER' then 1
					  when Result = 'LOSER' then 0
					  else -1
					  end,
		BetfairStarters.BSPActual = S.BSPActual
					  
from DtStarters S
Inner JOIN BetfairStarters T
ON T.MarketID = S.MarketID
and t.SelectionID = S.SelectionID
End
Begin
Insert Into BetfairOddsSaved
Select * 
from vw_BetfairSnapshot
End
Begin
	Truncate Table DtHorses
	Truncate Table DtStarters
	Truncate Table DtUpcomingRaces
END
