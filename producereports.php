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
            <!-- Default panel contents -->
            <div id="form">
                <form method="post" action="displayreports.php">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h3 class="panel-title">Please select question dates</h3>
                        </div>
                        <div class="panel-body">
                            <div class="row">

                                <!-- From Date -->
                                <div class="col-md-3">
                                    <div class="input-daterange input-group" id="datepicker" data-provide="datepicker">
                                        <span class="input-group-addon">From</span>
                                        <input id="fromDate" type="text" class="input-sm form-control" name="fromDate" required="required" />
                                    </div>
                                </div>

                                <!-- Padding -->
                                <div class="col-md-1">
                                </div>

                                <!-- To Date -->
                                <div class="col-md-3">
                                    <div class="input-daterange input-group" id="datepicker" data-provide="datepicker">
                                        <span class="input-group-addon">To</span>
                                        <input id="toDate" type="text" class="input-sm form-control" name="toDate" required="required" />
                                    </div>
                                </div>
                            </div>

                            <!-- Padding -->
                            <div class="row">
                                <br />
                            </div>                            
                        </div>
                    </div>
                    <!-- Submit -->
                    <div class="row">
                        <div class="col-md-3">
                            <div id="submitQ" dx-button="btnSubmit">
                                <input type="submit" name="submit" value="Generate Reports" />
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
