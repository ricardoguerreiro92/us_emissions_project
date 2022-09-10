-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.


CREATE TABLE "PopulationByState" (
    "State" string   NOT NULL,
    "Year" int   NOT NULL,
    "Population" int   NOT NULL,
    CONSTRAINT "pk_PopulationByState" PRIMARY KEY (
        "State"
     )
);

CREATE TABLE "GDPByState" (
    "State" string   NOT NULL,
    "Year" int   NOT NULL,
    "GDP" int   NOT NULL,
    CONSTRAINT "pk_GDPByState" PRIMARY KEY (
        "Year"
     )
);

CREATE TABLE "GHGEmissionsByState" (
    "State" string   NOT NULL,
    "Sector" string   NOT NULL,
    "Year" int   NOT NULL,
    "GHG" int   NOT NULL,
    CONSTRAINT "pk_GHGEmissionsByState" PRIMARY KEY (
        "Sector"
     )
);

CREATE TABLE "GHGEmissionsByStateBySector" (
    "State" string   NOT NULL,
    "Sector" string   NOT NULL,
    "Year" int   NOT NULL,
    "GHG" int   NOT NULL
);

ALTER TABLE "PopulationByState" ADD CONSTRAINT "fk_PopulationByState_Year" FOREIGN KEY("Year")
REFERENCES "GDPByState" ("Year");

ALTER TABLE "GDPByState" ADD CONSTRAINT "fk_GDPByState_State" FOREIGN KEY("State")
REFERENCES "PopulationByState" ("State");

ALTER TABLE "GHGEmissionsByState" ADD CONSTRAINT "fk_GHGEmissionsByState_State" FOREIGN KEY("State")
REFERENCES "PopulationByState" ("State");

ALTER TABLE "GHGEmissionsByState" ADD CONSTRAINT "fk_GHGEmissionsByState_Year" FOREIGN KEY("Year")
REFERENCES "GDPByState" ("Year");

ALTER TABLE "GHGEmissionsByStateBySector" ADD CONSTRAINT "fk_GHGEmissionsByStateBySector_State" FOREIGN KEY("State")
REFERENCES "PopulationByState" ("State");

ALTER TABLE "GHGEmissionsByStateBySector" ADD CONSTRAINT "fk_GHGEmissionsByStateBySector_Sector" FOREIGN KEY("Sector")
REFERENCES "GHGEmissionsByState" ("Sector");

ALTER TABLE "GHGEmissionsByStateBySector" ADD CONSTRAINT "fk_GHGEmissionsByStateBySector_Year" FOREIGN KEY("Year")
REFERENCES "GDPByState" ("Year");


-- rename column All GHG to allghg on different tables

ALTER TABLE sector_emissions 
RENAME COLUMN "All GHG" TO "allghg";

ALTER TABLE state_emissions 
RENAME COLUMN "All GHG" TO "allghg";


-- Create per_capita table
SELECT se."State", sp."Year", sp."Population",
	sg."GDP"/sp."Population" as gdp_per_capita, 
	se.allghg/sp."Population" as ghg_per_capita
INTO per_capita
FROM state_gdp sg
JOIN state_pop sp
	ON sg."StateFull" = sp."StateFull" AND sg."Year" = sp."Year"
JOIN state_emissions se
	ON sg."State" = se."State" AND sg."Year"=se."Year"
ORDER BY "State", "Year" ASC;

--Update from metric tons to pounds on ghg per_capita table
UPDATE per_capita SET ghg_per_capita=ghg_per_capita*2204.62;



--round gdp_per_capita and ghg_per_capita
UPDATE per_capita SET ghg_per_capita= ROUND(ghg_per_capita::numeric, 4);
UPDATE per_capita SET gdp_per_capita=ROUND(gdp_per_capita::numeric, 2);