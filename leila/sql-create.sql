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
  `user_id` INT NOT NULL AUTO_INCREMENT COMMENT 'ID of the user, auto increment',
  `usertype` INT NOT NULL COMMENT '1 = admin user\n2 = normal user\n3 = object owner',
  `password` VARCHAR(45) NULL COMMENT 'PW hash',
  `firstname` VARCHAR(20) NOT NULL COMMENT 'Given name',
  `lastname` VARCHAR(20) NOT NULL COMMENT 'Last name',
  `street` VARCHAR(20) NOT NULL COMMENT 'Street und House Number',
  `city` VARCHAR(20) NOT NULL COMMENT 'Name of City',
  `zipcode` VARCHAR(20) NOT NULL COMMENT 'ZIP Code',
  `country` VARCHAR(20) NOT NULL,
  `telephone` VARCHAR(45) NULL COMMENT 'Telephone number',
  `email` VARCHAR(45) NULL,
  `idnumber` VARCHAR(45) NULL COMMENT 'number of the ID provided',
  `comment` VARCHAR(200) NULL COMMENT 'Short comment',
  `comember` VARCHAR(100) NULL COMMENT 'Name of other people who can use this member card',
  PRIMARY KEY (`user_id`),
  FULLTEXT INDEX `name` (`firstname` ASC, `lastname` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`objects`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`objects` ;

CREATE TABLE IF NOT EXISTS `leila`.`objects` (
  `object_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto incremented ID of the object, generated on insert',
  `name` VARCHAR(45) NOT NULL COMMENT 'Name of the object',
  `description` VARCHAR(500) NULL COMMENT 'Short description of the object',
  `image` MEDIUMBLOB NULL COMMENT 'Photo of the object',
  `imagename` VARCHAR(45) NULL COMMENT 'Name of the image e.g. tool.jpg',
  `imagetype` VARCHAR(45) NULL COMMENT 'MIME type of the image e.g. image/jpeg',
  `scaledimage` MEDIUMBLOB NULL,
  `dateadded` DATE NULL COMMENT 'Date the object came to leila',
  `internalcomment` VARCHAR(200) NULL COMMENT 'internal comment, not to be displayed on the homepage, e.g. if the donor wants it back, or if we paid something for it',
  `owner` INT NULL COMMENT 'who is the owner / donor of the object? reference to users.user_id',
  `loaneduntil` DATE NULL COMMENT 'this object is loaned to leila until this date',
  `isavailable` INT NULL COMMENT 'is the object available for rent?\n\n1 = object can be rented\n\n2 = object is broken\n\n3 = object went missing\n\nwe never delete objects, since that destroys the history of rentals.',
  PRIMARY KEY (`object_id`),
  INDEX `fk_objects_users_idx` (`owner` ASC),
  FULLTEXT INDEX `namedescription` (`name` ASC, `description` ASC),
  CONSTRAINT `fk_objects_users_user_id`
    FOREIGN KEY (`owner`)
    REFERENCES `leila`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`rented`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`rented` ;

CREATE TABLE IF NOT EXISTS `leila`.`rented` (
  `object_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `loanedout` DATETIME NOT NULL COMMENT 'When was the item loaned out?',
  `duedate` DATE NOT NULL COMMENT 'When is the item due',
  `givenback` DATE NULL,
  `comment` VARCHAR(200) NULL,
  INDEX `fk_rented_objects1_idx` (`object_id` ASC),
  INDEX `fk_rented_users1_idx` (`user_id` ASC),
  PRIMARY KEY (`object_id`, `user_id`, `loanedout`),
  CONSTRAINT `fk_rented_objects_object_id`
    FOREIGN KEY (`object_id`)
    REFERENCES `leila`.`objects` (`object_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rented_users_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `leila`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`categories`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`categories` ;

CREATE TABLE IF NOT EXISTS `leila`.`categories` (
  `category_id` INT NOT NULL AUTO_INCREMENT,
  `ischildof` INT NULL COMMENT 'this category is a subcategory  of categories.ID\n\nnull if it is a top category',
  `name` VARCHAR(45) NOT NULL COMMENT 'Name of the Category, e.g. Sports or Tools',
  PRIMARY KEY (`category_id`),
  INDEX `fk_categories_categories1_idx` (`ischildof` ASC),
  CONSTRAINT `fk_categories_categories1`
    FOREIGN KEY (`ischildof`)
    REFERENCES `leila`.`categories` (`category_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`objects_has_categories`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`objects_has_categories` ;

CREATE TABLE IF NOT EXISTS `leila`.`objects_has_categories` (
  `object_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  PRIMARY KEY (`object_id`, `category_id`),
  INDEX `fk_objects_has_categories_categories1_idx` (`category_id` ASC),
  CONSTRAINT `fk_objects_has_categories_objects_object_id`
    FOREIGN KEY (`object_id`)
    REFERENCES `leila`.`objects` (`object_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_objects_has_categories_categories_category_id`
    FOREIGN KEY (`category_id`)
    REFERENCES `leila`.`categories` (`category_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `leila`.`membershipfees`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `leila`.`membershipfees` ;

CREATE TABLE IF NOT EXISTS `leila`.`membershipfees` (
  `user_id` INT NOT NULL COMMENT 'from users.ID',
  `from` DATE NOT NULL COMMENT 'Membership is from this date',
  `until` DATE NOT NULL COMMENT 'Membership is until this date',
  `amount` INT NOT NULL COMMENT 'Amount of membership fee paid in Euro',
  PRIMARY KEY (`user_id`, `from`, `until`),
  CONSTRAINT `fk_membershipfees_users_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `leila`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE = '';
GRANT USAGE ON *.* TO leila;
 DROP USER leila;
SET SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';
CREATE USER 'leila' IDENTIFIED BY 'blabla';

GRANT SELECT, INSERT, TRIGGER, UPDATE, DELETE ON TABLE `leila`.* TO 'leila';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
