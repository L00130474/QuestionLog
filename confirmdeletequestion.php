<!DOCTYPE html>
<html>
<head>
    <title>Manage Questions</title>
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

    <div id="main" class="container theme-showcase" role="main">        
        <div class="panel panel-primary">
            <!-- Default panel contents -->
            <div class="panel-heading">Confirm Delete Property</div>
            <div class="panel-body">
                <?php
                $server="localhost";
                $dbuser="root";
                $password="";
                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");
                $q_id=$_GET['q_id'];

                $sql="SELECT * from question WHERE q_id = $q_id";
                $result=mysqli_query($link,$sql);
                
                echo "<table>
                    ";
                    echo "
                    <tr>
                        <td><strong>Examiner</strong></td>
                        <td><strong>Claim Number</strong></td>
                        <td><strong>Received Date</strong></td>
                        <td><strong>Question</strong></td>
                    </tr>";
                    $row=mysqli_fetch_array($result);
                    $q_id=$row["q_id"];
                    $examiner_name=$row["examiner_name"];
                    $claim_no=$row["claim_no"];
                    $clm_recvd_date=$row["clm_recvd_date"];
                    $question_txt=$row["question_txt"];
                    echo"
                    <tr>                        
                        <td>$examiner_name</td>                        
                        <td>$claim_no</td>
                        <td>$clm_recvd_date</td>
                        <td>$question_txt</td>
                    </tr>";
                    
                    echo"
                </table>";
                echo "Do you want to permanently delete this question?                
                <p>
                    <a href='deletequestion.php?q_id=$q_id'>Delete</a>
                    <a href='managequestions.php'>Cancel</a>";
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
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">


<!--https://getbootstrap.com/docs/3.3/components/-->
