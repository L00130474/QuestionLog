<?php

	session_start();
	$server="localhost";
	$dbuser="root";
	$password="";
	$link=mysqli_connect($server,$dbuser,$password);
	mysqli_select_db($link,"question_log");

	//if the form is submitted
	if(isset($_POST['username']) and isset($_POST['password']))
	{
		$username=$_POST['username'];
		$password=$_POST['password'];

	//Checking the values are existing in the database or not
	$query="SELECT * FROM administration WHERE username='$username' and password='$password'";
	$result=mysqli_query($link, $query) or die (mysqli_error($connection));
	$count=mysqli_num_rows($result);

	//check username and password
	if($count==1)
		{
			$_SESSION['username']=$username;
			header("Location:admin.php");
			exit;
		}
	else
	//If no match show error message and return to login
		{
			$_SESSION['errors']=array('Your username and/or password were incorrect');
			header("Location:adminlogin.php");
		}
	}
?>