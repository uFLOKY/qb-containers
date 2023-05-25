
CREATE TABLE IF NOT EXISTS `containers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(50) DEFAULT NULL,
  `keyholders` text DEFAULT NULL,
  `flag` int(11) DEFAULT NULL,
  `total` int(11) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `slots` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4;
