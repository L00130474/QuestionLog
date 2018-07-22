<!DOCTYPE html>
<html>
<head>
    <title>SubmitQuestion</title>
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
                                    Examiner Name:
                                </div>
                                <div class="col-md-3">
                                    <input name="examiner_name" type="text" class="form-control" required="required" placeholder="Enter Examiner Name" />
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <!-- Email Address -->
                                <div class="col-md-2">
                                    Email Address:
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
                                    Claim Number:
                                </div>
                                <div class="col-md-3">
                                    <input name="claim_no" type="number" class="form-control" required="required" placeholder="Format: 12345678910" />
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <!-- Received Date -->
                                <div class="col-md-2">
                                    Claim Received Date:
                                </div>
                                <div class="col-md-3">

                                    <div class="input-daterange input-group" id="datepicker" data-provide="datepicker">
                                        <span class="input-group-addon">From</span>
                                        <input id="recdDate" type="text" class="input-sm form-control" name="clm_recvd_date" />
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
                                    Question:
                                </div>
                                <div class="col-md-3">
                                    <textarea name="question" rows="8" cols="35" required="required" placeholder="Enter Your Question Here"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Submit -->
                    <div class="row">
                        <div class="col-md-3">
                            <div id="submitQ" dx-button="btnSubmit">
                                <input type="submit" name="submit" value="Submit Question" />
                            </div>
                        </div>
                    </div>
                </form>

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
