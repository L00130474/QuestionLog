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
                    $question=$row["question"];
                    echo"
                    <tr>                        
                        <td>$examiner_name</td>                        
                        <td>$claim_no</td>
                        <td>$clm_recvd_date</td>
                        <td>$question</td>
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


<!--https://getbootstrap.com/docs/3.3/components/-->
