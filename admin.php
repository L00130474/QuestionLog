<!DOCTYPE html>
<html>
<head>
    <title>SME Area</title>
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
            <!-- Default panel contents -->
            <div class="panel-heading">Select from the options below</div>
            <div class="panel-body">
                <a class="btn btn-primary btn-lg" href="managequestions.php" role="button">Manage Questions</a>
                <br /><br />
                <a class="btn btn-primary btn-lg" href="displayreports.php" role="button">Display Reports</a>
            </div>
        </div>
    </div>
    <!--Include Footer-->
    <?php include("includes/footer.html");?>
</body>
</html>

<!-- Styles -->
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
