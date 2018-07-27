-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 27, 2018 at 05:10 PM
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `spAddQuestion` (IN `exam_name` VARCHAR(40), IN `emailAdd` VARCHAR(40), IN `claimNum` INT, IN `recvddate` DATE, IN `questionIn` TEXT, IN `qDate` DATE)  BEGIN
INSERT INTO question (examiner_name, email, claim_no, clm_recvd_date, question_txt, q_date) VALUES (exam_name, emailAdd, claimNum, recvddate, questionIn, qDate);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteQuestion` (IN `qId` INT(11))  NO SQL
BEGIN
DELETE FROM question WHERE q_id = qId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spDisplayApprovedQs` ()  BEGIN
      SELECT * FROM question WHERE STATUS != 'pending';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spEditQuestion` (IN `exam_name` VARCHAR(40), IN `emailAdd` VARCHAR(40), IN `claimNum` INT(11), IN `recvdDate` DATE, IN `questionIn` TEXT, IN `catIn` VARCHAR(30), IN `responseIn` TEXT, IN `responseDate` DATE, IN `smeIn` VARCHAR(30), IN `statusIn` VARCHAR(30), IN `questID` INT(11))  NO SQL
BEGIN
UPDATE question set examiner_name = exam_name, email = emailAdd, claim_no = claimNum, clm_recvd_date = recvdDate, question_txt = questionIn, category = catIn, response = responseIn, resp_date = responseDate, sme = smeIn, status = statusIn WHERE q_id = questID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spSearchQuestions` (IN `claimNum` INT(11))  NO SQL
BEGIN
	
	SET @sql = CONCAT("SELECT * FROM 'question' WHERE claim_no LIKE '%", @clmNum, "%'");  
    SELECT @sql;
    prepare stmt from @sql; 
  execute stmt; 
  deallocate prepare stmt; 
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
  `question_txt` text NOT NULL,
  `q_date` datetime NOT NULL,
  `response` text,
  `resp_date` date DEFAULT NULL,
  `sme` varchar(30) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `question`
--

INSERT INTO `question` (`q_id`, `examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `category`, `question_txt`, `q_date`, `response`, `resp_date`, `sme`, `status`) VALUES
(8, 'Ben Bridges', 'johnfcollesq@gmail.com', 1234567, '2018-07-16', 'Eligibility', '     My question needs to be a lot longer  My question needs to be a lot longer\r\n My question needs to be a lot longer  My question needs to be a lot longer\r\n My question needs to be a lot longer', '2018-07-16 19:52:00', '     response', '2018-05-05', 'Davini Doherty', 'Assigned'),
(9, 'dfd', 'clairepdonn@yahoo.ie', 4646, '0000-00-00', 'Reciprocity', '   fasfasddf', '2018-07-16 20:37:08', '   lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words', '0000-00-00', 'Ciara Quinn', 'Pending'),
(10, 'Ben Bridges', 'clairepdonn@yahoo.ie', 123456, '0000-00-00', '', 'safafassdf', '2018-07-16 21:00:27', NULL, NULL, NULL, 'pending'),
(11, 'bob', 'jc@jc.jc', 789465, '0000-00-00', '', 'question here', '2018-07-18 00:00:00', NULL, NULL, NULL, 'pending'),
(12, 'JCC', 'mccannfiona@eircom.net', 878987, '0000-00-00', '', ' ASFSFASDFS', '2018-07-20 00:00:00', ' ', '0000-00-00', 'Ciara Quinn', 'Assigned'),
(13, 'jc', 'fsdf@dfdf.com', 424234, '0000-00-00', '', 'fasfasfasdf', '2018-07-20 00:00:00', NULL, NULL, NULL, 'pending');

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
  MODIFY `q_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
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
