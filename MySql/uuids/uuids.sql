-- This SQL script add support for UUID v4 integration in string form.
-- it means that UUID will be stored in a 36 length CHAR.

-- You must run all SQL scripts in MySQL/ before running this file.


LOCK TABLES `provincias` WRITE, `municipios` WRITE, `sectores` WRITE;

-- Add UUID columns as strings
ALTER TABLE `municipios`
  ADD COLUMN `municipio_uuid` CHAR(36) NOT NULL AFTER `municipio_id`,
  ADD COLUMN `provincia_uuid` CHAR(36) NOT NULL AFTER `municipio_uuid`;

ALTER TABLE `provincias`
  ADD COLUMN `provincia_uuid` CHAR(36) NOT NULL AFTER `provincia_id`;

ALTER TABLE `sectores`
  ADD COLUMN `sector_uuid` CHAR(36) NOT NULL AFTER `sector_id`,
  ADD COLUMN `municipio_uuid` CHAR(36) NOT NULL AFTER `sector_uuid`;

-- Generate UUID values and migrate data

-- Uncomment to disable safe updates
-- SET SQL_SAFE_UPDATES = 0;

UPDATE `provincias`
SET `provincia_uuid` = UUID();

UPDATE `municipios`
SET `municipio_uuid` = UUID(),
    `provincia_uuid` = (SELECT `provincia_uuid` FROM `provincias` WHERE `provincia_id` = `municipios`.`provincia_id`);

UPDATE `sectores`
SET `sector_uuid` = UUID(),
    `municipio_uuid` = (SELECT `municipio_uuid` FROM `municipios` WHERE `municipio_id` = `sectores`.`municipio_id`);

-- Drop old foreign keys
ALTER TABLE `municipios`
  DROP FOREIGN KEY `provincia_id`,
  DROP COLUMN `provincia_id`;

ALTER TABLE `sectores`
  DROP FOREIGN KEY `ciudad_ir`,
  DROP COLUMN `municipio_id`;

-- Add new primary keys
ALTER TABLE `provincias`
  DROP PRIMARY KEY,
  DROP COLUMN `provincia_id`,
  ADD PRIMARY KEY (`provincia_uuid`);

ALTER TABLE `municipios`
  DROP PRIMARY KEY,
  DROP COLUMN `municipio_id`,
  ADD PRIMARY KEY (`municipio_uuid`);

ALTER TABLE `sectores`
  DROP PRIMARY KEY,
  DROP COLUMN `sector_id`,
  ADD PRIMARY KEY (`sector_uuid`);

-- Add new foreign keys
ALTER TABLE `municipios`
  ADD CONSTRAINT `provincia_uuid` FOREIGN KEY (`provincia_uuid`) REFERENCES `provincias` (`provincia_uuid`) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `sectores`
  ADD CONSTRAINT `ciudad_uuid` FOREIGN KEY (`municipio_uuid`) REFERENCES `municipios` (`municipio_uuid`) ON DELETE NO ACTION ON UPDATE NO ACTION;

UNLOCK TABLES;