<!DOCTYPE html>
<html>
<head>
    <title>Home Page</title>
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
                <li class="active"><a href="default.php">Home</a></li>
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

    <!--Main Container-->
    <div id="main" class="container theme-showcase" role="main">

        <!--Jumbotron-->
        <div class="jumbotron">
            <h1>Online Question Log</h1>
            <p>Browse questions by entering key word(s) in the search box below or submit a new question.<i class="glyphicon glyphicon-question-sign"></i></p>
            <p><a class="btn btn-primary btn-lg" href="addquestion.php" role="button">Submit Question</a></p>
        </div>

        <div class="panel panel-primary">

            <!-- Default panel contents -->
            <div class="panel-heading">Please browse or search as your question may already have been answered!</div>
            <div class="panel-body">

                <!--Connect to database and call stored procedure-->
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
                        while($row=mysqli_fetch_array($result))
                        {
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
                        {
                        echo("No entries to display");
                        }
                    mysqli_close($link);
                    ?>
                </table>
            </div>
        </div>
    </div>
    <?php include("includes/footer.html");?>
</body>
</html>

<!-- Styles -->
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/bootstrap/datatables.bootstrap.css" rel="stylesheet" />

<!-- Scripts -->
<script src="Scripts/bootstrap.js"></script>
<script src="Scripts/jquery.dataTables.js"></script>
<script src="Scripts/dataTables.bootstrap.js"></script>

<script>
    $(document).ready(function () {
        $('#questiontbl').DataTable({
            "order": [[4, "desc"]]
        });
    });
</script>

<!--https://getbootstrap.com/docs/3.3/components/-->
