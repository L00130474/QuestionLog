<!DOCTYPE html>
<html>
<head>
    <title>Manage Questions</title>
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
            <div class="panel-heading">Respond to or Delete a question</div>
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

                //Call Stored Procedure
                $sql="CALL spDisplayManagedQs";
                $result=mysqli_query($link,$sql);
                ?>
                <table id="manageqstbl" class="table table-striped table-bordered" style="width:100%">
                    <thead>
                        <tr>
                            <td><strong>Examiner</strong></td>
                            <td><strong>Claim Number</strong></td>
                            <td><strong>Received Date</strong></td>
                            <td><strong>Question</strong></td>
                            <td><strong>SME</strong></td>
                            <td><strong>Category</strong></td>
                            <td><strong>Status</strong></td>
                            <td><strong>Respond</strong></td>
                            <td><strong>Delete</strong></td>
                        </tr>
                    </thead>
                    <?php
                    if(mysqli_num_rows($result)>0)
                    {
                    while($row=mysqli_fetch_array($result)){
                    $q_id=$row["q_id"];
                    $examiner_name=$row["examiner_name"];
                    $claim_no=$row["claim_no"];
                    $clm_recvd_date=$row["clm_recvd_date"];
                    $question_txt=$row["question_txt"];
                    $sme_name=$row["sme_name"];
                    $cat_name=$row["cat_name"];
                    $status=$row["status"];
                    echo "
                    <tr>
                        <td>$examiner_name</td>
                        <td>$claim_no</td>
                        <td>$clm_recvd_date</td>
                        <td>$question_txt</td>
                        <td>$sme_name</td>
                        <td>$cat_name</td>
                        <td>$status</td> 
                        <td><a href='editquestion.php?q_id=$q_id' class='btn btn-info btn-sm'> Respond</a></td>
                        <td><a href='confirmdeletequestion.php?q_id=$q_id' class='btn btn-danger btn-sm'>Delete</a></td>
                    </tr>
                    " ;
                    }
                    }
                    else
                    {echo("No entries to display");}
                    mysqli_close($link);
                    ?>
                </table>
            </div>            
        </div>
        <div><button class="btn btn-primary btn-lg" onclick="goBack()">Back</button></div>
    </div>
    <?php include("includes/footer.html");?>
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
    $(document).ready(function () {
        $('#manageqstbl').DataTable({
            "order": [[6, "desc"]]
        });
    });
    function goBack() {
        window.history.back();
    }
</script>