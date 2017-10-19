SELECT markettime, 
       marketid, 
       results, 
       [15sec], 
       [30sec], 
       [1min], 
       [2min], 
       [3min], 
       [4min], 
       [5min] 
FROM   (SELECT DISTINCT markettime, 
                        marketid, 
                        marketid AS MID, 
                        timestampid 
        FROM   [HorseRacing].[dbo].[betfairoddssaved]) AS s 
       PIVOT (Count(marketid) 
             FOR timestampid IN ([15SEC], 
                                 [30SEC], 
                                 [1MIN], 
                                 [2MIN], 
                                 [3MIN], 
                                 [4MIN], 
                                 [5MIN])) AS pvt 
       INNER JOIN (SELECT marketid, 
                          Max(CASE 
                                WHEN finishbool != -1 THEN 1 
                                ELSE 0 
                              END) AS Results 
                   FROM   betfairstarters 
                   GROUP  BY marketid) a 
               ON a.marketid = mid 
ORDER  BY markettime DESC 