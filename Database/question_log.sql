-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 16, 2018 at 08:11 PM
-- Server version: 10.1.21-MariaDB
-- PHP Version: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `question_log`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchQuestions` ()  BEGIN
        SELECT * FROM question;
        END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `administration`
--

CREATE TABLE `administration` (
  `id` int(11) NOT NULL,
  `username` varchar(40) NOT NULL,
  `password` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `administration`
--

INSERT INTO `administration` (`id`, `username`, `password`) VALUES
(1, 'jc', 'jc');

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `cat_id` int(11) NOT NULL,
  `cat_name` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`cat_id`, `cat_name`) VALUES
(3, 'Misc'),
(4, 'Duplicate'),
(5, 'Reciprocity'),
(6, 'Copay'),
(7, 'Eligibility'),
(8, 'Timely Filing'),
(9, 'Contract');

-- --------------------------------------------------------

--
-- Table structure for table `question`
--

CREATE TABLE `question` (
  `q_id` int(11) NOT NULL,
  `examiner_name` varchar(40) NOT NULL,
  `email` varchar(30) NOT NULL,
  `claim_no` int(20) NOT NULL,
  `clm_recvd_date` date NOT NULL,
  `category` varchar(30) NOT NULL,
  `question` text NOT NULL,
  `q_date` datetime NOT NULL,
  `response` text,
  `resp_date` date DEFAULT NULL,
  `sme` varchar(30) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `question`
--

INSERT INTO `question` (`q_id`, `examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `category`, `question`, `q_date`, `response`, `resp_date`, `sme`, `status`) VALUES
(1, 'jc', 'johnfcollesq@gmail.com', 123, '0000-00-00', 'Duplicate', '  asdfasdf', '0000-00-00 00:00:00', '  the answer', '2018-07-09', 'Davini Doherty', 'Pending'),
(3, 'jc', 'johnfcollesq@gmail.com', 456, '2018-04-05', 'Duplicate', '  question', '2018-07-14 16:45:00', ' 123456', '2018-07-07', 'Davini Doherty', 'Closed');

-- --------------------------------------------------------

--
-- Table structure for table `sme`
--

CREATE TABLE `sme` (
  `sme_id` int(11) NOT NULL,
  `sme_name` varchar(40) NOT NULL,
  `sup_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sme`
--

INSERT INTO `sme` (`sme_id`, `sme_name`, `sup_id`) VALUES
(1, 'Ron Swanson', 3),
(2, 'Ciara Quinn', 2),
(3, 'Ben Davis', 3),
(4, 'Davini Doherty', 4);

-- --------------------------------------------------------

--
-- Table structure for table `supervisor`
--

CREATE TABLE `supervisor` (
  `sup_id` int(11) NOT NULL,
  `sup_name` varchar(40) NOT NULL,
  `region` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `supervisor`
--

INSERT INTO `supervisor` (`sup_id`, `sup_name`, `region`) VALUES
(1, 'Andy Foy', 'West'),
(2, 'Steff Quinn', 'South'),
(3, 'Jim James', 'Northwest');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `administration`
--
ALTER TABLE `administration`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`cat_id`);

--
-- Indexes for table `question`
--
ALTER TABLE `question`
  ADD PRIMARY KEY (`q_id`),
  ADD KEY `claim_no` (`claim_no`),
  ADD KEY `q_id` (`q_id`),
  ADD KEY `sme_id` (`sme`);

--
-- Indexes for table `sme`
--
ALTER TABLE `sme`
  ADD PRIMARY KEY (`sme_id`),
  ADD KEY `sme_id` (`sme_id`),
  ADD KEY `sme_id_2` (`sme_id`);

--
-- Indexes for table `supervisor`
--
ALTER TABLE `supervisor`
  ADD PRIMARY KEY (`sup_id`),
  ADD KEY `sup_id` (`sup_id`),
  ADD KEY `sup_id_2` (`sup_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `administration`
--
ALTER TABLE `administration`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `cat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `question`
--
ALTER TABLE `question`
  MODIFY `q_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `sme`
--
ALTER TABLE `sme`
  MODIFY `sme_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `supervisor`
--
ALTER TABLE `supervisor`
  MODIFY `sup_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
