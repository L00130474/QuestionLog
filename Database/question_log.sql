-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 09, 2018 at 10:23 PM
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
    q.status = 'Closed'
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spEditQuestion` (IN `exam_name` VARCHAR(40), IN `emailAdd` VARCHAR(40), IN `claimNum` INT(11), IN `recvdDate` DATE, IN `questionIn` TEXT, IN `catIn` INT(11), IN `responseIn` TEXT, IN `responseDate` DATE, IN `smeIn` INT(11), IN `statusIn` VARCHAR(30), IN `questID` INT(11))  NO SQL
BEGIN
UPDATE question set examiner_name = exam_name, email = emailAdd, claim_no = claimNum, clm_recvd_date = recvdDate, question_txt = questionIn, cat_id = catIn, response = responseIn, resp_date = responseDate, sme_id = smeIn, status = statusIn WHERE q_id = questID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spEditQuestion1` (IN `exam_name` VARCHAR(40), IN `emailAdd` VARCHAR(40), IN `claimNum` INT(11), IN `recvdDate` DATE, IN `questionIn` TEXT, IN `responseIn` TEXT, IN `responseDate` DATE, IN `statusIn` VARCHAR(30), IN `questID` INT(11), IN `smeName` VARCHAR(80), IN `cat_name` VARCHAR(40))  NO SQL
BEGIN

UPDATE `question` SET examiner_name = exam_name, email = emailAdd, claim_no = claimNum, clm_recvd_date = recvdDate, question_txt = questionIn, response = responseIn, resp_date = responseDate, status = statusIn WHERE q_id = questID;

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
	q.status <> 'Closed'
    GROUP by q.status;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spRegionalReport` (IN `fromDate` DATE, IN `toDate` DATE)  NO SQL
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
  `cat_id` int(11) NOT NULL,
  `question_txt` text NOT NULL,
  `q_date` datetime NOT NULL,
  `response` text,
  `resp_date` date DEFAULT NULL,
  `sme_id` int(11) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `question`
--

INSERT INTO `question` (`q_id`, `examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `cat_id`, `question_txt`, `q_date`, `response`, `resp_date`, `sme_id`, `status`) VALUES
(8, 'Ben Bridges', 'johnfcollesq@gmail.com', 1234567, '2018-07-18', 4, '           My question needs to be a lot longer  My question needs to be a lot longer\r\n My question needs to be a lot longer  My question needs to be a lot longer\r\n My question needs to be a lot longer', '2018-07-16 19:52:00', '           response', '2018-07-30', 2, 'Assigned'),
(9, 'dfd', 'clairepdonn@yahoo.ie', 4646, '2018-06-30', 4, '      fasfasddf', '2018-07-16 20:37:08', '      lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words', '2018-07-30', 2, 'Answered'),
(10, 'Ben Bridges', 'clairepdonn@yahoo.ie', 123456, '2018-07-01', 5, '    safafassdf', '2018-07-16 21:00:27', '    ', '2018-07-29', 2, 'Assigned'),
(11, 'bob', 'jc@jc.jc', 789465, '2018-05-29', 4, ' question here', '2018-07-18 00:00:00', ' ', '2018-07-30', 2, 'Pending'),
(12, 'JCCc', 'mccannfiona@eircom.net', 8789871, '2018-05-24', 4, '      answer this!', '2018-07-20 00:00:00', '        ', '2018-07-30', 2, 'Assigned'),
(13, 'jc', 'fsdf@dfdf.com', 424234, '2018-07-12', 7, '     fasfasfasdf', '2018-07-20 00:00:00', '     ', '2018-07-30', 2, 'Pending'),
(14, 'Hugh', 'johnfcollesq@gmail.com', 456798, '2018-07-16', 4, '      this is a question', '2018-07-28 00:00:00', '      ', '2018-07-30', 2, 'Answered'),
(15, 'billy', 'jim@johnson.ie', 78946, '2018-06-05', 4, '   sql', '2018-07-27 00:00:00', '   ', '0000-00-00', 2, 'Assigned'),
(16, 'claire', 'clairepdonn@yahoo.ie', 45678989, '2018-06-05', 4, '  afjlsfjsdafsa', '2018-07-28 00:00:00', '  anser', '2018-07-29', 2, 'Answered'),
(17, 'Carl Lewis', 'jc@jc.jc', 789456, '2018-08-20', 0, 'Question time', '2018-08-09 00:00:00', NULL, NULL, NULL, 'pending'),
(18, 'Jerry Top', 'mccannfiona@eircom.net', 465794313, '2018-08-09', 0, 'afljflasdkfjaslfjasd', '2018-08-09 00:00:00', NULL, NULL, NULL, 'pending');

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
(4, 'Davini', 'Dougherty', '', 4);

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
(4, 'Brad', 'Bobley', '', 4);

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
  ADD KEY `sme_id` (`sme_id`);

--
-- Indexes for table `region`
--
ALTER TABLE `region`
  ADD PRIMARY KEY (`regn_name`),
  ADD UNIQUE KEY `region_id` (`region_id`);

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
  MODIFY `q_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT for table `region`
--
ALTER TABLE `region`
  MODIFY `region_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `sme`
--
ALTER TABLE `sme`
  MODIFY `sme_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `supervisor`
--
ALTER TABLE `supervisor`
  MODIFY `sup_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
