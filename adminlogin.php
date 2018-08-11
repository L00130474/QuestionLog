<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
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
                        <li><a href="displayreports.php?fromDate=2000-01-01&toDate=2099-01-01">Display Reports</a></li>
                    </ul>
                </li>
                <li><a href="contactus.php">Contact Us</a></li>
                <li><a href="about.html">About</a></li>
            </ul>
        </div>
    </nav>

    <div id="main" class="container theme-showcase" role="main">
        <?php
        if(empty($_SESSION))
        session_start();
        if(isset($_SESSION['errors']))
        {
        echo "<div class='form-errors'>
            ";
            foreach($_SESSION['errors'] as $error)
            {
            echo "<p>
                ";
                echo $error;
                echo"
            </p>";
            }
            echo "
        </div>";
        }
        unset($_SESSION['errors']);
        ?>
        <div id="form">
            <div class="panel panel-primary">
                <!-- Default panel contents -->
                <div id="form">
                    <form method="post" action="process_login.php">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">Enter Username and Password</h3>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <!-- Username -->
                                    <div class="col-md-2">
                                        Username:
                                    </div>
                                    <div class="col-md-3">
                                        <input name="username" type="text" class="form-control" required="required" placeholder="Enter Username" />
                                    </div>

                                    <!-- Padding -->
                                    <div class="col-md-1">
                                    </div>
                                                                       
                                    <!-- Password -->
                                    <div class="col-md-2">
                                        Username:
                                    </div>
                                    <div class="col-md-3">
                                        <input name="password" type="password" class="form-control" required="required" placeholder="Enter Password" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Submit -->
                        <div class="row">
                            <div class="col-md-3">
                                <div id="submitQ" dx-button="btnSubmit">
                                    <input type="submit" name="submit" value="Submit" />
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
<script src="Styles/DatePicker/js/bootstrap-datepicker.min.js"></script>
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />
<!--https://getbootstrap.com/docs/3.3/components/-->
