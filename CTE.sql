With CTE as (
Select Distinct 
		S.MarketID,
		S.SelectionID,
		dbo.RemoveAlphaCharacters(DtHorses.Form) as FormCleaned,
		DtHorses.DaySinceLastRun,
		S.HorseName,
		FinishBool = Case when Result = 'WINNER' then 1
					  when Result = 'LOSER' then 0
					  else -1
					  end

from DtStarters S
inner join DtUpcomingRaces on 
DtUpcomingRaces.MarketID = S.MarketID 
inner join DtHorses on 
DtHorses.SelectionID = S.SelectionID

left JOIN BetfairStarters T
ON S.MarketID = T.MarketID and
   S.SelectionID = T.SelectionID

where S.Result != 'REMOVED'  and  t.EventID is null and t.MarketID is null )

Select Distinct MarketID 
from CTE 
where HorseName Not like '%Franco%' 