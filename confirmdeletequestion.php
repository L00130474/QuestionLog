<!DOCTYPE html>
<html>
<head>
    <title>Confirm Delete</title>
    <script src="Scripts/jquery-3.1.0.min.js"></script>
    <meta charset="utf-8" />
</head>
<body>
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <a class="navbar-brand" href="default.php">Optum Question Log</a>
            </div>
            <ul class="nav navbar-nav">
                <li><a href="default.php">Home</a></li>
                <li><a href="addquestion.php">Submit Question</a></li>
                <li class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="adminlogin.php">
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
                <li><a href="about.html">About</a></li>
            </ul>
        </div>
    </nav>

    <div id="main" class="container theme-showcase" role="main">
        <div class="panel panel-primary">
            <!-- Panel contents -->
            <div class="panel-heading">Confirm Delete Property</div>
            <div class="panel-body">
                <?php

                //Ensure user is logged in
                session_start();
                if(!isset($_SESSION['username']))
                {
                header("Location:adminlogin.php");
                }

                $server="localhost";
                $dbuser="root";
                $password="";
                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");
                $q_id=$_GET['q_id'];

                $sql="SELECT * from question WHERE q_id = $q_id";
                $result=mysqli_query($link,$sql);
                ?>

                <table id="confirmDeletetbl" class="table table-striped table-bordered" style="width:100%">

                    <tr>
                        <td><strong>Examiner</strong></td>
                        <td><strong>Claim Number</strong></td>
                        <td><strong>Received Date</strong></td>
                        <td><strong>Question</strong></td>
                    </tr>

                    <?php
                    $row=mysqli_fetch_array($result);
                    $q_id=$row["q_id"];
                    $examiner_name=$row["examiner_name"];
                    $claim_no=$row["claim_no"];
                    $clm_recvd_date=$row["clm_recvd_date"];
                    $question_txt=$row["question_txt"];
                    echo"
                    <tr>
                        <!--Populate table columns-->
                        <td>$examiner_name</td>
                        <td>$claim_no</td>
                        <td>$clm_recvd_date</td>
                        <td>$question_txt</td>
                    </tr>";
                    echo"
                </table>                
            </div>
        </div>
        <!-- Confirm Deletion -->
        <div>
            <h3>Do you want to permanently delete this question?</h3>
            <p>
                <br />
                <a href='deletequestion.php?q_id=$q_id' class='btn btn-danger btn-lg'>Delete</a>
                <a href='managequestions.php' class='btn btn-info btn-lg'>Cancel</a>
                ";
                mysqli_close($link);
                ?>
        </div>
    </div>
</body>
</html>

<!-- Styles -->
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />