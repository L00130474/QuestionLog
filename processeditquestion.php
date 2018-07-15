<!DOCTYPE html>
<html>
<head>
    <title></title>
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
                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");

                $q_id=$_POST["q_id"];
                $examiner_name=$_POST["examiner_name"];
                $email=$_POST["email"];
                $claim_no=$_POST["claim_no"];
                $clm_recvd_date=$_POST["clm_recvd_date"];
                $question=$_POST["question"];
                $category=$_POST["category"];
                $response=$_POST["response"];
                $resp_date=$_POST["resp_date"];
                $sme=$_POST["sme"];
                $status=$_POST["status"];

                $sql_update="UPDATE question set examiner_name = '$examiner_name', email = '$email', claim_no = '$claim_no', clm_recvd_date = '$clm_recvd_date', question = '$question', category = '$category', response = '$response', resp_date = '$resp_date', sme = '$sme', status = '$status' WHERE q_id=$q_id";

                 $retval = mysqli_query($link, $sql_update);

            if(! $retval)
            {
            die('Could not update data:'.mysql_error());
            }
            else
            {
                header("Location: http://localhost/Project3/QuestionLog/managequestions.php");
            exit;
            }
            echo "Question Updated";
            mysqli_close($link);
            ?>
            </div>
        </div>
    </div>

</body>
</html>
<script src="Scripts/bootstrap.js"></script>
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />


<!--https://getbootstrap.com/docs/3.3/components/-->
