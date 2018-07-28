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
            <div class="panel-heading">Panel heading</div>
            <div class="panel-body">
                <?php
                $server="localhost";
                $dbuser="root";
                $password="";

                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");
                $fromDate=$_GET["fromDate"];
                $toDate=$_GET["toDate"];

                $sql="CALL spOverallReport('$fromDate', '$toDate')";

                $result=mysqli_query($link,$sql);

                if(mysqli_num_rows($result)>0)
                {
                echo "<table>
                    ";
                    echo "
                    <tr>
                        <td><strong>Overall</strong></td>
                        <td><strong>Question Volume</strong></td>
                        <td><strong>Min. Tat (Days)</strong></td>
                        <td><strong>Max. Tat (Days)</strong></td>
                        <td><strong>Avg. Tat (Days)</strong></td>
                    </tr>";
                    while($row=mysqli_fetch_array($result)){
                    $volume=$row["volume"];
                    $min_tat=$row["min_tat"];
                    $max_tat=$row["max_tat"];
                    $avg_tat=$row["avg_tat"];
                    echo"
                    <tr>
                        <td>Overall</td>
                        <td>$volume</td>
                        <td>$min_tat</td>
                        <td>$max_tat</td>
                        <td>$avg_tat</td>
                    </tr>";
                    }
                    echo"
                </table>";
                }
                else
                {echo("No entries to display");}
                mysqli_close($link);
                ?>
            </div>
        </div>
        <div class="panel panel-primary">
            <!-- Default panel contents -->
            <div class="panel-heading">Panel heading</div>
            <div class="panel-body">
                <?php
                $server="localhost";
                $dbuser="root";
                $password="";

                $link=mysqli_connect($server,$dbuser,$password);
                mysqli_select_db($link, "question_log");
                $fromDate=$_GET["fromDate"];
                $toDate=$_GET["toDate"];

                $sql="CALL spOverallReport('$fromDate', '$toDate')";

                $result=mysqli_query($link,$sql);

                if(mysqli_num_rows($result)>0)
                {
                echo "<table>
                    ";
                    echo "
                    <tr>
                        <td><strong>Overall</strong></td>
                        <td><strong>Question Volume</strong></td>
                        <td><strong>Min. Tat (Days)</strong></td>
                        <td><strong>Max. Tat (Days)</strong></td>
                        <td><strong>Avg. Tat (Days)</strong></td>
                    </tr>";
                    while($row=mysqli_fetch_array($result)){
                    $volume=$row["volume"];
                    $min_tat=$row["min_tat"];
                    $max_tat=$row["max_tat"];
                    $avg_tat=$row["avg_tat"];
                    echo"
                    <tr>
                        <td>Overall</td>
                        <td>$volume</td>
                        <td>$min_tat</td>
                        <td>$max_tat</td>
                        <td>$avg_tat</td>
                    </tr>";
                    }
                    echo"
                </table>";
                }
                else
                {echo("No entries to display");}
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
