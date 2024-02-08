-- 1) IDENTITY on a PRIMARY KEY / AUTO_INCREMENT keyword on other languages (MySql?)

-- 2) Simple group by with HAVING close
SELECT Customer_Name, TicketNumber, Date_Bought, Date_Expires, COUNT(*) AS DuplicateCount
FROM Imports.dbo.Tickets_Imprt
GROUP BY Customer_Name, TicketNumber, Date_Bought, Date_Expires
HAVING COUNT(*) > 1;


-- 3) CTE with ROW_NUMBER OVER PARTITION BY to delete duplicates which have RowNum > 1
WITH Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Customer_Name, TicketNumber, Date_Bought, Date_Expires ORDER BY DateImported DESC) AS RowNum
    FROM Imports.dbo.Tickets_Imprt
)
DELETE FROM Duplicates
WHERE RowNum > 1;


-- 4) Default to GetDate() if no value for DateImported
ALTER TABLE Imports.dbo.Tickets_Imprt
ADD CONSTRAINT DF_DateImported DEFAULT GETDATE() FOR DateImported;

-- 5)
CREATE PROCEDURE MoveDataFromStagingToFinal AS
BEGIN
    INSERT INTO BestDeals.Tickets (Customer_Name, TicketNumber, Date_Bought, Date_Expires, DateImported)
    SELECT Customer_Name, TicketNumber, 
        CONVERT(datetime, Date_Bought, 101), -- Assuming dd/mm/yyyy format (from example could be also mm/dd/yyyy)
        CONVERT(datetime, Date_Expires, 120) 
        CONVERT(datetime, DateImported, 120)
    FROM Imports.dbo.Tickets_Staging;

    WITH LatestDuplicates AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY Customer_Name, TicketNumber, Date_Bought, Date_Expires ORDER BY DateImported DESC) AS RowNum
        FROM BestDeals.Tickets
    )
    DELETE FROM LatestDuplicates
    WHERE RowNum > 1;
END;

