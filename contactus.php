<!DOCTYPE html>
<html>
<head>
    <title>Contact Us</title>
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
                <li>
                    <a class="dropdown-toggle" data-toggle="dropdown">
                        SME Area
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a href="adminlogin.php">Log In</a></li>
                        <li><a href="managequestions.php">Manage Questions</a></li>
                        <li><a href="displayreports.php">Display Reports</a></li>
                    </ul>
                </li>
                <li class="active"><a href="contactus.php">Contact Us</a></li>                
            </ul>
        </div>
    </nav> 

    <div id="main" class="container theme-showcase" role="main">

        <div class="panel panel-primary">
            <div class="panel-heading">Contact Us with any Feedback or Issues</div>
            <div class="panel-body">

                <div id="form">
                    <form method="post" action="confirmemail.php" id="contactForm">
                        <div class="panel-body">

                            <!-- First Name -->
                            <div class="row">
                                <div class="col-md-2">
                                    First Name*
                                </div>
                                <div class="col-md-3 input-group">
                                    <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
                                    <input name="first_name" type="text" class="form-control" required="required" placeholder="First Name" />
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <!-- Last Name -->
                            <div class="row">
                                <div class="col-md-2">
                                    Last Name*
                                </div>
                                <div class="col-md-3 input-group">
                                    <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
                                    <input name="last_name" type="text" class="form-control" required="required" placeholder="Last Name" />
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <!-- Email -->
                            <div class="row">

                                <div class="col-md-2">
                                    Email*
                                </div>
                                <div class="col-md-3 input-group">
                                    <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
                                    <input name="email" id="email" type="email" class="form-control" required="required" placeholder="Email Address" />
                                </div>

                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <!-- Email Text -->
                            <div class="row">
                                <div class="col-md-2">
                                    Comment*
                                </div>
                                <div class="col-md-3 input-group">
                                    <span class="input-group-addon"><i class="glyphicon glyphicon-pencil"></i></span>
                                    <textarea class="form-control" name="comment" rows="4" placeholder="Comments" required="required"></textarea>
                                </div>
                            </div>
                        </div>
                        <div id="submitQ" dx-button="btnSubmit">
                            <input type="submit" name="submit" value="Send Message" class="btn btn-primary btn-lg" />
                        </div>
                    </form>
                </div>
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
<link href="Styles/ZebraDialog/zebra_dialog.css" rel="stylesheet" />

<!-- Scripts -->
<script src="Scripts/bootstrap.js"></script>
<script src="Scripts/zebra_dialog.src.js"></script>

<script>
    //Zebra Dialog runs when form submitted below line 
    $(document).ready(function () {
        $("#contactForm").submit(function (e) {            
            //prevent the form from posting as email server not set up
            e.preventDefault();
            //Pickup email address from form
            var emailAddress = $('#email').val();
            //Create Zebra pop up with various options
            new $.Zebra_Dialog(
                'Email received from ' + emailAddress + ', we will respond within 2 working days.',
                {
                    buttons: false,
                    modal: true,
                    auto_close: 5000,
                    onClose: function (caption) {
                        //reload page to clear form
                        window.location.reload(false);
                    }
                }
            );
        });
    });
</script>
