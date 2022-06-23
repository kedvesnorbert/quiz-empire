<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_index.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../includes/ip_functions.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function show_newssection()
{
	$deviceType = checkDevice();
	$res = db_newssection($_POST['n_offset'], $_POST['n_limit']);
	if(!$res)
	{
		return false;
	}
	$sorok = mysqli_num_rows($res);
	if($sorok == 0)
	{
		;
	}
	else
	{
		while($row = mysqli_fetch_assoc($res))
		{
			?>
			<div id='one_news_div' class="<?php echo "one_new_divclass" . $row['hir_id'] ?>">
				<table id='one_news_div_table'>
				<tr>
					<?php
					if($row['publication_date'] == 0)
					{
						$row['publication_date'] = "Ma";
					}
					elseif($row['publication_date'] > 0 && $row['publication_date'] < 7)
					{
						$row['publication_date'] .= " napja"; 
					}
					elseif($row['publication_date'] >= 7 && $row['publication_date'] <= 365)
					{
						$row['publication_date'] = floor($row['publication_date']/7) . " hete"; 
					}
					else
					{
						$row['publication_date'] = floor($row['publication_date']/365) . " éve"; 
					}
					
					if($row['adminuser'] == 1)
					{
						$kozzetevo = "<i>SYSTEM</i>";
						?>
						<td width="70%"><p id='publisher_name'>Közzétevő: <?php echo $kozzetevo . " <br><br>Hír létrehozva: <i>(" . $row['publication_date'] . ")"; ?></p>
						<?php
					}
					else
					{
						if($row['username'] != "Törölt felhasználó")
						{
							$kozzetevo = "<b>" . $row['username'] . "</b>";
							?>
							<td width="70%"><p id='publisher_name'>Közzétevő: <a href="profile.php?profil_id=<?php echo $row['userid'] ?>">
							<?php echo $kozzetevo; ?></a>  <?php echo " <br><br>Hír létrehozva: <i>(" . $row['publication_date'] . ")"; ?></p>
							<?php
						}
						else
						{
							$kozzetevo = "<i>" . $row['username'] . "</i>";
							?>
							<td width="70%"><p id='publisher_name'>Közzétevő: <?php echo $kozzetevo . " <br><br>Hír létrehozva: <i>(" . $row['publication_date'] . ")"; ?></p>
							<?php
						}
					}
					?>
					<td>
					<?php
					if($row['username'] == $_SESSION['user'] || $row['adminuser_my'] == 1)
					{
						?><button id='delmy_news' class="btn btn-danger" onclick='delete_this_news("<?php echo $row['hir_id']; ?>", "<?php echo $row['title']; ?>")'>Törlés</button>
						<div id="dialogDeleteThisNews" title="Hír törlése" style="display:none;"></div>
						<?php
					}
					?>
				<tr>
					<td colspan='2'><p id='news_title'><?php echo $row['title']; ?></p>
				<tr>
					<?php
					if(strlen($row['file_path'])> 1)
					{
						$filename = $row['filename'];
						$file = 'documents/images/newsfiles/' . $row['file_path'];
						$link_to_file = "<a href='$file' download>$filename</a> (" . $row['filesize'] . " MB)";
						$row['description'] .= "<br><br>Csatolt állományok: " . $link_to_file;
					}
					
					$reg_pattern = "/(((http|https|ftp|ftps)\:\/\/))[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\:[0-9]+)?(\/\S*)?/";
					if($deviceType != 0)
					{
						$row['description'] = preg_replace($reg_pattern, '<a href="$0" target="_self">$0</a>', $row['description']);
					}
					else
					{
						$row['description'] = preg_replace($reg_pattern, '<a href="$0" target="_blank">$0</a>', $row['description']);
					}
					
					if(strlen($row['image_path'])< 2)
					{
						?><td colspan='2'><p id='description_row'><?php echo nl2br($row['description']); ?></p><?php
					}
					else
					{
						?>
						<td style="word-wrap: break-word;"><p id='description_row'><?php echo nl2br($row['description']); 
						$imgurl = "documents/images/newsimages/" . $row['image_path'];
						?></p>
						<td style='padding-bottom:20px;text-align:center;'><img src="<?php echo $imgurl; ?>" alt="A képet nem találtuk meg a szerveren!" width="85%"></img>
						<?php
					}
					?>
				</table>
			</div>
			<?php
		}
	}
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(!isset($_POST['n_limit']) || strlen($_POST['n_limit'])<1 || !preg_match("/^[0-9]+$/", $_POST['n_limit']) || $_POST['n_limit'] <= -1 || 
	!isset($_POST['n_offset']) || strlen($_POST['n_offset'])<1 || !preg_match("/^[0-9]+$/", $_POST['n_offset']) || $_POST['n_offset'] <= -1)
	{
		
		echo err_missing_data();
	}
	elseif(logoff_ajax()==-1)
	{
		echo err_session_timeout();
	}
	else
	{
		show_newssection();
	}
}
else
{
	require_once("../error.php");
}
}
?>