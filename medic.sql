-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Client :  127.0.0.1
-- Généré le :  Ven 12 Mai 2017 à 12:38
-- Version du serveur :  5.7.9
-- Version de PHP :  5.6.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `fivem`
--

-- --------------------------------------------------------

--
-- Structure de la table `medic`
--

DROP TABLE IF EXISTS `medic`;
CREATE TABLE IF NOT EXISTS `medic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `victimId` varchar(255) NOT NULL,
  `victimServerId` varchar(255) NOT NULL,
  `medicId` varchar(255) DEFAULT NULL,
  `medicServerId` varchar(255) DEFAULT NULL,
  `victimState` varchar(255) NOT NULL DEFAULT 'waiting',
  `accidentTime` int(255) NOT NULL,
  `savedAt` int(255) DEFAULT NULL,
  `victimPos` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=72 DEFAULT CHARSET=latin1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
