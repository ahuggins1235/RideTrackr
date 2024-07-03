BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Rides" (
	"id"	TEXT,
	"heartRate"	NUMERIC,
	"speed"	NUMERIC,
	"distance"	NUMERIC,
	"activeEnergy"	NUMERIC,
	"altitudeGained"	NUMERIC,
	"rideDate"	TEXT,
	"duration"	NUMERIC,
	"temperature"	NUMERIC,
	"routeData"	BLOB,
	"hrSamples"	BLOB,
	"altitdueSamples"	BLOB,
	"speedSamples"	BLOB,
	PRIMARY KEY("id")
);
INSERT INTO "Rides" VALUES (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
COMMIT;
