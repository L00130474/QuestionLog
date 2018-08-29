<!DOCTYPE html>
<html>
<head>
    <title>Submit Question</title>
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
                <li class="active"><a href="addquestion.php">Add Question</a></li>
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

    <div id="container">
        
        <div id="main" class="container theme-showcase" role="main">

            <!--Jumbotron-->
            <div class="jumbotron">
                <h1>Submit Question</h1>
                <p>Please fill in ALL fields below. &nbsp;&nbsp; <i class="glyphicon glyphicon-hand-down"></i></p>
            </div>

            <div>
                <!-- Default panel contents -->
                <div id="form">
                    <form method="post" action="processaddquestion.php">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">Please fill in details below (All details are required)</h3>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <!-- Name -->
                                    <div class="col-md-2">
                                        <strong>Name*</strong>
                                    </div>
                                    <div class="col-md-3">
                                        <input name="examiner_name" type="text" class="form-control" required="required" placeholder="Enter Examiner Name" />
                                    </div>

                                    <!-- Padding -->
                                    <div class="col-md-1">
                                    </div>

                                    <!-- Email Address -->
                                    <div class="col-md-2">
                                        <strong>Email*</strong>
                                    </div>
                                    <div class="col-md-3">
                                        <input name="email" type="email" class="form-control" required="required" placeholder="Format: jbloggs@domain.ie" />
                                    </div>
                                </div>

                                <!-- Padding -->
                                <div class="row">
                                    <br />
                                </div>

                                <div class="row">
                                    <!-- Claim Number -->
                                    <div class="col-md-2">
                                        <strong>Claim Number*</strong>
                                    </div>
                                    <div class="col-md-3">
                                        <input name="claim_no" type="number" class="form-control" required="required" placeholder="Format: 12345678910" />
                                    </div>

                                    <!-- Padding -->
                                    <div class="col-md-1">
                                    </div>

                                    <!-- Received Date -->
                                    <div class="col-md-2">
                                        <strong>Claim Received Date*</strong>
                                    </div>

                                    <div class="col-md-3">
                                        <div class="input-daterange input-group" id="datepicker" data-provide="datepicker">
                                            <span class="input-group-addon"><strong>Date</strong></span>
                                            <input id="recdDate" type="text" required="required" class="input-sm form-control" name="clm_recvd_date" />
                                        </div>
                                    </div>
                                </div>

                                <!-- Padding -->
                                <div class="row">
                                    <br />
                                </div>

                                <div class="row">

                                    <!-- Question -->
                                    <div class="col-md-2">
                                        <strong>Question*</strong>
                                    </div>
                                    <div class="col-md-3">
                                        <textarea name="question" class="form-control" rows="8" required="required" placeholder="Enter Your Question Here"></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div id="submitQ" dx-button="btnSubmit">
                            <input type="submit" name="submit" value="Submit" class="btn btn-primary btn-lg" />
                            <button class="btn btn-primary btn-lg" onclick="goBack()">Back</button>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>
    <?php include("includes/footer.html");?>
</body>
</html>
<!-- Styles -->
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />

<!-- Scripts -->
<script src="Scripts/bootstrap.js"></script>
<script src="Styles/DatePicker/js/bootstrap-datepicker.js"></script>

<script>
    $('.input-daterange').datepicker({
        format: 'yyyy-mm-dd',
        todayBtn: "linked",
        clearBtn: true
    });

    function goBack() {
        window.history.back();
    }
</script>
