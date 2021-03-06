﻿<!DOCTYPE html>
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
                        <li class="active"><a href="adminlogin.php">Log In</a></li>
                        <li><a href="managequestions.php">Manage Questions</a></li>
                        <li><a href="displayreports.php">Display Reports</a></li>
                    </ul>
                </li>
                <li><a href="contactus.php">Contact Us</a></li>
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
                    <form method="post" action="process_login.php">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">Enter Username and Password</h3>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <!-- Username -->
                                    <div class="col-md-2">
                                        <strong>Username*</strong>
                                    </div>
                                    <div class="col-md-3">
                                        <input name="username" type="text" class="form-control" required="required" placeholder="Enter Username" />
                                    </div>

                                    <!-- Padding -->
                                    <div class="col-md-1">
                                    </div>
                                                                       
                                    <!-- Password -->
                                    <div class="col-md-2">
                                        <strong>Password*</strong>
                                    </div>
                                    <div class="col-md-3">
                                        <input name="password" type="password" class="form-control" required="required" placeholder="Enter Password" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="btn-toolbar">
                            <button type="submit" name="submit" value="Update" class="btn btn-primary btn-lg">Submit</button>
                            &nbsp;
                            <button class="btn btn-primary btn-lg" onclick="goBack()">Back</button>
                        </div>  
                    </form>                    
                    </div>
    <!--Include Footer-->
    <?php include("includes/footer.html");?>      
</body>
</html>

<!-- Styles -->
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />

<!-- Scripts -->
<script src="Scripts/bootstrap.js"></script>

<script>   
    function goBack() {
        window.history.back();
    }
</script>
