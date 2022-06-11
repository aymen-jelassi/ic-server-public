
CREATE TABLE IF NOT EXISTS `playerhousing` (
  `id` int(32),
  `owner` varchar(50),
  `rented` tinyint(1),
  `price` int(32),
  `wardrobe` LONGTEXT,
  PRIMARY KEY (`id`)
);

ALTER TABLE `characters`
  ADD `last_house` INT(11) DEFAULT 0
;

ALTER TABLE `characters_cars`
  ADD `lasthouse` INT(11) DEFAULT 0
;

