<?php require_once 'engine/init.php'; include 'layout/overall/header.php'; ?>

<h1>Downloads</h1>
<p>To play The Violet Project, install a 7.72-compatible client.</p>

<p>Download client for Windows <a href="<?php echo $config['client_download']; ?>">HERE</a>.</p>
<p>Download client for Linux <a href="<?php echo $config['client_download_linux']; ?>">HERE</a>.</p>
<p>Need classic Tibia.exe support? Download IP changer <a href="<?php echo isset($config['client_ip_changer_download']) ? $config['client_ip_changer_download'] : 'https://github.com/jo3bingham/tibia-ip-changer/releases/latest'; ?>">HERE</a>.</p>

<h2>How to connect and play:</h2>
<ol>
	<li>
		<a href="<?php echo $config['client_download']; ?>">Download</a> and install the client if you haven't already.
	</li>
	<li>
		If your client needs it, <a href="<?php echo isset($config['client_ip_changer_download']) ? $config['client_ip_changer_download'] : 'https://github.com/jo3bingham/tibia-ip-changer/releases/latest'; ?>">download</a> and run the IP changer.
	</li>
	<li>
		In the IP changer, change Client Path to the tibia.exe file where you installed the client.</strong>
	</li>
	<li>
		In the IP changer, write this in the IP field: <?php echo $_SERVER['SERVER_NAME']; ?>
	</li>
	<li>
		Now you can successfully login on the tibia client and play clicking on <strong>Apply</strong>.<br>
		If you do not have an account to login with, you need to register an account <a href="register.php">HERE</a>.
	</li>
</ol>

<?php
include 'layout/overall/footer.php'; ?>
