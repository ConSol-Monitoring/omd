SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE = 'TRADITIONAL';

DROP SCHEMA IF EXISTS `sakuli`;
CREATE SCHEMA IF NOT EXISTS `sakuli`
  DEFAULT CHARACTER SET utf8;
USE `sakuli`;

-- -----------------------------------------------------
-- Table `sakuli`.`sakuli_suites`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakuli`.`sakuli_suites` (
  `id`          INT(11)       NOT NULL AUTO_INCREMENT,
  `suiteID`     VARCHAR(255)  NOT NULL,
  `result`      INT(11)       NOT NULL,
  `result_desc` VARCHAR(45)   NOT NULL,
  `name`        VARCHAR(255)  NOT NULL,
  `guid`        VARCHAR(255)  NOT NULL,
  `start`       VARCHAR(255)  NOT NULL,
  `stop`        VARCHAR(255)  NULL,
  `warning`     INT(11)       NULL,
  `critical`    INT(11)       NULL,
  `duration`    FLOAT         NULL,
  `browser`     VARCHAR(255)  NULL,
  `host`        VARCHAR(255)  NULL,
  `screenshot`  MEDIUMBLOB    NULL,
  `msg`         VARCHAR(2500) NULL,
  `time`        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `guid_UNIQUE` (`guid` ASC))
  ENGINE = MyISAM
  DEFAULT CHARACTER SET = utf8
  COMMENT = 'Sakuli Testcases';


-- -----------------------------------------------------
-- Table `sakuli`.`sakuli_cases`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakuli`.`sakuli_cases` (
  `id`             INT(11)       NOT NULL AUTO_INCREMENT,
  `sakuli_suites_id` INT(11) NOT NULL,
  `caseID`         VARCHAR(255)  NOT NULL,
  `result`         INT(11)       NOT NULL,
  `result_desc`    VARCHAR(45)   NOT NULL,
  `name`           VARCHAR(255)  NOT NULL,
  `guid`           VARCHAR(255)  NOT NULL,
  `start`          VARCHAR(255)  NOT NULL,
  `stop`           VARCHAR(255)  NOT NULL,
  `warning`        INT(11)       NULL DEFAULT NULL,
  `critical`       INT(11)       NULL DEFAULT NULL,
  `duration`       FLOAT         NOT NULL,
  `lastpage`       VARCHAR(1000)  NULL DEFAULT NULL,
  `screenshot`     MEDIUMBLOB    NULL DEFAULT NULL,
  `msg`            VARCHAR(2500) NULL DEFAULT NULL,
  `time`           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`, `sakuli_suites_id`),
  INDEX `fk_sakuli_cases_sakuli_suites` (`sakuli_suites_id` ASC)
)
  ENGINE = MyISAM
  DEFAULT CHARACTER SET = utf8
  COMMENT = 'Sakuli Testcases';


-- -----------------------------------------------------
-- Table `sakuli`.`sakuli_jobs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakuli`.`sakuli_jobs` (
  `id`   INT(11)      NOT NULL AUTO_INCREMENT,
  `guid` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `ind_guid` (`guid` ASC))
  ENGINE = MyISAM
  DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sakuli`.`sakuli_steps`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakuli`.`sakuli_steps` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `sakuli_cases_id` INT(11) NOT NULL,
  `result`        INT(11)      NOT NULL,
  `result_desc`   VARCHAR(45)  NOT NULL,
  `name`          VARCHAR(255) NOT NULL,
  `start`         VARCHAR(255) NOT NULL,
  `stop`          VARCHAR(255) NOT NULL,
  `warning`       INT(11)      NULL DEFAULT NULL,
  `duration`      FLOAT        NOT NULL,
  `time`          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`, `sakuli_cases_id`),
  INDEX `fk_sakuli_steps_sakuli_cases1` (`sakuli_cases_id` ASC)
)
  ENGINE = MyISAM
  DEFAULT CHARACTER SET = utf8
  COMMENT = 'Sakuli Testcases';


SET SQL_MODE = @OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
