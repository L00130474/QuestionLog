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
                        <li><a href="displayreports.php?fromDate=1900-01-01&toDate=2099-01-01">Display Reports</a></li>
                    </ul>
                </li>
                <li class="active"><a href="contactus.php">Contact Us</a></li>
                <li><a href="about.html">About</a></li>
            </ul>
        </div>
    </nav>

    <div id="main" class="container theme-showcase" role="main">

        <div class="panel panel-primary">
            <div class="panel-heading">Contact Us with any Feedback or Issues</div>
            <div class="panel-body">

                <div id="form">
                    <form method="post" action="confirmemail.php">
                        <div class="panel-body">

                            <!-- First Name -->
                            <div class="row">

                                <div class="col-md-2">
                                    First Name:
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
                                    Last Name:
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
                                    Email:
                                </div>
                                <div class="col-md-3 input-group">
                                    <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
                                    <input name="email" type="email" class="form-control" required="required" placeholder="Email Address" />
                                </div>

                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>

                            <!-- Email Text -->
                            <div class="row">
                                <div class="col-md-2">
                                    Comment:
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

</body>
</html>
<script src="Scripts/bootstrap.js"></script>
<link href="Styles/bootstrap/bootstrap.css" rel="stylesheet" />
<link href="Styles/bootstrap/bootstrap-theme.min.css" rel="stylesheet" />
<link href="Styles/DatePicker/css/bootstrap-datepicker.min.css" rel="stylesheet" />
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<!--Date Time Picker-->
<script src="Styles/DatePicker/js/bootstrap-datepicker.js"></script>
<script>
    $('.input-daterange').datepicker({
        format: 'yyyy-mm-dd',
        todayBtn: "linked",
        clearBtn: true
    });
</script>
<script type="text/javascript">
    var config = {
        '.chosen-select': {},
        '.chosen-select-deselect': { allow_single_deselect: true },
        '.chosen-select-no-single': { disable_search_threshold: 15 },
        '.chosen-select-no-results': { no_results_text: 'No Matches' },
        '.chosen-select-width': { width: "95%" }
    }
    for (var selector in config) {
        $(selector).chosen(config[selector]);
    }
</script>


<!--https://getbootstrap.com/docs/3.3/components/-->
<!--https://bootsnipp.com/snippets/featured/advanced-dropdown-search-->
<!--https://stackoverflow.com/questions/20769285/set-date-picker-to-a-given-date-->
<!--$.datepicker.setDefaults({
    dateFormat: 'dd.mm.yy'
});-->
