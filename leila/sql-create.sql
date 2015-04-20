-- MySQL Script generated by MySQL Workbench
-- Sat Apr 18 16:21:09 2015
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema leila
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `leila` ;

-- -----------------------------------------------------
-- Schema leila
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `leila` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `leila` ;

-- -----------------------------------------------------
-- Table `leila`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`users` ;

CREATE TABLE IF NOT EXISTS `leila`.`users` (
  `ID` INT NOT NULL AUTO_INCREMENT COMMENT 'ID of the user, auto increment',
  `usertype` INT NOT NULL COMMENT '1 = admin user\n2 = normal user\n3 = object owner',
  `password` VARCHAR(45) NOT NULL COMMENT 'PW hash',
  `firstname` VARCHAR(20) NOT NULL COMMENT 'Given name',
  `lastname` VARCHAR(20) NOT NULL COMMENT 'Last name',
  `Street` VARCHAR(20) NOT NULL COMMENT 'Street und House Number',
  `City` VARCHAR(20) NOT NULL COMMENT 'Name of City',
  `zipcode` VARCHAR(20) NOT NULL COMMENT 'ZIP Code',
  `country` VARCHAR(20) NOT NULL,
  `telephone` VARCHAR(45) NULL COMMENT 'Telephone number',
  `email` VARCHAR(45) NULL,
  `idnumber` VARCHAR(45) NULL COMMENT 'number of the ID provided',
  `comment` VARCHAR(200) NULL COMMENT 'Short comment',
  `comember` VARCHAR(100) NULL COMMENT 'Name of other people who can use this member card',
  PRIMARY KEY (`ID`),
  INDEX `name` (`firstname` ASC, `lastname` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`objects`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`objects` ;

CREATE TABLE IF NOT EXISTS `leila`.`objects` (
  `ID` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto incremented ID of the object, generated on insert',
  `name` VARCHAR(45) NOT NULL COMMENT 'Name of the object',
  `description` VARCHAR(500) NULL COMMENT 'Short description of the object',
  `image` BLOB NULL COMMENT 'Photo of the object',
  `imagename` VARCHAR(45) NULL COMMENT 'Name of the image e.g. tool.jpg',
  `imagetype` VARCHAR(45) NULL COMMENT 'MIME type of the image e.g. image/jpeg',
  `scaledimage` MEDIUMBLOB NULL,
  `dateadded` DATE NULL COMMENT 'Date the object came to leila',
  `internalcomment` VARCHAR(200) NULL COMMENT 'internal comment, not to be displayed on the homepage, e.g. if the donor wants it back, or if we paid something for it',
  `owner` INT NULL COMMENT 'who is the owner / donor of the object? reference to users.id',
  `loaneduntil` DATE NULL COMMENT 'this object is loaned to leila until this date',
  `isavailable` INT NULL COMMENT 'is the object available for rent?\n\n0 = object can not be rented\n1 = object can be rented\n\nwhen there is no corresponding column in rented the object went missing / was stolen\n\nwe never delete objects, since that destroys the history of rentals. if a object is not available anymore set to 0',
  PRIMARY KEY (`ID`),
  INDEX `fk_objects_users_idx` (`owner` ASC),
  INDEX `name` (`name` ASC),
  INDEX `description` (`description`(100) ASC),
  CONSTRAINT `fk_objects_users`
    FOREIGN KEY (`owner`)
    REFERENCES `leila`.`users` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`rented`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`rented` ;

CREATE TABLE IF NOT EXISTS `leila`.`rented` (
  `objects_ID` INT NOT NULL,
  `users_ID` INT NOT NULL,
  `loanedout` DATETIME NOT NULL COMMENT 'When was the item loaned out?',
  `duedate` DATE NOT NULL COMMENT 'When is the item due',
  `givenback` DATETIME NULL,
  `comment` VARCHAR(200) NULL,
  INDEX `fk_rented_objects1_idx` (`objects_ID` ASC),
  INDEX `fk_rented_users1_idx` (`users_ID` ASC),
  PRIMARY KEY (`objects_ID`, `users_ID`, `loanedout`),
  CONSTRAINT `fk_rented_objects1`
    FOREIGN KEY (`objects_ID`)
    REFERENCES `leila`.`objects` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rented_users1`
    FOREIGN KEY (`users_ID`)
    REFERENCES `leila`.`users` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`categories`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`categories` ;

CREATE TABLE IF NOT EXISTS `leila`.`categories` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `ischildof` INT NULL COMMENT 'this category is a subcategory  of categories.ID\n\nnull if it is a top category',
  `name` VARCHAR(45) NOT NULL COMMENT 'Name of the Category, e.g. Sports or Tools',
  PRIMARY KEY (`ID`),
  INDEX `fk_categories_categories1_idx` (`ischildof` ASC),
  CONSTRAINT `fk_categories_categories1`
    FOREIGN KEY (`ischildof`)
    REFERENCES `leila`.`categories` (`ID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`categoriestoobjects`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`categoriestoobjects` ;

CREATE TABLE IF NOT EXISTS `leila`.`categoriestoobjects` (
  `objects_ID` INT NOT NULL,
  INDEX `fk_categoriestoobjects_objects1_idx` (`objects_ID` ASC),
  CONSTRAINT `fk_categoriestoobjects_objects1`
    FOREIGN KEY (`objects_ID`)
    REFERENCES `leila`.`objects` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`objects_has_categories`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`objects_has_categories` ;

CREATE TABLE IF NOT EXISTS `leila`.`objects_has_categories` (
  `objects_ID` INT NOT NULL,
  `categories_ID` INT NOT NULL,
  PRIMARY KEY (`objects_ID`, `categories_ID`),
  INDEX `fk_objects_has_categories_categories1_idx` (`categories_ID` ASC),
  CONSTRAINT `fk_objects_has_categories_objects1`
    FOREIGN KEY (`objects_ID`)
    REFERENCES `leila`.`objects` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_objects_has_categories_categories1`
    FOREIGN KEY (`categories_ID`)
    REFERENCES `leila`.`categories` (`ID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`membershipfees`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`membershipfees` ;

CREATE TABLE IF NOT EXISTS `leila`.`membershipfees` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `users_ID` INT NOT NULL COMMENT 'from users.ID',
  `amount` INT NOT NULL COMMENT 'Amount of membership fee paid in Euro',
  `from` DATE NOT NULL COMMENT 'Membership is from this date',
  `until` DATE NOT NULL COMMENT 'Membership is until this date',
  PRIMARY KEY (`ID`),
  INDEX `fk_membershipfees_users1_idx` (`users_ID` ASC),
  CONSTRAINT `fk_membershipfees_users1`
    FOREIGN KEY (`users_ID`)
    REFERENCES `leila`.`users` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`wishlist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`wishlist` ;

CREATE TABLE IF NOT EXISTS `leila`.`wishlist` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `users_ID` INT NULL COMMENT 'Which user has wished the item? from users.id',
  `Name` VARCHAR(45) NULL COMMENT 'Name of the item',
  `Description` VARCHAR(1000) NULL COMMENT 'Description of the item',
  `photo` BLOB NULL COMMENT 'How does the item look like?',
  PRIMARY KEY (`ID`),
  INDEX `fk_wishlist_users1_idx` (`users_ID` ASC),
  CONSTRAINT `fk_wishlist_users1`
    FOREIGN KEY (`users_ID`)
    REFERENCES `leila`.`users` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE = '';
GRANT USAGE ON *.* TO leila;
 DROP USER leila;
SET SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';
CREATE USER 'leila' IDENTIFIED BY 'blabla';

GRANT ALL ON `leila`.* TO 'leila';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;