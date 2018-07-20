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

                $examiner_name=$_POST["examiner_name"];
                $email=$_POST["email"];
                $claim_no=$_POST["claim_no"];
                $clm_recvd_date=$_POST["clm_recvd_date"];  
                $question=$_POST["question"];

                $sql_insert="CALL spAddQuestion('$examiner_name', '$email', '$claim_no',  '$clm_recvd_date', '$question', NOW())";

                if(mysqli_query($link, $sql_insert)) {
                echo "<h3>Question succesfully submitted for review.</h3>";
                echo "<a href='addquestion.php'> Return to add a question page</a>";}
                else {
                echo "An error occurred, try again!";
                }
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
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">




<!--https://getbootstrap.com/docs/3.3/components/-->
