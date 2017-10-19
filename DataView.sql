SELECT dbo.vw_betfairraces_wintbmarketsonly.markettimeaus, 
       dbo.betfairstarters.marketid, 
       dbo.betfairstarters.selectionid, 
       CASE 
         WHEN LEFT(RIGHT(formcleaned, 4), 1) = 0 THEN 10 
         WHEN LEFT(RIGHT(formcleaned, 4), 1) IS NULL THEN 0 
         ELSE Cast(LEFT(RIGHT(formcleaned, 4), 1) AS INT) 
       END                                    AS FourthRun, 
       CASE 
         WHEN LEFT(RIGHT(formcleaned, 3), 1) = 0 THEN 10 
         WHEN LEFT(RIGHT(formcleaned, 3), 1) IS NULL THEN 0 
         ELSE Cast(LEFT(RIGHT(formcleaned, 3), 1) AS INT) 
       END                                    AS ThirdRun, 
       CASE 
         WHEN LEFT(RIGHT(formcleaned, 2), 1) = 0 THEN 10 
         WHEN LEFT(RIGHT(formcleaned, 2), 1) IS NULL THEN 0 
         ELSE Cast(LEFT(RIGHT(formcleaned, 2), 1) AS INT) 
       END                                    AS SecondRun, 
       CASE 
         WHEN RIGHT(formcleaned, 1) = 0 THEN 10 
         WHEN RIGHT(formcleaned, 1) IS NULL THEN 0 
         ELSE Cast(RIGHT(formcleaned, 1) AS INT) 
       END                                    AS LastRun, 
       CASE 
         WHEN daysincelastrun IS NULL 
               OR daysincelastrun < 0 THEN 0 
         ELSE Cast(daysincelastrun AS FLOAT) 
       END                                    AS DaysSinceLastRun, 
       Cast(dbo.betfairstarters.age AS FLOAT) AS Age, 
       CASE 
         WHEN stalldraw IS NULL THEN 0 
         ELSE stalldraw 
       END                                    AS StallDraw, 
       CASE 
         WHEN weightunits = 'kg' THEN Round(Cast(weight AS FLOAT) * 2.20462, 0) 
         WHEN weight IS NULL THEN 130 
         ELSE weight 
       END                                    AS AdjWgt, 
       CASE 
         WHEN odds.[3min] IS NULL THEN 0 
         WHEN Cast(odds.[3min] AS FLOAT) > 0 THEN 1 / Cast(odds.[3min] AS FLOAT) 
         ELSE 0 
       END                                    AS Odds3min, 
       CASE 
         WHEN odds.[2min] IS NULL THEN 0 
         WHEN Cast(odds.[2min] AS FLOAT) > 0 THEN 1 / Cast(odds.[2min] AS FLOAT) 
         ELSE 0 
       END                                    AS Odds2min, 
       CASE 
         WHEN odds.[1min] IS NULL THEN 0 
         WHEN Cast(odds.[1min] AS FLOAT) > 0 THEN 1 / Cast(odds.[1min] AS FLOAT) 
         ELSE 0 
       END                                    AS Odds1min, 
       CASE 
         WHEN odds.[30sec] IS NULL THEN 0 
         WHEN Cast(odds.[30sec] AS FLOAT) > 0 THEN 1 / Cast( 
         odds.[30sec] AS FLOAT) 
         ELSE 0 
       END                                    AS Odds30sec, 
       CASE 
         WHEN odds.[15sec] IS NULL THEN 0 
         WHEN Cast(odds.[15sec] AS FLOAT) > 0 THEN 1 / Cast( 
         odds.[15sec] AS FLOAT) 
         ELSE 0 
       END                                    AS Odds15sec, 
       dbo.betfairstarters.finishbool, 
       dbo.betfairstarters.horsesaddlecloth, 
       CASE 
         WHEN bsptbl.bspnear IS NULL THEN 0 
         WHEN Cast(bsptbl.bspnear AS FLOAT) > 0 THEN 1 / Cast( 
         bsptbl.bspnear AS FLOAT) 
         ELSE 0 
       END                                    AS BSPNearprob, 
       bsptbl.bspnear 
FROM   dbo.betfairstarters 
       INNER JOIN dbo.vw_betfairoddssaved_pivottable_odds AS odds 
               ON odds.marketid = dbo.betfairstarters.marketid 
                  AND odds.horsesaddlecloth = 
                      dbo.betfairstarters.horsesaddlecloth 
       INNER JOIN dbo.vw_betfairraces_wintbmarketsonly 
               ON dbo.vw_betfairraces_wintbmarketsonly.marketid = 
                  dbo.betfairstarters.marketid 
       INNER JOIN (SELECT marketid, 
                          selectionid, 
                          horsesaddlecloth, 
                          bspnear 
                   FROM   dbo.betfairoddssaved 
                   WHERE  ( timestampid = '15sec' )) AS bsptbl 
               ON bsptbl.marketid = dbo.betfairstarters.marketid 
                  AND bsptbl.horsesaddlecloth = 
                      dbo.betfairstarters.horsesaddlecloth 
WHERE  ( Cast(dbo.betfairstarters.weight AS FLOAT) > 0 ) 
       AND ( odds.[15sec] IS NOT NULL ) 
       AND ( odds.results > -1 ) 