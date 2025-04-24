-- Database creation
CREATE DATABASE IndianRailwayReservation;
USE IndianRailwayReservation;

-- Table creations
CREATE TABLE Passenger (
    PassengerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Age INT,
    Gender ENUM('Male', 'Female', 'Other'),
    ContactNo VARCHAR(15) NOT NULL,
    Email VARCHAR(100),
    CONSTRAINT chk_age CHECK (Age > 0)
);

CREATE TABLE Station (
    StationID INT AUTO_INCREMENT PRIMARY KEY,
    StationName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    INDEX idx_station_name (StationName)
);

CREATE TABLE Route (
    RouteID INT AUTO_INCREMENT PRIMARY KEY,
    RouteName VARCHAR(100) NOT NULL,
    OriginStationID INT NOT NULL,
    DestinationStationID INT NOT NULL,
    TotalDistance DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (OriginStationID) REFERENCES Station(StationID),
    FOREIGN KEY (DestinationStationID) REFERENCES Station(StationID),
    CONSTRAINT chk_distance CHECK (TotalDistance > 0)
);

CREATE TABLE Train (
    TrainID INT AUTO_INCREMENT PRIMARY KEY,
    TrainName VARCHAR(100) NOT NULL,
    TrainType ENUM('Superfast', 'Express', 'Passenger', 'Rajdhani', 'Shatabdi'),
    RouteID INT NOT NULL,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID),
    INDEX idx_train_name (TrainName)
);

CREATE TABLE Class (
    ClassID INT AUTO_INCREMENT PRIMARY KEY,
    ClassName VARCHAR(50) NOT NULL,
    BaseFareMultiplier DECIMAL(4,2) NOT NULL,
    CONSTRAINT chk_multiplier CHECK (BaseFareMultiplier > 0)
);

-- Combined Coach and Seat table with composite SeatID
CREATE TABLE Seat (
    SeatID VARCHAR(20) PRIMARY KEY,  -- Format: 'TrainID-CoachNo-SeatNo' (e.g., '101-A1-15')
    TrainID INT NOT NULL,
    ClassID INT NOT NULL,
    CoachNo VARCHAR(10) NOT NULL,  -- e.g., 'A1', 'B2', 'S3'
    SeatNo VARCHAR(10) NOT NULL,    -- e.g., '1', '2', '12A', '12B'
    Availability BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID),
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    CONSTRAINT uk_seat UNIQUE (TrainID, CoachNo, SeatNo)
);

CREATE TABLE Schedule (
    ScheduleID INT AUTO_INCREMENT PRIMARY KEY,
    TrainID INT NOT NULL,
    DaysOfOperation VARCHAR(40) NOT NULL, -- e.g., "Mon,Wed,Fri"
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID)
);

CREATE TABLE RouteStation (
    RouteID INT NOT NULL,
    StationID INT NOT NULL,
    SequenceNo INT NOT NULL,
    DistanceFromOrigin DECIMAL(8,2) NOT NULL,
    ArrivalTime TIME,
    DepartureTime TIME,
    PRIMARY KEY (RouteID, StationID),
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID),
    FOREIGN KEY (StationID) REFERENCES Station(StationID),
    CONSTRAINT chk_sequence CHECK (SequenceNo > 0)
);

CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMode ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash') NOT NULL,
    PaymentDateTime DATETIME NOT NULL,
    Status ENUM('Success', 'Failed', 'Pending') NOT NULL,
    INDEX idx_payment_date (PaymentDateTime)
);

CREATE TABLE Booking (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    PassengerID INT NOT NULL,
    BookingDateTime DATETIME NOT NULL,
    BookingType ENUM('Online', 'Counter') NOT NULL,
    PaymentID INT NOT NULL,
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),
    FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID),
    INDEX idx_booking_date (BookingDateTime)
);

CREATE TABLE Ticket (
    PNR VARCHAR(10) PRIMARY KEY,
    BookingID INT NOT NULL,
    TrainID INT NOT NULL,
    JourneyDate DATE NOT NULL,
    ClassID INT NOT NULL,
    FromStationID INT NOT NULL,
    ToStationID INT NOT NULL,
    SeatID VARCHAR(20),  -- References the composite SeatID
    Status ENUM('Confirmed', 'RAC', 'Waitlist', 'Cancelled') NOT NULL,
    Fare DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID),
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    FOREIGN KEY (FromStationID) REFERENCES Station(StationID),
    FOREIGN KEY (ToStationID) REFERENCES Station(StationID),
    FOREIGN KEY (SeatID) REFERENCES Seat(SeatID),
    INDEX idx_journey_date (JourneyDate),
    INDEX idx_status (Status)
);

CREATE TABLE Concession (
    ConcessionID INT AUTO_INCREMENT PRIMARY KEY,
    ConcessionType VARCHAR(50) NOT NULL,
    DiscountPercentage DECIMAL(5,2) NOT NULL,
    CONSTRAINT chk_discount CHECK (DiscountPercentage >= 0 AND DiscountPercentage <= 100)
);

CREATE TABLE PassengerConcession (
    PassengerID INT NOT NULL,
    ConcessionID INT NOT NULL,
    ValidUntil DATE NOT NULL,
    PRIMARY KEY (PassengerID, ConcessionID),
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),
    FOREIGN KEY (ConcessionID) REFERENCES Concession(ConcessionID)
);

CREATE TABLE Cancellation (
    CancellationID INT AUTO_INCREMENT PRIMARY KEY,
    PNR VARCHAR(10) NOT NULL,
    CancellationDateTime DATETIME NOT NULL,
    RefundAmount DECIMAL(10,2) NOT NULL,
    RefundStatus ENUM('Processed', 'Pending', 'Rejected') NOT NULL,
    FOREIGN KEY (PNR) REFERENCES Ticket(PNR),
    INDEX idx_cancellation_date (CancellationDateTime)
);

-- Additional indexes for performance
CREATE INDEX idx_train_route ON Train(RouteID);
CREATE INDEX idx_ticket_train ON Ticket(TrainID);
CREATE INDEX idx_ticket_class ON Ticket(ClassID);
CREATE INDEX idx_seat_train_class ON Seat(TrainID, ClassID);

INSERT INTO Station (StationName, City, State) VALUES
('Mumbai Central', 'Mumbai', 'Maharashtra'),
('Chhatrapati Shivaji Terminus', 'Mumbai', 'Maharashtra'),
('New Delhi', 'Delhi', 'Delhi'),
('Delhi Junction', 'Delhi', 'Delhi'),
('Chennai Central', 'Chennai', 'Tamil Nadu'),
('Howrah Junction', 'Kolkata', 'West Bengal'),
('Bangalore City', 'Bangalore', 'Karnataka'),
('Secunderabad Junction', 'Hyderabad', 'Telangana'),
('Ahmedabad Junction', 'Ahmedabad', 'Gujarat'),
('Pune Junction', 'Pune', 'Maharashtra'),
('Jaipur Junction', 'Jaipur', 'Rajasthan'),
('Lucknow Junction', 'Lucknow', 'Uttar Pradesh'),
('Patna Junction', 'Patna', 'Bihar'),
('Nagpur Junction', 'Nagpur', 'Maharashtra'),
('Bhopal Junction', 'Bhopal', 'Madhya Pradesh'),
('Indore Junction', 'Indore', 'Madhya Pradesh'),
('Varanasi Junction', 'Varanasi', 'Uttar Pradesh'),
('Kanpur Central', 'Kanpur', 'Uttar Pradesh'),
('Allahabad Junction', 'Prayagraj', 'Uttar Pradesh'),
('Amritsar Junction', 'Amritsar', 'Punjab'),
('Chandigarh Junction', 'Chandigarh', 'Chandigarh'),
('Guwahati Junction', 'Guwahati', 'Assam'),
('Bhubaneswar', 'Bhubaneswar', 'Odisha'),
('Visakhapatnam Junction', 'Visakhapatnam', 'Andhra Pradesh'),
('Coimbatore Junction', 'Coimbatore', 'Tamil Nadu'),
('Madurai Junction', 'Madurai', 'Tamil Nadu'),
('Thiruvananthapuram Central', 'Thiruvananthapuram', 'Kerala'),
('Kochi Junction', 'Kochi', 'Kerala'),
('Mysore Junction', 'Mysore', 'Karnataka'),
('Vijayawada Junction', 'Vijayawada', 'Andhra Pradesh'),
('Tiruchirappalli Junction', 'Tiruchirappalli', 'Tamil Nadu'),
('Ranchi Junction', 'Ranchi', 'Jharkhand'),
('Raipur Junction', 'Raipur', 'Chhattisgarh'),
('Jodhpur Junction', 'Jodhpur', 'Rajasthan'),
('Udaipur City', 'Udaipur', 'Rajasthan'),
('Dehradun', 'Dehradun', 'Uttarakhand'),
('Haridwar Junction', 'Haridwar', 'Uttarakhand'),
('Gorakhpur Junction', 'Gorakhpur', 'Uttar Pradesh'),
('Jammu Tawi', 'Jammu', 'Jammu and Kashmir'),
('Surat Junction', 'Surat', 'Gujarat'),
('Vadodara Junction', 'Vadodara', 'Gujarat'),
('Rajkot Junction', 'Rajkot', 'Gujarat'),
('Bhavnagar Terminus', 'Bhavnagar', 'Gujarat'),
('Jabalpur Junction', 'Jabalpur', 'Madhya Pradesh'),
('Gwalior Junction', 'Gwalior', 'Madhya Pradesh'),
('Agra Cantt', 'Agra', 'Uttar Pradesh'),
('Bareilly Junction', 'Bareilly', 'Uttar Pradesh'),
('Moradabad Junction', 'Moradabad', 'Uttar Pradesh'),
('Gaya Junction', 'Gaya', 'Bihar'),
('Dhanbad Junction', 'Dhanbad', 'Jharkhand');

INSERT INTO Route (RouteName, OriginStationID, DestinationStationID, TotalDistance) VALUES
('Mumbai-Delhi Rajdhani', 1, 3, 1386),
('Delhi-Chennai Grand Trunk', 3, 5, 2180),
('Howrah-Delhi Rajdhani', 6, 3, 1448),
('Mumbai-Chennai Express', 1, 5, 1288),
('Delhi-Bangalore Sampark Kranti', 3, 7, 2370),
('Chennai-Hyderabad Shatabdi', 5, 8, 715),
('Delhi-Kolkata Express', 3, 6, 1472),
('Mumbai-Ahmedabad Shatabdi', 1, 9, 491),
('Delhi-Pune Express', 3, 10, 1524),
('Chennai-Bangalore Shatabdi', 5, 7, 362),
('Mumbai-Jaipur Superfast', 1, 11, 1145),
('Delhi-Lucknow Shatabdi', 3, 12, 512),
('Kolkata-Patna Rajdhani', 6, 13, 536),
('Mumbai-Nagpur Express', 1, 14, 837),
('Delhi-Bhopal Shatabdi', 3, 15, 702),
('Chennai-Coimbatore Shatabdi', 5, 25, 496),
('Delhi-Varanasi Superfast', 3, 17, 764),
('Mumbai-Indore Express', 1, 16, 655),
('Kolkata-Guwahati Rajdhani', 6, 22, 1037),
('Delhi-Amritsar Shatabdi', 3, 20, 448),
('Chennai-Thiruvananthapuram Express', 5, 27, 851),
('Mumbai-Goa Express', 1, 45, 756),
('Delhi-Jammu Tawi Rajdhani', 3, 39, 586),
('Kolkata-Bhubaneswar Rajdhani', 6, 23, 439),
('Mysore-Bangalore Express', 29, 7, 138),
('Hyderabad-Vijayawada Express', 8, 30, 281),
('Delhi-Dehradun Shatabdi', 3, 36, 302),
('Ahmedabad-Rajkot Express', 9, 42, 217),
('Patna-Gaya Express', 13, 49, 100),
('Nagpur-Bhopal Express', 14, 15, 412);

INSERT INTO Train (TrainName, TrainType, RouteID) VALUES
('Rajdhani Express (12951)', 'Rajdhani', 1),
('Grand Trunk Express (12615)', 'Express', 2),
('Howrah Rajdhani (12301)', 'Rajdhani', 3),
('Mumbai Mail (11039)', 'Express', 4),
('Sampark Kranti (12649)', 'Superfast', 5),
('Chennai Shatabdi (12007)', 'Shatabdi', 6),
('Duronto Express (12259)', 'Passenger', 7),
('Mumbai Shatabdi (12010)', 'Shatabdi', 8),
('Pune Express (12269)', 'Passenger', 9),
('Bangalore Shatabdi (12028)', 'Shatabdi', 10),
('Jaipur Superfast (12955)', 'Superfast', 11),
('Lucknow Shatabdi (12004)', 'Shatabdi', 12),
('Patna Rajdhani (12309)', 'Rajdhani', 13),
('Nagpur Express (12289)', 'Passenger', 14),
('Bhopal Shatabdi (12001)', 'Shatabdi', 15),
('Coimbatore Shatabdi (12243)', 'Shatabdi', 16),
('Varanasi Superfast (12561)', 'Superfast', 17),
('Indore Express (19301)', 'Express', 18),
('Guwahati Rajdhani (12423)', 'Rajdhani', 19),
('Amritsar Shatabdi (12013)', 'Shatabdi', 20),
('Thiruvananthapuram Express (12695)', 'Express', 21),
('Goa Express (12779)', 'Express', 22),
('Jammu Rajdhani (12425)', 'Rajdhani', 23),
('Bhubaneswar Rajdhani (22811)', 'Rajdhani', 24),
('Mysore Express (12609)', 'Express', 25),
('Vijayawada Express (12703)', 'Express', 26),
('Dehradun Shatabdi (12017)', 'Shatabdi', 27),
('Rajkot Express (12471)', 'Passenger', 28),
('Gaya Express (12351)', 'Passenger', 29),
('Bhopal Express (12155)', 'Express', 30);

INSERT INTO Class (ClassName, BaseFareMultiplier) VALUES
('Sleeper (SL)', 1.0),
('AC 3-tier (3A)', 1.8),
('AC 2-tier (2A)', 2.5),
('First Class (1A)', 3.5),
('AC Chair Car (CC)', 1.5),
('Second Sitting (2S)', 0.6);

-- Procedure to generate seats for a train
DELIMITER //
CREATE PROCEDURE GenerateSeatsForTrain(
    IN p_TrainID INT,
    IN p_ClassID INT,
    IN p_CoachPrefix VARCHAR(5),
    IN p_CoachCount INT,
    IN p_SeatsPerCoach INT
)
BEGIN
    DECLARE v_CoachNo INT DEFAULT 1;
    DECLARE v_SeatNo INT;
    DECLARE v_SeatID VARCHAR(20);
    
    WHILE v_CoachNo <= p_CoachCount DO
        SET v_SeatNo = 1;
        WHILE v_SeatNo <= p_SeatsPerCoach DO
            SET v_SeatID = CONCAT(p_TrainID, '-', p_CoachPrefix, v_CoachNo, '-', v_SeatNo);
            
            INSERT INTO Seat (SeatID, TrainID, ClassID, CoachNo, SeatNo)
            VALUES (v_SeatID, p_TrainID, p_ClassID, CONCAT(p_CoachPrefix, v_CoachNo), v_SeatNo);
            
            SET v_SeatNo = v_SeatNo + 1;
        END WHILE;
        SET v_CoachNo = v_CoachNo + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate seats for all 30 trains with realistic coach configurations

-- 1. Rajdhani Express (TrainID=1) - Typically has more AC coaches
CALL GenerateSeatsForTrain(1, 2, 'A', 5, 72);  -- 5 AC 3-tier coaches (A1-A5)
CALL GenerateSeatsForTrain(1, 3, 'B', 3, 48);  -- 3 AC 2-tier coaches (B1-B3)
CALL GenerateSeatsForTrain(1, 4, 'C', 2, 24);  -- 2 First AC coaches (C1-C2)

-- 2. Grand Trunk Express (TrainID=2) - More sleeper coaches
CALL GenerateSeatsForTrain(2, 1, 'S', 8, 72);  -- 8 Sleeper coaches (S1-S8)
CALL GenerateSeatsForTrain(2, 2, 'A', 4, 72);  -- 4 AC 3-tier coaches (A1-A4)
CALL GenerateSeatsForTrain(2, 6, 'D', 2, 108); -- 2 Second Sitting coaches (D1-D2)

-- 3. Howrah Rajdhani (TrainID=3)
CALL GenerateSeatsForTrain(3, 2, 'A', 6, 72);  -- 6 AC 3-tier
CALL GenerateSeatsForTrain(3, 3, 'B', 4, 48);  -- 4 AC 2-tier
CALL GenerateSeatsForTrain(3, 4, 'C', 1, 24);  -- 1 First AC

-- 4. Mumbai Mail (TrainID=4)
CALL GenerateSeatsForTrain(4, 1, 'S', 10, 72); -- 10 Sleeper
CALL GenerateSeatsForTrain(4, 2, 'A', 3, 72);  -- 3 AC 3-tier
CALL GenerateSeatsForTrain(4, 6, 'D', 3, 108); -- 3 Second Sitting

-- 5. Sampark Kranti (TrainID=5)
CALL GenerateSeatsForTrain(5, 1, 'S', 9, 72);  -- 9 Sleeper
CALL GenerateSeatsForTrain(5, 2, 'A', 5, 72);  -- 5 AC 3-tier

-- 6. Chennai Shatabdi (TrainID=6) - Only Chair Car
CALL GenerateSeatsForTrain(6, 5, 'C', 6, 85);  -- 6 AC Chair Cars

-- 7. Delhi-Kolkata Duronto (TrainID=7)
CALL GenerateSeatsForTrain(7, 2, 'A', 6, 72);  -- 6 AC 3-tier
CALL GenerateSeatsForTrain(7, 3, 'B', 4, 48);  -- 4 AC 2-tier

-- 8. Mumbai Shatabdi (TrainID=8) - Only Chair Car
CALL GenerateSeatsForTrain(8, 5, 'C', 7, 85);  -- 7 AC Chair Cars

-- 9. Pune Duronto (TrainID=9)
CALL GenerateSeatsForTrain(9, 2, 'A', 5, 72);  -- 5 AC 3-tier
CALL GenerateSeatsForTrain(9, 3, 'B', 3, 48);  -- 3 AC 2-tier

-- 10. Bangalore Shatabdi (TrainID=10) - Only Chair Car
CALL GenerateSeatsForTrain(10, 5, 'C', 6, 85); -- 6 AC Chair Cars

-- 11. Jaipur Superfast (TrainID=11)
CALL GenerateSeatsForTrain(11, 1, 'S', 7, 72); -- 7 Sleeper
CALL GenerateSeatsForTrain(11, 2, 'A', 4, 72); -- 4 AC 3-tier
CALL GenerateSeatsForTrain(11, 6, 'D', 3, 108);-- 3 Second Sitting

-- 12. Lucknow Shatabdi (TrainID=12) - Only Chair Car
CALL GenerateSeatsForTrain(12, 5, 'C', 5, 85); -- 5 AC Chair Cars

-- 13. Patna Rajdhani (TrainID=13)
CALL GenerateSeatsForTrain(13, 2, 'A', 5, 72); -- 5 AC 3-tier
CALL GenerateSeatsForTrain(13, 3, 'B', 3, 48); -- 3 AC 2-tier

-- 14. Nagpur Duronto (TrainID=14)
CALL GenerateSeatsForTrain(14, 2, 'A', 4, 72); -- 4 AC 3-tier
CALL GenerateSeatsForTrain(14, 3, 'B', 2, 48); -- 2 AC 2-tier

-- 15. Bhopal Shatabdi (TrainID=15) - Only Chair Car
CALL GenerateSeatsForTrain(15, 5, 'C', 5, 85); -- 5 AC Chair Cars

-- 16. Coimbatore Shatabdi (TrainID=16) - Only Chair Car
CALL GenerateSeatsForTrain(16, 5, 'C', 4, 85); -- 4 AC Chair Cars

-- 17. Varanasi Superfast (TrainID=17)
CALL GenerateSeatsForTrain(17, 1, 'S', 6, 72); -- 6 Sleeper
CALL GenerateSeatsForTrain(17, 2, 'A', 3, 72); -- 3 AC 3-tier
CALL GenerateSeatsForTrain(17, 6, 'D', 2, 108);-- 2 Second Sitting

-- 18. Indore Express (TrainID=18)
CALL GenerateSeatsForTrain(18, 1, 'S', 5, 72); -- 5 Sleeper
CALL GenerateSeatsForTrain(18, 2, 'A', 2, 72); -- 2 AC 3-tier

-- 19. Guwahati Rajdhani (TrainID=19)
CALL GenerateSeatsForTrain(19, 2, 'A', 4, 72); -- 4 AC 3-tier
CALL GenerateSeatsForTrain(19, 3, 'B', 2, 48); -- 2 AC 2-tier

-- 20. Amritsar Shatabdi (TrainID=20) - Only Chair Car
CALL GenerateSeatsForTrain(20, 5, 'C', 4, 85); -- 4 AC Chair Cars

-- 21. Thiruvananthapuram Express (TrainID=21)
CALL GenerateSeatsForTrain(21, 1, 'S', 8, 72); -- 8 Sleeper
CALL GenerateSeatsForTrain(21, 2, 'A', 3, 72); -- 3 AC 3-tier
CALL GenerateSeatsForTrain(21, 6, 'D', 3, 108);-- 3 Second Sitting

-- 22. Goa Express (TrainID=22)
CALL GenerateSeatsForTrain(22, 1, 'S', 7, 72); -- 7 Sleeper
CALL GenerateSeatsForTrain(22, 2, 'A', 2, 72); -- 2 AC 3-tier

-- 23. Jammu Rajdhani (TrainID=23)
CALL GenerateSeatsForTrain(23, 2, 'A', 5, 72); -- 5 AC 3-tier
CALL GenerateSeatsForTrain(23, 3, 'B', 3, 48); -- 3 AC 2-tier

-- 24. Bhubaneswar Rajdhani (TrainID=24)
CALL GenerateSeatsForTrain(24, 2, 'A', 4, 72); -- 4 AC 3-tier
CALL GenerateSeatsForTrain(24, 3, 'B', 2, 48); -- 2 AC 2-tier

-- 25. Mysore Express (TrainID=25)
CALL GenerateSeatsForTrain(25, 1, 'S', 4, 72); -- 4 Sleeper
CALL GenerateSeatsForTrain(25, 6, 'D', 2, 108);-- 2 Second Sitting

-- 26. Vijayawada Express (TrainID=26)
CALL GenerateSeatsForTrain(26, 1, 'S', 5, 72); -- 5 Sleeper
CALL GenerateSeatsForTrain(26, 2, 'A', 1, 72); -- 1 AC 3-tier

-- 27. Dehradun Shatabdi (TrainID=27) - Only Chair Car
CALL GenerateSeatsForTrain(27, 5, 'C', 4, 85); -- 4 AC Chair Cars

-- 28. Rajkot Intercity (TrainID=28)
CALL GenerateSeatsForTrain(28, 6, 'D', 5, 108);-- 5 Second Sitting

-- 29. Gaya Intercity (TrainID=29)
CALL GenerateSeatsForTrain(29, 6, 'D', 4, 108);-- 4 Second Sitting

-- 30. Bhopal Express (TrainID=30)
CALL GenerateSeatsForTrain(30, 1, 'S', 6, 72); -- 6 Sleeper
CALL GenerateSeatsForTrain(30, 2, 'A', 2, 72); -- 2 AC 3-tier


-- Update seat availability for confirmed bookings
DELIMITER //

CREATE PROCEDURE BookTicket(
    IN p_PassengerID INT,
    IN p_TrainID INT,
    IN p_JourneyDate DATE,
    IN p_ClassID INT,
    IN p_FromStationID INT,
    IN p_ToStationID INT,
    IN p_BookingType ENUM('Online', 'Counter'),
    IN p_PaymentMode ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash'),
    OUT p_PNR VARCHAR(10),
    OUT p_Status VARCHAR(20),
    OUT p_Fare DECIMAL(10,2),
    OUT p_CoachNumber VARCHAR(10),
    OUT p_SeatNumber VARCHAR(10)
)
BEGIN
    DECLARE v_AvailableSeatID VARCHAR(20);
    DECLARE v_BaseFare DECIMAL(10,2);
    DECLARE v_Distance DECIMAL(8,2);
    DECLARE v_BookingID INT;
    DECLARE v_PaymentID INT;
    DECLARE v_ConcessionDiscount DECIMAL(5,2);
    
    -- Calculate distance between stations
    SELECT ABS(rs1.DistanceFromOrigin - rs2.DistanceFromOrigin) INTO v_Distance
    FROM RouteStation rs1
    JOIN RouteStation rs2 ON rs1.RouteID = rs2.RouteID
    JOIN Train t ON rs1.RouteID = t.RouteID
    WHERE t.TrainID = p_TrainID 
    AND rs1.StationID = p_FromStationID 
    AND rs2.StationID = p_ToStationID;

    -- Debug: Show calculated distance
    SELECT v_Distance AS 'Debug_Distance';

    -- Get base fare
    SELECT (v_Distance * 0.5 * BaseFareMultiplier) INTO v_BaseFare
    FROM Class 
    WHERE ClassID = p_ClassID;

    -- Debug: Show base fare before discount
    SELECT v_BaseFare AS 'Debug_BaseFare_PreDiscount';

    -- Apply concession if applicable
    SELECT COALESCE(MAX(DiscountPercentage), 0) INTO v_ConcessionDiscount
    FROM PassengerConcession pc
    JOIN Concession c ON pc.ConcessionID = c.ConcessionID
    WHERE pc.PassengerID = p_PassengerID 
    AND p_JourneyDate BETWEEN pc.ValidUntil - INTERVAL 1 YEAR AND pc.ValidUntil;
    
    SET v_BaseFare = v_BaseFare * (1 - (v_ConcessionDiscount / 100));

    -- Debug: Show base fare after discount
    SELECT v_BaseFare AS 'Debug_BaseFare_Final';

    -- Find available seat
    SELECT SeatID, CoachNo, SeatNo INTO v_AvailableSeatID, p_CoachNumber, p_SeatNumber
    FROM Seat
    WHERE TrainID = p_TrainID 
    AND ClassID = p_ClassID
    AND Availability = TRUE
    AND SeatID NOT IN (
        SELECT SeatID 
        FROM Ticket 
        WHERE TrainID = p_TrainID 
        AND JourneyDate = p_JourneyDate 
        AND Status IN ('Confirmed', 'RAC')
    )
    LIMIT 1;
    
    -- Create payment record
    INSERT INTO Payment (Amount, PaymentMode, PaymentDateTime, Status)
    VALUES (v_BaseFare, p_PaymentMode, NOW(), 'Success');
    SET v_PaymentID = LAST_INSERT_ID();
    
    -- Create booking record
    INSERT INTO Booking (PassengerID, BookingDateTime, BookingType, PaymentID)
    VALUES (p_PassengerID, NOW(), p_BookingType, v_PaymentID);
    SET v_BookingID = LAST_INSERT_ID();
    
    -- Generate PNR
    SET p_PNR = CONCAT(SUBSTRING(MD5(RAND()) FROM 1 FOR 6), LPAD(FLOOR(RAND() * 10000), 4, '0'));
    
    -- Determine status
    IF v_AvailableSeatID IS NOT NULL THEN
        SET p_Status = 'Confirmed';
    ELSE
        SET p_Status = 'Waitlist';
        SET v_AvailableSeatID = NULL;
        SET p_CoachNumber = NULL;
        SET p_SeatNumber = NULL;
    END IF;
    
    -- Create ticket record
    INSERT INTO Ticket (PNR, BookingID, TrainID, JourneyDate, ClassID, FromStationID, ToStationID, SeatID, Status, Fare)
    VALUES (p_PNR, v_BookingID, p_TrainID, p_JourneyDate, p_ClassID, p_FromStationID, p_ToStationID, v_AvailableSeatID, p_Status, v_BaseFare);
    
    -- Update seat availability if confirmed
    IF p_Status = 'Confirmed' THEN
        UPDATE Seat SET Availability = FALSE WHERE SeatID = v_AvailableSeatID;
    END IF;
    
    SET p_Fare = v_BaseFare;
END //

DELIMITER ;

-- Use the BookTicket stored procedure
CALL BookTicket(5, 3,'2025-06-15', 2, 6,3,'Online','Credit Card',@pnr, @status, @fare, @coach, @seat);
select * from Ticket;
    
SELECT @pnr AS PNR, @status AS Status, @fare AS Fare, @coach AS Coach, @seat AS Seat;
-- pnr status tracking
SELECT 
    t.PNR,
    p.Name AS Passenger,
    tr.TrainName,
    t.JourneyDate,
    s1.StationName AS FromStation,
    s2.StationName AS ToStation,
    c.ClassName,
    t.SeatID,
    t.Status,
    t.Fare
FROM 
    Ticket t
JOIN Booking b ON t.BookingID = b.BookingID
JOIN Passenger p ON b.PassengerID = p.PassengerID
JOIN Train tr ON t.TrainID = tr.TrainID
JOIN Station s1 ON t.FromStationID = s1.StationID
JOIN Station s2 ON t.ToStationID = s2.StationID
JOIN Class c ON t.ClassID = c.ClassID
WHERE 
    t.PNR = 'PNR12345'; 
    
-- train Schedule lookup
SELECT 
    s.StationName,
    rs.ArrivalTime,
    rs.DepartureTime,
    rs.DistanceFromOrigin
FROM 
    RouteStation rs
JOIN Station s ON rs.StationID = s.StationID
JOIN Route r ON rs.RouteID = r.RouteID
JOIN Train t ON r.RouteID = t.RouteID
WHERE 
    t.TrainID = 3
ORDER BY 
    rs.SequenceNo;
    
-- available seats query
SELECT 
    s.SeatID,
    s.CoachNo,
    s.SeatNo
FROM 
    Seat s
WHERE 
    s.TrainID = 3 
    AND s.ClassID = 2
    AND s.Availability = TRUE
    AND NOT EXISTS (
        SELECT 1 FROM Ticket t 
        WHERE t.TrainID = 3 
        AND t.JourneyDate = '2025-06-15' 
        AND t.ClassID = 2 
        AND t.SeatID = s.SeatID
        AND t.Status IN ('Confirmed', 'RAC')
    );
    
-- List Passengers on a Train
SELECT 
    p.Name,
    p.Age,
    p.Gender,
    t.PNR,
    c.ClassName,
    t.SeatID,
    t.Status
FROM 
    Ticket t
JOIN Booking b ON t.BookingID = b.BookingID
JOIN Passenger p ON b.PassengerID = p.PassengerID
JOIN Class c ON t.ClassID = c.ClassID
WHERE 
    t.TrainID = 3 
    AND t.JourneyDate = '2025-06-15'
ORDER BY 
    t.Status, t.SeatID;
    
-- Waitlisted Passengers
SELECT 
    p.Name,
    p.ContactNo,
    t.PNR,
    t.JourneyDate,
    b.BookingDateTime
FROM 
    Ticket t
JOIN Booking b ON t.BookingID = b.BookingID
JOIN Passenger p ON b.PassengerID = p.PassengerID
WHERE 
    t.TrainID = 3 
    AND t.Status = 'Waitlist'
ORDER BY 
    b.BookingDateTime;
    
-- Total Refund for Cancelling a Train
SELECT 
    SUM(t.Fare * 
        CASE 
            WHEN DATEDIFF(t.JourneyDate, CURDATE()) > 30 THEN 0.75
            WHEN DATEDIFF(t.JourneyDate, CURDATE()) > 15 THEN 0.50
            WHEN DATEDIFF(t.JourneyDate, CURDATE()) > 1 THEN 0.25
            ELSE 0
        END) AS TotalRefundAmount
FROM 
    Ticket t
WHERE 
    t.TrainID = 3 
    AND t.JourneyDate = '2025-06-15'
    AND t.Status IN ('Confirmed', 'RAC');
    
-- Revenue Report
SELECT 
    DATE(b.BookingDateTime) AS BookingDate,
    COUNT(*) AS TicketsSold,
    SUM(p.Amount) AS TotalRevenue
FROM 
    Booking b
JOIN Payment p ON b.PaymentID = p.PaymentID
JOIN Ticket t ON b.BookingID = t.BookingID
WHERE 
    b.BookingDateTime BETWEEN '2025-03-01' AND '2025-04-30'
    AND p.Status = 'Success'
    AND t.Status != 'Cancelled'
GROUP BY 
    DATE(b.BookingDateTime)
ORDER BY 
    BookingDate;
    
-- Cancellation Records
SELECT 
    t.PNR,
    p.Name AS Passenger,
    tr.TrainName,
    t.JourneyDate,
    c.CancellationDateTime,
    c.RefundAmount,
    c.RefundStatus
FROM 
    Cancellation c
JOIN Ticket t ON c.PNR = t.PNR
JOIN Booking b ON t.BookingID = b.BookingID
JOIN Passenger p ON b.PassengerID = p.PassengerID
JOIN Train tr ON t.TrainID = tr.TrainID
ORDER BY 
    c.CancellationDateTime DESC;
    
-- Busiest Route
SELECT 
    r.RouteName,
    s1.StationName AS Origin,
    s2.StationName AS Destination,
    COUNT(*) AS PassengerCount
FROM 
    Ticket t
JOIN Train tr ON t.TrainID = tr.TrainID
JOIN Route r ON tr.RouteID = r.RouteID
JOIN Station s1 ON r.OriginStationID = s1.StationID
JOIN Station s2 ON r.DestinationStationID = s2.StationID
WHERE 
    t.JourneyDate BETWEEN '2025-04-01' AND '2025-04-30'
    AND t.Status IN ('Confirmed', 'RAC')
GROUP BY 
    r.RouteID
ORDER BY 
    PassengerCount DESC
LIMIT 5;

-- Itemized Ticket Bill
SELECT 
    t.PNR,
    p.Name AS Passenger,
    tr.TrainName,
    t.JourneyDate,
    s1.StationName AS FromStation,
    s2.StationName AS ToStation,
    c.ClassName,
    t.Fare AS BaseFare,
    CASE 
        WHEN pc.ConcessionID IS NOT NULL THEN t.Fare * (cn.DiscountPercentage/100)
        ELSE 0
    END AS ConcessionDiscount,
    t.Fare - CASE 
        WHEN pc.ConcessionID IS NOT NULL THEN t.Fare * (cn.DiscountPercentage/100)
        ELSE 0
    END AS NetFare,
    py.PaymentMode,
    py.PaymentDateTime
FROM 
    Ticket t
JOIN Booking b ON t.BookingID = b.BookingID
JOIN Passenger p ON b.PassengerID = p.PassengerID
JOIN Train tr ON t.TrainID = tr.TrainID
JOIN Station s1 ON t.FromStationID = s1.StationID
JOIN Station s2 ON t.ToStationID = s2.StationID
JOIN Class c ON t.ClassID = c.ClassID
JOIN Payment py ON b.PaymentID = py.PaymentID
LEFT JOIN PassengerConcession pc ON p.PassengerID = pc.PassengerID 
    AND t.JourneyDate BETWEEN pc.ValidUntil - INTERVAL 1 YEAR AND pc.ValidUntil
LEFT JOIN Concession cn ON pc.ConcessionID = cn.ConcessionID
WHERE 
    t.PNR = 'PNR12345';
    
-- Apply concession to a passenger
INSERT INTO PassengerConcession (PassengerID, ConcessionID, ValidUntil)
VALUES (5, 1, '2025-12-31'); -- Senior Citizen Male

-- Check valid concessions for a passenger
SELECT 
    p.Name,
    c.ConcessionType,
    c.DiscountPercentage,
    pc.ValidUntil
FROM 
    PassengerConcession pc
JOIN Passenger p ON pc.PassengerID = p.PassengerID
JOIN Concession c ON pc.ConcessionID = c.ConcessionID
WHERE 
    p.PassengerID = 5
    AND CURDATE() <= pc.ValidUntil;
    
-- Payment Mode Success Rate Analysis
SELECT 
    PaymentMode,
    COUNT(*) AS TotalAttempts,
    SUM(CASE WHEN Status = 'Success' THEN 1 ELSE 0 END) AS SuccessfulPayments,
    ROUND((SUM(CASE WHEN Status = 'Success' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2) AS SuccessRate
FROM 
    Payment
GROUP BY 
    PaymentMode
ORDER BY 
    SuccessRate DESC;
    
-- Top 5 Passengers with Most Concession Discounts
SELECT 
    p.PassengerID,
    p.Name,
    COUNT(pc.ConcessionID) AS ConcessionsAvailed,
    SUM(t.Fare * (cn.DiscountPercentage/100)) AS TotalDiscountAvailed
FROM 
    Passenger p
JOIN PassengerConcession pc ON p.PassengerID = pc.PassengerID
JOIN Concession cn ON pc.ConcessionID = cn.ConcessionID
JOIN Booking b ON p.PassengerID = b.PassengerID
JOIN Ticket t ON b.BookingID = t.BookingID
WHERE 
    t.JourneyDate BETWEEN pc.ValidUntil - INTERVAL 1 YEAR AND pc.ValidUntil
GROUP BY 
    p.PassengerID, p.Name
ORDER BY 
    TotalDiscountAvailed DESC
LIMIT 5;

