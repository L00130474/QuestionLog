﻿<!DOCTYPE html>
<html>
<head>
    <title>Summary Reports</title>
    <script src="Scripts/jquery-3.1.0.min.js"></script>


    <meta charset="utf-8" />
</head>
<body>
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <a class="navbar-left" href="default.php"><img src="images/question_gold.png" width="20" height="20"> WE Question Log </a>
            </div>
            <ul class="nav navbar-nav">
                <li><a href="default.php">Home</a></li>
                <li><a href="addquestion.php">Submit Question</a></li>
                <li class="active">
                    <a class="dropdown-toggle" data-toggle="dropdown">
                        SME Area
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a href="adminlogin.php">Log In</a></li>
                        <li><a href="managequestions.php">Manage Questions</a></li>
                        <li class="active"><a href="displayreports.php">Display Reports</a></li>
                    </ul>
                </li>
                <li><a href="contactus.php">Contact Us</a></li>                
            </ul>
        </div>
    </nav> 

    <div id="main" class="container theme-showcase" role="main">
        <div class="panel panel-primary">
            <!-- Default panel contents -->
            <div class="panel-heading">Open Summary. Note: Date Filters not applied</div>
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

                $sql="CALL spOpenReport";

                $result=mysqli_query($link,$sql);
                ?>

                <table id="openReportTbl" class="table table-striped table-bordered" style="width:100%">

                    <tr>
                        <td><strong>Status</strong></td>
                        <td><strong>Question Volume</strong></td>
                        <td><strong>Max. Age Of Claim (Days)</strong></td>
                        <td><strong>Avg. Age Of Claim (Days)</strong></td>
                        <td><strong>Avg. Age of Question (Days)</strong></td>
                    </tr>
                    <?php
                    if(mysqli_num_rows($result)>0)
                    {
                    while($row=mysqli_fetch_array($result)){
                    $status=$row["status"];
                    $volume=$row["volume"];
                    if ($volume == '')
                    $volume = '0';
                    $max_lag=$row["max_lag"];
                    if ($max_lag == '')
                    $max_lag = 'N/A';
                    $avg_lag=$row["avg_lag"];
                    if ($avg_lag == '')
                    $avg_lag = 'N/A';
                    $avg_tat=$row["avg_tat"];
                    if ($avg_tat == '')
                    $avg_tat = 'N/A';
                    echo"
                    <tr>
                        <td>$status</td>
                        <td>$volume</td>
                        <td>$max_lag</td>
                        <td>$avg_lag</td>
                        <td>$avg_tat</td>
                    </tr>";
                    }
                    echo"
                </table>";
                }
                else
                {echo("<tr><td>No open claims found</td><td></td><td></td><td></td><td></td></tr></table>");}
                mysqli_close($link);
                ?>
            </div>
        </div>

        <div class="panel panel-danger">
            <div class="panel-heading">
                <h3 class="panel-title">Please select question dates</h3>
            </div>
            <div class="panel-body">
                <div class="row">

                    <!-- From Date -->
                    <div class="col-md-3">
                        <div class="input-daterange input-group" id="datepicker" data-provide="datepicker">
                            <span class="input-group-addon">From</span>
                            <input id="fromDate" type="text" class="input-sm form-control" name="fromDate" required="required" />
                        </div>
                    </div>

                    <!-- Padding -->
                    <div class="col-md-1">
                    </div>

                    <!-- To Date -->
                    <div class="col-md-3">
                        <div class="input-daterange input-group" id="datepicker" data-provide="datepicker">
                            <span class="input-group-addon">To</span>
                            <input id="toDate" type="text" class="input-sm form-control" name="toDate" required="required" />
                        </div>
                    </div>
                    <!-- Update Dates -->
                    <div class="col-md-3">
                        <div id="submitQ" dx-button="btnSubmit">
                            <input type="submit" name="submit" id="btnSubmitDates" class="btn btn-danger btn-sm" value="Generate Reports" />
                        </div>
                    </div>
                </div>
            </div>
        </div>        

        <div class="panel panel-primary">
            <!-- Default panel contents -->
            <div class="panel-heading">Closed Summary</div>
            <div class="panel-body">

                <!--Closed Questions Report-->
                <?php
                $server="localhost";
                $dbuser="root";
                $password="";

                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");

                if (isset($_GET["fromDate"]))
                {
                $fromDate=$_GET["fromDate"];
                $toDate=$_GET["toDate"];

                $sql="CALL spClosedReport('$fromDate', '$toDate')";

                $result=mysqli_query($link,$sql);
                ?>

                <table id="closedReportTbl" class="table table-striped table-bordered" style="width:100%">

                    <!--Table Headings-->
                    <tr>
                        <td><strong>Status</strong></td>
                        <td><strong>Question Volume</strong></td>
                        <td><strong>Max. Tat (Days)</strong></td>
                        <td><strong>Avg. Lag to Received Date (Days)</strong></td>
                        <td><strong>Avg. Tat (Days)</strong></td>
                    </tr>
                    <!--Display Rows and Handle Nulls-->
                    <?php
                    if(mysqli_num_rows($result)>0)
                    {
                    while($row=mysqli_fetch_array($result)){
                    $status=$row["status"];
                    $volume=$row["volume"];
                    if ($volume == '')
                    $volume = '0';
                    $max_tat=$row["max_tat"];
                    if ($max_tat == '')
                    $max_tat = 'N/A';
                    $avg_lag=$row["avg_lag"];
                    if ($avg_lag == '')
                    $avg_lag = 'N/A';
                    $avg_tat=$row["avg_tat"];
                    if ($avg_tat == '')
                    $avg_tat = 'N/A';
                    echo"
                    <!--Populate Columns-->
                    <tr>
                        <td>$status</td>
                        <td>$volume</td>
                        <td>$max_tat</td>
                        <td>$avg_lag</td>
                        <td>$avg_tat</td>
                    </tr>";
                    }
                    echo"
                </table>";
                }
                else
                {echo("<tr><td>No results for dates selected</td><td></td><td></td><td></td><td></td></tr></table>");}
                mysqli_close($link);
                }
                    else
                    {
                        echo "<h3>Please enter date span above</h3>";
                    }
                ?>
            </div>
        </div>
        <div class="panel panel-primary">
            <!-- Default panel contents -->
            <div class="panel-heading">Regional Summary</div>
            <div class="panel-body">
                <?php
                $server="localhost";
                $dbuser="root";
                $password="";

                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");

                if (isset($_GET["fromDate"]))
                {
                $fromDate=$_GET["fromDate"];
                $toDate=$_GET["toDate"];

                $sql="CALL spRegionalReport('$fromDate', '$toDate')";

                $result=mysqli_query($link,$sql);
                ?>

                <table id="regionalReportTbl" class="table table-striped table-bordered" style="width:100%">
                    <tr>
                        <td><strong>Region</strong></td>
                        <td><strong>Question Volume</strong></td>
                        <td><strong>Pending</strong></td>
                        <td><strong>Assigned</strong></td>
                        <td><strong>Answered</strong></td>
                    </tr>
                    <?php
                    if(mysqli_num_rows($result)>0)
                    {
                    while($row=mysqli_fetch_array($result)){
                    $regn_name=$row["regn_name"];
                    if ($regn_name == '')
                    $regn_name = 'Unassigned';
                    $volume=$row["volume"];
                    if ($volume == '')
                    $volume = '0';
                    $pending=$row["pending"];
                    if ($pending == '')
                    $pending = '0';
                    $assigned=$row["assigned"];
                    if ($assigned == '')
                    $assigned = '0';
                    $answered=$row["answered"];
                    if ($answered == '')
                    $answered = '0';
                    echo"
                    <tr>
                        <td>$regn_name</td>
                        <td>$volume</td>
                        <td>$pending</td>
                        <td>$assigned</td>
                        <td>$answered</td>
                    </tr>";
                    }
                    echo"
                </table>";
                }
                else
                {echo("<tr><td>No results for dates selected</td><td></td><td></td><td></td><td></td></tr></table>");}
                mysqli_close($link);
                }
                else
                {
                echo "<h3>Please enter date span above</h3>";
                }
                ?>
            </div>
        </div>

        <div class="panel panel-primary">
            <!-- Default panel contents -->
            <div class="panel-heading">Supervisor Summary</div>
            <div class="panel-body">
                <?php
                $server="localhost";
                $dbuser="root";
                $password="";

                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");

                if (isset($_GET["fromDate"]))
                {
                $fromDate=$_GET["fromDate"];
                $toDate=$_GET["toDate"];

                $sql="CALL spSupervisorReport('$fromDate', '$toDate')";

                $result=mysqli_query($link,$sql);
                ?>

                <table id="supervisorReportTbl" class="table table-striped table-bordered" style="width:100%">
                    <tr>
                        <td><strong>Supervisor</strong></td>
                        <td><strong>Question Volume</strong></td>
                        <td><strong>Min. Tat (Days)</strong></td>
                        <td><strong>Max. Tat (Days)</strong></td>
                        <td><strong>Avg. Tat (Days)</strong></td>
                    </tr>
                    <?php
                    if(mysqli_num_rows($result)>0)
                    {
                    while($row=mysqli_fetch_array($result)){
                    $sup_name=$row["sup_name"];
                    if ($sup_name == '')
                    $sup_name = 'Unassigned';
                    $volume=$row["volume"];
                    if ($volume == '')
                    $volume = '0';
                    $min_tat=$row["min_tat"];
                    if ($min_tat == '')
                    $min_tat = 'N/A';
                    $max_tat=$row["max_tat"];
                    if ($max_tat == '')
                    $max_tat = 'N/A';
                    $avg_tat=$row["avg_tat"];
                    if ($avg_tat == '')
                    $avg_tat = 'N/A';

                    echo"
                    <tr>
                        <td>$sup_name</td>
                        <td>$volume</td>
                        <td>$min_tat</td>
                        <td>$max_tat</td>
                        <td>$avg_tat</td>
                    </tr>";
                    }
                    echo"
                </table>";
                }
                else
                {echo("<tr><td>No results for dates selected</td><td></td><td></td><td></td><td></td></tr></table>");}
                mysqli_close($link);
                }
                else
                {
                echo "<h3>Please enter date span above</h3>";
                }
                ?>
            </div>
        </div>        
    </div>
    <!--Include Footer-->
    <?php include("includes/footerlong.html");?>  
</body>
</html>
<!-- Styles -->
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />

<!-- Scripts -->
<script src="Scripts/bootstrap.js"></script>
<script src="Styles/DatePicker/js/bootstrap-datepicker.js"></script>

<script>
    $('.input-daterange').datepicker({
        format: 'yyyy-mm-dd',
        todayBtn: "linked",
        clearBtn: true
    });

    $(document).ready(function () {
        $("#btnSubmitDates").click(function () {
            var fromDate = $('#fromDate').val();
            var toDate = $('#toDate').val();
            var url = 'http://localhost/Project3/QuestionLog/displayreports.php?fromDate=' + fromDate + '&toDate=' + toDate;
            window.location.href = url;
        });
    });
</script>