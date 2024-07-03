BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Rides" (
	"id"	TEXT,
	"heartRate"	NUMERIC,
	"speed"	NUMERIC,
	"distance"	NUMERIC,
	"altitudeGained"	NUMERIC,
	"rideDate"	TEXT,
	"duration"	NUMERIC,
	"temperature"	NUMERIC,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "Locations" (
	"id"	TEXT,
	"latitude"	NUMERIC,
	"longitude"	NUMERIC,
	"timeStamp"	TEXT,
	"Ride_ID"	TEXT,
	PRIMARY KEY("id"),
	FOREIGN KEY("Ride_ID") REFERENCES "Rides"("id")
);
CREATE TABLE IF NOT EXISTS "hrSamples" (
	"id"	TEXT,
	"date"	TEXT,
	"min"	NUMERIC,
	"max"	NUMERIC,
	"Ride_Id"	TEXT,
	PRIMARY KEY("id"),
	FOREIGN KEY("Ride_Id") REFERENCES "Rides"("id")
);
CREATE TABLE IF NOT EXISTS "altSamples" (
	"id"	TEXT,
	"date"	TEXT,
	"min"	NUMERIC,
	"max"	NUMERIC,
	"Ride_Id"	TEXT,
	PRIMARY KEY("id"),
	FOREIGN KEY("Ride_Id") REFERENCES "Locations"("id")
);
CREATE TABLE IF NOT EXISTS "spdSamples" (
	"id"	TEXT,
	"date"	TEXT,
	"min"	NUMERIC,
	"max"	NUMERIC,
	"Ride_Id"	TEXT,
	PRIMARY KEY("id")
);
COMMIT;
