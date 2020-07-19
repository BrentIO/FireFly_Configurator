/* This script must be run from the local server, not through MySQL Workbench. */

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema firefly
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `firefly` ;

-- -----------------------------------------------------
-- Schema firefly
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `firefly` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `firefly` ;

-- -----------------------------------------------------
-- Table `firefly`.`buttonColors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`buttonColors` ;

CREATE TABLE IF NOT EXISTS `firefly`.`buttonColors` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `friendlyName` VARCHAR(20) NOT NULL,
  `hexValue` CHAR(6) NOT NULL,
  `brightnessMinimum` TINYINT NOT NULL DEFAULT '0',
  `brightnessMaximum` TINYINT NOT NULL DEFAULT '100',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `friendlyName_UNIQUE` (`friendlyName` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`switches`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`switches` ;

CREATE TABLE IF NOT EXISTS `firefly`.`switches` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `controllerId` INT NULL DEFAULT NULL,
  `controllerPort` INT NULL DEFAULT NULL,
  `macAddress` BIGINT UNSIGNED NULL DEFAULT NULL,
  `hwVersion` TINYINT(1) NOT NULL,
  `firmwareId` INT NULL DEFAULT NULL,
  `friendlyName` VARCHAR(20) NOT NULL,
  `mqttUsername` VARCHAR(20) NULL DEFAULT NULL,
  `mqttPassword` VARCHAR(255) NULL DEFAULT NULL,
  `bootstrapURL` VARCHAR(255) NULL DEFAULT NULL,
  `bootstrapCounter` INT NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `macAddress_UNIQUE` (`macAddress` ASC) VISIBLE,
  INDEX `controllerId_idx` (`controllerId` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`inputs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`inputs` ;

CREATE TABLE IF NOT EXISTS `firefly`.`inputs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `switchId` INT NOT NULL,
  `position` TINYINT UNSIGNED NOT NULL,
  `pin` TINYINT UNSIGNED NULL DEFAULT NULL,
  `colorId` INT NOT NULL,
  `circuitType` ENUM('NORMALLY_OPEN', 'NORMALLY_CLOSED') NOT NULL,
  `friendlyName` VARCHAR(20) NOT NULL,
  `broadcastOnChange` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  `enabled` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  INDEX `switchId_idx` (`switchId` ASC) VISIBLE,
  INDEX `colorId_idx` (`colorId` ASC) VISIBLE,
  CONSTRAINT `colorId`
    FOREIGN KEY (`colorId`)
    REFERENCES `firefly`.`buttonColors` (`id`),
  CONSTRAINT `switchId`
    FOREIGN KEY (`switchId`)
    REFERENCES `firefly`.`switches` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`controllers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`controllers` ;

CREATE TABLE IF NOT EXISTS `firefly`.`controllers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `macAddress` BIGINT UNSIGNED NOT NULL,
  `friendlyName` VARCHAR(20) NOT NULL,
  `ipAddress` INT UNSIGNED NOT NULL,
  `subnet` INT UNSIGNED NOT NULL,
  `dns` INT UNSIGNED NOT NULL,
  `gateway` INT UNSIGNED NOT NULL,
  `mqttUsername` VARCHAR(20) NULL DEFAULT NULL,
  `mqttPassword` VARCHAR(255) NULL DEFAULT NULL,
  `hwVersion` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `macAddress_UNIQUE` (`macAddress` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`outputs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`outputs` ;

CREATE TABLE IF NOT EXISTS `firefly`.`outputs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `controllerId` INT NULL DEFAULT NULL,
  `controllerPort` TINYINT UNSIGNED NULL DEFAULT NULL,
  `pin` TINYINT UNSIGNED NULL DEFAULT NULL,
  `friendlyName` VARCHAR(20) NULL DEFAULT NULL,
  `outputType` ENUM('BINARY', 'VARIABLE') NULL DEFAULT NULL,
  `enabled` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  `amperage` TINYINT UNSIGNED NULL DEFAULT '0',
  `breakerId` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `uniqueRow` (`controllerId` ASC, `controllerPort` ASC, `pin` ASC, `friendlyName` ASC) VISIBLE,
  INDEX `controllerId_idx` (`controllerId` ASC) VISIBLE,
  CONSTRAINT `controllerId`
    FOREIGN KEY (`controllerId`)
    REFERENCES `firefly`.`controllers` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`actions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`actions` ;

CREATE TABLE IF NOT EXISTS `firefly`.`actions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `inputId` INT NULL DEFAULT NULL,
  `outputId` INT NULL DEFAULT NULL,
  `actionType` ENUM('INCREASE', 'DECREASE', 'TOGGLE') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `unique` (`inputId` ASC, `outputId` ASC) VISIBLE,
  INDEX `buttonId_idx` (`inputId` ASC) VISIBLE,
  INDEX `outputId_idx` (`outputId` ASC) VISIBLE,
  CONSTRAINT `buttonId`
    FOREIGN KEY (`inputId`)
    REFERENCES `firefly`.`inputs` (`id`),
  CONSTRAINT `outputId`
    FOREIGN KEY (`outputId`)
    REFERENCES `firefly`.`outputs` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`breakers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`breakers` ;

CREATE TABLE IF NOT EXISTS `firefly`.`breakers` (
  `id` INT NOT NULL,
  `friendlyName` VARCHAR(20) NOT NULL,
  `amperage` TINYINT UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `friendlyName_UNIQUE` (`friendlyName` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`brightnessNames`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`brightnessNames` ;

CREATE TABLE IF NOT EXISTS `firefly`.`brightnessNames` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `friendlyName` VARCHAR(20) NOT NULL,
  `brightnessValue` TINYINT NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `friendlyName_UNIQUE` (`friendlyName` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`controllerPins`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`controllerPins` ;

CREATE TABLE IF NOT EXISTS `firefly`.`controllerPins` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `hwVersion` TINYINT UNSIGNED NOT NULL,
  `pin` TINYINT UNSIGNED NOT NULL,
  `inputAllowed` TINYINT UNSIGNED NOT NULL DEFAULT '0',
  `binaryOutputAllowed` TINYINT UNSIGNED NOT NULL DEFAULT '0',
  `variableOutputAllowed` TINYINT UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `hwVersionPinUnique` (`hwVersion` ASC, `pin` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`controllerPorts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`controllerPorts` ;

CREATE TABLE IF NOT EXISTS `firefly`.`controllerPorts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `hwVersion` TINYINT UNSIGNED NOT NULL,
  `port` TINYINT UNSIGNED NOT NULL,
  `inputAllowed` TINYINT UNSIGNED NOT NULL DEFAULT '0',
  `outputAllowed` TINYINT UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `unique` (`hwVersion` ASC, `port` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`firmware`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`firmware` ;

CREATE TABLE IF NOT EXISTS `firefly`.`firmware` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `deviceType` ENUM('CONTROLLER', 'CLIENT') NOT NULL,
  `version` INT NOT NULL,
  `url` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `version_UNIQUE` (`version` ASC) VISIBLE,
  UNIQUE INDEX `unique` (`deviceType` ASC, `version` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `firefly`.`settings`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`settings` ;

CREATE TABLE IF NOT EXISTS `firefly`.`settings` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `settingName` VARCHAR(20) NOT NULL,
  `settingValue` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  UNIQUE INDEX `settingName_UNIQUE` (`settingName` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `firefly` ;

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getActionsJson`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getActionsJson` (`json` INT, `inputId` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getBreakers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getBreakers` (`id` INT, `friendlyName` INT, `amperage` INT, `json` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getColorBrightnessNames`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getColorBrightnessNames` (`colorId` INT, `brightnessNames` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getControllerPinsUnused`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getControllerPinsUnused` (`controllerId` INT, `pin` INT, `inputAllowed` INT, `binaryOutputAllowed` INT, `variableOutputAllowed` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getControllerPinsUsed`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getControllerPinsUsed` (`controllerId` INT, `switchId` INT, `pin` INT, `pinType` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getControllerPortsUnused`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getControllerPortsUnused` (`controllerId` INT, `port` INT, `inputAllowed` INT, `outputAllowed` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getControllerPortsUsed`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getControllerPortsUsed` (`controllerId` INT, `id` INT, `port` INT, `portType` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getControllers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getControllers` (`id` INT, `macAddress` INT, `friendlyName` INT, `ipAddress` INT, `subnet` INT, `dns` INT, `gateway` INT, `json` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getInputs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getInputs` (`controllerId` INT, `name` INT, `pin` INT, `circuitType` INT, `broadcastOnStateChange` INT, `enabled` INT, `outputs` INT, `json` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getOutputs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getOutputs` (`outputId` INT, `controllerId` INT, `outputName` INT, `outputType` INT, `pin` INT, `controllerPort` INT, `position` INT, `enabled` INT, `amperage` INT, `breakerId` INT, `json` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getSwitchButtons`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getSwitchButtons` (`switchId` INT, `json` INT);

-- -----------------------------------------------------
-- Placeholder table for view `firefly`.`getSwitches`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `firefly`.`getSwitches` (`switchId` INT, `macAddress` INT, `deviceName` INT, `firmwareVersion` INT, `firmwareURL` INT, `bootstrapVersion` INT, `switchName` INT, `json` INT);

-- -----------------------------------------------------
-- function adjustBrightnessLevels
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`adjustBrightnessLevels`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `adjustBrightnessLevels`(colorMinimum int, colorMaximum int, brightnessLevel int) RETURNS int
    DETERMINISTIC
BEGIN


IF brightnessLevel = 0 THEN

	RETURN brightnessLevel;

END IF;

IF brightnessLevel BETWEEN colorMinimum AND colorMaximum THEN

	
	RETURN brightnessLevel;

END IF;

IF brightnessLevel < colorMinimum THEN

	
	RETURN colorMinimum;
    
END IF;

IF brightnessLevel > colorMaximum THEN

	
	RETURN colorMaximum;
    
END IF;


RETURN brightnessLevel;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteBreaker
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteBreaker`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteBreaker`(IN _id int)
BEGIN

DECLARE breakerCount int;

SELECT 
    COUNT(*)
INTO breakerCount FROM
    outputs
WHERE
    breakerId = _id;

IF breakerCount > 0 THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or more outputs are using this breaker.';

END IF;

DELETE FROM breakers 
WHERE
    id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteBrightnessName
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteBrightnessName`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteBrightnessName`(IN _id int)
BEGIN

DELETE FROM brightnessNames WHERE id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteButtonColor
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteButtonColor`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteButtonColor`(IN _id int)
BEGIN

DECLARE buttonCount int;

SELECT 
    COUNT(*)
INTO buttonCount FROM
    buttons
WHERE
    colorId = _id;

IF buttonCount > 0 THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or more buttons are using this color.';

END IF;

DELETE FROM buttonColors 
WHERE
    id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteController
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteController`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteController`(
IN _id int
)
BEGIN

DECLARE switchCount, outputCount int;

SELECT 
    COUNT(*)
INTO switchCount FROM
    switches
WHERE
    controllerId = _id;

SELECT 
    COUNT(*)
INTO outputCount FROM
    outputs
WHERE
    controllerId = _id;

IF switchCount + outputCount > 0 THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or more switches or outputs are using this controller.';

END IF;

DELETE FROM controllers 
WHERE
    id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteControllerPins
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteControllerPins`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteControllerPins`(IN _hwVersion tinyint, IN _pin tinyint)
BEGIN

DECLARE inputCount int;
DECLARE outputCount int;
DECLARE _id int;


SELECT 
    id
INTO _id FROM
    controllerPins
WHERE
    hwVersion = _hwVersion AND pin = _pin;

IF _id is null THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid hwVersion or pin.';

END IF;

SELECT 
    COUNT(*)
INTO inputCount FROM
    firefly.switches
        INNER JOIN
    controllers ON switches.controllerId = controllers.id
        INNER JOIN
    inputs ON inputs.switchId = switches.id
        INNER JOIN
    controllerPins ON controllerPins.hwVersion = controllers.hwVersion
        AND controllerPins.pin = inputs.pin
WHERE
    controllerPins.id = _id;

SELECT 
    COUNT(*)
INTO outputCount FROM
    outputs
        INNER JOIN
    controllers ON outputs.controllerId = controllers.id
        INNER JOIN
    controllerPins ON controllers.hwVersion = controllerPins.hwVersion
        AND outputs.pin = controllerPins.pin
WHERE
    controllerPins.id = _id;
        

IF inputCount > 0 THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or more inputs are using this pin.';

END IF;

IF outputCount > 0 THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or more outputs are using this pin.';

END IF;


DELETE FROM controllerPins 
WHERE
    id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteInput
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteInput`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteInput`(IN _id int)
BEGIN



DECLARE actionsCount int;

SELECT 
    COUNT(*)
INTO actionsCount FROM
    actions
WHERE
    inputId = _id;

IF actionsCount > 0 THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or more actions are using this input.';

END IF;

DELETE FROM inputs where id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteOutput
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteOutput`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteOutput`(IN _id int)
BEGIN



DECLARE actionsCount int;

SELECT 
    COUNT(*)
INTO actionsCount FROM
    actions
WHERE
    outputId = _id;

IF actionsCount > 0 THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or more actions are using this output.';

END IF;

DELETE FROM outputs where id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteSetting
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteSetting`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteSetting`(IN _id int)
BEGIN



DELETE FROM settings where id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteSwitch
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`deleteSwitch`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `deleteSwitch`(IN _id int)
BEGIN

DECLARE buttonCount int;

SELECT 
    COUNT(*)
INTO buttonCount FROM
    buttons
WHERE
    switchId = _id;

IF buttonCount > 0 THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or more buttons or outputs are using this switch.';

END IF;

DELETE FROM switches 
WHERE
    id = _id;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editAction
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editAction`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editAction`(IN _id int, IN _inputId int, IN _outputId int, _actionType ENUM('INCREASE','DECREASE','TOGGLE'), OUT id_ int)
BEGIN



DECLARE inputControllerId int;
DECLARE outputControllerId int;
DECLARE _outputType varchar(25);

SELECT 
    switches.controllerId
INTO inputControllerId FROM
    switches
        INNER JOIN
    inputs ON inputs.switchId = switches.id
WHERE
    inputs.id = _inputId;

SELECT 
    controllerId, outputType
INTO outputControllerId , _outputType FROM
    outputs
WHERE
    outputs.id = _outputId;

IF inputControllerId is null THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No controller found for input.';

END IF;

IF outputControllerId is null THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No controller found for output.';

END IF;

IF inputControllerId <> outputControllerId is null THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Input and output are not on the same controller.';

END IF;


IF (_actionType IN ('INCREASE', 'DECREASE') AND _outputType = 'BINARY') OR (_actionType IN ('TOGGLE') AND _outputType = 'VARIABLE') THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The action type is not valid for the output type.';

END IF;


INSERT INTO actions (id, inputId, outputId, actionType)
VALUES (_id, _inputId, _outputId, _actionType)
ON DUPLICATE KEY UPDATE
	actionType = _actionType;

SELECT 
    id
INTO id_ FROM
    actions
WHERE
    inputId = _inputId
        AND outputId = _outputId;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editBreaker
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editBreaker`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editBreaker`(IN _id int,
IN _friendlyName varchar(20),
IN _amperage tinyint,
OUT id_ INT)
BEGIN

SET _friendlyName = TRIM(_friendlyName);

INSERT INTO breakers (id, friendlyName, amperage)
VALUES (_id, _friendlyName, IFNULL(_amperage, 0))
ON DUPLICATE KEY UPDATE
	friendlyName = _friendlyName,
	amperage = IFNULL(_amperage, 0);

SELECT 
    id
INTO id_ FROM
    breakers
WHERE
    friendlyName = _friendlyName;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editBrightnessName
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editBrightnessName`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editBrightnessName`(IN _id int,
IN _name varchar(20),
IN _brightness tinyint,
OUT id_ int)
BEGIN




SET _name = UPPER(trim(_name));


IF _brightness < 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Brightness must be >=0.';
END IF;

IF _brightness > 100 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Brightness must be <=100.';
END IF;

INSERT INTO brightnessNames
	(id, friendlyName, brightnessValue)
VALUES
	(_id, _name, _brightness)
ON DUPLICATE KEY UPDATE
	friendlyName = _name,
	brightnessValue = _brightness;

SELECT 
    id
INTO id_ FROM
    brightnessNames
WHERE
    friendlyName = _name;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editButtonColor
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editButtonColor`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editButtonColor`(IN _id int,
IN _color varchar(20),
IN _hexValue char(7),
IN _brightnessMinimum tinyint,
IN _brightnessMaximum tinyint,
OUT id_ int)
BEGIN




SET _color = UPPER(trim(_color));
SET _hexValue = UPPER(TRIM(REPLACE(_hexValue, '#','')));


IF _brightnessMinimum < 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Minimum brightness must be >=0.';
END IF;

IF _brightnessMinimum > 100 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Minimum brightness must be <=100.';
END IF;

IF _brightnessMaximum < 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximum brightness must be >=0.';
END IF;

IF _brightnessMaximum > 100 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximum brightness must be <=100.';
END IF;

IF _brightnessMinimum > _brightnessMaximum THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Minimum brightness must be less than maximum brightness.';
END IF;

INSERT INTO buttonColors
	(id, friendlyName, hexValue, brightnessMinimum, brightnessMaximum)
VALUES
	(_id, _color, _hexValue, _brightnessMinimum, _brightnessMaximum)
ON DUPLICATE KEY UPDATE
	friendlyName = _color,
    hexValue = _hexValue,
	brightnessMinimum = _brightnessMinimum,
	brightnessMaximum = _brightnessMaximum;

SELECT 
    id
INTO id_ FROM
    buttonColors
WHERE
    friendlyName = _color;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editController
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editController`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editController`(
IN _id int,
IN _macAddress varchar(17),
IN _name varchar(20),
IN _ipAddress varchar(15),
IN _subnet varchar(15),
IN _dns varchar(15),
IN _gateway varchar(15),
IN _mqttUsername varchar(20),
IN _mqttPassword varchar(255),
IN _hwVersion tinyint(1),
OUT id_ int
)
BEGIN


SET _name = trim(_name);
SET _mqttUsername = trim(_mqttUsername);
SET _mqttPassword = trim(_mqttPassword);
SET _macAddress = trim(REPLACE(_macAddress, ':',''));



IF length(_mqttUsername) = 0 THEN
	SET _mqttUsername = NULL;
END IF;

IF length(_mqttPassword) = 0 THEN
	SET _mqttPassword = NULL;
END IF;


INSERT INTO controllers
	(id, macAddress, friendlyName, ipAddress, subnet, dns, gateway, mqttUsername, mqttPassword, hwVersion)
VALUES
	(_id, CONV(_macAddress,16,10), _name, INET_ATON(_ipAddress), INET_ATON(_subnet), INET_ATON(_dns), INET_ATON(_gateway), _mqttUsername, _mqttPassword, _hwVersion)
ON DUPLICATE KEY UPDATE
	macAddress = CONV(_macAddress,16,10),
    friendlyName = _name,
    ipAddress = INET_ATON(_ipAddress),
    subnet = INET_ATON(_subnet),
    dns = INET_ATON(_dns),
    gateway = INET_ATON(_gateway),
    mqttUsername = _mqttUsername,
    mqttPassword = _mqttPassword,
    hwVersion = _hwVersion;

SELECT 
    id
INTO id_ FROM
    controllers
WHERE
    macAddress = CONV(_macAddress, 16, 10);

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editControllerPins
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editControllerPins`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editControllerPins`(IN _id int,
IN _hwVersion tinyint(1),
IN _pin tinyint(1),
IN _inputAllowed tinyint(1),
IN _binaryOutputAllowed tinyint(1),
IN _variableOutputAllowed tinyint(1),
OUT id_ int
)
BEGIN


INSERT INTO controllerPins(
id, hwVersion, pin, inputAllowed, binaryOutputAllowed, variableOutputAllowed)
VALUES
(_id, _hwVersion, _pin, _inputAllowed, _binaryOutputAllowed, _variableOutputAllowed)
ON DUPLICATE KEY UPDATE
	inputAllowed = _inputAllowed,
    binaryOutputAllowed = _binaryOutputAllowed, 
    variableOutputAllowed = _variableOutputAllowed;
    
SELECT 
    id
INTO id_ FROM
    controllerPins
WHERE
    hwVersion = _hwVersion
        AND pin = _pin;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editControllerPorts
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editControllerPorts`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editControllerPorts`(IN _id int, IN _hwVersion tinyint, IN _port tinyint, IN _inputAllowed tinyint, IN _outputAllowed tinyint, OUT id_ int)
BEGIN




INSERT INTO controllerPorts(id, hwVersion, port, inputAllowed, outputAllowed)
VALUES (_id, _hwVersion, _port, _inputAllowed, _outputAllowed)
ON DUPLICATE KEY UPDATE
	inputAllowed = _inputAllowed,
	outputAllowed = _outputAllowed;

SELECT 
    id
INTO id_ FROM
    controllerPorts
WHERE
    hwVersion = _hwVersion AND port = _port;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editFirmware
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editFirmware`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editFirmware`(IN _id int, IN _deviceType ENUM('CONTROLLER','CLIENT'), IN _version int, IN _url varchar(255), OUT id_ int)
BEGIN


SET _url = trim(_url);

INSERT INTO firmware (id, deviceType, version, url)
VALUES (_id, _deviceType, _version, _url)
ON DUPLICATE KEY UPDATE
	deviceType = _deviceType,
    version = _version,
    url = _url;
    
SELECT 
    id
INTO id_ FROM
    firmware
WHERE
    deviceType = _deviceType
        AND version = _version;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editInput
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editInput`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editInput`(IN _id int,
IN _switchId int,
IN _position tinyint,
IN _pin tinyint,
IN _colorId int,
IN _circuitType ENUM('NORMALLY_OPEN','NORMALLY_CLOSED'),
IN _name varchar(20),
IN _broadcastOnChange tinyint,
IN _enabled tinyint,
OUT id_ int
)
BEGIN




SET _name = trim(_name);


INSERT INTO inputs (
	id,
	switchId,
	position,
	pin,
	colorId, 
	circuitType,
	friendlyName,
	broadcastOnChange,
	enabled)
VALUES(
	_id,
	_switchId,
	_position,
	_pin,
	_colorId,
	_circuitType,
	_name,
	_broadcastOnChange,
	true)
ON DUPLICATE KEY UPDATE
	switchId = _switchId,
	position = _position,
	pin = _pin,
	colorId = _colorId,
	circuitType = _circuitType,
	friendlyName = _name,
	broadcastOnChange = _broadcastOnChange,
	enabled = _enabled;

SELECT 
    id
INTO id_ FROM
    inputs
WHERE
    switchId = _switchId
        AND position = _position
        AND pin = _pin
        AND colorId = _colorId
        AND circuitType = _circuitType
        AND friendlyName = _name
        AND broadcastOnChange = _broadcastOnChange;
        

CALL incrementSwitchBootstrapCounter(id_);

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editOutput
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editOutput`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editOutput`(
IN _id int,
IN _controllerId int,
IN _controllerPort tinyint,
IN _pin tinyint,
IN _name varchar(20),
IN _outputType ENUM('BINARY','VARIABLE'),
IN _enabled tinyint,
IN _amperage tinyint,
IN _breakerId int,
OUT id_ int
)
BEGIN

SET _name = trim(_name);

INSERT INTO outputs
	(id, controllerId, controllerPort, pin, friendlyName, outputType, enabled, amperage, breakerId)
VALUES
	(_id, _controllerId, _controllerPort, _pin, _name, _outputType, true, IFNULL(_amperage, 0), breakerId)
ON DUPLICATE KEY UPDATE
	controllerId = _controllerId,
    controllerPort = _controllerPort,
    pin = _pin, 
    friendlyName = _name,
    outputType = _outputType,
    enabled = _enabled,
    amperage = IFNULL(_amperage, 0),
    breakerId = _breakerId;

SELECT 
    id
INTO id_ FROM
    outputs
WHERE
    controllerId = _controllerId
        AND controllerPort = _controllerPort
        AND pin = _pin
        AND outputType = _outputType
        AND friendlyName = _name;
    

IF _outputType = 'VARIABLE' THEN
	DELETE FROM actions 
	WHERE
		outputId = id_
		AND actionType NOT IN ('INCREASE' , 'DECREASE');
END IF;
    
IF _outputType = 'BINARY' THEN
    DELETE FROM actions
    WHERE
		outputId = id_
        AND actionType NOT IN ('TOGGLE');
END IF;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editSetting
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editSetting`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editSetting`(
IN _id int,
IN _name varchar(20),
IN _value varchar(255),
OUT id_ int
)
BEGIN




SET _name = trim(_name);
SET _value = trim(_value);


INSERT INTO settings
	(settingName, settingValue)
VALUES 
	(_name, _value)
ON DUPLICATE KEY UPDATE
	settingName = _name,
	settingValue = _value;
    
SELECT 
    id
INTO id_ FROM
    settings
WHERE
    settingName = _name;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure editSwitch
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`editSwitch`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `editSwitch`(
IN _id int,
IN _controllerId int,
IN _controllerPort int,
IN _macAddress varchar(17),
IN _hwVersion tinyint,
IN _name varchar(20),
IN _mqttUsername varchar(20),
IN _mqttPassword varchar(255),
IN _bootstrapURL varchar(255),
IN _firmwareId int,
OUT id_ int
)
BEGIN

DECLARE _firmwareId_ int;




SET _name = trim(_name);
SET _mqttUsername = trim(_mqttUsername);
SET _mqttPassword = trim(_mqttPassword);
SET _macAddress = trim(REPLACE(_macAddress, ':',''));
SET _bootstrapURL = trim(_bootstrapURL);


IF length(_mqttUsername) = 0 THEN
	SET _mqttUsername = NULL;
END IF;

IF length(_mqttPassword) = 0 THEN
	SET _mqttPassword = NULL;
END IF;

IF length(_bootstrapURL) = 0 THEN
	SET _bootstrapURL = NULL;
END IF;

SELECT 
    id
INTO _firmwareId_ FROM
    firmware
WHERE
    id = _firmwareId AND deviceType = 'CLIENT';


IF _firmwareId_ is null THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid firmware.';

END IF;


INSERT INTO switches
	(id, controllerId, controllerPort, macAddress, hwVersion, friendlyName, firmwareId)
VALUES
	(_id, _controllerId, _controllerPort, CONV(_macAddress,16,10), _hwVersion, _name, _firmwareId)
ON DUPLICATE KEY UPDATE
	controllerId = _controllerId,
    controllerPort = _controllerPort,
    macAddress = CONV(_macAddress,16,10),
    hwVersion = _hwVersion,
	friendlyName = _name,
	mqttUsername = _mqttUsername,
	mqttPassword = _mqttPassword,
    bootstrapURL = _bootstrapURL,
    firmwareId = _firmwareId;

SELECT 
    id
INTO id_ FROM
    switches
WHERE
    macAddress = CONV(_macAddress, 16, 10);
    

CALL incrementSwitchBootstrapCounter(id_);

END$$

DELIMITER ;

-- -----------------------------------------------------
-- function formatMacAddress
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`formatMacAddress`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `formatMacAddress`(macAddress bigint) RETURNS char(17) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	
    
    
	return CONCAT_WS(':',substring(hex(macAddress),1,2), substring(hex(macAddress),3,2), substring(hex(macAddress),5,2),
   substring(hex(macAddress),7,2), substring(hex(macAddress),9,2), substring(hex(macAddress),11,2));


END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getBootstrapURL
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`getBootstrapURL`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `getBootstrapURL`(requestedMacAddress bigint) RETURNS varchar(255) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE returnValue varchar(255);
    
SELECT 
    bootstrapURL
INTO returnValue FROM
    switches
WHERE
    macAddress = requestedMacAddress;

    

IF isnull(returnValue) THEN
	SELECT
		settingValue
    INTO
		returnValue
    FROM
		settings
    WHERE
		settingName = 'BootstrapURL';
    
END IF;

RETURN returnValue;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getButtonColorId
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`getButtonColorId`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `getButtonColorId`(_colorName varchar(20)) RETURNS int
    DETERMINISTIC
BEGIN

DECLARE returnValue int;


SET _colorName = UPPER(TRIM(_colorName));

SELECT 
    id
INTO returnValue FROM
    buttonColors
WHERE
    friendlyName = _colorName;

Return returnValue;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getMQTTPassword
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`getMQTTPassword`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `getMQTTPassword`(requestedMacAddress bigint) RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE returnValue varchar(20);

SELECT 
    mqttPassword
INTO returnValue FROM
    controllers
WHERE
    macAddress = requestedMacAddress;
    

IF isnull(returnValue) THEN
SELECT 
    mqttPassword
INTO
	returnValue
FROM
    switches
WHERE
    macAddress = requestedMacAddress;
END IF;
    

IF isnull(returnValue) THEN
	SELECT
		settingValue
    INTO
		returnValue
    FROM
		settings
    WHERE
		settingName = 'MQTTPassword';
    
END IF;

RETURN returnValue;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getMQTTUsername
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`getMQTTUsername`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `getMQTTUsername`(requestedMacAddress bigint) RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE returnValue varchar(20);

SELECT 
    mqttUsername
INTO returnValue FROM
    controllers
WHERE
    macAddress = requestedMacAddress;
    

IF isnull(returnValue) THEN
SELECT 
    mqttUsername
INTO
	returnValue
FROM
    switches
WHERE
    macAddress = requestedMacAddress;
END IF;
    

IF isnull(returnValue) THEN
	SELECT
		settingValue
    INTO
		returnValue
    FROM
		settings
    WHERE
		settingName = 'MQTTUsername';
    
END IF;

RETURN returnValue;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getNextInputPin
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`getNextInputPin`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `getNextInputPin`(_controllerId tinyint) RETURNS tinyint
    DETERMINISTIC
BEGIN

DECLARE returnValue tinyint;



SELECT 
    pin
INTO returnValue FROM
    firefly.getControllerPinsUnused
WHERE
    inputAllowed = TRUE
        AND controllerId = _controllerId
ORDER BY (binaryOutputAllowed * 10 + variableOutputAllowed * 10) ASC , pin ASC
LIMIT 1;

IF returnValue is null THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No pins available.';

END IF;

RETURN returnValue;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getNextOutputPin
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`getNextOutputPin`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `getNextOutputPin`(_controllerId tinyint, _outputType ENUM('BINARY','VARIABLE')) RETURNS tinyint
    DETERMINISTIC
BEGIN

DECLARE returnValue tinyint;



IF _outputType = 'BINARY' THEN

	SELECT 
		pin
	INTO returnValue FROM
		firefly.getControllerPinsUnused
	WHERE
		binaryOutputAllowed = TRUE
			AND controllerId = _controllerId
	ORDER BY (binaryOutputAllowed * 10 + variableOutputAllowed * 10) ASC , pin ASC
	LIMIT 1;
END IF;

IF _outputType = 'VARIABLE' THEN
	SELECT 
		pin
	INTO returnValue FROM
		firefly.getControllerPinsUnused
	WHERE
		variableOutputAllowed = TRUE
			AND controllerId = _controllerId
	ORDER BY pin ASC
	LIMIT 1;

END IF;

IF returnValue is null THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No pins available.';

END IF;

RETURN returnValue;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getNextPort
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`getNextPort`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `getNextPort`(_controllerId int, _portType ENUM('INPUT', 'OUTPUT')) RETURNS tinyint
    DETERMINISTIC
BEGIN

DECLARE returnValue tinyint;

IF _portType = 'OUTPUT' THEN

	SELECT 
		port
	INTO returnValue FROM
		getControllerPortsUnused
	WHERE
		outputAllowed = TRUE
			AND controllerId = _controllerId
	ORDER BY inputAllowed ASC , port
	LIMIT 1;

END IF;

IF _portType = 'INPUT' THEN
	SELECT 
		port
	INTO returnValue FROM
		getControllerPortsUnused
	WHERE
		inputAllowed = TRUE
			AND controllerId = _controllerId
	ORDER BY outputAllowed ASC , port
	LIMIT 1;

END IF;

IF returnValue is null THEN

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No ports available.';

END IF;

RETURN returnValue;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getSetting
-- -----------------------------------------------------

USE `firefly`;
DROP function IF EXISTS `firefly`.`getSetting`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` FUNCTION `getSetting`(requstedName varchar(20)) RETURNS varchar(255) CHARSET utf8mb4
    DETERMINISTIC
BEGIN


IF requstedName = 'mqttUsername' OR requstedName = 'mqttPassword' THEN

	return NULL;

END IF;

RETURN  (SELECT
    settingValue
FROM
    settings
WHERE
    settingName = requstedName); 
    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure incrementSwitchBootstrapCounter
-- -----------------------------------------------------

USE `firefly`;
DROP procedure IF EXISTS `firefly`.`incrementSwitchBootstrapCounter`;

DELIMITER $$
USE `firefly`$$
CREATE DEFINER=`root`@`%` PROCEDURE `incrementSwitchBootstrapCounter`(IN _switchId int)
BEGIN



UPDATE switches SET bootstrapCounter = bootstrapCounter + 1 WHERE id = _switchId;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `firefly`.`getActionsJson`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getActionsJson`;
DROP VIEW IF EXISTS `firefly`.`getActionsJson` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getActionsJson` AS select json_arrayagg(json_object('output',`firefly`.`outputs`.`friendlyName`,'action',`firefly`.`actions`.`actionType`)) AS `json`,`firefly`.`actions`.`inputId` AS `inputId` from (`firefly`.`actions` join `firefly`.`outputs` on((`firefly`.`outputs`.`id` = `firefly`.`actions`.`outputId`))) group by `firefly`.`actions`.`inputId`;

-- -----------------------------------------------------
-- View `firefly`.`getBreakers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getBreakers`;
DROP VIEW IF EXISTS `firefly`.`getBreakers` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getBreakers` AS select `firefly`.`breakers`.`id` AS `id`,`firefly`.`breakers`.`friendlyName` AS `friendlyName`,`firefly`.`breakers`.`amperage` AS `amperage`,json_object('id',`firefly`.`breakers`.`id`,'friendlyName',`firefly`.`breakers`.`friendlyName`,'amperage',`firefly`.`breakers`.`amperage`) AS `json` from `firefly`.`breakers`;

-- -----------------------------------------------------
-- View `firefly`.`getColorBrightnessNames`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getColorBrightnessNames`;
DROP VIEW IF EXISTS `firefly`.`getColorBrightnessNames` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getColorBrightnessNames` AS select `firefly`.`buttonColors`.`id` AS `colorId`,json_object('color',`firefly`.`buttonColors`.`friendlyName`,'intensity',(select json_arrayagg(json_object('name',`firefly`.`brightnessNames`.`friendlyName`,'brightness',`ADJUSTBRIGHTNESSLEVELS`(`firefly`.`buttonColors`.`brightnessMinimum`,`firefly`.`buttonColors`.`brightnessMaximum`,`firefly`.`brightnessNames`.`brightnessValue`))) from `firefly`.`brightnessNames`)) AS `brightnessNames` from `firefly`.`buttonColors`;

-- -----------------------------------------------------
-- View `firefly`.`getControllerPinsUnused`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getControllerPinsUnused`;
DROP VIEW IF EXISTS `firefly`.`getControllerPinsUnused` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getControllerPinsUnused` AS select `firefly`.`controllers`.`id` AS `controllerId`,`firefly`.`controllerPins`.`pin` AS `pin`,`firefly`.`controllerPins`.`inputAllowed` AS `inputAllowed`,`firefly`.`controllerPins`.`binaryOutputAllowed` AS `binaryOutputAllowed`,`firefly`.`controllerPins`.`variableOutputAllowed` AS `variableOutputAllowed` from ((`firefly`.`controllerPins` join `firefly`.`controllers` on((`firefly`.`controllerPins`.`hwVersion` = `firefly`.`controllers`.`hwVersion`))) left join `firefly`.`getControllerPinsUsed` on(((`firefly`.`controllers`.`id` = `getControllerPinsUsed`.`controllerId`) and (`getControllerPinsUsed`.`pin` = `firefly`.`controllerPins`.`pin`)))) where (`getControllerPinsUsed`.`pinType` is null) order by `firefly`.`controllers`.`id`,`firefly`.`controllerPins`.`pin`;

-- -----------------------------------------------------
-- View `firefly`.`getControllerPinsUsed`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getControllerPinsUsed`;
DROP VIEW IF EXISTS `firefly`.`getControllerPinsUsed` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getControllerPinsUsed` AS select `usedPins`.`controllerId` AS `controllerId`,`usedPins`.`switchId` AS `switchId`,`usedPins`.`pin` AS `pin`,`usedPins`.`pinType` AS `pinType` from (select `firefly`.`switches`.`controllerId` AS `controllerId`,`firefly`.`inputs`.`switchId` AS `switchId`,`firefly`.`inputs`.`pin` AS `pin`,'INPUT' AS `pinType` from ((`firefly`.`inputs` join `firefly`.`switches` on((`firefly`.`inputs`.`switchId` = `firefly`.`switches`.`id`))) join `firefly`.`controllers` on((`firefly`.`switches`.`controllerId` = `firefly`.`controllers`.`id`))) union select `firefly`.`outputs`.`controllerId` AS `controllerId`,NULL AS `switchId`,`firefly`.`outputs`.`pin` AS `pin`,'OUTPUT' AS `pinType` from `firefly`.`outputs`) `usedPins` order by `usedPins`.`controllerId`,`usedPins`.`pin`;

-- -----------------------------------------------------
-- View `firefly`.`getControllerPortsUnused`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getControllerPortsUnused`;
DROP VIEW IF EXISTS `firefly`.`getControllerPortsUnused` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getControllerPortsUnused` AS select `firefly`.`controllers`.`id` AS `controllerId`,`firefly`.`controllerPorts`.`port` AS `port`,`firefly`.`controllerPorts`.`inputAllowed` AS `inputAllowed`,`firefly`.`controllerPorts`.`outputAllowed` AS `outputAllowed` from ((`firefly`.`controllerPorts` join `firefly`.`controllers` on((`firefly`.`controllers`.`hwVersion` = `firefly`.`controllerPorts`.`hwVersion`))) left join `firefly`.`getControllerPortsUsed` on(((`getControllerPortsUsed`.`controllerId` = `firefly`.`controllers`.`id`) and (`getControllerPortsUsed`.`port` = `firefly`.`controllerPorts`.`port`)))) where (`getControllerPortsUsed`.`portType` is null);

-- -----------------------------------------------------
-- View `firefly`.`getControllerPortsUsed`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getControllerPortsUsed`;
DROP VIEW IF EXISTS `firefly`.`getControllerPortsUsed` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getControllerPortsUsed` AS select `usedPorts`.`controllerId` AS `controllerId`,`usedPorts`.`id` AS `id`,`usedPorts`.`port` AS `port`,`usedPorts`.`portType` AS `portType` from (select `firefly`.`switches`.`controllerId` AS `controllerId`,`firefly`.`switches`.`id` AS `id`,`firefly`.`switches`.`controllerPort` AS `port`,'INPUT' AS `portType` from `firefly`.`switches` union select `firefly`.`outputs`.`controllerId` AS `controllerId`,`firefly`.`outputs`.`id` AS `id`,`firefly`.`outputs`.`controllerPort` AS `port`,'OUTPUT' AS `portType` from `firefly`.`outputs`) `usedPorts`;

-- -----------------------------------------------------
-- View `firefly`.`getControllers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getControllers`;
DROP VIEW IF EXISTS `firefly`.`getControllers` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getControllers` AS select `firefly`.`controllers`.`id` AS `id`,`FORMATMACADDRESS`(`firefly`.`controllers`.`macAddress`) AS `macAddress`,`firefly`.`controllers`.`friendlyName` AS `friendlyName`,inet_ntoa(`firefly`.`controllers`.`ipAddress`) AS `ipAddress`,inet_ntoa(`firefly`.`controllers`.`subnet`) AS `subnet`,inet_ntoa(`firefly`.`controllers`.`dns`) AS `dns`,inet_ntoa(`firefly`.`controllers`.`gateway`) AS `gateway`,json_object('friendlyName',`firefly`.`controllers`.`friendlyName`,'network',json_object('macAddress',`FORMATMACADDRESS`(`firefly`.`controllers`.`macAddress`),'ipAddress',inet_ntoa(`firefly`.`controllers`.`ipAddress`),'subnet',inet_ntoa(`firefly`.`controllers`.`subnet`),'dns',inet_ntoa(`firefly`.`controllers`.`dns`),'gateway',inet_ntoa(`firefly`.`controllers`.`gateway`)),'mqtt',json_object('serverName',`GETSETTING`('mqttServer'),'port',cast(`GETSETTING`('mqttPort') as unsigned),'username',`GETMQTTUSERNAME`(`firefly`.`controllers`.`macAddress`),'password',`GETMQTTPASSWORD`(`firefly`.`controllers`.`macAddress`),'topics',json_object('client',`GETSETTING`('clientTopic'),'control',`GETSETTING`('controlTopic'),'event',`GETSETTING`('eventTopic')))) AS `json` from `firefly`.`controllers`;

-- -----------------------------------------------------
-- View `firefly`.`getInputs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getInputs`;
DROP VIEW IF EXISTS `firefly`.`getInputs` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getInputs` AS select `firefly`.`switches`.`controllerId` AS `controllerId`,concat(`firefly`.`switches`.`friendlyName`,`firefly`.`inputs`.`friendlyName`) AS `name`,`firefly`.`inputs`.`pin` AS `pin`,`firefly`.`inputs`.`circuitType` AS `circuitType`,if(`firefly`.`inputs`.`broadcastOnChange`,'TRUE','FALSE') AS `broadcastOnStateChange`,if(`firefly`.`inputs`.`enabled`,'TRUE','FALSE') AS `enabled`,`getActionsJson`.`json` AS `outputs`,json_object('name',concat(`firefly`.`switches`.`friendlyName`,`firefly`.`inputs`.`friendlyName`),'pin',`firefly`.`inputs`.`pin`,'circuitType',`firefly`.`inputs`.`circuitType`,'broadcastOnStateChange',((0 <> `firefly`.`inputs`.`broadcastOnChange`) is true),'enabled',((0 <> `firefly`.`inputs`.`enabled`) is true),'outputs',`getActionsJson`.`json`) AS `json` from ((`firefly`.`inputs` join `firefly`.`switches` on((`firefly`.`inputs`.`switchId` = `firefly`.`switches`.`id`))) join `firefly`.`getActionsJson` on((`getActionsJson`.`inputId` = `firefly`.`inputs`.`id`)));

-- -----------------------------------------------------
-- View `firefly`.`getOutputs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getOutputs`;
DROP VIEW IF EXISTS `firefly`.`getOutputs` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getOutputs` AS select `firefly`.`outputs`.`id` AS `outputId`,`firefly`.`outputs`.`controllerId` AS `controllerId`,`firefly`.`outputs`.`friendlyName` AS `outputName`,`firefly`.`outputs`.`outputType` AS `outputType`,`firefly`.`outputs`.`pin` AS `pin`,`firefly`.`outputs`.`controllerPort` AS `controllerPort`,if((`firefly`.`outputs`.`outputType` = 'BINARY'),1,2) AS `position`,if(`firefly`.`outputs`.`enabled`,'TRUE','FALSE') AS `enabled`,`firefly`.`outputs`.`amperage` AS `amperage`,`firefly`.`outputs`.`breakerId` AS `breakerId`,json_object('name',`firefly`.`outputs`.`friendlyName`,'outputType',`firefly`.`outputs`.`outputType`,'pin',`firefly`.`outputs`.`pin`,'enabled',((0 <> `firefly`.`outputs`.`enabled`) is true),'amperage',`firefly`.`outputs`.`amperage`,'breakerId',`firefly`.`outputs`.`breakerId`) AS `json` from `firefly`.`outputs`;

-- -----------------------------------------------------
-- View `firefly`.`getSwitchButtons`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getSwitchButtons`;
DROP VIEW IF EXISTS `firefly`.`getSwitchButtons` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getSwitchButtons` AS select `firefly`.`inputs`.`switchId` AS `switchId`,json_arrayagg(json_object('name',`firefly`.`inputs`.`friendlyName`,'port',(case when (`firefly`.`inputs`.`position` = 1) then 'A' when (`firefly`.`inputs`.`position` = 2) then 'B' when (`firefly`.`inputs`.`position` = 3) then 'C' when (`firefly`.`inputs`.`position` = 4) then 'D' when (`firefly`.`inputs`.`position` = 5) then 'E' when (`firefly`.`inputs`.`position` = 6) then 'F' end),'led',`getColorBrightnessNames`.`brightnessNames`)) AS `json` from (((`firefly`.`inputs` join `firefly`.`buttonColors` on((`firefly`.`buttonColors`.`id` = `firefly`.`inputs`.`colorId`))) join `firefly`.`getColorBrightnessNames` on((`firefly`.`inputs`.`colorId` = `getColorBrightnessNames`.`colorId`))) join `firefly`.`switches` on((`firefly`.`inputs`.`switchId` = `firefly`.`switches`.`id`))) group by `firefly`.`inputs`.`switchId`;

-- -----------------------------------------------------
-- View `firefly`.`getSwitches`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `firefly`.`getSwitches`;
DROP VIEW IF EXISTS `firefly`.`getSwitches` ;
USE `firefly`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `firefly`.`getSwitches` AS select `firefly`.`switches`.`id` AS `switchId`,`FORMATMACADDRESS`(`firefly`.`switches`.`macAddress`) AS `macAddress`,hex(`firefly`.`switches`.`macAddress`) AS `deviceName`,`firefly`.`firmware`.`version` AS `firmwareVersion`,`firefly`.`firmware`.`url` AS `firmwareURL`,`firefly`.`switches`.`bootstrapCounter` AS `bootstrapVersion`,`firefly`.`switches`.`friendlyName` AS `switchName`,json_object('version',`firefly`.`switches`.`bootstrapCounter`,'name',`firefly`.`switches`.`friendlyName`,'bootstrap',json_object('url',`GETBOOTSTRAPURL`(`firefly`.`switches`.`macAddress`),'refreshMilliseconds',cast(`GETSETTING`('bootstrapRefreshMs') as unsigned)),'firmware',json_object('url',`firefly`.`firmware`.`url`,'refreshMilliseconds',cast(`GETSETTING`('firmwareRefreshMs') as unsigned)),'network',json_object('ssid',`GETSETTING`('wifiSSID'),'key',`GETSETTING`('wifiKey')),'mqtt',json_object('serverName',`GETSETTING`('mqttServer'),'port',`GETSETTING`('mqttPort'),'username',`GETMQTTUSERNAME`(`firefly`.`switches`.`macAddress`),'password',`GETMQTTPASSWORD`(`firefly`.`switches`.`macAddress`),'topics',json_object('control',`GETSETTING`('controlTopic'),'event',`GETSETTING`('eventTopic'),'client',`GETSETTING`('clientTopic'))),'buttons',`getSwitchButtons`.`json`) AS `json` from ((`firefly`.`switches` join `firefly`.`firmware` on((`firefly`.`switches`.`firmwareId` = `firefly`.`firmware`.`id`))) join `firefly`.`getSwitchButtons` on((`getSwitchButtons`.`switchId` = `firefly`.`switches`.`id`)));

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
