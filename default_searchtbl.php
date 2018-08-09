﻿<!DOCTYPE html>
<html>
<head>
    <title>Home Page</title>
    <script src="Scripts/jquery-3.1.0.min.js"></script>
    <meta charset="utf-8" />
</head>
<body>
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <a class="navbar-brand" href="Default.html">Optum Question Log</a>
            </div>
            <ul class="nav navbar-nav">
                <li class="active"><a href="Default.php">Home</a></li>
                <li><a href="addquestion.php">Submit Question</a></li>
                <li><a href="adminlogin.php">SME Log In</a></li>
                <li><a href="about.php">About</a></li>
            </ul>
        </div>
    </nav>    

    <div id="main" class="container theme-showcase" role="main">
        <div class="jumbotron">
            <h1>Welcome</h1>
            <p>This is some info</p>
            <p><a class="btn btn-primary btn-lg" href="addquestion.php" role="button">Submit a Question</a></p>
        </div>
        <div class="panel panel-primary">


            <!-- Default panel contents -->
            <div class="panel-heading">Panel heading</div>
            <div class="panel-body">
                <?php
                $server="localhost";
                $dbuser="root";
                $password="";
                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");

                $sql="CALL spDisplayApprovedQs";
                $result=mysqli_query($link,$sql);
                ?>
                <table id="questiontbl" class="table table-striped table-bordered" style="width:100%">
                    <thead>
                        <tr>
                            <td><strong>Examiner</strong></td>
                            <td><strong>Claim Number</strong></td>
                            <td><strong>Received Date</strong></td>
                            <td><strong>Question</strong></td>
                            <td><strong>Question Date</strong></td>
                            <td><strong>Response</strong></td>
                            <td><strong>Response Date</strong></td>
                            <td><strong>SME</strong></td>
                            <td><strong>Status</strong></td>
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
                    $q_date=$row["q_date"];
                    $response=$row["response"];
                    $resp_date=$row["resp_date"];
                    $sme_name=$row["sme_name"];
                    $status=$row["status"];
                    echo "
                    <tr>
                        <td>$examiner_name</td>
                        <td>$claim_no</td>
                        <td>$clm_recvd_date</td>
                        <td>$question_txt</td>
                        <td>$q_date</td>
                        <td>$response</td>
                        <td>$resp_date</td>
                        <td>$sme_name</td>
                        <td>$status</td>
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
    </div>
</body>
</html>
<script src="Scripts/bootstrap.js"></script>
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />
<script src="Styles/DatePicker/js/bootstrap-datepicker.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" />
<script src="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.10.12/js/dataTables.bootstrap.min.js"></script>
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.12/css/dataTables.bootstrap.min.css" />

<script>
    $(document).ready(function () {
        $('#questiontbl').DataTable({
            "order": [[4, "desc"]]
        });
    });
</script>

<!--https://getbootstrap.com/docs/3.3/components/-->
