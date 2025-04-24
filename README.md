
# Railway Ticket Reservation System - README

## Overview
This project implements a comprehensive Railway Ticket Reservation System using MySQL. The system manages passenger information, train schedules, seat availability, ticket booking, cancellations, and various reporting functions.

## Database Schema
The database consists of the following main tables:
- **Passenger**: Stores passenger details
- **Train**: Contains train information
- **Route**: Defines train routes and stations
- **Class**: Different travel classes with fare multipliers
- **Seat**: Seat inventory management
- **Ticket**: Ticket booking records
- **Payment**: Payment transaction details
- **Cancellation**: Cancellation and refund records

## Key Features

### Booking Management
- Ticket booking with automatic PNR generation
- Seat allocation based on availability
- Fare calculation considering distance and concessions
- Multiple payment methods support

### Status Tracking
- PNR status lookup
- Waitlist position tracking
- Automatic RAC to Confirmed upgrades
- Waitlist to RAC movement

### Reporting
- Revenue analysis by period/train type
- Occupancy and utilization reports
- Cancellation and refund tracking
- Popular route analysis

## Installation

1. **Prerequisites**:
   - MySQL Server 8.0+
   - MySQL Workbench (recommended)

2. **Setup**:
   ```bash
   mysql -u root -p < database_schema.sql
   ```

3. **Sample Data**:
   ```bash
   mysql -u root -p < sample_data.sql
   ```

## Usage

### Basic Operations

**Book a Ticket**:
```sql
CALL BookTicket(
    passenger_id, 
    train_id, 
    journey_date, 
    class_id, 
    from_station_id, 
    to_station_id, 
    booking_type, 
    payment_mode, 
    @pnr, 
    @status, 
    @fare, 
    @coach, 
    @seat
);
SELECT @pnr, @status, @fare, @coach, @seat;
```

**Cancel a Ticket**:
```sql
CALL CancelTicket('ABC1234567', @refund, @status);
SELECT @refund, @status;
```

**Check PNR Status**:
```sql
SELECT * FROM v_pnr_status WHERE PNR = 'ABC1234567';
```

## Views

1. **v_pnr_status**: Shows complete ticket details for a PNR
2. **v_train_schedule**: Displays complete schedule for a train
3. **v_seat_availability**: Shows available seats by train/date/class
4. **v_revenue_report**: Daily/monthly revenue summary

## Stored Procedures

1. **BookTicket**: Handles complete ticket booking process
2. **CancelTicket**: Manages ticket cancellation and refunds
3. **GenerateSeatsForTrain**: Initializes seat inventory for new trains
4. **UpgradeWaitlist**: Automatically upgrades waitlisted tickets

## Functions

1. **CalculateTicketFare**: Computes fare based on distance and class
2. **CheckSeatAvailability**: Returns available seat count
3. **GetWaitlistPosition**: Shows passenger's waitlist position

## API Endpoints (Conceptual)

```
GET    /api/trains               - List all trains
GET    /api/trains/{id}/schedule - Train schedule
POST   /api/bookings             - Create new booking
GET    /api/bookings/{pnr}       - Booking details
DELETE /api/bookings/{pnr}       - Cancel booking
GET    /api/reports/revenue      - Revenue report
```

## License
This project is licensed under the MIT License.
