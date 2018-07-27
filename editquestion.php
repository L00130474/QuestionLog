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
                <a class="navbar-brand" href="addquestion.php">Optum Question Log</a>
            </div>
            <ul class="nav navbar-nav">
                <li class="active"><a href="Default.html">Home</a></li>
                <li><a href="admin.html">SME Log In</a></li>
                <li><a href="about.html">About</a></li>
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

                $sql="SELECT * FROM QUESTION WHERE q_id=$q_id";
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
                $status=$row["status"];

                $sqlSme = "SELECT * FROM sme";
                $result2=mysqli_query($link,$sqlSme);
                $row2=mysqli_fetch_array($result2);

                $sqlCat = "SELECT * FROM category";
                $result3=mysqli_query($link,$sqlCat);
                $row3=mysqli_fetch_array($result3);

                mysqli_close($link);
                ?>

                <div id="form">
                    <form method="post" action="processeditquestion.php">

                        <input type="hidden" name="q_id" value="<?php echo $q_id; ?>" />

                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-2">
                                    Examiner Name:
                                </div>
                                <div class="col-md-3">
                                    <input name="examiner_name" type="text" value="<?php echo $examiner_name ;?>" />
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    Email Address:
                                </div>
                                <div class="col-md-3">
                                    <input name="email" type="email" value="<?php echo $email ;?>" />
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <div class="row">
                                <div class="col-md-2">
                                    Claim Number:
                                </div>
                                <div class="col-md-3">
                                    <input name="claim_no" type="text" value="<?php echo $claim_no ;?>" />
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    Received Date
                                </div>
                                <div class="col-md-3">
                                    <input name="clm_recvd_date" type="text" value="<?php echo $clm_recvd_date ;?>" />
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <div class="row">
                                <div class="col-md-2">
                                    Question Date:
                                </div>
                                <div class="col-md-3">
                                    <input name="q_date" type="text" value="<?php echo $q_date ;?>" />
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    Category:
                                </div>
                                <div class="col-md-3">

                                    <select name="cat_id" class="chosen-select" style="width: 160px;">
                                        <?php
                                        WHILE($row3=mysqli_fetch_array($result3))
                                        {
                                        ?>                                        
                                        <option><?php echo $row3["cat_id"]; ?></option>
                                        <?php
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
                                    Question
                                </div>
                                <div class="col-md-3">
                                    <textarea name="question" rows="8" cols="35"> <?php echo $question ;?></textarea>
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    Response:
                                </div>
                                <div class="col-md-3">
                                    <textarea name="response" rows="8" cols="35"> <?php echo $response ;?></textarea>
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <div class="row">
                                <div class="col-md-2">
                                    Response Date:
                                </div>
                                <div class="col-md-3">
                                    <input name="resp_date" type="text" value="<?php echo $resp_date ;?>" />
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <div class="col-md-2">
                                    SME:
                                </div>
                                <div class="col-md-3">

                                    <select name="sme_id" class="chosen-select" style="width: 160px;">
                                        <?php
                                        WHILE($row2=mysqli_fetch_array($result2))
                                        {
                                        ?>
                                        <option><?php echo $row2["sme_id"];?></option>
                                        <?php
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
                                    Status:
                                </div>
                                <div class="col-md-3">
                                    <select name="status" class="chosen-select" style="width: 100px;">
                                        <option>Pending</option>
                                        <option>Assigned</option>
                                        <option>Closed</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-3">
                                <div id="submitQ" dx-button="btnSubmit">
                                    <input type="submit" name="submit" value="Update" />
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
<script src="Scripts/bootstrap.js"></script>
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />

<!--Date Time Picker-->
<script src="Styles/DatePicker/js/bootstrap-datepicker.js"></script>
<script>
    $('.input-daterange').datepicker({
        format: 'yyyy-mm-dd',
        todayBtn: "linked",
        clearBtn: true
    });
</script>
<script type="text/javascript">
    var config = {
        '.chosen-select': {},
        '.chosen-select-deselect': { allow_single_deselect: true },
        '.chosen-select-no-single': { disable_search_threshold: 15 },
        '.chosen-select-no-results': { no_results_text: 'No Matches' },
        '.chosen-select-width': { width: "95%" }
    }
    for (var selector in config) {
        $(selector).chosen(config[selector]);
    }
</script>


<!--https://getbootstrap.com/docs/3.3/components/-->
