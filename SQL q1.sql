-- For quick testing
CREATE TABLE TableA (
    trainerid INT,
    starttime DATETIME,
    endtime DATETIME
);

-- If needed, indexing on trainderid and starttime for lots of read/write
CREATE INDEX idx_trainer_starttime ON TableA (trainerid, starttime); 

INSERT INTO TableA (trainerid, starttime, endtime)
VALUES
    (1234, '2018-01-10 08:30:00', '2018-01-10 09:00:00'),
    (1234, '2018-01-10 08:45:00', '2018-01-10 09:15:00'),
    (1234, '2018-01-10 09:30:00', '2018-01-10 10:00:00'),
    (2345, '2018-01-10 08:45:00', '2018-01-10 09:15:00'),
    (2345, '2018-01-10 09:30:00', '2018-01-10 10:00:00'),
    (2345, '2018-01-10 10:50:00', '2018-01-10 11:00:00'),
    (2345, '2018-01-10 09:50:00', '2018-01-10 10:00:00');

WITH Clashes AS (
    SELECT 
        trainerid, starttime, endtime, LEAD(starttime) OVER (PARTITION BY trainerid ORDER BY starttime) AS next_starttime
    FROM TableA
)
SELECT 
    trainerid, starttime, endtime
FROM Clashes
WHERE starttime < next_starttime;