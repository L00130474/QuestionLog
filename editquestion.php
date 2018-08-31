<!DOCTYPE html>
<html>
<head>
    <title>Respond</title>
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
                        <li class="active"><a href="managequestions.php">Manage Questions</a></li>
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
                $q_id=$_GET["q_id"];
                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");

                $sql="CALL spQuestionDetails($q_id)";
                $result=mysqli_query($link,$sql);
                $row=mysqli_fetch_array($result);

                $q_id=$row["q_id"];
                $examiner_name=$row["examiner_name"];
                $email=$row["email"];
                $claim_no=$row["claim_no"];
                $clm_recvd_date=$row["clm_recvd_date"];
                $cat_id=$row["cat_id"];
                $question=$row["question_txt"];
                $q_date=$row["q_date"];
                $response=$row["response"];
                $resp_date=$row["resp_date"];
                $sme_id=$row["sme_id"];
                $statusSelected=$row["status"];
                $sme_nameSelected=$row["sme_name"];
                $cat_nameSelected=$row["cat_name"];

                mysqli_close($link);

                $server="localhost";
                $dbuser="root";
                $password="";
                $q_id=$_GET["q_id"];
                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");

                $sqlSme = "SELECT concat(sme_fname, ' ', sme_lname) as sme_name FROM sme";
                $result2=mysqli_query($link,$sqlSme);
                
                $sqlCat = "SELECT cat_name FROM category";
                $result3=mysqli_query($link,$sqlCat);

                mysqli_close($link);
                ?>

                <div id="form">
                    <form method="post" action="processeditquestion.php">

                        <input type="hidden" name="q_id" value="<?php echo $q_id; ?>" />

                        <div class="panel-body">

                            <div class="row">
                                <div class="col-md-2">
                                    <strong>Examiner Name</strong>
                                </div>
                                <div class="col-md-3">
                                    <input name="examiner_name" type="text" class="form-control" value="<?php echo $examiner_name ;?>" disabled />
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    <strong>Email Address</strong>
                                </div>
                                <div class="col-md-3">
                                    <input name="email" type="email" class="form-control" value="<?php echo $email ;?>" disabled/>
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <div class="row">
                                <div class="col-md-2">
                                    <strong>Claim Number</strong>
                                </div>
                                <div class="col-md-3">
                                    <input name="claim_no" type="text" class="form-control" value="<?php echo $claim_no ;?>" disabled/>
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    <strong>Received Date</strong>
                                </div>
                                <div class="col-md-3">
                                    <input name="clm_recvd_date" type="text" class="form-control" value="<?php echo $clm_recvd_date ;?>" disabled/>
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <div class="row">
                                <div class="col-md-2">
                                    <strong>Question Date</strong>
                                </div>
                                <div class="col-md-3">
                                    <input name="q_date" type="text" class="form-control" value="<?php echo $q_date ;?>" disabled />
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    <strong>Category</strong>
                                </div>
                                <div class="col-md-3">

                                    <select name="cat_name" class="form-control">
                                        <?php
                                            WHILE($row3=mysqli_fetch_array($result3))
                                            {
                                                $catName=$row3["cat_name"];
                                                If($catName == $cat_nameSelected)
                                                    echo "<option selected>$catName</option>";
                                                else
                                                    echo "<option>$catName</option>";
                                            }
                                        ?>
                                    </select>
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <div class="row">
                                <div class="col-md-2">
                                    <strong>Question</strong>
                                </div>
                                <div class="col-md-3">
                                    <textarea name="question" rows="8" class="form-control" disabled> <?php echo $question ;?></textarea>
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    <strong>Response</strong>
                                </div>
                                <div class="col-md-3">
                                    <textarea name="response" rows="8" class="form-control"> <?php echo $response ;?></textarea>
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <div class="row">
                                <div class="col-md-2">
                                    <strong>Response Date</strong>
                                </div>
                                <div class="col-md-3">
                                    <input name="resp_date" type="text" class="form-control" value="<?php echo $resp_date ;?>" />
                                    <div class="input-daterange input-group" id="datepicker" data-provide="datepicker">
                                        <span class="input-group-addon"><strong>Date</strong></span>
                                        <input id="recdDate" type="text" required="required" class="input-sm form-control" name="clm_recvd_date" />
                                    </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    <strong>SME</strong>
                                </div>
                                <div class="col-md-3">
                                    <select name="sme_name" class="form-control">
                                        <?php
                                            WHILE($row2=mysqli_fetch_array($result2))
                                            {
                                                $smeName=$row2["sme_name"];
                                                If($smeName == $sme_nameSelected)
                                                echo "
                                                <option selected>$smeName</option>";
                                                else
                                                echo "<option>$smeName</option>";
                                            }
                                        ?>
                                    </select>
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <!-- Populate Status Dropdown Menu -->
                            <div class="row">
                                <div class="col-md-2">
                                   <strong>Status</strong>
                                </div>
                                <div class="col-md-3">
                                    <select name="status" class="form-control">
                                        <option>Pending</option>
                                        <option>Assigned</option>
                                        <option>Answered</option>
                                    </select>
                                </div>
                            </div>
                        </div>  
                        <div class="btn-toolbar">                            
                            <button type="submit" name="submit" value="Update" class="btn btn-primary btn-lg">Update</button>
                            &nbsp;
                            <button class="btn btn-primary btn-lg" onclick="goBack()">Back</button>
                        </div>                      
                    </form>
                </div>                
            </div>  
        </div>
    </div>
</body>
</html>

<!-- Styles -->
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />
<link href="Styles/bootstrap/datatables.bootstrap.css" rel="stylesheet" />

<!-- Scripts -->
<script src="Scripts/bootstrap.js"></script>
<script src="Styles/DatePicker/js/bootstrap-datepicker.js"></script>
<script src="Scripts/jquery.dataTables.js"></script>
<script src="Scripts/dataTables.bootstrap.js"></script>

<script>
    $('.input-daterange').datepicker({
        format: 'yyyy-mm-dd',
        todayBtn: "linked",
        clearBtn: true
    });

    function goBack() {
        window.history.back();
    }
</script>