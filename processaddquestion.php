﻿<!DOCTYPE html>
<html>
<head>
    <title></title>
    <script src="Scripts/jquery-3.1.0.min.js"></script>
    <meta charset="utf-8" />
</head>
<body>
    <!--Menu-->
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <a class="navbar-left" href="default.php"><img src="images/question_gold.png" width="20" height="20"> WE Question Log </a>
            </div>
            <ul class="nav navbar-nav">
                <li><a href="default.php">Home</a></li>
                <li class="active"><a href="addquestion.php">Submit Question</a></li>
                <li class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown">
                        SME Area
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a href="adminlogin.php">Log In</a></li>
                        <li><a href="managequestions.php">Manage Questions</a></li>
                        <li><a href="displayreports.php">Display Reports</a></li>
                    </ul>
                </li>
                <li><a href="contactus.php">Contact Us</a></li>
            </ul>
        </div>
    </nav> 

    <div id="main" class="container theme-showcase" role="main">
        <div class="panel panel-primary">
            <div class="panel-body">
                <?php

                $server="localhost";
                $dbuser="root";
                $password="";
                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");              

                $examiner_name=$_POST["examiner_name"];
                $email=$_POST["email"];
                $claim_no=$_POST["claim_no"];
                $clm_recvd_date=$_POST["clm_recvd_date"];  
                $question=$_POST["question"];

                $sql_insert="CALL spAddQuestion('$examiner_name', '$email', '$claim_no',  '$clm_recvd_date', '$question', NOW())";

                if(mysqli_query($link, $sql_insert)) 
                {
                    echo "<h3>Question succesfully submitted for review.</h3>";
                    echo "<a href='addquestion.php' class='btn btn-info btn-lg'> Return to add a question page</a>";}
                    else {
                    echo "Error, please contact system adminstrator";
                }
                mysqli_close($link);
                ?>
            </div>
        </div>
    </div>

</body>
</html>

<!-- Styles -->
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />