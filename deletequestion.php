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

    <!--<div id="main" class="container theme-showcase" role="main">
        <div class="panel panel-primary">-->
            <!-- Default panel contents -->
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

                $sql_delete="CALL spDeleteQuestion($q_id)";

                $retval=mysqli_query($link, $sql_delete);
                if(! $retval)
                {
                    die('Could not delete data:'.mysql_error());
                }
                else
                {
                    header("Location: http://localhost/Project3/QuestionLog/managequestions.php");
                    exit;
                }
                mysqli_close($link);
                ?>
            </div>
        <!--</div>
    </div>-->

</body>
</html>

<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />