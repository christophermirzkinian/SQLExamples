SELECT  DtHorses.HorseName,t2o.JockeyID
FROM    DtHorses
CROSS APPLY
        (
        SELECT  TOP 3 *
        FROM    DtStarters
        WHERE   DtStarters.HorseName = DtHorses.HorseName
        ORDER BY
                DtStarters.MarketID DESC
        ) t2o