-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 26, 2018 at 01:06 PM
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spClosedReport` (IN `fromDate` DATE, IN `toDate` DATE)  NO SQL
BEGIN

SELECT 
	q.status, COUNT(*) AS volume, MAX(DateDiff(q.resp_date, q.q_date )) AS max_tat, ROUND(AVG(DateDiff(q.resp_date,q.clm_recvd_date)),2) AS avg_lag, ROUND(AVG(DateDiff(q.resp_date, q.q_date )),2) AS avg_tat 
FROM 
	question AS q
WHERE 
	q.q_date >= fromDate and q.q_date <= toDate AND
    q.status = 'Answered'
    GROUP by q.status;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteQuestion` (IN `qId` INT(11))  NO SQL
BEGIN
DELETE FROM question WHERE q_id = qId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spDisplayApprovedQs` ()  BEGIN
      SELECT q.*, concat(s.sme_fname, ' ', s.sme_lname) as sme_name FROM question as q
      JOIN sme as s on q.sme_id = s.sme_id
      WHERE STATUS != 'pending'
      ORDER BY q.q_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spDisplayManagedQs` ()  NO SQL
BEGIN
      SELECT q.*, c.cat_name, concat(s.sme_fname, ' ', s.sme_lname) as sme_name
      FROM question AS q
      LEFT JOIN sme AS s 
      on q.sme_id = s.sme_id
      LEFT JOIN category AS c
      ON q.cat_id = c.cat_id
      ORDER BY q.status desc, q.q_date DESC;      
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spEditQuestion` (IN `responseIn` TEXT, IN `responseDate` DATE, IN `statusIn` VARCHAR(30), IN `questID` INT(11), IN `smeName` VARCHAR(80), IN `cat_name` VARCHAR(40))  NO SQL
BEGIN

UPDATE `question` SET response = responseIn, resp_date = responseDate, status = statusIn WHERE q_id = questID;

UPDATE `question` AS q JOIN sme AS s 
SET q.sme_id=s.sme_id WHERE q_id = questID AND concat(s.sme_fname, ' ', s.sme_lname) = smeName;

UPDATE `question` AS q JOIN category AS c
SET q.cat_id = c.cat_id WHERE q_id = questID AND c.cat_name = cat_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spOpenReport` ()  NO SQL
BEGIN

SELECT 
	q.status, COUNT(*) AS volume, MAX(DateDiff(NOW(), q.clm_recvd_date)) AS max_lag, ROUND(AVG(DateDiff(NOW(),q.clm_recvd_date)),2) AS avg_lag, ROUND(AVG(DateDiff(NOW(), q.q_date )),2) AS avg_tat 
FROM 
	question AS q
WHERE 
	q.status <> 'Answered'
    GROUP by q.status;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spQuestionDetails` (IN `qId` INT(11))  NO SQL
SELECT q.*,concat(sme_fname, ' ', sme_lname) as sme_name, cat_name FROM `question` as q 
LEFT JOIN `sme` AS s ON q.sme_id = s.sme_id
LEFT JOIN `category` AS c ON q.cat_id = c.cat_id
WHERE q_id = qId$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spRegionalReport` (IN `fromDate` DATE, IN `toDate` DATE)  NO SQL
BEGIN

SELECT
	r.`regn_name`, COUNT(*) AS volume,
COUNT(
    	CASE
    		WHEN q.`status` = 'Pending'
    		THEN 1
    		ELSE NULL
    	END
     ) AS 'pending',
COUNT(
    	CASE
    		WHEN q.`status` = 'Assigned'
    		THEN 1
    		ELSE NULL
    	END
     ) AS 'assigned',
COUNT(
    	CASE
    		WHEN q.`status` = 'Answered'
    		THEN 1
    		ELSE NULL
    	END
     ) AS 'answered'
FROM 
	question AS q 
LEFT JOIN sme AS s 
	ON q.`sme_id` = s.`sme_id`
LEFT JOIN supervisor AS su
    ON s.`sup_id` = su.`sup_id`
LEFT JOIN region as r
	on su.`region_id` = r.`region_id`
WHERE
	q.`q_date` >= fromDate and q.`q_date` <= toDate
GROUP BY r.`regn_name`
ORDER BY volume DESC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spRegionalReportDEL` (IN `fromDate` DATE, IN `toDate` DATE)  NO SQL
BEGIN

SELECT 
	r.regn_name, COUNT(*) AS volume, MIN(DateDiff(q.resp_date, q.q_date )) AS min_tat, MAX(DateDiff(q.resp_date, q.q_date )) AS max_tat, ROUND(AVG(DateDiff(q.resp_date, q.q_date )),2) AS avg_tat 
FROM 
	question AS q 
LEFT JOIN sme AS s 
	ON q.sme_id = s.sme_id
LEFT JOIN supervisor AS su
    ON s.sup_id = su.sup_id
LEFT JOIN region as r
	on su.region_id = r.region_id    
WHERE 
	q.q_date >= fromDate and q.q_date <= toDate
GROUP BY r.regn_name
ORDER BY volume DESC, avg_tat DESC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spSearchQuestions` (IN `claimNum` INT(11))  NO SQL
BEGIN
	
	SET @sql = CONCAT("SELECT * FROM 'question' WHERE claim_no LIKE '%", @clmNum, "%'");  
    SELECT @sql;
    prepare stmt from @sql; 
  execute stmt; 
  deallocate prepare stmt; 
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spSupervisorReport` (IN `fromDate` DATE, IN `toDate` DATE)  NO SQL
BEGIN

SELECT 
	concat(su.sup_lname,', ',su.sup_fname, ' ',su.m_initial) AS sup_name, COUNT(*) AS volume, MIN(DateDiff(q.resp_date, q.q_date )) AS min_tat, MAX(DateDiff(q.resp_date, q.q_date )) AS max_tat, ROUND(AVG(DateDiff(q.resp_date, q.q_date )),2) AS avg_tat 
FROM 
	question AS q 
LEFT JOIN sme AS s 
	ON q.sme_id = s.sme_id
LEFT JOIN supervisor AS su
    ON s.sup_id = su.sup_id
WHERE 
	q.q_date >= fromDate and q.q_date <= toDate
GROUP BY concat(su.sup_lname,', ',su.sup_fname, ' ',su.m_initial)
ORDER BY volume DESC, avg_tat DESC;

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
  `cat_id` int(11) DEFAULT NULL,
  `question_txt` text NOT NULL,
  `q_date` date NOT NULL,
  `response` text,
  `resp_date` date DEFAULT NULL,
  `sme_id` int(11) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `question`
--

INSERT INTO `question` (`q_id`, `examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `cat_id`, `question_txt`, `q_date`, `response`, `resp_date`, `sme_id`, `status`) VALUES
(8, 'Ben Bridges', 'johnfcollesq@gmail.com', 1234567, '2018-07-18', 4, '           My question needs to be a lot longer  My question needs to be a lot longer\r\n My question needs to be a lot longer  My question needs to be a lot longer\r\n My question needs to be a lot longer', '2018-07-16', '           response', '2018-07-30', 2, 'Assigned'),
(9, 'dfd', 'clairepdonn@yahoo.ie', 4646, '2018-06-30', 4, '      fasfasddf', '2018-07-16', '      lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words', '2018-07-30', 2, 'Answered'),
(12, 'JCCc', 'mccannfiona@eircom.net', 8789871, '2018-05-24', 4, '      answer this!', '2018-07-20', '        ', '2018-07-30', 2, 'Assigned'),
(14, 'Hugh', 'johnfcollesq@gmail.com', 456798, '2018-07-16', 4, '      this is a question', '2018-07-28', '      ', '2018-07-30', 2, 'Answered'),
(15, 'billy', 'jim@johnson.ie', 78946, '2018-06-05', 4, '   sql', '2018-07-27', '      ', '0000-00-00', 3, 'Pending'),
(16, 'claire', 'clairepdonn@yahoo.ie', 45678989, '2018-06-05', 4, '  afjlsfjsdafsa', '2018-07-28', '  anser', '2018-07-29', 2, 'Answered');

-- --------------------------------------------------------

--
-- Table structure for table `region`
--

CREATE TABLE `region` (
  `region_id` int(11) NOT NULL,
  `regn_name` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `region`
--

INSERT INTO `region` (`region_id`, `regn_name`) VALUES
(1, 'North'),
(2, 'East'),
(3, 'South'),
(4, 'West');

-- --------------------------------------------------------

--
-- Table structure for table `sme`
--

CREATE TABLE `sme` (
  `sme_id` int(11) NOT NULL,
  `sme_fname` varchar(40) NOT NULL,
  `sme_lname` varchar(40) NOT NULL,
  `m_initial` varchar(3) NOT NULL,
  `sup_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sme`
--

INSERT INTO `sme` (`sme_id`, `sme_fname`, `sme_lname`, `m_initial`, `sup_id`) VALUES
(1, 'Ron', 'Swanson', '', 3),
(2, 'Ciara', 'Quinn', '', 2),
(3, 'Ben', 'Davis', '', 3),
(4, 'Davini', 'Dougherty', '', 4),
(5, 'Martin', 'Martin', 'M', 1),
(6, 'Tom', 'Thompson', 'T', 8),
(7, 'Martin', 'Martin', 'M', 1),
(8, 'Tom', 'Thompson', 'T', 5),
(9, 'Matt', 'Matthews', 'M', 7),
(10, 'Peter', 'Parker', 'T', 6),
(11, 'May', 'June', 'M', 6),
(12, 'Melanie', 'Melania', 'P', 8),
(13, 'Rupert', 'Brare', 'M', 6),
(14, 'Tim', 'Rodgers', 'P', 1);

-- --------------------------------------------------------

--
-- Table structure for table `supervisor`
--

CREATE TABLE `supervisor` (
  `sup_id` int(11) NOT NULL,
  `sup_fname` varchar(40) NOT NULL,
  `sup_lname` varchar(40) NOT NULL,
  `m_initial` varchar(3) NOT NULL,
  `region_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `supervisor`
--

INSERT INTO `supervisor` (`sup_id`, `sup_fname`, `sup_lname`, `m_initial`, `region_id`) VALUES
(1, 'Andy', 'Foy', '', 1),
(2, 'Steff', 'Quinn', '', 2),
(3, 'John', 'Jameson', '', 3),
(4, 'Brad', 'Bobley', '', 4),
(5, 'James', 'Coyle', 'R', 3),
(6, 'Mary', 'Garden', 'L', 2),
(7, 'Lois', 'Cambridge', 'L', 2),
(8, 'Emily', 'Estevez', 'Q', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `administration`
--
ALTER TABLE `administration`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

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
  ADD KEY `sme_id` (`sme_id`),
  ADD KEY `cat_id` (`cat_id`);

--
-- Indexes for table `region`
--
ALTER TABLE `region`
  ADD PRIMARY KEY (`regn_name`),
  ADD UNIQUE KEY `region_id` (`region_id`),
  ADD KEY `region_id_2` (`region_id`);

--
-- Indexes for table `sme`
--
ALTER TABLE `sme`
  ADD PRIMARY KEY (`sme_id`),
  ADD KEY `sme_id` (`sme_id`),
  ADD KEY `sme_id_2` (`sme_id`),
  ADD KEY `sup_id` (`sup_id`);

--
-- Indexes for table `supervisor`
--
ALTER TABLE `supervisor`
  ADD PRIMARY KEY (`sup_id`),
  ADD KEY `sup_id` (`sup_id`),
  ADD KEY `sup_id_2` (`sup_id`),
  ADD KEY `region_id` (`region_id`);

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
  MODIFY `q_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
--
-- AUTO_INCREMENT for table `region`
--
ALTER TABLE `region`
  MODIFY `region_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `sme`
--
ALTER TABLE `sme`
  MODIFY `sme_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT for table `supervisor`
--
ALTER TABLE `supervisor`
  MODIFY `sup_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
