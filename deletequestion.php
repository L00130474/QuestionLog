﻿<!DOCTYPE html>
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
            <!-- Default panel contents -->
            <div class="panel-heading">Panel heading</div>
            <div class="panel-body">
                <?php

                $server="localhost";
                $dbuser="root";
                $password="";
                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");
                $q_id=$_GET["q_id"];  
                 
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
        </div>
    </div>

</body>
</html>
<script src="Scripts/bootstrap.js"></script>
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />


<!--https://getbootstrap.com/docs/3.3/components/-->