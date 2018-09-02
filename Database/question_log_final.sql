-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 01, 2018 at 05:10 PM
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
	q.q_date >= fromDate and q.q_date <= toDate AND
    q.status = 'Answered'
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
  `q_date` date NOT NULL,
  `response` text,
  `resp_date` date DEFAULT NULL,
  `sme_id` int(11) DEFAULT NULL,
  `status` varchar(30) DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- Dumping data for table `question`
--

INSERT INTO `question` (`q_id`, `examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `cat_id`, `question_txt`, `q_date`, `response`, `resp_date`, `sme_id`, `status`) VALUES
(1, 'Shane', 'Shane@we.com', 46589541, '2018-08-08', 3, 'Claim has an EOR attached with pricing for 4 codes claim is billing 7\n\nline 2 77334-TC has no rate but the repricing ind etc is there does this mean you pay at BC or what process do I follow here to obtain a rate?', '2018-08-15', ' Okay to pay at billed charges', '2018-08-23', 5, 'Answered'),
(4, 'Shane', 'Shane@we.com', 46589544, '2018-07-31', 3, 'Please review docs attached for POTF\n\nI dont think any are valid!', '2018-08-13', ' ', '0000-00-00', 1, 'Pending'),
(5, 'Myles', 'Myles@we.com', 46589545, '2018-08-08', 0, 'This clm has CES review and denial edits. I think the denial for line 8 should stand and the review for  line 11 and 1 would allow them to be paid. Am i correct with that? Thanks.', '2018-08-13', '', NULL, 0, 'Pending'),
(6, 'catherine ', 'catherine @we.com', 46589546, '2018-08-08', 0, 'I dont know what risk to go wit this claim, OU in history capped but HS01, if i dont follow this i think i cap per P&P??', '2018-08-13', '', NULL, 0, 'Pending'),
(7, 'catherine ', 'catherine @we.com', 46589547, '2018-06-08', 0, 'Im on step 18 on sop, Are the services billed routine ? the first one is on the UR/ER but they are both Z codes does this mean that it isnt routine or is and should be denied not covered?? \n', '2018-08-13', '', NULL, 0, 'Pending'),
(8, 'David', 'David@we.com', 46589548, '2018-07-30', 0, 'corrected claim to claim that had capitation overturned due to cap 300 process, do I also follow the process or cap it?', '2018-08-10', '', NULL, 0, 'Pending'),
(9, 'Chris ', 'Chris @we.com', 46589549, '2018-07-18', 0, 'Hi Angela, am I correct to apply 127% of CMS as the rates for my billed codes? I see langauage there regarding RVU\'s does that have any significant impact? Thanks', '2018-08-09', '', NULL, 0, 'Pending'),
(10, 'David', 'David@we.com', 46589550, '2018-07-27', 0, 'ooa\nmy dos 7/18/18\nauth with dos 07/18/18->07/21/18 has been linked \nwith comment\nEMBER BEGAN RECEIVING SERVICES ON 07/18/18 ///CAC/MCR ID:CCA\n\nshould I use the auth?', '2018-08-08', '', NULL, 0, 'Pending'),
(11, 'Monica', 'Monica@we.com', 46589551, '2018-07-24', 0, 'Just checking this for TF. There\'s an eob attached from the pmg but i still think it\'s out for TF. Can you double check it for me please? Thanks ', '2018-08-08', '', NULL, 0, 'Pending'),
(12, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589552, '2018-08-01', 0, 'My claim is billed with mod RT, claim #8 in history has no mod RT billed...do I treat my claim as corrected and assume #8 was RT aswell as dx is pain in right hip....', '2018-08-07', '', NULL, 0, 'Pending'),
(13, 'Catherine ', 'Catherine @we.com', 46589553, '2018-07-30', 0, 'U risk - screen 14 - see screen 11, in screen 11 would i follow the *pathology & rad ip & op  which states pro H, \nOr \nRadiology (diagnostic only) - op BOTH M risk ??', '2018-08-03', '', NULL, 0, 'Pending'),
(14, 'Rebecca  ', 'Rebecca  @we.com', 46589554, '2018-07-27', 0, 'Recent COB comments stating OI prime.  EOB attached to claim - showing all charges as Member Resp.  I cannot verify where EOB came from so don\'t really think it should be used.  Should I request correct EOB or pay per U&C as this is less than member resp?? \n\n\n\n\n', '2018-08-02', '', NULL, 0, 'Pending'),
(15, 'Chris', 'Chris@we.com', 46589555, '2018-07-26', 0, 'Hi Angela,\nThis claim has no FFS, by report or F/S & I am reaching this claim needs to go for contract clar & to contact your SME but there is another DEC with a F/S available - can I just link the other DEC #18130 1971 & use that?\nThanks.', '2018-08-02', '', NULL, 0, 'Pending'),
(16, 'Shane', 'Shane@we.com', 46589556, '2018-07-21', 0, 'SH Medicaid claim has to go for ces review. I need the provider specilaity all I can find is specialist what should I use here?', '2018-08-01', '', NULL, 0, 'Pending'),
(17, 'Chris', 'Chris@we.com', 46589557, '2018-07-18', 0, 'Hi, this claim is a CFC 7. The OCN is #18 but was incorrectly processed i think when i read the ces edits.\nTrying to wrap my head around this but, this is a CFC 7 is it ok to ignore first claim as a full recoupments will have to be made & just focus on the new claim #34 ? On claim #34 am I right to assume all the dup edits & the daily frequency (units) edit can be bypassed?\nThanks.', '2018-08-01', '', NULL, 0, 'Pending'),
(18, 'Thomas', 'Thomas@we.com', 46589558, '2018-07-19', 0, 'I have a corrected claim to a previously denied claim denied for invalid ICD.  The original claim wasn\'t billed within TF limits, but there is possible proof attached. It is a misdirected cover letter from PMG, but I cannot determine any date to use from it . There is a date on the image received 08/01/2018 but I am unsure if this will suffice.', '2018-07-31', '', NULL, 0, 'Pending'),
(19, 'Zeta', 'Zeta@we.com', 46589559, '2018-07-24', 0, 'When looking at the Pecos exceptions, does the service provider type have to match? If so, I am unsure how to process as I have \'OH Other\' as my type.', '2018-07-31', '', NULL, 0, 'Pending'),
(20, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589560, '2018-07-03', 0, 'Hi, I was asked to reopen this claim and reverse copay as the benefit didnt apply as it wasnt related to CT and now i cant find any rates for my claim even though the ARC used previously was SF and the claim was Num J\'d. I dont know how to continue or price this claim still.\nThanks.', '2018-07-30', '', NULL, 0, 'Pending'),
(21, 'Chris', 'Chris@we.com', 46589561, '2018-06-15', 0, 'Hi, this claim is pos 12 OOA and the members home address is not the facility address. The conclusion I am reaching is denied non-covered but I\'m not sure if I should continue with this denial as of the POS 12. Should I continue with the denial? Thanks.', '2018-07-30', '', NULL, 0, 'Pending'),
(22, 'Chris', 'Chris@we.com', 46589562, '2018-06-15', 0, 're below question - the claim comment in this claim states disregard C2 & this claim is ineligible for viant pricing ? So C2 cant be used how should I contiinue thanks.', '2018-07-30', '', NULL, 0, 'Pending'),
(23, 'Chris', 'Chris@we.com', 46589563, '2018-07-06', 0, 'Hi, This claim has a shell contract with nothing populated in the UHC flag in the provider information screen - following SOP it asks are any of the flags populated in this field & as it is blank i have to follow no option which leads me to request Contract Clarification.\nHow should I continue, thanks.', '2018-07-27', '', NULL, 0, 'Pending'),
(24, 'Catherine ', 'Catherine @we.com', 46589564, '2018-07-24', 0, 'Got to step 17 on sop and dx is chronic, i dont know tho if the first visit was auth/referred??', '2018-07-27', '', NULL, 0, 'Pending'),
(25, 'Catherine', 'Catherine@we.com', 46589565, '2018-07-24', 0, 'This claim has pricing attached as in a co non con claim, but there is a contract \nFor professional service 130% of medicare \nNot sure which one to use here, if it is cms would i reverse code 78937-28 which is denied out 7U?? ', '2018-07-27', '', NULL, 0, 'Pending'),
(26, 'Chris', 'Chris@we.com', 46589566, '2018-07-24', 0, 'Hi, can you please direct me which ARC to use to deny the claim? XS is the remark code used but the system didnt apply so is there a more appropriate ARC to use ? Thanks', '2018-07-26', '', NULL, 0, 'Pending'),
(27, 'Myles', 'Myles@we.com', 46589567, '2018-06-29', 0, 'My clm #177 has a CES edit for unbundled to #172. The code on #172 has been paid, normally i would recover the payment and process my clm (same DEC# on both clms) but the payable on #172 is less than copay and was closed 07/3Q. Do i back out the copay and readjust payable to $0.00 with Arc 84 and then pay my clm and add full $10 copay? Or do i need to reopen #172 and deny 3G? Thanks. ', '2018-07-26', '', NULL, 0, 'Pending'),
(28, 'Thomas', 'Thomas@we.com', 46589568, '2018-07-16', 0, 'This claim has MIR reductions to apply, but line 1 is billed with modifier 79 so is excluded from MIR reductions. As Line  1 has the highest allowable , would I then process line 2 as 100% of allowable due to the modifier 79 on line 1   i.e. exclude it from consideration when applying reductions? Or would I consider the modifier 79 redundant and apply reductions to all other lines as normal? ', '2018-07-25', '', NULL, 0, 'Pending'),
(29, 'Catherine ', 'Catherine @we.com', 46589569, '2018-07-11', 0, 'Can i deny my claim a dup to clm #077,or is this were the claim cant be denied a dup,  i think that claim #072 has the wrong service provider linked, ', '2018-07-25', '', NULL, 0, 'Pending'),
(30, 'Shane', 'Shane@we.com', 46589570, '2018-07-17', 0, 'Claim is logged in area but has an OOA auth, per screen 18 its in area. Should I follow the auth and change to OOA?', '2018-07-25', '', NULL, 0, 'Pending'),
(31, 'Catherine ', 'Catherine @we.com', 46589571, '2018-07-20', 0, 'UHC remark code not defined, Examiner action on return codes spreadsheet :  If this code is received, the reject code is not defined in NICE.  Route to the appropriate COUHPReview queue by region for research.                                     Escalation Team Action:  Work with CPO to understand undefined code and to develop appropriate response for claim. there is a pricing sheet attached does this mean it has already been here for this action.\n', '2018-07-25', '', NULL, 0, 'Pending'),
(32, 'Catherine ', 'Catherine @we.com', 46589572, '2018-06-13', 0, 'Examiner requeted medical records per IC87 suspend code and theyhave been recieved and claim now has comment no mcr review required does this mean that all is good now in the claim and i can pay it out,', '2018-07-25', '', NULL, 0, 'Pending'),
(33, 'Catherine ', 'Catherine @we.com', 46589573, '2018-07-21', 0, 'Dummy group - can claim be sent to be relogged to mbr # 1383414 -02 even if its termed on 07/01/17 and dates of service 07/17/18.', '2018-07-25', '', NULL, 0, 'Pending'),
(34, 'John', 'John@we.com', 46589574, '2018-07-20', 0, 'I have a CES suspend - mAP - The primary procedure code on history line 43008877037010024 0001/1 that is associated with this add-on procedure code has received an edit with a deny or review status. Per the CES suspend/denial spreadsheet, it says \"review the history claim primary procedure code that iCES calls out...\". No procedure code is called out so I don\'t know what claim in history to check. ', '2018-07-24', '', NULL, 0, 'Pending'),
(35, 'Chris', 'Chris@we.com', 46589575, '2018-07-03', 0, 'This claim is to be reopned as the infertility SOP has been updated. With this claim infertility does not apply. So am I right to think that all codes are now payable minus all the copay off each line & apply the new benefit (A8 - O/P INFRTLTY-EXCL OOPM) ??\nWhen i Num O - E and look at members benefits I cannot find A8 where can I see how much, if any copay is to be paid.\nThanks.', '2018-07-24', '', NULL, 0, 'Pending'),
(36, 'Chris', 'Chris@we.com', 46589576, '2018-06-21', 0, 'This is an infertility claim I was asked to reopen and review as of new infertility SOP. However, I have arrived at the same outcome as before. No copay to be applied as the max has been met.\nWhen i try close this claim now it says payment less than or equal to zero & it wont close.\nHow should I conitinue?\nThanks.', '2018-07-24', '', NULL, 0, 'Pending'),
(37, 'x9a', 'x9a@we.com', 46589577, '2018-07-16', 0, 'could you confirm the copay applied is correct? ben\' map\' does not work on this claim so had to do it manually. 28 mod with tc mod billed on same claim so wasn\'t sure to apply copay once or twice for code 78817. thanks', '2018-07-20', '', NULL, 0, 'Pending'),
(38, 'Aisling', 'Aisling@we.com', 46589578, '2018-07-16', 0, 'Matching system auth my claim falls 1 day after the auth dos however the discharge date on the auth screen is blank...no related fac bill in hx..the claim has already been sent fpr review with no comments added from mcr..should i be denying this claim 3g-48??', '2018-07-19', '', NULL, 0, 'Pending'),
(39, 'x9a', 'x9a@we.com', 46589579, '2018-07-09', 0, 'please review line 8 for denial per mcr comment. i just need the correct arc & eop as cannot trace any.\n\nthanks', '2018-07-19', '', NULL, 0, 'Pending'),
(40, 'Monica', 'Monica@we.com', 46589580, '2018-07-12', 0, 'My claim is corrected to claim #418. Can i use the Reva comments in that claim to bring mine in for TF? Thanks!', '2018-07-19', '', NULL, 0, 'Pending'),
(41, 'Shane', 'Shane@we.com', 46589581, '2018-06-25', 0, 'Medicaid claim with no image bar a document on page showing billed charges\n\nDec number linked is OOP MAX \n\nNot sure what to do with this should I just treat as a no-image claim?\n\nThanks', '2018-07-18', '', NULL, 0, 'Pending'),
(42, 'Monica', 'Monica@we.com', 46589582, '2018-06-21', 0, 'CFC7 on image but no matching claim in hx so treating as a new claim. Out for TF but there\'s an eob from the PMG attached. Going through the TF SOP, it says to Update the Received Date field within claim comments with the receive date on the POTF. Is this just the paid date on the eob & just put it into the additional info date? Thanks!', '2018-07-18', '', NULL, 0, 'Pending'),
(43, 'Catherine ', 'Catherine @we.com', 46589583, '2018-07-16', 0, 'No rate listed for G9771', '2018-07-18', '', NULL, 0, 'Pending'),
(44, 'Thomas', 'Thomas@we.com', 46589584, '2017-07-25', 0, 'This claim was re-opened as the risk has been updated to be payable. There is possible proof of TF attached, but the service provider or the codes billed don\'t all match the claim. Unsure to consider this proof or not.', '2018-07-18', '', NULL, 0, 'Pending'),
(45, 'Catherine ', 'Catherine @we.com', 46589585, '2018-07-02', 0, 'Is it ok tp pay code 70773 at the global rate even tho there is a mod Q1', '2018-07-18', '', NULL, 0, 'Pending'),
(46, 'James Woods', 'James Woods@we.com', 46589586, '2018-07-06', 0, 'On the SOP says PR 22 what does this mean?', '2018-07-18', '', NULL, 0, 'Pending'),
(47, 'X9A', 'X9A@we.com', 46589587, '2018-07-06', 0, 'please advise on job aid / sop for new pay indicators. I have a pay indicator \"A\" & cannot find anyway to determine it.\n\nThanks', '2018-07-17', '', NULL, 0, 'Pending'),
(48, 'Myles', 'Myles@we.com', 46589588, '2018-06-12', 0, 'SW Region 47. Contract language from scr 18 says to see individual fac for rates. How do i identify which rate to use for this clm? thanks.', '2018-07-17', '', NULL, 0, 'Pending'),
(49, 'X9A', 'X9A@we.com', 46589589, '2018-06-12', 0, 'please advise on risk as screen 11 language indicates pp01 however as my claim are in pos 11, i should follow normal risk screen therefore capping claim?\n\nthanks', '2018-07-16', '', NULL, 0, 'Pending'),
(50, 'X9A', 'X9A@we.com', 46589590, '2018-07-09', 0, 'unsure whether this claim should be treated as seperate to claim #83 & denied per timely filing or whether it\'s a corrected claim to #83 in which case does a full recovery need done on clm #83.', '2018-07-12', '', NULL, 0, 'Pending'),
(51, 'John', 'John@we.com', 46589591, '2018-06-19', 0, 'I\'m getting to step 13 in the OOA SOP, I have a related OM in Hx (#117) which is denied for TF but when I check TF, it\'s within TF limit. There is also a REVA comment saying a corrected bill with a inpatient bill type should be submitted. There is also a MCR comment on the OM saying it\'s in-area. Can I use this MCR comment to determine my claim or would I skip that step in the SOP? Thanks!', '2018-07-12', '', NULL, 0, 'Pending'),
(52, 'Monica', 'Monica@we.com', 46589592, '2018-06-07', 0, 'CFC 7 claim. Original claim #083 seems to have had a full refund. Claim #84 is a partial dup to mine. Should i be doing the IR on this claim & processing mine as the new claim? Thanks ', '2018-07-12', '', NULL, 0, 'Pending'),
(53, 'LESLEY-ANN', 'LESLEY-ANN@we.com', 46589593, '2018-07-09', 0, 'My claim has CES Flag CMGT7 for line 12....some of the descriptions say the line is non covered and one says covered so not sure whether to pay or deny this line?', '2018-07-12', '', NULL, 0, 'Pending'),
(54, 'LESLEY-ANN', 'LESLEY-ANN@we.com', 46589594, '2018-07-03', 0, 'I have modifiers Q1 on my claim which are clinical research. The claim has patient alerts but is not transplant related. Do i need to route my claim to clinical trials or can I pay the claim?', '2018-07-12', '', NULL, 0, 'Pending'),
(55, 'John', 'John@we.com', 46589595, '2018-07-09', 0, 'I have a claim when I num J, its pulling K0 denials. In the noncovered benefit (K0) SOP, I get to none of the scenarios match your claim so I have to determine if this is a covered benefit. I benefit mapped the claim and per the DX I\'m getting SRV_CATGRY 14 but when I check the benefit available inquiry screen, I can\'t find benefit 14. Therefore I dont know what benefit I\'m looking for in ISET. Can you check to see is this benefit covered? Thanks!', '2018-07-12', '', NULL, 0, 'Pending'),
(56, 'Shane', 'Shane@we.com', 46589596, '2018-06-19', 0, 'OB-S billed with pos 22. I have an impatient facility bill partially in my dates IA #028. Is this ok to process or should it be denied step 8 image v nice?\n\nThanks', '2018-07-11', '', NULL, 0, 'Pending'),
(57, 'Shane', 'Shane@we.com', 46589597, '2018-06-22', 3, 'Claim was in a pend status for provider sanction and has a suspend in comments.\n\nprovider type is 70 per NPI site the speciality is clinic/centre radiology.\n\nCan I still pay this per pecos exceptions? I checked the provider type document and cant find a type for clinic/centre rad\n\nThanks', '2018-07-10', '', NULL, 12, 'Assigned'),
(58, 'David', 'David@we.com', 46589598, '2018-07-02', 4, 'Cob \nbox 10b selected with aaa eob\nmy claim has 1 line which was denied on the eob for incorrect dx.  \nShould this claim be denied as there was no payable on the auto eob for my code?', '2018-07-10', '', NULL, 13, 'Assigned'),
(59, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589599, '2018-05-02', 5, 'Claims needs reset by manager', '2018-07-10', '', NULL, 14, 'Assigned'),
(60, 'Veena', 'Veena@we.com', 46589600, '2018-04-17', 6, 'claim back from audit as pippa rvw complete, there is comments from RA rvw requesting med records, do i deny claim requesting records or close it per pippa audit', '2018-07-09', '', NULL, 14, 'Assigned'),
(61, 'Chris', 'Chris@we.com', 46589601, '2018-06-21', 7, 'I can\'t make out the contract language & have no clue how I should price this claim.\nThanks.', '2018-07-06', '', NULL, 10, 'Assigned'),
(62, 'Monica', 'Monica@we.com', 46589602, '2018-06-23', 8, 'Pricing sheet has denied code with arc HD but there is no manul arc for it on spreadsheet. Not sure what arc to use. Thanks ', '2018-07-06', '', NULL, 10, 'Assigned'),
(63, 'David', 'David@we.com', 46589603, '2018-06-28', 9, 'WA claim\nCES edit CDTPR\nRecovery needed on line 2 of claim 379009701211 but copay exceeded payable for that line.\nshould the recovery go ahead as normal or should the copay be backed out and applied to the new claim?', '2018-07-06', '', NULL, 10, 'Assigned'),
(64, 'Shane', 'Shane@we.com', 46589604, '2018-06-22', 3, 'Risk\n\nLine 1 &2 are payable per nuclear medicine for line 3&4 radiology codes  are capped per PC0147 but as they have been billed with TC mod for same DOS can we pay these also or should they be capped?', '2018-07-05', '', NULL, 10, 'Assigned'),
(65, 'David', 'David@we.com', 46589605, '2018-06-18', 4, 'risk Chemo Diagnosis with U indicator in PC0147.\nstep: Is there a chemo claim billed on same date of service as your claim? \n\nQuestion:  Could this be a MB with a Chemo diagnosis in any position or does it have to be a TY?', '2018-07-05', '', NULL, 14, 'Assigned'),
(66, 'Shane Meehan', 'Shane Meehan@we.com', 46589606, '2018-07-02', 5, 'Being directed to screen 11 for risk\n\nCan I use the family planning and abortion to pay the claim  DX is missed Abortion not sure if this would still apply', '2018-07-05', '', NULL, 13, 'Assigned'),
(67, 'Chris', 'Chris@we.com', 46589607, '2018-06-22', 6, 'Hi, could claim #14 / #13 OJ\'s be used as previous ER claims & my claim as a follow up visit step 17 OOA ? Dx on my claim is preventitive so I dont know if you can class this as similar Dx if they relate?', '2018-07-05', '', NULL, 8, 'Assigned'),
(68, 'Zeta', 'Zeta@we.com', 46589608, '2018-06-28', 7, 'My claim has KO denial for both codes and per the SOP it tells me to check ISET but there are no benefits in detail adjustment screen so do I deny Non covered? \n\nNW claim', '2018-07-04', '', NULL, 9, 'Assigned'),
(69, 'Monica', 'Monica@we.com', 46589609, '2018-04-30', 8, 'Pricing sheet is denying all lines with arc XS but this isn\'t listed in excel sheet. Just wondering what manual arc to use for this? Thanks ', '2018-07-04', '', NULL, 4, 'Assigned'),
(70, 'Monica', 'Monica@we.com', 46589610, '2018-06-04', 9, 'Can i just double check per the contract that i\'ll be paying at 127% medicare? This bit of text put me off a bit -  W/OUT GEOGRAPHIC PRACTICE COST INDEX (GPCI) ADJUSTMENT MADE TO RVU\'s. Thanks ', '2018-07-03', '', NULL, 5, 'Assigned'),
(71, 'Chris', 'Chris@we.com', 46589611, '2018-05-15', 3, 'Hi, this is a misdirected claim the carve out reached is U- see screen 11 but I\'m finding it hard to figure out which carve out on screen 11 applys to my code if any. Can u please have a wee look to see if any apply.\nThanks.', '2018-07-03', '', NULL, 6, 'Assigned'),
(72, 'Myles', 'Myles@we.com', 46589612, '2018-06-21', 4, 'This clm is POS 21 and OOA. No fac or auth however MCR has cmt that it is related to AJ clm #074, this has been denied 07/3G. There is another AJ #072 which looks related and has been processed can I process my clm using #072? thanks.', '2018-07-03', '', NULL, 6, 'Assigned'),
(73, 'Chris', 'Chris@we.com', 46589613, '2018-05-09', 5, 'Hi, this claim has 2 codes called out in the carecore auth & one of the codes is in a pend status there is a comment there from MCR saying I need specific med records for this code.\nI am reaching step 9 of auth SOP & it doesnt call out steps for me to follow to request the information. \nSo am I correct to pay other codes on the claim deny that code with ARC 74 & request AI with letter AI-08  ? Thanks', '2018-07-03', '', NULL, 2, 'Assigned'),
(74, 'X9A', 'X9A@we.com', 46589614, '2017-06-18', 6, 'please advise risk arrangement as unable to determine same for both claims - thanks.', '2018-07-02', '', NULL, 2, 'Assigned'),
(75, 'X9A', 'X9A@we.com', 46589615, '2018-06-27', 7, 'different dos on claim, half would be in area per IA & other half of the codes OOA per AA.\n\nsame scenario for both claims. Which do i use?', '2018-07-02', '', NULL, 3, 'Assigned'),
(76, 'Catherine ', 'Catherine @we.com', 46589616, '2018-07-25', 8, 'Claim seems to have ongoin illness cyctic fibrosis and was goin to bring it in area, but noticed place of service 23 comes b4 that on sop would i leave this claim out and pay out of area.', '2018-07-02', '', NULL, 3, 'Assigned'),
(77, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589617, '2018-06-14', 9, 'I am denying this claim for eligibility but when I put the LC/STS in this comes up;\n\nOCN IS IN INCORRECT FORMAT.PLEASE REVIEW   ', '2018-06-28', '', NULL, 7, 'Assigned'),
(78, 'Dean', 'Dean@we.com', 46589618, '2018-05-24', 3, 'My claim is a corrected claim to  IB 078 but is being flagged for timely filing per the SOP there is POTF attached but the image quality is low and I cant determie which date is appriate for the last action date on the claim', '2018-06-28', '', NULL, 7, 'Assigned'),
(79, 'Aisling ', 'Aisling @we.com', 46589619, '2018-05-16', 4, '**NW region (43) code 81771 code found in 2018 clinical lab folder but no price listed 0.000...!the indicator on the spreadsheet is L I\'m not sure if that makes a difference or not,should i just use default % for this code?', '2018-06-28', '', NULL, 7, 'Assigned'),
(80, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589620, '2018-06-11', 5, 'When i go to pay out claim this comes up\n\nERROR: PAYEE ADDRESS INCOMPLETE, A MANUAL CHECK REQUIRED IF FOREIGN ADDRESS  \n\nUnsure of what to do', '2018-06-28', '', NULL, 1, 'Assigned'),
(81, 'Zeta', 'Zeta@we.com', 46589621, '2018-06-21', 6, 'I have a corrected claim to #077. two of my codes are capped but the other code (SG011) is Undetermined risk with note - Sutter P & P. The claim in hx paid this code and I will more than likley  Arc DA it if it\'s payable.', '2018-06-28', '', NULL, 5, 'Assigned'),
(82, 'Catherine', 'Catherine@we.com', 46589622, '2018-06-22', 7, '128 - UFCW PROVIDER - review screen 11 for exceptions regarding employer group number.\nDoes this apply to my claim never seen this before.\nrisk U in screen 17', '2018-06-28', '', NULL, 6, 'Assigned'),
(83, 'Catherine ', 'Catherine @we.com', 46589623, '2018-06-25', 8, 'On step 17 ooa sop, dx is chronic, - Yes - Was the first visit authorized? \nHow do i tell if the first visit was authorized?', '2018-06-28', '', NULL, 8, 'Assigned'),
(84, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589624, '2018-06-06', 9, 'Claim needs to be reset by manager', '2018-06-27', '', NULL, 9, 'Assigned'),
(85, 'Rebecca ', 'Rebecca @we.com', 46589625, '2018-04-23', 3, 'Claim is messed up --- $788.00 billed charges only showing as $28.00 in NICE --- upped to $788 by adding minus figure to zero line but not sure this is correct - thinking it might need relogging but not sure what is to be relogged.  Two different images - pricing have priced \'corrected claim\' but seems original claim was logged ----- please advise.  ', '2018-06-27', '', NULL, 4, 'Assigned'),
(86, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589626, '2018-04-09', 4, 'This claim is a medicaid claim and the provider in box 31 is linked whereas the medicaid DEC should be linked.\nIt looks like there is no available DEC # that matches the claim.\nMedicaid claims dont go to PIM, are you able to find one?\nThank you v much.', '2018-06-25', '', NULL, 12, 'Assigned'),
(87, 'Thomas', 'Thomas@we.com', 46589627, '2018-06-05', 5, 'I have a CO non par claim with UHZX suspend and an undefined remark code. The undefined iCES rmk code is XS . Just wondering what the correct manual ARC to use is? Thanks ', '2018-06-22', '', NULL, 11, 'Assigned'),
(88, 'Chris', 'Chris@we.com', 46589628, '2018-06-18', 6, 'Hi, I am reaching U carve out see screen 11 & I don\'t think any of the carve out\'s in this screen are applicable is that correct? The only one I think may apply could be -\n ENDOSCOPIC STUDIES: INPT/OUTPT (W/ OR W/O BIOPSY)    PRO-  M \n\n\nThanks for your time.', '2018-06-21', '', NULL, 11, 'Assigned'),
(89, 'Chris', 'Chris@we.com', 46589629, '2018-06-11', 7, 'I am getting to U - Nuclear MED see screen 11 for risk in screen 14 & I don\'t think this applies to my claim as it states Tech/Fac in the comment section.\nHow should I continue, do I move tpo the next carve out if this doesnt apply? Thanks.', '2018-06-21', '', NULL, 12, 'Assigned'),
(90, 'Aisling', 'Aisling@we.com', 46589630, '2018-05-19', 8, 'Mcr comments saying to change the claim to an MB?the claim has been changed back an forth from an MB to AB not sure whay it should be with comments? this is a hospice claim do we deny this at cob or pricing?', '2018-06-21', '', NULL, 13, 'Assigned'),
(91, 'Catherine', 'Catherine@we.com', 46589631, '2018-06-15', 9, 'following ooa sop, step 9, Is the member an AZ passport member? \nWhat does this mean ? \nmember is AZ ', '2018-06-20', '', NULL, 14, 'Assigned'),
(92, 'Lauren', 'Lauren@we.com', 46589632, '2018-06-13', 3, 'I have a KO denial my other lines have been denied by CES and im going to deny my line with ARC 4J, unsure of what denial letter and lc/sts to use.', '2018-06-19', '', NULL, 14, 'Assigned'),
(93, 'Catherine ', 'Catherine @we.com', 46589633, '2018-06-13', 4, 'I never did fertility before usto send them to a Queue, First fertility claim, should it be capped as only the primary dx has to be fertility??', '2018-06-19', '', NULL, 10, 'Assigned'),
(94, 'Monica', 'Monica@we.com', 46589634, '2018-05-21', 5, 'CFC 7 claim in nice. There\'s nothing in hx for it but there\'s a letter from us in the attachments saying it was ineligible for the dos. i\'ve done a member search and there\'s nothing i can find. Should i be treating it as a new claim or corrected? It would be out for TF if treated as a new day claim. Thanks ', '2018-06-19', '', NULL, 10, 'Assigned'),
(95, 'Catherine', 'Catherine@we.com', 46589635, '2018-06-13', 6, 'just double checking this contract would i pay my codes at 70%, Thx.', '2018-06-18', '', NULL, 10, 'Assigned'),
(96, 'Zeta', 'Zeta@we.com', 46589636, '2018-06-08', 7, 'I have come to a risk carve out \'U\' for the A9700 and J2787 codes on my claim which is for screen 11. Per the language I am unsure whether to follow the H risk as I don\'t have a TC. ', '2018-06-15', '', NULL, 10, 'Assigned'),
(97, 'aisling', 'aisling@we.com', 46589637, '2018-06-04', 8, 'claim needs contract clar', '2018-06-14', '', NULL, 14, 'Assigned'),
(98, 'Aisling', 'Aisling@we.com', 46589638, '2018-06-04', 9, 'need contract clar on this claim no contract for service provider', '2018-06-14', '', NULL, 13, 'Assigned'),
(99, 'Dean', 'Dean@we.com', 46589639, '2018-06-12', 3, 'I have a claim with a matching Auth that was authed on 08/07/18 but it has a note in the comments from 08/08/18 that says to deny the entire stay, not sure if I auth the claim or deny it not medically indicated or not covered?', '2018-06-14', '', NULL, 8, 'Assigned'),
(100, 'Myles', 'Myles@we.com', 46589640, '2018-05-31', 4, 'To me this (#097) looks like it should be treated as c/r to #012. (mod 91 addeed and 7 units billed for 88380 with Dx pointer BA)   #012 had some lines denied as dups and some for CES. the ces edits were for unbundled to line 8 which was denied as a dup. I have clm #097 if i treat as c/r then it\'s out for timely filing...should i process 097 or reopend 012? thanks.', '2018-06-14', '', NULL, 9, 'Assigned'),
(101, 'Thomas', 'Thomas@we.com', 46589641, '2018-05-09', 5, 'I have a matching system auth and a related facility AN #10 denied non covered, but the dx is Urgent/emergent. Do I follow the auth or process OOA as the member is urgent/emergent ?', '2018-06-13', '', NULL, 4, 'Assigned'),
(102, 'Monica', 'Monica@we.com', 46589642, '2018-04-05', 6, 'CFC7 Claim. Totally confused on it! The OCN on the image is for claim #79 which was denied for TF but they\'re also referencing claim #82 which they say this code unbundles to. Not sure if this is out for TF, can get paid or if IR can be done & to what claim! Thanks in advance!!', '2018-06-13', '', NULL, 5, 'Assigned'),
(103, 'Monica', 'Monica@we.com', 46589643, '2018-05-29', 7, 'My claim is POS 21. Auth for my dos says approval but also has a note that it\'s not covered. Not sure what bit to go with! Thanks ', '2018-06-13', '', NULL, 6, 'Assigned'),
(104, 'Shane Meehan', 'Shane Meehan@we.com', 46589644, '2018-05-17', 8, 'Claim is a dupe to #089 in history it was paid and recovered per A/D Downadjust what outcome does that have on my claim can I go ahead and pay or dupe it?\n\nIf payable its out for TF can i use the orignal as a last action dates there is some docs attached but I dont think they are valid', '2018-06-13', '', NULL, 6, 'Assigned'),
(105, 'Aisling', 'Aisling@we.com', 46589645, '2018-05-25', 9, 'Can you please review claim comments there is an NDM syaing to deny the claim per billing info and box 32 on the image is highlighted, but a service provider has been linked since then. Should I still follow NDM comments or process the claim?', '2018-06-13', '', NULL, 2, 'Assigned'),
(106, 'Zeta', 'Zeta@we.com', 46589646, '2018-05-24', 3, 'I have 2 claims in Hx the same as mine and I am unsure how the original #004 was adjusted or what was done with it. ', '2018-06-12', '', NULL, 2, 'Assigned'),
(107, 'Catherine ', 'Catherine @we.com', 46589647, '2018-05-14', 4, 'Would i deny lines 1,2,3 with DA and pay line 4 $118.94?? its a corrected claim to 009 i think. thx ', '2018-06-12', '', NULL, 3, 'Assigned'),
(108, 'Aisling ', 'Aisling @we.com', 46589648, '2018-06-08', 5, 'Could you please review mod 32 on this claim?', '2018-06-12', '', NULL, 3, 'Assigned'),
(109, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589649, '2018-06-04', 6, 'My claim has been denied by CES as dup to claim #20 but box 32 and 33 are different but doctors are the same. Also my claim is truely in Area and #20 is OOA??', '2018-06-12', '', NULL, 7, 'Assigned'),
(110, 'Chris', 'Chris@we.com', 46589650, '2018-04-18', 7, 'This claim is related to clinical trials as of the system auth & as it is non-par I have followed the SOP & I have to price from the corp drive for these codes. \nLine #2 0179T has no suitable carve out on the carrier pricing s/sheet that matches my locality from box 32 on my claim so I am not sure how to price this?\nHow should I continue to price this line? \nThanks.', '2018-06-12', '', NULL, 7, 'Assigned'),
(111, 'Catherine ', 'Catherine @we.com', 46589651, '2018-05-21', 8, 'Im so unsure if there is proof attached to this for timely filing.(maybe the cover letter )??', '2018-06-08', '', NULL, 7, 'Assigned'),
(112, 'Dean', 'Dean@we.com', 46589652, '2018-04-20', 9, 'My claim has the ces alert \"ICES STANDALONE REQUIRED\", the sop has directed me to contact my sme', '2018-06-08', '', NULL, 1, 'Assigned'),
(113, 'Aisling ', 'Aisling @we.com', 46589653, '2018-05-15', 3, 'Risk: see screen 11 not sure which one it is?', '2018-06-07', '', NULL, 5, 'Assigned'),
(114, 'Catherine ', 'Catherine @we.com', 46589654, '2018-05-23', 4, 'Cob indic Q, i cant find this one on the sop, not sure wat it means, also just checking does MIR still only apply to secure claims??', '2018-06-07', '', NULL, 6, 'Assigned'),
(115, 'Catherine ', 'Catherine @we.com', 46589655, '2018-05-05', 5, 'This claim is in area and is inpatient place of service 21, no other claims in hx are inpatient no auth/fac but there is related claims with place of service 22, followed auth sop and seems ok to pay per that and there is a comment in too, i think it should be denied as incorrect place of service tho.', '2018-06-07', '', NULL, 8, 'Assigned'),
(116, 'Chris', 'Chris@we.com', 46589656, '2018-05-24', 6, 'Hi there is a doccument attached to this claim & I am wondering can it be used for POTF? I can\'t locate the PMG name anywhere on the doccument only the service provider so I was thinking it wouldnt be valid is this correct?\nThank you .', '2018-06-06', '', NULL, 9, 'Assigned'),
(117, 'Aisling', 'Aisling@we.com', 46589657, '2018-04-13', 7, 'claim was routed to mcr and they left a comment POSSIBLE ERROR IN POS BILLED, its pos 23 should this comment be ignored??how should i proceed?', '2018-06-06', '', NULL, 4, 'Assigned'),
(118, 'X9A', 'X9A@we.com', 46589658, '2018-05-29', 8, 'Claim has a GY mod & when I look this up on KL, it should deny yet ces didn\'t flag it on my claim. Can you confirm whether i am able to pay line #8.\n\nGY: Item or service statutorily excluded, does not meet the definition of any Medicare benefit or for non-Medicare insurers, is not a contract benefit ...', '2018-06-06', '', NULL, 12, 'Assigned'),
(119, 'X9A', 'X9A@we.com', 46589659, '2018-04-18', 9, 'LIFEPRINT: This claim previously denied 3G-80 PER AUTH & now the auth has resended. I am unsure what date to pay the claim from. The facility has interim bills & corrected billing & therefore i\'m unsure whether we use 1 of these or the date that the auth resended. Auth #3924143', '2018-06-06', '', NULL, 11, 'Assigned'),
(120, 'Catherine', 'Catherine@we.com', 46589660, '2018-05-15', 3, 'I sent this claim for u&c and then i num j the claim and the rate i got for code 73771-28 is $24.28 and u&c rate is $28.00, should i go with the system one?? ', '2018-06-05', '', NULL, 11, 'Assigned'),
(121, 'Dean', 'Dean@we.com', 46589661, '2018-05-24', 4, 'My claim has language in screen 18 that says reimbursement shall be according to the dept supervisors copy of the fee schedule but theres no fee schedule loaded i\'m not sure how to price the claim', '2018-06-05', '', NULL, 12, 'Assigned'),
(122, 'Chris', 'Chris@we.com', 46589662, '2018-05-21', 5, 'Hi Angela,\nOn this claim I have a CES edit saying that line #2 is a dup to another code billed on the same day by same provider.\nOn claim #17 my code G8002 is billed with mod TC this time and I seen on encoder that this code can be billed 2 times per day.\nAm I ok to bypass this CES edit or should I allow it to stand.\nThanks.\n', '2018-06-01', 'Dates are entered into Nice incorrectly. please update Nice to match the imahe and resend for CES', '2018-06-05', 13, 'Answered'),
(123, 'Zeta', 'Zeta@we.com', 46589663, '2018-05-15', 6, 'I have a claim that is C/R to claim #079. the provider has submitted line 1 globally whereas on the original it wa billed with Mod TC. Am I right to DA lines 2 & 3 and pay the difference between line 1 on both claims. \nUnsure If I should reverse the copay on the original or bypass on my claim.', '2018-05-31', 'DA line  and  and pay the difference. bypass the copay as its already paid on the original and this is ok', '2018-06-05', 14, 'Answered'),
(124, 'Catherine ', 'Catherine @we.com', 46589664, '2018-05-25', 7, 'pricing is taking this code out as duplicate i dont think it is can i num k and pay per eob??', '2018-05-31', 'Send to UHPReview with  comment and routing comment - please price,  is NOT a duplicate', '2018-06-05', 14, 'Answered'),
(125, 'Zeta', 'Zeta@we.com', 46589665, '2018-05-09', 8, 'I have a OOA claim with a date span. both my dates are covered by related AM\'s but I have a related AB that was brough in area and capped which should be processed as OOA per the AM\'S. I have multiple surgery codes billed and I am unsure if MSR applies.', '2018-05-30', 'Rework the capped OB to process correctly OOA. verify codes and dates of service, if you have multiple codes for srv grp  that have an MSR indicator of  - this means multiple surgery applies', '2018-06-01', 10, 'Answered'),
(126, 'Dean', 'Dean@we.com', 46589666, '2018-05-15', 9, 'My claim needs manual pricing with repricing method 17 and indicator FX the manual arc says V0 (Zero) but nice is telling me this arc is invalid, how should I deny the line?', '2018-05-30', 'Use Manual N', '2018-05-31', 10, 'Answered'),
(127, 'Monica', 'Monica@we.com', 46589667, '2018-04-17', 3, 'CFC 7 claim. Ces is giving me an edit for line 7 that it unbundles to a code on the previous claim but as i\'ll be doing IR should i ignore this edit? The code that it unbundles to is also billed on my claim so i\'m a bit confused on it ', '2018-05-30', 'Bypass the edit as you are doing an IR, the edit sounds like it should also apply on your  but as its not called out against your  - we cant apply it', '2018-05-31', 10, 'Answered'),
(128, 'Catherine', 'Catherine@we.com', 46589668, '2018-04-19', 4, 'Claim is a dup to #002, but there is a comment \"risk overturn per cap 300 process\",,in my claim #003, never seen this before should i pay this claim??\nAlso when would you apply interest if i do pay this ??', '2018-05-30', 'Rework the original  - make it PP risk with CR risk reason and continue to pay/deny as normal. keep   as pp rish with CR risk reason and deny it as a dup to  ', '2018-05-31', 10, 'Answered'),
(129, 'Monica', 'Monica@we.com', 46589669, '2018-04-16', 5, 'I have Ces edit IC73 for one of my codes. I\'ve followed the sop for it and i don\'t think the description is on the spreadsheet. Can you just double check that i\'m right to be denying the 2nd line per step 4 of the sop? Thanks ', '2018-05-29', 'Yea, the test is not listed as stated on the image - continue to deny', '2018-05-31', 14, 'Answered'),
(130, 'Catherine ', 'Catherine @we.com', 46589670, '2018-05-04', 6, 'This claim is paying out zero when num j, also claim type maps to claim type OX, but recently changed from this unsure how to continue ', '2018-05-29', ' is an OB due to the primary OB in history for same provider/DOS. Deny G stating the  is priced at .', '2018-06-01', 13, 'Answered'),
(131, 'catherine ', 'catherine @we.com', 46589671, '2018-05-09', 7, 'Claim has reject code T1 i cant see any UHXX suspend reason code, following sop would i be right to send this claim for medical records as it is over $2000??', '2018-05-28', 'SOP needs to be updated to state T reject with any other UHXX or NO UHXX suspend - follow step  of manual U&C pricing section.', '2018-06-05', 8, 'Answered'),
(132, 'Dean', 'Dean@we.com', 46589672, '2018-04-20', 8, 'I have a claim thats bee nrouted to transplant and has member alerts but comments from TP saying its not related, the auth says \"authorized transplant\" but covers my DOS, can I use the auth and proceed with the claim?', '2018-05-28', 'Email sent to TP SME, keep pended awaiting response\n\n*******************************\n\n being pulled by TP SME to enter correct comments and route for review', '2018-05-29', 9, 'Answered'),
(133, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589673, '2018-05-08', 9, 'This claim has no image and I am processing based on the information loaded in NICE.I think I am correct in saying that my claim is a dup to #20 and I should process 20 with earliest recieved date & dup 19 to it is that correct?\nThanks.', '2018-05-28', 'Yea, Process   as the only . Deny   as a Dup. Not sure what has happened here, looks like the image was taken away and then relogged.', '2018-05-28', 4, 'Answered'),
(134, 'Thomas', 'Thomas@we.com', 46589674, '2017-11-13', 3, 'This claim was re-opened from Lifeprint. System denied the claim ineligible and the member is eligible now. Not sure if the sytem processed incorrectly at the time and now the system is flagging for interest. Unsure of how to apply interest. ', '2018-05-25', 'Pay from received date - going by member eligibility screen - this member has been eligible from  or before and each update has been an eligible one since. this  should have been processed as eligible', '2018-05-28', 5, 'Answered'),
(135, 'Shane', 'Shane@we.com', 46589675, '2018-03-27', 4, 'Radiation therapy claim POS 21 can I deny this per step 8 image v nice for the OU-S billed claim #70?\n\nI also have a AA claim #047 in date span paid and an OOA auth.\n\nBoth claims are related to mines\n\n', '2018-05-25', 'Follow the AA and link the OOA inpatient auth. the patient was inpatient at the time and as the AA is present for your POS  - we cant deny per step .', '2018-05-28', 6, 'Answered'),
(136, 'Shane ', 'Shane @we.com', 46589676, '2018-05-07', 5, 'Please review page 2 for POTF, seems to be from a clearing house not sure if this can be used as a valid doc.\n\nOnly payable line is line 2 - 77002-28\n\n', '2018-05-24', 'Please use check date : // as either the LDOS or the Rcvd date for TF calculations, this is a PMG EOB', '2018-05-29', 6, 'Answered'),
(137, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589677, '2018-05-22', 6, 'I have 3 payable lines on my claim. Copay only went off 2 lines but not the 3rd...do I manually take the rest of the copay?', '2018-05-24', 'Benefit map the  to see if the copay applies to , if yes - manually apply with Arc J', '2018-05-28', 2, 'Answered'),
(138, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589678, '2018-05-03', 7, 'This claim should be forwarded to PBHI for processing per MCR comments...unsure of the process?', '2018-05-23', 'Can you please route this back to MCR to review the  again and enter the following comment too:\n\n is not consider PBHI and should be processed as medical plan responsibility', '2018-05-28', 2, 'Answered'),
(139, 'Monica', 'Monica@we.com', 46589679, '2018-05-01', 8, 'Have the MUH & MEH edit for the same code on my claim & the hx claim. Can i just double check that i\'d be right in requesting a recovery for line one on claim #197? Thanks ', '2018-05-23', 'Both edits are correct to be on the code.\n\nFor the mUH edit,  # has a different provider, so this edit should be bypassed.\n\nFor the mEH edit, line  on # doesn\'t have the appropriate modifier, , and a recovery should be made on this service.', '2018-05-23', 3, 'Answered'),
(140, 'Chris', 'Chris@we.com', 46589680, '2018-04-06', 9, 'RISK SCREEN is directing me to use screen 11.\n\nIs this the carve out I have to use ??\nHOSPITAL BASED PHYSICIANS (RADIOLOGY & PATHOLOGY) IP\nH RISK HS01/Y \n\nIs this ok to follow or is there another one i should follow.\nThanks.', '2018-05-23', 'Yes this is the correct risk arrangement. ', '2018-05-23', 3, 'Answered'),
(141, 'Aisling', 'Aisling@we.com', 46589681, '2018-05-01', 3, 'I have two APs in history #003/#004 they are both related to my claim but one is denied not covered and the other one is denied provider writeoff..per step 12 in OOA,which one should i be following?how should i move forward?', '2018-05-23', 'You should follow the outcome of the facility .', '2018-05-23', 7, 'Answered'),
(142, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589682, '2018-05-10', 4, 'There is $14 copay on my claim but there is also 20% co insurance...which do I apply?', '2018-05-22', 'Please verify #\n\n*******************************\n\nPlease apply the $. copay only, per the EOC . applies', '2018-05-23', 7, 'Answered'),
(143, 'x9a', 'x9a@we.com', 46589683, '2018-04-09', 5, 'please verify whether this claim needs denied 7Y per claim comment or rather relogged per difference in information from hcfa to nice. claim is quite hard to read.', '2018-05-22', 'Unable to determine correct Dx as this image is unreadable.\n\n should be V per the image vs nice SOP', '2018-05-28', 7, 'Answered'),
(144, 'X9A', 'X9A@we.com', 46589684, '2018-04-04', 6, '** LIFEPRINT **\n\nPLEASE REVIEW ATTACHMENTS FOR POSSIBLE PROOF OF TIMELY FILING. ', '2018-05-22', 'No valid source available. Unable to accept POTF.', '2018-05-23', 1, 'Answered'),
(145, 'Chris', 'Chris@we.com', 46589685, '2018-04-30', 7, 'Hi Ryan,\nI have a misdirected claim here with a possible related claim in Hx same DOS as my POS 81 OC, which is an AO which would change the claim type on my claim if it is deemed as related.\nDo you think that the AO can be used as a related claim there are some indications it may be but I\'m not sure. \nThanks.', '2018-05-22', 'Yes you can treat the AO as related.\n\nBoth s are to do with throat infections or virus. The services billed on your  is a test. The services on the AO is evaluating the test from your .', '2018-05-22', 5, 'Answered'),
(146, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589686, '2018-05-09', 8, 'Claim is reponed now.\nMy claim has been billed with multiple Surgery codes...unsure if Multiple Surgery Reductions apply??', '2018-05-21', ' is closed.', '2018-05-22', 6, 'Answered'),
(147, 'Zeta', 'Zeta@we.com', 46589687, '2018-05-15', 9, 'I am unsure if claim #31 is a dup as I cannot locate an image for it and I am unable pull it up through processing.\n\n\nIt appears an exact match in NICE.', '2018-05-21', 'Continue to process your .  # will need to be J as it was logged in-error. I will get the image logged for that , so it can be closed.\n\n', '2018-05-22', 8, 'Answered'),
(148, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589688, '2018-05-15', 3, 'My claim has a non covered auth but there is also a reworked AN in history...unsure which one to follow?', '2018-05-21', 'Per step  of the OOA SOP, you should use the non-covered auth for your ', '2018-05-22', 9, 'Answered'),
(149, 'Catherine ', 'Catherine @we.com', 46589689, '2018-01-29', 4, 'when should i apply interest from on this claim?? ', '2018-05-21', 'Apply interest from received date.', '2018-05-22', 4, 'Answered'),
(150, 'Catherine', 'Catherine@we.com', 46589690, '2018-04-23', 5, 'Should my claim be a corrected claim to #007 seems like a duplicate but F10 in screen 2 is not taking out the code as it does in claim #007.', '2018-05-18', 'Yes treat your  as a corrected , as CES hasn\'t denied the lines. \n\nThis has caused a finanical impact and should be treated a corrected .', '2018-05-21', 12, 'Answered'),
(151, 'Myles', 'Myles@we.com', 46589691, '2018-05-11', 6, 'This clm is POS 12 and logged as OOA (AC) could you have this reviewed with documentation team to see if it can be brought in area based on POS 12, thanks.', '2018-05-15', ' is closed.', '2018-05-18', 11, 'Answered'),
(152, 'Paddy', 'Paddy@we.com', 46589692, '2018-05-11', 7, 'Per MUH CES Edit, please verify if rendering physician npi can be used if group name used in box 31 as unbundled code potentially with different physician to clm #24', '2018-05-11', 'As this is the same provider, request a recovery on the histroy  # line .', '2018-05-17', 11, 'Answered'),
(153, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589693, '2018-04-09', 8, 'I have an exact match dup to claim in history #39, that claim is the original claim and my claim should have been dupped to claim #39 and claim #39 should be processed and payable. Unsure if I should reopen claim in history and pay as normal and dup my claim to it.', '2018-05-11', 'You should deny # J, as the  shouldn\'t have been logged and process # for payment.', '2018-05-14', 12, 'Answered'),
(154, 'Chris', 'Chris@we.com', 46589694, '2017-10-25', 9, 'I need to pay interest on this claim and I cannot see claim comments after the second page so I dont know what happened earlier on the claim.\nShould I pay interest from rcvd date as no additional info was needed for me to pay the claim? ', '2018-05-11', 'Ticket INC has been submitted to get a full copy of  comments\n\n comments have been emailed to examiner.', '2018-05-14', 13, 'Answered'),
(155, 'Paddy', 'Paddy@we.com', 46589695, '2018-04-24', 3, 'my clm is cr to clm #1 which has been downadjusted. Does the downadjusted clm (1) need reopened to remove copay as this will need put onto my clm.\n\nalso, how do we calculate the recovery amount with upadjust/downadjust scenarios as these are starting to become more frequent.', '2018-05-11', 'Yes you will need to reopen the original  to reverse the copay and apply it to your . \n\nOn the original , everything was recovered except line  - -. So this code will need to be DAed on your .', '2018-05-14', 14, 'Answered');
INSERT INTO `question` (`q_id`, `examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `cat_id`, `question_txt`, `q_date`, `response`, `resp_date`, `sme_id`, `status`) VALUES
(156, 'Dean', 'Dean@we.com', 46589696, '2018-04-24', 4, 'My claim is a corrected claim to claim 009 but 009 has been down adjusted and has had a recovery done on it.I\'m not sure how to work my claim since I cant determine if the adjustments to the original were made correctly.', '2018-05-10', 'Process your  as a corrected to #. You will need to DA line  and process the remaining lines as normal. Also you will need to reverse copay on # and reapply it to your .', '2018-05-14', 14, 'Answered'),
(157, 'Myles', 'Myles@we.com', 46589697, '2018-04-09', 5, 'This clm looks to have code 78817 PI billed but the PI falls on the line and has been logged in Nice as 78817 PT. I have changed the mod in the back screen but CES still denies for the PT mod with mod XP...do i go with the CES denial or have it relogged?', '2018-05-09', 'The CES system was still reading the PT modifier, I changed it in CES and reviewed it again. CES has came with with no edits. ', '2018-05-10', 10, 'Answered'),
(158, 'Chris', 'Chris@we.com', 46589698, '2018-03-26', 6, 'This medicaid claim is over 3 years old & has no EOB or it is not corrected to any claim.\nAm I ok toi deny this as normal for TF - & Is it the renderring provider contract that may have special TF limits for future reference? I can find no renderring pvr anyway just to know for again.\nThanks.', '2018-05-09', 'Yes continue to deny this  for TF.', '2018-05-09', 10, 'Answered'),
(159, 'Catherine ', 'Catherine @we.com', 46589699, '2018-04-16', 7, 'Can i deny my claim a dup,(clam #017 denied 07/3V) image does not indicate corrected replacement claim', '2018-05-08', 'No, continue to process your  as a corrected.\n\n # was billed as ICD and yours has been corrected to ICD', '2018-05-09', 10, 'Answered'),
(160, 'Aisling ', 'Aisling @we.com', 46589700, '2018-04-24', 8, '(*REGION SW 47*)  Ces edit CDPTR is flagging on my claim but following the cdptr job aid I cant see where the other claims are per step 3 of the job aid,how should i proceed with this!!', '2018-05-04', 'Step  of the CDPTR job aid instructs you to use the ICN to locate the history. \n\nUsing this you can determine that the history  has been paid. The  was paid yesterday, if the cheque run hasn\'t started, then please reopen the  and deny it per step ', '2018-05-08', 10, 'Answered'),
(161, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589701, '2018-04-12', 9, 'I am corrected claim to claim #2 in history. Claim #2 was originally paid out and then SAM EDIT has denied the payable line saying to resubmit with NDC on line 7. Unsure if I should pay my claim as normal or ARC DA my claim?', '2018-05-02', 'There is no NDC on your , however, that process is not part of our process. You should process your  as normal.', '2018-05-04', 14, 'Answered'),
(162, 'Dean', 'Dean@we.com', 46589702, '2017-07-23', 3, 'Theres an EOB aatached otthi sclaim but I\'m not sure if I can use it for timely filing as the DOS dont seem to match my claim?', '2018-05-02', 'The DOS on the proof doesn\'t match your , so shouldn\'t be considered.', '2018-05-04', 13, 'Answered'),
(163, 'catherine', 'catherine@we.com', 46589703, '2018-04-12', 4, 'should this claim be treated as non contracted, change indicator etc.??', '2018-05-02', 'Route this cliam to UHPReview for pricing with the following comment:\n\nPlease price  using Global Shell contract with product code C', '2018-05-04', 8, 'Answered'),
(164, 'Aisling ', 'Aisling @we.com', 46589704, '2018-04-20', 5, 'copay is pulling on my claim however it has been taking on claim 170 but the decs are different on each claim but box 31 are the same and so is the tax id! should i be applying copay to my claim? ', '2018-05-01', 'Please verify #\n\nUPDATE /:\nYou should consider these the same provider and waive the dollar copay as this has been taken on #.', '2018-05-04', 9, 'Answered'),
(165, 'Shane Meehan', 'Shane Meehan@we.com', 46589705, '2018-03-20', 6, 'Should line 4 A9772 be capped? Directed to screen 11 for risk nuclear med, says TC mod must be billed but Tc mod cant be billed with this A code.\n\n', '2018-05-01', 'TC modifier is billed on your  so you should follow the Nuclear Medicine and use \"H\" risk', '2018-05-01', 4, 'Answered'),
(166, 'Monica', 'Monica@we.com', 46589706, '2018-04-10', 7, 'CFC 7 claim. Just want to double check that i do the IR on claim #030. Original claim #24 was denied for incorrect pos, they resubmitted with POS 12 on claim #30 & now resubmitted again with pos 22 on my claim. Thanks ', '2018-05-01', 'Yes use # as your OCN and do an IR if required on this .', '2018-05-04', 5, 'Answered'),
(167, 'Paddy', 'Paddy@we.com', 46589707, '2018-04-17', 8, 'Unable to determine on my corrected claim whether the original was correct per partial auto debit / downadjust. Original claim #13.\n\nAre there any SOP or Documents that confirm what to do with these claims going forward that have upadjust/downadhust. Do we ignore the original claim & process the new claim?', '2018-04-30', 'There is no upadjust or downadjust document. If unsure, rework have the files available to see why the adjust was done.\n\nFor  # the reason:\n\"Per Moldx requirements, the required Z code was not billed as required for LCD L\"\n\nThis is in relation to the unlisted code. Process your  as a corrected  for payment by reviewing all normal processes.\n\n', '2018-05-04', 6, 'Answered'),
(168, 'Myles', 'Myles@we.com', 46589708, '2018-04-09', 9, 'Southwest (47). My clm is c/r to #249. A EOMB was requested on 249 and is now provided with #279 however the member name is blanked out and the DOS don\'t match, can you verify if I\'m correct to deny based on requested information not provided, thanks. ', '2018-04-27', 'You will deny the  per step  of the unlisted SOP.', '2018-05-01', 6, 'Answered'),
(169, 'Monica', 'Monica@we.com', 46589709, '2018-03-20', 3, 'CFC7 claim. On the attachments in the claim is a cover letter from us saying the original claim was denied as a dup to claim #88. There\'s no other claim for that date in the system. Do i process like this was the only submission & then deny for TF in that case?', '2018-04-26', 'The system has auto-indexed the first submission to  #. The first one, Doc ID#:  and is received on //. The second one, Doc ID#:  and is received on //.\n\nThis means your  with within TF limits. Link all \'s and enter a  comment:\n\nOriginal  was auto-indexed to  #.  is within TF limits.\n\nAlso as your  is a CFC, there is no need to relog the original s as they will be denied for payment on your .', '2018-04-27', 2, 'Answered'),
(170, 'Myles', 'Myles@we.com', 46589710, '2018-04-03', 4, 'My clm #028 is a c/r to #017. 17 has 4 lines billed and 3 were initially paid with 81479 denied. There was then a downadj done and 2 of the line were taken back 81211 & 81408. Provider has submitted medical records for 81479 but it appears reva has rejected them. Should i now repay 81211 and 81408 PA? thanks.', '2018-04-26', 'Yes repay line  and , as these have been recovered in-error. DA line  and  line  per the unlisted process.', '2018-04-27', 2, 'Answered'),
(171, 'Aisling', 'Aisling@we.com', 46589711, '2018-04-12', 5, 'ces edit flagging CDTPR, my two lines are being called out for review. #899 is paid in history per the CDTPR  job aid should i just process my claim as normal and request a recovery on claim 899??', '2018-04-24', 'Please verify #\n\nUPDATE /:\nIf your region isn\'t CA, please make sure you\'re stating the region.\n\nThe CES edit is referring to  #, as this  is paid, make the relevant recovery for the codes outlined on the edit.', '2018-04-27', 3, 'Answered'),
(172, 'Monica', 'Monica@we.com', 46589712, '2017-09-05', 6, 'Going through the clinical trial sop and i\'m getting as far as step 17 & to deny back to medicare. can you double check to make sure that\'s correct?', '2018-04-24', 'Yes deny the  per step .', '2018-04-27', 3, 'Answered'),
(173, 'Catherine', 'Catherine@we.com', 46589713, '2018-02-21', 7, 'Determining in v ooa in hx there is an AJ (clm 007) and an OJ (clm 008 ) whic of these woudl i follow ??', '2018-04-24', 'You  has POS , so use the rendering providers information to determine OOA. You only need to review ambulance s for POS .', '2018-04-27', 7, 'Answered'),
(174, 'Deborah McHugh', 'Deborah McHugh@we.com', 46589714, '2018-04-05', 8, 'Related OU needs reviewed.', '2018-04-23', 'What is the # of the OU? \n\nAlso this should be sent in a email instead of using the Q.Log.', '2018-04-27', 7, 'Answered'),
(175, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589715, '2018-03-19', 9, 'I have a claim that looks like it should be denied as ineligible.\nHowever, there is a cover sheet attached - an AB1324 eligibility gaurentee sheet?\nDo I trust that sheet and continue to process? \nThanks.', '2018-04-23', 'This  should be consider ineligible and denied as such.', '2018-04-24', 7, 'Answered'),
(176, 'Dean', 'Dean@we.com', 46589716, '2018-04-17', 3, 'contract language in the claim lists my code 88307 in two seperate places and two different rate, one says based on specimen size but I\'m not sure how to price it,', '2018-04-23', 'Please verify  #. Also check the Q.Log, as a similar question was ready asked.', '2018-04-27', 1, 'Answered'),
(177, 'Lauren', 'Lauren@we.com', 46589717, '2018-04-04', 4, 'I have an exact match dup to a claim in history #47 both images dont match BC in nice but when add up each line individually they match what is logged in nice. Unsure how to process my claim', '2018-04-20', 'Unable to view image for #, so try your  as an exact dupe based on the info in Nice.', '2018-04-27', 5, 'Answered'),
(178, 'Monica', 'Monica@we.com', 46589718, '2018-02-28', 5, 'Sh claim that is denied 3S. There\'s no letter for 3S for the SH LOB. I have an email from Cathal Canning to put in 3Q template and i\'ve sent it to the denial queue 3 times and it keeps coming back into my pends. Not sure what way to proceed. Thanks ', '2018-04-19', 'I have manually created the letter. You can click complete on the processing box.', '2018-04-20', 6, 'Answered'),
(179, 'Catherine', 'Catherine@we.com', 46589719, '2018-03-21', 6, 'Should i link the auth and deny this claim as this is were i get to on the auth sop, ones in hx are paid ??', '2018-04-19', 'You  is not covered in this auth and should not be used.\n\nIf you check the auth comments screen and looks for your DOS, these are not included in a any the denials.', '2018-04-20', 8, 'Answered'),
(180, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589720, '2018-04-11', 7, 'I\'m not sure if my claim is chronic. #8 matches my dx and TID numbers match. #4 matches my claim but is capped even though there is an auth not medically indicated for there DOS. Unsure what to do?', '2018-04-16', ' # is the first visit. Process that  and follow the OOA determination.', '2018-04-19', 9, 'Answered'),
(181, 'Monica', 'Monica@we.com', 46589721, '2018-03-06', 8, 'CFC 7 claim. Claim #72 is referenced on the image but it\'s duping to claims #70 & #71 as well, both are paid. Not sure what claim number to put in or what way to do IR', '2018-04-16', 'As there is mutliple original s, link all \'s and follow the non-CFC process. \n\nAlso enter the following  comment:\n is considered a corrected  to #,  & ', '2018-04-19', 4, 'Answered'),
(182, 'Shane Meehan', 'Shane Meehan@we.com', 46589722, '2018-03-15', 9, 'Please review for POTF per page 2 on image ', '2018-04-12', 'Yes we can accept thois as POTF, as this is an EOB from the PMG.\n\nYou will use the date on the top left - //. As this EOB is from the PMG you can use this as your LDOS and use the received date in Nice - //. Making the TF limit  days.', '2018-04-19', 12, 'Answered'),
(183, 'Chris', 'Chris@we.com', 46589723, '2018-04-09', 3, 'CES edit regarding unbundled codes.\nAm I right to think the first code in Hx 71100 must be recovered & I can pay the code on my claim 71101?\nThanks.', '2018-04-12', 'The CES line disposition for this line is U = unchanged, there is no action that is needed with this edit and is for information only.', '2018-04-12', 11, 'Answered'),
(184, 'Zeta', 'Zeta@we.com', 46589724, '2018-04-05', 4, 'I have a auth that has \'approval\' on it but in comments has a note for Non covered... I am unsure if I deny the claim 3B or proceed as it has approval?', '2018-04-12', 'Deny you  based on the notes section of the auth.', '2018-04-12', 11, 'Answered'),
(185, 'Lauren', 'Lauren@we.com', 46589725, '2018-04-09', 5, 'Have contract text in screen 18 my code 88307 is called out twice in the contract with two different rates, not sure which rate to price my claim at?', '2018-04-12', 'Reimburse this  at $.', '2018-04-12', 12, 'Answered'),
(186, 'Aisling', 'Aisling@we.com', 46589726, '2018-03-20', 6, 'Iset still not working can you please check supplemental benefits for hospice?', '2018-04-12', 'Discussed with examiner and got iSet working.', '2018-04-19', 13, 'Answered'),
(187, 'Chris', 'Chris@we.com', 46589727, '2018-03-22', 7, 'This claim is a POS 81 so it is logged as in area.\nHowever, there is an AM in Hx can you confirm this claim is related and I can use it to change the claim to an AC?\nThanks.', '2018-04-11', 'Yes treat your  as related to #.\n\n', '2018-04-16', 14, 'Answered'),
(188, 'Chris ', 'Chris @we.com', 46589728, '2017-11-03', 8, 'Interest is to be paid on this claim.\nThe check was void and DEC was changed before payment.\nWhen should I apply interest from?\nThanks.', '2018-04-11', 'Please check the interest SOP, as this is called out.\n\nCheck Void s when the reason for the check void is because of an issue with the s payment process and not because of the provider. Interest is applicable from the original received date.\nExample: The check was originally sent to the incorrect payee. \n', '2018-04-12', 14, 'Answered'),
(189, 'Chris', 'Chris@we.com', 46589729, '2018-02-21', 9, 'Misdirected claim = \nThis claim is POS 23 with an inpatient auth there which brings it in area and capped but OOA mileage?\nShould I use the auth or follow milegae?\nI know POS 23 dont need auth\'s but from speaking with Shane he said he was instructed last week to deny a POS 23 claim with a denied by group auth?\nThanks.', '2018-04-11', 'The auth should not have been used as the facility setting of the auth doesn\'t match.\n\nIf there is a matching auth for POS , you should use the auth.', '2018-04-12', 10, 'Answered'),
(190, 'Monica', 'Monica@we.com', 46589730, '2018-02-21', 3, 'Cob claim where it\'s pulling copay and deductible. The PR amount is the same as billed charges. Just trying to figure out the sop. Do i take the deductible and minus out the copay to pro rate it?', '2018-04-11', 'For line  you will apply the deductible with its normal ARC and take the copay off with . \n\nYou only need to pro-rate the copay if this brings UHC payable lower then the PR amount. As this line\'s PR amount is billed charges, you\'re not required to pro-rate the copay and the full copay should be applied.', '2018-04-12', 10, 'Answered'),
(191, 'Dean', 'Dean@we.com', 46589731, '2018-03-27', 4, 'The claim has risk that doesnt match up between screen 14 & 17, in screen one for example it says HS01 but Line 1 in screen 14 is H then in screen 17 it reaches a capped carve out, I\'m just unsure how to proceed\n*Edit 04/13/18*\nI routed the claim because i cant process the claim type and it was returned with the following message \"misroute- for a claim to be MA the service provider DEC Number (phys name in NICE below aggn prov & group name) ', '2018-04-11', 'This is an Apria Syb-Cap agreement. \n\nUsing  type mapping the  type should be change to MA', '2018-04-12', 10, 'Answered'),
(192, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589732, '2018-04-04', 5, 'When I benefit mapped my claim nothing pulled on the NICE screen...when manually done the first category that is listed is 17 which looks like $27 copay should be applied. Do I apply this even though NICE screen is blank?', '2018-04-09', 'When you manually benefit map this  you should stop at carve-out for your Dx. As this benefits map to infertility and there is no infertility benefits in the benefit screen you will more on.\n\nYou will keep going down till you get to seq. , as the alternate benefit is \"N\", you can\'t apply any benefit after this line.\n\nMember does not have a benefit.', '2018-04-11', 10, 'Answered'),
(193, 'Chris ', 'Chris @we.com', 46589733, '2018-02-28', 6, 'Can you please check if doccuments attached are valid for POTF? Thanks', '2018-04-09', 'I would not use this as POTF, as we\'re unable to identify if these remittance reports are from the PMG. The only name listed on them is the provider.', '2018-04-10', 14, 'Answered'),
(194, 'Monica', 'Monica@we.com', 46589734, '2018-01-30', 7, 'Cob claim. EOB from medicare where PR is $0 and a note saying health care policy is prime. cob comments have just been updated still saying that medicare is prime. Should we be asking for another eob or do i follow the sop and deny it 3D per step 9? Thanks ', '2018-04-09', 'Process this  as UHC prime.\n\nFollowing the COB - adjustment SOP: you should get to step  - \"Has the primary payer paid the billed service?\", NO.\n\"Was denial due to member ineligibility?\", NO.\n\"Is the denial deemed provider or member liability?\", Member.\n\nI am determining this to be member liabililty based on the denial on the EOB - CO- = This care may be covered by another payer per coordination of benefits.', '2018-04-11', 13, 'Answered'),
(195, 'Paddy', 'Paddy@we.com', 46589735, '2018-03-27', 8, 'Per Screen 11 language; please advise whether risk is Capped MC01 or HS01 as there are two options for code 88307. ', '2018-04-09', 'Risk should be HS. \n\nYou  is related to surgery  #, so you should follow:\n\nLABORATORY/PATHOLOGY-IP &OP SURGERY RELATED   BOTH                 H ', '2018-04-11', 8, 'Answered'),
(196, 'Shane Meehan', 'Shane Meehan@we.com', 46589736, '2018-03-30', 9, 'Copay -  claim is showing copay of $97 radio pro complex which maps to my cpt code 77014 but there is a 20% co-ins also which one should be used here the orginal $97?', '2018-04-06', 'Domain request  submitted \n\nUpdate /:\nCopay to be applied st then the co-insurance, System should apply the correct adjustments. ', '2018-04-11', 9, 'Answered'),
(197, 'Monica', 'Monica@we.com', 46589737, '2017-12-26', 3, 'Corrected Cob claim. They have attached an eob now but only one of the codes is correct. The other code on the eob has the correct amount but is different to what is on the hcfa. Should i be requesting another eob?', '2018-04-06', 'As G is not on the EOB, you should deny this code with ARC DW.', '2018-04-11', 4, 'Answered'),
(198, 'Zeta', 'Zeta@we.com', 46589738, '2018-03-30', 4, 'I have an exact match dup to claim #028 but I can\'t determine if claim #028 was processed correctly as it has been denied Provider writeoff per CES flag. Ces was never envoked on original #028.', '2018-04-05', ' # was denied based on a CES edit on  #, however, only line  should have been denied and line  should have been considered payable.', '2018-04-10', 5, 'Answered'),
(199, 'Dean', 'Dean@we.com', 46589739, '2018-04-03', 5, 'My claim has a possible COB alert with na indicator G, it says that pacificare is secondary but step 1 of the COB SOP doesnt explain what steps to take wit ha G indicator, is this considered dual coverage due to spouse?', '2018-04-05', ' is closed.', '2018-04-10', 6, 'Answered'),
(200, 'John', 'John@we.com', 46589740, '2018-03-15', 6, 'Can you have a look at this claim for the copay? When I num J the claim \"SRV GRP 031 - INVALID ALI\" appeared. Can you check to see is the copay right, thanks', '2018-04-05', 'Benefit map your  to determine the correct copay for your .', '2018-04-12', 6, 'Answered'),
(201, 'John', 'John@we.com', 46589741, '2018-03-19', 7, 'Can you check the contract language on this claim? Would I be using the 100% from CMS per page 7 in the contract? or does this not relate to my claim and I have to change the contract ind to N?', '2018-04-04', 'You should process this  as contracted per the contract in screen . As your  is non-transplant related, you will price your  at % of CMS.', '2018-04-05', 2, 'Answered'),
(202, 'Myles', 'Myles@we.com', 46589742, '2018-03-30', 8, 'My clm POS 11 has a DC auth 3920887 (its for bed type AJ OOA, EMERGENCY ROOM) for code \"78317 Bone and/or joint imaging\" my clm has code 73130 billed (Radiologic examination, hand; minimum of 3 views) would i use this auth or disregard it as it\'s doesn\'t match my clm?', '2018-04-04', 'Disregard the auth, as the procedure listed doesn\'t match your .', '2018-04-04', 2, 'Answered'),
(203, 'John', 'John@we.com', 46589743, '2018-03-15', 9, 'I\'m trying to determine the risk for service group 011 for my two J2787 codes. First I get to seq line 10 because of dx C70.911(dx pointer E) but my dx pointer for my code in box 24e is ABCD. Can I use this call out or would I be skipping this as that dx doesn\'t relate to my code and be taking seq line 77 which is capped?', '2018-04-04', 'You can use seq  - H risk for your . \n\nBox .E is limited to only  entities, so the provider is unable to enter any Dx past D.', '2018-04-04', 3, 'Answered'),
(204, 'John', 'John@we.com', 46589744, '2018-03-12', 3, 'I have a claim with POS 2 which is a C/R to a claim with POS 22. I get to CES and the CES edit is BPS. If you look that up in the s/sheet, it says to route to ICES pend queue. I have routed it twice and its back in my pends saying don\'t route back to that queue. It still isn\'t saying no edits found for CES so what should I do with this claim? I have a few of them in my pends now.', '2018-04-03', 'Deny this  based on the CES edit - ARC  and freeform with the CES edit as your letter.', '2018-04-04', 3, 'Answered'),
(205, 'Catherine', 'Catherine@we.com', 46589745, '2018-03-27', 4, ' REIMBURSEMENT SHALL BE ACCORDING TO THE DEPT SUPERVISOR\'S COPY OF THE FEE SCHEDULE.                                                                           \nNot sure of this contract were do i find it ', '2018-04-03', 'I have emailed you instructions on how to price the .', '2018-04-05', 7, 'Answered'),
(206, 'Chris', 'Chris@we.com', 46589746, '2018-03-27', 5, 'I have a POS 21 claim and there are multiple IA-I\'s IA-R\'s AA\'s & AA-I/ AA-R in Hx are you able to tell me which one to use as related as I have no idea? \nMultiple matching service providers on the claims also.\nThanks.', '2018-04-03', 'Treat your  as related to - and process as in-area.\n\n - needed to be splits, as the part of the services is candidacy & maintenance (your s is related to this) and the rest is TP related.', '2018-04-03', 7, 'Answered'),
(207, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589747, '2018-03-22', 6, 'I have CES review for line 1 - G0103 with CES flag LBIM when I search for the CES flag in the CES reveiw tab, it tells me to follow the non covered job aid. when i opent the link it takes me to the unlisted code process. I have searched encoder and it is not an unlisted code. Unsure how to proceed', '2018-03-30', 'Follow the CES noncovered process\n\nhttp://kl/Content/Operational%Processes/Production/PHS-AMS-PacLife/Transaction%NICE%New/General%Processing/f_Admin%Only/CES%Non%Covered%Process.htm\n\n', '2018-04-03', 7, 'Answered'),
(208, 'Lauren Lynch', 'Lauren Lynch@we.com', 46589748, '2018-02-19', 7, 'I\'ve contract language in screen 18 that states to pay ancillary charges at 70% of billed charges. I have a realted AP in history that has 79840 billed which is called out as a case rate in my screen 18 I\'m unsure whether my code is included in the price 79840 code.', '2018-03-29', 'Reimburse the  at % per screen .', '2018-04-03', 1, 'Answered'),
(209, 'Shane Meehan', 'Shane Meehan@we.com', 46589749, '2018-03-12', 8, 'Risk is directing me to screen 11 for rad code 71020 \n\nPathology & Radiology IP/OP      H Ind\nRadiology (Diagnostic)               M Ind\n\nWhich carveout should be used?', '2018-03-28', 'Use the radiology only risk.\n\nRadiology (Diagnostic)               M Ind', '2018-04-03', 5, 'Answered'),
(210, 'Chris ', 'Chris @we.com', 46589750, '2016-09-08', 9, 'Medicaid claim: \nWhen I am going to link a DEC to this claim for pricing there are 3 applicable DEC #\'s when I search the NPI  (24, 27 & 28)\nThe 3rd contract gives a different rate than the other 2.\nThe 3 contracts have 3 different addresses the PObox # is found in all of them & none of the given addresses match the address on the NPI website.\nHow should I continue with pricing?\nThanks', '2018-03-28', 'As none of the s match the facility address on the NPI site and there are multiple Dec# with different rates, process the s as non-par.', '2018-04-03', 6, 'Answered'),
(211, 'Myles', 'Myles@we.com', 46589751, '2018-03-08', 3, 'The codes billed for my DOS have been paid twice before on clm #127 and #134 (they were marked as cfc 7), as the codes are billed with mod 78 i am obliged to pay this again or can i deny as a dup? thanks.', '2018-03-28', 'Deny yout  as a dupe to #, the other s are correct to be paid per the CFC process.', '2018-04-03', 8, 'Answered'),
(212, 'Shane Meehan', 'Shane Meehan@we.com', 46589752, '2018-03-19', 4, 'Error message when trying to pay the claim Payee address is incomplete a manual check required if foreign address what should I do here? Adress logged in F8 matched that on the supp pages and previous claims have been paid matched that same address.', '2018-03-27', 'If you\'re still get this prompt when trying to pay the , please send the  to PIM and say \"Payee address is incomplete - please link working Dec#\"', '2018-04-03', 9, 'Answered'),
(213, 'Monica', 'Monica@we.com', 46589753, '2018-01-22', 5, 'CFC 7 claim which is corrected to claim #17 which was denied. They\'ve resubmitted it but combined claim #17 & #18 together. #18 has already been paid. Not sure which claim i should be referencing and do i need to do IR on claim #018?', '2018-03-27', 'Enter in the OCN as # and process the IR on that .\n\nFollowing the SOP linking # would be correct, however, as # has been paid, you should link this instead, so the IR can be issued.', '2018-04-03', 4, 'Answered'),
(214, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589754, '2018-02-27', 6, 'I still cannot see claim comments on this claim previous to the pricing comments?\nI need to see the comments for pricing purposes & dont know how to see them?', '2018-03-26', ' is closed.', '2018-04-03', 12, 'Answered'),
(215, 'Catherine ', 'Catherine @we.com', 46589755, '2018-03-06', 7, 'cob indicator F, sop does not have a step for this indicator ', '2018-03-26', 'On step  of the COB SOP, follow \"no\" and then \"yes\" and continue onto step .\n\nA documentation request has been submitted to add in the new COB indicators.', '2018-04-03', 11, 'Answered'),
(216, 'Catherine', 'Catherine@we.com', 46589756, '2018-03-19', 8, 'Not sure if i should take the copay $70 on my claim, per comments i think the copay should be taken clm #072 03/12/18 but there dosnt seem to be a copay for this claim and it was taken on #089 and taken back. should i take the 70 on my claim #071', '2018-03-26', 'Copay should not be taken. \n\nFor the rad therapy complex copay, copay is only applicable once per treatment plan, e.g. once per  days. As February is only  day month, copay is not applicable until //.', '2018-04-03', 11, 'Answered'),
(217, 'Chris', 'Chris@we.com', 46589757, '2018-01-26', 9, 'This claim was logged incorrectly as 4 was a duplicate to line 3 until it was fixed and TC mod was added to the code on line 4. This line was never priced. I contacted Dwayne and asked him to reprice this for me but he emailed me back with an email that read Viant savings achieveed .... Paybable amount $401.78 which is the allowable for the overall claim. I have waited for the new pricing sheet for over a week now and dont know what to do. How should I continue?', '2018-03-26', 'Make the payable on line  the difference between the pricing sheet and the Viant comment with ARC NZ, i.e. $. less $. = $.', '2018-04-03', 12, 'Answered'),
(218, 'Chris', 'Chris@we.com', 46589758, '2018-02-27', 3, 'Can you check POTF please? Out by 1 day\nSome attachment - remittance advice sheet attached with dates but cant see PMG name on them.', '2018-03-23', 'The document attached is an EOB from  # and can\'t be used as POTF.', '2018-04-03', 13, 'Answered'),
(219, 'Aisling', 'Aisling@we.com', 46589759, '2018-02-14', 4, 'Per dup sop #389 would be a corrected replacement to claim #387 per dec and box 33 difference,how ever #387 is paid but one code was denied for ces 88341 but it would still be denied on my claim,could i deny this as a dup or would i be going on to DA the claim??', '2018-03-22', 'Deny line  per the CES edit and deny the remaining DA.', '2018-04-03', 14, 'Answered'),
(220, 'Shane Meehan', 'Shane Meehan@we.com', 46589760, '2018-01-08', 5, 'Per claim comments claim was to be denied for no med rec recieved? Clean ind is changed back to Y COB is not in effect until 07/18 does this just mean the claim is now payable as COB is not in effect and the clean ind was correct to be changed back to Y?', '2018-03-22', 'The request for COB EOB was incorrect and the clean indicator getting changed to a N was also incorrect as a result. \n\nThe clean indicator is correct to be a Y. Continue to process your  as normal. ', '2018-04-03', 14, 'Answered'),
(221, 'Aisling', 'Aisling@we.com', 46589761, '2018-03-06', 6, 'Per auth sop claim should be sent to mcr per the billed charges are over the 700$ mark,however it has been sent to mcr twice UNABLE TO PROCESS W/OUT FACILITY CLAIM.should i be denying this claim?3g-48?', '2018-03-22', 'Yes you can deny the  G-, as the  requires a facility  for MCR to review due to billed charges  and MCR are stating unable to process without facility . ', '2018-03-22', 10, 'Answered'),
(222, 'Zeta', 'Zeta@we.com', 46589762, '2018-03-16', 7, 'I have manually priced this claim per the contract but when I num J it takes $10.00 copay but there is no other benefits listed with copay.', '2018-03-21', 'Please benefit map you  to verify the copay before entering a question.\n\nLine  will map to seq.  and has \"\" in column Q, so copay shouldn\'t be applied.\nLine  will map to seq.  and has \"\" in column Q, so copay should be applied.', '2018-03-22', 10, 'Answered'),
(223, 'Aisling', 'Aisling@we.com', 46589763, '2018-03-09', 8, 'system has put in an arc DH,(Invalid procedure code) not sure if i should let this stand or back out the adjustments and manually price???', '2018-03-21', 'You can backout of the system arc and pay line  as it is a valid procedure per encoder. You also have an muH ces review on your , meaning that you will have to request a recovery on procedure code  on  # as it has an unbundled relationship with  on your  and the check has gone. Request a recovery for that line only. \n\nProceed to pay all lines on your  as normal.', '2018-03-30', 10, 'Answered'),
(224, 'Dean', 'Dean@we.com', 46589764, '2018-03-14', 9, 'My claim is a Dup to claim 021 in hx but 021 was denied for being within hospice Date span, I was going to deny mine as a dup but I cant find the correct insert, should I deny it for hospice instead? ', '2018-03-21', 'As the original  # is denied correctly for Hospice coverage and your  is an exact match dup, you can deny your  as a DUP to it with denial letter H- i.e previously denied as provider write-off.', '2018-03-22', 10, 'Answered'),
(225, 'David', 'David@we.com', 46589765, '2018-02-27', 3, 'Claim has 2 hcfas with different primary dx.\nI looks loike it has beend sent for relogging to be split but the second hcfa has not been logged to a claim.  Do I need to have the second hcfa logged again?\nalso the hcfa which relates to my claim has 2 pos. should it be denied \"incorrect pos billed\"?', '2018-03-21', 'Deny the  using the free form letter stating ?multiple POS of billed please resubmit with a corrected POS', '2018-03-22', 14, 'Answered'),
(226, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589766, '2018-02-27', 4, 'I cannot see comments after the 2 most recent pages of claim comments.\nHow should I continue?\nThanks.', '2018-03-20', 'Price this  per U&C. There is an EOR attached with a T edit and suspend UN, so you should be pricing per U&C.\n\nAs you\'re unable to see the comments, consider the  to have GIS comments and verify OOA (note POS ).', '2018-04-03', 13, 'Answered'),
(227, 'Zeta', 'Zeta@we.com', 46589767, '2018-03-15', 5, 'I am unsure how to price this per the contract in screen 18? I have no fee schedule so would I price per CMS? ', '2018-03-20', ' is closed.', '2018-03-30', 8, 'Answered'),
(228, 'Shane Meehan', 'Shane Meehan@we.com', 46589768, '2018-03-05', 6, 'I have an IC-V (void) its a corrected claim original was denied for TF now have POTF attached and is payable. I took out the resubmission code 8 in the back screen is not on the image.     \n\nIs it ok to take out the V and pay the claim?', '2018-03-15', 'Yes remove the \"V\"  type modifier from your  and pay as normal. \n\nThe  was incorrectly logged as a void  by the logger. As there is no CFC on the , the  should not be considered a void .', '2018-03-30', 9, 'Answered'),
(229, 'Thomas ', 'Thomas @we.com', 46589769, '2018-03-12', 7, 'I have a claim that was prevoiusly in a paid status and has been re-opened. MIR has been applied to the claim and a deductible has been applied to the claim, but i\'m uncertain whether to apply sequestration or not. Also, Detail/adj screen has lots of adjustments in the claim so i\'m unsure if a relog would be required or not.', '2018-03-15', 'Yes seq. applies to your . You will have to manually apply it to this  before closing.\n\nThe  is not required to be relogged, unless we can an OOB alert when you go to close the .\n', '2018-03-20', 4, 'Answered'),
(230, 'Dean', 'Dean@we.com', 46589770, '2018-03-13', 8, 'I\'m having difficulty finding an address thats consistent between the image and NICE, if I use box 32 the claim will be in area but all other zip cdes ive found keep it OOA, its POS 12 also and the num Y address matches a sutter facility but the image and Supplimental pages dont. ', '2018-03-15', 'Ues the zip code found on the supplemental pages, as this is the correct zip for your service facility address.', '2018-03-20', 5, 'Answered'),
(231, 'Monica', 'Monica@we.com', 46589771, '2017-09-28', 9, 'Reopened claim originally denied for no auth/fac bill. Auth is now updated & it\'s prompting for interest. Not sure what date i should put in for it ', '2018-03-14', 'Apply interest interest from rec\'d date as we didn\'t fulliful the CA Health and Safty compliance.', '2018-03-15', 6, 'Answered'),
(232, 'Monica', 'Monica@we.com', 46589772, '2018-02-26', 3, 'Trying to verify TF on this claim. Can the sutter health cover sheet be used as potf? Thanks ', '2018-03-14', 'Yes you can use these misdirected letters as POTF. These are from Sutter, and Palo Alto should be considered Sutter. \n\nFollow the PMG EOB rules to verify the POTF.', '2018-03-14', 6, 'Answered'),
(233, 'Monica', 'Monica@we.com', 46589773, '2018-01-11', 4, 'Corrected claim to #080 which was denied for TF. Poss potf attached to my claim, can you verify pls? Thanks ', '2018-03-13', 'POTF doesn\'t match your  and shouldn\'t be considered.', '2018-03-30', 2, 'Answered'),
(234, 'Zeta', 'Zeta@we.com', 46589774, '2018-03-01', 5, 'I have a span date on my claim which is covered over two auths. One auth is denied by group for one date and the rest are from a DM auth.\n\nI am unsure how to deny this. would I follow the DM denial?', '2018-03-13', 'Link the denied by group auth and deny all codes on // with ARC .\n\nDeny the remaining codes per the DM auth.\n\nUse denial G- and comment: \"No authorization received for services rendered and incorrect place of service billed, submit a corrected \"', '2018-03-14', 2, 'Answered'),
(235, 'Dean', 'Dean@we.com', 46589775, '2018-03-09', 6, 'I have a cardiology claim with no evidence of transplant but the matching system auth 3917787 is in the status \"authorized transplant\" can I use it since it covers the whole month or do I continue on and ignore it?', '2018-03-13', ' closed.', '2018-03-14', 3, 'Answered'),
(236, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589776, '2018-03-02', 7, 'I have related claims in history that are denied non covered, #77 and #78, but my claim is urgent emergent diagnosis..would this make my claim payable OOA', '2018-03-13', 'I have re-assigned these AP\'s as they should have considered the U/E Dxs on your . Pend your  until these are reworked and process your  accordingly', '2018-03-14', 3, 'Answered'),
(237, 'John', 'John@we.com', 46589777, '2018-02-26', 8, 'Hospice SOP step 8 - Determine if services billed are considered a supplemental benefit?\n\nI don\'t have access to iSET so would you be able to check for me? It\'s only one Dx, thanks.', '2018-03-13', 'Follow the \"No\" option here and continue to step .', '2018-03-14', 7, 'Answered'),
(238, 'Aisling', 'Aisling@we.com', 46589778, '2018-01-15', 9, 'Member appears  INELIGIBLE as of fdos..when checking for another policy a message is showing CAN\'T DISPLAY MORE RECORDS; how should i move forward with this claim?', '2018-03-13', 'This  has been relogged to , so please J your  and add a  comment. \n\nReview the relogged s and see if the  has been processed correctly per our guidelines. As the  has been processed in-area and capped, but there is an OOA form on your .', '2018-03-14', 7, 'Answered'),
(239, 'Monica', 'Monica@we.com', 46589779, '2018-01-11', 3, 'CFC 7 claim where the original claim was denied for TF. No potf on the new claim, would i just continue to deny it for that?', '2018-03-12', 'As the original  is correctly denied for TF and there is no POTF on your  either, deny the  for TF', '2018-03-13', 7, 'Answered'),
(240, 'David', 'David@we.com', 46589780, '2018-01-03', 4, 'The system auth denies 1 unit of 83921 but there is two units billed on the line.  Should I deny half the billed arc 21?', '2018-03-12', 'Yes, deny half of  per the non-covered auth linked.', '2018-03-13', 1, 'Answered'),
(241, 'Chris', 'Chris@we.com', 46589781, '2018-03-05', 5, 'I have a claim that is a C/R to a claim in HX 771179801071 \nNothing on the HCFA has changed - With claim #72 doccuments have been submitted which may bring the claim in for Timely Filing as the original was correctly denied. \nAre these doccuments enough to suggest it is a C/R? \nAnd if so can you verify the POTF \nThanks.', '2018-03-12', 'You can deny your  as a dupe, as the POTF doesn\'t bring the  within TF limits.', '2018-03-13', 5, 'Answered'),
(242, 'Monica', 'Monica@we.com', 46589782, '2017-06-27', 6, 'Lifeprint claim where risk changed after the claim was closed. System prompting for interest, it it just from the receive date? Can\'t see anything in the sop for this scenario ', '2018-03-12', 'This is a retro update to the contract, as such the risk should be payable from //. Interest should be applied from recieved date.', '2018-03-13', 6, 'Answered'),
(243, 'Aisling ', 'Aisling @we.com', 46589783, '2018-03-08', 7, 'Per auth comment note should i be denying this claim per step 9 auth sop?', '2018-03-12', 'There is no notes for your DOS to be denied and should be considered auth per the available auth.', '2018-03-12', 8, 'Answered'),
(244, 'Monica', 'Monica@we.com', 46589784, '2018-01-09', 8, 'My claim is pos 21. There is an OU & IA for my dates of service. Auth have a comment in my claim saying that it relates to the IA but the facility is matching the OU which would make my pos incorrect. Can you confirm what facility it relates to? Thanks ', '2018-03-12', 'Follow the MCR comments and treat the corresponding facility s as the IA. All the related OUs have been capped.', '2018-03-12', 9, 'Answered'),
(245, 'Zeta', 'Zeta@we.com', 46589785, '2018-02-22', 9, 'I have a pended auth and a related AA in history that was denied for no med records recieved. I am unsure how to deny my claim.\n\nEDIT\nI am unsure of the correct denial letter to use as there is a specific letter for commercial but not for Secure. Will I use the freeform letter with the comment from the commerical 3G-37.', '2018-03-09', 'Following the OOA inpatient prof. job aid, you will deny the  for no auth/no facility.\n\nOn Q, you will follow the rd option, information has not been received.\n\nAs there is no letter available for this and G- letter can\'t be used. Use the freeform with the text from E&I letter for your letter.', '2018-03-12', 4, 'Answered'),
(246, 'Chris', 'Chris@we.com', 46589786, '2018-03-05', 3, 'System correctly denied original claim #107 for TF \nSame claim has then been submitted along with possible POTF doccuments.\nCan you please have a look at the POTF.\nThanks.', '2018-03-08', ' closed.', '2018-03-12', 12, 'Answered'),
(247, 'Chris ', 'Chris @we.com', 46589787, '2018-03-05', 4, 'I have a claim that is a C/R to a claim in HX 771179801071\nNothing on the HCFA has changed - With claim #72 doccuments have been submitted which may bring the claim in for Timely Filing as the original was correctly denied.\nAre these doccuments enough to suggest it is a C/R?\nAnd if so can you verify the POTF\nThanks.', '2018-03-08', ' closed.', '2018-03-12', 11, 'Answered'),
(248, 'Myles', 'Myles@we.com', 46589788, '2018-03-01', 5, 'My claim has 2 auth\'s it\'s POS 21. The 1st auth is for Er visit and is denied by group. the 2nd auth 3913777 covers the rest of the stay and is an inpatient auth but is denied DM. Should i get MCR to review auth  3913777 for all DOS?', '2018-03-08', 'Yes, please route the  to MCR and ask them to review the auth and see if your FDOS is included.', '2018-03-12', 11, 'Answered'),
(249, 'Zeta', 'Zeta@we.com', 46589789, '2018-03-02', 6, 'I have an auth thats in approved status and I am not sure if the note attached refers to my DOS or just the above dates.', '2018-03-08', 'The note referres to // only. As your DOS is included in the section date span, you\'re okay to link the auth and process the .', '2018-03-12', 12, 'Answered'),
(250, 'Myles', 'Myles@we.com', 46589790, '2018-02-15', 7, 'the information in Nice for my clm #070 doesn\'t match DOB, or address. There is another termed contract with the correct details # 177980001. Step 8 in image vs nice says to contact SME. Does clm #070 need to be relogged to correct member no? Thanks.', '2018-03-08', 'The policy mention above is the members old policy and it has been transfered to your policy. As such, so of the information seems to be incorrectly entered into Nice. \n\nHowever, I would not get this  relogged and would continue to process as normal under the current policy.', '2018-03-12', 13, 'Answered'),
(251, 'Myles', 'Myles@we.com', 46589791, '2018-02-08', 8, 'These is a Hx clm #209 that denied for timely filing. there is a stamp on the original image that would have taken it inside the TF limit of 90 days, the cover letter date 01/12/18 leaves it outside the limit. Can I trust the date on original image from Manage Care Systems 12/18/17?', '2018-03-07', 'Managed care system LLC is clearing house that is affiliated with the members PMG. As such, the received date at the top of  # should have been considered as POTF. \n\nYou can deny your  with ARC DA and reopen #.', '2018-03-12', 14, 'Answered'),
(252, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589792, '2018-03-05', 9, 'Got to step 17 on OOA SOP, i\'m looking for previous related/ER claim...#41 is an AJ and has similar diagnosis to my claim. I\'m wondering can i use this to process my claim as OOA as it is a month previous', '2018-03-07', 'Follow the \"subsequent follow-up visit\" option on step . As # would be conisdered the first follow-up.', '2018-03-12', 14, 'Answered'),
(253, 'Myles', 'Myles@we.com', 46589793, '2018-02-14', 3, 'There is no address in Box 32 and Num Y is blank. Related Hx clm #087 has been paid by the sys using the address in F8 but i can\'t see how that is verifyed. there are also several HX clms that have been paid using add in F8 but no address provided. Can i trust F8 in this case or should this be denied as per the SOP? Thanks. ', '2018-03-07', 'F should never be used to verify facility address.  # has a facility address in box . This can be used to verify your facility.', '2018-03-12', 10, 'Answered'),
(254, 'Myles', 'Myles@we.com', 46589794, '2018-02-02', 4, 'I have received the CES message :Have you run clm through CES standalone Y/N. there is a CES edit saying No Edits Found, but there is also an edit saying IC08-NO ICES EDITS DUE TO MISSING CARRIER ID. Can i proceed to process this or does CES need to be manually applied? Thanks.', '2018-03-07', 'Bypass CES and follow the no edits found comment.', '2018-03-12', 10, 'Answered'),
(255, 'Myles', 'Myles@we.com', 46589795, '2018-02-09', 5, 'I am denying this clm for Eligibility but there is excess lines in comments and EPD won\'t complete. Could you log a ticket to resolve this issue please.  ', '2018-03-07', 'When the EPD freezes on the comments, press Numlock + X and allow the EPD to continue to review the .', '2018-03-12', 10, 'Answered'),
(256, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589796, '2018-03-01', 6, 'I have an auth that is in an approved status but there is a note saying to deny entire stay as not medically necessary..which do I go by?', '2018-03-06', ' should be denied not medically necessary per the note on the auth.', '2018-03-12', 10, 'Answered'),
(257, 'Myles', 'Myles@we.com', 46589797, '2018-02-12', 7, 'There is a clm in Hx #084 that has the same DOS,code/billed charges it\'s in an 02/1N status. I can\'t pull an image or when i try to pull it through processing box it says #084 doesn\'t exist. Can i proceed to process #087 thanks.', '2018-03-06', 'This  has no image, so have sent to form to be indexed. Continue to process your . When # is logged, this  will be denied as a dupe to your .', '2018-03-07', 14, 'Answered'),
(258, 'Monica', 'Monica@we.com', 46589798, '2017-12-11', 8, 'IC08-NO ICES EDITS DUE TO MISSING CARRIER ID  ', '2018-03-06', 'Enter a  comment:\n\nPlease re-run CES with carrier zip \n\nAnd route the  to CESPnd.', '2018-03-09', 13, 'Answered'),
(259, 'David', 'David@we.com', 46589799, '2018-01-22', 9, 'Copay.\ncannot num J.\ncopay has a u indicator.\n71048 billed with both a 28 and tc mod.\nshould copay be applied to 1 or both lines?', '2018-03-05', 'Please benefit map your . Only  copay is applicable.', '2018-03-09', 8, 'Answered'),
(260, 'Lauren Lynch', 'Lauren Lynch@we.com', 46589800, '2018-02-27', 3, 'My claim has two different DOS one for 2/13/18 and the other for 2/20/18, I have two related system auths that cover the dates for each auth no 3 and no 7. Auth number 7 is a DM auth and auth number 3 is approved with comments saying to deny entire stay. I am unsure how to correctly process the claim.', '2018-03-05', 'Link auth:  and deny the whole  for incorrect POS.', '2018-03-07', 9, 'Answered'),
(261, 'Chris', 'Chris@we.com', 46589801, '2017-04-24', 4, 'This claim has returned with M&R CES edits rather than commercial edits.\nI resent the claim to CES & asked them to review the edits again but the claim was routed back to a queue with no update.\nhow should I continue?', '2018-03-05', 'I got CES manually ran on the . Please folllow the new edits in the  check screen.', '2018-03-05', 4, 'Answered'),
(262, 'David', 'David@we.com', 46589802, '2018-02-05', 5, 'corrected claim to #280\nit has a 7 on the claim info header page but not on the Image and a routing comment \"not cfc 7\" should I process and if so how do I take out the 7 in the header info page', '2018-03-05', 'I have removed the CFC  on the s header info screen. You\'re okay to process as normal.', '2018-03-06', 5, 'Answered'),
(263, 'Monica', 'Monica@we.com', 46589803, '2018-01-11', 6, 'CFC 7 claim. On the image, they\'ve referenced 2 different claim numbers, not sure which one i should be linking to my claim. ', '2018-03-05', 'Link #. The provider is stating that # has a unbundled CPT. But box  is indicating that the OCN is #.', '2018-03-05', 6, 'Answered'),
(264, 'Dean', 'Dean@we.com', 46589804, '2018-02-20', 7, 'My claim is a corrected claim to 037 which has claim comments that outline the pricing. I have screen 18 language that relates to the codes on my claim but the only code that is different has been capped by the system. I\'m unsure how to proceed based on the contract language in my claim or as a duplicate.', '2018-03-05', 'Treat your  as a corrected, due to the J being billed on your cliam.\n\nI have adding a comment on the pricing for each of the codes billed. \n\nYou will need to muiltply the units billed by the doesage to find the strength, i.e. line  = mg, line  = mg (NOTE line  = doesn\'t show a doesage and this should be considered mg). Price is per ml, each of the pricing is strength in relation to ml\'s. Use the calculation for the strength to determine the correct price for each line. \n\nOnce you have found the price for each line, you will need to multiply this by your contract %, i.e. less % \n\nWhen adjusting these, use ARC ', '2018-03-05', 6, 'Answered'),
(265, 'Monica', 'Monica@we.com', 46589805, '2018-02-05', 8, 'Corrected claim to #281. $14.00 o/p x-ray on orignal claim but mine is showing $0.00. Should the $14.00 be applied to my claim? Thanks ', '2018-03-02', 'When you benefit map your codes and the follow the GC (O/P X-ray), in column Q the copay amount is \"\". This means that the copay shouldn\'t be applied.\n\n', '2018-03-07', 2, 'Answered'),
(266, 'David', 'David@we.com', 46589806, '2018-02-08', 9, 'ooa \npos 21 related claim#118 was denied \"INVALID PRESENT ON ADMISSION INDICATOR\"  should I deny my claim 3g-48?\n', '2018-03-02', 'As  # was denied at pricing, you can treat that the  was allowed for OOA.\n\nPlease note that this cliam is Medicaid and should only be processed by examiners who are trained in Medicaid', '2018-03-06', 2, 'Answered');
INSERT INTO `question` (`q_id`, `examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `cat_id`, `question_txt`, `q_date`, `response`, `resp_date`, `sme_id`, `status`) VALUES
(267, 'Myles', 'Myles@we.com', 46589807, '2018-01-05', 3, 'I am trying to verify if this is in or OOA. Box 32 is blank and Num Y is PO box. There is an IA #081 in Hx with same DOS, SAINT LOUISE REGIONAL HOS , but it is denied for SIU. Can i use or trust the Zip from this clm to verify my clm as in area and also for pricing?', '2018-03-02', 'Yes you can use this IA as a related  for OOA and pricing, as the primary Dx is the same and the admission type is emergency and your  has POS .', '2018-03-02', 3, 'Answered'),
(268, 'Dean', 'Dean@we.com', 46589808, '2018-02-06', 4, 'I had to reopen this claim and apply copay that wasnt taken on Line 2. Ive sorted the claim but it wont let me put it back into an 07 status. ', '2018-02-28', 'As the cheque has ready been issue, the back screen can\'t be decreased. As copay was not applied correctly, you will need to:\n\nApply copay to the applicable line, e.g. . J on line \nSubtract the copay amount back on with same ARC used to pay the code, e.g. -.  on line \nChange the  back to the previous status, e.g. /A', '2018-03-02', 3, 'Answered'),
(269, 'Monica', 'Monica@we.com', 46589809, '2018-02-22', 5, 'CFC 7 claim that is out for TF. No other claim in hx that it matches to. Would you just treat this as a first submission & deny?', '2018-02-28', 'Yes treat this as a first submission, as there is no other  in our system. As there is no POTF attached, you\'re okay to deny the  for TF.', '2018-02-28', 7, 'Answered'),
(270, 'Dean', 'Dean@we.com', 46589810, '2018-02-14', 6, 'The address in box 32 of my image is different to the address billed in my numlock Y scree and different again to the address listed in my supplimental pages. Which one of these should I trust when it comes to determining things like OOA or pricing?', '2018-02-28', 'Trust the address that is on the supplemental pages, as this address matches the address in the additional data screen.', '2018-02-28', 7, 'Answered'),
(271, 'Thomas', 'Thomas@we.com', 46589811, '2018-01-22', 7, 'Can you check the proof of timely filing. The EOB has the doctor\'s name from claim #7 in history (Ali Badday) . Can I use this as proof as my claim has a different Doctor? ', '2018-02-27', ' is closed.', '2018-02-28', 7, 'Answered'),
(272, 'David', 'David@we.com', 46589812, '2018-02-19', 8, 'Can you please review potf to verify if it can be used?\n', '2018-02-27', ' is closed.', '2018-02-28', 1, 'Answered'),
(273, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589813, '2018-01-15', 9, 'Viant pricing which leaves us with 1 allowable over 2 lines once again. This is a reoccuring problem and the Viant pricing sheet never attaches & the similar claims have sat in my pends for 2/3 weeks. In training we were told to split the allowable over the 2 payable lines.\nIs that ok to do? ', '2018-02-26', 'As this  is not aged, please allow a week from the date of the pricing comments, to see if the pricing sheet get index. \n\nI wouldn\'t be spliting the allowable over the lines, I would wait for the pricing sheet to be indexed.', '2018-02-28', 5, 'Answered'),
(274, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589814, '2018-02-05', 3, 'I denied this claim as a dup & it has returned to my pends with routing comment - Please specify dup claim no in comments.\nI have clearly stated what claim it is a dup to but there are Reva comments entered that I dont understand. Can you please have a look at the comments.\nHow should I continue with this claim?', '2018-02-26', 'Include the # you\'re duping the  to. \n\nIn your comments, you have your # mention and not the original submission.', '2018-02-27', 6, 'Answered'),
(275, 'David', 'David@we.com', 46589815, '2018-02-05', 4, 'This claim is a c/r  to claim 282142701133 which was paid initialy but then a down adjust recovery was done on adjunct code Q9987.  Can I pay the line on this claim?', '2018-02-23', 'As the NDC has been included in the corrected , allow the code for payment.', '2018-02-26', 8, 'Answered'),
(276, 'Zeta', 'Zeta@we.com', 46589816, '2018-02-14', 5, 'Claim is corrected to history claim #037. Recovery has been recieved on claim #37. Theres a copay that applied on original claim of $14.00. My C/R has been billed with Mod 28 and copay no longer applies. Unsure how this affects original copay.', '2018-02-22', 'Copays should be reverse when a full recovery is done. As this is a Tracr recovery, they don\'t reverse the copay. You will need to reverse the copay on the original  and process your  as normal. \n\nThe balance of the $ of copay will get deducted from the next applicable  with copay by the system before the copay invoice is issued to the member.', '2018-02-26', 9, 'Answered'),
(277, 'Zeta', 'Zeta@we.com', 46589817, '2018-02-16', 6, 'My claim in History has MCR comments to deny the claim PBHI. This is my related claim and has same DX as mine but per the SOP my claim would not be PBHI... would I process per the MCR comments in my related claim or follow the SOP?', '2018-02-22', 'Please delegate this  to PBHI, as there is an auth in Linx for this  and should be processed by UBH.', '2018-02-23', 4, 'Answered'),
(278, 'Monica', 'Monica@we.com', 46589818, '2018-01-09', 7, 'Have got the following ces edit... IC80-PET scans for cancer DX ICES:ICES FLAG=CP8BR, ICES ACTION=R FOR LINE# 0002  ICES: Per NCD guidelines, CMS ID(s) 220.8.17, prostate cancer is not a covered indication for an initial PET scan. I\'ve gone through the pet scans sop and i\'ve got to step 7 where it says to continue as normal. Can you double check to make sure this is right, never seen this edit before. Thanks ', '2018-02-20', 'Yes, you\'re correct.\n\nNo other action necessary, continue to process the  as normal.', '2018-02-22', 12, 'Answered'),
(279, 'Zeta', 'Zeta@we.com', 46589819, '2018-02-09', 8, 'I have a possible C/R to claim #009. In the original claim the second line was denied for CES and the first was paid(G0202). On my claim now the code (77087) is the exact same procedure as the original code paid (G0202), would I deny that line DA? The system has not flagged anything and It would appear to be paying line two on my claim as CES has not denied it this time.', '2018-02-20', 'Request a recovery on  #, as G is not billed on your . Process your  as normal and allow both code, as CES is not denying them.', '2018-02-26', 11, 'Answered'),
(280, 'Thomas', 'Thomas@we.com', 46589820, '2018-01-25', 9, 'I have a POS 21 with a related authorization that is for observation only. There is an IA in history that is denied 3G-39 stating that services are not approved for this level of care. Unsure how to process my claim. ', '2018-02-20', 'You can\'t use the outpatient auth, as it doesn\'t match your facility setting.\n\nYour code is not on the prior auth, so authorisation is not required. Continue with your next step of processing.', '2018-02-20', 11, 'Answered'),
(281, 'John', 'John@we.com', 46589821, '2018-01-26', 3, 'Can you check this claim for POTF? ', '2018-02-20', 'The letter attached appears to be from the PMG, however, there is no paid or denied date on the EOB and so we can\'t use this for POTF.', '2018-02-20', 12, 'Answered'),
(282, 'Aisling', 'Aisling@we.com', 46589822, '2018-02-16', 4, 'Trying to change loc/sts and this message is showing up at the bottom of the screen** %RDB-E-DEADLOCK, request failed due to resource deadlock**', '2018-02-19', ' is closed.', '2018-02-22', 13, 'Answered'),
(283, 'Monica', 'Monica@we.com', 46589823, '2017-12-29', 5, 'CFC 7 claim, corrected to #417. Original claim was 3Q\'d so i\'ve done adjustments in that claim & denyed 3G. The copay max has been met but it needs to be taken now on the corrected claim but the system won\'t allow me to close it. Not sure how to proceed ', '2018-02-19', 'You will need to contact the MOOP mailbox (OOP) and ask them to adjust the cost share for your member. Once they have it adjusted, you will need to apply the $. copay to your  and process it as normal.', '2018-03-06', 14, 'Answered'),
(284, 'Dean', 'Dean@we.com', 46589824, '2018-02-09', 6, 'The claim has shell contract language but the pricing Ssheet has no allowable amount and no reject codes, the SOP says to route to SME for for further investigation', '2018-02-19', 'Deny the  using provider write-off freeform with the letter: \"No contractual rates available for the services billed\"', '2018-02-19', 14, 'Answered'),
(285, 'Zeta', 'Zeta@we.com', 46589825, '2018-02-01', 7, 'I have a system auth with \'DENIED BY GROUP\'... Do I deny this as non covered benefit and link the auth?', '2018-02-15', 'Keep the  OOA, link the auth and deny the ; G- with ARC  and letter \'No authorization received for services rendered\'.', '2018-02-19', 10, 'Answered'),
(286, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589826, '2018-02-09', 8, 'This claim is POS 17 - mobile unit & services have taken place in Vancouver.\nI get to step 17 OOA it is a chronic Dx & the first claim in Hx to that provider 778087401017 is denied by CES.\nThis would indicate that the first visit is authorized or reffered as of SOP & every claim to that provider in Hx is brought in area and capped as a result.\nI can\'t see how this claim was authorized & there is no referring physician so I have no idea how this examiner got to CES.\nIs claim 17 incorrectly processed I know there are reva comments.\nHow should I continue? thanks.', '2018-02-15', ' should be processed as in-area per step  of OOA, as the service billed are telephonic services.', '2018-02-19', 10, 'Answered'),
(287, 'Thomas', 'Thomas@we.com', 46589827, '2017-12-29', 9, 'I have an E&I non par claim that has a pricing sheet attcahed with a t1 reject code. Claim has been to pim and they have verified the DEC. SOP leads me to U&C pricing and there is no rate loaded in NICE and claim comments from U&C state no rate found. I wanted to make sure I would be right to default to 80% billed ?', '2018-02-14', 'Yes, reimburse this  at % of billed charges with ARC ', '2018-02-19', 10, 'Answered'),
(288, 'X8Y', 'X8Y@we.com', 46589828, '2018-01-04', 3, 'I have pended this claim since the 8th of Feb waiting for a Viant pricing sheet to attach as I was given 1 allowable in claim comments but I have 2 codes billed & can\'t decide what allowable is required on each line. The pricing sheet hasnt been attached a week on.\nHow should I continue with this claim?\nThanks.', '2018-02-14', 'Wait till Tuesday th, to see if the pricing sheet attaches. If the pricing sheet still hasn\'t attached by then, then split the payable equally over the  lines.', '2018-02-15', 10, 'Answered'),
(289, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589829, '2018-02-02', 4, 'When I invoke CES, PPOONE ICES EDITS NOT APPLIED comes up in CES comment screen...can I still pay out the claim?\nThere\'s also a UHZX remark code in claim comments?', '2018-02-13', 'As there is no available ARC for this code, please use the iCES remark code as your ARc, i.e. FD', '2018-02-14', 14, 'Answered'),
(290, 'Dean', 'Dean@we.com', 46589830, '2018-02-02', 5, 'MY claim has a contract that states only codes in the fee shedule are payable but its only a single code so my claim is denied. What ARC  should i use to deny the lines not in the fee schedule or what location status?', '2018-02-13', 'As fee schedule # , only has . All other codes should be denied. Deny the remaining lines with ARC  and deny the  provider write-off, using the freeform \"No contractual rates available for the services billed\"', '2018-02-15', 13, 'Answered'),
(291, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589831, '2018-02-12', 6, 'When I went to pay out my claim, it came up \"no contract found for assigned provider\" but there is a contract in screen 9', '2018-02-13', 'Route this  to SHAsgnProv and ask them to fix the contract loaded.', '2018-02-13', 8, 'Answered'),
(292, 'Zeta', 'Zeta@we.com', 46589832, '2018-02-09', 7, 'I have to deny my claim for deductible exceeds payable (SH) and i\'m unsure what letter to use? not on matrix.', '2018-02-13', 'UPDATE /:\n\nDeny the  S and use the letter for Q denial.', '2018-02-13', 9, 'Answered'),
(293, 'David', 'David@we.com', 46589833, '2018-02-12', 8, 'Following the OOA process this pos 23 claim woud be kept out of area but there is an oj(#011) in history with the same dos and a simalar dx, though it has a different name and address should I use this to bring my claim in area?', '2018-02-13', 'Follow the OOA guidelines for ER.', '2018-02-14', 4, 'Answered'),
(294, 'Terry ', 'Terry @we.com', 46589834, '2018-01-16', 9, 'Falling under chronic, 1st visit denied non covered . Would it be correct to deny my claim no covered per step 18', '2018-02-12', 'Yes, follow the denial per step .', '2018-02-13', 5, 'Answered'),
(295, 'Aisling', 'Aisling@we.com', 46589835, '2018-02-08', 3, 'Per SOP pos 12 can you please review in/ooa for this claim.', '2018-02-12', 'Follow step  of the OOA SOP.', '2018-02-13', 6, 'Answered'),
(296, 'Monica', 'Monica@we.com', 46589836, '2017-12-29', 4, 'CFC 7 claim & trying to do immediate recoupment on claim #332 but i keep getting this error message..CANNOT PROCESS THIS CLAIM, 837 STILL PROCESSING. TRY AGAIN LATER. I\'ve never seen this before & #332 has been closed since October?', '2018-02-12', 'There is currently a problem with the recovery screen and the IR process. Please pend s that require IR until problem is resolved.\n\nUPDATE /:\nProblem has been fixed and you should be able to do an IR on the original .', '2018-02-13', 6, 'Answered'),
(297, 'Aisling', 'Aisling@we.com', 46589837, '2018-02-02', 5, 'can you please check proof of timely filing>?', '2018-02-12', 'No dates available bring  within TF limits.', '2018-02-13', 2, 'Answered'),
(298, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589838, '2018-02-05', 6, 'Screen 18 language, unsure to price with carrier locality or without. Please advise', '2018-02-09', 'Price the  at % of CMS, using the zip code in provider inquiry screen (Numlock + Y) to determine you carrier locality.', '2018-02-13', 2, 'Answered'),
(299, 'Shane Meehan', 'Shane Meehan@we.com', 46589839, '2018-01-22', 7, 'Claim meets CA wildfire criteria. Claim has 8 codes billed and one is outside the date span would I still pay all codes billed?', '2018-02-09', 'Follow the no auth/no facility for this .', '2018-02-12', 3, 'Answered'),
(300, 'Aisling', 'Aisling@we.com', 46589840, '2018-01-23', 8, 'Pecos. checked the npi from the  service provider and its not fitting into the pecos denial exceptions however when you search the npi in coloum J for philip granchi it brings up provider type 30! im not sure if we can use this npi or not if not i would be denying the claim.', '2018-02-09', 'As OH - Other is not list in the PECOS denial exceptions, allow PECOS to be applied to this .', '2018-02-12', 3, 'Answered'),
(301, 'Dean', 'Dean@we.com', 46589841, '2018-02-05', 9, 'My claim is being denied as a duplicate to claim 21 but 21 is denied for PECOS and I cant find the correct insert for my denial letter.', '2018-02-09', 'There is no PECOS flags on your  and should be considered a corrected  to #', '2018-02-12', 7, 'Answered'),
(302, 'Terry ', 'Terry @we.com', 46589842, '2017-12-20', 3, 'claim has no fac & auth but falls under wildfire exceptions. \nIs claim correct to still be denied 3g-48 ', '2018-02-08', 'You can still deny Wildfire s for no auth/no facility as we only bypass the authorisation guidelines, as this process is called out in OOA, we can still follow the normal OOA guidelines.', '2018-02-13', 7, 'Answered'),
(303, 'Myles', 'Myles@we.com', 46589843, '2018-01-31', 4, 'For my clm #004 box 32 is blank, Num Y and 33 have P.O. Box. There are 2 Hx clms AP #003 and MB #002 that look to have been done at the same location. Can i use the zip from the AP as a valid location for my clm tp price it.', '2018-02-08', 'You can\'t use this s, as they\'re not related.', '2018-02-08', 7, 'Answered'),
(304, 'Shane Meehan', 'Shane Meehan@we.com', 46589844, '2018-01-24', 5, 'Per note on auth #3910147 would this deny the claim in auth step 9 per denied not medically indicated?', '2018-02-08', 'Yes, you will need to follow the updated note in the auth comments screen and deny this  for not medically necessary', '2018-02-08', 1, 'Answered'),
(305, 'Chris ', 'Chris @we.com', 46589845, '2017-12-07', 6, 'I have already asked a question regarding this claim and the CES edit & I was instructed to route for manual pricing. However, it is returning from pricing with no update including a claim comment saying pricing already attached see sheet in imaging?\nI dont know how to continue with this claim.', '2018-02-07', 'Contracted Dwayne to try and obtain Viant pricing sheet.\n\nUPDATE /:\n comments have been updated to include Viant pricing, please wait for the sheet to attach.', '2018-02-08', 5, 'Answered'),
(306, 'Terry ', 'Terry @we.com', 46589846, '2017-12-29', 7, 'Orignally a facility claim type , is claim correct to be an AU and denied following MCR Comments ? ', '2018-02-07', 'The  is correct to be cardiology. I wouldn\'t follow this MCR comments, as there is an address available in the Numlock + Y screen. Please use this address for OOA and pricing.', '2018-02-08', 6, 'Answered'),
(307, 'Dean Curran', 'Dean Curran@we.com', 46589847, '2018-01-29', 8, 'Claim was brought in area per screen 11 language (Zip Code 97032) and the system capped it. I went to double check the risk and reached a carve out with U indicator and ER admit comment, according to sutter process the risk would be pp01-n as its POS 23 and not on the sutter facility list, unsure whether I trust the system or change the risk to payable', '2018-02-07', 'As your facility is a non-Sutter facility, risk should be planned risk.', '2018-02-07', 8, 'Answered'),
(308, 'Terry ', 'Terry @we.com', 46589848, '2018-01-19', 9, 'WOULD THE SECOND AUTH (3907340) BE OK TO USE FOR MY CLAIM ', '2018-02-07', 'For this auth the Dec#, nor the TIN matches. But as the name of the facility matches, could you please send this to MCR to review the auth for your .', '2018-02-07', 9, 'Answered'),
(309, 'Myles', 'Myles@we.com', 46589849, '2018-01-15', 3, 'My clm has Box 32 blank, Num Y and Box 33 are P.O. Boxes. Clm #081 is billed by the same provider and has used sys auth #3907472 to process the clm in area. Can i use clm #081 to take my clm in area? Thanks.\n', '2018-02-07', 'You can use auth#  for you can. Follow this for your OOA determination. ', '2018-02-07', 4, 'Answered'),
(310, 'Rebecca', 'Rebecca@we.com', 46589850, '2017-12-15', 4, 'Claim returned from UHC with $0.00 allowable.  Followed processing guidelines and returned to UHPRev (per UHE1 Suspend)  Pricing ($0.00) has now been confirmed - how should this claim be closed out? \n\n', '2018-02-06', 'Please deny this  provider write-off and use the freeform letter \"No separate reimbursement for these services billed\"', '2018-02-07', 12, 'Answered'),
(311, 'Aisling', 'Aisling@we.com', 46589851, '2018-01-22', 5, 'there is an OU 047 and a IA 089 for my dates of service mine is for pos 21, however there is a comment from mcr saying that my claim is related to 047 should this be denied per step 7 image vs nice or could i process on with there being an IA in history???', '2018-02-06', 'Follow the IA as your related . Your primary Dx I. has a similar Dx I. on the IA and your POS is .', '2018-02-07', 11, 'Answered'),
(312, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589852, '2017-12-26', 6, 'As per exceptions with codes that are on the SB188 Drugs List when the member is under 18 years old we take rates from screen 10 but for Line #4 I cant price it from that screen?\nHow should I price this line, I have rates from screen 10 for my other payable lines?', '2018-02-05', 'As there is no rates available in screen  for , apply the rate found in screen  - fee schedule.', '2018-02-06', 11, 'Answered'),
(313, 'Zeta', 'Zeta@we.com', 46589853, '2018-01-21', 7, 'I have come to step 11 CES (SH) SOP and it tells me to:\n?	 Pend the claim to your personal pends. \n?	Email SME to have the claim routed to Medicare & Retirement CES site\n \nMy SME is unsure of the correct process. ', '2018-02-05', 'I have done a critical data changed, please route the  to CESDelay for the system to extract CES', '2018-02-06', 12, 'Answered'),
(314, 'Terry ', 'Terry @we.com', 46589854, '2017-01-22', 8, 'Second opinion needed on if claim is corrected to be denied for timely filing ', '2018-02-02', 'There is no POTF attached to this , so you\'re okay to deny for TF.', '2018-02-05', 13, 'Answered'),
(315, 'Shane Meehan', 'Shane Meehan@we.com', 46589855, '2018-01-25', 9, 'Am I correct to cap out this claim? PC0147 is calling out infertilty and per sutter matrix for E&I PMG risk.\n\nThe DX is also on ART PROC GUIDE SOP advanced infertility. can I just follow the sutter matrix for basic infertility?', '2018-02-02', 'Can you route this  to MCR to determine if the  is basic or advanced, using the following comments \"MCR required to determine ART vs. Basis Infertility\"\n\nOnce the  is back from MCR follow the Sutter Matrix related to that infertility.', '2018-02-05', 14, 'Answered'),
(316, 'Monica ', 'Monica @we.com', 46589856, '2017-11-02', 3, 'Misdirected claim that can now be processed due to facility claim in hx. It\'s promting for interest but i\'m not sure what i should go for. Can\'t see anything in the interest sop that related to it. The only thing is says for misdirected is if additional info was needed but it was right at the time to be capped...', '2018-02-02', 'As this  was processed correctly at the time and only become a share risk once the facility  was received, I would use the received date of the facility  (//) as the date interest should apply from.', '2018-02-05', 14, 'Answered'),
(317, 'Shane Meehan', 'Shane Meehan@we.com', 46589857, '2018-01-12', 4, 'E&I claim with a visalia contract, How should this be priced? Only DEC available is the one linked. Can I use the rates from the corp drive at 70% and what Arc?', '2018-02-01', 'For Visalia Pathology Group, follow your normal contract hierarchy for this contract:\n\n.	% of the clinical labs per the corp drive\n.	Rates per CMS\n.	% of billed charges\n\nIf you\'re reimbursing at a Medicare rate, please use ARC  and ignore EPD alert .', '2018-02-02', 10, 'Answered'),
(318, 'Terry Tyrrell', 'Terry Tyrrell@we.com', 46589858, '2018-01-15', 5, 'OOA - For related claim , I have one AN denied  not covered and also a AP which has beeen paid, how do I determine the correct related claim to use ', '2018-01-31', 'Follow the facility bill.', '2018-02-02', 10, 'Answered'),
(319, 'Myles Connor', 'Myles Connor@we.com', 46589859, '2018-01-05', 6, 'This clm is a c/r for # 074 & # 003. Clm # 003 was initially paid then a recovery done for some reason. Clm #074 was marked as c/r on image and was denied 07/3B. My Dx is the same but on my clm they have used 28 mod and altered the bill charges. Can i use auth 3828283 for my clm, if not can i use clm # 009 as related, the Dx is similiar? Thanks. ', '2018-01-30', 'You can\'t use the auth, as the providers don\'t match. Could you route this  to MCR again, stating that this is a corrected  and if they can review it for OOA. As they never reviewed # for OOA.', '2018-02-02', 10, 'Answered'),
(320, 'Terry Tyrrell', 'Terry Tyrrell@we.com', 46589860, '2018-01-05', 7, 'Following KL this claim should be paid, Although the claims in history and facility are denied not covered, should I denying as the AN in history is denied not covered ? ', '2018-01-30', 'You will need to follow the same outcome as the facility .', '2018-02-02', 10, 'Answered'),
(321, 'Asiling', 'Asiling@we.com', 46589861, '2018-01-11', 8, 'Pos 12 per sop need sme to verify if ooa?', '2018-01-29', 'Process  as in-area', '2018-01-30', 14, 'Answered'),
(322, 'Terry ', 'Terry @we.com', 46589862, '2018-01-04', 9, 'per question 18 ooa -\nIs there a related out-of-area (OOA) claim in history with a primary or secondary diagnosis billed as urgent/emergent?\nCould I use claim 21 AO ?', '2018-01-29', 'Yes you can use this . Both are performed in the same facility and both primary Dx\'s are to do with the respiratory system.', '2018-01-29', 13, 'Answered'),
(323, 'X8Y', 'X8Y@we.com', 46589863, '2017-11-10', 3, 'I cant see claim comments for this claim past the second page. The payable is over 14000 and I am reluctant to pay this as I dont know what has happened on the claim before this.\nIs there any way earlier comments can be viewed?', '2018-01-29', 'There is no way to load the comments. You will have to process the s using the comments available.', '2018-01-29', 8, 'Answered'),
(324, 'X9A', 'X9A@we.com', 46589864, '2017-11-10', 4, 'please advise how to process OOA per step 8 when member address matches box 32 with pos 13.', '2018-01-29', 'Assisted living isn\'t covered on this step, please carry onto the next step.', '2018-01-29', 9, 'Answered'),
(325, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589865, '2018-01-22', 5, 'This is a Medicaid claim.\nIt looks to me like a partial dup. However, the DEC # linked is different to claim #774841702017 but I am wondering does this even matter as we are paying renderring provider and the renderring provider is the same in both claims? If i follow sop it states that this will be a C/R as the DEC # differs?\nWhat should I do in this case?', '2018-01-29', 'The Dec# linked to your  doesn\'t match, please change the Dec# to the one linked on  # and process the  accordingly.', '2018-01-29', 4, 'Answered'),
(326, 'aisling', 'aisling@we.com', 46589866, '2017-12-22', 6, 'Could you please claim type map this claim,i dont think it should be an OA-R?', '2018-01-29', 'Process  as OA.', '2018-01-29', 5, 'Answered'),
(327, 'Paddy', 'Paddy@we.com', 46589867, '2017-12-28', 7, 'my clm is corrected to clm #24. there have been a few clms processed incorrectly as duplicates to clm #24. the difference is box 33. clm #24 has now been paid.\n\nshould i set up a recovery on original clm #24 & then pay my clm per the address difference? my thought is that the provider has been paid to the wrong address hence why they continue to send duplicates.', '2018-01-25', 'The incorrect Dec# (per the information in box ) is linked. Please link Dec# -. As the provider is different then #, you will need to request a recovery on this ', '2018-01-29', 6, 'Answered'),
(328, 'X9A', 'X9A@we.com', 46589868, '2018-01-16', 8, 'please review for TF per doc page 4/11 & advise how to process. original claim #248. copay applied on line 1 & 2 originally, claim denied provider write off with SW Arcs on lines 3 & 4.', '2018-01-25', 'The dates on the EOB won\'t bring the  within TF limits and should be denied for TF. You will also need to reopen  # and reverse the copay that has been incorrectly applied to it.', '2018-01-25', 6, 'Answered'),
(329, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589869, '2017-12-07', 9, 'Claim recieved back from MCR with regards to Chromosome Microarray review that I requested.\nHowever, MCR states no review required for this Px code?\nAnother comment from some examiner then states box 32 required for processing but there is a suitable address there I think? What should I do as I cant price this code see CES edit ', '2018-01-25', 'Box  isn\'t required on E&I s. As MCR states that no review is required, can you please route the  for manual pricing.', '2018-01-25', 2, 'Answered'),
(330, 'Terry ', 'Terry @we.com', 46589870, '2018-01-23', 3, 'Unsure wheither to deny for pecos - provider type is 99 ALL PROVIDER, when searching NPI it is returning with Radiology Diagnostic Radiologya and also is pecos flags sop is states 99 is a dummy provider ', '2018-01-25', 'As provider type  covers multiple provider types, apply the same rules as  and follow the NPI registry. Per the NPI registry the providers primary taxonomy is Radiology Disgnostic and this maps to . As  is called out on the exceptions, you should consider the services payable', '2018-01-29', 2, 'Answered'),
(331, 'Terry ', 'Terry @we.com', 46589871, '2018-01-09', 4, 'This claim has a unbundled code but the the unbundled code is in the same claim not in history , would this mean that I am paying code 88344 and denying code 88380 within the same claim.', '2018-01-25', 'Allow the CES denial. Unbundled codes can be on the same  or any  that falls on the same DOS.', '2018-01-29', 3, 'Answered'),
(332, 'aisling', 'aisling@we.com', 46589872, '2018-01-02', 5, 'screen 18 contract lang - is relating to REIMBURSEMENT RATES FOR TRANSPLANTS there is no F/S and its contracted provider,when i looked for another dec there was none to match so should i treat this as non par??', '2018-01-25', 'Contract  that is linked can not be used. Please follow the provider verification SOP.', '2018-01-29', 3, 'Answered'),
(333, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589873, '2017-12-20', 6, 'MCR comments regarding iSET - We have never been shown how to use iSET I dont know what I am looking for on the site in relation to the MCR comments on my claim?', '2018-01-24', 'Deny the whole  non-covered put the auth.', '2018-01-29', 7, 'Answered'),
(334, 'Shane', 'Shane@we.com', 46589874, '2018-01-03', 7, 'claim is rework claim , apparently it is wrong to be in area . \nper pos 81 can claim 77 (AD-I)  be used as a related claim to keep it out of area ? \n', '2018-01-24', 'Follow the OOA determination on related  #.', '2018-01-29', 7, 'Answered'),
(335, 'X9A', 'X9A@we.com', 46589875, '2017-12-11', 8, 'This clm is is a dup to #021. From the payment distibution screen of #021 it says it was paid on 03/09/17 with check no # DR033787 for $78.08 but there is no overall total as normal showing. Has this check gone? If so can I assume the total on that check was just $78.08? How should I proceed? Thanks.', '2018-01-23', 'The  has been paid by correspondence, so you can use the $. as the total amount paid also. ', '2018-01-25', 7, 'Answered'),
(336, 'John', 'John@we.com', 46589876, '2018-01-22', 9, 'This clm has suspend for PECOS, it has flagged \"XX17-Provider Type 70 on claim with PECOS/PMD\" but Nice is showing the type as 30, with POS 23 and its a radiology clm so PECOS shouldn\'t stand. I can\'t see anything in the PECOS SOP to resolve the suspend. How do i proceed? Thanks.', '2018-01-23', 'Please follow the PECOS Denail Exceptions section of the SOP.', '2018-01-23', 1, 'Answered'),
(337, 'Shane', 'Shane@we.com', 46589877, '2018-01-03', 3, 'claim is rework claim , apparently it is wrong to be in area .\nper pos 81 can claim 77 (AD-I)  be used as a related claim to keep it out of area ? ', '2018-01-23', 'This is a Skilll Nursing Facility , also the  is closed.', '2018-01-24', 5, 'Answered'),
(338, 'Myles', 'Myles@we.com', 46589878, '2018-01-16', 4, 'OOA\nDM Auth with comment \"KROBE28,01-04-2018 08:07AM:allow ancillary and professional providers..krobertsonlvnmcr\"\nMy claim only has 1 code which has a 28 mod. \nShould I pay it? \n\n ', '2018-01-23', 'Use the auth to determine OOA, but don\'t deny the  and follow the update that is provided on the auth comments screen.', '2018-01-24', 6, 'Answered'),
(339, 'catherine ', 'catherine @we.com', 46589879, '2018-01-01', 5, 'related claim in history 049 has been denied for DM auth,but the auth doesnt match my dates there is a mcr comment REC IN MCR ALLOW ANCILLARY AND PROFESSIONAL CLAIMS. DENIAL is FOR FACILITY ONLY, MBR MET OBS.KROBERTSONLVNMCR, but following the sops the claim will be payabe,but with the related facility claim being denied should i be denying mine too??', '2018-01-19', 'You will need to deny your  due to the outcome on the related  #. \n\nMCR was reviewing the auth and saying the auth doesn\'t apply, however, for OOA you will need to follow the outomce of the facility bill.', '2018-01-24', 8, 'Answered'),
(340, 'catherine ', 'catherine @we.com', 46589880, '2018-01-12', 6, 'Have a TK in history 077 drop of point doesnt match my address in box 32 could this still be used as a related claim?', '2018-01-19', 'No this ambulance  can\'t be used as related, as the ambulance has picked up the member from your hospital.', '2018-01-22', 9, 'Answered'),
(341, 'David', 'David@we.com', 46589881, '2018-01-15', 7, 'Would I be right to deny this claim for no address in box 32 or although different dates should address in back screen of claim 28 be used for the address ?', '2018-01-18', 'You\'re unable to use  #, as the  is unrelated. As such, following the M&R Non-par pricing, you will be denying the  for P.O. Box in box .', '2018-01-19', 4, 'Answered'),
(342, 'Chris ', 'Chris @we.com', 46589882, '2017-12-27', 8, 'With the first 3 lines denying for pecos and last line being a ces denial - would I be right to deny for CES ? ', '2018-01-17', 'This scenario is called out denial hierarchy exceptions on the PECOS SOP. Please follow this.', '2018-01-19', 12, 'Answered'),
(343, 'David', 'David@we.com', 46589883, '2017-09-27', 9, 'Alert \"DEC# MISMATCH - CURRENT CLAIM VS ORIGINAL CLAIM - PLEASE REVIEW\" comes up when I try to pay.', '2018-01-17', 'This  is a CFC, please route to Corr queue for processing.', '2018-01-23', 11, 'Answered'),
(344, 'Monica', 'Monica@we.com', 46589884, '2017-12-20', 3, '**INTERVENTION CLAIM - REFER TO SHAREPOINT** \n', '2018-01-17', 'Please refer to the CA Wildfire Bulletin & review if  needs to be paid based on exceptions listed. If paying per bulletin, ensure  comment ?California Wildfire exception process? is entered. ', '2018-01-17', 11, 'Answered'),
(345, 'Lesley-Ann', 'Lesley-Ann@we.com', 46589885, '2017-11-27', 4, 'This claim was paid. A pecos flag then appeared and adjusted the payable to $0 but the check was still sent.  It was then relogged and the relogged claim has been paid.  A recovery was then requested on the original claim so it could be deleted on the 12-28-17. How long does the recovery process take as I am getting emails about a ticket to have the claim deleted?', '2018-01-17', 'The recovery process can take some time, as the provider doesn\'t always seems the recoveries as they come in and could instead process all recoveries as the end of the year. As such, best to close the ticket and enter a  comment, directing other examiner to no process the .', '2018-01-17', 12, 'Answered'),
(346, 'Catherine ', 'Catherine @we.com', 46589886, '2017-08-22', 5, 'As the only difference between my claim and claim number #3 is the the second digit of the billing address , would this make my claim a corrected claim to claim #3 ? ', '2018-01-17', 'Treat this  as a dupe. The provider must have mistyped on  #, as that zip code isn\'t valid for the PO Box billed.', '2018-01-17', 13, 'Answered'),
(347, 'Rebecca  ', 'Rebecca  @we.com', 46589887, '2017-08-22', 6, 'With the first 3 lines denying for pecos and last line being a ces denial - would I be right to deny for CES ? ', '2018-01-17', ' closed.', '2018-01-17', 14, 'Answered'),
(348, 'Chris', 'Chris@we.com', 46589888, '2017-08-22', 7, 'MCR Comment states \"unable to process without fac\" however there shouldn\'t be a fac for POS 13. Please confirm whether i deny this 4W or provider write off per MCR comment.', '2018-01-17', 'Deny the  for provider write off as per MCR comments', '2018-01-17', 14, 'Answered'),
(349, 'Shane', 'Shane@we.com', 46589889, '2017-08-28', 8, 'Just trying to fix this PECOS claim. I?ve done adjustments in back screen to deny out but I can?t get it closed again. Can you take a look at it please? Thanks ', '2018-01-17', 'There has been a check issue for the amount of $., you will need to adjust the back screen to show this in the payable field. You will be able to close the  then and you will need to request a recovery for this amount.', '2018-01-17', 10, 'Answered'),
(350, 'Chris', 'Chris@we.com', 46589890, '2018-01-11', 9, 'My clm #838897801027 is POS 23, no info in box 32, and PO Box in 33 and Num Y. there is another OB clm # 838897801024 that was taken in area from the address in Num Y. There is also an unprocessed AJ clm # 838897801028 that has an address in Box 1 but that leaves my clm OOA. Can I use the address from the OB to take my In area, or should i use the AJ address.', '2018-01-16', 'Please follow point  on step  of the OOA step:\n\nReview member?s  history for related s that may have the same facility setting.\n\nFollowing this, you will use the AJ in history. ', '2018-01-17', 10, 'Answered'),
(351, 'Thomas', 'Thomas@we.com', 46589891, '2017-12-15', 3, 'corrected claim its a contracted provider epd is flagging for timely filing looking at the sop should i still be taking the timely filing limit from the contract or should i be giving it 387 days?not sure if i should deny it or not?', '2018-01-16', 'As there is no timely filing limits called out in the contract, you will need to apply the default limits. This will make the  within TF limits.', '2018-01-16', 10, 'Answered'),
(352, 'Zeta', 'Zeta@we.com', 46589892, '2018-01-10', 4, 'Copay,ces had denied my rad code but i have the set up code and transport code still payable there is 14 dollars copay in the back screen should this be applied to one of these codes?', '2018-01-16', 'Please benefit map your  and apply the benefit that maps to your code.', '2018-01-16', 10, 'Answered'),
(353, 'Chris Flanagan', 'Chris Flanagan@we.com', 46589893, '2017-03-22', 5, 'should the pecos on this claim stand?did an NPI search and its showing  MULTI-SPECIALTY GROUP and Pediatrics?', '2018-01-16', 'Please refer to the PECOS Denial Exceptions subsection in the PECOS SOP and follow the provider types called out. If your provioder type isn\'t listed, then the  isn\'t except.', '2018-01-16', 14, 'Answered'),
(354, 'Chris', 'Chris@we.com', 46589894, '2017-12-20', 6, 'I cannot understand comments from MCR -\nI think the auth should be linked and 83970 denied ARC 21 but what is the language regarding the members EOC about?\nAre the remaining codes payable?', '2018-01-15', 'Evidence of coverage, means you will need to review iSet to see if the member has additional coverage for these. ', '2018-01-16', 13, 'Answered'),
(355, 'Chris', 'Chris@we.com', 46589895, '2017-12-29', 7, 'This claim has corrected claim marked on the image although there is no claim in history I can relate it to,  it is also to be denied for timely fileing but when i try to change it to 07/3g status the system prompts \"CO-E-000  CONTACT COMPUTER OPERATIONS IMMEDIATELY\".  ', '2018-01-15', 'I have removed the CFC from the s header info screen, so you should be fine to process the  now.', '2018-01-16', 8, 'Answered'),
(356, 'Chris', 'Chris@we.com', 46589896, '2017-01-04', 8, 'Following the SOP my claim would be a dup to claim to claim 31, although 31 is a CFC7 so would make it a corrected claim ? ', '2018-01-15', 'As the CFC isn\'t on your , you can deny the  as a dupe.', '2018-01-16', 9, 'Answered'),
(357, 'Catherine ', 'Catherine @we.com', 46589897, '2017-01-04', 9, 'As any claim I am deny step 7 image vs nice is being routed back to my pends for incorrect denial (PLEASE SPECIFY DENIAL CORRECT TEMPLATE AND EOB  IN NICE I COMMENT)\n\ncan I please get confirmation I am denying correct:\nSH3GNK 3G-80                                            \nINCORRECT PLACE OF SERVICE BILLED, SUBMIT A CORRECTED CLAIM', '2018-01-15', 'Yes this is the correct denial. If the letter team send it back again, please email me and I will contract them.', '2018-01-16', 4, 'Answered'),
(358, 'Catherine', 'Catherine@we.com', 46589898, '2017-01-04', 3, 'Would claim be comsidered a dup or corrected claim to 21. unsure as billing address is just out by 1 digit ', '2018-01-12', 'Please process this  as a dupe.', '2018-01-16', 5, 'Answered'),
(359, 'Chris', 'Chris@we.com', 46589899, '2017-12-26', 4, 'Denying claim for timely filing, second opinion needed on wheither I am right to do so ', '2018-01-12', ' closed.', '2018-01-15', 6, 'Answered'),
(360, 'Myles', 'Myles@we.com', 46589900, '2017-12-11', 5, 'Should claim be treated as dup or recorrected\nreplacement ? unsure ', '2018-01-11', 'Please specify the other ', '2018-01-16', 6, 'Answered'),
(361, 'Thomas', 'Thomas@we.com', 46589901, '2017-12-29', 6, 'Would you be able to claim type map this claim for me, Thanks', '2018-01-11', 'Please process this  as Cardiology.', '2018-01-15', 2, 'Answered'),
(362, 'Catherine ', 'Catherine @we.com', 46589902, '2017-12-29', 7, 'second opinion needed on wheither claim it right to be denied for timely filing ', '2018-01-10', 'Yes please deny for TF, as we\'re unable to determine a source for this POTF submitted.', '2018-01-15', 2, 'Answered'),
(363, 'Shane', 'Shane@we.com', 46589903, '2018-01-04', 8, 'i have a tk-g clm 018 the system has grouped returned it however the drop off address is blank can i use this as my related claim or would i just keep mine OOA as there are AJs that have been processed OOA?', '2018-01-10', 'The drop off on  # matches your , so you can use it as related. I checked the OOA of that  and it should be OOA. I will get that  assigned and processed.', '2018-01-15', 3, 'Answered'),
(364, 'Catherine ', 'Catherine @we.com', 46589904, '2017-12-14', 9, 'Can you please review the comments on this claim should i be denying this claim out per the Ndm comment?>>', '2018-01-10', 'As there is a matching Dec# linked, ignore the NDM comments that tell you to deny your  and continue to process the .', '2018-01-15', 3, 'Answered'),
(365, 'Catherine ', 'Catherine @we.com', 46589905, '2017-12-14', 3, 'can the Ap in history be used as a related claim for POS 22, I would be paying my claim if this was ok to use but claim in history have not used its and denied the claims ?', '2018-01-10', 'Yes you can use the AP - OOA Outpatient/Doctors Office, as your related . By using this as your related , you will be denying your  non-covered', '2018-01-16', 7, 'Answered'),
(366, 'Catherine ', 'Catherine @we.com', 46589906, '2018-01-04', 4, 'MULTIPLE MODIFIER PRICING , No address in box 32 , would claim be right to be denied ', '2018-01-10', 'We are unable to determine the service facility address, so  should be denied G- using ARC .', '2018-01-16', 7, 'Answered'),
(367, 'John', 'John@we.com', 46589907, '2017-12-27', 5, 'would claim be right to be denied for timely timing ', '2018-01-10', ' is closed.', '2018-01-10', 7, 'Answered'),
(368, 'Chris', 'Chris@we.com', 46589908, '2017-12-06', 6, 'could you please have a look at the mcr comments on this claim,an how i should move forward??', '2018-01-10', 'MCR require a facility bill to determine the auth - the auth will remain pended till the faility is received. As no faility has been received and the  is getting aged, can you deny the  for no auth/no facility.', '2018-01-10', 1, 'Answered'),
(369, 'Chris', 'Chris@we.com', 46589909, '2017-12-12', 7, 'IC08-NO ICES EDITS DUE TO MISSING CARRIER ID per sop Email SME to have the claim routed to Medicare & Retirement CES site,', '2018-01-10', 'IC is when the system is unable to determine the carrier locality of the service provider.\n\nFor this  can you enter the following comments: Please re-run CES using carrier zip code . \n\nAnd then route the  to the iCESPND in an open status.', '2018-01-10', 5, 'Answered'),
(370, 'x9a', 'x9a@we.com', 46589910, '2017-12-12', 8, 'Claim is related to chemo, however the most dominant service on claim is the lab code so I think it\'s right to be an OC....? However the contract langauge on screen 18 has language related to Chemo that I don\'t understand. How should I proceed with it? Thanks', '2018-01-09', 'I have adding a comment on the pricing for each of the codes billed (not the lab, as this code is capped). \n\nYou will need to muiltply the units billed by the doesage to find the strength, i.e. line  = mg, line  = mg (NOTE line  = doesn\'t show a doesage and this should be considered ml). Price is per ml, each of the pricing is strength in relation to ml\'s. Use the calculation for the strength to determine the correct price for each line. \n\nOnce you have found the pirce for each line, you will need to multiply this by your contract %, i.e. less % \n\nWhen adjusting these, use ARC ', '2018-01-10', 6, 'Answered'),
(371, 'Aisling', 'Aisling@we.com', 46589911, '2017-12-12', 9, 'should claim be denied for timely filing following attachments', '2018-01-09', 'I can\'t determine who the POTF was sumitted to. As there is no valid billing recipent, this  should be denied for TF', '2018-01-10', 8, 'Answered'),
(372, 'x9a', 'x9a@we.com', 46589912, '2017-12-12', 3, 'Would this claim be classed as pecos ', '2018-01-09', 'Please review the PECOS screen - option Q from Nice Submenu', '2018-01-10', 9, 'Answered'),
(373, 'Monica', 'Monica@we.com', 46589913, '2017-12-26', 4, 'OOA Progess - 3rd code it covered by auth as it is a separte date , other codes could be denied california inpatient,  would I be denying all codes and paying the last ?', '2018-01-08', 'Link the auth and process the  as OOA. The remaining codes will be allowed per related  #', '2018-01-10', 4, 'Answered'),
(374, 'Shane', 'Shane@we.com', 46589914, '2017-12-27', 5, 'should claim be denied for timely filing following attachemnts ', '2018-01-08', 'I can\'t determine who the POTF was sumitted to. As there is no valid billing recipent, this  should be denied for TF', '2018-01-09', 12, 'Answered'),
(375, 'Monica', 'Monica@we.com', 46589915, '2017-11-13', 6, 'CES flag IC94 BPS,  per the ces for nice spreadsheet the examiner action should be to route to ICES pend que. However when I did this it was routed back to my pends with the claim comment \"submitted for ces review to wrong que, pls wait for system edits to apply.\"   How should I proceed with this?', '2018-01-05', 'Route this back to CESPnd with routing and  comments: valid POS () on , please review again for other edits ', '2018-01-09', 11, 'Answered'),
(376, 'Catherine ', 'Catherine @we.com', 46589916, '2017-12-19', 7, 'This clm #007 is billing more than 20 lines, i need to have it manually accessed for CES. ', '2018-01-05', 'Route the  to CESPnd with routing and  comments: exceeds lines for CES and requires manual review', '2018-01-09', 11, 'Answered'),
(377, 'Thomas', 'Thomas@we.com', 46589917, '2017-12-22', 8, 'could the AP in history be used as a related claim to my claim ', '2018-01-05', 'Yes AP can be related. \n\nThe referring physician in box  on your  is the physicina in box  on the AP. Plus your Dx - I. is similar to the AP Dx - I., both have to do with heart attackes. ', '2018-01-09', 12, 'Answered'),
(378, 'Catherine ', 'Catherine @we.com', 46589918, '2017-11-10', 9, 'claim recieved back from pimm with coment \'  PER NTWK MGMT UNABLE TO BILL WITH NAME RADIANT/PO NEED  TO RESUBMIT SINCE DOS OF NOT 01/01/18   ID:SKO?\n? 2-JAN-2018 12:77 NDM12  \' . Should claim be denied following this comment ?                                ', '2018-01-05', 'Yes deny this  use ARC  and G-, copying the comments from PIM as your letter.', '2018-01-09', 13, 'Answered'),
(379, 'James Woods', 'James Woods@we.com', 46589919, '2017-12-27', 3, 'I have one line payable on my claim the rest is capped but the line that is payable is  a lab transport code,there is $10 copay on the back screen which the system has taken it off this code is this allowed or should it be backed out and priced manually', '2018-01-05', 'Allow this copay, as this is the correct copay for this code.', '2018-01-09', 14, 'Answered'),
(380, 'X9A', 'X9A@we.com', 46589920, '2017-12-27', 4, 'Would this claim be classed as pecos ', '2018-01-04', 'PLEASE VERIFY  #', '2018-01-09', 14, 'Answered'),
(381, 'Myles', 'Myles@we.com', 46589921, '2017-12-21', 5, 'Risk is directing me to screen 11. I think it should be capped is this correct?', '2018-01-04', 'Following screen  I would apply PMG risk. \n\nUsing: Laboratory/pathology - OP - Diagnostic (hospital based-non-surgery related)', '2018-08-16', 10, 'Answered'),
(382, 'X9A', 'X9A@we.com', 46589922, '2016-11-21', 6, 'Would attachments be proof  for timely filing ?', '2018-01-04', 'No this can\'t be used, as this doesn\'t match your ', '2018-01-09', 10, 'Answered'),
(383, 'X9A', 'X9A@we.com', 46589923, '2017-12-21', 7, 'should 20% copay be paid on my claim if MB in history has paid 30% ', '2018-01-04', 'The only limit to the amount of times youcan apply a % copay, is the copay max. So you can apply the % copay to your  too.', '2018-01-09', 10, 'Answered'),
(384, 'John', 'John@we.com', 46589924, '2017-11-17', 8, 'Double checking auth is ok to check, to confirm comment deny entire stay is for the above date in auth comments ', '2018-01-03', 'PLEASE VERIFY  NUMBER', '2018-01-09', 10, 'Answered'),
(385, 'Monica', 'Monica@we.com', 46589925, '2017-12-07', 9, 'Ces edit - Current line diagnosis O09729 is not valid with current line procedure code 81229. This line requires manual review. SDX Policy: Chromosome Microarray\n\nI reviewd the UHP return code spreadsheet and found appropriate ARC\'s. However, I\'m not sure what I should be reviewing & system ARC 8A still leaves 8700 payable.', '2018-01-03', 'Upon reviewing the Chromosome Microarray policies, O. isn\'t an applicable Dx for this service. \n\nHowever, the list isn\'t a finite list. Can you please route this  to MCR and ask them to review Chromosome Microarray.', '2018-08-16', 14, 'Answered'),
(386, 'LESLEY-ANN', 'LESLEY-ANN@we.com', 46589926, '2017-10-20', 3, 'Would claim be correct to process in area if related claim 29 has gis comments but which is also processed in area and capped ', '2018-01-03', 'I got  # re-assigned and the  is now getting reviewed again, as it seems to be OOA. Please waiting till # is fully processed before processing your . \n\nYou can route your  to PilNoFac in the time being.', '2018-01-09', 13, 'Answered'),
(387, 'LESLEY-ANN', 'LESLEY-ANN@we.com', 46589927, '2017-11-23', 4, 'misdirected claim auth 2.states that its approved but there are auth comment telling me to Deny entire stay/case as not medically necessary-facility liability PLEASE SEE ICMR? how should i proceed>?', '2018-01-02', ' should be denied for incorrect place of services, per the comments in auth# ', '2018-01-15', 8, 'Answered');
INSERT INTO `question` (`q_id`, `examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `cat_id`, `question_txt`, `q_date`, `response`, `resp_date`, `sme_id`, `status`) VALUES
(388, 'John', 'John@we.com', 46589928, '2017-12-19', 5, 'Can the auth be used for my claim , discharge date covers my  DOS but auth comments do not. ', '2018-01-02', 'As the discharge dates covers your DOS, please use this auth and deny your  as not medically indicate.\n', '2018-01-09', 9, 'Answered'),
(408, 'john', 'jc@jc.jc', 12312312, '2018-09-01', 0, 'fdafdas', '2018-09-01', NULL, NULL, NULL, 'Pending');

-- --------------------------------------------------------

--
-- Table structure for table `question_archive`
--

CREATE TABLE `question_archive` (
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
  `status` varchar(30) NOT NULL DEFAULT 'pending',
  `q_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Dumping data for table `question_archive`
--

INSERT INTO `question_archive` (`examiner_name`, `email`, `claim_no`, `clm_recvd_date`, `cat_id`, `question_txt`, `q_date`, `response`, `resp_date`, `sme_id`, `status`, `q_id`) VALUES
('Ben Bridges', 'johnfcollesq@gmail.com', 1234567, '2018-07-18', 4, '           My question needs to be a lot longer  My question needs to be a lot longer\r\n My question needs to be a lot longer  My question needs to be a lot longer\r\n My question needs to be a lot longer', '2018-07-16', '           response', '2018-07-30', 2, 'Assigned', 8),
('dfd', 'clairepdonn@yahoo.ie', 4646, '2018-06-30', 4, '      fasfasddf', '2018-07-16', '      lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words  lots of words', '2018-07-30', 2, 'Answered', 9),
('JCCc', 'mccannfiona@eircom.net', 8789871, '2018-05-24', 4, '      answer this!', '2018-07-20', '        ', '2018-07-30', 2, 'Assigned', 12),
('Hugh', 'johnfcollesq@gmail.com', 456798, '2018-07-16', 4, '      this is a question', '2018-07-28', '      ', '2018-07-30', 2, 'Answered', 14),
('billy', 'jim@johnson.ie', 78946, '2018-06-05', 4, '   sql', '2018-07-27', '      ', '0000-00-00', 3, 'Pending', 15),
('claire', 'clairepdonn@yahoo.ie', 45678989, '2018-06-05', 4, '  afjlsfjsdafsa', '2018-07-28', '  anser', '2018-07-29', 2, 'Answered', 16);

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
  ADD KEY `q_id` (`q_id`,`cat_id`,`sme_id`);

--
-- Indexes for table `question_archive`
--
ALTER TABLE `question_archive`
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
  MODIFY `q_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=409;
--
-- AUTO_INCREMENT for table `question_archive`
--
ALTER TABLE `question_archive`
  MODIFY `q_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
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
