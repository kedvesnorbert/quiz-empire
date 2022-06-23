-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2022. Jún 23. 21:52
-- Kiszolgáló verziója: 10.4.11-MariaDB
-- PHP verzió: 7.2.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `quiz`
--

DELIMITER $$
--
-- Eljárások
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `accept_friendship` (IN `p_username` VARCHAR(25) CHARSET utf8, IN `p_friendid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
    DECLARE v_id1 INT;
    DECLARE v_id2 INT;
    DECLARE v_statusz INT;
    DECLARE v_sorszam INT DEFAULT 0;
    DECLARE v_szam INT;
	DECLARE v_friendname VARCHAR(30);
	
START TRANSACTION;
    SET p_response = "";
	SELECT user INTO v_friendname FROM user WHERE id = p_friendid;
    IF(is_realuser(p_username) = 1 AND is_realuser(v_friendname) = 1 AND p_username != v_friendname) THEN
        SELECT id INTO v_id1 FROM user WHERE user = p_username;
        SELECT id INTO v_id2 FROM user WHERE user = v_friendname;
        SELECT COUNT(*) INTO v_sorszam FROM friend WHERE (id1 = v_id1 AND id2 = v_id2) OR (id1 = v_id2 AND id2 = v_id1);
        IF(v_sorszam = 1) THEN      
            SELECT COUNT(*) INTO v_szam FROM friend WHERE id1 = v_id1 AND id2 = v_id2;
            IF(v_szam = 1) THEN
            
                SELECT status INTO v_statusz FROM friend WHERE id1 = v_id1 AND id2 = v_id2;     
                IF(v_statusz = 0) THEN
                    SET p_response = "Már barátnak jelölted ezt a felhasználót korábban. Várd meg amíg visszaigazol!";
                ELSEIF(v_statusz = 1) THEN
                    SET p_response = "Jelenleg barátok vagytok!";
                ELSE
                    SET p_response = "Barátnak jelölés MEGTAGADVA!";
                END IF;
            
            ELSE
            
                SELECT status INTO v_statusz FROM friend WHERE id1 = v_id2 AND id2 = v_id1;
                IF(v_statusz = 0) THEN
                    SET p_response = "Ez a felhasználó korábban barátnak jelölt. Igazold vissza, ha szeretnéd!";
                ELSEIF(v_statusz = 1) THEN
                    SET p_response = "Jelenleg barátok vagytok!";
                ELSE
                    SET p_response = "Ezt a felhasználót letiltottad!";
                END IF;
            END IF;
        ELSEIF(v_sorszam = 0) THEN
            INSERT INTO friend (id1, id2, status) VALUES (v_id1, v_id2, 0);
            INSERT INTO log_data VALUES (NULL, 29, p_username, CONCAT("Jelölésedet elküldtük a/az ", v_friendname, " nevű felhasználónak!"), "SYSTEM", NOW(), 0);
            INSERT INTO log_data VALUES (NULL, 29, v_friendname, CONCAT("Barátnak jelöltek, a/az ", p_username, " nevű felhasználó!"), "SYSTEM", NOW(), 0);
            SET p_response = "ok";
        ELSE
            SET p_response = "Error! Too many rows exception";
        END IF;
    
    ELSE
        SET p_response = "Wrong input parameters! Try again!";
    END IF;

	IF(p_response = "ok") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `accept_newquiz_accomplish` (IN `p_id` INT, IN `p_adminusername` VARCHAR(30) CHARSET utf8, OUT `p_response` VARCHAR(5000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_admindb INT;
	DECLARE v_darab INT;
	DECLARE v_phase INT;
	DECLARE v_osszeskerdes INT;
	DECLARE v_rendszeraltalkert INT;
	DECLARE v_kicsinalta VARCHAR(25);
	DECLARE v_cim VARCHAR(50);
START TRANSACTION;
	SET p_response = "";
	SELECT COUNT(id_number) INTO v_darab FROM thema WHERE id_number = p_id AND is_deleted = 0 AND is_request = 0;
	SELECT COUNT(*) INTO v_admindb FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	IF(v_darab != 1) THEN
		SET p_response = CONCAT(p_response, "Hibás kvíz azonosító! ");
	ELSEIF(v_admindb != 1) THEN
		SET p_response = CONCAT(p_response, "Hibás Admin azonosító! ");
	ELSE
		SELECT quiz_name, phase, requested_by, minimum_requested_quest INTO v_cim, v_phase, v_kicsinalta, v_rendszeraltalkert FROM thema WHERE id_number = p_id;
		IF(v_phase != 2) THEN
			SET p_response = CONCAT(p_response, "Hiba! A kvíz nincs a 2. fázisban! ");
		END IF;
		
		SELECT COUNT(id) INTO v_osszeskerdes FROM quiz_question WHERE quiz_id = p_id AND username = v_kicsinalta AND is_verified = 1;
		IF(v_osszeskerdes < v_rendszeraltalkert) THEN
			SET p_response = CONCAT(p_response, "Nincs elég kérdés beküldve ebben a témakörben! ");
		END IF;
		
		IF(p_response = "") THEN
			INSERT INTO log_data VALUES (NULL, 33, v_kicsinalta, CONCAT("Ezennel értesítünk, hogy az általad készített ", v_cim, " nevű saját kvízt sikeresen teljesítetted. Mostantól elérhető számodra és azon felhasználók számára, akiknek jogosultságot adtál. A kvíz elkészítéséért 300 jutalompontot kaptál."), p_adminusername, NOW(), 0);
			UPDATE user SET points = points + 300 WHERE user = v_kicsinalta;
			UPDATE thema SET phase = 3, accomplished_by = v_kicsinalta, accomplish_date = NOW() WHERE id_number = p_id;
			SET p_response = "ok";
		END IF;
	END IF;
	
	IF(p_response = "ok") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `accept_question` (IN `p_id` INT, IN `p_adminid` INT, OUT `p_response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darab INT;
	DECLARE v_admin INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_adminusername VARCHAR(30);
START TRANSACTION;
	SET p_response = '';
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;
	SELECT COUNT(*) INTO v_darab FROM quiz_question WHERE id = p_id AND (is_verified IS NULL OR is_verified = 0);
	IF(v_darab != 1) THEN
		SET p_response = 'Hibás azonosító, vagy a kérdés nincs abban a fázisban, hogy a műveletet végre lehessen hajtani!';
	ELSEIF(v_darab = 1 AND v_admin = 1 AND p_response = '') THEN
		SELECT username INTO v_username FROM quiz_question WHERE id = p_id;
		SELECT user INTO v_adminusername FROM user WHERE id = p_adminid;
		UPDATE quiz_question SET is_verified = 1, is_active = 1, verified_by = p_adminid, verification_time = NOW() WHERE id = p_id;
		UPDATE user SET points = points + 15 WHERE user = v_username;
		INSERT INTO log_data VALUES (NULL, 10, v_username, CONCAT('A ', p_id, ' - azonosítójú beküldött kérdésedet elfogadtuk. Jutalmad: 15 pont!'), v_adminusername, NOW(), 0);
		INSERT INTO question_comment VALUES (NULL, p_id, v_adminusername, CONCAT('Ezt a kérdést elfogadták! 15 pont jutalom került jóváírásra a beküldőnek.'), NOW());
		SET p_response = 'ok';
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `accept_request_accomplish` (IN `p_id` INT, IN `p_adminusername` VARCHAR(30) CHARSET utf8, OUT `p_response` VARCHAR(5000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_admin INT;
	DECLARE v_darab INT;
	DECLARE v_phase INT;
	DECLARE v_elvallalva INT;
	DECLARE v_osszeskerdes INT;
	DECLARE v_rendszeraltalkert INT;
	DECLARE v_useraltalkert INT;
	DECLARE v_nagyobb INT;
	DECLARE v_kivallalta VARCHAR(25);
	DECLARE v_cim VARCHAR(50);
	DECLARE v_pontszam INT;
	DECLARE v_userid INT;
	DECLARE c_user INT;
	DECLARE c_usernev VARCHAR(25);
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE curz1 CURSOR FOR SELECT DISTINCT user_id FROM request_vote WHERE quiz_id = p_id;        
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
START TRANSACTION;
	SET p_response = "";
	SELECT COUNT(*) INTO v_admin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = CONCAT(p_response, "Hibás Admin azonosító! ");
	END IF;
	SELECT COUNT(id_number) INTO v_darab FROM thema WHERE id_number = p_id AND is_deleted = 0;
	IF(v_darab != 1) THEN
		SET p_response = CONCAT(p_response, "Hibás kérés azonosító! ");
	ELSE
		SELECT quiz_name, phase, is_undertaken, undertaken_by, minimum_requested_quest, byuser_minreq_quest INTO v_cim, v_phase, v_elvallalva, v_kivallalta, v_rendszeraltalkert, v_useraltalkert FROM thema WHERE id_number = p_id;
		IF(v_phase != 2) THEN
			SET p_response = CONCAT(p_response, "Hiba! A kérés nincs a 2. fázisban! ");
		END IF;
		IF(v_elvallalva != 1) THEN
			SET p_response = CONCAT(p_response, "A kérés teljesítését senki sem vállalta el! ");
		END IF;
		IF(v_useraltalkert = NULL) THEN
			SET v_nagyobb = v_rendszeraltalkert;
		ELSE
			IF(v_useraltalkert > v_rendszeraltalkert) THEN
				SET v_nagyobb = v_useraltalkert;
			ELSE
				SET v_nagyobb = v_rendszeraltalkert;
			END IF;
		END IF;
		SELECT COUNT(id) INTO v_osszeskerdes FROM quiz_question WHERE quiz_id = p_id AND username = v_kivallalta AND is_verified = 1;
		IF(v_osszeskerdes < v_nagyobb) THEN
			SET p_response = CONCAT(p_response, "Nincs elég kérdés beküldve ebben a témakörben! ");
		END IF;
		SELECT id INTO v_userid FROM user WHERE user = v_kivallalta;
		
		IF(p_response = "") THEN
			OPEN curz1;
			REPEAT
				FETCH curz1 INTO c_user;
				IF ( ! done ) THEN
					SELECT user INTO c_usernev FROM user WHERE id = c_user;
					INSERT INTO log_data VALUES (NULL, 21, c_usernev, CONCAT("Ezennel értesítünk, hogy az általad (is) kért ", v_cim, " nevű kvíz TELJESÍTVE LETT!"), "SYSTEM", NOW(), 0);
				END IF;
			UNTIL done END REPEAT;
			CLOSE curz1;
			
			SELECT SUM(offered_points) INTO v_pontszam FROM request_vote WHERE quiz_id = p_id;
			INSERT INTO log_data VALUES (NULL, 21, v_kivallalta, CONCAT("A/Az ", v_cim, " nevű kérést sikeresen teljesítetted! Jutalmad: ", FLOOR(v_pontszam/2), " pont. "), p_adminusername, NOW(), 0);
			UPDATE user SET points = points + FLOOR(v_pontszam/2) WHERE user = v_kivallalta;
			DELETE FROM request_vote WHERE quiz_id = p_id;
			UPDATE thema SET phase = 3, accomplished_by = v_kivallalta, accomplish_date = NOW() WHERE id_number = p_id;
			UPDATE undertaken_request SET status = 1 WHERE user_id = v_userid AND request_id = p_id;
			SET p_response = "ok";
		END IF;
		IF(p_response = "ok") THEN
			COMMIT;
		ELSE
			ROLLBACK;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `accomplish_request` (IN `p_requestid` INT, IN `p_user` VARCHAR(30) CHARSET utf8, IN `p_anonymus` INT, OUT `p_response` VARCHAR(5000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_keres INT;
	DECLARE v_fazis INT;
	DECLARE v_jelenleg_elvallt INT;
	DECLARE v_userid INT;
	DECLARE v_kikerte VARCHAR(30);
	DECLARE v_mar_elvallaltak INT;
	DECLARE v_duplanvallalt INT;
	DECLARE v_temanev VARCHAR(150);
	DECLARE v_level INT;
	DECLARE v_kuldhetkerdest INT;
START TRANSACTION;
	SET p_response = "";
	SELECT level, lawtosendquestion INTO v_level, v_kuldhetkerdest FROM user WHERE user = p_user;
	/*IF(v_level < 3) THEN
		SET p_response = CONCAT(p_response, "A kéréseket csak 3., vagy magasabb rangú felhasználóink teljesíthetik! ");
	END IF;*/
	IF(v_kuldhetkerdest != 1) THEN
		SET p_response = CONCAT(p_response, "A kérést NEM teljesítheted, mert NINCS jogod kvízkérdéseket beküldeni! ");
	END IF;
	SELECT is_request, phase INTO v_keres, v_fazis FROM thema WHERE id_number = p_requestid;
	IF(v_keres != 1 OR v_fazis != 2) THEN
		SET p_response = CONCAT(p_response, "Hiba! Ez a kérés nem teljesíthető! ");
	END IF;
	SELECT id INTO v_userid FROM user WHERE user = p_user;
	SELECT COUNT(*) INTO v_jelenleg_elvallt FROM undertaken_request WHERE user_id = v_userid AND status = 0;
	IF(v_jelenleg_elvallt > 5) THEN
		SET p_response = CONCAT(p_response, "Egyszerre MAX 5 kérés teljesítését vállalhatod el! ");
	END IF;
	SELECT COUNT(*) INTO v_duplanvallalt FROM undertaken_request WHERE user_id = v_userid AND request_id = p_requestid;
	IF(v_duplanvallalt > 0) THEN
		SET p_response = CONCAT(p_response, "Csak egyszer van lehetőséged egy kérés tejesítésére! ");
	END IF;
	SELECT requested_by INTO v_kikerte FROM thema WHERE id_number = p_requestid;
	IF(v_kikerte = p_user) THEN
		SET p_response = CONCAT(p_response, "Saját kérésedet NEM teljesítheted! ");
	END IF;
	SELECT COUNT(*) INTO v_mar_elvallaltak FROM undertaken_request WHERE request_id = p_requestid AND status = 0;
	IF(v_mar_elvallaltak > 0) THEN
		SET p_response = CONCAT(p_response, "Ennek a kérésnek a teljesítését már elvállalták! ");
	END IF;
	IF(p_response = "") THEN
		SELECT quiz_name INTO v_temanev FROM thema WHERE id_number = p_requestid;
		INSERT INTO log_data VALUES(NULL, 20, p_user, CONCAT("Jelentkeztél a ", v_temanev, " nevű kérés teljesítésére! További információ: -elvállalt kérések-nél."), "SYSTEM", NOW(), 0);
		IF(p_anonymus = 1 AND v_level > 4) THEN
			UPDATE thema SET is_undertaken = 1, undertaken_by = p_user, accomplish_deadline = NOW() + INTERVAL 7 DAY, anonymus_accomplish = 1 WHERE id_number = p_requestid;
		ELSE
			UPDATE thema SET is_undertaken = 1, undertaken_by = p_user, accomplish_deadline = NOW() + INTERVAL 7 DAY, anonymus_accomplish = 0 WHERE id_number = p_requestid;
		END IF;
		INSERT INTO undertaken_request VALUES(v_userid, p_requestid, 0);
	END IF;
	IF(p_response = "") THEN
		SET p_response = "Sikeres művelet!";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_to_favorites` (IN `p_username` VARCHAR(25) CHARSET utf8, IN `p_quizid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darabszam INT;
	DECLARE v_id INT;
	DECLARE v_toroltuser INT;
START TRANSACTION;
	SET p_response = "";
	SELECT COUNT(id) INTO v_id FROM user WHERE user = p_username;
	IF(v_id = 1) THEN
		SELECT id, deleteduser INTO v_id, v_toroltuser FROM user WHERE user = p_username;
		IF(v_toroltuser != 0) THEN
			SET p_response = CONCAT(p_response, "Törölt felhasználó!!");
		END IF;
		SELECT COUNT(f.quiz_id) INTO v_darabszam FROM favorite_quiz f JOIN user u ON (f.user_id = u.id) WHERE u.user = p_username AND f.quiz_id = p_quizid;
		IF(v_darabszam > 0) THEN
			SET p_response = CONCAT(p_response, "Ezt a kvízt már hozzáadtad a Kedvencekhez!");
		END IF;
		IF(v_darabszam = 0 AND p_response = "") THEN
			INSERT INTO favorite_quiz VALUES(v_id, p_quizid);
		END IF;
	ELSE
		SET p_response = CONCAT(p_response, "Hibás user azonosító");
	END IF;

	IF(p_response = "") THEN
		SET p_response = "Sikeres művelet!";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `block_user` (IN `p_username` VARCHAR(25) CHARSET utf8, IN `p_friendid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
    DECLARE v_id1 INT;
    DECLARE v_id2 INT;
    DECLARE v_statusz INT;
    DECLARE v_sorszam INT DEFAULT 0;
    DECLARE v_szam INT;
	DECLARE v_friendname VARCHAR(30);
	
START TRANSACTION;
    SET p_response = "";
	SELECT user INTO v_friendname FROM user WHERE id = p_friendid;
    IF(is_realuser(p_username) = 1 AND is_realuser(v_friendname) = 1 AND p_username != v_friendname) THEN
        SELECT id INTO v_id1 FROM user WHERE user = p_username;
        SELECT id INTO v_id2 FROM user WHERE user = v_friendname;
        SELECT COUNT(*) INTO v_sorszam FROM friend WHERE (id1 = v_id1 AND id2 = v_id2) OR (id1 = v_id2 AND id2 = v_id1);
        IF(v_sorszam = 1) THEN      
            SELECT COUNT(*) INTO v_szam FROM friend WHERE id1 = v_id1 AND id2 = v_id2;
            IF(v_szam = 1) THEN
            
                SELECT status INTO v_statusz FROM friend WHERE id1 = v_id1 AND id2 = v_id2;     
                IF(v_statusz = 0) THEN
					UPDATE friend SET status = -1 WHERE id1 = v_id1 AND id2 = v_id2;
                    SET p_response = "ok";
                ELSEIF(v_statusz = 1) THEN
                    SET p_response = "Jelenleg barátok vagytok! Ahhoz, hogy le tudd tiltani, törölnöd kell a baráti listádról!";
                ELSE
                    SET p_response = "Ezt a felhasználót már letiltottad!";
                END IF;
            
            ELSE
            
                SELECT status INTO v_statusz FROM friend WHERE id1 = v_id2 AND id2 = v_id1;
                IF(v_statusz = 0) THEN
                    SET p_response = "Ez a felhasználó korábban barátnak jelölt. Ahhoz, hogy le tudd tiltani, törölnöd kell a baráti jelölését!";
                ELSEIF(v_statusz = 1) THEN
                    SET p_response = "Jelenleg barátok vagytok! Ahhoz, hogy le tudd tiltani, törölnöd kell a baráti listádról!";
                ELSE
                    SET p_response = "Ez a felhasználót letiltott téged!";
                END IF;
            END IF;
        ELSEIF(v_sorszam = 0) THEN
            INSERT INTO friend (id1, id2, status) VALUES (v_id1, v_id2, -1);
            SET p_response = "ok";
        ELSE
            SET p_response = "Error! Too many rows exception";
        END IF;
    
    ELSE
        SET p_response = "Wrong input parameters! Try again!";
    END IF;

	IF(p_response = "ok") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buy_help` (IN `p_username` VARCHAR(30) CHARSET utf8, IN `p_itemcount` INT, OUT `p_response` VARCHAR(150) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_warn INT;
	DECLARE v_szint INT;
	DECLARE v_pontszam INT;
	DECLARE v_premium INT;
	DECLARE v_toroltuser INT;
START TRANSACTION;
	SELECT warn, level, points, premium, deleteduser INTO v_warn, v_szint, v_pontszam, v_premium, v_toroltuser FROM user WHERE user = p_username;
	IF(v_warn != 0) THEN
		SET p_response = 'WARN-t kaptál! Ez alatt számodra ez a funkció nem megengedett!!!';
	END IF;
	IF(v_toroltuser != 0) THEN
		SET p_response = 'Törölt felhasználó! Ez a funkció nem megengedett!!!';
	ELSE
		IF(v_warn = 0 AND v_premium != 0) THEN
			IF(v_pontszam >= 4*p_itemcount) THEN
				SET p_response = CONCAT("Sikeres művelet! Vásároltál ", p_itemcount, " segítséget ", 4*p_itemcount, " pontért!");
				UPDATE user SET points = points - 4*p_itemcount, help = help + p_itemcount WHERE user = p_username;
				INSERT INTO log_data VALUES (NULL, 8, p_username, CONCAT("Vásároltál ", p_itemcount, " segítséget ", 4*p_itemcount, " pontért!"), 'SYSTEM', NOW(), 0);
			ELSE
				SET p_response = "Nem sikerült végrehajtani a vásárlást, mert nincs elegendő mennyiségű pontszámod!";
			END IF;
		ELSEIF(v_warn = 0 AND v_premium = 0 AND v_szint = 2) THEN
			IF(v_pontszam >= 24*p_itemcount) THEN
				SET p_response = CONCAT("Sikeres művelet! Vásároltál ", p_itemcount, " segítséget ", 24*p_itemcount, " pontért!");
				UPDATE user SET points = points - 24*p_itemcount, help = help + p_itemcount WHERE user = p_username;
				INSERT INTO log_data VALUES (NULL, 8, p_username, CONCAT("Vásároltál ", p_itemcount, " segítséget ", 24*p_itemcount, " pontért!"), 'SYSTEM', NOW(), 0);
			ELSE
				SET p_response = "Nem sikerült végrehajtani a vásárlást, mert nincs elegendő mennyiségű pontszámod!";
			END IF;
		ELSEIF(v_warn = 0 AND v_premium = 0 AND v_szint = 3) THEN
			IF(v_pontszam >= 18*p_itemcount) THEN
				SET p_response = CONCAT("Sikeres művelet! Vásároltál ", p_itemcount, " segítséget ", 18*p_itemcount, " pontért!");
				UPDATE user SET points = points - 18*p_itemcount, help = help + p_itemcount WHERE user = p_username;
				INSERT INTO log_data VALUES (NULL, 8, p_username, CONCAT("Vásároltál ", p_itemcount, " segítséget ", 18*p_itemcount, " pontért!"), 'SYSTEM', NOW(), 0);
			ELSE
				SET p_response = "Nem sikerült végrehajtani a vásárlást, mert nincs elegendő mennyiségű pontszámod!";
			END IF;	
		ELSEIF(v_warn = 0 AND v_premium = 0 AND v_szint = 4) THEN
			IF(v_pontszam >= 12*p_itemcount) THEN
				SET p_response = CONCAT("Sikeres művelet! Vásároltál ", p_itemcount, " segítséget ", 12*p_itemcount, " pontért!");
				UPDATE user SET points = points - 12*p_itemcount, help = help + p_itemcount WHERE user = p_username;
				INSERT INTO log_data VALUES (NULL, 8, p_username, CONCAT("Vásároltál ", p_itemcount, " segítséget ", 12*p_itemcount, " pontért!"), 'SYSTEM', NOW(), 0);
			ELSE
				SET p_response = "Nem sikerült végrehajtani a vásárlást, mert nincs elegendő mennyiségű pontszámod!";
			END IF;	
		ELSEIF(v_warn = 0 AND v_premium = 0 AND v_szint = 5) THEN
			IF(v_pontszam >= 8*p_itemcount) THEN
				SET p_response = CONCAT("Sikeres művelet! Vásároltál ", p_itemcount, " segítséget ", 8*p_itemcount, " pontért!");
				UPDATE user SET points = points - 8*p_itemcount, help = help + p_itemcount WHERE user = p_username;
				INSERT INTO log_data VALUES (NULL, 8, p_username, CONCAT("Vásároltál ", p_itemcount, " segítséget ", 8*p_itemcount, " pontért!"), 'SYSTEM', NOW(), 0);
			ELSE
				SET p_response = "Nem sikerült végrehajtani a vásárlást, mert nincs elegendő mennyiségű pontszámod!";
			END IF;
		ELSEIF(v_warn = 0 AND v_premium = 0 AND v_szint < 2) THEN
			SET p_response = "Ezt a funkciót csak KEZDŐ-, vagy magasabb szintű felhasználóink érhetik el! \n(Kivéve prémium felhasználók)!!!";
		END IF;
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `change_password` (IN `p_user` VARCHAR(30) CHARSET utf8, IN `p_currentpw` VARCHAR(128) CHARSET utf8, IN `p_newpw` VARCHAR(128) CHARSET utf8, IN `p_newpw2` VARCHAR(128) CHARSET utf8, OUT `p_response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_regijelszo VARCHAR(128);
	DECLARE v_toroltuser INT;
START TRANSACTION;
	SET p_response = "";
	SELECT pw, deleteduser INTO v_regijelszo, v_toroltuser FROM user WHERE user = p_user;
	IF(v_toroltuser != 0) THEN
		SET p_response = CONCAT(p_response, "Törölt felhasználó!!! ");
	END IF;
	IF(LENGTH(p_newpw) < 128 OR LENGTH(p_newpw2) < 128 OR LENGTH(p_currentpw) < 128) THEN
		SET p_response = CONCAT(p_response, "Mindhárom mező kitöltése kötelező! ");
	END IF;
	IF(p_newpw != p_newpw2) THEN
		SET p_response = CONCAT(p_response, "Nem talál a két jelszó! ");
	END IF;
	IF(p_currentpw != v_regijelszo) THEN
		SET p_response = CONCAT(p_response, "A jelenlegi jelszavadat helytelenül írtad be! ");
	END IF;
	IF(p_currentpw = p_newpw) THEN
		SET p_response = CONCAT(p_response, "A régi és az új jelszavad megegyezik! ");
	END IF;
	IF(p_response = "") THEN
		UPDATE user SET pw = p_newpw WHERE user = p_user;
		INSERT INTO log_data VALUES(NULL, 8, p_user, CONCAT("A jelszavadat sikeresen megváltoztattad."), 'SYSTEM', NOW(), 1);
		SET p_response = "mindenok";
	END IF;
	IF(p_response = "mindenok") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `confirm_newquiz` (IN `p_quizid` INT, IN `p_adminusername` VARCHAR(30) CHARSET utf8, OUT `response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_dbadmin INT;
	DECLARE v_fazis INT;
	DECLARE v_ownquiz INT;
	DECLARE v_torolt INT;
	DECLARE v_temanev VARCHAR(150);
	DECLARE v_kikerte VARCHAR(30);
START TRANSACTION;
	SET response = "";
	SELECT COUNT(*) INTO v_dbadmin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	SELECT COUNT(*) INTO v_db FROM thema WHERE id_number = p_quizid;
	IF(v_db != 1) THEN
		SET response = CONCAT(response, "Hibás kvízazonosító! ");
	ELSEIF(v_dbadmin != 1) THEN
		SET response = CONCAT(response, "Hibás Adminazonosító! ");
	ELSE
		SELECT phase, is_deleted, quiz_name, is_request, requested_by INTO v_fazis, v_torolt, v_temanev, v_ownquiz, v_kikerte FROM thema WHERE id_number = p_quizid;
		IF(v_ownquiz != 0) THEN
			SET response = CONCAT(response, "Hiba! Nem saját kvíz ez a kvíz! ");
		END IF;
		IF(v_fazis != 1) THEN
			SET response = CONCAT(response, "Hiba! A kvíz nincs az első fázisban! ");
		END IF;
		IF(v_torolt != 0) THEN
			SET response = CONCAT(response, "Hiba! Ez a kvíz törölve van! ");
		END IF;
		IF(v_fazis = 1 AND v_torolt = 0 AND response = "") THEN
			UPDATE thema SET phase = 2 WHERE id_number = p_quizid;
			INSERT INTO log_data VALUES(NULL, 14, v_kikerte, CONCAT("Elfogadtuk a ", v_temanev, " nevű új kvízed témáját! Most már nekiláthatsz kérdéseket beküldeni a kvízedhez."), p_adminusername, NOW(), 0);
		END IF;
	END IF;
	
	IF(response = "") THEN
		SET response = "ok";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `confirm_request` (IN `p_requestid` INT, IN `p_adminusername` VARCHAR(30) CHARSET utf8, OUT `response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_admin INT;
	DECLARE v_requestcount INT;
	DECLARE v_fazis INT;
	DECLARE v_torolt INT;
	DECLARE v_isrequest INT;
	DECLARE v_temanev VARCHAR(150);
	DECLARE v_kikerte VARCHAR(30);
START TRANSACTION;
	SET response = "";
	SELECT COUNT(*) INTO v_admin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET response = CONCAT(response, "Hibás Admin azonosító! ");
	END IF;
	SELECT COUNT(id_number) INTO v_requestcount FROM thema WHERE id_number = p_requestid AND is_request = 1;
	IF(v_requestcount != 1) THEN
		SET response = CONCAT(response, "Hibás kérés azonosító! ");
	ELSE
		SELECT is_request, phase, is_deleted, quiz_name, requested_by INTO v_isrequest, v_fazis, v_torolt, v_temanev, v_kikerte FROM thema WHERE id_number = p_requestid;
		IF(v_fazis != 1) THEN
			SET response = CONCAT(response, "Hiba! A kérés nincs az első fázisban! ");
		END IF;
		IF(v_torolt != 0) THEN
			SET response = CONCAT(response, "Hiba! Ez a kérés törölve van! ");
		END IF;
		IF(v_isrequest != 1) THEN
			SET response = CONCAT(response, "Hiba! Ez a kvíz NEM egy kérés! ");
		END IF;
		IF(v_fazis = 1 AND v_torolt = 0 AND response = "") THEN
			UPDATE thema SET phase = 2 WHERE id_number = p_requestid;
			INSERT INTO log_data VALUES(NULL, 19, v_kikerte, CONCAT("Elfogadtuk a/az ", v_temanev, " nevű kérésedet! Ennek teljesítése esetén értesíteni fogunk."), p_adminusername, NOW(), 0);
		END IF;
	END IF;
	
	IF(response = "") THEN
		SET response = "ok";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `connect_database` ()  MODIFIES SQL DATA
BEGIN
	SET NAMES 'utf8mb4';
    SET CHARACTER SET 'utf8mb4';
	SET COLLATION_CONNECTION='utf8mb4_unicode_ci';
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `correcting_question` (IN `p_questionid` INT, IN `p_quizid` INT, IN `p_question` VARCHAR(255) CHARSET utf8, IN `p_ans1` VARCHAR(150) CHARSET utf8, IN `p_ans2` VARCHAR(150) CHARSET utf8, IN `p_ans3` VARCHAR(150) CHARSET utf8, IN `p_ans4` VARCHAR(150) CHARSET utf8, IN `p_username` VARCHAR(25) CHARSET utf8, IN `p_comment` VARCHAR(150) CHARSET utf8, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE k INT;
	DECLARE v1 INT;
    DECLARE v2 INT;
    DECLARE v3 INT;
    DECLARE v4 INT;
	DECLARE megj INT;
	DECLARE v_pk INT DEFAULT 0;
	DECLARE old_kerdes VARCHAR(255);
	DECLARE old_val1 VARCHAR(150);
	DECLARE old_val2 VARCHAR(150);
	DECLARE old_val3 VARCHAR(150);
	DECLARE old_val4 VARCHAR(150);
	DECLARE v_gettemaid INT;
START TRANSACTION;
	SET v_gettemaid = law_to_get_thema(p_username, p_quizid);
	SET k = is_correct_questiontext(p_question);
    SET v1 = is_correct_questionanswer(p_ans1);
    SET v2 = is_correct_questionanswer(p_ans2);
    SET v3 = is_correct_questionanswer(p_ans3);
    SET v4 = is_correct_questionanswer(p_ans4);
	SET megj = is_correct_questionanswer(p_comment);
	SELECT COUNT(id) INTO v_pk FROM quiz_question WHERE id = p_questionid AND is_verified = 2 AND username = p_username;
	IF(v_pk = 1) THEN
		SELECT is_verified INTO v_pk FROM quiz_question WHERE id = p_questionid AND is_verified = 2 AND username = p_username;
		IF(CAST(p_questionid AS UNSIGNED) > 0 AND p_questionid > 0 AND LENGTH(p_question) > 0 AND LENGTH(p_ans1) > 0 AND LENGTH(p_ans2) > 0 AND LENGTH(p_ans3) > 0 AND LENGTH(p_ans4) > 0 AND LENGTH(p_username) > 0 AND v_gettemaid = 1 AND k = 1 AND v1 = 1 AND v2 = 1 AND v3 = 1 AND v4 = 1 AND megj = 1 AND CAST(p_quizid AS UNSIGNED) > 0 AND p_quizid > 0 AND v_pk = 2) THEN
			SELECT question, ans1, ans2, ans3, ans4 INTO old_kerdes, old_val1, old_val2, old_val3, old_val4 FROM quiz_question WHERE id = p_questionid AND is_verified = 2 AND username = p_username;
			UPDATE quiz_question SET quiz_id = p_quizid, question = p_question, ans1 = p_ans1, ans2 = p_ans2, ans3 = p_ans3, ans4 = p_ans4, is_verified = NULL WHERE id = p_questionid;
			INSERT INTO question_comment VALUES(NULL, p_questionid, p_username, CONCAT('Módosítás előtti adatok: kérdés - ', old_kerdes, ' , helyes válasz - ', old_val1, ' , rossz válaszok: ', old_val2, ' , ', old_val3, ' , ', old_val4) , NOW());
			INSERT INTO log_data VALUES (NULL, 35, p_username, CONCAT("A/Az ", p_questionid, ' - azonosítójú kérdés javítva!'), "SYSTEM", NOW(), 1);
			IF(LENGTH(p_comment) > 0) THEN
				INSERT INTO question_comment VALUES(NULL, p_questionid, p_username, p_comment, NOW());
			END IF;
			SET p_response = 'mindenok';
		ELSE
			SET p_response = 'Hiba történt! Helytelen adatokat adtál meg! Vigyázz, hogy a kérdés és a válaszok ne tartalmazzanak SQL specifikus szavakat! A kérdés nagybetűvel, vagy idézőjellel kezdődjön és kérdőjellel végződjön! Csak a számodra engedélyezett témakörben küldhetsz be kérdéseket!';
		END IF;
	ELSE
		SET p_response = 'Hiba történt! Lehetséges okok: nincs ilyen azonosítójű kérdés, vagy nincs jogod módosítani ezt a kérdést!';
	END IF;
	
	IF(p_response = 'mindenok') THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_competition` (IN `p_themaid` INT, IN `p_color` VARCHAR(7) CHARSET utf8, IN `p_announcement` DATE, IN `p_startdate` DATETIME, IN `p_enddate` DATETIME, IN `p_activity` INT, IN `p_rew1` INT, IN `p_rew2` INT, IN `p_rew3` INT, IN `p_rew4` INT, IN `p_rew5` INT, IN `p_rew6` INT, IN `p_rew7` INT, IN `p_adminid` INT, OUT `p_response` VARCHAR(5000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darab INT;
	DECLARE v_startdate DATETIME;
	DECLARE v_enddate DATETIME;
	DECLARE v_quizid INT;
	DECLARE v_admin INT;
	DECLARE v_quizexists INT;
	DECLARE x INT DEFAULT 0;
	DECLARE y INT;
	
	DECLARE c_announcement_date DATE;
	DECLARE c_startdate DATETIME;
	DECLARE c_enddate DATETIME;
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE curz1 CURSOR FOR SELECT announcement_date, startdate, enddate FROM competition WHERE announcement_date > NOW();        
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
	
START TRANSACTION;
	SET p_response = '';
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;
	
	IF(p_rew1 < 100 OR p_rew1 > 25000) THEN
		SET p_response = 'A maximális jutalom 100-25000 közötti pontmennyiség legyen!!';
	END IF;
	IF(p_rew1 <= p_rew2 OR p_rew2 <= p_rew3 OR p_rew3 <= p_rew4 OR p_rew4 <= p_rew5 OR p_rew5 <= p_rew6 OR p_rew6 <= p_rew7) THEN
		SET p_response = 'A jutalmak nagysága szigorúan csökkenő érték legyen az elsőtől az utolsóig!';
	END IF;
	
	IF(DATEDIFF(p_announcement, NOW()) < 1) THEN
		SET p_response = 'A bejelentés ideje nem lehet kisebb a mai dátumnál!';
	END IF;
	
	IF(STR_TO_DATE(p_announcement, '%Y-%m-%d') IS NULL) THEN
		SET p_response = 'A bejelentés ideje helytelen, vagy nem egy dátum!';
	END IF;
	
	IF(STR_TO_DATE(p_startdate, '%Y-%m-%d %H:%i:%s') IS NULL) THEN
		SET p_response = 'A kezdés ideje helytelen, vagy nem egy dátum!';
	END IF;
	
	IF(STR_TO_DATE(p_enddate, '%Y-%m-%d %H:%i:%s') IS NULL) THEN
		SET p_response = 'A lezárás ideje helytelen, vagy nem egy dátum!';
	END IF;
	
	IF(DATEDIFF(p_startdate, p_announcement) < 1) THEN
		SET p_response = 'A bejelentés ideje és a kezdés dátuma közt legyen minimum 1 nap különbség! Természetesen a bejelentés ideje kisebb kell legyen a kezdés idejénél!';
	END IF;
	
	IF(DATEDIFF(p_enddate, p_startdate) < 3 OR DATEDIFF(p_enddate, p_startdate) > 14) THEN
		SET p_response = 'A verseny legalább 3 napot, de maximum 14 napig tarthat!';
	END IF;
	
	SELECT COUNT(*) INTO v_quizexists FROM thema WHERE id_number = p_themaid AND phase = 3;
	IF(v_quizexists = 1) THEN
		OPEN curz1;
			REPEAT
				FETCH curz1 INTO c_announcement_date, c_startdate, c_enddate;
				IF ( ! done ) THEN
					IF( (c_enddate < p_announcement AND p_enddate > c_announcement_date) || (p_enddate < c_announcement_date AND c_enddate > p_announcement) ) THEN
						SET y = 69999;
					ELSE
						SET x = X + 1;
					END IF;
				END IF;
			UNTIL done END REPEAT;
		CLOSE curz1;
		
		
		IF(p_response = '' AND x = 0) THEN
			INSERT INTO competition VALUES(NULL, p_themaid, p_announcement, 0, p_rew1, p_rew2, p_rew3, p_rew4, p_rew5, p_rew6, p_rew7, p_startdate, p_enddate, p_color);
			SET p_response = 'ok';
		ELSE
			SET p_response = CONCAT(p_response, 'Nem sikerült létrehozni a versenyt! ', x);
			IF(x > 0) THEN
				SET p_response = CONCAT(p_response, ' verseny időpontjával ütközik! ');
			END IF;
		END IF;
	ELSE
		SET p_response = 'Nem található ilyen azonosítójú kvíz!';
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_new_chatgroup` (IN `p_name` VARCHAR(25) CHARSET utf8, IN `p_creatorid` INT, IN `p_invitemore` INT, IN `p_members` VARCHAR(9000) CHARSET utf8, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_lawtousechat INT;
	DECLARE v_now DATETIME;
	DECLARE v_groupid INT;
	DECLARE v_username VARCHAR(30);
	DECLARE c_id INT;
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE curz CURSOR FOR SELECT id FROM user WHERE FIND_IN_SET(id, p_members) AND id IN ( SELECT f.id1 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.id = p_creatorid AND f.status = 1 UNION SELECT f.id2 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.id = p_creatorid AND f.status = 1);
START TRANSACTION;
	SET p_response = "";
	IF(LENGTH(p_name)< 5 OR LENGTH(p_name)>25) THEN
		SET p_response = CONCAT(p_response, "Az csoport neve maximum 25 karakter lehet! ");
	END IF;
	IF(p_creatorid < 0) THEN
		SET p_response = CONCAT(p_response, "Hibás user azonosító! ");
	END IF;
	IF(p_invitemore < 0 || p_invitemore > 1) THEN
		SET p_response = CONCAT(p_response, "Hibás adat a további tagok meghívása! ");
	END IF;
	SELECT user, lawtousechat INTO v_username, v_lawtousechat FROM user WHERE id = p_creatorid;
	IF(v_lawtousechat != 1) THEN
		SET p_response = CONCAT(p_response, "Nincs jogod csoportot létrehozni és üzenetet küldeni! ");
	END IF;
	
	SET v_now = NOW();
	IF(p_response = "") THEN
		INSERT INTO chat_group VALUES(NULL, p_name, p_creatorid, v_now, p_invitemore, 0);
		SELECT COUNT(*) INTO v_groupid FROM chat_group WHERE group_creator = p_creatorid AND creation_date = v_now;
		IF(v_groupid = 1) THEN
			SELECT id INTO v_groupid FROM chat_group WHERE group_creator = p_creatorid AND creation_date = v_now;
			INSERT INTO group_member VALUES (v_groupid, p_creatorid, p_creatorid, v_now);
			INSERT INTO chat_message VALUES(NULL, p_creatorid, v_groupid, "A csoport létrejött. - A csoport első és automatikus üzenete. Jó szórakozást!", NOW());
			
			BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
			OPEN curz;
				REPEAT
					FETCH curz INTO c_id;
					IF ( ! done ) THEN
						INSERT INTO group_member VALUES(v_groupid, c_id, p_creatorid, v_now);
					END IF;
				UNTIL done END REPEAT;
			CLOSE curz;
			END;
			INSERT INTO chat_history VALUES (v_groupid, CONCAT(v_username, " létrehozta a csoportot. "), NOW());
			SET p_response = "ok";
		ELSE
			SET p_response = CONCAT(p_response, "Hiba történt a csoport tagjainak felvételekor! ");
		END IF;
	END IF;
	
	IF(p_response = "ok") THEN
    	COMMIT;
    ELSE
    	ROLLBACK;
    END IF;
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_quiz` (IN `p_title` VARCHAR(100) CHARSET utf8, IN `p_description` VARCHAR(1000) CHARSET utf8, IN `p_reason` VARCHAR(150) CHARSET utf8, IN `p_language` INT, IN `p_accessquiz` INT, IN `p_numofplaying` INT, IN `p_questions` INT, IN `p_acceptquestion` INT, IN `p_seconds` INT, IN `p_showcorrect` INT, IN `p_startd` VARCHAR(15) CHARSET utf8, IN `p_endd` VARCHAR(15) CHARSET utf8, IN `p_creatoruser` VARCHAR(30) CHARSET utf8, IN `p_anonymus` INT, IN `p_password` VARCHAR(128) CHARSET utf8, IN `p_verify` INT, IN `p_passdegree` INT, IN `p_accessquiz_array` VARCHAR(9000) CHARSET utf8, IN `p_acceptquestion_array` VARCHAR(9000) CHARSET utf8, OUT `p_response` VARCHAR(9999) CHARSET utf8)  MODIFIES SQL DATA
BEGIN	
	DECLARE v_talalatok INT;
	DECLARE v_rang INT;
	DECLARE v_szabad INT;
	
	DECLARE v_quizid INT;
	
	DECLARE c_id INT;
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE cc_id INT;
	DECLARE done1 BOOLEAN DEFAULT 0;
	DECLARE curz CURSOR FOR SELECT id FROM user WHERE FIND_IN_SET(id, p_accessquiz_array) AND id IN ( SELECT f.id1 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = p_creatoruser AND f.status = 1 UNION SELECT f.id2 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = p_creatoruser AND f.status = 1);
	DECLARE curz1 CURSOR FOR SELECT id FROM user WHERE FIND_IN_SET(id, p_acceptquestion_array) AND id IN ( SELECT f.id1 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = p_creatoruser AND f.status = 1 UNION SELECT f.id2 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = p_creatoruser AND f.status = 1);
	
START TRANSACTION;
	SET p_response = "";
	SELECT lawtocreatequiz INTO v_szabad FROM user WHERE user = p_creatoruser;
	IF(v_szabad != 1) THEN
		SET p_response = CONCAT(p_response, "Nincs jogod kvízt beküldeni! ");
	END IF;
	IF(LENGTH(p_title) < 1 OR LENGTH(p_title) > 100) THEN
		SET p_response = CONCAT(p_response, "A cím hossza maximum 100 karakter lehet! ");
	END IF;
	SELECT COUNT(quiz_name) INTO v_talalatok FROM thema WHERE quiz_name = p_title AND is_deleted = 0;
	IF(v_talalatok > 0) THEN
		SET p_response = CONCAT(p_response, "Quiz already existis! ");
	END IF;
	IF(LENGTH(p_description) < 1 OR LENGTH(p_description) > 999) THEN
		SET p_response = CONCAT(p_response, "A leírás hossza maximum 1000 karakter lehet! ");
	END IF;
	IF(LENGTH(p_reason) < 1 OR LENGTH(p_reason) > 150) THEN
		SET p_response = CONCAT(p_response, "Az ok hossza maximum 150 karakter lehet! ");
	END IF;
	IF(p_passdegree < 10 OR p_passdegree > 100) THEN
		SET p_response = CONCAT(p_response, "Az átmenés minimum 10% és max 100% lehet! ");
	END IF;
	IF(p_language != 1 AND p_language != 2) THEN
		SET p_response = CONCAT(p_response, "Hiba a nyelv kiválasztásánál! ");
	END IF;
	IF(p_accessquiz != 1 AND p_accessquiz != 2 AND p_accessquiz != 3 AND p_accessquiz != 4 AND p_accessquiz != 5) THEN
		SET p_response = CONCAT(p_response, "Hiba a kvíz elérhetőség kiválasztásánál! ");
	END IF;
	SELECT level INTO v_rang FROM user WHERE user = p_creatoruser;
	IF(v_rang < 5 AND p_accessquiz = 4) THEN
		SET p_response = CONCAT(p_response, "Ezen a szinten NINCS jogod jelszavas védelmet beállítani a teszten! ");
	END IF;
	IF(LENGTH(p_password) > 128 AND p_accessquiz = 4) THEN
		SET p_response = CONCAT(p_response, "A jelszó hossza nagyobb mint 128 karakter! ");
	END IF;
	IF(p_numofplaying != 1 AND p_numofplaying != 2 AND p_numofplaying != 3 AND p_numofplaying != 4 AND p_numofplaying != 5 AND p_numofplaying != 6) THEN
		SET p_response = CONCAT(p_response, "Hiba a kvízen való részvétel kiválasztásánál! ");
	END IF;
	IF(p_questions < 13 OR p_questions > 45 OR LENGTH(p_questions) < 1) THEN
		SET p_response = CONCAT(p_response, "A játékonkénti kérdésszám 13-45 között lehet! ");
	END IF;
	IF(p_acceptquestion != 1 AND p_acceptquestion != 2 AND p_acceptquestion != 3 AND p_acceptquestion != 4 AND p_acceptquestion != 5) THEN
		SET p_response = CONCAT(p_response, "Hiba a kérdés fogadás kiválasztásánál! ");
	END IF;
	IF(p_seconds < 15 OR p_seconds > 99) THEN
		SET p_response = CONCAT(p_response, "A másodperc értéke 15-99 között lehet! ");
	END IF;
	IF(p_showcorrect != 1 AND p_showcorrect != 2) THEN
		SET p_response = CONCAT(p_response, "Hiba a helyes válaszok mutatása kiválasztásánál! ");
	END IF;
	IF(p_verify < 0 OR p_verify > 1000000) THEN
		SET p_response = CONCAT(p_response, "A kvíz ellenőrzési lehetőségei 0 és 1000000 közti érték lehet! ");
	END IF;
	IF(v_rang < 5 AND p_anonymus = 1) THEN
		SET p_response = CONCAT(p_response, "Ezen a szinten NINCS jogod Anonymusként létrehozni a kvízt! ");
	END IF;
	IF(DATEDIFF(p_startd, NOW()) < 0) THEN
		SET p_response = CONCAT(p_response, "A kezdő dátum nem lehet kisebb a mai dátumnál! ");
	END IF;
	IF(DATEDIFF(p_endd, NOW()) < 0) THEN
		SET p_response = CONCAT(p_response, "A második dátum nem lehet kisebb a mai dátumnál! ");
	END IF;
	IF(DATEDIFF(p_endd, p_startd) < 1) THEN
		SET p_response = CONCAT(p_response, "A két dátum között legalább 1 nap legyen! ");
	END IF;
	IF(LENGTH(p_startd) < 1) THEN
		SET p_startd = NULL;
	END IF;
	IF(LENGTH(p_endd) < 1) THEN
		SET p_endd = NULL;
	END IF;
	IF(LENGTH(p_password) < 1) THEN
		SET p_password = NULL;
	END IF;
	IF(p_numofplaying = 4) THEN
		SET p_numofplaying = 5;
	ELSEIF(p_numofplaying = 5) THEN
		SET p_numofplaying = 10;
	ELSEIF(p_numofplaying = 6) THEN
		SET p_numofplaying = 0;
	END IF;
	
	IF(p_response = "" AND v_szabad = 1) THEN
		INSERT INTO thema VALUES(NULL, p_title, p_description, 0, p_language, 1, 0, p_questions, ROUND(p_questions*1.45, 0), p_acceptquestion, p_showcorrect, p_seconds, p_numofplaying, p_accessquiz, p_startd, p_endd, p_creatoruser, p_creatoruser, NOW(), NULL, NULL, p_reason, p_anonymus, 0, p_password, 0, NULL, NULL, p_verify, p_passdegree);
		INSERT INTO log_data VALUES (NULL, 13, p_creatoruser, CONCAT("A/Az ", p_title, " témájú kvíz adatait sikeresen elküldted. Ennek jóváhagyásáról, és a további tennivalókról értesíteni fogunk! "), 'SYSTEM', NOW(), 0);
		
		SELECT id_number INTO v_quizid FROM thema WHERE quiz_name = p_title AND requested_by = p_creatoruser AND accomplished_by = p_creatoruser AND description = p_description ORDER BY request_date DESC LIMIT 1;
		
		IF(p_accessquiz = 2) THEN
			BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
			OPEN curz;
				REPEAT
					FETCH curz INTO c_id;
					IF ( ! done ) THEN
						INSERT INTO permission_play_quiz VALUES(c_id, v_quizid);
					END IF;
				UNTIL done END REPEAT;
			CLOSE curz;
			END;
		END IF;
		
		IF(p_acceptquestion = 3) THEN
			BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done1 = 1;
			OPEN curz1;
				REPEAT
					FETCH curz1 INTO cc_id;
					IF ( ! done1 ) THEN
						INSERT INTO permission_submit_question VALUES(cc_id, v_quizid);
					END IF;
				UNTIL done1 END REPEAT;
			CLOSE curz1;
			END;
		END IF;
		
		SET p_response = "Sikeres művelet!";
	END IF;
	IF(p_response = "Sikeres művelet!") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_request` (IN `p_title` VARCHAR(50) CHARSET utf8, IN `p_description` VARCHAR(1000) CHARSET utf8, IN `p_pointsoffered` INT, IN `p_language` INT, IN `p_questions` INT, IN `p_questionrequired` INT, IN `p_seconds` INT, IN `p_showcorrect` INT, IN `p_requestedby` VARCHAR(30) CHARSET utf8, IN `p_anonymus` INT, OUT `p_response` VARCHAR(9999) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_talalatok INT;
	DECLARE v_rang INT;
	DECLARE v_ok VARCHAR(35);
	DECLARE v_pontok INT;
	DECLARE v_userid INT;
	DECLARE v_keresid INT;
	DECLARE v_lawtouserequests INT;
START TRANSACTION;
	SET p_response = "";
	SELECT points, lawtouserequests INTO v_pontok, v_lawtouserequests FROM user WHERE user=p_requestedby;
	IF(v_lawtouserequests != 1) THEN
		SET p_response = CONCAT(p_response, "Ez a funkció számodra nem megengedett! ");
	END IF;
	IF(p_pointsoffered > v_pontok) THEN
		SET p_response = CONCAT(p_response, "A felajánlott pontok száma nem lehet nagyobb a jelenlegi pontszámodnál! ");
	END IF;
	IF(p_pointsoffered < 100 OR p_pointsoffered > 10000000) THEN
		SET p_response = CONCAT(p_response, "A felajánlott pontok száma 100 és 10.000.000 között kell legyen! ");
	END IF;
	SET v_ok = "Kérés teljesítés";
	IF(LENGTH(p_title) < 1 OR LENGTH(p_title) > 50) THEN
		SET p_response = CONCAT(p_response, "A cím hossza maximum 50 karakter lehet! ");
	END IF;
	SELECT COUNT(quiz_name) INTO v_talalatok FROM thema WHERE quiz_name = p_title;
	IF(v_talalatok > 0) THEN
		SET p_response = CONCAT(p_response, "Request or Quiz already existis! ");
	END IF;
	IF(LENGTH(p_description) < 1 OR LENGTH(p_description) > 999) THEN
		SET p_response = CONCAT(p_response, "A leírás hossza maximum 1000 karakter lehet! ");
	END IF;
	IF(p_language != 1 AND p_language != 2) THEN
		SET p_response = CONCAT(p_response, "Hiba a nyelv kiválasztásánál! ");
	END IF;
	IF(p_questions < 13 OR p_questions > 45 OR LENGTH(p_questions) < 1) THEN
		SET p_response = CONCAT(p_response, "A játékonkénti kérdésszám 13-45 között lehet! ");
	END IF;
	IF(p_questionrequired = -1) THEN
		IF(LENGTH(p_questionrequired) > 2) THEN
			SET p_response = CONCAT(p_response, "Az általad minimálisan kért kérdésszám maximum 99 lehet! ");
		END IF;
	END IF;
	IF(p_seconds < 15 OR p_seconds > 99) THEN
		SET p_response = CONCAT(p_response, "A másodperc értéke 15-99 között lehet! ");
	END IF;
	IF(p_showcorrect != 1 AND p_showcorrect != 2) THEN
		SET p_response = CONCAT(p_response, "Hiba a helyes válaszok mutatása kiválasztásánál! ");
	END IF;
	SELECT level INTO v_rang FROM user WHERE user = p_requestedby;
	IF(v_rang < 5 AND p_anonymus = 1) THEN
		SET p_response = CONCAT(p_response, "Ezen a szinten NINCS jogod Anonymusként kvízt kérni! ");
	END IF;
	IF(p_questionrequired = -1 OR p_questionrequired < -1) THEN
		SET p_questionrequired = NULL;
	END IF;
	IF(p_response = "") THEN
		INSERT INTO thema VALUES(NULL, p_title, p_description, 0, p_language, 1, 1, p_questions, ROUND(p_questions*1.45, 0), 4, p_showcorrect, p_seconds, 0, 3, NULL, NULL, p_requestedby, NULL, NOW(), NULL, p_questionrequired, v_ok, 0, p_anonymus, NULL, 0, NULL, NULL, 1, 50);
		INSERT INTO log_data VALUES (NULL, 18, p_requestedby, CONCAT("A/Az ", p_title, " témájú kérésedet sikeresen rögzítettük. Ennek jóváhagyásáról értesíteni fogunk! "), 'SYSTEM', NOW(), 0);
		UPDATE user SET points = points - p_pointsoffered WHERE user = p_requestedby;
		SELECT id INTO v_userid FROM user WHERE user = p_requestedby;
		SELECT COUNT(*) INTO v_keresid FROM thema WHERE quiz_name = p_title AND requested_by = p_requestedby AND description = p_description ORDER BY request_date DESC LIMIT 1;
		IF(v_keresid = 1) THEN
			SELECT id_number INTO v_keresid FROM thema WHERE quiz_name = p_title AND requested_by = p_requestedby AND description = p_description ORDER BY request_date DESC LIMIT 1;
			INSERT INTO request_vote VALUES(v_userid, v_keresid, p_pointsoffered, NOW());
		ELSE
			SET p_response = CONCAT(p_response, "Hiba történt! Kérjük próbálja meg újra beküldeni a kérést! ");
		END IF;
	END IF;
	IF(p_response = "") THEN
		SET p_response = "Sikeres művelet!";
		COMMIT;
	ELSE
		ROLLBACK;
		SET p_response = CONCAT(p_response, "Hiba történt! Nem sikerült elküldeni a kérést! ");
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_chatgroup` (IN `p_groupid` INT, IN `p_adminid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_csoport INT;
	DECLARE v_tagjae INT;
	DECLARE v_db INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_csoportnev VARCHAR(100);
START TRANSACTION;
	SET p_response = "";
	IF(p_groupid < 2) THEN
		SET p_response = CONCAT(p_response, "Hibás csoport azonosító! ");
	END IF;
	IF(p_adminid < 1) THEN
		SET p_response = CONCAT(p_response, "Hibás csoportadmin azonosító! ");
	END IF;
	
	SELECT COUNT(*) INTO v_db FROM user WHERE deleteduser = 0 AND id = p_adminid;
	IF(v_db != 1) THEN
		SET p_response = CONCAT(p_response, "Törölt felhasználó! ");
	END IF;
	
	SELECT COUNT(*) INTO v_csoport FROM chat_group WHERE id = p_groupid AND is_deleted = 0 AND group_creator = p_adminid;
	IF(v_csoport = 1) THEN
		SELECT COUNT(*) INTO v_tagjae FROM group_member WHERE group_id = p_groupid AND user_id = p_adminid;
		IF(v_tagjae = 1) THEN
			SELECT user INTO v_username FROM user WHERE id = p_adminid;
			SELECT group_name INTO v_csoportnev FROM chat_group WHERE id = p_groupid;
			IF(p_response = "") THEN
				UPDATE chat_group SET is_deleted = 1 WHERE id = p_groupid AND group_creator = p_adminid;
				DELETE FROM group_member WHERE group_id = p_groupid;
				INSERT INTO chat_history VALUES (p_groupid, CONCAT(v_username, " törölte a csoportot. "), NOW());
			ELSE
				SET p_response = CONCAT(p_response, "Nem sikerűlt végrehajtani a műveletet! ");
			END IF;
				
		ELSE
			SET p_response = CONCAT(p_response, "Nem vagy tagja a csoportnak! ");
		END IF;
	ELSE
		SET p_response = CONCAT(p_response, "Hiba történt! Lehetséges okok: nem vagy a csoport adminja, vagy a csoportot törölték! ");
	END IF;
	
	IF(p_response = "") THEN
    	COMMIT;
    ELSE
    	ROLLBACK;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_competition` (IN `p_competitionid` INT, IN `p_adminid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darab INT;
	DECLARE v_startdate DATETIME;
	DECLARE v_enddate DATETIME;
	DECLARE v_admin INT;
	DECLARE v_activity INT;
	
START TRANSACTION;
	SET p_response = '';
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;	
		
	SELECT COUNT(*) INTO v_darab FROM competition WHERE id = p_competitionid;
	IF(v_darab = 1) THEN
		SELECT startdate, enddate, activity INTO v_startdate, v_enddate, v_activity FROM competition WHERE id = p_competitionid;
		IF(v_startdate <= NOW()) THEN
			SET p_response = 'A törlés nem megengedett, mert a verseny már elkezdődött!';
		END IF;
		IF(v_enddate <= NOW()) THEN
			SET p_response = 'A törlés nem megengedett, mert a verseny már véget ért!';
		END IF;
		
		IF(p_response = '') THEN
			DELETE FROM competition WHERE id = p_competitionid;
			SET p_response = 'ok';
		ELSE
			SET p_response = CONCAT(p_response, 'Nem sikerült törölni a versenyt! ');
		END IF;
	ELSE
		SET p_response = 'Nem található ilyen azonosítójú verseny!';
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_friendship` (IN `p_friendid` INT, IN `p_username` VARCHAR(25) CHARSET utf8, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
    DECLARE v_id1 INT;
    DECLARE v_id2 INT;
    DECLARE v_statusz INT;
    DECLARE v_sorszam INT DEFAULT 0;
    DECLARE v_szam INT;
    DECLARE v_friendname VARCHAR(30);
	
START TRANSACTION;
    SET p_response = "";
    SELECT user INTO v_friendname FROM user WHERE id = p_friendid;
    IF(is_realuser(v_friendname) = 1 AND is_realuser(p_username) = 1 AND v_friendname != p_username) THEN
        SELECT id INTO v_id1 FROM user WHERE user = v_friendname;
        SELECT id INTO v_id2 FROM user WHERE user = p_username;
        SELECT COUNT(*) INTO v_sorszam FROM friend WHERE (id1 = v_id1 AND id2 = v_id2) OR (id2 = v_id1 AND id1 = v_id2);
        IF(v_sorszam = 1) THEN      
            
			SELECT status INTO v_statusz FROM friend WHERE (id1 = v_id1 AND id2 = v_id2) OR (id2 = v_id1 AND id1 = v_id2);     
			IF(v_statusz = 0) THEN
				SET p_response = "Nem törölheted ezt a felhasználót a listádról, mert nem vagytok barátok!";
			ELSEIF(v_statusz = 1) THEN
				DELETE FROM friend WHERE (id1 = v_id1 AND id2 = v_id2) OR (id2 = v_id1 AND id1 = v_id2);
				SET p_response = "ok";
			ELSE
				SET p_response = "Ezt a felhasználót letiltottad!";
			END IF;
            
            
        ELSEIF(v_sorszam = 0) THEN
            SET p_response = "Hiba történt! Hibás adatok!";
        ELSE
            SET p_response = "Error! Too many rows exception";
        END IF;
    
    ELSE
        SET p_response = "Hiba történt! Hibás adatok! Próbáld újra később!";
    END IF;

	IF(p_response = "ok") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_news` (IN `p_userid` INT, IN `p_newsid` INT, IN `p_reason` VARCHAR(100) CHARSET utf8, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_isadmin INT;
	DECLARE v_sajathir INT;
	DECLARE v_hircim VARCHAR(50);
	DECLARE v_username VARCHAR(30);
	DECLARE v_hirkozzetevoje VARCHAR(30);
START TRANSACTION;
	SET p_response = "";
	IF(LENGTH(p_reason)< 5 OR LENGTH(p_reason) > 100) THEN
		SET p_response = "A törlés oka 5-100 karakterből állhat!";
	END IF;
	SELECT COUNT(*) INTO v_isadmin FROM user WHERE id = p_userid AND deleteduser = 0;
	IF(v_isadmin = 1) THEN
		SELECT adminuser, user INTO v_isadmin, v_username FROM user WHERE id = p_userid;
		SELECT COUNT(*) INTO v_sajathir FROM news WHERE id = p_newsid;
		IF(v_sajathir = 1) THEN
			SELECT publisher_id, title INTO v_sajathir, v_hircim FROM news WHERE id = p_newsid;
			SELECT user INTO v_hirkozzetevoje FROM user WHERE id = v_sajathir;
			IF(p_response = "" AND (v_isadmin = 1 OR v_sajathir = p_userid)) THEN
				UPDATE news SET is_deleted = 1, deleted_by = p_userid, deletion_reason = p_reason, deletion_time = NOW() WHERE id = p_newsid;
				INSERT INTO log_data VALUES(NULL, 7, v_hirkozzetevoje, CONCAT("A/Az ", v_hircim, " hírt törölték. Ennek oka: ", p_reason), v_username, NOW(), 0);
			ELSE
				SET p_response = "A hírt csak a közzétevője, vagy az adminok törölhetik!";
			END IF;
		ELSE
			SET p_response = "Hibás hir azonosító!";
		END IF;
		
	ELSE
		SET p_response = "Hibás user azonosító!";
	END IF;
	
	IF(p_response = "") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_question_permanently` (IN `p_id` INT, IN `p_adminid` INT, OUT `p_response` VARCHAR(3000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darab INT;
	DECLARE v_allactivequestion INT;
	DECLARE v_quizid INT;
	DECLARE v_phase INT;
	DECLARE v_numofquestion INT;
	DECLARE v_admin INT;
START TRANSACTION;
	SET p_response = '';
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;
	SELECT COUNT(*) INTO v_darab FROM quiz_question WHERE id = p_id AND is_active = 0;
	IF(v_darab = 1) THEN
		SELECT quiz_id INTO v_quizid FROM quiz_question WHERE id = p_id;
		SELECT num_of_question, phase INTO v_numofquestion, v_phase FROM thema WHERE id_number = v_quizid;
		SELECT COUNT(*) INTO v_allactivequestion FROM quiz_question WHERE quiz_id = v_quizid AND is_active = 1; 
		
		IF(v_phase = 3) THEN
			IF(v_numofquestion >= v_allactivequestion - 1) THEN
				SET p_response = 'Hiba! A művelet nem hajtható végre, mert nem maradna elég aktív kérdés a kvízen való részvételhez.';
			END IF;
		END IF;
		IF(p_response = '') THEN
			DELETE FROM question_comment WHERE question_id = p_id;
			DELETE FROM quiz_question WHERE id = p_id;
			SET p_response = 'ok';
		END IF;
	ELSE
		SET p_response = 'A kérdés nem törölhető, mert jelenleg aktív, vagy nem található ilyen azonosítójú kérdés!';
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_quiz_comment` (IN `p_username` VARCHAR(30) CHARSET utf8, IN `p_quizid` INT, IN `p_comment` VARCHAR(3000) CHARSET utf8, IN `p_date` DATETIME, OUT `p_message` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_username VARCHAR(30);
	DECLARE v_uid INT DEFAULT 0;
	DECLARE v_db INT;
	DECLARE v_torolve INT;
START TRANSACTION;
	SET p_message = "";
	SELECT COUNT(id) INTO v_db FROM user WHERE user = p_username AND deleteduser = 0;
	IF(v_db != 1) THEN
		SET p_message = CONCAT(p_message, "User ID error");
	ELSE
		SELECT id INTO v_uid FROM user WHERE user = p_username;
	END IF;
	IF(STR_TO_DATE(p_date, '%Y-%m-%d %H:%i:%s') IS NULL) THEN
		SET p_message = CONCAT(p_message, "Invalid comment time! ");
	END IF;
	SELECT COUNT(*) INTO v_db FROM quiz_comment WHERE user_id = v_uid AND quiz_id = p_quizid AND comment_text = p_comment AND comment_date = p_date;
	IF(v_db != 1) THEN
		SET p_message = CONCAT(p_message, "No such message");
	ELSE
		SELECT is_deleted INTO v_torolve FROM quiz_comment WHERE user_id = v_uid AND quiz_id = p_quizid AND comment_text = p_comment AND comment_date = p_date;
		IF(v_torolve = 1) THEN
			SET p_message = CONCAT(p_message, "Ezt a hozzászólásodat már törölted!");
		END IF;
	END IF;
	
	IF(p_message = "") THEN
		UPDATE quiz_comment SET is_deleted = 1 WHERE user_id = v_uid AND quiz_id = p_quizid AND comment_text = p_comment AND comment_date = p_date;
	END IF;
	
	IF(p_message = "") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_request` (IN `p_requestid` INT, IN `p_user` VARCHAR(30) CHARSET utf8, IN `p_delreason` VARCHAR(150) CHARSET utf8, OUT `p_response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_cim VARCHAR(150);
	DECLARE v_darab INT;
	DECLARE v_isrequest INT;
	DECLARE v_phase INT;
	DECLARE v_elvallalva INT;
	DECLARE v_kikerte VARCHAR(30);
	
	DECLARE c_usernev VARCHAR(30);
	DECLARE c_user INT;
	DECLARE c_pontok INT;
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE curz1 CURSOR FOR SELECT DISTINCT user_id, SUM(offered_points) FROM request_vote WHERE quiz_id = p_requestid GROUP BY user_id;        
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
	
START TRANSACTION;
	SET p_response = "";
	IF(LENGTH(p_delreason) < 5 OR LENGTH(p_delreason) > 150) THEN
		SET p_response = CONCAT(p_response, "Az ok mező hossza 5-150 között legyen!");
	END IF;
	SELECT COUNT(id_number) INTO v_darab FROM thema WHERE id_number = p_requestid AND is_deleted = 0;
	IF(v_darab != 1) THEN
		SET p_response = CONCAT(p_response, "Hibás kérés azonosító! ");
	ELSE
		SELECT quiz_name INTO v_cim FROM thema WHERE id_number = p_requestid;
		SELECT is_request, phase, is_undertaken, requested_by INTO v_isrequest, v_phase, v_elvallalva, v_kikerte FROM thema WHERE id_number = p_requestid;
		IF(v_phase != 2) THEN
			SET p_response = CONCAT(p_response, "A kérés nem törölhető, mert még nincs ellenőrizve, vagy már teljesítve lett! ");
		END IF;
		IF(v_elvallalva != 0) THEN
			SET p_response = CONCAT(p_response, "A kérés nem törölhető, mert már jelentkezetek ennek teljesítésére! ");
		END IF;
		IF(v_kikerte != p_user) THEN
			SET p_response = CONCAT(p_response, "A kérés nem törölhető, mert ez nem a te kérésed! ");
		END IF;
		IF(v_phase = 2 AND v_isrequest = 1 AND v_elvallalva = 0 AND v_kikerte = p_user AND p_response = "") THEN
			UPDATE thema SET is_deleted = 1 WHERE id_number = p_requestid;
			OPEN curz1;
			REPEAT
				FETCH curz1 INTO c_user, c_pontok;
				IF ( ! done ) THEN
					UPDATE user SET points = points + c_pontok WHERE id = c_user;
					SELECT user INTO c_usernev FROM user WHERE id = c_user;
					INSERT INTO log_data VALUES (NULL, 24, c_usernev, CONCAT("Az általad (is) kért ", v_cim, " nevű kérés törölve lett! Ok: ", p_delreason, " A kérésre összesen ", c_pontok, " pontot szántál, melyet ezennel visszaadunk!"), "SYSTEM", NOW(), 0);
				END IF;
			UNTIL done END REPEAT;
			CLOSE curz1;
			DELETE FROM request_vote WHERE quiz_id = p_requestid;
		ELSE
			SET p_response = CONCAT(p_response, "Valami hiba törtent! ");
		END IF;
	END IF;
	IF(p_response = "") THEN
		SET p_response = "Sikeres művelet!";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `enable_user` (IN `p_username` VARCHAR(25) CHARSET utf8, IN `p_friendid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
    DECLARE v_id1 INT;
    DECLARE v_id2 INT;
    DECLARE v_statusz INT;
    DECLARE v_sorszam INT DEFAULT 0;
    DECLARE v_szam INT;
    DECLARE v_friendname VARCHAR(30);
	
START TRANSACTION;
    SET p_response = "";
    SELECT user INTO v_friendname FROM user WHERE id = p_friendid;
    IF(is_realuser(p_username) = 1 AND is_realuser(v_friendname) = 1 AND p_username != v_friendname) THEN
        SELECT id INTO v_id1 FROM user WHERE user = p_username;
        SELECT id INTO v_id2 FROM user WHERE user = v_friendname;
        SELECT COUNT(*) INTO v_sorszam FROM friend WHERE id1 = v_id1 AND id2 = v_id2;
        IF(v_sorszam = 1) THEN      
            
			SELECT status INTO v_statusz FROM friend WHERE id1 = v_id1 AND id2 = v_id2;     
			IF(v_statusz = 0) THEN
				SET p_response = "Ez a felhasználó nincs a tiltólistán!";
			ELSEIF(v_statusz = 1) THEN
				SET p_response = "Jelenleg barátok vagytok!";
			ELSE
				DELETE FROM friend WHERE id1 = v_id1 AND id2 = v_id2;
				SET p_response = "ok";
			END IF;
            
            
        ELSEIF(v_sorszam = 0) THEN
            SET p_response = "Hiba történt! Hibás adatok!";
        ELSE
            SET p_response = "Error! Too many rows exception";
        END IF;
    
    ELSE
        SET p_response = "Hiba történt! Hibás adatok! Próbáld újra később!";
    END IF;

	IF(p_response = "ok") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `exit_from_chatgroup` (IN `p_groupid` INT, IN `p_memberid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_csoport INT;
	DECLARE v_tagjae INT;
	DECLARE v_admin INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_csoportnev VARCHAR(100);
START TRANSACTION;
	SET p_response = "";
	IF(p_groupid < 2) THEN
		SET p_response = CONCAT(p_response, "Hibás csoport azonosító! ");
	END IF;
	IF(p_memberid < 1) THEN
		SET p_response = CONCAT(p_response, "Hibás felhasználó azonosító! ");
	END IF;
	
	SELECT COUNT(*) INTO v_csoport FROM chat_group WHERE id = p_groupid AND is_deleted = 0;
	IF(v_csoport = 1) THEN
		SELECT COUNT(*) INTO v_tagjae FROM group_member WHERE group_id = p_groupid AND user_id = p_memberid;
		IF(v_tagjae = 1) THEN
			SELECT group_creator INTO v_admin FROM chat_group WHERE id = p_groupid;
			IF(v_admin != p_memberid) THEN
				SELECT user INTO v_username FROM user WHERE id = p_memberid;
				SELECT group_name INTO v_csoportnev FROM chat_group WHERE id = p_groupid;
				IF(p_response = "") THEN
					DELETE FROM group_member WHERE group_id = p_groupid AND user_id = p_memberid;
					INSERT INTO chat_history VALUES (p_groupid, CONCAT(v_username, " kilépett a csoportból. "), NOW());
				ELSE
					SET p_response = CONCAT(p_response, "Nem sikerűlt végrehajtani a műveletet! ");
				END IF;
			ELSE
				SET p_response = CONCAT(p_response, "Mint a csoport adminisztrátora - nem hagyhatod el a csoportot! ");
			END IF;
			
		ELSE
			SET p_response = CONCAT(p_response, "Nem vagy tagja a csoportnak! ");
		END IF;
	ELSE
		SET p_response = CONCAT(p_response, "Hiba történt! Lehetséges okok: a csoportot törölték! ");
	END IF;
	
	IF(p_response = "") THEN
    	COMMIT;
    ELSE
    	ROLLBACK;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `failed_request_fulfillment` (IN `p_requestid` INT, IN `p_adminusername` VARCHAR(30) CHARSET utf8, OUT `response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_admin INT;
	DECLARE v_requestcount INT;
	DECLARE v_fazis INT;
	DECLARE v_elvallalva INT;
	DECLARE v_meddigteljesitheti DATETIME;
	DECLARE v_osszeskerdes INT;
	DECLARE v_osszesellenorzott INT;
	DECLARE v_kivallalta VARCHAR(30);
	DECLARE v_useraltalkert INT;
	DECLARE v_rendszeraltalkert INT;
	DECLARE v_nagyobb INT;
	DECLARE v_userid INT;
	DECLARE v_temanev VARCHAR(150);
	DECLARE p_user VARCHAR(25);
START TRANSACTION;
	SET response = "";
	SELECT COUNT(*) INTO v_admin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET response = CONCAT(response, "Hibás Admin azonosító! ");
	END IF;
	SELECT COUNT(id_number) INTO v_requestcount FROM thema WHERE id_number = p_requestid AND is_request = 1;
	IF(v_requestcount != 1) THEN
		SET response = CONCAT(response, "Hibás kérés azonosító! ");
	ELSE
		SELECT quiz_name, phase, is_undertaken, accomplish_deadline, undertaken_by, minimum_requested_quest, byuser_minreq_quest INTO v_temanev, v_fazis, v_elvallalva, v_meddigteljesitheti, v_kivallalta, v_rendszeraltalkert, v_useraltalkert FROM thema WHERE id_number = p_requestid;
		SELECT id INTO v_userid FROM user WHERE user = v_kivallalta;
		SET p_user = v_kivallalta;
		IF(v_useraltalkert = NULL) THEN
			SET v_nagyobb = v_rendszeraltalkert;
		ELSE
			IF(v_useraltalkert > v_rendszeraltalkert) THEN
				SET v_nagyobb = v_useraltalkert;
			ELSE
				SET v_nagyobb = v_rendszeraltalkert;
			END IF;
		END IF;
		IF(v_fazis != 2) THEN
			SET response = CONCAT(response, "A kérés nincs a 2. fázisban! ");
		END IF;
		IF(v_elvallalva != 1) THEN
			SET response = CONCAT(response, "A kérés teljesítését senki sem vállalta el! ");
		END IF;
		IF(v_meddigteljesitheti >= NOW()) THEN
			SET response = CONCAT(response, "A kérés teljesítési ideje még nem járt le! ");
		END IF;
		SELECT COUNT(*) INTO v_osszeskerdes FROM quiz_question WHERE quiz_id = p_requestid AND username = p_user AND is_verified = 1;
		IF(v_osszeskerdes >= v_nagyobb) THEN
			SET response = CONCAT(response, "A kérésre be lett küldve a kötelező számú kérdés! ");
		END IF;
		SELECT COUNT(*) INTO v_osszesellenorzott FROM quiz_question WHERE quiz_id = p_requestid AND username = p_user AND is_verified IS NULL;
		IF(v_osszesellenorzott > 0) THEN
			SET response = CONCAT(response, CONCAT("Még maradt ", v_osszesellenorzott, " db kérdés, amely még nem volt leellenőrizve. A teljesítés elutasításához ellenőrizni kell ezeket! "));
		END IF;
		IF(response = "" AND v_meddigteljesitheti < NOW() AND v_osszeskerdes < v_nagyobb) THEN
			UPDATE thema SET is_undertaken = 0, undertaken_by = NULL, accomplish_deadline = NULL, anonymus_accomplish = 0 WHERE id_number = p_requestid;
			UPDATE undertaken_request SET status = -1 WHERE request_id = p_requestid AND user_id = v_userid;
			INSERT INTO log_data VALUES(NULL, 22, p_user, CONCAT("Nem teljesítetted a kért határidőn belül a ", v_temanev, " nevű kérést, amelyet elvállaltál! Nincs több lehetőséged teljesíteni ezt a kérést. Az ebben a témában beküldött kérdéseidet töröltük és visszavontuk az értük kapott pontokat."), p_adminusername, NOW(), 0);
			UPDATE quiz_question SET is_verified = 3 WHERE username = p_user AND quiz_id = p_requestid;
			UPDATE user SET points = points - (v_osszeskerdes*15) WHERE user = p_user;
		END IF;
	END IF;
	
	IF(response = "") THEN
		SET response = "ok";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `friendship_action` (IN `p_friendid` INT, IN `p_username` VARCHAR(30) CHARSET utf8, IN `p_action` INT, OUT `p_message` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
    DECLARE v_id1 INT;
    DECLARE v_id2 INT;
    DECLARE v_statusz INT;
    DECLARE v_sorszam INT DEFAULT 0;
    DECLARE v_szam INT;
	DECLARE v_friendname VARCHAR(30);
	
START TRANSACTION;
    SET p_message = "";
	SELECT user INTO v_friendname FROM user WHERE id = p_friendid;
    IF(is_realuser(v_friendname) = 1 AND is_realuser(p_username) = 1 AND v_friendname != p_username) THEN
        SELECT id INTO v_id1 FROM user WHERE user = v_friendname;
        SELECT id INTO v_id2 FROM user WHERE user = p_username;
        SELECT COUNT(*) INTO v_sorszam FROM friend WHERE id1 = v_id1 AND id2 = v_id2;
        IF(v_sorszam = 1) THEN      
            
			SELECT status INTO v_statusz FROM friend WHERE id1 = v_id1 AND id2 = v_id2;     
			IF(v_statusz = 0) THEN
				IF(p_action = 1) THEN
					UPDATE friend SET status = 1 WHERE id1 = v_id1 AND id2 = v_id2;
					INSERT INTO log_data VALUES (NULL, 29, v_friendname, CONCAT("Visszaigazoltak barátnak: a/az ", p_username, " nevű felhasználó!"), "SYSTEM", NOW(), 0);
					SET p_message = "ok1";
				ELSEIF(p_action = 0) THEN
					DELETE FROM friend WHERE id1 = v_id1 AND id2 = v_id2;
					SET p_message = "ok0";
				ELSE
					SET p_message = "Hibás művelet azonosító!";
				END IF;
			ELSEIF(v_statusz = 1) THEN
				SET p_message = "Jelenleg barátok vagytok!";
			ELSE
				SET p_message = "Ezt a felhasználót letiltottad!/Tiltva vagy nála.";
			END IF;
            
            
        ELSEIF(v_sorszam = 0) THEN
            SET p_message = "Hiba történt! Hibás adatok!";
        ELSE
            SET p_message = "Error! Too many rows exception";
        END IF;
    
    ELSE
        SET p_message = "Hiba történt! Hibás adatok! Próbáld újra később!";
    END IF;

	IF(p_message = "ok1" OR p_message = "ok0") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_competition_result` (INOUT `totalcorrect` INT, IN `p_testid` INT, IN `p_username` VARCHAR(25) CHARSET utf8, OUT `p_score` DOUBLE)  MODIFIES SQL DATA
BEGIN
	DECLARE bonusz INT DEFAULT 0;
	DECLARE pontszerzesjoga INT;
	DECLARE v_numofQ INT;
	DECLARE v_rew1 INT;
	DECLARE v_rew2 INT;
	DECLARE v_rew3 INT;
	DECLARE v_rew4 INT;
	DECLARE v_rew5 INT;
	DECLARE v_rew6 INT;
	DECLARE v_rew7 INT;
	DECLARE v_startdate DATE;
	DECLARE v_enddate DATE;
	DECLARE v_quizname VARCHAR(200);
	DECLARE v_elsoalkalom INT;
	DECLARE v_userid INT;
	DECLARE v_actquizid INT;
	DECLARE c_id INT;
	DECLARE c_ans1 VARCHAR(150);
	DECLARE c_ans2 VARCHAR(150);
	DECLARE c_ans3 VARCHAR(150);
	DECLARE c_ans4 VARCHAR(150);
	DECLARE c_position INT;
	DECLARE c_correct INT;
	DECLARE c_ownanswer VARCHAR(255);
	DECLARE cc_ownans INT DEFAULT 0;
	DECLARE v_reqquired_atmenes INT;
	DECLARE v_ossznehezseg INT;
	DECLARE v_teljesitett INT;
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE curz1 CURSOR FOR SELECT id, ans1, ans2, ans3, ans4, position, correct, own_answer FROM live_question WHERE user = p_username AND bool = 1;        
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
START TRANSACTION;
	SET v_startdate = DATE_FORMAT(NOW(), '%Y-%m-%d');
	SET v_enddate = DATE_FORMAT(NOW(), '%Y-%m-%d');
	SELECT t.quiz_name, t.num_of_question, c.reward1, c.reward2, c.reward3, c.reward4, c.reward5, c.reward6, c.reward7, t.start_date, t.end_date, t.pass_degree INTO v_quizname, v_numofQ, v_rew1, v_rew2, v_rew3, v_rew4, v_rew5, v_rew6, v_rew7, v_startdate, v_enddate, v_reqquired_atmenes FROM thema t JOIN competition c ON t.id_number = c.quiz_id WHERE c.activity = 1 AND t.id_number = p_testid;
	SELECT id INTO v_userid FROM user WHERE user = p_username;
	SELECT COUNT(quiz_id) INTO v_elsoalkalom FROM quiz_played WHERE user_id = v_userid AND quiz_id = p_testid AND v_startdate <= finishing_date AND v_enddate >= finishing_date;
		
		IF(totalcorrect >=0 && totalcorrect <=v_numofQ) THEN
			UPDATE user SET quizplayed_total = quizplayed_total + 1 WHERE user = p_username;
			SELECT lawtogetpoints INTO pontszerzesjoga FROM user WHERE user = p_username;
			
			SET p_score = 0;
			SELECT SUM(difficulty) INTO v_ossznehezseg FROM live_question WHERE type = p_testid AND user = p_username AND bool = 1;
			SELECT SUM(difficulty) INTO v_teljesitett FROM live_question WHERE type = p_testid AND user = p_username AND bool = 1 AND correct = 1;
			IF(v_ossznehezseg IS NULL) THEN
				SET v_ossznehezseg = 1; /*mert 0-val nem lehet osztani*/
			END IF;
			IF(v_teljesitett IS NULL) THEN
				SET v_teljesitett = 0;
			END IF;
			SET p_score = TRUNCATE((v_teljesitett / v_ossznehezseg)*100, 2);
			
			IF( p_score >= 0 AND p_score <= 20 ) THEN 
				SET bonusz = v_rew7;
			ELSEIF( p_score >= 20 AND p_score <= 36 ) THEN 
				SET bonusz = v_rew6;
			ELSEIF( p_score >= 36 AND p_score <= 51 ) THEN 
				SET bonusz = v_rew5;
			ELSEIF( p_score >= 51 AND p_score <= 74 ) THEN 
				SET bonusz = v_rew4;
			ELSEIF( p_score >= 74 AND p_score <= 84 ) THEN 
				SET bonusz = v_rew3;
			ELSEIF( p_score >= 84 AND p_score <= 94 ) THEN 
				SET bonusz = v_rew2;
			ELSEIF( p_score >= 94 ) THEN 
				SET bonusz = v_rew1;
			END IF;
			
			
			IF(pontszerzesjoga = 1) THEN
				UPDATE user SET points = points + bonusz WHERE user = p_username;
			END IF;
			INSERT INTO log_data VALUES(NULL, 34, p_username, CONCAT("Részvétel a/az ", v_quizname, " nevű kvízen."), "SYSTEM", NOW(), 1);
			INSERT INTO quiz_played VALUES(NULL, v_userid, p_testid, totalcorrect, NOW(), 0, p_score);
			SELECT test_id INTO v_actquizid FROM quiz_played WHERE user_id = v_userid AND quiz_id = p_testid ORDER BY finishing_date DESC LIMIT 1;
			OPEN curz1;
				REPEAT
					FETCH curz1 INTO c_id, c_ans1, c_ans2, c_ans3, c_ans4, c_position, c_correct, c_ownanswer;
					IF ( ! done ) THEN
						IF(c_ownanswer = c_ans1) THEN
							SET cc_ownans = 1;
						ELSEIF(c_ownanswer = c_ans2) THEN
							SET cc_ownans = 2;
						ELSEIF(c_ownanswer = c_ans3) THEN
							SET cc_ownans = 3;
						ELSEIF(c_ownanswer = c_ans4) THEN
							SET cc_ownans = 4;
						END IF;
						IF(c_correct = -1) THEN
							SET cc_ownans = 0;
						END IF;
						INSERT INTO played_quiz_question VALUES (v_actquizid, c_id, c_position, c_correct, cc_ownans);
					END IF;
				UNTIL done END REPEAT;
			CLOSE curz1;
		END IF;
	
	
	DELETE FROM live_question WHERE type = p_testid AND user = p_username;
	SET totalcorrect = bonusz;	

COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_quiz_result` (INOUT `totalcorrect` INT, IN `p_quiztype` INT, IN `p_username` VARCHAR(30) CHARSET utf8, OUT `p_score` DOUBLE)  MODIFIES SQL DATA
BEGIN

DECLARE bonusz INT DEFAULT 0;
DECLARE pontszerzesjoga INT;
DECLARE v_numofQ INT;
DECLARE v_elsoalkalom INT;
DECLARE v_userid INT;
DECLARE v_actquizid INT;
DECLARE c_id INT;
DECLARE c_ans1 VARCHAR(150);
DECLARE c_ans2 VARCHAR(150);
DECLARE c_ans3 VARCHAR(150);
DECLARE c_ans4 VARCHAR(150);
DECLARE c_position INT;
DECLARE c_correct INT;
DECLARE c_ownanswer VARCHAR(255);
DECLARE cc_ownans INT DEFAULT 0;
DECLARE v_reqquired_atmenes INT;
DECLARE v_ossznehezseg INT;
DECLARE v_teljesitett INT;
DECLARE v_answeredquestions INT;
DECLARE done BOOLEAN DEFAULT 0;
DECLARE curz1 CURSOR FOR SELECT id, ans1, ans2, ans3, ans4, position, correct, own_answer FROM live_question WHERE user = p_username AND bool = 1;        
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;

START TRANSACTION;
IF(p_quiztype = 0) THEN
	CASE 
		WHEN totalcorrect < 3 THEN SET bonusz = 0;
		WHEN totalcorrect = 3 THEN SET bonusz = 1;
		WHEN totalcorrect = 4 THEN SET bonusz = 2;
		WHEN totalcorrect = 5 THEN SET bonusz = 3;
		WHEN totalcorrect = 6 THEN SET bonusz = 3;
		WHEN totalcorrect = 7 THEN SET bonusz = 4;
		WHEN totalcorrect = 8 THEN SET bonusz = 5;
		WHEN totalcorrect = 9 THEN SET bonusz = 6;
		WHEN totalcorrect = 10 THEN SET bonusz = 10;
		WHEN totalcorrect > 10 THEN SET bonusz = 0;
	END CASE;
	
	IF(totalcorrect >=0 && totalcorrect <=10) THEN
		UPDATE user SET quizplayed_total = quizplayed_total + 1 WHERE user = p_username;
		SELECT lawtogetpoints INTO pontszerzesjoga FROM user WHERE user = p_username;
		IF(pontszerzesjoga = 1) THEN
			UPDATE user SET points = points + totalcorrect + bonusz WHERE user = p_username;
		END IF;
		IF(totalcorrect = 10) THEN
			UPDATE user SET perfectgames = perfectgames + 1 where user = p_username;
		END IF;
	END IF;
	DELETE FROM live_question WHERE type = -1 AND user = p_username;
	SET totalcorrect = totalcorrect + bonusz;

ELSEIF(p_quiztype = -1) THEN
	CASE 
		WHEN totalcorrect < 3 THEN SET bonusz = 0;
		WHEN totalcorrect = 3 THEN SET bonusz = 1;
		WHEN totalcorrect = 4 THEN SET bonusz = 2;
		WHEN totalcorrect = 5 THEN SET bonusz = 3;
		WHEN totalcorrect = 6 THEN SET bonusz = 3;
		WHEN totalcorrect = 7 THEN SET bonusz = 4;
		WHEN totalcorrect = 8 THEN SET bonusz = 5;
		WHEN totalcorrect = 9 THEN SET bonusz = 6;
		WHEN totalcorrect = 10 THEN SET bonusz = 10;
		WHEN totalcorrect > 10 THEN SET bonusz = 0;
	END CASE;
	
	IF(totalcorrect >=0 && totalcorrect <=10) THEN
		UPDATE user SET help = help - 1 WHERE user = p_username;
		UPDATE user SET quizplayed_total = quizplayed_total + 1 WHERE user = p_username;
		SELECT lawtogetpoints INTO pontszerzesjoga FROM user WHERE user = p_username;
		IF(pontszerzesjoga = 1) THEN
			UPDATE user SET points = points + totalcorrect + bonusz WHERE user = p_username;
		END IF;
		IF(totalcorrect = 10) THEN
			UPDATE user SET perfectgames = perfectgames + 1 where user = p_username;
		END IF;
	END IF;
	DELETE FROM live_question WHERE type = -1 AND user = p_username;
	SET totalcorrect = totalcorrect + bonusz;

ELSEIF(p_quiztype > 0) THEN
	SELECT num_of_question, pass_degree INTO v_numofQ, v_reqquired_atmenes FROM thema WHERE id_number = p_quiztype;
	SELECT id INTO v_userid FROM user WHERE user = p_username;
	SELECT COUNT(quiz_id) INTO v_elsoalkalom FROM quiz_played WHERE user_id = v_userid AND quiz_id = p_quiztype;
	IF(v_elsoalkalom = 0) THEN
		IF( totalcorrect >= v_numofQ * 25/100 AND totalcorrect < v_numofQ * 40/100 ) THEN 
			SET bonusz = FLOOR(v_numofQ * 30/100);
		ELSEIF( totalcorrect >= v_numofQ * 40/100 AND totalcorrect < v_numofQ * 50/100 ) THEN 
			SET bonusz = FLOOR(v_numofQ * 45/100);
		ELSEIF( totalcorrect >= v_numofQ * 50/100 AND totalcorrect < v_numofQ * 60/100 ) THEN 
			SET bonusz = FLOOR(v_numofQ * 55/100);
		ELSEIF( totalcorrect >= v_numofQ * 60/100 AND totalcorrect < v_numofQ * 70/100 ) THEN 
			SET bonusz = FLOOR(v_numofQ * 65/100);
		ELSEIF( totalcorrect >= v_numofQ * 70/100 AND totalcorrect < v_numofQ * 75/100 ) THEN 
			SET bonusz = FLOOR(v_numofQ * 70/100);
		ELSEIF( totalcorrect >= v_numofQ * 75/100 AND totalcorrect < v_numofQ * 85/100 ) THEN 
			SET bonusz = FLOOR(v_numofQ * 80/100);
		ELSEIF( totalcorrect >= v_numofQ * 85/100 AND totalcorrect < v_numofQ * 95/100 ) THEN 
			SET bonusz = FLOOR(v_numofQ * 90/100);
		ELSEIF( totalcorrect >= v_numofQ * 95/100 ) THEN 
			SET bonusz = v_numofQ;
		END IF;
	ELSE
		SET bonusz = 0;
	END IF;
	
	IF(totalcorrect >=0 && totalcorrect <=v_numofQ) THEN
		UPDATE user SET quizplayed_total = quizplayed_total + 1 WHERE user = p_username;
		SELECT lawtogetpoints INTO pontszerzesjoga FROM user WHERE user = p_username;
		
		SET p_score = 0;
		SELECT COUNT(*) INTO v_answeredquestions FROM live_question WHERE user = p_username AND bool = 1;
		SELECT SUM(difficulty) INTO v_ossznehezseg FROM live_question WHERE type = p_quiztype AND user = p_username AND bool = 1;
		SELECT SUM(difficulty) INTO v_teljesitett FROM live_question WHERE type = p_quiztype AND user = p_username AND bool = 1 AND correct = 1;
		IF(v_ossznehezseg IS NULL) THEN
			SET v_ossznehezseg = 1; /*mert 0-val nem lehet osztani*/
		END IF;
		IF(v_teljesitett IS NULL) THEN
			SET v_teljesitett = 0;
		END IF;
		IF(v_answeredquestions = v_numofQ) THEN
			SET p_score = TRUNCATE((v_teljesitett / v_ossznehezseg)*100, 2);
		END IF;
		
		IF(pontszerzesjoga = 1 AND p_score >= v_reqquired_atmenes) THEN
			UPDATE user SET points = points + totalcorrect + bonusz WHERE user = p_username;
		END IF;
		
		IF(totalcorrect = v_numofQ) THEN
			UPDATE user SET perfectgames = perfectgames + 1 WHERE user = p_username;
		END IF;
		
		INSERT INTO quiz_played VALUES(NULL, v_userid, p_quiztype, totalcorrect, NOW(), 0, p_score);
		SELECT test_id INTO v_actquizid FROM quiz_played WHERE user_id = v_userid AND quiz_id = p_quiztype ORDER BY finishing_date DESC LIMIT 1;
		
		OPEN curz1;
			REPEAT
				FETCH curz1 INTO c_id, c_ans1, c_ans2, c_ans3, c_ans4, c_position, c_correct, c_ownanswer;
				IF ( ! done ) THEN
					IF(c_ownanswer = c_ans1) THEN
						SET cc_ownans = 1;
					ELSEIF(c_ownanswer = c_ans2) THEN
						SET cc_ownans = 2;
					ELSEIF(c_ownanswer = c_ans3) THEN
						SET cc_ownans = 3;
					ELSEIF(c_ownanswer = c_ans4) THEN
						SET cc_ownans = 4;
					END IF;
					IF(c_correct = -1) THEN
						SET cc_ownans = 0;
					END IF;
					INSERT INTO played_quiz_question VALUES (v_actquizid, c_id, c_position, c_correct, cc_ownans);
				END IF;
			UNTIL done END REPEAT;
		CLOSE curz1;
		
	END IF;
	DELETE FROM live_question WHERE type = p_quiztype AND user = p_username;
	IF(p_score >= v_reqquired_atmenes) THEN
		SET totalcorrect = totalcorrect + bonusz;
	ELSE
		SET totalcorrect = 0;
	END IF;	

END IF;	
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_chatmsg` (IN `p_userid` INT, IN `p_groupid` INT, IN `p_msg` VARCHAR(2000) CHARSET utf8mb4, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_groupid INT;
	DECLARE v_ismember INT;
	DECLARE v_lawtousechat INT;
START TRANSACTION;
	SET p_response = "";
	IF(LENGTH(p_msg)< 1 OR LENGTH(p_msg)>2000) THEN
		SET p_response = CONCAT(p_response, "Az üzenet hossza maximum 2000 karakter lehet! ");
	END IF;
	/*IF(p_userid NOT REGEXP "/^[0-9]+$/") THEN
		SET p_response = CONCAT(p_response, "Hibás felhasználó! ");
	END IF;
	IF(p_groupid NOT REGEXP "/^[0-9]+$/") THEN
		SET p_response = CONCAT(p_response, "Hibás csoportazonosító!! ");
	END IF;*/
	/*SET p_response = CONCAT(p_response, "uzenetszovege: ", p_msg, " ---csoportid: ", p_groupid, " ---userid: ", p_userid);*/
	SELECT lawtousechat INTO v_lawtousechat FROM user WHERE id = p_userid;
	IF(v_lawtousechat != 1) THEN
		SET p_response = CONCAT(p_response, "Nincs jogod üzenetet küldeni! ");
	END IF;
	SELECT COUNT(*) INTO v_groupid FROM chat_group WHERE id = p_groupid AND is_deleted = 0;
	IF(v_groupid = 1) THEN
		SELECT COUNT(*) INTO v_ismember FROM group_member WHERE group_id = p_groupid AND user_id = p_userid;
		IF(v_ismember = 1) THEN
			IF(p_response = "") THEN
				INSERT INTO chat_message VALUES(NULL, p_userid, p_groupid, p_msg, NOW());
			END IF;
		ELSEIF(p_groupid = 1) THEN
			IF(p_response = "") THEN
				INSERT INTO chat_message VALUES(NULL, p_userid, p_groupid, p_msg, NOW());
			END IF;
		ELSE
			SET p_response = CONCAT(p_response, "Nem vagy tagja ennek a csoportnak! ");
		END IF;
	ELSE
		SET p_response = CONCAT(p_response, "Hibás csoportazonosító! ");
	END IF;
    
    IF(p_response = "") THEN
    	COMMIT;
    ELSE
    	ROLLBACK;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_quiz_comment` (IN `p_quizid` INT, IN `p_user` VARCHAR(25) CHARSET utf8, IN `p_comment` VARCHAR(2500) CHARSET utf8mb4, OUT `p_message` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_dbuser INT;
	DECLARE v_dbquiz INT;
	DECLARE v_toroltquiz INT;
	DECLARE v_phasequiz INT;
	DECLARE v_dbquizplayed INT DEFAULT 0;
	DECLARE v_userid INT DEFAULT 0;
	DECLARE v_dbmycomment INT;
	DECLARE v_lastcomment DATETIME;
	DECLARE v_quizname VARCHAR(200);
START TRANSACTION;
	SET p_message = "";
	IF(LENGTH(p_comment) < 5 OR LENGTH(p_comment) > 2500) THEN
		SET p_message = CONCAT(p_message, "Comment length must be between 5-2500! ");
	END IF;
	SELECT COUNT(user) INTO v_dbuser FROM user WHERE user = p_user AND deleteduser = 0;
	IF(v_dbuser != 1) THEN
		SET p_message = CONCAT(p_message, "No such user! Or Deleted User");
	ELSE
		SELECT id INTO v_userid FROM user WHERE user = p_user;
	END IF;
	SELECT COUNT(*) INTO v_dbquiz FROM thema WHERE id_number = p_quizid;
	IF(v_dbquiz != 1) THEN
		SET p_message = CONCAT(p_message, "No such quiz! ");
	ELSE
		SELECT is_deleted, phase, quiz_name INTO v_toroltquiz, v_phasequiz, v_quizname FROM thema WHERE id_number = p_quizid;
		IF(v_toroltquiz = 1 OR v_phasequiz < 3) THEN
			SET p_message = CONCAT(p_message, "This quiz cannot have any comments! ");
		END IF;
	END IF;
	SELECT COUNT(*) INTO v_dbquizplayed FROM quiz_played WHERE quiz_id = p_quizid AND user_id = v_userid;
	IF(v_dbquizplayed < 1) THEN
		SET p_message = CONCAT(p_message, "Play this quiz at least once to leave comment! ");
	END IF;
	IF(p_message = "") THEN
		SELECT COUNT(*) INTO v_dbmycomment FROM quiz_comment WHERE user_id = v_userid AND quiz_id = p_quizid AND is_deleted = 0;
		IF(v_dbmycomment > 0) THEN
			SELECT comment_date INTO v_lastcomment FROM quiz_comment WHERE user_id = v_userid AND quiz_id = p_quizid AND is_deleted = 0 ORDER BY comment_date DESC LIMIT 1;
			IF(TIMESTAMPDIFF(MINUTE, v_lastcomment, NOW())>60) THEN
				INSERT INTO quiz_comment VALUES(v_userid, p_quizid, p_comment, NOW(), NOW(), 0, 0, 0, NULL, NULL);
				INSERT INTO log_data VALUES (NULL, 26, p_user, CONCAT("A felhasználó hozzászólt a/az ", v_quizname, " kvízhez."), "SYSTEM", NOW(), 1);
			ELSE
				SET p_message = CONCAT(p_message, "Óránként csak egy hozzászólás írható! ");
			END IF;
		ELSE
			INSERT INTO quiz_comment VALUES(v_userid, p_quizid, p_comment, NOW(), NOW(), 0, 0, 0, NULL, NULL);
		END IF;
	END IF;
	
	IF(p_message = "") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `invite_friend_to_chatgroup` (IN `p_userid` INT, IN `p_invited` INT, IN `p_group` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_tagjae_inviter INT;
	DECLARE v_engedelyezve INT;
	DECLARE v_groupcreator INT;
	DECLARE v_baratok1 INT;
	DECLARE v_baratok2 INT;
	DECLARE v_mar_tag INT;
	DECLARE v_newmembername VARCHAR(30);
	DECLARE v_chatadmin VARCHAR(30);
	DECLARE v_groupname VARCHAR(200);
START TRANSACTION;
	SET p_response = "";
	IF(p_userid < 0) THEN
		SET p_response = CONCAT(p_response, "Hibás user azonosító! ");
	END IF;
	IF(p_invited < 0) THEN
		SET p_response = CONCAT(p_response, "Hibás barát azonosító! ");
	END IF;
	IF(p_group < 2) THEN
		SET p_response = CONCAT(p_response, "Hibás csoport azonosító! ");
	END IF;
	SELECT COUNT(*) INTO v_db FROM chat_group WHERE id = p_group AND is_deleted = 0;
	IF(v_db = 1) THEN
		SELECT invite_members, group_creator INTO v_engedelyezve, v_groupcreator FROM chat_group WHERE id = p_group AND is_deleted = 0;
		SELECT user INTO v_newmembername FROM user WHERE id = p_invited;
		SELECT user INTO v_chatadmin FROM user WHERE id = p_userid;
		SELECT group_name INTO v_groupname FROM chat_group WHERE id = p_group;
		SELECT COUNT(*) INTO v_tagjae_inviter FROM group_member WHERE group_id = p_group AND user_id = p_userid;
		IF(v_tagjae_inviter = 1) THEN
			SELECT COUNT(*) INTO v_baratok1 FROM friend WHERE id1 = p_userid AND id2 = p_invited AND status = 1;
			SELECT COUNT(*) INTO v_baratok2 FROM friend WHERE id1 = p_invited AND id2 = p_userid AND status = 1;
			IF(v_baratok1 + v_baratok2 = 1) THEN
				IF(v_engedelyezve = 1 || p_userid = v_groupcreator) THEN
					SELECT COUNT(*) INTO v_mar_tag FROM group_member WHERE group_id = p_group AND user_id = p_invited;
					IF(v_mar_tag = 0 AND p_response = "") THEN
						INSERT INTO group_member VALUES(p_group, p_invited, p_userid, NOW());
						INSERT INTO chat_history VALUES (p_group, CONCAT(v_chatadmin, " meghívta ", v_newmembername, "-t a csoportba. "), NOW());
					ELSE
						SET p_response = CONCAT(p_response, "Ez a felhasználó már tagja a csoportnak! ");
					END IF;
				ELSE
					SET p_response = CONCAT(p_response, "A csoportba csak az adminisztrátor hívhat meg felhasználókat! ");
				END IF;
			ELSE
				SET p_response = CONCAT(p_response, "Az adott felhasználó nem a barátod, így nem hívhatod meg a csoportba! ");
			END IF;
		ELSE
			SET p_response = CONCAT(p_response, "Nem vagy tagja ennek a csoportnak, így ennélfogva nincs jogod meghívni ide felhasználókat! ");
		END IF;
	ELSE
		SET p_response = CONCAT(p_response, "Hibás csoport! Ide nem hívható meg a kért user! ");
	END IF;
	
	IF(p_response = "") THEN
    	COMMIT;
    ELSE
    	ROLLBACK;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `level_allocation` (IN `p_username` VARCHAR(30) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_warn INT;
	DECLARE v_szintetmegtart INT;
	DECLARE v_premium INT;
	DECLARE v_pontszam INT;
	DECLARE v_jatekszam INT;
	DECLARE v_szint INT;
	DECLARE v_toroltuser INT;
START TRANSACTION;
	SELECT deleteduser, keep_level, warn, premium, points, quizplayed_total, level INTO v_toroltuser, v_szintetmegtart, v_warn, v_premium, v_pontszam, v_jatekszam, v_szint FROM user WHERE user = p_username;
	IF(v_szintetmegtart = 0 AND v_toroltuser = 0) THEN
		IF(v_pontszam >= 15000 AND v_jatekszam >= 1500) THEN
			UPDATE user SET level = 5 where user = p_username;
			IF(v_warn = 0 AND v_premium = 0) THEN
				UPDATE user SET lawtousechat = 1, lawtosendquestion = 1, lawtopostnews = 1, lawtosearchuser = 1, lawtoeditfaq = 1, lawtogetpoints = 1, lawtouserequests = 1, lawtocreatequiz = 1, lawtosendmail = 1 WHERE user = p_username;
			END IF;
		ELSEIF(v_pontszam >= 5001 AND v_jatekszam >= 501) THEN
			UPDATE user SET level = 4 where user = p_username;
			IF(v_warn = 0 AND v_premium = 0) THEN
				UPDATE user SET lawtousechat = 1, lawtosendquestion = 1, lawtopostnews = 1, lawtosearchuser = 1, lawtoeditfaq = 0, lawtogetpoints = 1, lawtouserequests = 1, lawtocreatequiz = 1, lawtosendmail = 1 WHERE user = p_username;
			END IF;
		ELSEIF(v_pontszam >= 501 AND v_jatekszam >= 51) THEN
			UPDATE user SET level = 3 where user = p_username;
			IF(v_warn = 0 AND v_premium = 0) THEN
				UPDATE user SET lawtousechat = 1, lawtosendquestion = 1, lawtopostnews = 0, lawtosearchuser = 0, lawtoeditfaq = 0, lawtogetpoints = 1, lawtouserequests = 1, lawtocreatequiz = 1, lawtosendmail = 1 WHERE user = p_username;
			END IF;
		ELSEIF(v_pontszam >= 20 AND v_jatekszam >= 2) THEN
			UPDATE user SET level = 2 where user = p_username;
			IF(v_warn = 0 AND v_premium = 0) THEN
				UPDATE user SET lawtousechat = 1, lawtosendquestion = 0, lawtopostnews = 0, lawtosearchuser = 0, lawtoeditfaq = 0, lawtogetpoints = 1, lawtouserequests = 1, lawtocreatequiz = 0, lawtosendmail = 1 WHERE user = p_username;
			END IF;
		ELSE
			UPDATE user SET level = 1 where user = p_username;
			IF(v_warn = 0 AND v_premium = 0) THEN
				UPDATE user SET lawtousechat = 0, lawtosendquestion = 0, lawtopostnews = 0, lawtosearchuser = 0, lawtoeditfaq = 0, lawtogetpoints = 1, lawtouserequests = 0, lawtocreatequiz = 0, lawtosendmail = 1 WHERE user = p_username;
			END IF;
		END IF;
	
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `maintenance_time` (IN `p_user` VARCHAR(30) CHARSET utf8, OUT `p_response` VARCHAR(1000) CHARSET utf8)  READS SQL DATA
BEGIN
	DECLARE v_sorok INT DEFAULT 0;
	
	SET p_response = "";
	SELECT COUNT(id) INTO v_sorok FROM live_question WHERE user = p_user;
	IF(v_sorok = 0) THEN
		INSERT INTO log_data VALUES(NULL, 1, p_user, CONCAT("Kijelentkeztetés karbantartás miatt."), 'SYSTEM', NOW(), 1);
		SET p_response = "ok";
	ELSE
		SET p_response = "jatekban";
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mark_message_read` (IN `p_id` INT, IN `p_dbase` INT, IN `p_user` VARCHAR(25) CHARSET utf8, OUT `p_response` VARCHAR(3000) CHARSET utf8)  MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
	DECLARE v_uid INT;
	DECLARE v_rowid INT;
START TRANSACTION;
	SET p_response = "";
    
	SELECT COUNT(*) INTO v_uid FROM user WHERE user = p_user;
	IF(v_uid != 1) THEN
		SET p_response = CONCAT(p_response, "Hibás user azonosító! ");
	ELSE
		SELECT id INTO v_uid FROM user WHERE user = p_user;
		IF(p_dbase = 0) THEN
			SELECT COUNT(*) INTO v_rowid FROM log_data WHERE id = p_id AND username = p_user;
			IF(v_rowid = 1 AND p_response = "") THEN
				UPDATE log_data SET is_seen = 1 WHERE id = p_id AND username = p_user;
			ELSE
				SET p_response = CONCAT(p_response, "A műveletet nem sikerűlt végrehajtani! ");
			END IF;
		ELSE
			SELECT COUNT(*) INTO v_rowid FROM private_message WHERE id = p_id AND receiver_id = v_uid;
			IF(v_rowid = 1 AND p_response = "") THEN
				UPDATE private_message SET read_msg = 1 WHERE id = p_id AND receiver_id = v_uid;
			ELSE
				SET p_response = CONCAT(p_response, "A műveletet nem sikerűlt végrehajtani! ");
			END IF;
		END IF;
	END IF;
	
	IF(p_response = "") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `points_to_hiding_profile` (IN `p_username` VARCHAR(30) CHARSET utf8, OUT `p_response` VARCHAR(150) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
    DECLARE v_warn INT;
	DECLARE v_profilrejt INT;
	DECLARE v_pontszam INT;
	DECLARE v_premium INT;
	DECLARE v_toroltuser INT;
    START TRANSACTION;
	SELECT deleteduser, warn, points, profilehiding, premium INTO v_toroltuser, v_warn, v_pontszam, v_profilrejt, v_premium FROM user WHERE user = p_username;
	IF(v_toroltuser != 0) THEN
		SET p_response = 'Törölt felhasználó!';
	END IF;
	IF(v_profilrejt = 1) THEN
		SET p_response = 'Jelenleg be van állítva a profilod rejtettsége!';
	END IF;
	IF(v_warn != 0) THEN
		SET p_response = 'WARN-t kaptál! Ezért számodra ez a funkció nem elérhető!';
	END IF;
	IF(v_pontszam < 500 AND v_premium = 0) THEN
		SET p_response = 'Ez a beállítás számodra NEM megengedett, mert NINCS elegendő mennyiségű pontszámod!';
	END IF;
	IF(v_pontszam >= 500 AND v_premium = 0 AND v_profilrejt = 0 AND v_warn = 0 AND v_toroltuser = 0) THEN
		SET p_response = 'Sikeres művelet! A profilod rejtettse 30 napig érvényes. Ezért a beállításért -500 pontot vont le Tőled a rendszer.';
		UPDATE user SET points = points - 500, profilehiding = 1, profilehiding_expire = NOW() + INTERVAL 30 DAY WHERE user = p_username;
		INSERT INTO log_data VALUES (NULL, 8, p_username, 'A profilod rejtettségét sikeresen beállítottad a következő 30 napra! Pontváltozás történt: -500 pont, ok: profilrejtettség beállítása!', 'SYSTEM', NOW(), 0);
	END IF;
	IF(v_premium = 1 AND v_profilrejt = 0 AND v_warn = 0 AND v_toroltuser = 0) THEN
		UPDATE user SET profilehiding = 1, profilehiding_expire = premium_expire WHERE user = p_username;
		SET p_response = 'Sikeres művelet! Mostantól profilod rejtettséget élvez a PREMIUM tagságod alatt.';
		INSERT INTO log_data VALUES (NULL, 8, p_username, 'A profilod rejtettségét ingyen beállítottad a prémium tagságod idejéig!', 'SYSTEM', NOW(), 0);
	END IF;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `post_news` (IN `p_userid` INT, IN `p_title` VARCHAR(50) CHARSET utf8, IN `p_description` VARCHAR(3000) CHARSET utf8mb4, IN `p_imagepath` VARCHAR(255) CHARSET utf8, IN `p_filepath` VARCHAR(255) CHARSET utf8, IN `p_filename` VARCHAR(255) CHARSET utf8, IN `p_imagesize` DOUBLE, IN `p_filesize` DOUBLE, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_hirdb INT;
START TRANSACTION;
	SET p_response = "";
	IF(LENGTH(p_title)< 5 OR LENGTH(p_title)>50) THEN
		SET p_response = CONCAT(p_response, "A hír címe 5-50 karakterből állhat! ");
	END IF;
	IF(LENGTH(p_description)< 25 OR LENGTH(p_description)>3000) THEN
		SET p_response = CONCAT(p_response, "A hír leírása 25-3000 karakterből állhat! ");
	END IF;
	IF(LENGTH(p_imagepath)<1) THEN
		SET p_imagepath = NULL;
	END IF;
	IF(LENGTH(p_imagepath)>255) THEN
		SET p_response = CONCAT(p_response, "A kép útvonala legfeljebb 200 karakterből állhat! ");
	END IF;
	IF(LENGTH(p_filepath)>255) THEN
		SET p_response = CONCAT(p_response, "A file útvonala legfeljebb 200 karakterből állhat! ");
	END IF;
	IF(LENGTH(p_filepath)<1) THEN
		SET p_filepath = NULL;
	END IF;
	IF(LENGTH(p_filename)>255) THEN
		SET p_response = CONCAT(p_response, "A file neve legfeljebb 200 karakterből állhat! ");
	END IF;
	IF(LENGTH(p_filename)<1) THEN
		SET p_filename = NULL;
	END IF;
	IF(p_imagesize < 0 OR p_imagesize > 2) THEN
		SET p_response = CONCAT(p_response, "A kép mérete legfeljebb 2 MB lehet! ");
	END IF;
	IF(p_imagesize = 0) THEN
		SET p_imagesize = NULL;
	END IF;
	IF(p_filesize < 0 OR p_filesize > 4) THEN
		SET p_response = CONCAT(p_response, "A file mérete legfeljebb 4 MB lehet! ");
	END IF;
	IF(p_filesize = 0) THEN
		SET p_filesize = NULL;
	END IF;
	SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid AND (lawtopostnews = 1 OR adminuser = 1);
	IF(v_db = 1) THEN
		SELECT COUNT(*) INTO v_hirdb FROM news WHERE publisher_id = p_userid AND publication_date >= CURDATE();
		IF(v_hirdb > 0) THEN
			SET p_response = CONCAT(p_response, "Naponta csak 1 hírt lehet közzétenni! ");
		ELSE
			IF(p_response = "") THEN
				INSERT INTO news VALUES (NULL, p_userid, p_title, p_description, p_filename, p_imagepath, p_imagesize, p_filepath, p_filesize, NOW(), 0, NULL, NULL, NULL);
				INSERT INTO log_data VALUES(NULL, 7, p_userid, CONCAT("Hír közzétéve a Főoldalon. A hír témája/címe: ", p_title), 'SYSTEM', NOW(), 1);
			ELSE
				SET p_response = CONCAT(p_response, "Nem sikerűlt elküldeni a hírt! ");
			END IF;
		END IF;
	ELSE
		SET p_response = CONCAT(p_response, "Csak ADMIN, vagy 4.rangtól kezdődően lehet hírt létrehozni! ");
	END IF;
	
	IF(p_response = "") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `premium_timeout` (IN `p_username` VARCHAR(30) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_premium INT;
	DECLARE v_premiumlejar DATETIME;
START TRANSACTION;
	SET v_premiumlejar = DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s');
	SELECT premium, premium_expire INTO v_premium, v_premiumlejar FROM user WHERE user = p_username;
	IF(v_premium = 1) THEN
		IF(NOW() >= v_premiumlejar) THEN
			UPDATE user SET premium = 0, premium_expire = 0, keep_level = 0 WHERE user = p_username;
			UPDATE premium SET is_active = 0 WHERE userid = (SELECT id FROM user WHERE user = p_username) AND is_active = 1;
			INSERT INTO log_data VALUES (NULL, 6, p_username, 'Az általad kapott PREMIUM ideje lejárt!', 'SYSTEM', NOW(), 0);
		END IF;
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `profilehiding_timeout` (IN `p_username` VARCHAR(30) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_profilrejt INT;
	DECLARE v_profilrejtlejar DATETIME;
START TRANSACTION;
	SELECT profilehiding, profilehiding_expire INTO v_profilrejt, v_profilrejtlejar FROM user WHERE user = p_username;
	IF(v_profilrejt = 1) THEN
		IF(v_profilrejtlejar - NOW() < 0) THEN
			UPDATE user SET profilehiding = 0, profilehiding_expire = 0 WHERE user = p_username;
			INSERT INTO log_data VALUES (NULL, 5, p_username, 'A profilod rejtettségi ideje lejárt!', 'SYSTEM', NOW(), 0);
		END IF;
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `question_activation` (IN `p_id` INT, IN `p_adminid` INT, IN `p_action` INT, OUT `p_response` VARCHAR(150) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_bool INT;
	DECLARE v_darab INT;
	DECLARE v_quizid INT;
	DECLARE v_allactivequestion INT;
	DECLARE v_numofquestion INT;
	DECLARE v_admin INT;
	DECLARE v_adminusername VARCHAR(30);
START TRANSACTION;
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;
	SELECT COUNT(*) INTO v_darab FROM quiz_question WHERE id = p_id AND is_verified = 1;
	IF(v_darab != 1) THEN
		SET p_response = 'Nincs ilyen azonosítójú kérdés! Csak ELFOGADOTT státuszú kérdések aktiválhatók/inaktiválhatók!';
	ELSE
		SELECT user INTO v_adminusername FROM user WHERE id = p_adminid;
		SELECT quiz_id, is_active INTO v_quizid, v_bool FROM quiz_question WHERE id = p_id;
		
		IF(p_action = 0) THEN
			SELECT num_of_question INTO v_numofquestion FROM thema WHERE id_number = v_quizid;
			SELECT COUNT(*) INTO v_allactivequestion FROM quiz_question WHERE quiz_id = v_quizid AND is_active = 1; 
			IF(v_bool = 0) THEN
				SET p_response = 'Hiba! Ez a kérdés jelenleg INAKTÍV!';
			ELSEIF(v_numofquestion >= v_allactivequestion - 1) THEN
				SET p_response = 'Hiba! A művelet nem hajtható végre, mert nem maradna elég aktív kérdés a kvíz teljesítéséhez.';
			ELSE
				UPDATE quiz_question SET is_active = 0 WHERE id = p_id;
				INSERT INTO question_comment VALUES (NULL, p_id, v_adminusername, "A kérdést inaktiválták határozatlan ideig.", NOW());
				SET p_response = 'ok';
			END IF;
			
		ELSEIF(p_action = 1) THEN
			IF(v_bool = 1) THEN
				SET p_response = 'Hiba! Ez a kérdés jelenleg AKTÍV!';
			ELSE
				UPDATE quiz_question SET is_active = 1 WHERE id = p_id;
				INSERT INTO question_comment VALUES (NULL, p_id, v_adminusername, "A kérdést újra aktiválták.", NOW());
				SET p_response = 'ok';
			END IF;
		END IF;
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reject_newquiz` (IN `p_quizid` INT, IN `p_adminusername` VARCHAR(30) CHARSET utf8, IN `p_rejectreason` VARCHAR(150) CHARSET utf8, OUT `response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_dbadmin INT;
	DECLARE v_fazis INT;
	DECLARE v_torolt INT;
	DECLARE v_isrequest INT;
	DECLARE v_temanev VARCHAR(150);
	DECLARE v_kikerte VARCHAR(30);
	DECLARE v_id INT;
START TRANSACTION;
	SET response = "";
	IF(LENGTH(p_rejectreason)>150 OR LENGTH(p_rejectreason) < 5) THEN
		SET response = CONCAT(response, "Hiba! A kvíz törlési oka 5-150 karakter legyen! ");
	END IF;
	SELECT COUNT(*) INTO v_dbadmin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	SELECT COUNT(*) INTO v_db FROM thema WHERE id_number = p_quizid;
	IF(v_db != 1) THEN
		SET response = CONCAT(response, "Hibás kvízazonosító! ");
	ELSEIF(v_dbadmin != 1) THEN
		SET response = CONCAT(response, "Hibás Adminazonosító! ");
	ELSE
		SELECT phase, is_deleted, quiz_name, is_request, requested_by INTO v_fazis, v_torolt, v_temanev, v_isrequest, v_kikerte FROM thema WHERE id_number = p_quizid;
		IF(v_isrequest != 0) THEN
			SET response = CONCAT(response, "Hiba! A kvíz nem saját kvíz! ");
		END IF;
		IF(v_fazis != 1) THEN
			SET response = CONCAT(response, "Hiba! A kvíz nincs az első fázisban! ");
		END IF;
		IF(v_torolt != 0) THEN
			SET response = CONCAT(response, "Hiba! Ez a kvíz törölve van! ");
		END IF;
		IF(v_fazis = 1 AND v_torolt = 0 AND response = "") THEN
			UPDATE thema SET is_deleted = 1 WHERE id_number = p_quizid;
			INSERT INTO log_data VALUES(NULL, 16, v_kikerte, CONCAT("Kvíz törölve! A/Az ", v_temanev, " nevű kvízed törölve lett a következő indokkal: ", p_rejectreason), p_adminusername, NOW(), 0);
		END IF;
	END IF;
	IF(response = "") THEN
		SET response = "ok";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reject_question` (IN `p_id` INT, IN `p_modreason` VARCHAR(500) CHARSET utf8, IN `p_minuspoints` INT, IN `p_adminid` INT, OUT `p_response` VARCHAR(300) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darab INT;
	DECLARE v_admin INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_adminusername VARCHAR(30);
START TRANSACTION;
	SET p_response = '';
	IF(LENGTH(p_modreason) < 5 OR LENGTH(p_modreason)>400) THEN
		SET p_response = 'A moderátori comment 5-400 karakter legyen!!';
	END IF;
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;
	IF(p_minuspoints < 0 OR p_minuspoints > 100) THEN
		SET p_response = 'Csak 0-100 közötti pontmennyiség vonható le!';
	END IF;
	SELECT COUNT(*) INTO v_darab FROM quiz_question WHERE id = p_id AND (is_verified IS NULL OR is_verified = 2);
	IF(v_darab != 1) THEN
		SET p_response = 'Hibás azonosító, vagy a kérdés nincs abban a fázisban, hogy a műveletet végre lehessen hajtani!';
	ELSEIF(v_darab = 1 AND v_admin = 1 AND p_response = '') THEN
		SELECT username INTO v_username FROM quiz_question WHERE id = p_id;
		SELECT user INTO v_adminusername FROM user WHERE id = p_adminid;
		UPDATE quiz_question SET is_verified = 3, verified_by = p_adminid, verification_time = NOW(), is_active = 0 WHERE id = p_id;
		UPDATE user SET points = points - p_minuspoints WHERE user = v_username;
		INSERT INTO log_data VALUES (NULL, 12, v_username, CONCAT('A/Az ', p_id, ' - azonosítójú kérdés elutasítva. Ok: ', p_modreason, ' Pontlevonás: ', p_minuspoints, ' pont!'), v_adminusername, NOW(), 0);
		INSERT INTO question_comment VALUES (NULL, p_id, v_adminusername, CONCAT('Ezt a kérdést elutasították! Ok: ', p_modreason, '.'), NOW());
		SET p_response = 'ok';
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reject_request` (IN `p_requestid` INT, IN `p_adminusername` VARCHAR(30) CHARSET utf8, IN `p_rejectreason` VARCHAR(150) CHARSET utf8, OUT `response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_admin INT;
	DECLARE v_requestcount INT;
	DECLARE v_fazis INT;
	DECLARE v_torolt INT;
	DECLARE v_temanev VARCHAR(150);
	DECLARE v_kikerte VARCHAR(30);
	DECLARE v_pontszam INT;
	DECLARE v_id INT;
START TRANSACTION;
	SET response = "";
	IF(LENGTH(p_rejectreason)>150 OR LENGTH(p_rejectreason) < 1) THEN
		SET response = CONCAT(response, "Hiba! A kérés törlési oka 1-150 karakter legyen! ");
	END IF;
	SELECT COUNT(*) INTO v_admin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET response = CONCAT(response, "Hibás Admin azonosító! ");
	END IF;
	SELECT COUNT(id_number) INTO v_requestcount FROM thema WHERE id_number = p_requestid AND is_request = 1;
	IF(v_requestcount != 1) THEN
		SET response = CONCAT(response, "Hibás kérés azonosító! ");
	ELSE
		SELECT phase, is_deleted, quiz_name, requested_by INTO v_fazis, v_torolt, v_temanev, v_kikerte FROM thema WHERE id_number = p_requestid;
		IF(v_fazis != 1) THEN
			SET response = CONCAT(response, "Hiba! A kérés nincs az első fázisban! ");
		END IF;
		IF(v_torolt != 0) THEN
			SET response = CONCAT(response, "Hiba! Ez a kérés törölve van! ");
		END IF;
		IF(v_fazis = 1 AND v_torolt = 0 AND response = "") THEN
			SELECT id INTO v_id FROM user WHERE user = v_kikerte;
			SELECT SUM(offered_points) INTO v_pontszam FROM request_vote WHERE quiz_id = p_requestid AND user_id = v_id;
			UPDATE thema SET is_deleted = 1 WHERE id_number = p_requestid;
			UPDATE user SET points = points + v_pontszam WHERE id = v_id;
			DELETE FROM request_vote WHERE quiz_id = p_requestid AND user_id = v_id;
			INSERT INTO log_data VALUES(NULL, 24, v_kikerte, CONCAT("A/Az ", v_temanev, " nevű kérésed törölve lett! Ok: ", p_rejectreason, ". A kérésre ", v_pontszam, " pontot szántál, melyet ezennel visszaadtunk."), p_adminusername, NOW(), 0);
		END IF;
	END IF;
	
	IF(response = "") THEN
		SET response = "ok";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `remove_from_chatgroup` (IN `p_groupid` INT, IN `p_adminid` INT, IN `p_memberid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_csoport INT;
	DECLARE v_tagjae INT;
	DECLARE v_csoportadmin VARCHAR(30);
	DECLARE v_csoporttag VARCHAR(30);
START TRANSACTION;
	SET p_response = "";
	IF(p_groupid < 2) THEN
		SET p_response = CONCAT(p_response, "Hibás csoport azonosító! ");
	END IF;
	IF(p_adminid < 0) THEN
		SET p_response = CONCAT(p_response, "Hibás csoportadmin azonosító! ");
	END IF;
	IF(p_memberid < 2) THEN
		SET p_response = CONCAT(p_response, "Hibás felhasználó azonosító! ");
	END IF;
	
	IF(p_adminid = p_memberid) THEN
		SET p_response = CONCAT(p_response, "Mint a csoport adminisztrátora, nem hagyhatod el a csoportot! ");
	END IF;
	
	SELECT COUNT(*) INTO v_csoport FROM chat_group WHERE id = p_groupid AND group_creator = p_adminid AND is_deleted = 0;
	IF(v_csoport = 1) THEN
		SELECT COUNT(*) INTO v_tagjae FROM group_member WHERE group_id = p_groupid AND user_id = p_memberid;
		IF(v_tagjae = 1) THEN
			SELECT user INTO v_csoportadmin FROM user WHERE id = p_adminid;
			SELECT user INTO v_csoporttag FROM user WHERE id = p_memberid;
			IF(p_response = "") THEN
				DELETE FROM group_member WHERE group_id = p_groupid AND user_id = p_memberid;
				INSERT INTO chat_history VALUES (p_groupid, CONCAT(v_csoportadmin, " eltávolította ", v_csoporttag, "-t a csoportból. "), NOW());
			ELSE
				SET p_response = CONCAT(p_response, "Nem sikerűlt végrehajtani a műveletet! ");
			END IF;
		ELSE
			SET p_response = CONCAT(p_response, "Ez a felhasználó nem tagja a csoportnak! ");
		END IF;
	ELSE
		SET p_response = CONCAT(p_response, "Hiba történt! Lehetséges okok: nem te vagy a csoport adminisztrátora, vagy a csoportot törölték! ");
	END IF;
	
	IF(p_response = "") THEN
    	COMMIT;
    ELSE
    	ROLLBACK;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `remove_from_favorites` (IN `p_username` VARCHAR(25) CHARSET utf8, IN `p_quizid` INT, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darabszam INT;
	DECLARE v_id INT;
	DECLARE v_toroltuser INT;
START TRANSACTION;
	SET p_response = "";
	SELECT COUNT(id) INTO v_id FROM user WHERE user = p_username;
	IF(v_id = 1) THEN
		SELECT id, deleteduser INTO v_id, v_toroltuser FROM user WHERE user = p_username;
		IF(v_toroltuser != 0) THEN
			SET p_response = CONCAT(p_response, "Törölt felhasználó!");
		END IF;
		SELECT COUNT(f.quiz_id) INTO v_darabszam FROM favorite_quiz f JOIN user u ON (f.user_id = u.id) WHERE u.user = p_username AND f.quiz_id = p_quizid;
		IF(v_darabszam = 0) THEN
			SET p_response = CONCAT(p_response, "A kvíz nincs a Kedvencek között!");
		END IF;
		IF(v_darabszam > 0 AND p_response = "") THEN
			DELETE FROM favorite_quiz WHERE user_id = v_id AND quiz_id = p_quizid;
		END IF;
	ELSE
		SET p_response = CONCAT(p_response, "Hibás user azonosító");
	END IF;

	IF(p_response = "") THEN
		SET p_response = "Sikeres művelet!";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `renew_accomplish_deadline` (IN `p_requestid` INT, IN `p_adminusername` VARCHAR(30) CHARSET utf8, IN `p_days` INT, OUT `response` VARCHAR(1000) CHARSET utf8)  NO SQL
BEGIN
	DECLARE v_admin INT;
	DECLARE v_requestcount INT;
	DECLARE v_fazis INT;
	DECLARE v_torolt INT;
	DECLARE v_isrequest INT;
	DECLARE v_temanev VARCHAR(150);
	DECLARE v_kikerte VARCHAR(30);
	DECLARE v_accomplish_deadline DATETIME;
	DECLARE v_isundertaken INT;
	DECLARE v_undertakenby VARCHAR(30);
	DECLARE v_newdeadline DATETIME;
START TRANSACTION;
	SET response = "";
	IF(LENGTH(p_days) < 0 OR p_days < 1 OR p_days > 30) THEN
		SET response = CONCAT(response, "A határidő legfeljebb 30 nappal hosszabbítható meg! ");
	END IF;
	SELECT COUNT(*) INTO v_admin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET response = CONCAT(response, "Hibás Admin azonosító! ");
	END IF;
	SELECT COUNT(id_number) INTO v_requestcount FROM thema WHERE id_number = p_requestid AND is_request = 1;
	IF(v_requestcount != 1) THEN
		SET response = CONCAT(response, "Hibás kérés azonosító! ");
	ELSE
		SELECT is_request, phase, is_deleted, quiz_name, requested_by, is_undertaken, accomplish_deadline, undertaken_by INTO v_isrequest, v_fazis, v_torolt, v_temanev, v_kikerte, v_isundertaken, v_accomplish_deadline, v_undertakenby FROM thema WHERE id_number = p_requestid;
		IF(v_fazis != 2) THEN
			SET response = CONCAT(response, "Hiba! A kérés nincs a 2. fázisban! ");
		END IF;
		IF(v_torolt != 0) THEN
			SET response = CONCAT(response, "Hiba! Ez a kérés törölve van! ");
		END IF;
		IF(v_isrequest != 1) THEN
			SET response = CONCAT(response, "Hiba! Ez a kvíz NEM egy kérés! ");
		END IF;
		IF(v_isundertaken != 1) THEN
			SET response = CONCAT(response, "Hiba! Ez a kvíz nincsen elvállalva! ");
		END IF;
		IF(v_accomplish_deadline IS NULL) THEN
			SET response = CONCAT(response, "Hiba! A kvíznek nincs teljesítési határideje! ");
		END IF;
		IF(v_fazis = 2 AND v_torolt = 0 AND response = "") THEN
			UPDATE thema SET accomplish_deadline = accomplish_deadline + INTERVAL p_days DAY WHERE id_number = p_requestid;
			SELECT accomplish_deadline INTO v_newdeadline FROM thema WHERE id_number = p_requestid;
			INSERT INTO log_data VALUES(NULL, 37, v_undertakenby, CONCAT("Meghosszabbítottuk a/az ", v_temanev, " nevű kérés teljesítésének határidejét! Az új határidő: ", v_newdeadline, " ."), p_adminusername, NOW(), 0);
		END IF;
	END IF;
	
	IF(response = "") THEN
		SET response = "ok";
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sendback_question_forupdate` (IN `p_id` INT, IN `p_modreason` VARCHAR(400) CHARSET utf8, IN `p_adminid` INT, OUT `p_response` VARCHAR(150) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darab INT;
	DECLARE v_admin INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_adminusername VARCHAR(30);
START TRANSACTION;
	SET p_response = '';
	IF(LENGTH(p_modreason) < 5 OR LENGTH(p_modreason)>400) THEN
		SET p_response = 'A moderátori comment 1-400 karakter legyen!!';
	END IF;
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;
	SELECT COUNT(*) INTO v_darab FROM quiz_question WHERE id = p_id AND (is_verified IS NULL OR is_verified = 0);
	IF(v_darab != 1) THEN
		SET p_response = 'Hibás azonosító, vagy a kérdés nincs abban a fázisban, hogy a műveletet végre lehessen hajtani!';
	ELSEIF(v_darab = 1 AND v_admin = 1 AND p_response = '') THEN
		SELECT username INTO v_username FROM quiz_question WHERE id = p_id;
		SELECT user INTO v_adminusername FROM user WHERE id = p_adminid;
		UPDATE quiz_question SET is_verified = 2 WHERE id = p_id;
		INSERT INTO log_data VALUES (NULL, 11, v_username, CONCAT('Kérdés visszaküldve! - A ', p_id,' - azonosítójú kérdést visszaküldték javításra. Ok: ', p_modreason, '!'), v_adminusername, NOW(), 0);
		INSERT INTO question_comment VALUES (NULL, p_id, v_adminusername, CONCAT('Ezt a kérdést visszaküldték javításra! Ok: ', p_modreason, '.'), NOW());
		SET p_response = 'ok';
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_private_message` (IN `p_sender` VARCHAR(25) CHARSET utf8, IN `p_recipient` VARCHAR(25) CHARSET utf8, IN `p_message` VARCHAR(5000) CHARSET utf8mb4, OUT `p_response` VARCHAR(1000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_id INT;
	DECLARE v_myid INT DEFAULT 0;
	DECLARE v_statusz INT;
	DECLARE v_db INT;
	DECLARE v_lastsent DATETIME;
START TRANSACTION;
	SET p_response = "";
	IF(LENGTH(p_message)< 5 OR LENGTH(p_message)>5000) THEN
		SET p_response = CONCAT(p_response, "Hiba. Az üzenet hossza 5-5000 karakter legyen!");
	END IF;
	SELECT COUNT(*) INTO v_myid FROM user WHERE BINARY user = BINARY p_sender AND deleteduser = 0;
	IF(v_myid != 1) THEN
		SET p_response = CONCAT(p_response, "A küldő neve hibás!");
	ELSE
		SELECT id INTO v_myid FROM user WHERE BINARY user = BINARY p_sender AND deleteduser = 0;
	END IF;
	SELECT COUNT(*) INTO v_id FROM user WHERE BINARY user = BINARY p_recipient AND deleteduser = 0;
	IF(v_id != 1) THEN
		SET p_response = CONCAT(p_response, "Hiba. A címzett nem létezik az adatbázisban!");
	ELSE
		SELECT id INTO v_id FROM user WHERE BINARY user = BINARY p_recipient AND deleteduser = 0;
		SET v_statusz = status_send_message(v_myid, v_id);
		IF(v_statusz != 0) THEN
			SET p_response = CONCAT(p_response, "Üzenetküldés megtagadva!");
		ELSE
			SELECT COUNT(*) INTO v_db FROM private_message WHERE sender_id = v_myid AND receiver_id = v_id;
			IF(v_db = 0) THEN
				IF(p_response = "") THEN
					INSERT INTO private_message VALUES (NULL, v_myid, v_id, p_message, NOW(), 0);
					SET p_response = "ok";
				END IF;
			ELSE
				SELECT sending_time INTO v_lastsent FROM private_message WHERE sender_id = v_myid AND receiver_id = v_id ORDER BY sending_time DESC LIMIT 1;
				IF(TIMESTAMPDIFF(MINUTE, v_lastsent, NOW()) >= 5) THEN
					IF(p_response = "") THEN
						INSERT INTO private_message VALUES (NULL, v_myid, v_id, p_message, NOW(), 0);
						SET p_response = "ok";
					END IF;
				ELSE
					SET p_response = CONCAT(p_response, "Várj legalább 5 percet a következő üzenet küldéséig! Nem sikerűlt elküldeni az üzenetet!");
				END IF;
			END IF;
		END IF;
	END IF;
	
	IF(p_response = "ok") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_competition` (IN `p_competitionid` INT, IN `p_themaid` INT, IN `p_color` VARCHAR(7) CHARSET utf8, IN `p_announcement` DATE, IN `p_startdate` DATETIME, IN `p_enddate` DATETIME, IN `p_activity` INT, IN `p_rew1` INT, IN `p_rew2` INT, IN `p_rew3` INT, IN `p_rew4` INT, IN `p_rew5` INT, IN `p_rew6` INT, IN `p_rew7` INT, IN `p_adminid` INT, OUT `p_response` VARCHAR(5000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_darab INT;
	DECLARE v_startdate DATETIME;
	DECLARE v_enddate DATETIME;
	DECLARE v_quizid INT;
	DECLARE v_admin INT;
	DECLARE v_quizexists INT;
	DECLARE x INT DEFAULT 0;
	DECLARE y INT;
	
	DECLARE c_announcement_date DATE;
	DECLARE c_startdate DATETIME;
	DECLARE c_enddate DATETIME;
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE curz1 CURSOR FOR SELECT announcement_date, startdate, enddate FROM competition WHERE announcement_date > NOW() AND id != p_competitionid;        
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
	
START TRANSACTION;
	SET p_response = '';
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;
	
	IF(p_rew1 < 100 OR p_rew1 > 25000) THEN
		SET p_response = 'A maximális jutalom 100-25000 közötti pontmennyiség legyen!!';
	END IF;
	IF(p_rew1 <= p_rew2 OR p_rew2 <= p_rew3 OR p_rew3 <= p_rew4 OR p_rew4 <= p_rew5 OR p_rew5 <= p_rew6 OR p_rew6 <= p_rew7) THEN
		SET p_response = 'A jutalmak nagysága szigorúan csökkenő érték legyen az elsőtől az utolsóig!';
	END IF;
	
	IF(DATEDIFF(p_announcement, NOW()) < 1) THEN
		SET p_response = 'A bejelentés ideje nem lehet kisebb a mai dátumnál!';
	END IF;
	
	IF(STR_TO_DATE(p_announcement, '%Y-%m-%d') IS NULL) THEN
		SET p_response = 'A bejelentés ideje helytelen, vagy nem egy dátum!';
	END IF;
	
	IF(STR_TO_DATE(p_startdate, '%Y-%m-%d %H:%i:%s') IS NULL) THEN
		SET p_response = 'A kezdés ideje helytelen, vagy nem egy dátum!';
	END IF;
	
	IF(STR_TO_DATE(p_enddate, '%Y-%m-%d %H:%i:%s') IS NULL) THEN
		SET p_response = 'A lezárás ideje helytelen, vagy nem egy dátum!';
	END IF;
	
	IF(DATEDIFF(p_startdate, p_announcement) < 1) THEN
		SET p_response = 'A bejelentés ideje és a kezdés dátuma közt legyen minimum 1 nap különbség! Természetesen a bejelentés ideje kisebb kell legyen a kezdés idejénél!';
	END IF;
	
	IF(DATEDIFF(p_enddate, p_startdate) < 3 OR DATEDIFF(p_enddate, p_startdate) > 14) THEN
		SET p_response = 'A verseny legalább 3 napot, de maximum 14 napig tarthat!';
	END IF;
	
	SELECT COUNT(*) INTO v_darab FROM competition WHERE id = p_competitionid;
	SELECT COUNT(*) INTO v_quizexists FROM thema WHERE id_number = p_themaid AND phase = 3;
	IF(v_darab = 1 AND v_quizexists = 1) THEN
		SELECT startdate, enddate INTO v_startdate, v_enddate FROM competition WHERE id = p_competitionid;
		IF(v_startdate <= NOW()) THEN
			SET p_response = 'Az adatok nem módosíthatók, mert a verseny már elkezdődött!';
		END IF;
		IF(v_enddate <= NOW()) THEN
			SET p_response = 'Az adatok nem módosíthatók, mert a verseny már véget ért!';
		END IF;
		
		OPEN curz1;
			REPEAT
				FETCH curz1 INTO c_announcement_date, c_startdate, c_enddate;
				IF ( ! done ) THEN
					/*IF( (c_enddate >= p_announcement AND p_startdate >=c_announcement_date) () ) THEN*/
					IF( (c_enddate < p_announcement AND p_enddate > c_announcement_date) || (p_enddate < c_announcement_date AND c_enddate > p_announcement) ) THEN
						SET y = 69999;
					ELSE
						SET x = 1;
					END IF;
				END IF;
			UNTIL done END REPEAT;
		CLOSE curz1;
		
		
		IF(p_response = '' AND x = 0) THEN
			UPDATE competition SET quiz_id = p_themaid, announcement_date = p_announcement, activity = 0, reward1 = p_rew1, reward2 = p_rew2, reward3 = p_rew3, reward4 = p_rew4, reward5 = p_rew5, reward6 = p_rew6, reward7 = p_rew7, startdate = p_startdate, enddate = p_enddate, button_color = p_color WHERE id = p_competitionid;
			SET p_response = 'ok';
		ELSE
			SET p_response = CONCAT(p_response, 'Nem sikerült módosítani az adatokat! ', x);
			IF(x > 0) THEN
				SET p_response = CONCAT(p_response, ' verseny időpontjával ütközik! ');
			END IF;
		END IF;
	ELSE
		SET p_response = 'Nem található ilyen azonosítójú verseny, vagy kvíz!';
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_question_in_secret` (IN `p_questionid` INT, IN `p_themaid` INT, IN `p_diff` INT, IN `p_questiontext` VARCHAR(255) CHARSET utf8, IN `p_ans1` VARCHAR(150) CHARSET utf8, IN `p_ans2` VARCHAR(150) CHARSET utf8, IN `p_ans3` VARCHAR(150) CHARSET utf8, IN `p_ans4` VARCHAR(150) CHARSET utf8, IN `p_reverify` INT, IN `p_adminid` VARCHAR(25) CHARSET utf8, OUT `p_response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE k INT;
	DECLARE v1 INT;
	DECLARE v2 INT;
	DECLARE v3 INT;
	DECLARE v4 INT;
	DECLARE v_darab INT;
	DECLARE v_temakor INT;
	DECLARE v_nehezseg INT;
	DECLARE v_kerdes VARCHAR(255);
	DECLARE v_val1 VARCHAR(150);
	DECLARE v_val2 VARCHAR(150);
	DECLARE v_val3 VARCHAR(150);
	DECLARE v_val4 VARCHAR(150);
	
	DECLARE v_allactivequestion INT;
	DECLARE v_numofquestion INT;
	DECLARE v_phase INT;
	
	DECLARE vissza VARCHAR(1000);
	DECLARE vu_temakor INT;
	DECLARE vu_nehezseg INT;
	DECLARE vu_kerdes VARCHAR(255);
	DECLARE vu_val1 VARCHAR(150);
	DECLARE vu_val2 VARCHAR(150);
	DECLARE vu_val3 VARCHAR(150);
	DECLARE vu_val4 VARCHAR(150);
	DECLARE v_admin INT;
	DECLARE v_adminusername VARCHAR(30);
START TRANSACTION;
	SET p_response = '';
	IF(LENGTH(p_questiontext) < 1 OR LENGTH(p_ans1) < 1 OR LENGTH(p_ans2) < 1 OR LENGTH(p_ans3) < 1 OR LENGTH(p_ans4) < 1 OR LENGTH(p_reverify) != 1 OR LENGTH(p_questionid) < 1 OR p_questionid < 0 OR LENGTH(p_themaid) < 1 OR LENGTH(p_diff) < 1 OR p_themaid < 1) THEN
		SET p_response = 'Helytelenek a bemeneti adatok!';
	END IF;
	SET k = is_correct_questiontext(p_questiontext);
    SET v1 = is_correct_questionanswer(p_ans1);
    SET v2 = is_correct_questionanswer(p_ans2);
    SET v3 = is_correct_questionanswer(p_ans3);
    SET v4 = is_correct_questionanswer(p_ans4);
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		SET p_response = 'Hibás Admin felhasználó!';
	END IF;
	SELECT COUNT(*) INTO v_darab FROM quiz_question WHERE id = p_questionid;
	IF((p_reverify = 0 OR p_reverify = 1) AND k = 1 AND v1 = 1 AND v2 = 1 AND v3 = 1 AND v4 = 1 AND (p_diff = -1 OR p_diff = 1 OR p_diff = 2) AND v_darab = 1 AND p_response = '') THEN
		SELECT user INTO v_adminusername FROM user WHERE id = p_adminid;
		SELECT quiz_id, difficulty, question, ans1, ans2, ans3, ans4 INTO v_temakor, v_nehezseg, v_kerdes, v_val1, v_val2, v_val3, v_val4 FROM quiz_question WHERE id = p_questionid;
		
		SELECT num_of_question, phase INTO v_numofquestion, v_phase FROM thema WHERE id_number = v_temakor;
		SELECT COUNT(*) INTO v_allactivequestion FROM quiz_question WHERE quiz_id = v_temakor AND is_active = 1; 
		IF(v_numofquestion >= v_allactivequestion - 1 AND v_phase = 3 AND p_reverify = 1) THEN
			SET p_response = 'Hiba! A művelet nem hajtható végre, mert nem maradna elég aktív kérdés a kvíz teljesítéséhez.';
		ELSE
			UPDATE quiz_question SET quiz_id = p_themaid, difficulty = p_diff, question = p_questiontext, ans1 = p_ans1, ans2 = p_ans2, ans3 = p_ans3, ans4 = p_ans4 WHERE id = p_questionid;
			IF(p_reverify = 1) THEN
				UPDATE quiz_question SET is_active = 0, is_verified = NULL WHERE id = p_questionid;
			END IF;
			SELECT quiz_id, difficulty, question, ans1, ans2, ans3, ans4 INTO vu_temakor, vu_nehezseg, vu_kerdes, vu_val1, vu_val2, vu_val3, vu_val4 FROM quiz_question WHERE id = p_questionid;
			SET vissza = 'Módositott adatok: ';
			IF(v_temakor != vu_temakor) THEN SET vissza = CONCAT(vissza, ' Témakör: ', v_temakor, '; '); END IF;
			IF(v_nehezseg != vu_nehezseg) THEN SET vissza = CONCAT(vissza, ' Nehézség: ', v_nehezseg, '; '); END IF;
			IF(v_kerdes != vu_kerdes) THEN SET vissza = CONCAT(vissza, ' Kérdés: ', v_kerdes, '; '); END IF;
			IF(v_val1 != vu_val1) THEN SET vissza = CONCAT(vissza, ' Helyes válasz: ', v_val1, '; '); END IF;
			IF(v_val2 != vu_val2) THEN SET vissza = CONCAT(vissza, ' 1. rossz válasz: ', v_val2, '; '); END IF;
			IF(v_val3 != vu_val3) THEN SET vissza = CONCAT(vissza, ' 2. rossz válasz: ', v_val3, '; '); END IF;
			IF(v_val4 != vu_val4) THEN SET vissza = CONCAT(vissza, ' 3. rossz válasz: ', v_val4, '; '); END IF;
			INSERT INTO question_comment VALUES (NULL, p_questionid, v_adminusername, vissza, NOW());
			SET p_response = 'ok';
		END IF;
	ELSE
		SET p_response = 'Hibásak a bemeneti adatok!';
	END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_quiz` (IN `p_quizid` INT, IN `p_accessquiz` INT, IN `p_numofplaying` INT, IN `p_acceptquestions` INT, IN `p_startd` VARCHAR(15) CHARSET utf8, IN `p_endd` VARCHAR(15) CHARSET utf8, IN `p_username` VARCHAR(25) CHARSET utf8, IN `p_newquizpassword` VARCHAR(128) CHARSET utf8, IN `p_oldquizpassword` VARCHAR(128) CHARSET utf8, IN `p_accountpassword` VARCHAR(128) CHARSET utf8, IN `p_verify` INT, IN `p_accessquiz_array` VARCHAR(9000) CHARSET utf8, IN `p_acceptquestion_array` VARCHAR(9000) CHARSET utf8, OUT `p_response` VARCHAR(3000) CHARSET utf8)  MODIFIES SQL DATA
BEGIN	
	DECLARE v_db INT;
	DECLARE v_toroltuser INT;
	DECLARE v_rang INT;
	DECLARE v_isdeleted INT;
	DECLARE v_owner VARCHAR(25);
	DECLARE v_oldquizpw VARCHAR(128);
	DECLARE v_accountpw VARCHAR(128);
	DECLARE v_isrequest INT DEFAULT 1;
	DECLARE v_cim VARCHAR(150) DEFAULT "";
	
	DECLARE c_id INT;
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE cc_id INT;
	DECLARE done1 BOOLEAN DEFAULT 0;
	DECLARE curz CURSOR FOR SELECT id FROM user WHERE FIND_IN_SET(id, p_accessquiz_array);        
	DECLARE curz1 CURSOR FOR SELECT id FROM user WHERE FIND_IN_SET(id, p_acceptquestion_array);
	
START TRANSACTION;
	SET p_response = "";
	SELECT pw, deleteduser INTO v_accountpw, v_toroltuser FROM user WHERE user = p_username;
	IF(LENGTH(v_accountpw) != 128) THEN
		SET p_response = CONCAT(p_response, "Nincs ilyen user! ");
	END IF;
	IF(v_accountpw != p_accountpassword) THEN
		SET p_response = CONCAT(p_response, "Hibás fiókjelszó! ");
	END IF;
	IF(v_toroltuser != 0) THEN
		SET p_response = CONCAT(p_response, "Törölt felhasználó! ");
	END IF;
	SELECT COUNT(id_number) INTO v_db FROM thema WHERE is_deleted = 0 AND is_request = 0 AND id_number = p_quizid;
	IF(v_db != 1) THEN
		SET p_response = CONCAT(p_response, "Hibás kvízazonosító! ");
	ELSE
		SELECT is_deleted, accomplished_by, password, is_request, quiz_name INTO v_isdeleted, v_owner, v_oldquizpw, v_isrequest, v_cim FROM thema WHERE id_number = p_quizid;
		IF(v_isdeleted = 1) THEN
			SET p_response = CONCAT(p_response, "Törölt kvíz! Nem áll jogodban módosítani! ");
		END IF;
		IF(v_owner != p_username) THEN
			SET p_response = CONCAT(p_response, "Nincs jogod módosítani ezt a kvízt! ");
		END IF;
		IF(v_isrequest = 1) THEN
			SET p_response = CONCAT(p_response, "A kérésre teljesített kvízeket már nem módosíthatod! ");
		END IF;
		IF(p_accessquiz != 1 AND p_accessquiz != 2 AND p_accessquiz != 3 AND p_accessquiz != 4 AND p_accessquiz != 5) THEN
			SET p_response = CONCAT(p_response, "Hiba a kvíz elérhetőség kiválasztásánál! ");
		END IF;
		IF(p_verify < 0 OR p_verify > 1000000) THEN
			SET p_response = CONCAT(p_response, "A kvíz ellenőrzési lehetőségeinél 0-1000000 közti értéket adj meg! ");
		END IF;
		SELECT level INTO v_rang FROM user WHERE user = p_username;
		IF(v_rang < 5 AND p_accessquiz = 4) THEN
			SET p_response = CONCAT(p_response, "Ezen a szinten NINCS jogod jelszavas védelmet beállítani a teszten! ");
		END IF;
		IF(LENGTH(p_newquizpassword) > 128 AND p_accessquiz = 4) THEN
			SET p_response = CONCAT(p_response, "Az új teszt jelszavának hossza nagyobb mint 128 karakter! ");
		END IF;
		IF(p_numofplaying != 1 AND p_numofplaying != 2 AND p_numofplaying != 3 AND p_numofplaying != 4 AND p_numofplaying != 5 AND p_numofplaying != 6) THEN
			SET p_response = CONCAT(p_response, "Hiba a kvízen való részvétel kiválasztásánál! ");
		END IF;
		IF(p_acceptquestions != 1 AND p_acceptquestions != 2 AND p_acceptquestions != 3 AND p_acceptquestions != 4 AND p_acceptquestions != 5) THEN
			SET p_response = CONCAT(p_response, "Hiba a kérdés fogadás kiválasztásánál! ");
		END IF;
		IF(DATEDIFF(p_endd, NOW()) < 0) THEN
			SET p_response = CONCAT(p_response, "A második dátum nem lehet kisebb a mai dátumnál! ");
		END IF;
		IF(DATEDIFF(p_endd, p_startd) < 1) THEN
			SET p_response = CONCAT(p_response, "A két dátum között legalább 1 nap legyen! ");
		END IF;
		IF(LENGTH(v_oldquizpw) < 1) THEN
			SET v_oldquizpw = NULL;
		END IF;
		IF(LENGTH(p_startd) < 1) THEN
			SET p_startd = NULL;
		END IF;
		IF(LENGTH(p_endd) < 1) THEN
			SET p_endd = NULL;
		END IF;
		IF(p_numofplaying = 4) THEN
			SET p_numofplaying = 5;
		ELSEIF(p_numofplaying = 5) THEN
			SET p_numofplaying = 10;
		ELSEIF(p_numofplaying = 6) THEN
			SET p_numofplaying = 0;
		END IF;
		
	END IF;
	
	IF(p_response = "") THEN
		IF(v_oldquizpw IS NULL) THEN
			UPDATE thema SET access = p_accessquiz WHERE id_number = p_quizid;
			IF(p_accessquiz = 4) THEN
				UPDATE thema SET password = p_newquizpassword WHERE id_number = p_quizid;
			END IF;
		ELSE
			IF(v_oldquizpw = p_oldquizpassword) THEN
				UPDATE thema SET access = p_accessquiz WHERE id_number = p_quizid;
				IF(p_accessquiz = 4) THEN
					UPDATE thema SET password = p_newquizpassword WHERE id_number = p_quizid;
				ELSE
					UPDATE thema SET password = NULL WHERE id_number = p_quizid;
				END IF;
			ELSE
				SET p_response = CONCAT(p_response, "Helytelen a teszt régi jelszava! ");
			END IF;
		END IF;
		DELETE FROM permission_play_quiz WHERE quizid = p_quizid;
		DELETE FROM permission_submit_question WHERE quizid = p_quizid;
		UPDATE thema SET num_of_playing = p_numofplaying, accept_questions = p_acceptquestions, start_date = p_startd, end_date = p_endd, verification = p_verify WHERE id_number = p_quizid;
		
		IF(p_accessquiz = 2) THEN
			BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
			OPEN curz;
				REPEAT
					FETCH curz INTO c_id;
					IF ( ! done ) THEN
						INSERT INTO permission_play_quiz VALUES(c_id, p_quizid);
					END IF;
				UNTIL done END REPEAT;
			CLOSE curz;
			END;
		END IF;
		
		IF(p_acceptquestions = 3) THEN
			BEGIN
			DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done1 = 1;
			OPEN curz1;
				REPEAT
					FETCH curz1 INTO cc_id;
					IF ( ! done1 ) THEN
						INSERT INTO permission_submit_question VALUES(cc_id, p_quizid);
					END IF;
				UNTIL done1 END REPEAT;
			CLOSE curz1;
			END;
		END IF;
		
		INSERT INTO log_data VALUES (NULL, 27, p_username, CONCAT("A/Az ", v_cim, " témájú kvíz adatai módosultak. "), 'SYSTEM', NOW(), 0);
		
	END IF;
	
	IF(p_response = "") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `upload_quizbackground` (IN `p_quizid` INT, IN `p_imagepath` VARCHAR(255) CHARSET utf8, IN `p_userid` INT, IN `p_imagesize` DOUBLE, IN `p_imageext` VARCHAR(5) CHARSET utf8, OUT `p_response` VARCHAR(500) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_db1 INT;
	DECLARE v_db2 INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_hirdb INT;
	DECLARE v_isrequest INT;
	DECLARE v_allbg INT;
	
START TRANSACTION;
	SET p_response = "";
	IF(LENGTH(p_imagepath)<1) THEN
		SET p_response = CONCAT(p_response, "A kép nem érkezett meg a szerverhez! ");
	END IF;
	IF(LENGTH(p_imagepath)>255) THEN
		SET p_response = CONCAT(p_response, "A kép útvonala legfeljebb 255 karakterből állhat! Nevezd át a képet rövidebbre! ");
	END IF;
	IF(p_imagesize <= 0 OR p_imagesize > 0.5) THEN
		SET p_response = CONCAT(p_response, "A kép mérete legfeljebb 0.5 MB lehet! ");
	END IF;
	SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
	SELECT COUNT(*) INTO v_db1 FROM thema WHERE id_number = p_quizid;
	IF(v_db != 1 OR v_db1 != 1) THEN
		SET p_response = CONCAT(p_response, "Hibás felhasználó-, vagy quiz ID! ");
	ELSE
		SELECT user INTO v_username FROM user WHERE id = p_userid;
		SELECT is_request INTO v_isrequest FROM thema WHERE id_number = p_quizid;
		SELECT COUNT(*) INTO v_allbg FROM background WHERE quiz_id = p_quizid;
		IF(v_allbg > 50) THEN
			SET p_response = CONCAT(p_response, "Egy kvízhez legfeljebb 50 képet küldhetsz be! ");
		END IF;
		
		IF(v_isrequest = 0) THEN
			SELECT COUNT(*) INTO v_db2 FROM thema WHERE id_number = p_quizid AND requested_by = v_username AND phase > 1 AND is_deleted = 0;
			IF(v_db2 != 1) THEN
				SET p_response = CONCAT(p_response, "Hiba! Helytelen kvizid, vagy userowner! ");
			ELSE
				IF(p_response = "") THEN
					INSERT INTO background VALUES(NULL, p_quizid, p_imagepath, p_userid, NOW(), p_imagesize, p_imageext, NULL, NULL, 0);
				END IF;
			END IF;
		ELSE
			SELECT COUNT(*) INTO v_db2 FROM thema WHERE id_number = p_quizid AND (undertaken_by = v_username OR accomplished_by = v_username) AND phase > 1 AND is_deleted = 0;
			IF(v_db2 != 1) THEN
				SET p_response = CONCAT(p_response, "Hiba!! Helytelen kvizid, vagy userowner! ");
			ELSE
				IF(p_response = "") THEN
					INSERT INTO background VALUES(NULL, p_quizid, p_imagepath, p_userid, NOW(), p_imagesize, p_imageext, NULL, NULL, 0);
				END IF;
			END IF;
		END IF;
	END IF;
	
	IF(p_response = "") THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verify_procedures` (IN `p_username` VARCHAR(30) CHARSET utf8)  MODIFIES SQL DATA
BEGIN

CALL warn_timeout(p_username);
CALL premium_timeout(p_username);
CALL profilehiding_timeout(p_username);
CALL level_allocation(p_username);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `warn_timeout` (IN `p_username` VARCHAR(30) CHARSET utf8)  MODIFIES SQL DATA
BEGIN
	DECLARE v_warn INT;
	DECLARE v_warnlejar DATETIME;
START TRANSACTION;
	SELECT warn, warn_expire INTO v_warn, v_warnlejar FROM user WHERE user = p_username;
	IF(v_warn = 1) THEN
		IF(v_warnlejar - NOW() < 0) THEN
			UPDATE user SET warn = 0, warn_expire = 0 WHERE user = p_username;
			UPDATE warn SET is_active = 0 WHERE userid = (SELECT id FROM user WHERE user = p_username) AND is_active = 1;
			INSERT INTO log_data VALUES (NULL, 3, p_username, 'Az általad kapott WARN ideje lejárt! Az emiatt megvont jogokat ismét engedélyeztük!', 'SYSTEM', NOW(), 0);
		END IF;
	END IF;
COMMIT;
END$$

--
-- Függvények
--
CREATE DEFINER=`root`@`localhost` FUNCTION `accept_backgroundimage` (`p_imgid` INT, `p_adminuserid` INT) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_db1 INT;
	DECLARE v_quizid INT;
	DECLARE v_isadmin INT;
	DECLARE v_db2 INT;
	DECLARE v_username VARCHAR(30);
	
	SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminuserid;
	SELECT COUNT(*) INTO v_db1 FROM background WHERE id = p_imgid AND active = 0;
	IF(v_db != 1 OR v_db1 != 1) THEN
		RETURN "Hibás Admin-, vagy image ID! ";
	ELSE
		SELECT adminuser INTO v_isadmin FROM user WHERE id = p_adminuserid;
		SELECT quiz_id INTO v_quizid FROM background WHERE id = p_imgid;
		
		SELECT COUNT(*) INTO v_db2 FROM thema WHERE id_number = v_quizid AND v_isadmin = 1;
		IF(v_db2 != 1) THEN
			RETURN "Hiba! Helytelen kvizid, vagy Admin ID! ";
		ELSE
			UPDATE background SET adminid = p_adminuserid, accept_time = NOW(), active = 1 WHERE id = p_imgid;
			RETURN "ok";
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `accept_quiz_comment` (`p_quizid` INT, `p_userid` INT, `p_commentdate` DATETIME, `p_adminid` INT) RETURNS VARCHAR(500) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_admin INT;
	DECLARE v_verified INT;
	DECLARE v_deleted INT;
	DECLARE v_lastmodified DATETIME;
	DECLARE v_verifiedtime DATETIME;
	
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		RETURN "Hibás Admin azonosító!";
	END IF;
	SELECT COUNT(*) INTO v_db FROM quiz_comment WHERE user_id = p_userid AND quiz_id = p_quizid AND comment_date = p_commentdate;
	IF(v_db < 1) THEN
		RETURN "Hibás comment azonosító!";
	ELSEIF(v_db > 1) THEN
		RETURN "Too Many Rows Exception!";
	ELSEIF(v_db = 1) THEN
		SELECT is_deleted, is_verified, last_modified, verification_time INTO v_deleted, v_verified, v_lastmodified, v_verifiedtime FROM quiz_comment WHERE user_id = p_userid AND quiz_id = p_quizid AND comment_date = p_commentdate;
		IF(v_deleted = 1) THEN
			RETURN "User által törölt hozzászólást már nem kell ellenőrizni!";
		END IF;
		IF(v_verified = 2) THEN
			RETURN "Ezt a commentet már ellenőrizték!";
		END IF;
		IF(v_verified = 0 OR (v_verified = 1 AND (v_lastmodified > v_verifiedtime) AND v_verifiedtime IS NOT NULL)) THEN
			UPDATE quiz_comment SET is_verified = 1, verified_by = p_adminid, verification_time = NOW() WHERE user_id = p_userid AND quiz_id = p_quizid AND comment_date = p_commentdate;
			RETURN "ok";
		END IF;
	ELSE
		RETURN "An error Occured!";
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `access_competition` (`p_username` VARCHAR(25) CHARSET utf8, `p_type` INT) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE uzenet VARCHAR(500);
	DECLARE v_db INT;
	DECLARE v_userid INT;
	DECLARE v_torolt INT;
	DECLARE v_phase INT;
	DECLARE v_access INT;
	DECLARE v_start_date DATETIME;
	DECLARE v_end_date DATETIME;
	DECLARE v_played INT;
	DECLARE v_toroltuser INT;
	
	DECLARE p_testid INT;
	DECLARE v_numofquestion INT;
	DECLARE v_otherquiz INT;
	
	SET v_start_date = DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s');
	SET v_end_date = DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s');
	SET uzenet = "";
	
	SELECT COUNT(quiz_id) INTO p_testid FROM competition WHERE activity = 1;
	IF(p_testid != 1) THEN
		SET uzenet = CONCAT(uzenet, "Váratlan hiba lépett fel! ");
	ELSE
		SELECT quiz_id INTO p_testid FROM competition WHERE activity = 1;
	
		SELECT COUNT(id_number) INTO v_db FROM thema WHERE id_number = p_testid;
		SELECT COUNT(id) INTO v_userid FROM user WHERE user = p_username;
		IF(v_db = 1 AND v_userid = 1) THEN
			SELECT id, deleteduser INTO v_userid, v_toroltuser FROM user WHERE user = p_username;
			SELECT t.is_deleted, t.phase, t.access, t.num_of_question, c.startdate, c.enddate INTO v_torolt, v_phase, v_access, v_numofquestion, v_start_date, v_end_date FROM thema t JOIN competition c ON (c.quiz_id = t.id_number) WHERE t.id_number = p_testid AND c.activity = 1;
			IF(v_toroltuser != 0) THEN
				SET uzenet = CONCAT(uzenet, "Törölt felhasználó! ");
			END IF;
			IF(v_torolt = 1 OR v_phase != 3) THEN
				SET uzenet = CONCAT(uzenet, "Ez a kvíz jelenleg nem érhető el! ");
			END IF;
			IF(v_start_date > NOW() AND v_start_date IS NOT NULL) THEN
				SET uzenet = CONCAT(uzenet, "A kvíz csak ", v_start_date, " után érhető el! ");
			END IF;
			IF(v_end_date < NOW() AND v_end_date IS NOT NULL) THEN
				SET uzenet = CONCAT(uzenet, "A kvíz már nem elérhető! ");
			END IF;
			IF(v_access < 1 OR v_access > 5) THEN
				SET uzenet = CONCAT(uzenet, "Hiba a kvíz elérhetőségénél! ");
			END IF;
			SELECT COUNT(*) INTO v_played FROM quiz_played WHERE user_id = v_userid AND quiz_id = p_testid AND finishing_date >= v_start_date AND finishing_date <=v_end_date;
			IF(v_played > 0) THEN
				SET uzenet = "Ezt a kvízt már lejátszottad! Nincs több lehetőséged! ";
			END IF;		
		ELSE
			SET uzenet = "Hibás kvíz, vagy user azonosító!";
		END IF;
	
	END IF;
	
	IF(p_type = 1) THEN
		IF(uzenet = "") THEN			
			SELECT COUNT(*) INTO v_otherquiz FROM live_question WHERE user = p_username;
			IF(v_otherquiz > 0) THEN
				RETURN "Egy másik belépést észleltünk! Előbb fejezd be a már elkezdett kvízt és utána kezdj neki az újnak!";
			END IF;
			SET v_numofquestion = v_numofquestion + 1;
			INSERT INTO live_question (id, difficulty, question, ans1, ans2, ans3, ans4, user, bool, type, position, correct, own_answer) SELECT DISTINCT id, difficulty, question, ans1, ans2, ans3, ans4, p_username, 0, p_testid, 0, 0, NULL FROM quiz_question WHERE is_active = 1 AND quiz_id = p_testid ORDER BY RAND() LIMIT v_numofquestion;
			RETURN "ok";
		ELSE
			RETURN uzenet;
		END IF;
	ELSE
		IF(uzenet = "") THEN
			RETURN "ok";
		ELSE
			RETURN uzenet;
		END IF;
	END IF;
	
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `access_generalquiz` (`p_username` VARCHAR(30) CHARSET utf8) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_iddb INT;
DECLARE v_otherquiz INT;
DECLARE v_questiontype INT;
DECLARE v_help INT;

SELECT COUNT(id) INTO v_iddb FROM user WHERE user = p_username AND deleteduser = 0;
IF(v_iddb != 1) THEN
	RETURN "Hibás felhasználó!";
END IF;

SELECT COUNT(*) INTO v_otherquiz FROM live_question WHERE user = p_username;
IF(v_otherquiz > 0) THEN
	RETURN "Belépés megtagadva";
ELSE
	SELECT questiontype, help INTO v_questiontype, v_help FROM user WHERE user = p_username;
	IF(v_questiontype = 0) THEN
		INSERT INTO live_question (id, difficulty, question, ans1, ans2, ans3, ans4, user, bool, type, position, correct, own_answer) SELECT DISTINCT id, 0, question, ans1, ans2, ans3, ans4, p_username, 0, -1, 0, 0, NULL FROM quiz_question WHERE is_active = 1 AND quiz_id BETWEEN 1 AND 10 ORDER BY RAND() LIMIT 11;
	ELSEIF(v_questiontype = 1) THEN
		INSERT INTO live_question (id, difficulty, question, ans1, ans2, ans3, ans4, user, bool, type, position, correct, own_answer) SELECT DISTINCT id, 0, question, ans1, ans2, ans3, ans4, p_username, 0, -1, 0, 0, NULL FROM quiz_question WHERE is_active = 1 AND difficulty = 1 AND quiz_id BETWEEN 1 AND 10 ORDER BY RAND() LIMIT 11;
	ELSEIF(v_questiontype = 2) THEN
		INSERT INTO live_question (id, difficulty, question, ans1, ans2, ans3, ans4, user, bool, type, position, correct, own_answer) SELECT DISTINCT id, 0, question, ans1, ans2, ans3, ans4, p_username, 0, -1, 0, 0, NULL FROM quiz_question WHERE is_active = 1 AND difficulty = 2 AND quiz_id BETWEEN 1 AND 10 ORDER BY RAND() LIMIT 11;
	END IF;
	RETURN "ok";
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `access_practicemode` (`p_username` VARCHAR(30) CHARSET utf8) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_iddb INT;
DECLARE v_otherquiz INT;
DECLARE v_questiontype INT;
DECLARE v_help INT;

SELECT COUNT(id) INTO v_iddb FROM user WHERE user = p_username AND deleteduser = 0;
IF(v_iddb != 1) THEN
	RETURN "Hibás felhasználó!";
END IF;

SELECT COUNT(*) INTO v_otherquiz FROM live_question WHERE user = p_username;
IF(v_otherquiz > 0) THEN
	RETURN "Belépés megtagadva";
ELSE
	INSERT INTO live_question (id, difficulty, question, ans1, ans2, ans3, ans4, user, bool, type, position, correct, own_answer) SELECT DISTINCT id, 0, question, ans1, ans2, ans3, ans4, p_username, 0, -2, 0, 0, NULL FROM quiz_question WHERE is_active = 1 AND difficulty = 1 AND quiz_id BETWEEN 1 AND 10 ORDER BY RAND() LIMIT 11;
	RETURN "ok";
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `access_quiz` (`p_username` VARCHAR(25) CHARSET utf8, `p_testid` INT, `p_pw` VARCHAR(128) CHARSET utf8) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE uzenet VARCHAR(2000);
	DECLARE v_otherquiz INT;
	DECLARE v_tesztelerhetoseg INT;
	DECLARE v_baratok1 INT;
	DECLARE v_baratok2 INT;
	DECLARE v_db INT;
	DECLARE v_userid INT;
	DECLARE v_admin INT;
	DECLARE v_torolt INT;
	DECLARE v_phase INT;
	DECLARE v_numofquestion INT;
	DECLARE v_numofplaying INT;
	DECLARE v_numofplayingUser INT;
	DECLARE v_access INT;
	DECLARE v_start_date DATE;
	DECLARE v_end_date DATE;
	DECLARE v_accomplishedby VARCHAR(25);
	DECLARE v_accomplishedbyId INT;
	DECLARE v_password VARCHAR(128);
	DECLARE v_ok INT;
	DECLARE v_toroltuser INT;

	SET v_start_date = DATE_FORMAT(NOW(), '%Y-%m-%d');
	SET v_end_date = DATE_FORMAT(NOW(), '%Y-%m-%d');
	SET uzenet = "";
	SET v_ok = 0;
	
	SELECT COUNT(*) INTO v_otherquiz FROM live_question WHERE user = p_username;
	IF(v_otherquiz > 0) THEN
		RETURN "Egy másik belépést észleltünk!";
	END IF;
	
	SELECT COUNT(id_number) INTO v_db FROM thema WHERE id_number = p_testid AND 1 > (SELECT COUNT(*) FROM competition WHERE quiz_id = p_testid AND activity = 1);
	SELECT COUNT(id) INTO v_userid FROM user WHERE user = p_username;
	IF(v_db = 1 AND v_userid = 1) THEN
		SELECT id, adminuser, deleteduser INTO v_userid, v_admin, v_toroltuser FROM user WHERE user = p_username;
		SELECT t.is_deleted, t.phase, t.num_of_question, t.num_of_playing, t.access, t.start_date, t.end_date, t.accomplished_by, t.password INTO v_torolt, v_phase, v_numofquestion, v_numofplaying, v_access, v_start_date, v_end_date, v_accomplishedby, v_password FROM thema t WHERE t.id_number = p_testid;
		IF(v_toroltuser != 0) THEN
			SET uzenet = CONCAT(uzenet, "Törölt felhasználó! ");
		END IF;
		IF(v_torolt = 1 OR v_phase != 3) THEN
			SET uzenet = CONCAT(uzenet, "Ez a kvíz jelenleg nem érhető el! ");
		END IF;
		IF(v_start_date > CURDATE() AND v_start_date IS NOT NULL) THEN
			SET uzenet = CONCAT(uzenet, "A kvíz csak ", v_start_date, " után érhető el! ");
		END IF;
		IF(v_end_date < CURDATE() AND v_end_date IS NOT NULL) THEN
			SET uzenet = CONCAT(uzenet, "A kvíz már nem elérhető! ");
		END IF;
		SELECT COUNT(q.user_id) INTO v_numofplayingUser FROM quiz_played q JOIN user u ON (q.user_id = u.id) WHERE u.user = p_username AND q.quiz_id = p_testid;
		IF(v_numofplaying - v_numofplayingUser <= 0 AND v_numofplaying != 0) THEN
			SET uzenet = CONCAT(uzenet, "Nincs több lehetőséged lejátszani ezt a kvízt! ");
		END IF;
		IF(v_access < 1 OR v_access > 5) THEN
			SET uzenet = CONCAT(uzenet, "Hiba a kvíz elérhetőségénél! ");
		END IF;
		
		IF(uzenet = "") THEN
			IF(v_access = 1) THEN
				IF(v_admin = 1 OR v_accomplishedby = p_username) THEN
					SET v_ok = 1;
				ELSE
					SET uzenet = CONCAT(uzenet, "Nincs jogod elérni ezt a kvízt! ");
				END IF;
			ELSEIF(v_access = 2) THEN
				SELECT COUNT(quizid) INTO v_tesztelerhetoseg FROM permission_play_quiz WHERE userid = v_userid AND quizid = p_testid;
				IF(v_admin = 1 OR v_accomplishedby = p_username OR v_tesztelerhetoseg > 0) THEN
					SET v_ok = 1;
				ELSE
					SET uzenet = CONCAT(uzenet, "Nincs jogod elérni ezt a kvízt! ");
				END IF;
			ELSEIF(v_access = 3) THEN
				SET v_ok = 1;
			ELSEIF(v_access = 5) THEN
				SELECT u.id INTO v_accomplishedbyId FROM user u JOIN thema t ON (u.user = t.accomplished_by) WHERE t.id_number = p_testid;
				SELECT COUNT(*) INTO v_baratok1 FROM friend WHERE id1 = v_accomplishedbyId AND id2 = v_userid AND status = 1;
				SELECT COUNT(*) INTO v_baratok2 FROM friend WHERE id2 = v_accomplishedbyId AND id1 = v_userid AND status = 1;
				IF(v_admin = 1 OR v_accomplishedby = p_username OR (v_baratok1+v_baratok2)>0) THEN
					SET v_ok = 1;
				ELSE
					SET uzenet = CONCAT(uzenet, "Nincs jogod elérni ezt a kvízt! ");
				END IF;
			ELSEIF(v_access = 4) THEN
				IF(LENGTH(v_password) > 0) THEN
					IF(v_password = p_pw) THEN
						SET v_ok = 1;
					ELSE
						SET uzenet = CONCAT(uzenet, "Hibás jelszó! ");
					END IF;
				ELSE
					SET v_ok = 1;
				END IF;
			END IF;
		END IF;
			
	ELSE
		SET uzenet = "Hibás kvíz, vagy user azonosító!";
	END IF;
	
	
	IF(v_ok = 1) THEN
		SET v_numofquestion = v_numofquestion + 1;
		INSERT INTO live_question (id, difficulty, question, ans1, ans2, ans3, ans4, user, bool, type, position, correct, own_answer) SELECT DISTINCT id, difficulty, question, ans1, ans2, ans3, ans4, p_username, 0, p_testid, 0, 0, NULL FROM quiz_question WHERE is_active = 1 AND quiz_id = p_testid ORDER BY RAND() LIMIT v_numofquestion;
		SET uzenet = "ok";
		RETURN "ok";
	ELSE
		RETURN uzenet;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `censore_quiz_comment` (`p_quizid` INT, `p_userid` INT, `p_commentdate` DATETIME, `p_modifiedcomment` VARCHAR(3000) CHARSET utf8mb4, `p_moderatedcomment` VARCHAR(500) CHARSET utf8mb4, `p_adminid` INT) RETURNS VARCHAR(500) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_admin INT;
	DECLARE v_verified INT;
	DECLARE v_deleted INT;
	DECLARE v_lastmodified DATETIME;
	DECLARE v_verifiedtime DATETIME;
	
	IF(LENGTH(p_modifiedcomment) < 1 OR LENGTH(p_modifiedcomment) > 3000) THEN
		RETURN "A módosított comment hossza 1-3000 karakter lehet!";
	END IF;
	IF(LENGTH(p_moderatedcomment) < 10 OR LENGTH(p_moderatedcomment) > 400) THEN
		RETURN "A moderátori comment hossza 10-400 karakter lehet!";
	END IF;
	SELECT COUNT(*) INTO v_admin FROM user WHERE id = p_adminid AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		RETURN "Hibás Admin azonosító!";
	END IF;
	SELECT COUNT(*) INTO v_db FROM quiz_comment WHERE user_id = p_userid AND quiz_id = p_quizid AND comment_date = p_commentdate;
	IF(v_db < 1) THEN
		RETURN "Hibás comment azonosító!";
	ELSEIF(v_db > 1) THEN
		RETURN "Too Many Rows Exception!";
	ELSEIF(v_db = 1) THEN
		SELECT is_deleted, is_verified, last_modified, verification_time INTO v_deleted, v_verified, v_lastmodified, v_verifiedtime FROM quiz_comment WHERE user_id = p_userid AND quiz_id = p_quizid AND comment_date = p_commentdate;
		IF(v_deleted = 1) THEN
			RETURN "User által törölt hozzászólást már nem kell ellenőrizni!";
		END IF;
		IF(v_verified = 2) THEN
			RETURN "Ezt a commentet már ellenőrizték!";
		END IF;
		IF(v_verified = 0 OR (v_verified = 1 AND (v_lastmodified > v_verifiedtime) AND v_verifiedtime IS NOT NULL)) THEN
			UPDATE quiz_comment SET comment_text = p_modifiedcomment, moderation = p_moderatedcomment, is_verified = 2, verified_by = p_adminid, verification_time = NOW() WHERE user_id = p_userid AND quiz_id = p_quizid AND comment_date = p_commentdate;
			RETURN "ok";
		END IF;
	ELSE
		RETURN "An error Occured!";
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `delete_account` (`p_userid` INT, `p_adminuserid` INT, `p_reason` VARCHAR(100) CHARSET utf8, `p_pw` VARCHAR(128) CHARSET utf8, `p_mydeletion` INT) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_toroltuser INT;
DECLARE v_db INT DEFAULT 0;
DECLARE v_username VARCHAR(30);
DECLARE v_adminusername VARCHAR(30);
DECLARE v_adminuser INT;
DECLARE v_isadmin INT;
DECLARE v_pw VARCHAR(128);

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen user azonosító!";
END IF;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminuserid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen admin azonosító!";
END IF;

IF(LENGTH(p_reason) < 5 OR LENGTH(p_reason) > 100) THEN
	RETURN "Helytelen érték a p_reason!";
END IF;

IF(p_mydeletion != 0 AND p_mydeletion != 1) THEN
	RETURN "Helytelen érték a p_mydeletion!";
END IF;

SELECT adminuser INTO v_adminuser FROM user WHERE id = p_adminuserid;
IF(p_userid != p_adminuserid) THEN
	IF(v_adminuser != 1) THEN
		RETURN "Ez a funkció csak Admin felhasználóknak megengedett!";
	END IF;
END IF;

SELECT deleteduser INTO v_toroltuser FROM user WHERE id = p_userid;
IF(v_toroltuser != 0) THEN
	RETURN "Ezt a felhasználót már törölték!!";
END IF;


SELECT user INTO v_adminusername FROM user WHERE id = p_adminuserid;
SELECT user, pw, adminuser INTO v_username, v_pw, v_isadmin FROM user WHERE id = p_userid;

IF(p_mydeletion = 1) THEN
	IF(v_pw != p_pw) THEN
		RETURN "Hibás jelszó!";
	END IF;
	UPDATE user SET deleteduser = 1, adminuser = 0, keep_level = 0, lawtousechat = 0, lawtosendquestion = 0, lawtopostnews = 0, lawtosearchuser = 0, lawtoeditfaq = 0, lawtogetpoints = 0, lawtouserequests = 0, lawtocreatequiz = 0, lawtosendmail = 0, delete_reason = "Saját fiók törlése." WHERE id = p_userid;
	DELETE FROM live_question WHERE user = v_username;
	INSERT INTO log_data VALUES (NULL, 30, v_username, "Ezt a fiókot a felhasználó törölte. Indok: (saját fiók törlése)", 'SYSTEM', NOW(), 0);
ELSE
	IF(v_isadmin = 1) THEN
		RETURN "Admin felhasználók nem törölhetők! A törléshez vissza kell vonni a felhasználó Admin jogát!";
	END IF;
	UPDATE user SET deleteduser = 1, adminuser = 0, keep_level = 0, lawtousechat = 0, lawtosendquestion = 0, lawtopostnews = 0, lawtosearchuser = 0, lawtoeditfaq = 0, lawtogetpoints = 0, lawtouserequests = 0, lawtocreatequiz = 0, lawtosendmail = 0, delete_reason = p_reason WHERE id = p_userid;
	DELETE FROM live_question WHERE user = v_username;
	INSERT INTO log_data VALUES (NULL, 30, v_username, CONCAT("Ezt a fiókot egy Admin törölte a következő indokkal: ", p_reason), v_adminusername, NOW(), 0);
END IF;

RETURN "ok";

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `delete_backgroundimage` (`p_imgid` INT, `p_userid` INT) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_db1 INT;
	DECLARE v_quizid INT;
	DECLARE v_isadmin INT;
	DECLARE v_db2 INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_isrequest INT;
	
	SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
	SELECT COUNT(*) INTO v_db1 FROM background WHERE id = p_imgid;
	IF(v_db != 1 OR v_db1 != 1) THEN
		RETURN "Hibás felhasználó-, vagy image ID! ";
	ELSE
		SELECT user, adminuser INTO v_username, v_isadmin FROM user WHERE id = p_userid;
		SELECT quiz_id INTO v_quizid FROM background WHERE id = p_imgid;
		SELECT is_request INTO v_isrequest FROM thema WHERE id_number = v_quizid;
		
		IF(v_isrequest = 0) THEN
			SELECT COUNT(*) INTO v_db2 FROM thema WHERE id_number = v_quizid AND (requested_by = v_username OR v_isadmin = 1);
			IF(v_db2 != 1) THEN
				RETURN "Hiba! Helytelen kvizid, vagy userowner, vagy Admin ID! ";
			ELSE
				DELETE FROM background WHERE id = p_imgid;
				RETURN "ok";
			END IF;
		ELSE
			SELECT COUNT(*) INTO v_db2 FROM thema WHERE id_number = p_quizid AND (undertaken_by = v_username OR accomplished_by = v_username OR v_isadmin = 1);
			IF(v_db2 != 1) THEN
				RETURN "Hiba!! Helytelen kvizid, vagy userowner! ";
			ELSE
				DELETE FROM background WHERE id = p_imgid;
				RETURN "ok";
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `delete_enable_quiz` (`p_quizid` INT, `p_adminusername` VARCHAR(30) CHARSET utf8, `p_reason` VARCHAR(150) CHARSET utf8, `p_action` INT) RETURNS VARCHAR(500) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_admin INT;
	DECLARE v_isdeleted INT;
	DECLARE v_phase INT;
	DECLARE v_quizname VARCHAR(100);
	DECLARE v_user VARCHAR(30);
	
	IF(LENGTH(p_reason) < 5 OR LENGTH(p_reason) > 150) THEN
		RETURN "Az művelet okának hossza 5-150 között legyen!";
	END IF;
	IF(p_action != 0  AND p_action != 1) THEN
		RETURN "Hibás művelet azonosító!";
	END IF;
	SELECT COUNT(*) INTO v_admin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		RETURN "Hibás Admin azonosító!";
	END IF;
	SELECT COUNT(id_number) INTO v_db FROM thema WHERE id_number = p_quizid;
	IF(v_db != 1) THEN
		RETURN "Hibás kvíz azonosító!";
	ELSE
		SELECT is_deleted, quiz_name, phase, requested_by INTO v_isdeleted, v_quizname, v_phase, v_user FROM thema WHERE id_number = p_quizid;
		IF(v_phase < 2 || v_phase > 3) THEN
			RETURN "Ez a művelet csak 2. vagy 3. fázisú kvízek esetén használható!";
		END IF;
		IF(v_isdeleted = 0 AND p_action = 0) THEN
			RETURN "A kvíz nincsen törölve! Nem történt módosulás!";
		ELSEIF(v_isdeleted = 1 AND p_action = 1) THEN
			RETURN "A kvíz törölve van! Nem történt módosulás!";
		ELSE
			UPDATE thema SET is_deleted = p_action WHERE id_number = p_quizid;
			IF(p_action = 1) THEN
				INSERT INTO log_data VALUES(NULL, 17, v_user, CONCAT("A/Az ", v_quizname, " nevű kvízt törölték a következő indokkal: ", p_reason), p_adminusername, NOW(), 0);
			ELSE
				INSERT INTO log_data VALUES(NULL, 14, v_user, CONCAT("A/Az ", v_quizname, " nevű kvíz újra aktív, melynek oka: ", p_reason), p_adminusername, NOW(), 0);
			END IF;
		END IF;
		RETURN "ok";
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `delete_played_quiz` (`p_testid` INT, `p_adminusername` VARCHAR(30) CHARSET utf8) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_admin INT;
	
	SELECT COUNT(*) INTO v_admin FROM user WHERE user = p_adminusername AND adminuser = 1 AND deleteduser = 0;
	IF(v_admin != 1) THEN
		RETURN "Hibás Admin azonosító!";
	END IF;
	SELECT COUNT(test_id) INTO v_db FROM quiz_played WHERE test_id = p_testid;
	IF(v_db != 1) THEN
		RETURN "Hibás teszt azonosító!";
	ELSE
		DELETE FROM played_quiz_question WHERE quiz_id = p_testid;
		DELETE FROM quiz_played WHERE test_id = p_testid;
		RETURN "ok";
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `delete_warn` (`p_userid` INT, `p_adminuserid` INT, `p_delreason` VARCHAR(100) CHARSET utf8) RETURNS VARCHAR(500) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_warn INT;
DECLARE v_db INT DEFAULT 0;
DECLARE v_username VARCHAR(30);
DECLARE v_adminusername VARCHAR(30);
DECLARE v_adminuser INT;
DECLARE v_warningstarted DATETIME;
DECLARE v_toroltuser INT;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen user azonosító!";
END IF;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminuserid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen admin azonosító!";
END IF;

SELECT COUNT(*) INTO v_db FROM warn WHERE userid = p_userid AND warningends >= NOW() AND is_active = 1;
IF(v_db != 1) THEN
	RETURN "A felhasználó jelenleg NINCS WARN alatt van! Így nincs, amit eltörölni!";
END IF;
SELECT warningstarted INTO v_warningstarted FROM warn WHERE userid = p_userid AND warningends >= NOW() AND is_active = 1;

SELECT warn, deleteduser INTO v_warn, v_toroltuser FROM user WHERE id = p_userid;
IF(v_toroltuser != 0) THEN
	RETURN "Törölt felhasználó!! Ez a beállítás nem engedélyezett!";
END IF;
IF(v_warn = 0) THEN
	RETURN "A felhasználó jelenleg nincs WARN alatt van! Így nincs, amit eltörölni!";
END IF;

SELECT adminuser INTO v_adminuser FROM user WHERE id = p_adminuserid;
IF(v_adminuser != 1) THEN
	RETURN "Ez a funkció csak Admin felhasználóknak megengedett!";
END IF;

SELECT user INTO v_username FROM user WHERE id = p_userid;
SELECT user INTO v_adminusername FROM user WHERE id = p_adminuserid;


UPDATE user SET warn = 0, warn_expire = 0, keep_level = 0 WHERE id = p_userid;
UPDATE warn SET deletedby = p_adminuserid, delete_reason = p_delreason, delete_time = NOW(), is_active = 0 WHERE userid = p_userid AND warningstarted = v_warningstarted AND is_active = 1;
INSERT INTO log_data VALUES (NULL, 3, v_username, CONCAT('Az általad kapott WARN-t visszavontuk!! A visszavonás oka: ', p_delreason), v_adminusername, NOW(), 0);
RETURN "ok";

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `export_pdf` (`p_testid` INT, `p_userid` INT, `p_username` VARCHAR(30) CHARSET utf8) RETURNS INT(11) READS SQL DATA
BEGIN
	DECLARE v_darab INT DEFAULT 0;
	DECLARE v_userid INT;
	DECLARE v_quizid INT;
	DECLARE v_ellenorzes INT;
	DECLARE v_aktualisellenorzott INT;
	DECLARE v_osszesellenorzott INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_feltolto VARCHAR(30);
	DECLARE v_rang INT;
	DECLARE v_toroltuser INT;
	
	IF(p_testid < 1) THEN
		RETURN -1;
	END IF;
	SELECT COUNT(level) INTO v_rang FROM user WHERE id = p_userid;
	IF(v_rang = 1) THEN
		SELECT level, deleteduser INTO v_rang, v_toroltuser FROM user WHERE id = p_userid;
		IF(v_rang < 2) THEN
			RETURN -5;
		END IF;
		IF(v_toroltuser != 0) THEN
			RETURN -5;
		END IF;
	ELSE
		RETURN -4;
	END IF;
	SELECT COUNT(*) INTO v_darab FROM quiz_played WHERE test_id = p_testid;
	IF(v_darab = 1) THEN
		SELECT user_id, quiz_id, is_verified INTO v_userid, v_quizid, v_aktualisellenorzott FROM quiz_played WHERE test_id = p_testid;
		SELECT COUNT(*) INTO v_darab FROM thema WHERE id_number = v_quizid;
		IF(v_darab = 1) THEN
			SELECT accomplished_by, verification INTO v_feltolto, v_ellenorzes FROM thema WHERE id_number = v_quizid;
			SELECT COUNT(*) INTO v_osszesellenorzott FROM quiz_played WHERE user_id = p_userid AND quiz_id = v_quizid AND is_verified = 1;
			IF(v_userid = p_userid AND (v_aktualisellenorzott = 1 OR v_ellenorzes = -1 OR (v_ellenorzes - v_osszesellenorzott) > 0)) THEN
				UPDATE quiz_played SET is_verified = 1 WHERE test_id = p_testid;
				RETURN 1;
			ELSEIF(v_feltolto = p_username) THEN
				RETURN 1;
			ELSE
				RETURN -2;
			END IF;
		ELSE
			RETURN -3;
		END IF;
		
	ELSE
		RETURN -4;
	END IF;
	
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `export_pdf_admin` (`p_testid` INT, `p_userid` INT, `p_username` VARCHAR(30) CHARSET utf8) RETURNS INT(11) READS SQL DATA
BEGIN
	DECLARE v_darab INT DEFAULT 0;
	
	IF(p_testid < 1) THEN
		RETURN -1;
	END IF;

	SELECT COUNT(*) INTO v_darab FROM quiz_played WHERE test_id = p_testid;
	IF(v_darab = 1) THEN
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;
	
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `free_premium` (`p_userid` INT, `p_adminid` INT, `p_delay` INT) RETURNS VARCHAR(250) CHARSET utf8 NO SQL
BEGIN
	DECLARE v_db INT;
	DECLARE v_warn INT;
	DECLARE v_toroltuser INT;
	DECLARE v_premium INT;
	DECLARE v_username VARCHAR(30);
	DECLARE v_adminusername VARCHAR(30);
	
	IF(p_delay < 1 OR p_delay > 365) THEN
		RETURN "Az ingyen Prémium ideje legalább 1 nap és legfeljebb 1 év (365 nap)";
	END IF;
	
	SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
	IF(v_db != 1) THEN
		RETURN "Érvénytelen user azonosító!";
	END IF;
	
	SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminid AND adminuser = 1;
	IF(v_db != 1) THEN
		RETURN "Érvénytelen admin azonosító!";
	END IF;
	
	SELECT user INTO v_adminusername FROM user WHERE id = p_adminid AND adminuser = 1;
	SELECT user, warn, premium, deleteduser INTO v_username, v_warn, v_premium, v_toroltuser FROM user WHERE id = p_userid;
	IF(v_toroltuser != 0) THEN
		RETURN "Törölt felhasználó!! Ez a beállítás nem engedélyezett!";
	END IF;
	IF(v_premium = 1) THEN
		RETURN 'A felhasználó jelenleg prémium tag!';
	END IF;
	IF(v_warn != 0) THEN
		RETURN 'A felhasználó Warn alatt van! Ez alatt NEM lehet prémium tag!!!';
	END IF;
	
	IF(v_premium = 0 AND v_warn = 0) THEN
		UPDATE user SET premium = 1, premium_expire = NOW() + INTERVAL p_delay DAY, lawtousechat = 1, lawtosendquestion = 1, lawtosearchuser = 1, lawtouserequests = 1, lawtogetpoints = 1, lawtosendmail = 1, lawtocreatequiz = 1, lawtopostnews = 1 WHERE id = p_userid;
		INSERT INTO premium VALUES(p_userid, 0, 0, p_delay, p_adminid, NOW(), NOW() + INTERVAL p_delay DAY, NULL, NULL, NULL, 1);
		INSERT INTO log_data VALUES (NULL, 6, v_username, CONCAT('Ingyenes Prémium tagságod lett, amelynek ideje: ', p_delay, ' nap.'), v_adminusername, NOW(), 0);
		RETURN "ok";
	END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_friendship_status` (`p_username` VARCHAR(25) CHARSET utf8, `p_friendname` VARCHAR(25) CHARSET utf8) RETURNS INT(11) READS SQL DATA
BEGIN
    DECLARE v_id1 INT;
    DECLARE v_id2 INT;
    DECLARE v_statusz INT;
    DECLARE v_sorszam INT DEFAULT 0;
    DECLARE v_uzenet VARCHAR(500);
	DECLARE v_returncode INT DEFAULT -3;
    DECLARE v_szam INT;
    
    IF(is_realuser(p_username) = 1 AND is_realuser(p_friendname) = 1 AND p_username != p_friendname) THEN
        SELECT id INTO v_id1 FROM user WHERE user = p_username;
        SELECT id INTO v_id2 FROM user WHERE user = p_friendname;
        SELECT COUNT(*) INTO v_sorszam FROM friend WHERE (id1 = v_id1 AND id2 = v_id2) OR (id1 = v_id2 AND id2 = v_id1);
        IF(v_sorszam = 1) THEN      
            SELECT COUNT(*) INTO v_szam FROM friend WHERE id1 = v_id1 AND id2 = v_id2;
            IF(v_szam = 1) THEN
            
                SELECT status INTO v_statusz FROM friend WHERE id1 = v_id1 AND id2 = v_id2;     
                IF(v_statusz = 0) THEN
                    SET v_uzenet = "Már barátnak jelölted ezt a felhasználót korábban. Várd meg amíg visszaigazol!";
					SET v_returncode = 2;
					RETURN v_returncode;
                ELSEIF(v_statusz = 1) THEN
                    SET v_uzenet = "Jelenleg barátok vagytok!";
					SET v_returncode = 1;
					RETURN v_returncode;
                ELSE
                    SET v_uzenet = "Barátnak jelölés MEGTAGADVA!";
					SET v_returncode = 4;
					RETURN v_returncode;
                END IF;
            
            ELSE
            
                SELECT status INTO v_statusz FROM friend WHERE id1 = v_id2 AND id2 = v_id1;
                IF(v_statusz = 0) THEN
                    SET v_uzenet = "Ez a felhasználó korábban barátnak jelölt. Igazold vissza, ha szeretnéd!";
					SET v_returncode = 3;
					RETURN v_returncode;
                ELSEIF(v_statusz = 1) THEN
                    SET v_uzenet = "Jelenleg barátok vagytok!";
					SET v_returncode = 1;
					RETURN v_returncode;
                ELSE
                    SET v_uzenet = "Ezt a felhasználót letiltottad!";
					SET v_returncode = 5;
					RETURN v_returncode;
                END IF;
            END IF;
        ELSEIF(v_sorszam = 0) THEN
            SET v_uzenet = "A baratnak jeloles lehetseges.";
			SET v_returncode = 0;
			RETURN v_returncode;
        ELSE
            SET v_uzenet = "Error! Too many rows exception";
			SET v_returncode = -1;
			RETURN v_returncode;
        END IF;
    
    ELSE
        SET v_uzenet = "Wrong input parameters! Try again!";
		SET v_returncode = -2;
		RETURN v_returncode;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `give_warn` (`p_lawtogetpoints` INT, `p_lawtousechat` INT, `p_lawtouserequests` INT, `p_lawtosendmail` INT, `p_lawtocreatequiz` INT, `p_lawtosendquestion` INT, `p_lawtosearchuser` INT, `p_lawtopostnews` INT, `p_minuspoints` INT, `p_warndelay` INT, `p_warnreason` VARCHAR(100) CHARSET utf8, `p_userid` INT, `p_adminuserid` INT) RETURNS VARCHAR(700) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_lawtogetpoints INT;
DECLARE v_lawtousechat INT;
DECLARE v_lawtouserequests INT;
DECLARE v_lawtosendmail INT;
DECLARE v_lawtocreatequiz INT;
DECLARE v_lawtosendquestion INT;
DECLARE v_lawtosearchuser INT;
DECLARE v_lawtopostnews INT;
DECLARE v_toroltuser INT;
DECLARE v_warn INT;
DECLARE v_db INT DEFAULT 0;
DECLARE v_username VARCHAR(30);
DECLARE v_adminusername VARCHAR(30);
DECLARE v_adminuser INT;
DECLARE v_regijogok INT;
DECLARE v_ujjogok INT;
DECLARE v_megvontjogok VARCHAR(500) DEFAULT "";

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen user azonosító!";
END IF;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminuserid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen admin azonosító!";
END IF;

IF(p_minuspoints < 100 OR p_minuspoints > 10000) THEN
	RETURN "A levont pontok értéke 100-10000 között legyen!";
END IF;
IF(p_warndelay < 3 OR p_warndelay > 100) THEN
	RETURN "A Warn ideje 3-100 nap!";
END IF;

IF(LENGTH(p_warnreason)<5 OR LENGTH(p_warnreason)>100) THEN
	RETURN "A Warn oka 5-100 karakter legyen!";
END IF;

IF(p_lawtogetpoints != 0 AND p_lawtogetpoints != 1) THEN
	RETURN "Helytelen érték a p_lawtogetpoints!";
END IF;

IF(p_lawtousechat != 0 AND p_lawtousechat != 1) THEN
	RETURN "Helytelen érték a p_lawtousechat!";
END IF;

IF(p_lawtouserequests != 0 AND p_lawtouserequests != 1) THEN
	RETURN "Helytelen érték a p_lawtouserequests!";
END IF;

IF(p_lawtosendmail != 0 AND p_lawtosendmail != 1) THEN
	RETURN "Helytelen érték a p_lawtosendmail!";
END IF;

IF(p_lawtocreatequiz != 0 AND p_lawtocreatequiz != 1) THEN
	RETURN "Helytelen érték a p_lawtocreatequiz!";
END IF;

IF(p_lawtosendquestion != 0 AND p_lawtosendquestion != 1) THEN
	RETURN "Helytelen érték a p_lawtosendquestion!";
END IF;

IF(p_lawtosearchuser != 0 AND p_lawtosearchuser != 1) THEN
	RETURN "Helytelen érték a p_lawtosearchuser!";
END IF;

IF(p_lawtopostnews != 0 AND p_lawtopostnews != 1) THEN
	RETURN "Helytelen érték a p_lawtopostnews!";
END IF;

SELECT warn, deleteduser INTO v_warn, v_toroltuser FROM user WHERE id = p_userid;
IF(v_toroltuser != 0) THEN
	RETURN "Törölt felhasználó!! Ez a beállítás nem engedélyezett!";
END IF;
IF(v_warn != 0) THEN
	RETURN "A felhasználó jelenleg WARN alatt van! Nem adható WARN annak lejártáig!";
END IF;

SELECT adminuser INTO v_adminuser FROM user WHERE id = p_adminuserid;
IF(v_adminuser != 1) THEN
	RETURN "Ez a funkció csak Admin felhasználóknak megengedett!";
END IF;

SELECT user, lawtogetpoints, lawtousechat, lawtouserequests, lawtosendmail, lawtocreatequiz, lawtosendquestion, lawtosearchuser, lawtopostnews INTO v_username, v_lawtogetpoints, v_lawtousechat, v_lawtouserequests, v_lawtosendmail, v_lawtocreatequiz, v_lawtosendquestion, v_lawtosearchuser, v_lawtopostnews FROM user WHERE id = p_userid;
SELECT user INTO v_adminusername FROM user WHERE id = p_adminuserid;

IF(v_lawtogetpoints - p_lawtogetpoints < 0) THEN
	RETURN "A jogokat kizárólag megvonni szabad Warn idejére! (lawtogetpoints)!";
END IF;
IF(v_lawtousechat - p_lawtousechat < 0) THEN
	RETURN "A jogokat kizárólag megvonni szabad Warn idejére! (lawtousechat)!";
END IF;
IF(v_lawtouserequests - p_lawtouserequests < 0) THEN
	RETURN "A jogokat kizárólag megvonni szabad Warn idejére! (lawtouserequests)!";
END IF;
IF(v_lawtosendmail - p_lawtosendmail < 0) THEN
	RETURN "A jogokat kizárólag megvonni szabad Warn idejére! (lawtosendmail)!";
END IF;
IF(v_lawtocreatequiz - p_lawtocreatequiz < 0) THEN
	RETURN "A jogokat kizárólag megvonni szabad Warn idejére! (lawtocreatequiz)!";
END IF;
IF(v_lawtosendquestion - p_lawtosendquestion < 0) THEN
	RETURN "A jogokat kizárólag megvonni szabad Warn idejére! (lawtosendquestion)!";
END IF;
IF(v_lawtosearchuser - p_lawtosearchuser < 0) THEN
	RETURN "A jogokat kizárólag megvonni szabad Warn idejére! (lawtosearchuser)!";
END IF;
IF(v_lawtopostnews - p_lawtopostnews < 0) THEN
	RETURN "A jogokat kizárólag megvonni szabad Warn idejére! (lawtopostnews)!";
END IF;

SET v_regijogok = v_lawtocreatequiz + v_lawtogetpoints + v_lawtopostnews + v_lawtosearchuser + v_lawtosendmail + v_lawtosendquestion + v_lawtousechat + v_lawtouserequests;
SET v_ujjogok = p_lawtocreatequiz + p_lawtogetpoints + p_lawtopostnews + p_lawtosearchuser + p_lawtosendmail + p_lawtosendquestion + p_lawtousechat + p_lawtouserequests;
IF(v_regijogok <= v_ujjogok AND v_regijogok != 0) THEN
	RETURN "Legalább egy jogmegvonás kötelező! (Kivéve ha eleve minden jog meg van vonva)!";
END IF;

IF(v_lawtocreatequiz > p_lawtocreatequiz) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Kvíz készítése, ");
END IF;
IF(v_lawtogetpoints > p_lawtogetpoints) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Pontok gyüjtése, ");
END IF;
IF(v_lawtopostnews > p_lawtopostnews) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Új hír kiírása, ");
END IF;
IF(v_lawtosearchuser > p_lawtosearchuser) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Felhasználókereső használata, ");
END IF;
IF(v_lawtosendmail > p_lawtosendmail) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Privát üzenet küldése, ");
END IF;
IF(v_lawtosendquestion > p_lawtosendquestion) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Kérdések beküldése, ");
END IF;
IF(v_lawtousechat > p_lawtousechat) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Chat használata, ");
END IF;
IF(v_lawtouserequests > p_lawtouserequests) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Kérések használata, ");
END IF;
IF(LENGTH(v_megvontjogok) < 1) THEN
	SET v_megvontjogok = "Nincs";
END IF;

UPDATE user SET warn = 1, totalwarn = totalwarn + 1, points = points - p_minuspoints, warn_expire = NOW() + INTERVAL p_warndelay DAY, lawtocreatequiz = p_lawtocreatequiz, lawtogetpoints = p_lawtogetpoints, lawtopostnews = p_lawtopostnews, lawtosearchuser = p_lawtosearchuser, lawtosendmail = p_lawtosendmail, lawtosendquestion = p_lawtosendquestion, lawtousechat = p_lawtousechat, lawtouserequests = p_lawtouserequests, keep_level = 0, premium = 0, premium_expire = 0, profilehiding = 0, profilehiding_expire = 0 WHERE id = p_userid;
INSERT INTO warn VALUES(p_userid, p_warnreason, v_megvontjogok, p_minuspoints, p_warndelay, p_adminuserid, NOW(), NOW()+ INTERVAL p_warndelay DAY, NULL, NULL, NULL, 1);
UPDATE premium SET deletedby = p_adminuserid, deletereason = 'Warn miatt törölve', deletetime = NOW(), is_active = 0 WHERE userid = p_userid AND is_active = 1;
INSERT INTO log_data VALUES (NULL, 3, v_username, CONCAT('WARN-t kaptál, ezért bizonyos funkciók meg lettek tőled vonva! A figyelmeztetés oka: ', p_warnreason, ', amelynek időtartama ', p_warndelay, ' nap. A warn miatt ', p_minuspoints, ' pontot vontunk le tőled!'), v_adminusername, NOW(), 0);
RETURN "ok";

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `is_correct_questionanswer` (`p_questionanswer` VARCHAR(150) CHARSET utf8) RETURNS INT(11) BEGIN
    IF(LENGTH(p_questionanswer) < 156) THEN
    RETURN 1;
    END IF;
RETURN -1;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `is_correct_questiontext` (`p_questiontext` VARCHAR(255) CHARSET utf8) RETURNS INT(11) BEGIN
    IF(p_questiontext REGEXP "^([A-Z]|""[A-Z0-9]|'[A-Z0-9])(.|s)*[?]$" AND LENGTH(p_questiontext) < 255) THEN
    RETURN 1;
    END IF;
RETURN -1;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `is_realuser` (`p_username` VARCHAR(25) CHARSET utf8) RETURNS INT(11) READS SQL DATA
BEGIN
    DECLARE v_sorok INT DEFAULT 0;
    
    IF(LENGTH(p_username)< 3 OR LENGTH(p_username)> 25)	THEN
        RETURN -1;
    END IF;
    IF(p_username REGEXP "^[a-zA-Z0-9]*$") THEN
        SELECT COUNT(*) INTO v_sorok FROM user WHERE BINARY user = BINARY p_username;
        IF(v_sorok != 1) THEN
            RETURN -2;/* tul sok hasonlo talalat, vagy egy sem */
        END IF;
    END IF;
    RETURN 1;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `law_to_get_thema` (`p_user` VARCHAR(30) CHARSET utf8, `p_quizid` INT) RETURNS INT(11) READS SQL DATA
BEGIN

DECLARE v_userid INT DEFAULT 0;
DECLARE v_admin INT DEFAULT 0;
DECLARE v_db INT DEFAULT 0;
DECLARE v_eredmeny INT;

SELECT COUNT(*) INTO v_db FROM user WHERE BINARY user = BINARY p_user;
IF(v_db != 1) THEN
	RETURN -1;
END IF;
SELECT id, adminuser INTO v_userid, v_admin FROM user WHERE user = p_user;

SELECT 1 INTO v_eredmeny FROM dual WHERE p_quizid IN (
	SELECT id_number FROM thema WHERE is_request = 0 AND is_deleted = 0 AND 
	( (phase = 2 AND requested_by = p_user) OR
	  (phase = 3 AND
			(
				(accept_questions = 1 AND requested_by = p_user) OR
				(accept_questions = 2 AND (v_admin = 1 OR requested_by = p_user)) OR 
				(accept_questions = 3 AND 
					(v_admin = 1 OR requested_by = p_user OR id_number IN 
						(SELECT quizid FROM permission_submit_question WHERE userid = v_userid)
						) ) OR
				accept_questions = 4
			)
	  )
	)
	UNION 
	SELECT id_number FROM thema WHERE is_request = 1 AND is_deleted = 0 AND 
		( (phase = 2 AND is_undertaken = 1 AND undertaken_by = p_user) OR phase = 3 )
	UNION
	SELECT t.id_number FROM thema t JOIN user u ON (t.requested_by = u.user) WHERE t.is_request = 0 AND phase = 3 AND t.is_deleted = 0 AND 
	t.accept_questions = 5 AND (v_admin = 1 OR t.requested_by = p_user OR 
		( v_userid IN ( SELECT f.id1 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = t.requested_by AND f.status = 1 UNION SELECT f.id2 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = t.requested_by AND f.status = 1)
		)
		)
	);

IF(v_eredmeny = 1) THEN
	RETURN 1;
ELSE
	RETURN 0;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `like_quiz` (`p_userid` INT, `p_quizid` INT) RETURNS INT(11) MODIFIES SQL DATA
BEGIN

DECLARE v_toroltuser INT;
DECLARE v_alreadyliked INT;
DECLARE v_accomplishedby VARCHAR(30);
DECLARE v_user VARCHAR(30);
DECLARE v_quizname VARCHAR(200);
DECLARE v_total INT DEFAULT 0;

IF(p_quizid < 1 OR LENGTH(p_quizid) < 1 OR p_userid < 1 OR LENGTH(p_userid) < 1) THEN
	RETURN -1;
END IF;

SELECT COUNT(*) INTO v_alreadyliked FROM quiz_like WHERE user_id = p_userid AND quiz_id = p_quizid;
IF(v_alreadyliked > 0) THEN
	RETURN -3;
END IF;

SELECT user, deleteduser INTO v_user, v_toroltuser FROM user WHERE id = p_userid;
IF(v_toroltuser != 0) THEN
	RETURN -1;
END IF;
SELECT accomplished_by, quiz_name INTO v_accomplishedby, v_quizname FROM thema WHERE id_number = p_quizid;
IF(v_accomplishedby = v_user) THEN
	RETURN -2;
END IF;

SELECT COUNT(*) INTO v_total FROM quiz_like WHERE quiz_id = p_quizid;
INSERT INTO quiz_like VALUES(p_userid, p_quizid, NOW());
INSERT INTO log_data VALUES (NULL, 26, v_user, CONCAT("A felhasználó kedvelte a/az ", v_quizname, " kvízt"), "SYSTEM", NOW(), 1);
IF(v_total = 0) THEN
	RETURN 0;
ELSE
	RETURN 1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `login` (`p_username` VARCHAR(30) CHARSET utf8, `p_password` VARCHAR(128) CHARSET utf8, `p_device` VARCHAR(255) CHARSET utf8) RETURNS VARCHAR(500) CHARSET utf8 NO SQL
BEGIN

DECLARE v_username VARCHAR(30);
DECLARE v_toroltuser INT;
DECLARE v_password VARCHAR(128);
DECLARE v_email VARCHAR(60);
DECLARE v_id INT;
DECLARE v_deletereason VARCHAR(200);

/*DailyPoints*/
DECLARE v_today INT;
DECLARE v_szint INT;
DECLARE v_lawtogetpoints INT;
/*DailyPoints*/

/**/
DECLARE darab INT;
DECLARE v_db INT DEFAULT 0;
/**/
DECLARE v_now DATETIME DEFAULT NOW();

SELECT COUNT(id) INTO v_id FROM user WHERE BINARY user = BINARY p_username OR BINARY email = BINARY p_username;
IF(v_id = 0) THEN
	INSERT INTO login VALUES(NULL, p_username, p_ip, p_device, v_now, 0, 0, 1, 0);
	RETURN "Hibás felhasználónév vagy jelszó!!!";
END IF;
SELECT id, user, deleteduser, pw, email, delete_reason INTO v_id, v_username, v_toroltuser, v_password, v_email, v_deletereason FROM user WHERE BINARY user = BINARY p_username OR BINARY email = BINARY p_username;
IF(p_password != v_password) THEN
	INSERT INTO login VALUES(NULL, v_username, p_ip, p_device, v_now, 0, 0, 1, 0);
	RETURN "Hibás felhasználónév vagy jelszó! (Wrong username or password)";
END IF;
IF(v_toroltuser != 0) THEN
	INSERT INTO login VALUES(NULL, v_username, p_device, v_now, 0, 0, 1, 0);
	RETURN CONCAT("Ezt a felhasználói fiókot töröltük a következő indokkal: ", v_deletereason);
END IF;

/*DailyPoints*/
SELECT level, lawtogetpoints INTO v_szint, v_lawtogetpoints FROM user WHERE id = v_id;
SELECT COUNT(*) INTO v_today FROM login WHERE username = v_username AND login_date >= CURDATE() AND login_type = 0;
IF(v_today = 0 AND v_lawtogetpoints = 1) THEN
	UPDATE user SET points = points + 2*v_szint, help = help + 1 WHERE id = v_id;
END IF;

/*IP-address and device*/
IF(LENGTH(p_device)>0) THEN
	SELECT COUNT(*) INTO v_db FROM login WHERE username = v_username AND login_date = v_now AND login_type = 0;
	IF(v_db > 0) THEN
		SET v_now = DATE_ADD(v_now, INTERVAL 1 SECOND);
		DO SLEEP(1);
	END IF;
	INSERT INTO login VALUES(NULL, v_username, p_device, v_now, 1, 0, 0, 0);
	
	/*DailyPoints*/

	UPDATE user SET lastvisit = v_now WHERE user = v_username;
	SELECT COUNT(*) INTO darab FROM live_question WHERE user = v_username;
	
	INSERT INTO log_data VALUES (NULL, 1, v_username, 'Bejelentkezés megtörtént.', 'SYSTEM', v_now, 1);
ELSE
	RETURN "Invalid device!";
END IF;

RETURN v_now;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `loginadmin` (`p_username` VARCHAR(30) CHARSET utf8, `p_password` VARCHAR(128) CHARSET utf8, `p_device` VARCHAR(255) CHARSET utf8) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_username VARCHAR(30);
DECLARE v_email VARCHAR(60);
DECLARE v_toroltuser INT;
DECLARE v_password VARCHAR(128);
DECLARE v_admin INT;
DECLARE v_id INT;
DECLARE v_now DATETIME DEFAULT NOW();
DECLARE v_db INT DEFAULT 0;
DECLARE v_lastvisitadmin DATETIME;

SELECT COUNT(id) INTO v_id FROM user WHERE BINARY user = BINARY p_username OR BINARY email = BINARY p_username;
IF(v_id = 0) THEN
	INSERT INTO login VALUES(NULL, p_username, p_device, v_now, 0, 1, 1, 0);
	RETURN "Hibás felhasználónév vagy jelszó!!!";
END IF;
SELECT id, adminuser, lastvisit_admin, user, deleteduser, pw, email INTO v_id, v_admin, v_lastvisitadmin, v_username, v_toroltuser, v_password, v_email FROM user WHERE BINARY user = BINARY p_username OR BINARY email = BINARY p_username;
IF(p_password != v_password OR v_toroltuser != 0 OR v_admin != 1) THEN
	INSERT INTO login VALUES(NULL, v_username, p_device, v_now, 0, 1, 1, 0);
	RETURN "Hibás felhasználónév vagy jelszó! A bejelentkezés csak Admin tagoknak lehetséges!";
END IF;

IF(LENGTH(p_device)>0) THEN
	SELECT COUNT(*) INTO v_db FROM login WHERE username = v_username AND is_success = 1 AND login_type = 1 AND logged_out = 0 AND TIMESTAMPDIFF(MINUTE, v_lastvisitadmin, NOW()) <= 15;
	IF(v_db > 0) THEN
		RETURN "Egy másik bejelentkezés van függőben! Egy időben csak egy helyről lehet Adminként belépni!";
	END IF;
	UPDATE login SET logged_out = 1 WHERE username = v_username AND is_success = 1 AND login_type = 1 AND logged_out = 0;
	INSERT INTO login VALUES(NULL, v_username, p_device, v_now, 1, 1, 0, 0);
	INSERT INTO log_data VALUES (NULL, 1, v_username, 'Bejelentkezés Adminként.', 'SYSTEM', v_now, 1);
	UPDATE user SET lastvisit_admin = v_now WHERE user = v_username;
ELSE
	RETURN "Invalid device!";
END IF;

RETURN v_now;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `logout` (`p_username` VARCHAR(30) CHARSET utf8, `p_type` INT, `p_adminlogout` INT, `p_logintime` DATETIME) RETURNS INT(11) MODIFIES SQL DATA
BEGIN

DECLARE v_db INT DEFAULT 0;

IF(p_type != 1 AND p_type != 0) THEN
	RETURN -1;
END IF;
IF(p_adminlogout != 1 AND p_adminlogout != 0) THEN
	RETURN -1;
END IF;
SELECT COUNT(id) INTO v_db FROM user WHERE BINARY user = BINARY p_username;
IF(v_db != 1) THEN
	RETURN -1;
ELSE
	IF(p_adminlogout = 0) THEN
		IF(p_type = 0) THEN /*inaktivitas miatti logout*/
			INSERT INTO log_data VALUES (NULL, 1, p_username, 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', NOW(), 1);
			UPDATE login SET logged_out = 1, logout_date = NOW() WHERE login_date = p_logintime AND username = p_username;
			RETURN 1;
		ELSE /*kijelentkezes gombra kattintas altali logout*/
			INSERT INTO log_data VALUES (NULL, 1, p_username, 'Sikeres kijelentkezés történt.', 'SYSTEM', NOW(), 1);
			UPDATE login SET logged_out = 1, logout_date = NOW() WHERE login_date = p_logintime AND username = p_username;
			RETURN 1;
		END IF;
	ELSE
		INSERT INTO log_data VALUES (NULL, 1, p_username, 'Kijelentkezés Adminként.', 'SYSTEM', NOW(), 1);
		UPDATE login SET logged_out = 1, logout_date = NOW() WHERE login_date = p_logintime AND username = p_username;
		RETURN 1;
	END IF;
	
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `modify_admin_law` (`p_admin` INT, `p_userid` INT, `p_adminuserid` INT) RETURNS VARCHAR(500) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_warn INT;
DECLARE v_toroltuser INT;
DECLARE v_db INT DEFAULT 0;
DECLARE v_username VARCHAR(30);
DECLARE v_adminusername VARCHAR(30);
DECLARE v_adminuser INT;
DECLARE v_useradminuser INT;
DECLARE v_response VARCHAR(500) DEFAULT "";
DECLARE v_responseforuser VARCHAR(500) DEFAULT "";

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen user azonosító!";
END IF;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminuserid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen admin azonosító!";
END IF;

IF(p_admin != 0 AND p_admin != 1) THEN
	RETURN "Helytelen érték a p_admin!";
END IF;

SELECT warn, deleteduser INTO v_warn, v_toroltuser FROM user WHERE id = p_userid;
IF(v_warn != 0) THEN
	RETURN "A felhasználó jelenleg WARN alatt van! Ez a beállítás NEM használható annak lejártáig!";
END IF;
IF(v_toroltuser != 0) THEN
	RETURN "Törölt felhasználó!! Ez a beállítás nem megengedett!";
END IF;

SELECT adminuser INTO v_adminuser FROM user WHERE id = p_adminuserid;
IF(v_adminuser != 1) THEN
	RETURN "Ez a funkció csak Admin felhasználóknak megengedett!";
END IF;
SELECT user INTO v_adminusername FROM user WHERE id = p_adminuserid;
SELECT user, adminuser INTO v_username, v_useradminuser FROM user WHERE id = p_userid;

IF(v_useradminuser = 1) THEN
	IF(p_admin = 0) THEN
		UPDATE user SET adminuser = 0 WHERE id = p_userid;
		SET v_response = CONCAT(v_response, "Admin jog visszavonva.");
		SET v_responseforuser = "Egy Admin tag visszavonta az Admin jogodat!";
	ELSE
		SET v_response = CONCAT(v_response, "Nem történt változás. Az Admin jog megtartva.");
	END IF;
	
ELSE
	IF(p_admin = 1) THEN
		UPDATE user SET adminuser = 1 WHERE id = p_userid;
		SET v_response = CONCAT(v_response, "Admin jog megadva.");
		SET v_responseforuser = CONCAT(v_responseforuser, "Admin jogot kaptál.");
	ELSE
		SET v_response = CONCAT(v_response, "Nem történt módosulás. Az Admin jog kikapcsolva. ");
	END IF;
END IF;

IF(LENGTH(v_responseforuser) > 1) THEN
	INSERT INTO log_data VALUES (NULL, 4, v_username, v_responseforuser, v_adminusername, NOW(), 0);
END IF;

RETURN v_response;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `modify_profile_hiding` (`p_profilehideON` INT, `p_delay` INT, `p_userid` INT, `p_adminuserid` INT) RETURNS VARCHAR(500) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_warn INT;
DECLARE v_premium INT;
DECLARE v_db INT DEFAULT 0;
DECLARE v_username VARCHAR(30);
DECLARE v_adminusername VARCHAR(30);
DECLARE v_adminuser INT;
DECLARE v_toroltuser INT;
DECLARE v_profilrejt INT;
DECLARE v_profilrejtlejar DATETIME;
DECLARE v_response VARCHAR(500) DEFAULT "";
DECLARE v_responseforuser VARCHAR(500) DEFAULT "";

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen user azonosító!";
END IF;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminuserid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen admin azonosító!";
END IF;

IF(p_profilehideON != 0 AND p_profilehideON != 1) THEN
	RETURN "Helytelen érték a p_profilehideON!";
END IF;

IF(p_delay < 1 OR p_delay > 365) THEN
	RETURN "Helytelen érték a p_delay!";
END IF;

SELECT warn, premium, deleteduser INTO v_warn, v_premium, v_toroltuser FROM user WHERE id = p_userid;
IF(v_toroltuser != 0) THEN
	RETURN "Törölt felhasználó!! Ez a beállítás nem engedélyezett!";
END IF;
IF(v_warn != 0) THEN
	RETURN "A felhasználó jelenleg WARN alatt van! Ez a beállítás NEM használható annak lejártáig!";
END IF;
IF(v_premium != 0) THEN
	RETURN "A felhasználó jelenleg Prémium tagság alatt van! Ez a beállítás NEM használható annak lejártáig!";
END IF;

SELECT adminuser INTO v_adminuser FROM user WHERE id = p_adminuserid;
IF(v_adminuser != 1) THEN
	RETURN "Ez a funkció csak Admin felhasználóknak megengedett!";
END IF;
SELECT user INTO v_adminusername FROM user WHERE id = p_adminuserid;
SELECT user, profilehiding, profilehiding_expire INTO v_username, v_profilrejt, v_profilrejtlejar FROM user WHERE id = p_userid;

IF(p_profilehideON = 1) THEN
	IF(v_profilrejt = 1) THEN
		UPDATE user SET profilehiding = 1, profilehiding_expire = v_profilrejtlejar + INTERVAL p_delay DAY WHERE id = p_userid;
		SET v_response = CONCAT(v_response, "A profil rejtettségi ideje módosult: ", p_delay, " nappal meg lett hosszabítva!");
		SET v_responseforuser = CONCAT(v_responseforuser, p_delay, ' nappal meg lett hosszabítva. ');
	ELSE
		UPDATE user SET profilehiding = 1, profilehiding_expire = NOW() + INTERVAL p_delay DAY WHERE id = p_userid;
		SET v_response = CONCAT(v_response, "A profil rejtettségi ideje: ", p_delay, " napig be lett kapcsolva!");
		SET v_responseforuser = CONCAT(v_responseforuser, p_delay, ' napig be lett kapcsolva. ');
	END IF;
	
ELSE
	IF(v_profilrejt = 1) THEN
		UPDATE user SET profilehiding = 0, profilehiding_expire = 0 WHERE id = p_userid;
		SET v_response = CONCAT(v_response, "A profil rejtettsége ki lett kapcsolva. ");
		SET v_responseforuser = CONCAT(v_responseforuser, "Kikapcsolva.");
	ELSE
		SET v_response = CONCAT(v_response, "Nem történt módosulás. A profil rejtettsége ki van kapcsolva. ");
	END IF;
END IF;

IF(LENGTH(v_responseforuser) > 1) THEN
	INSERT INTO log_data VALUES (NULL, 5, v_username, CONCAT('Egy Admin módosításokat végzett a profilod rejtettségén: ', v_responseforuser), v_adminusername, NOW(), 0);
END IF;

RETURN v_response;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `modify_user_laws` (`p_keeplevel` INT, `p_currentlevel` INT, `p_lawtogetpoints` INT, `p_lawtousechat` INT, `p_lawtouserequests` INT, `p_lawtosendmail` INT, `p_lawtocreatequiz` INT, `p_lawtosendquestion` INT, `p_lawtosearchuser` INT, `p_lawtopostnews` INT, `p_plusminuspoints` INT, `p_helps` INT, `p_deletefreepremium` INT, `p_questiontype` INT, `p_userid` INT, `p_adminuserid` INT) RETURNS VARCHAR(500) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_lawtogetpoints INT;
DECLARE v_lawtousechat INT;
DECLARE v_lawtouserequests INT;
DECLARE v_lawtosendmail INT;
DECLARE v_lawtocreatequiz INT;
DECLARE v_lawtosendquestion INT;
DECLARE v_lawtosearchuser INT;
DECLARE v_lawtopostnews INT;
DECLARE v_szintetmegtart INT;
DECLARE v_warn INT;
DECLARE v_toroltuser INT;
DECLARE v_db INT DEFAULT 0;
DECLARE v_username VARCHAR(30);
DECLARE v_adminusername VARCHAR(30);
DECLARE v_adminuser INT;
DECLARE v_megvontjogok VARCHAR(500) DEFAULT "";
DECLARE v_engedelyezettjogok VARCHAR(500) DEFAULT "";
DECLARE v_prdb INT DEFAULT 0;
DECLARE v_response VARCHAR(500) DEFAULT "";
DECLARE v_responseforuser VARCHAR(500) DEFAULT "";

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen user azonosító!";
END IF;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminuserid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen admin azonosító!";
END IF;

IF(p_keeplevel != 0 AND p_keeplevel != 1) THEN
	RETURN "Helytelen érték a p_keeplevel!";
END IF;

IF(p_currentlevel < 1 OR p_currentlevel > 5) THEN
	RETURN "Helytelen érték a p_currentlevel!";
END IF;

IF(p_lawtogetpoints != 0 AND p_lawtogetpoints != 1) THEN
	RETURN "Helytelen érték a p_lawtogetpoints!";
END IF;

IF(p_lawtousechat != 0 AND p_lawtousechat != 1) THEN
	RETURN "Helytelen érték a p_lawtousechat!";
END IF;

IF(p_lawtouserequests != 0 AND p_lawtouserequests != 1) THEN
	RETURN "Helytelen érték a p_lawtouserequests!";
END IF;

IF(p_lawtosendmail != 0 AND p_lawtosendmail != 1) THEN
	RETURN "Helytelen érték a p_lawtosendmail!";
END IF;

IF(p_lawtocreatequiz != 0 AND p_lawtocreatequiz != 1) THEN
	RETURN "Helytelen érték a p_lawtocreatequiz!";
END IF;

IF(p_lawtosendquestion != 0 AND p_lawtosendquestion != 1) THEN
	RETURN "Helytelen érték a p_lawtosendquestion!";
END IF;

IF(p_lawtosearchuser != 0 AND p_lawtosearchuser != 1) THEN
	RETURN "Helytelen érték a p_lawtosearchuser!";
END IF;

IF(p_lawtopostnews != 0 AND p_lawtopostnews != 1) THEN
	RETURN "Helytelen érték a p_lawtopostnews!";
END IF;

IF(p_deletefreepremium != 0 AND p_deletefreepremium != 1) THEN
	RETURN "Helytelen érték a p_deletefreepremium!";
END IF;

IF(p_questiontype != 0 AND p_questiontype != 1 AND p_questiontype != 2) THEN
	RETURN "Helytelen érték a p_questiontype!";
END IF;

SELECT warn, deleteduser INTO v_warn, v_toroltuser FROM user WHERE id = p_userid;
IF(v_toroltuser != 0) THEN
	RETURN "Törölt felhasználó!! Ez a beállítás nem engedélyezett!";
END IF;
IF(v_warn != 0) THEN
	RETURN "A felhasználó jelenleg WARN alatt van! Ez a beállítás NEM használható annak lejártáig!";
END IF;

SELECT adminuser INTO v_adminuser FROM user WHERE id = p_adminuserid;
IF(v_adminuser != 1) THEN
	RETURN "Ez a funkció csak Admin felhasználóknak megengedett!";
END IF;

SELECT user, lawtogetpoints, lawtousechat, lawtouserequests, lawtosendmail, lawtocreatequiz, lawtosendquestion, lawtosearchuser, lawtopostnews, keep_level INTO v_username, v_lawtogetpoints, v_lawtousechat, v_lawtouserequests, v_lawtosendmail, v_lawtocreatequiz, v_lawtosendquestion, v_lawtosearchuser, v_lawtopostnews, v_szintetmegtart FROM user WHERE id = p_userid;
SELECT user INTO v_adminusername FROM user WHERE id = p_adminuserid;

IF(v_lawtogetpoints - p_lawtogetpoints < 0) THEN
	SET v_engedelyezettjogok = CONCAT(v_engedelyezettjogok, "Pontok gyüjtése, ");
END IF;
IF(v_lawtousechat - p_lawtousechat < 0) THEN
	SET v_engedelyezettjogok = CONCAT(v_engedelyezettjogok, "Chat használata, ");
END IF;
IF(v_lawtouserequests - p_lawtouserequests < 0) THEN
	SET v_engedelyezettjogok = CONCAT(v_engedelyezettjogok, "Kérések használata, ");
END IF;
IF(v_lawtosendmail - p_lawtosendmail < 0) THEN
	SET v_engedelyezettjogok = CONCAT(v_engedelyezettjogok, "Privát üzenet küldése, ");
END IF;
IF(v_lawtocreatequiz - p_lawtocreatequiz < 0) THEN
	SET v_engedelyezettjogok = CONCAT(v_engedelyezettjogok, "Kvíz készítése, ");
END IF;
IF(v_lawtosendquestion - p_lawtosendquestion < 0) THEN
	SET v_engedelyezettjogok = CONCAT(v_engedelyezettjogok, "Kérdések beküldése, ");
END IF;
IF(v_lawtosearchuser - p_lawtosearchuser < 0) THEN
	SET v_engedelyezettjogok = CONCAT(v_engedelyezettjogok, "Felhasználókereső használata, ");
END IF;
IF(v_lawtopostnews - p_lawtopostnews < 0) THEN
	SET v_engedelyezettjogok = CONCAT(v_engedelyezettjogok, "Új hír kiírása, ");
END IF;
IF(LENGTH(v_engedelyezettjogok) < 1) THEN
	SET v_engedelyezettjogok = "Nincs";
END IF;

/*----------------------------------------------*/

IF(v_lawtocreatequiz > p_lawtocreatequiz) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Kvíz készítése, ");
END IF;
IF(v_lawtogetpoints > p_lawtogetpoints) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Pontok gyüjtése, ");
END IF;
IF(v_lawtopostnews > p_lawtopostnews) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Új hír kiírása, ");
END IF;
IF(v_lawtosearchuser > p_lawtosearchuser) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Felhasználókereső használata, ");
END IF;
IF(v_lawtosendmail > p_lawtosendmail) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Privát üzenet küldése, ");
END IF;
IF(v_lawtosendquestion > p_lawtosendquestion) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Kérdések beküldése, ");
END IF;
IF(v_lawtousechat > p_lawtousechat) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Chat használata, ");
END IF;
IF(v_lawtouserequests > p_lawtouserequests) THEN
	SET v_megvontjogok = CONCAT(v_megvontjogok, "Kérések használata, ");
END IF;
IF(LENGTH(v_megvontjogok) < 1) THEN
	SET v_megvontjogok = "Nincs";
END IF;

SELECT COUNT(*) INTO v_prdb FROM premium WHERE userid = p_userid AND is_active = 1;

IF(v_prdb = 0) THEN
	IF(p_keeplevel = 1) THEN
		UPDATE user SET keep_level = 1, level = p_currentlevel, lawtocreatequiz = p_lawtocreatequiz, lawtogetpoints = p_lawtogetpoints, lawtopostnews = p_lawtopostnews, lawtosearchuser = p_lawtosearchuser, lawtosendmail = p_lawtosendmail, lawtosendquestion = p_lawtosendquestion, lawtousechat = p_lawtousechat, lawtouserequests = p_lawtouserequests WHERE id = p_userid;
		SET v_responseforuser = CONCAT(v_responseforuser, "új rangod: ", p_currentlevel, ', engedélyezett jogok: ', v_engedelyezettjogok, ', megvont jogok: ', v_megvontjogok, '; ');
	ELSE
		UPDATE user SET keep_level = 0 WHERE id = p_userid;
		SET v_responseforuser = CONCAT(v_responseforuser, "az aktuális rangodhoz tartozó jogok lettek újra aktívak; ");
	END IF;
	SET v_response = CONCAT(v_response, "A jogok és a szint módosult! ");
ELSE
	SET v_response = CONCAT(v_response, "A jogok és a szint nem módosult, mert a felhasználó jelenleg Prémium tag! ");
END IF;

IF(p_plusminuspoints != 0) THEN
	UPDATE user SET points = points + p_plusminuspoints WHERE id = p_userid;
	SET v_responseforuser = CONCAT(v_responseforuser, "pontszámváltozás: ", p_plusminuspoints, '; ');
	SET v_response = CONCAT(v_response, "A pontszám módosult! ");
END IF;

IF(p_helps != 0) THEN
	UPDATE user SET help = help + p_helps WHERE id = p_userid;
	SET v_responseforuser = CONCAT(v_responseforuser, " új segítségeid száma: ", p_helps, '; ');
	SET v_response = CONCAT(v_response, "A segítségek száma módosult! ");
END IF;

SELECT COUNT(*) INTO v_prdb FROM premium WHERE userid = p_userid AND minuspoints = 0 AND price = 0 AND is_active = 1;
IF(p_deletefreepremium = 1) THEN
	IF(v_prdb > 0) THEN
		UPDATE premium SET deletedby = p_adminuserid, deletereason = "Ingyenes prémium törlése", deletetime = NOW(), is_active = 0 WHERE userid = p_userid AND minuspoints = 0 AND price = 0 AND is_active = 1;
		UPDATE user SET premium = 0, premium_expire = 0 WHERE id = p_userid;
		SET v_response = CONCAT(v_response, "Az ingyenes prémium eltörölve! ");
		SET v_responseforuser = CONCAT(v_responseforuser, "Az ingyenes prémium el lett törölve; ");
	ELSE
		SET v_response = CONCAT(v_response, "A felhasználóknak nincs jelenleg ingyenes prémiumja, így nem tudtuk eltörölni azt! ");
	END IF;	
END IF;

UPDATE user SET questiontype = p_questiontype WHERE id = p_userid;
SET v_response = CONCAT(v_response, "A kérdésnehézség módosítva! ");

INSERT INTO log_data VALUES (NULL, 8, v_username, CONCAT('Egy Admin módosításokat végzett a profilodon: ', v_responseforuser), v_adminusername, NOW(), 0);

RETURN v_response;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `offer_points_to_request` (`p_quizid` INT, `p_user` VARCHAR(30) CHARSET utf8, `p_points` INT) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE uzenet VARCHAR(200);
	DECLARE v_pontszam INT;
	DECLARE v_userazonosito INT;
	DECLARE v_fazis INT;
	DECLARE v_isreq INT;
	DECLARE v_kerespontjai INT;
	DECLARE v_toroltuser INT;
	
	SET uzenet = "";
	SELECT deleteduser, points, id INTO v_toroltuser, v_pontszam, v_userazonosito FROM user WHERE user = p_user;
	IF(v_toroltuser != 0) THEN
		RETURN "Törölt felhasználó!";
	END IF;
	IF(v_pontszam < p_points) THEN
		RETURN "Nincs elég pontszámod!";
	END IF;
	IF(p_points < 30) THEN
		RETURN "A minimálisan megadandó pontszám 30.";
	END IF;
	IF(p_points > 10000000) THEN
		RETURN "A maximálisan megadandó pontszám 10.000.000!";
	END IF;
	SELECT phase, is_request INTO v_fazis, v_isreq FROM thema WHERE id_number = p_quizid;
	IF(v_fazis > 2) THEN
		RETURN "Ez a kérés már teljesítve lett!";
	END IF;
	IF(v_isreq != 1) THEN
		RETURN "Csak kérésekhez ajánlható fel pont!";
	END IF;
	IF(uzenet = "") THEN
		INSERT INTO request_vote VALUES(v_userazonosito, p_quizid, p_points, NOW());
		UPDATE user SET points = points - p_points WHERE user = p_user;
		INSERT INTO log_data VALUES (NULL, 8, p_user, CONCAT("Pontváltozás történt: -", p_points, " levonás. Ok: kérésre felajánlott pontok"), 'SYSTEM', NOW(), 0);
		SELECT FLOOR(SUM(offered_points)/2) INTO v_kerespontjai FROM request_vote WHERE quiz_id = p_quizid;
		RETURN v_kerespontjai;
	ELSE
		RETURN "Nem sikerült végrehajtani a műveletet!";
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `points_to_premium` (`p_username` VARCHAR(30) CHARSET utf8) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE v_db INT;
	DECLARE v_warn INT;
	DECLARE v_pontszam INT;
	DECLARE v_premium INT;
	DECLARE v_userid INT;
	DECLARE v_toroltuser INT;

	SELECT COUNT(*) INTO v_db FROM user WHERE user = p_username;
	IF(v_db != 1) THEN
		RETURN "Érvénytelen user azonosító!";
	END IF;
	SELECT id, warn, points, premium, deleteduser INTO v_userid, v_warn, v_pontszam, v_premium, v_toroltuser FROM user WHERE user = p_username;
	IF(v_toroltuser != 0) THEN
		RETURN 'Törölt felhasználó!';
	END IF;
	IF(v_premium = 1) THEN
		RETURN 'Jelenleg PRÉMIUM tag vagy!';
	END IF;
	IF(v_warn != 0) THEN
		RETURN 'WARN-t kaptál! Ez alatt NEM lehetsz PRÉMIUM tag!!!';
	END IF;
	IF(v_pontszam < 15000) THEN
		RETURN 'Ez a funkció számodra NEM elérhető, mert NINCS elegendő mennyiségű pontszámod!';
	END IF;
	IF(v_premium = 0 AND v_warn = 0 AND v_pontszam >= 15000) THEN
		UPDATE user SET points = points - 15000, premium = 1, premium_expire = NOW() + INTERVAL 30 DAY, lawtousechat = 1, lawtosendquestion = 1, lawtosearchuser = 1, lawtouserequests = 1, lawtogetpoints = 1, lawtosendmail = 1, lawtocreatequiz = 1, lawtopostnews = 1 WHERE user = p_username;
		INSERT INTO premium VALUES(v_userid, 15000, 0, 30, NULL, NOW(), NOW() + INTERVAL 30 DAY, NULL, NULL, NULL, 1);
		INSERT INTO log_data VALUES (NULL, 6, p_username, 'Beváltottál 15000 pontot 1 hónapos Prémium csomagra!', 'SYSTEM', NOW(), 0);
		RETURN "ok";
	END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `quizrating` (`p_userid` INT, `p_quizid` INT, `p_rating` INT) RETURNS INT(11) MODIFIES SQL DATA
BEGIN

DECLARE v_username VARCHAR(30);
DECLARE v_quizname VARCHAR(200);
DECLARE v_db INT;
DECLARE v_quizdb INT DEFAULT 0;
DECLARE v_toroltuser INT;

IF(p_rating < 1 OR p_rating > 5 OR LENGTH(p_rating) != 1 OR LENGTH(p_quizid) < 1 OR p_quizid < 1) THEN
	RETURN -1;
END IF;

SELECT user, deleteduser INTO v_username, v_toroltuser FROM user WHERE id = p_userid;
IF(v_toroltuser != 0) THEN
	RETURN -1;
END IF;

SELECT COUNT(*) INTO v_quizdb FROM thema WHERE id_number = p_quizid;
IF(v_quizdb < 1) THEN
	RETURN -2;
END IF;
SELECT quiz_name INTO v_quizname FROM thema WHERE id_number = p_quizid;
SELECT COUNT(*) INTO v_db FROM quiz_rating WHERE user_id = p_userid AND quiz_id = p_quizid;
IF(v_db = 0) THEN
	INSERT INTO quiz_rating VALUES(p_userid, p_quizid, p_rating, NOW());
	INSERT INTO log_data VALUES(NULL, 26, v_username, CONCAT("A felhasználó értékelte a/az ", v_quizname, " kvízt."), "SYSTEM", NOW(), 1);
	RETURN 1;
ELSE
	RETURN 0;
END IF;
	
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `registration` (`p_fullname` VARCHAR(100) CHARSET utf8, `p_email` VARCHAR(100) CHARSET utf8, `p_username` VARCHAR(30) CHARSET utf8, `p_password` VARCHAR(128) CHARSET utf8) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_emailcount INT DEFAULT 0;
DECLARE v_usernamecount INT DEFAULT 0;

IF(LENGTH(p_fullname)< 5 OR LENGTH(p_fullname)>100) THEN
	RETURN "A teljes név hossza 5-100 közötti karakter legyen!";
END IF;
IF(LENGTH(p_email)< 5 OR LENGTH(p_email)>100) THEN
	RETURN "Az email-cím hossza 5-100 közötti karakter legyen!";
END IF;
IF(LENGTH(p_username)< 4 OR LENGTH(p_username)>25) THEN
	RETURN "Az felhasználónév hossza 4-25 közötti karakter legyen!";
END IF;
IF(LENGTH(p_password)< 1) THEN
	RETURN "Hiba a jelszóval!";
END IF;

SELECT COUNT(*) INTO v_usernamecount FROM user WHERE user = p_username;
IF(v_usernamecount > 0) THEN
	RETURN "Ez a felhasználónév már foglalt!!";
END IF;

SELECT COUNT(*) INTO v_emailcount FROM user WHERE email = p_email;
IF(v_emailcount > 0) THEN
	RETURN "Ezzel az email-címmel már regisztráltak!!";
END IF;

INSERT INTO user VALUES(NULL, 0, 0, 1, 0, 0, 0, 1, 0, NULL, 0, 0, 0, 0, 0, 2, 0, NOW(), NOW(), 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, p_fullname, p_email, p_username, p_password);
INSERT INTO log_data VALUES (NULL, 2, p_username, 'Sikeres regisztráció történt.', 'SYSTEM', NOW(), 1);
RETURN "ok";
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `restore_account` (`p_userid` INT, `p_adminuserid` INT, `p_reason` VARCHAR(100) CHARSET utf8) RETURNS VARCHAR(250) CHARSET utf8 MODIFIES SQL DATA
BEGIN

DECLARE v_toroltuser INT;
DECLARE v_db INT DEFAULT 0;
DECLARE v_username VARCHAR(30);
DECLARE v_adminusername VARCHAR(30);
DECLARE v_adminuser INT;
DECLARE v_premium INT;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_userid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen user azonosító!";
END IF;

SELECT COUNT(*) INTO v_db FROM user WHERE id = p_adminuserid;
IF(v_db != 1) THEN
	RETURN "Érvénytelen admin azonosító!";
END IF;

IF(LENGTH(p_reason) < 5 OR LENGTH(p_reason) > 100) THEN
	RETURN "Helytelen érték a p_reason!";
END IF;

SELECT adminuser INTO v_adminuser FROM user WHERE id = p_adminuserid;
IF(v_adminuser != 1) THEN
	RETURN "Ez a funkció csak Admin felhasználóknak megengedett!";
END IF;

SELECT deleteduser, premium INTO v_toroltuser, v_premium FROM user WHERE id = p_userid;
IF(v_toroltuser != 1) THEN
	RETURN "Ez a felhasználó nincsen törölve!! A beállítás nem megengedett!";
END IF;


SELECT user INTO v_adminusername FROM user WHERE id = p_adminuserid;
SELECT user INTO v_username FROM user WHERE id = p_userid;


UPDATE user SET deleteduser = 0, adminuser = 0, keep_level = 0, delete_reason = NULL WHERE id = p_userid;
IF(v_premium = 1) THEN
	UPDATE user SET lawtousechat = 1, lawtosendquestion = 1, lawtopostnews = 1, lawtosearchuser = 1, lawtoeditfaq = 1, lawtogetpoints = 1, lawtouserequests = 1, lawtocreatequiz = 1, lawtosendmail = 1 WHERE id = p_userid;
END IF;
INSERT INTO log_data VALUES (NULL, 31, v_username, CONCAT("Ezt a fiókot egy Admin visszaállította a következő indokkal: ", p_reason), v_adminusername, NOW(), 0);

RETURN "ok";

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `send_question` (`p_quizid` INT, `p_question` VARCHAR(255) CHARSET utf8, `p_ans1` VARCHAR(150) CHARSET utf8, `p_ans2` VARCHAR(150) CHARSET utf8, `p_ans3` VARCHAR(150) CHARSET utf8, `p_ans4` VARCHAR(150) CHARSET utf8, `p_username` VARCHAR(25) CHARSET utf8, `p_comment` VARCHAR(150), `p_difficulty` INT) RETURNS VARCHAR(500) CHARSET utf8 MODIFIES SQL DATA
BEGIN
	DECLARE darabszam INT; 
    DECLARE darabszamm INT;
    DECLARE dbrosszak INT;
    DECLARE sor INT;
    DECLARE k INT;
    DECLARE v1 INT;
    DECLARE v2 INT;
    DECLARE v3 INT;
    DECLARE v4 INT;
	DECLARE megj INT;
	DECLARE v_id INT DEFAULT 0;
    DECLARE v_jog INT;
	DECLARE v_gettemakor INT;
	DECLARE v_now DATETIME DEFAULT NOW();
	
	SET v_gettemakor = law_to_get_thema(p_username, p_quizid);
	IF(v_gettemakor != 1) THEN
		RETURN "Ebben a témakörben nem küldhetsz be kérdést!";
	END IF;
	
    IF(LENGTH(p_question) < 1 OR LENGTH(p_ans1) < 1 OR LENGTH(p_ans2) < 1 OR LENGTH(p_ans3) < 1 OR LENGTH(p_ans4) < 1 OR LENGTH(p_difficulty) < 1 OR LENGTH(p_username) < 1) THEN
        RETURN "Hiányzó adatok!";
    END IF;
    IF(CAST(p_quizid AS UNSIGNED) < 1 OR p_quizid < 1) THEN
        RETURN "Hibás témakör választás!";
    END IF;
	IF(p_difficulty < 1 OR p_difficulty > 2) THEN
		RETURN "Nincs nehézség kiválasztva!";
	END IF;
    SET k = is_correct_questiontext(p_question);
    SET v1 = is_correct_questionanswer(p_ans1);
    SET v2 = is_correct_questionanswer(p_ans2);
    SET v3 = is_correct_questionanswer(p_ans3);
    SET v4 = is_correct_questionanswer(p_ans4);
	SET megj = is_correct_questionanswer(p_comment);
    SELECT lawtosendquestion INTO v_jog FROM user WHERE user = p_username;
    IF(k = -1 OR v1 = -1 OR v2 = -1 OR v3 = -1 OR v4 = -1 OR megj = -1) THEN
        RETURN "Helytelen a kérdés vagy a válaszok szövege! A kérdés nagybetűvel, vagy idézőjellel kezdődjön. Vigyázz, a kis-és nagybetűkre, a kérdés végén a kérdőjelre, és hogy egyik se tartalmazzon SQL specifikus szavakat! A kérdés végén a kérdőjel után ne legyen extra szóköz.";
    END IF;
    IF(v_jog != 1) THEN
    	RETURN "Nincs jogod kérdéseket beküldeni!";
    END IF;
    SELECT COUNT(*) INTO darabszamm FROM quiz_question WHERE (LOWER(question) = LOWER(p_question)) AND (LOWER(ans1) = LOWER(p_ans1));
    SELECT COUNT(*) INTO dbrosszak FROM log_data WHERE username = p_username AND log_message LIKE "Az általad beküldött kérdés%már szerepel%" AND TIMESTAMPDIFF(MINUTE, log_date, NOW()) < 15 FOR UPDATE;
  IF(dbrosszak > 4) THEN
    SELECT COUNT(*) INTO sor FROM log_data WHERE username = p_username AND log_message LIKE "Túl sok%" AND TIMESTAMPDIFF(MINUTE, log_date, NOW()) < 15;
    IF(sor < 1) THEN
        INSERT INTO log_data VALUES (NULL, 36, p_username, "Túl sok helytelen kérdést adtál meg rövid időn belül!", "SYSTEM", NOW(), 0);
    END IF;
    RETURN "A túl sok sikertelen próbálkozásaid miatt 15 percig letiltottuk számodra a kérdésbeküldést!";
  ELSEIF(darabszamm > 0) THEN 
  	INSERT INTO log_data VALUES (NULL, 36, p_username, CONCAT("Az általad beküldött kérdés: ", p_question, " már szerepel a játékban!"), "SYSTEM", NOW(), 0);
    RETURN "Ez a kérdés már be lett küldve!";
  ELSE
  	INSERT INTO quiz_question (quiz_id, difficulty, question, ans1, ans2, ans3, ans4, username, is_verified, is_active, sending_time, verified_by, verification_time) VALUES (p_quizid, p_difficulty, p_question, p_ans1, p_ans2, p_ans3, p_ans4, p_username, NULL, 0, v_now, NULL, NULL);
    INSERT INTO log_data VALUES (NULL, 9, p_username, CONCAT("Új kérdés: ", p_question), "SYSTEM", NOW(), 0);
	IF(LENGTH(p_comment)>0) THEN
		SELECT COUNT(*) INTO v_id FROM quiz_question WHERE question = p_question AND ans1 = p_ans1 AND ans2 = p_ans2 AND ans3 = p_ans3 AND ans4 = p_ans4 AND username = p_username AND sending_time = v_now;
		IF(v_id = 1) THEN
			SELECT id INTO v_id FROM quiz_question WHERE question = p_question AND ans1 = p_ans1 AND ans2 = p_ans2 AND ans3 = p_ans3 AND ans4 = p_ans4 AND username = p_username AND sending_time = v_now;
			INSERT INTO question_comment (question_id, posted_by, comment_text, comment_time) VALUES(v_id, p_username, p_comment, NOW());
		END IF;
	END IF;
  END IF;
    RETURN "Successfully inserted question!";
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `status_send_message` (`p_senderid` INT, `p_recipientid` INT) RETURNS INT(11) READS SQL DATA
BEGIN
    DECLARE v_user1 VARCHAR(30);
    DECLARE v_user2 VARCHAR(30);
    DECLARE v_lawtosendmail INT;
	DECLARE v_admine INT;
	DECLARE v_acceptmails INT;
	DECLARE v_friendstatus INT;
	
	SELECT user INTO v_user1 FROM user WHERE id = p_senderid;
    SELECT user INTO v_user2 FROM user WHERE id = p_recipientid;
	
    IF(is_realuser(v_user1) = 1 AND is_realuser(v_user2) = 1 AND v_user1 != v_user2) THEN
        
        SELECT lawtosendmail, adminuser INTO v_lawtosendmail, v_admine FROM user WHERE user = v_user1;
		SELECT accept_privmessage INTO v_acceptmails FROM user WHERE user = v_user2;
        IF(v_lawtosendmail = 1) THEN
			
			SET v_friendstatus = get_friendship_status(v_user1, v_user2);
			IF(v_acceptmails = 0) THEN
				IF(v_friendstatus = 4 OR v_friendstatus = 5) THEN
					RETURN 2; /*tiltott user*/
				ELSE
					RETURN 0; /*OK*/
				END IF;
			ELSEIF(v_acceptmails = 1) THEN
				IF(v_admine = 1 AND v_friendstatus != 4 AND v_friendstatus != 5) THEN
					RETURN 0; /*OK*/
				ELSE
					RETURN 3; /*nem admin vagy tiltott user*/
				END IF;
			ELSEIF(v_acceptmails = 2) THEN
				IF((v_admine = 1 OR v_friendstatus = 1) AND v_friendstatus = 1) THEN
					RETURN 0; /*OK*/
				ELSE
					RETURN 4;
				END IF;
			ELSE
				RETURN -2; /*uzenetfogadas mezo erteke hibas*/
			END IF;
			
		ELSE
			RETURN 1; /*Nincs joga uzenetet kuldeni*/
		END IF;
    
    ELSE
        RETURN -1; /*Hibas parameterek*/
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `update_lastvisit` (`p_username` VARCHAR(30) CHARSET utf8, `p_type` INT) RETURNS INT(11) MODIFIES SQL DATA
BEGIN

IF(is_realuser(p_username) = 1 AND (p_type = 0 OR p_type = 1)) THEN
	IF(p_type = 0) THEN
		UPDATE user SET lastvisit = NOW() WHERE user = p_username;
		RETURN 1;
	ELSE
		UPDATE user SET lastvisit_admin = NOW() WHERE user = p_username;
		RETURN 1;
	END IF;
END IF;
RETURN 0;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `background`
--

CREATE TABLE `background` (
  `id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `image_path` varchar(255) CHARACTER SET utf8 NOT NULL,
  `posted_by` int(11) NOT NULL,
  `posting_time` datetime NOT NULL,
  `image_size` double NOT NULL,
  `image_ext` varchar(5) NOT NULL,
  `adminid` int(11) DEFAULT NULL,
  `accept_time` datetime DEFAULT NULL,
  `active` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `background`
--

INSERT INTO `background` (`id`, `quiz_id`, `image_path`, `posted_by`, `posting_time`, `image_size`, `image_ext`, `adminid`, `accept_time`, `active`) VALUES
(112, 11, 'documents/images/quizbackgrounds/11/dxKUC1yBbiq151632085618.jpg', 15, '2021-09-20 00:06:58', 0.05, 'jpg', 15, '2021-09-20 15:44:57', 1),
(113, 11, 'documents/images/quizbackgrounds/11/B2pcM3cIZvE151632085645.jpg', 15, '2021-09-20 00:07:25', 0.08, 'jpg', 15, '2021-09-20 15:54:40', 1),
(114, 11, 'documents/images/quizbackgrounds/11/D52PXy5Snmy151632085660.jpg', 15, '2021-09-20 00:07:40', 0.03, 'jpg', 15, '2021-09-20 15:12:24', 1),
(115, 11, 'documents/images/quizbackgrounds/11/iCDwAd70CQu151632085674.jpg', 15, '2021-09-20 00:07:54', 0.18, 'jpg', 15, '2021-09-20 15:56:14', 1),
(116, 11, 'documents/images/quizbackgrounds/11/yq1I08nYLnn151632085690.jpg', 15, '2021-09-20 00:08:10', 0.23, 'jpg', 15, '2021-09-20 15:56:16', 1),
(117, 11, 'documents/images/quizbackgrounds/11/AukzedOu5KA151632085707.jpg', 15, '2021-09-20 00:08:28', 0.18, 'jpg', 15, '2021-09-20 15:13:53', 1),
(118, 11, 'documents/images/quizbackgrounds/11/tPpXDypmuqm151632085726.jpg', 15, '2021-09-20 00:08:46', 0.06, 'jpg', 15, '2021-09-20 15:56:18', 1),
(119, 11, 'documents/images/quizbackgrounds/11/63tpv5BRSdK151632085766.jpg', 15, '2021-09-20 00:09:26', 0.03, 'jpg', 15, '2021-09-20 15:12:13', 1),
(120, 11, 'documents/images/quizbackgrounds/11/xK6PrUt46u2151632085783.jpg', 15, '2021-09-20 00:09:43', 0.15, 'jpg', 15, '2021-09-20 15:56:20', 1),
(123, 12, 'documents/images/quizbackgrounds/12/O2n70AaIOe6151632086325.jpg', 15, '2021-09-20 00:18:45', 0.33, 'jpg', 15, '2021-09-20 15:56:24', 1),
(124, 12, 'documents/images/quizbackgrounds/12/xqmxC2Y0tDL151632086340.jpg', 15, '2021-09-20 00:19:00', 0.25, 'jpg', 15, '2021-09-20 15:56:26', 1),
(125, 12, 'documents/images/quizbackgrounds/12/VMnHaXvs12T151632086352.jpg', 15, '2021-09-20 00:19:12', 0.46, 'jpg', 15, '2021-09-20 15:56:44', 1),
(126, 12, 'documents/images/quizbackgrounds/12/lXAczMMeVAU151632086367.jpg', 15, '2021-09-20 00:19:27', 0.13, 'jpg', 15, '2021-09-20 15:56:51', 1),
(127, 12, 'documents/images/quizbackgrounds/12/7rOrnGjjUU9151632086387.jpg', 15, '2021-09-20 00:19:47', 0.19, 'jpg', 15, '2021-09-20 15:56:57', 1),
(128, 12, 'documents/images/quizbackgrounds/12/fscsW8LENR1151632086403.jpg', 15, '2021-09-20 00:20:03', 0.29, 'jpg', 15, '2021-09-20 15:57:06', 1),
(130, 12, 'documents/images/quizbackgrounds/12/97ffswqCMRi151632086471.jpg', 15, '2021-09-20 00:21:11', 0.27, 'jpg', 15, '2021-09-20 15:57:11', 1),
(131, 12, 'documents/images/quizbackgrounds/12/nJMHUuKbaMN151632086513.jpg', 15, '2021-09-20 00:21:53', 0.44, 'jpg', 15, '2021-09-20 15:57:21', 1),
(132, 12, 'documents/images/quizbackgrounds/12/p2vvhh4Gd3E151632086652.jpg', 15, '2021-09-20 00:24:12', 0.3, 'jpg', 15, '2021-09-20 15:57:23', 1),
(133, 12, 'documents/images/quizbackgrounds/12/eIwWBjaC7FI151632086676.jpg', 15, '2021-09-20 00:24:36', 0.48, 'jpg', 15, '2021-09-20 15:14:20', 1),
(134, 12, 'documents/images/quizbackgrounds/12/unEiKyNatnE151632086692.jpg', 15, '2021-09-20 00:24:52', 0.13, 'jpg', 15, '2021-09-20 15:57:26', 1),
(135, 12, 'documents/images/quizbackgrounds/12/SCPU4WjdSiY151632086711.jpg', 15, '2021-09-20 00:25:11', 0.36, 'jpg', 15, '2021-09-20 15:22:40', 1),
(137, 12, 'documents/images/quizbackgrounds/12/RmXgdzRs1iL151632086957.jpg', 15, '2021-09-20 00:29:17', 0.26, 'jpg', 15, '2021-09-20 15:57:29', 1),
(138, 12, 'documents/images/quizbackgrounds/12/oMKNd4zrpCx151632086969.jpg', 15, '2021-09-20 00:29:29', 0.31, 'jpg', 15, '2021-09-20 15:57:32', 1),
(140, 12, 'documents/images/quizbackgrounds/12/dN7oSLkyHAF151632086991.jpg', 15, '2021-09-20 00:29:51', 0.18, 'jpg', 15, '2021-09-20 15:13:56', 1),
(142, 12, 'documents/images/quizbackgrounds/12/XVKqA2g4JGv151632087024.jpg', 15, '2021-09-20 00:30:24', 0.33, 'jpg', 15, '2021-09-20 15:57:36', 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `chat_group`
--

CREATE TABLE `chat_group` (
  `id` int(11) NOT NULL,
  `group_name` varchar(50) CHARACTER SET utf8 NOT NULL,
  `group_creator` int(11) NOT NULL,
  `creation_date` datetime NOT NULL,
  `invite_members` int(11) NOT NULL,
  `is_deleted` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `chat_group`
--

INSERT INTO `chat_group` (`id`, `group_name`, `group_creator`, `creation_date`, `invite_members`, `is_deleted`) VALUES
(1, 'Nyilvános chatszoba', 15, '2018-03-01 17:43:40', 0, 0),
(21, 'Szövetség', 15, '2021-03-15 14:45:09', 1, 0),
(32, 'Család', 101, '2021-07-02 18:24:57', 0, 0),
(34, 'ASDDDD', 15, '2021-08-07 10:43:58', 1, 0),
(40, 'Barátok', 94, '2021-08-23 00:30:06', 0, 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `chat_history`
--

CREATE TABLE `chat_history` (
  `group_id` int(11) NOT NULL,
  `event_text` varchar(500) NOT NULL,
  `event_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `chat_history`
--

INSERT INTO `chat_history` (`group_id`, `event_text`, `event_date`) VALUES
(21, 'Edit24 meghívta aaaa-t a csoportba. ', '2022-05-19 23:15:22'),
(21, 'sss eltávolította aaaa-t a csoportból. ', '2022-05-19 23:14:19'),
(21, 'sss meghívta Edit24-t a csoportba. ', '2022-05-19 23:09:10'),
(21, 'sss meghívta Mesi-t a csoportba. ', '2022-05-16 09:48:01'),
(40, 'aaaa eltávolította bbbb-t a csoportból. ', '2022-06-18 17:38:18'),
(40, 'aaaa meghívta sss-t a csoportba. ', '2022-06-18 17:38:11'),
(40, 'tttt kilépett a csoportból. ', '2021-09-05 17:55:33');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `chat_message`
--

CREATE TABLE `chat_message` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `msg` varchar(2000) COLLATE utf8mb4_bin NOT NULL,
  `sending_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

--
-- A tábla adatainak kiíratása `chat_message`
--

INSERT INTO `chat_message` (`id`, `user_id`, `group_id`, `msg`, `sending_time`) VALUES
(7, 15, 21, 'A csoport létrejött. - A csoport első és automatikus üzenete. Jó szórakozást!', '2021-03-15 14:45:09'),
(8, 15, 21, ' Létrehoztam ezt a szövetségi csoportot XD\ncool', '2021-03-15 14:46:10'),
(10, 94, 21, ' remek XD', '2021-03-15 14:47:45'),
(11, 94, 21, ' cool', '2021-03-15 15:01:54'),
(119, 94, 21, ' 😂😍', '2021-03-24 15:07:22'),
(178, 101, 32, 'A csoport létrejött. - A csoport első és automatikus üzenete. Jó szórakozást!', '2021-07-02 18:24:57'),
(191, 101, 32, ' Halii', '2021-07-02 18:30:53'),
(193, 94, 32, ' Helloooo :))', '2021-07-02 21:02:29'),
(215, 15, 34, 'A csoport létrejött. - A csoport első és automatikus üzenete. Jó szórakozást!', '2021-08-07 10:43:58'),
(244, 94, 40, 'A csoport létrejött. - A csoport első és automatikus üzenete. Jó szórakozást!', '2021-08-23 00:30:06'),
(245, 94, 40, ' Sziasztok! Mizu?', '2021-08-23 00:30:18'),
(246, 15, 40, ' Haliii ', '2021-08-23 10:27:51'),
(254, 118, 1, ' 4548956', '2021-08-24 19:37:33'),
(314, 15, 1, ' Ezt mindenki látja', '2022-06-20 13:14:23'),
(315, 15, 34, ' sziasztok!', '2022-06-20 13:14:45'),
(316, 15, 1, ' bárki írhat ide 👍😎', '2022-06-20 13:15:24'),
(317, 124, 1, ' Sziasztok', '2022-06-20 22:46:39');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `competition`
--

CREATE TABLE `competition` (
  `id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `announcement_date` date NOT NULL,
  `activity` int(11) NOT NULL,
  `reward1` int(11) NOT NULL,
  `reward2` int(11) NOT NULL,
  `reward3` int(11) NOT NULL,
  `reward4` int(11) NOT NULL,
  `reward5` int(11) NOT NULL,
  `reward6` int(11) NOT NULL,
  `reward7` int(11) NOT NULL,
  `startdate` datetime NOT NULL,
  `enddate` datetime NOT NULL,
  `button_color` varchar(20) NOT NULL DEFAULT '#1E90FF'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `competition`
--

INSERT INTO `competition` (`id`, `quiz_id`, `announcement_date`, `activity`, `reward1`, `reward2`, `reward3`, `reward4`, `reward5`, `reward6`, `reward7`, `startdate`, `enddate`, `button_color`) VALUES
(1, 11, '2020-10-25', -1, 1000, 875, 750, 580, 340, 100, 10, '2020-12-08 08:52:10', '2020-12-08 14:58:32', '#FF7C1E'),
(2, 12, '2020-12-18', -1, 2400, 2150, 1900, 1550, 1000, 550, 100, '2020-12-18 04:00:00', '2020-12-23 23:59:00', '#1E90FF'),
(3, 12, '2021-03-21', -1, 2000, 1650, 1200, 1100, 800, 150, 10, '2021-03-20 20:25:00', '2021-03-21 19:59:00', '#1E90FF'),
(4, 1, '2021-06-14', -1, 70, 60, 50, 40, 30, 20, 10, '2021-06-14 22:35:49', '2021-06-15 01:26:10', '#bf1945'),
(6, 6, '2021-08-16', -1, 1000, 900, 750, 625, 450, 195, 50, '2021-08-31 19:00:00', '2021-09-07 10:37:04', '#333399'),
(12, 11, '2021-10-24', -1, 10000, 8900, 6700, 3800, 2100, 1000, 100, '2021-10-29 20:00:00', '2021-11-03 23:59:59', '#ff8a05');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `favorite_quiz`
--

CREATE TABLE `favorite_quiz` (
  `user_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `favorite_quiz`
--

INSERT INTO `favorite_quiz` (`user_id`, `quiz_id`) VALUES
(15, 3),
(15, 6),
(15, 12),
(15, 67),
(15, 86),
(15, 164),
(15, 176),
(15, 177),
(94, 1),
(94, 4),
(94, 6),
(94, 164),
(94, 177),
(96, 67),
(99, 6),
(99, 97),
(99, 177),
(103, 67),
(108, 67),
(112, 67),
(112, 97),
(123, 11),
(123, 12),
(123, 67),
(123, 86),
(123, 97),
(123, 164),
(123, 176),
(123, 177);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `friend`
--

CREATE TABLE `friend` (
  `id1` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `friend`
--

INSERT INTO `friend` (`id1`, `id2`, `status`) VALUES
(3, 15, 1),
(15, 76, 1),
(15, 92, 0),
(15, 93, 0),
(15, 94, 1),
(15, 95, 0),
(15, 96, 0),
(15, 97, 0),
(15, 110, 0),
(15, 113, 0),
(15, 115, -1),
(55, 15, 1),
(55, 94, 1),
(78, 95, 1),
(87, 94, 1),
(87, 105, 0),
(87, 108, 1),
(94, 77, 1),
(94, 101, 1),
(94, 107, 1),
(94, 112, 1),
(94, 118, 1),
(94, 119, 0),
(101, 76, 1),
(102, 116, 1),
(104, 96, 0),
(108, 94, 1),
(118, 87, 0),
(122, 94, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `group_member`
--

CREATE TABLE `group_member` (
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `invited_by` int(11) NOT NULL,
  `joining_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `group_member`
--

INSERT INTO `group_member` (`group_id`, `user_id`, `invited_by`, `joining_date`) VALUES
(21, 3, 15, '2022-05-16 09:48:01'),
(21, 15, 15, '2021-03-15 14:45:09'),
(21, 87, 15, '2021-03-15 14:45:09'),
(21, 94, 122, '2022-05-19 23:15:22'),
(21, 104, 15, '2021-06-03 23:57:05'),
(21, 122, 15, '2022-05-19 23:09:10'),
(32, 76, 101, '2021-07-02 18:24:57'),
(32, 94, 101, '2021-07-02 18:28:45'),
(32, 101, 101, '2021-07-02 18:24:57'),
(34, 3, 15, '2021-08-07 10:43:58'),
(34, 15, 15, '2021-08-07 10:43:58'),
(34, 76, 15, '2021-08-07 10:43:58'),
(40, 15, 94, '2022-06-18 17:38:11'),
(40, 87, 94, '2021-08-23 00:30:06'),
(40, 94, 94, '2021-08-23 00:30:06');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `live_question`
--

CREATE TABLE `live_question` (
  `id` int(6) NOT NULL,
  `difficulty` int(11) NOT NULL,
  `question` varchar(255) NOT NULL,
  `ans1` varchar(150) NOT NULL,
  `ans2` varchar(150) NOT NULL,
  `ans3` varchar(150) NOT NULL,
  `ans4` varchar(150) NOT NULL,
  `user` varchar(30) NOT NULL,
  `bool` int(1) NOT NULL,
  `type` int(1) NOT NULL,
  `position` int(11) NOT NULL,
  `correct` int(11) NOT NULL,
  `own_answer` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `login`
--

CREATE TABLE `login` (
  `id` int(11) NOT NULL,
  `username` varchar(60) NOT NULL,
  `device_type` varchar(500) NOT NULL,
  `login_date` datetime NOT NULL,
  `is_success` int(11) NOT NULL,
  `login_type` int(11) NOT NULL DEFAULT 0,
  `logged_out` int(11) NOT NULL DEFAULT 1,
  `logout_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `login`
--

INSERT INTO `login` (`id`, `username`, `device_type`, `login_date`, `is_success`, `login_type`, `logged_out`, `logout_date`) VALUES
(2200, 'sss', 'DESKTOP', '2021-10-19 21:32:08', 1, 1, 1, '2021-10-19 21:54:47'),
(2201, 'sss', 'DESKTOP', '2021-10-19 21:54:52', 1, 1, 1, '2021-10-19 22:11:26'),
(2202, 'sss', 'DESKTOP', '2021-10-19 22:11:31', 1, 1, 1, '2021-10-19 22:54:55'),
(2203, 'sss', 'DESKTOP', '2021-10-19 23:34:08', 1, 1, 1, '2021-10-20 09:31:45'),
(2204, 'sss', 'DESKTOP', '2021-10-20 09:31:53', 1, 1, 1, '2021-10-20 10:40:55'),
(2205, 'sss', 'DESKTOP', '2021-10-20 10:08:01', 1, 0, 1, '2021-10-20 10:08:52'),
(2206, 'sss', 'DESKTOP', '2021-10-20 10:40:59', 1, 1, 1, '2021-10-20 11:16:41'),
(2207, 'sss', 'DESKTOP', '2021-10-20 10:51:37', 1, 0, 1, '2021-10-20 19:52:21'),
(2208, 'sss', 'DESKTOP', '2021-10-20 11:16:46', 1, 1, 1, '2021-10-20 12:06:25'),
(2209, 'sss', 'DESKTOP', '2021-10-20 12:06:49', 1, 1, 1, '2021-10-20 12:27:14'),
(2210, 'sss', 'DESKTOP', '2021-10-20 12:28:57', 1, 1, 1, '2021-10-20 13:13:17'),
(2211, 'sss', 'DESKTOP', '2021-10-20 13:13:21', 1, 1, 1, '2021-10-20 16:30:26'),
(2212, 'sss', 'DESKTOP', '2021-10-20 16:30:34', 1, 1, 1, '2021-10-20 19:15:25'),
(2213, 'sss', 'DESKTOP', '2021-10-20 19:15:34', 1, 1, 1, '2021-10-20 19:37:08'),
(2214, 'sss', 'DESKTOP', '2021-10-20 19:37:12', 1, 1, 1, '2021-10-20 21:15:06'),
(2215, 'sss', 'DESKTOP', '2021-10-20 21:15:12', 1, 1, 1, '2021-10-20 21:45:28'),
(2216, 'sss', 'DESKTOP', '2021-10-20 21:49:01', 1, 1, 1, '2021-10-20 22:09:47'),
(2217, 'sss', 'DESKTOP', '2021-10-20 22:37:21', 1, 0, 1, '2021-10-20 23:26:59'),
(2218, 'sss', 'DESKTOP', '2021-10-20 22:37:49', 1, 1, 1, '2021-10-21 08:13:23'),
(2219, 'sss', 'DESKTOP', '2021-10-20 23:27:03', 1, 0, 1, '2021-10-20 23:27:21'),
(2220, 'iiii', 'DESKTOP', '2021-10-20 23:27:27', 1, 0, 1, '2021-10-20 23:32:10'),
(2221, 'sss', 'DESKTOP', '2021-10-20 23:37:50', 1, 0, 1, '2021-10-20 23:41:24'),
(2222, 'sss', 'DESKTOP', '2021-10-21 08:13:31', 1, 1, 1, '2021-10-22 11:45:54'),
(2223, 'sss', 'DESKTOP', '2021-10-21 08:45:01', 1, 0, 1, '2021-10-21 08:45:08'),
(2224, 'sss', 'DESKTOP', '2021-10-22 11:46:00', 1, 1, 1, '2021-10-22 14:05:15'),
(2225, 'sss', 'DESKTOP', '2021-10-22 14:05:19', 1, 1, 1, '2021-10-22 16:15:56'),
(2226, 'sss', 'DESKTOP', '2021-10-22 16:17:30', 0, 0, 1, '0000-00-00 00:00:00'),
(2227, 'sss', 'DESKTOP', '2021-10-22 16:18:16', 0, 0, 1, '0000-00-00 00:00:00'),
(2228, 'sss', 'DESKTOP', '2021-10-22 16:18:32', 1, 0, 1, '2021-10-23 12:45:50'),
(2229, 'aaaa', 'DESKTOP', '2021-10-22 16:22:54', 1, 0, 1, '2021-10-22 16:52:44'),
(2230, 'sss', 'DESKTOP', '2021-10-22 16:52:48', 1, 0, 1, '2021-10-22 17:56:03'),
(2231, 'sss', 'DESKTOP', '2021-10-22 17:56:18', 0, 0, 1, '0000-00-00 00:00:00'),
(2232, 'sss', 'DESKTOP', '2021-10-22 17:56:29', 1, 0, 1, '2021-10-22 20:01:30'),
(2233, 'aaaa', 'DESKTOP', '2021-10-22 20:01:35', 1, 0, 1, '2021-10-22 20:49:32'),
(2234, 'sss', 'DESKTOP', '2021-10-22 20:58:01', 1, 0, 1, '2021-10-22 21:16:13'),
(2235, 'llll', 'DESKTOP', '2021-10-22 21:16:20', 1, 0, 1, '2021-10-22 21:42:44'),
(2236, 'sss', 'DESKTOP', '2021-10-22 21:42:54', 1, 1, 1, '2021-10-22 21:50:45'),
(2237, 'aaaa', 'DESKTOP', '2021-10-22 21:50:50', 1, 1, 1, '2021-10-22 21:51:34'),
(2238, 'sss', 'DESKTOP', '2021-10-22 23:29:30', 1, 0, 1, '2021-10-22 23:51:28'),
(2239, '\'', 'DESKTOP', '2021-10-22 23:51:38', 0, 0, 1, '0000-00-00 00:00:00'),
(2240, '\"', 'DESKTOP', '2021-10-22 23:52:00', 0, 0, 1, '0000-00-00 00:00:00'),
(2241, 'sss', 'DESKTOP', '2021-10-22 23:54:34', 0, 0, 1, '0000-00-00 00:00:00'),
(2242, 'sss', 'DESKTOP', '2021-10-22 23:54:47', 1, 0, 1, '2021-10-23 00:19:44'),
(2243, 'sss', 'DESKTOP', '2021-10-23 00:19:51', 1, 0, 1, '2021-10-23 00:20:13'),
(2244, 'sss', 'DESKTOP', '2021-10-23 08:23:57', 1, 0, 1, '2021-10-23 08:41:51'),
(2245, 'aaaa', 'DESKTOP', '2021-10-23 08:41:55', 1, 0, 1, '2021-10-23 09:22:48'),
(2246, 'sss', 'DESKTOP', '2021-10-23 09:22:54', 1, 0, 1, '2021-10-23 09:26:19'),
(2247, 'jjjj', 'DESKTOP', '2021-10-23 09:26:25', 1, 0, 1, '2021-10-23 09:45:55'),
(2248, 'sss', 'DESKTOP', '2021-10-23 09:45:59', 1, 0, 1, '2021-10-23 10:35:50'),
(2249, 'sss', 'DESKTOP', '2021-10-23 10:36:31', 1, 0, 1, '2021-10-23 10:36:41'),
(2250, 'iiii', 'DESKTOP', '2021-10-23 10:36:45', 1, 0, 1, '2021-10-23 10:38:25'),
(2251, 'aaaa', 'DESKTOP', '2021-10-23 10:38:29', 1, 0, 1, '2021-10-23 10:44:55'),
(2252, 'llll', 'DESKTOP', '2021-10-23 10:45:01', 1, 0, 1, '2021-10-23 11:07:54'),
(2253, 'aaaa', 'DESKTOP', '2021-10-23 11:07:58', 1, 0, 1, '2021-10-23 11:08:41'),
(2254, 'sss', 'DESKTOP', '2021-10-23 11:08:44', 1, 0, 1, '2021-10-23 11:20:40'),
(2255, 'sss', 'DESKTOP', '2021-10-23 11:20:49', 1, 1, 1, '2021-10-23 11:41:33'),
(2256, 'llll', 'DESKTOP', '2021-10-23 11:41:42', 1, 0, 1, '2021-10-23 11:58:40'),
(2257, 'sss', 'DESKTOP', '2021-10-23 11:58:48', 1, 1, 1, '2021-10-23 13:33:09'),
(2258, 'sss', 'DESKTOP', '2021-10-23 12:45:56', 1, 0, 1, '2021-10-23 21:58:33'),
(2259, 'aaaa', 'DESKTOP', '2021-10-23 16:59:34', 1, 0, 1, '2021-10-23 17:01:51'),
(2260, 'sss', 'DESKTOP', '2021-10-23 17:01:55', 1, 0, 1, '2021-10-23 17:44:33'),
(2261, 'sss', 'DESKTOP', '2021-10-27 10:26:04', 1, 0, 1, '2021-10-27 10:43:48'),
(2262, 'sss', 'DESKTOP', '2021-10-27 10:43:54', 0, 0, 1, '0000-00-00 00:00:00'),
(2263, 'sss', 'DESKTOP', '2021-10-27 10:44:00', 1, 0, 1, '2021-10-27 10:56:43'),
(2264, 'aaaa', 'DESKTOP', '2021-10-27 10:56:47', 1, 0, 1, '2021-10-27 11:05:07'),
(2265, 'sss', 'DESKTOP', '2021-10-27 11:05:15', 1, 1, 1, '0000-00-00 00:00:00'),
(2266, 'sss', 'DESKTOP', '2021-10-27 11:16:53', 1, 0, 1, '2021-10-27 11:17:40'),
(2267, 'sss', 'DESKTOP', '2021-10-27 11:23:12', 1, 1, 1, '2021-10-27 11:25:22'),
(2268, 'sss', 'DESKTOP', '2021-12-08 14:13:12', 1, 0, 1, '2021-12-08 14:14:47'),
(2269, 'sss', 'DESKTOP', '2021-12-08 14:14:56', 1, 1, 1, '2021-12-08 14:15:31'),
(2270, 'sss', 'DESKTOP', '2021-12-08 14:25:54', 1, 0, 0, '0000-00-00 00:00:00'),
(2271, 'sss', 'DESKTOP', '2021-12-08 14:27:22', 1, 0, 1, '2021-12-08 14:27:32'),
(2272, 'sss', 'DESKTOP', '2021-12-08 14:27:38', 1, 0, 0, '0000-00-00 00:00:00'),
(2273, 'sss', 'DESKTOP', '2021-12-08 14:27:58', 1, 0, 0, '0000-00-00 00:00:00'),
(2274, 'sss', 'DESKTOP', '2021-12-08 14:29:39', 1, 0, 1, '2021-12-08 14:29:45'),
(2275, 'sss', 'DESKTOP', '2021-12-08 14:29:48', 1, 0, 1, '2021-12-08 14:30:04'),
(2276, 'sss', 'DESKTOP', '2021-12-08 14:30:47', 1, 0, 1, '2021-12-08 14:30:59'),
(2277, 'sss', 'DESKTOP', '2021-12-08 14:31:01', 1, 0, 1, '2021-12-08 14:31:12'),
(2278, 'sss', 'DESKTOP', '2021-12-08 14:31:48', 1, 0, 1, '2021-12-08 14:32:47'),
(2279, 'sss', 'DESKTOP', '2021-12-08 14:33:09', 1, 0, 1, '2021-12-08 14:33:14'),
(2280, 'sss', 'DESKTOP', '2021-12-08 14:34:43', 1, 0, 1, '2021-12-08 14:36:17'),
(2281, 'sss', 'DESKTOP', '2021-12-08 14:36:20', 1, 0, 1, '2021-12-08 14:37:57'),
(2282, 'sss', 'DESKTOP', '2021-12-08 14:37:59', 1, 0, 1, '2021-12-08 14:38:23'),
(2283, 'sss', 'DESKTOP', '2021-12-08 14:38:30', 1, 0, 1, '2021-12-08 14:39:24'),
(2284, 'de', 'DESKTOP', '2021-12-08 14:39:29', 0, 0, 1, '0000-00-00 00:00:00'),
(2285, 'sss', 'DESKTOP', '2021-12-08 14:39:38', 1, 0, 1, '2021-12-08 14:41:10'),
(2286, 'sss', 'DESKTOP', '2021-12-08 14:41:42', 1, 0, 0, '0000-00-00 00:00:00'),
(2287, 'sss', 'DESKTOP', '2021-12-08 14:41:59', 1, 0, 1, '2021-12-08 14:43:46'),
(2288, 'sss', 'DESKTOP', '2021-12-08 14:43:56', 1, 0, 1, '2021-12-08 14:53:35'),
(2289, 'sss', 'DESKTOP', '2021-12-08 14:53:40', 1, 0, 1, '2021-12-08 14:54:16'),
(2290, 'sss', 'DESKTOP', '2021-12-08 14:54:20', 1, 0, 1, '2021-12-08 14:54:33'),
(2291, 'sss', 'DESKTOP', '2021-12-08 14:54:45', 1, 0, 1, '2021-12-08 14:57:27'),
(2292, 'sss', 'DESKTOP', '2021-12-08 14:57:32', 1, 0, 1, '2021-12-08 14:59:25'),
(2293, 'sss', 'DESKTOP', '2021-12-08 14:59:31', 1, 0, 1, '2021-12-08 15:00:12'),
(2294, 'sss', 'DESKTOP', '2021-12-08 15:00:16', 1, 0, 1, '2021-12-08 15:13:09'),
(2295, 'sss', 'DESKTOP', '2021-12-08 15:14:35', 1, 0, 0, '0000-00-00 00:00:00'),
(2296, 'sss', 'DESKTOP', '2021-12-08 15:15:07', 1, 0, 1, '2021-12-08 15:15:12'),
(2297, 'sss', 'DESKTOP', '2021-12-08 15:20:21', 0, 0, 1, '0000-00-00 00:00:00'),
(2298, 'sss', 'DESKTOP', '2021-12-08 15:20:36', 1, 0, 1, '2021-12-08 15:22:54'),
(2299, 'sss', 'DESKTOP', '2021-12-08 15:23:02', 1, 0, 1, '2021-12-08 15:28:59'),
(2300, 'sss', 'DESKTOP', '2021-12-08 15:29:05', 1, 0, 1, '2021-12-08 15:29:25'),
(2301, 'd4wfter', 'DESKTOP', '2021-12-08 15:29:28', 0, 0, 1, '0000-00-00 00:00:00'),
(2302, 'sss', 'DESKTOP', '2021-12-08 15:29:35', 1, 0, 1, '2021-12-08 15:29:36'),
(2303, 'aaaa', 'DESKTOP', '2021-12-08 15:33:17', 1, 0, 1, '2021-12-08 15:33:20'),
(2304, 'sss', 'DESKTOP', '2021-12-08 15:33:26', 1, 0, 1, '2021-12-08 15:33:33'),
(2305, 'sss', 'DESKTOP', '2021-12-08 15:33:41', 1, 0, 1, '2021-12-08 15:33:47'),
(2306, 'sss', 'DESKTOP', '2021-12-08 15:34:59', 1, 0, 1, '2021-12-08 15:57:26'),
(2307, 'sss', 'DESKTOP', '2021-12-08 15:57:43', 1, 0, 1, '2021-12-08 16:00:50'),
(2308, 'aaaa', 'DESKTOP', '2021-12-08 16:00:54', 1, 0, 1, '2021-12-08 16:01:38'),
(2309, 'sss', 'DESKTOP', '2021-12-08 16:01:48', 1, 0, 0, '0000-00-00 00:00:00'),
(2310, 'lkjh', 'DESKTOP', '2021-12-08 16:03:10', 1, 0, 1, '2021-12-08 16:03:33'),
(2311, 'sss', 'DESKTOP', '2021-12-08 16:08:37', 1, 1, 1, '2021-12-08 16:08:59'),
(2312, 'sss', 'DESKTOP', '2021-12-08 16:16:01', 1, 0, 1, '2021-12-08 16:16:46'),
(2313, 'sss', 'DESKTOP', '2021-12-08 16:16:59', 1, 0, 1, '2021-12-08 16:17:24'),
(2314, 'sss', 'DESKTOP', '2021-12-08 16:17:33', 1, 0, 0, '0000-00-00 00:00:00'),
(2315, 'aaaa', 'DESKTOP', '2021-12-08 16:22:59', 1, 0, 0, '0000-00-00 00:00:00'),
(2316, 'sss', 'DESKTOP', '2021-12-08 16:24:08', 1, 0, 1, '2021-12-08 16:24:25'),
(2317, 'sss', 'DESKTOP', '2021-12-08 16:24:31', 1, 0, 0, '0000-00-00 00:00:00'),
(2318, 'sss', 'DESKTOP', '2021-12-08 16:24:44', 1, 0, 0, '0000-00-00 00:00:00'),
(2319, 'sss', 'DESKTOP', '2021-12-08 16:32:14', 1, 1, 1, '2021-12-08 16:32:59'),
(2320, 'sss', 'DESKTOP', '2021-12-08 16:33:03', 1, 1, 1, '2021-12-08 16:34:07'),
(2321, 'sss', 'DESKTOP', '2021-12-08 16:34:10', 1, 1, 1, '2021-12-08 16:34:42'),
(2322, 'sss', 'DESKTOP', '2021-12-08 16:34:55', 1, 1, 1, '2021-12-08 16:36:12'),
(2323, 'sss', 'DESKTOP', '2021-12-08 16:36:21', 0, 1, 1, '0000-00-00 00:00:00'),
(2324, 'sss', 'DESKTOP', '2021-12-08 16:36:26', 1, 1, 1, '2021-12-08 16:36:40'),
(2325, 'sss', 'DESKTOP', '2021-12-08 16:36:46', 1, 1, 1, '2021-12-08 16:37:11'),
(2326, 'sss', 'DESKTOP', '2021-12-08 16:37:35', 1, 1, 1, '2021-12-08 16:37:37'),
(2327, 'sss', 'DESKTOP', '2021-12-12 11:03:29', 1, 0, 1, '2021-12-12 11:06:27'),
(2328, 'sss', 'DESKTOP', '2021-12-12 11:11:20', 1, 0, 1, '2021-12-12 11:53:33'),
(2329, 'sss', 'DESKTOP', '2021-12-12 11:53:39', 1, 0, 1, '2021-12-12 13:09:50'),
(2330, 'iiii', 'DESKTOP', '2021-12-12 13:10:00', 1, 0, 1, '2021-12-12 13:10:10'),
(2331, 'sss', 'DESKTOP', '2021-12-12 13:10:14', 1, 0, 1, '2021-12-12 15:00:25'),
(2332, 'sss', 'DESKTOP', '2021-12-12 15:00:30', 1, 0, 1, '2021-12-12 15:32:01'),
(2333, 'sss', 'DESKTOP', '2021-12-12 15:32:05', 1, 0, 1, '2021-12-12 15:59:20'),
(2334, 'sss', 'DESKTOP', '2021-12-12 15:59:24', 1, 0, 1, '2021-12-12 16:19:18'),
(2335, 'sss', 'DESKTOP', '2021-12-13 09:53:23', 1, 1, 1, '2021-12-13 09:53:51'),
(2336, 'sss', 'DESKTOP', '2021-12-13 17:10:03', 1, 0, 1, '2021-12-15 12:46:22'),
(2337, 'sss', 'DESKTOP', '2022-04-07 09:37:09', 1, 0, 1, '2022-04-07 09:39:54'),
(2338, 'sss', 'DESKTOP', '2022-04-07 09:40:04', 1, 1, 1, '2022-04-07 09:56:04'),
(2339, 'aaaa', 'DESKTOP', '2022-04-07 13:27:47', 1, 0, 1, '2022-04-21 09:09:31'),
(2340, 'sss', 'DESKTOP', '2022-04-21 09:09:44', 1, 0, 1, '2022-04-21 09:28:00'),
(2341, 'sss', 'DESKTOP', '2022-04-21 10:26:35', 0, 0, 1, '0000-00-00 00:00:00'),
(2342, 'sss', 'DESKTOP', '2022-04-21 10:45:47', 1, 0, 1, '2022-04-21 12:43:46'),
(2343, 'aaaa', 'DESKTOP', '2022-04-21 12:43:52', 1, 0, 1, '2022-04-21 12:44:05'),
(2344, 'sss', 'DESKTOP', '2022-04-21 12:44:09', 1, 0, 1, '2022-04-21 15:27:55'),
(2345, 'sss', 'DESKTOP', '2022-04-21 15:28:00', 1, 0, 1, '2022-04-21 15:55:35'),
(2346, 'llll', 'DESKTOP', '2022-04-21 15:55:46', 1, 0, 1, '2022-04-21 15:55:56'),
(2347, 'sss', 'DESKTOP', '2022-04-21 15:56:04', 1, 0, 1, '2022-04-21 16:17:40'),
(2348, 'EzEgyHosszuNevv', 'DESKTOP', '2022-04-21 16:17:49', 1, 0, 1, '2022-04-21 16:22:20'),
(2349, 'sss', 'DESKTOP', '2022-04-21 16:22:24', 1, 0, 1, '2022-04-21 16:37:41'),
(2350, 'sss', 'DESKTOP', '2022-04-21 16:38:40', 1, 0, 1, '2022-04-21 17:04:18'),
(2351, 'sss', 'DESKTOP', '2022-04-21 17:04:26', 1, 0, 1, '2022-04-21 17:50:10'),
(2352, 'sss', 'DESKTOP', '2022-04-21 17:50:15', 1, 0, 1, '2022-04-21 20:00:43'),
(2353, 'sss', 'DESKTOP', '2022-04-21 20:16:31', 0, 0, 1, '0000-00-00 00:00:00'),
(2354, 'sss', 'PHONE OR MOBILE', '2022-04-21 20:18:08', 0, 0, 1, '0000-00-00 00:00:00'),
(2355, 'sss', 'DESKTOP', '2022-04-21 20:19:02', 0, 0, 1, '0000-00-00 00:00:00'),
(2356, 'sss', 'PHONE OR MOBILE', '2022-04-21 23:40:56', 0, 0, 1, '0000-00-00 00:00:00'),
(2357, 'sss', 'PHONE OR MOBILE', '2022-04-21 23:41:03', 1, 0, 1, '2022-04-21 23:48:42'),
(2358, 'aaaa', 'DESKTOP', '2022-04-21 23:48:50', 1, 0, 1, '2022-04-22 00:32:23'),
(2359, 'sss', 'PHONE OR MOBILE', '2022-04-22 09:13:11', 1, 0, 1, '2022-04-22 12:00:07'),
(2360, 'sss', 'DESKTOP', '2022-04-22 12:01:10', 1, 0, 1, '2022-04-22 14:01:54'),
(2361, 'sss', 'DESKTOP', '2022-04-22 14:02:00', 1, 0, 1, '2022-04-22 20:20:53'),
(2362, 'sss', 'DESKTOP', '2022-04-22 20:20:58', 1, 0, 1, '2022-04-22 21:05:19'),
(2363, 'sss', 'DESKTOP', '2022-04-22 21:05:31', 1, 0, 1, '2022-04-22 21:21:32'),
(2364, 'sss', 'DESKTOP', '2022-04-22 21:21:36', 1, 0, 1, '2022-04-23 08:36:01'),
(2365, 'sss', 'DESKTOP', '2022-04-23 08:36:11', 1, 0, 1, '2022-04-23 10:01:59'),
(2366, 'sss', 'DESKTOP', '2022-04-23 10:02:02', 1, 0, 1, '2022-04-23 11:32:22'),
(2367, 'sss', 'DESKTOP', '2022-04-23 11:32:26', 1, 0, 1, '2022-04-23 12:32:04'),
(2368, 'sss', 'DESKTOP', '2022-04-23 13:31:22', 1, 0, 1, '2022-04-23 15:04:42'),
(2369, 'sss', 'DESKTOP', '2022-04-23 15:04:46', 0, 0, 1, '0000-00-00 00:00:00'),
(2370, 'sss', 'DESKTOP', '2022-04-23 15:04:51', 1, 0, 1, '2022-04-23 16:26:21'),
(2371, 'sss', 'DESKTOP', '2022-04-23 16:26:26', 1, 0, 1, '2022-04-23 17:23:49'),
(2372, 'sss', 'DESKTOP', '2022-04-23 17:23:52', 1, 0, 1, '2022-04-23 20:33:31'),
(2373, 'sss', 'DESKTOP', '2022-04-23 20:33:36', 1, 0, 1, '2022-04-24 09:09:45'),
(2374, 'sss', 'DESKTOP', '2022-04-24 09:09:51', 1, 0, 1, '2022-04-24 10:34:01'),
(2375, 'sss', 'DESKTOP', '2022-04-24 10:34:05', 1, 0, 1, '2022-04-24 13:09:33'),
(2376, 'llll', 'DESKTOP', '2022-04-24 13:09:56', 1, 0, 1, '2022-04-24 13:17:55'),
(2377, 'aaaa', 'DESKTOP', '2022-04-24 13:18:01', 1, 0, 1, '2022-04-24 13:19:50'),
(2378, 'sss', 'DESKTOP', '2022-04-24 13:19:54', 1, 0, 1, '2022-04-24 14:38:02'),
(2379, 'sss', 'DESKTOP', '2022-04-24 14:38:07', 1, 0, 1, '2022-04-24 16:03:14'),
(2380, 'aaaa', 'DESKTOP', '2022-04-24 16:03:18', 1, 0, 1, '2022-04-24 18:02:07'),
(2381, 'sss', 'DESKTOP', '2022-04-24 18:02:11', 1, 0, 1, '2022-04-24 18:05:43'),
(2382, 'aaaa', 'DESKTOP', '2022-04-24 18:05:50', 1, 0, 1, '2022-04-24 21:55:07'),
(2383, 'sss', 'DESKTOP', '2022-04-24 21:55:13', 1, 0, 1, '2022-04-24 22:32:12'),
(2384, 'sss', 'PHONE OR MOBILE', '2022-04-24 22:32:19', 1, 0, 1, '2022-04-24 23:20:27'),
(2385, 'sss', 'DESKTOP', '2022-04-27 12:22:36', 1, 0, 1, '2022-04-27 14:34:53'),
(2386, 'sss', 'DESKTOP', '2022-04-27 14:34:57', 1, 0, 1, '2022-04-27 18:25:57'),
(2387, 'sss', 'DESKTOP', '2022-04-27 18:26:01', 1, 0, 1, '2022-04-27 19:55:23'),
(2388, 'sss', 'DESKTOP', '2022-04-27 19:55:27', 1, 0, 1, '2022-04-27 21:58:00'),
(2389, 'sss', 'DESKTOP', '2022-04-27 20:06:15', 1, 1, 1, '2022-04-27 20:07:04'),
(2390, 'sss', 'DESKTOP', '2022-04-27 21:58:15', 1, 0, 1, '2022-04-27 22:30:22'),
(2391, 'sss', 'DESKTOP', '2022-04-27 22:30:26', 1, 0, 1, '2022-04-28 00:37:35'),
(2392, 'iiii', 'DESKTOP', '2022-04-28 00:37:42', 1, 0, 1, '2022-04-28 00:41:27'),
(2393, 'llll', 'DESKTOP', '2022-04-28 00:41:32', 1, 0, 1, '2022-04-28 09:13:05'),
(2394, 'sss', 'DESKTOP', '2022-04-28 09:13:12', 1, 0, 1, '2022-04-28 10:18:45'),
(2395, 'sss', 'DESKTOP', '2022-04-28 10:18:50', 1, 0, 1, '2022-04-28 12:18:26'),
(2396, 'sss', 'DESKTOP', '2022-04-28 12:02:44', 1, 1, 1, '2022-04-28 12:35:42'),
(2397, 'sss', 'DESKTOP', '2022-04-28 12:18:30', 1, 0, 1, '2022-04-28 12:35:19'),
(2398, 'sss', 'DESKTOP', '2022-04-28 12:35:23', 1, 0, 1, '2022-04-28 14:36:05'),
(2399, 'sss', 'DESKTOP', '2022-04-28 12:35:47', 1, 1, 1, '0000-00-00 00:00:00'),
(2400, 'aaaa', 'DESKTOP', '2022-04-28 12:47:25', 1, 0, 1, '2022-04-28 12:47:49'),
(2401, 'sss', 'DESKTOP', '2022-04-28 14:36:09', 1, 0, 1, '2022-04-28 15:06:52'),
(2402, 'Norberto99', 'DESKTOP', '2022-04-28 15:06:59', 1, 0, 1, '2022-04-28 15:07:03'),
(2403, 'iiii', 'DESKTOP', '2022-04-28 15:07:07', 1, 0, 1, '2022-04-28 15:10:17'),
(2404, 'sss', 'DESKTOP', '2022-04-28 15:10:20', 1, 0, 1, '2022-04-28 18:39:48'),
(2405, 'sss', 'DESKTOP', '2022-04-28 18:39:53', 1, 0, 1, '2022-04-28 18:53:11'),
(2406, 'llll', 'DESKTOP', '2022-04-28 18:53:16', 1, 0, 1, '2022-04-28 19:05:11'),
(2407, 'sss', 'DESKTOP', '2022-04-28 19:05:16', 1, 0, 1, '2022-04-28 19:44:14'),
(2408, 'sss', 'DESKTOP', '2022-04-28 19:44:18', 1, 0, 1, '2022-04-28 21:09:59'),
(2409, 'sss', 'DESKTOP', '2022-04-28 21:10:03', 1, 0, 1, '2022-04-28 21:49:41'),
(2410, 'sss', 'DESKTOP', '2022-04-28 21:49:50', 1, 0, 1, '2022-04-28 22:41:15'),
(2411, 'sss', 'DESKTOP', '2022-04-28 22:41:20', 1, 0, 1, '2022-04-29 00:41:38'),
(2412, 'sss', 'DESKTOP', '2022-04-28 23:58:46', 1, 1, 1, '2022-04-29 00:00:17'),
(2413, 'sss', 'DESKTOP', '2022-04-29 00:41:42', 1, 0, 1, '2022-04-29 09:37:21'),
(2414, 'aaaa', 'DESKTOP', '2022-04-29 09:37:27', 1, 0, 1, '2022-04-29 09:37:40'),
(2415, 'sss', 'DESKTOP', '2022-04-29 09:37:48', 1, 0, 1, '2022-04-29 10:15:45'),
(2416, 'sss', 'DESKTOP', '2022-04-29 09:40:03', 1, 1, 1, '2022-04-29 12:20:37'),
(2417, 'llll', 'DESKTOP', '2022-04-29 10:15:50', 1, 0, 1, '2022-04-29 10:16:46'),
(2418, 'sss', 'DESKTOP', '2022-04-29 10:16:51', 1, 0, 1, '2022-04-29 10:41:03'),
(2419, 'sss', 'DESKTOP', '2022-04-29 10:41:08', 1, 0, 1, '2022-04-29 12:03:53'),
(2420, 'aaaa', 'DESKTOP', '2022-04-29 12:03:57', 1, 0, 1, '2022-04-29 12:29:47'),
(2421, 'sss', 'DESKTOP', '2022-04-29 12:20:41', 1, 1, 1, '2022-04-29 12:57:54'),
(2422, 'sss', 'DESKTOP', '2022-04-29 12:29:51', 1, 0, 1, '2022-04-30 17:18:17'),
(2423, 'sss', 'DESKTOP', '2022-04-30 17:18:28', 1, 0, 1, '2022-04-30 19:06:31'),
(2424, 'sss', 'DESKTOP', '2022-04-30 19:06:36', 1, 0, 1, '2022-04-30 19:35:04'),
(2425, 'sss', 'DESKTOP', '2022-04-30 19:35:08', 1, 0, 1, '2022-05-01 09:59:52'),
(2426, 'sss', 'DESKTOP', '2022-05-01 09:59:57', 1, 0, 1, '2022-05-01 12:18:00'),
(2427, 'sss', 'DESKTOP', '2022-05-01 12:18:04', 1, 0, 1, '2022-05-01 12:59:38'),
(2428, 'sss', 'DESKTOP', '2022-05-01 12:59:42', 0, 0, 1, '0000-00-00 00:00:00'),
(2429, 'sss', 'DESKTOP', '2022-05-01 12:59:47', 1, 0, 1, '2022-05-01 13:03:14'),
(2430, 'llll', 'DESKTOP', '2022-05-01 13:03:19', 1, 0, 1, '2022-05-01 13:20:13'),
(2431, 'sss', 'DESKTOP', '2022-05-01 13:20:17', 1, 0, 1, '2022-05-01 13:20:29'),
(2432, 'llll', 'DESKTOP', '2022-05-01 13:20:36', 1, 0, 1, '2022-05-01 14:34:53'),
(2433, 'sss', 'DESKTOP', '2022-05-01 14:34:58', 1, 0, 1, '2022-05-01 14:49:05'),
(2434, 'llll', 'DESKTOP', '2022-05-01 14:49:10', 1, 0, 1, '2022-05-01 15:12:36'),
(2435, 'sss', 'DESKTOP', '2022-05-01 15:12:51', 1, 0, 1, '2022-05-01 15:47:07'),
(2436, 'sss', 'DESKTOP', '2022-05-01 15:47:12', 1, 0, 1, '2022-05-01 15:50:30'),
(2437, 'llll', 'DESKTOP', '2022-05-01 15:50:34', 1, 0, 1, '2022-05-01 19:49:31'),
(2438, 'sss', 'DESKTOP', '2022-05-01 19:49:39', 1, 0, 1, '2022-05-01 20:53:09'),
(2439, 'sss', 'DESKTOP', '2022-05-01 20:53:14', 1, 0, 1, '2022-05-01 21:06:02'),
(2440, 'iiii', 'DESKTOP', '2022-05-01 21:06:07', 1, 0, 1, '2022-05-01 21:46:44'),
(2441, 'aaaa', 'DESKTOP', '2022-05-01 21:46:50', 1, 0, 1, '2022-05-01 22:46:37'),
(2442, 'sss', 'DESKTOP', '2022-05-01 22:46:42', 1, 0, 1, '2022-05-01 22:48:20'),
(2443, 'aaaa', 'DESKTOP', '2022-05-01 22:48:23', 0, 0, 1, '0000-00-00 00:00:00'),
(2444, 'aaaa', 'DESKTOP', '2022-05-01 22:48:28', 1, 0, 1, '2022-05-02 09:41:12'),
(2445, 'aaaa', 'DESKTOP', '2022-05-02 09:41:20', 1, 0, 1, '2022-05-02 10:05:37'),
(2446, 'aaaa', 'DESKTOP', '2022-05-02 10:05:44', 1, 0, 0, '0000-00-00 00:00:00'),
(2447, 'aaaa', 'DESKTOP', '2022-05-02 10:05:45', 1, 0, 1, '2022-05-02 10:46:08'),
(2448, 'sss', 'DESKTOP', '2022-05-02 10:46:12', 1, 0, 1, '2022-05-02 11:10:43'),
(2449, 'aaaa', 'DESKTOP', '2022-05-02 11:10:46', 1, 0, 1, '2022-05-02 13:55:45'),
(2450, 'aaaa', 'DESKTOP', '2022-05-02 13:55:51', 1, 0, 1, '2022-05-02 17:17:45'),
(2451, 'aaaa', 'DESKTOP', '2022-05-02 17:17:50', 1, 0, 1, '2022-05-02 18:27:40'),
(2452, 'aaaa', 'DESKTOP', '2022-05-02 18:27:44', 1, 0, 1, '2022-05-02 21:40:01'),
(2453, 'sss', 'DESKTOP', '2022-05-02 21:40:06', 1, 0, 1, '2022-05-02 21:59:16'),
(2454, 'aaaa', 'DESKTOP', '2022-05-02 21:59:20', 1, 0, 1, '2022-05-02 22:00:24'),
(2455, 'sss', 'DESKTOP', '2022-05-02 22:00:27', 1, 0, 1, '2022-05-02 23:25:24'),
(2456, 'sss', 'DESKTOP', '2022-05-02 23:25:28', 1, 0, 1, '2022-05-03 22:30:01'),
(2457, 'Norberto99', 'DESKTOP', '2022-05-03 22:30:13', 1, 0, 1, '2022-05-03 22:30:54'),
(2458, 'aaaa', 'DESKTOP', '2022-05-03 22:30:59', 1, 0, 1, '2022-05-03 22:31:49'),
(2459, 'iiii', 'DESKTOP', '2022-05-03 22:31:54', 1, 0, 1, '2022-05-03 22:54:16'),
(2460, 'sss', 'DESKTOP', '2022-05-03 22:43:51', 1, 1, 1, '2022-05-03 23:17:44'),
(2461, 'sss', 'PHONE OR MOBILE', '2022-05-03 22:54:22', 1, 0, 1, '2022-05-03 22:55:39'),
(2462, 'Norberto99', 'DESKTOP', '2022-05-03 22:55:51', 1, 0, 1, '2022-05-03 23:16:30'),
(2463, 'llll', 'DESKTOP', '2022-05-03 23:16:35', 1, 0, 1, '2022-05-03 23:16:54'),
(2464, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-03 23:17:00', 0, 0, 1, '0000-00-00 00:00:00'),
(2465, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-03 23:17:07', 1, 0, 1, '2022-05-03 23:30:43'),
(2466, 'sss', 'DESKTOP', '2022-05-03 23:17:49', 1, 1, 1, '2022-05-03 23:36:13'),
(2467, 'sss', 'DESKTOP', '2022-05-03 23:30:47', 1, 0, 1, '2022-05-04 09:25:18'),
(2468, 'sss', 'DESKTOP', '2022-05-04 09:25:31', 1, 0, 1, '2022-05-04 10:33:01'),
(2469, 'aaaa', 'DESKTOP', '2022-05-04 10:33:04', 1, 0, 1, '2022-05-04 10:41:31'),
(2470, 'sss', 'DESKTOP', '2022-05-04 10:41:34', 1, 0, 1, '2022-05-04 11:31:40'),
(2471, 'aaaa', 'DESKTOP', '2022-05-04 11:31:44', 1, 0, 1, '2022-05-04 12:57:36'),
(2472, 'sss', 'DESKTOP', '2022-05-04 12:57:40', 1, 0, 1, '2022-05-04 14:09:38'),
(2473, 'sss', 'DESKTOP', '2022-05-04 14:09:42', 1, 0, 1, '2022-05-04 14:21:19'),
(2474, 'sss', 'DESKTOP', '2022-05-04 14:21:52', 1, 0, 1, '2022-05-04 16:02:20'),
(2475, 'sss', 'DESKTOP', '2022-05-04 16:02:24', 1, 0, 1, '2022-05-04 16:29:29'),
(2476, 'sss', 'DESKTOP', '2022-05-04 16:29:33', 1, 0, 1, '2022-05-04 17:41:29'),
(2477, 'aaaa', 'DESKTOP', '2022-05-04 17:41:34', 1, 0, 1, '2022-05-04 22:37:01'),
(2478, 'sss', 'DESKTOP', '2022-05-05 11:52:40', 1, 0, 1, '2022-05-05 13:39:08'),
(2479, 'sss', 'DESKTOP', '2022-05-05 13:39:13', 1, 0, 1, '2022-05-05 16:10:39'),
(2480, 'sss', 'DESKTOP', '2022-05-05 16:10:45', 1, 0, 1, '2022-05-05 17:05:23'),
(2481, 'sss', 'DESKTOP', '2022-05-05 17:05:26', 1, 0, 1, '2022-05-05 18:27:39'),
(2482, 'sss', 'DESKTOP', '2022-05-05 18:27:43', 1, 0, 1, '2022-05-05 21:08:43'),
(2483, 'sss', 'DESKTOP', '2022-05-05 21:08:47', 1, 0, 1, '2022-05-06 18:13:40'),
(2484, 'sss', 'DESKTOP', '2022-05-06 18:13:46', 1, 0, 1, '2022-05-06 21:35:07'),
(2485, 'sss', 'DESKTOP', '2022-05-06 21:35:57', 1, 0, 1, '2022-05-06 22:39:03'),
(2486, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-06 22:39:08', 1, 0, 1, '2022-05-06 22:39:24'),
(2487, 'sss', 'DESKTOP', '2022-05-06 22:39:27', 1, 0, 1, '2022-05-06 22:46:16'),
(2488, 'aaaa', 'DESKTOP', '2022-05-06 22:46:20', 1, 0, 1, '2022-05-06 23:02:01'),
(2489, 'sss', 'DESKTOP', '2022-05-06 23:02:05', 1, 0, 1, '2022-05-07 01:54:17'),
(2490, 'sss', 'DESKTOP', '2022-05-07 10:58:55', 1, 0, 1, '2022-05-07 11:51:24'),
(2491, 'sss', 'DESKTOP', '2022-05-07 11:51:29', 1, 0, 1, '2022-05-07 12:23:18'),
(2492, 'aaaa', 'DESKTOP', '2022-05-07 12:23:21', 1, 0, 1, '2022-05-07 15:39:41'),
(2493, 'sss', 'DESKTOP', '2022-05-07 12:27:53', 1, 1, 1, '2022-05-07 12:29:28'),
(2494, 'sss', 'DESKTOP', '2022-05-07 15:39:47', 1, 0, 1, '2022-05-07 22:27:33'),
(2495, 'sss', 'DESKTOP', '2022-05-14 14:01:50', 1, 0, 1, '2022-05-14 14:31:43'),
(2496, 'iiii', 'DESKTOP', '2022-05-14 14:31:47', 1, 0, 1, '2022-05-14 14:39:03'),
(2497, 'sss', 'DESKTOP', '2022-05-14 14:39:08', 1, 0, 1, '2022-05-14 17:08:57'),
(2498, 'sss', 'DESKTOP', '2022-05-14 17:09:00', 1, 0, 1, '2022-05-14 17:17:34'),
(2499, 'iiii', 'DESKTOP', '2022-05-14 17:17:40', 1, 0, 1, '2022-05-14 17:18:51'),
(2500, 'sss', 'DESKTOP', '2022-05-14 17:18:55', 1, 0, 1, '2022-05-14 19:41:05'),
(2501, 'sss', 'DESKTOP', '2022-05-14 19:41:08', 1, 0, 1, '2022-05-14 20:08:16'),
(2502, 'iiii', 'DESKTOP', '2022-05-14 20:08:21', 0, 0, 1, '0000-00-00 00:00:00'),
(2503, 'iiii', 'DESKTOP', '2022-05-14 20:08:26', 1, 0, 1, '2022-05-14 20:11:40'),
(2504, 'sss', 'DESKTOP', '2022-05-14 20:10:03', 1, 1, 1, '2022-05-14 20:11:47'),
(2505, 'aaaa', 'DESKTOP', '2022-05-14 20:12:01', 1, 0, 1, '2022-05-16 09:17:16'),
(2506, 'sss', 'DESKTOP', '2022-05-16 09:17:23', 1, 0, 1, '2022-05-16 10:17:43'),
(2507, 'iiii', 'DESKTOP', '2022-05-16 10:17:48', 1, 0, 1, '2022-05-16 10:58:32'),
(2508, 'aaaa', 'DESKTOP', '2022-05-16 10:58:36', 1, 0, 1, '2022-05-16 11:26:02'),
(2509, 'aaaa', 'DESKTOP', '2022-05-16 11:26:06', 1, 0, 1, '2022-05-16 11:26:35'),
(2510, 'iiii', 'DESKTOP', '2022-05-16 11:26:39', 1, 0, 1, '2022-05-16 11:27:03'),
(2511, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 11:27:07', 1, 0, 1, '2022-05-16 11:44:44'),
(2512, 'iiii', 'DESKTOP', '2022-05-16 11:44:50', 1, 0, 1, '2022-05-16 11:45:40'),
(2513, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 11:45:46', 0, 0, 1, '0000-00-00 00:00:00'),
(2514, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 11:45:51', 1, 0, 1, '2022-05-16 11:49:12'),
(2515, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 11:49:16', 1, 0, 1, '2022-05-16 11:49:55'),
(2516, 'iiii', 'DESKTOP', '2022-05-16 11:49:59', 1, 0, 1, '2022-05-16 11:51:28'),
(2517, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 11:51:35', 1, 0, 1, '2022-05-16 11:52:00'),
(2518, 'iiii', 'DESKTOP', '2022-05-16 11:52:04', 1, 0, 1, '2022-05-16 11:57:57'),
(2519, 'aaaa', 'DESKTOP', '2022-05-16 11:58:00', 1, 0, 1, '2022-05-16 12:50:19'),
(2520, 'aaaa', 'DESKTOP', '2022-05-16 12:50:23', 1, 0, 1, '2022-05-16 12:53:37'),
(2521, 'iiii', 'DESKTOP', '2022-05-16 12:53:42', 1, 0, 1, '2022-05-16 12:56:37'),
(2522, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 12:56:41', 1, 0, 1, '2022-05-16 12:59:12'),
(2523, 'iiii', 'DESKTOP', '2022-05-16 12:59:19', 1, 0, 1, '2022-05-16 13:53:21'),
(2524, 'aaaa', 'DESKTOP', '2022-05-16 13:53:26', 1, 0, 1, '2022-05-16 13:57:00'),
(2525, 'iiii', 'DESKTOP', '2022-05-16 13:57:04', 1, 0, 1, '2022-05-16 13:57:44'),
(2526, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 13:57:50', 1, 0, 1, '2022-05-16 13:58:51'),
(2527, 'iiii', 'DESKTOP', '2022-05-16 13:58:57', 1, 0, 1, '2022-05-16 14:00:12'),
(2528, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 14:00:17', 1, 0, 1, '2022-05-16 14:00:56'),
(2529, 'iiii', 'DESKTOP', '2022-05-16 14:01:03', 1, 0, 1, '2022-05-16 14:22:41'),
(2530, 'aaaa', 'DESKTOP', '2022-05-16 14:22:45', 1, 0, 1, '2022-05-16 14:24:59'),
(2531, 'sss', 'DESKTOP', '2022-05-16 14:25:03', 1, 0, 1, '2022-05-16 14:28:18'),
(2532, 'aaaa', 'DESKTOP', '2022-05-16 14:28:22', 1, 0, 1, '2022-05-16 14:56:56'),
(2533, 'iiii', 'DESKTOP', '2022-05-16 14:57:02', 1, 0, 1, '2022-05-16 14:59:50'),
(2534, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 14:59:54', 1, 0, 1, '2022-05-16 15:00:08'),
(2535, 'sss', 'DESKTOP', '2022-05-16 15:00:11', 1, 0, 1, '2022-05-16 15:00:39'),
(2536, 'aaaa', 'DESKTOP', '2022-05-16 15:00:42', 1, 0, 1, '2022-05-16 15:04:41'),
(2537, 'aaaa', 'DESKTOP', '2022-05-16 15:04:48', 1, 0, 1, '2022-05-16 15:04:56'),
(2538, 'sss', 'DESKTOP', '2022-05-16 15:04:58', 1, 0, 1, '2022-05-16 15:07:28'),
(2539, 'aaaa', 'DESKTOP', '2022-05-16 15:07:32', 1, 0, 1, '2022-05-16 16:07:25'),
(2540, 'sss', 'DESKTOP', '2022-05-16 16:07:28', 1, 0, 1, '2022-05-16 16:36:57'),
(2541, 'iiii', 'DESKTOP', '2022-05-16 16:37:02', 1, 0, 1, '2022-05-16 16:37:18'),
(2542, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 16:37:23', 1, 0, 1, '2022-05-16 16:44:40'),
(2543, 'iiii', 'DESKTOP', '2022-05-16 16:44:45', 1, 0, 1, '2022-05-16 16:48:16'),
(2544, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-16 16:48:20', 1, 0, 1, '2022-05-16 18:32:19'),
(2545, 'sss', 'DESKTOP', '2022-05-16 18:32:27', 1, 0, 1, '2022-05-16 19:01:11'),
(2546, 'aaaa', 'DESKTOP', '2022-05-16 19:01:14', 1, 0, 1, '2022-05-16 19:44:35'),
(2547, 'Norberto99', 'DESKTOP', '2022-05-16 19:44:40', 1, 0, 1, '2022-05-16 19:44:55'),
(2548, 'jjjj', 'DESKTOP', '2022-05-16 19:45:00', 1, 0, 1, '2022-05-16 21:54:21'),
(2549, 'sss', 'DESKTOP', '2022-05-16 21:54:25', 1, 0, 1, '2022-05-16 22:00:25'),
(2550, 'aaaa', 'DESKTOP', '2022-05-16 22:00:29', 1, 0, 1, '2022-05-16 23:09:52'),
(2551, 'aaaa', 'DESKTOP', '2022-05-16 23:11:34', 1, 0, 1, '2022-05-17 09:55:41'),
(2552, 'aaaa', 'DESKTOP', '2022-05-17 09:55:51', 1, 0, 1, '2022-05-17 10:11:22'),
(2553, 'aaaa', 'DESKTOP', '2022-05-17 10:11:27', 0, 0, 1, '0000-00-00 00:00:00'),
(2554, 'aaaa', 'DESKTOP', '2022-05-17 10:11:32', 1, 0, 1, '2022-05-17 11:16:10'),
(2555, 'aaaa', 'DESKTOP', '2022-05-17 11:16:16', 1, 0, 1, '2022-05-17 11:21:48'),
(2556, 'sss', 'DESKTOP', '2022-05-17 11:21:52', 1, 0, 1, '2022-05-17 11:22:47'),
(2557, 'Norberto99', 'DESKTOP', '2022-05-17 11:22:56', 1, 0, 0, '0000-00-00 00:00:00'),
(2558, 'Norberto99', 'DESKTOP', '2022-05-17 11:22:57', 1, 0, 1, '2022-05-17 11:23:16'),
(2559, 'EzEgyHosszuNevv', 'DESKTOP', '2022-05-17 11:23:21', 1, 0, 1, '2022-05-17 11:25:56'),
(2560, 'sss', 'DESKTOP', '2022-05-17 11:25:59', 1, 0, 1, '2022-05-17 12:07:49'),
(2561, 'sss', 'DESKTOP', '2022-05-17 12:07:53', 0, 0, 1, '0000-00-00 00:00:00'),
(2562, 'sss', 'DESKTOP', '2022-05-17 12:07:59', 0, 0, 1, '0000-00-00 00:00:00'),
(2563, 'sss', 'DESKTOP', '2022-05-17 12:08:06', 1, 0, 1, '2022-05-17 12:29:52'),
(2564, 'aaaa', 'DESKTOP', '2022-05-17 12:29:55', 1, 0, 1, '2022-05-17 12:49:34'),
(2565, 'sss', 'DESKTOP', '2022-05-17 12:50:51', 1, 0, 1, '2022-05-17 13:52:09'),
(2566, 'sss', 'DESKTOP', '2022-05-17 13:52:13', 1, 0, 1, '2022-05-17 13:53:02'),
(2567, 'iiii', 'DESKTOP', '2022-05-17 13:53:06', 1, 0, 1, '2022-05-17 14:06:49'),
(2568, 'sss', 'DESKTOP', '2022-05-17 14:06:52', 1, 0, 1, '2022-05-17 14:36:29'),
(2569, 'aaaa', 'DESKTOP', '2022-05-17 14:36:32', 1, 0, 1, '2022-05-17 15:41:10'),
(2570, 'sss', 'DESKTOP', '2022-05-17 15:41:15', 1, 0, 1, '2022-05-17 19:02:13'),
(2571, 'sss', 'DESKTOP', '2022-05-17 19:02:17', 1, 0, 1, '2022-05-17 19:28:08'),
(2572, 'sss', 'DESKTOP', '2022-05-17 19:28:12', 1, 0, 1, '2022-05-17 20:17:34'),
(2573, 'paraZita0', 'DESKTOP', '2022-05-17 19:39:02', 1, 0, 1, '2022-05-17 19:54:56'),
(2574, 'paraZita0', 'DESKTOP', '2022-05-17 20:07:12', 1, 0, 1, '2022-05-17 20:15:53'),
(2575, 'jjjj', 'DESKTOP', '2022-05-17 20:16:04', 1, 0, 0, '0000-00-00 00:00:00'),
(2576, 'aaaa', 'DESKTOP', '2022-05-17 20:17:38', 1, 0, 1, '2022-05-17 22:07:35'),
(2577, 'sss', 'DESKTOP', '2022-05-17 22:07:40', 1, 0, 1, '2022-05-18 08:44:09'),
(2578, 'sss', 'DESKTOP', '2022-05-18 08:44:22', 1, 0, 1, '2022-05-18 09:14:01'),
(2579, 'jjjj', 'DESKTOP', '2022-05-18 09:08:21', 1, 0, 1, '2022-05-18 09:12:56'),
(2580, 'aaaa', 'DESKTOP', '2022-05-18 09:13:01', 1, 0, 1, '2022-05-18 09:13:11'),
(2581, 'jjjj', 'DESKTOP', '2022-05-18 09:13:15', 1, 0, 1, '2022-05-18 09:18:48'),
(2582, 'aaaa', 'DESKTOP', '2022-05-18 09:14:19', 1, 0, 1, '2022-05-18 11:14:09'),
(2583, 'sss', 'DESKTOP', '2022-05-18 11:14:13', 1, 0, 1, '2022-05-18 20:23:13'),
(2584, 'sss', 'DESKTOP', '2022-05-18 20:23:21', 1, 0, 1, '2022-05-18 21:45:51'),
(2585, 'sss', 'DESKTOP', '2022-05-19 15:09:41', 1, 0, 1, '2022-05-19 15:58:30'),
(2586, 'Edit24', 'DESKTOP', '2022-05-19 16:26:06', 1, 0, 1, '2022-05-19 16:27:24'),
(2587, 'Edit24', 'DESKTOP', '2022-05-19 16:27:39', 0, 0, 1, '0000-00-00 00:00:00'),
(2588, 'Edit24', 'DESKTOP', '2022-05-19 16:27:52', 1, 0, 1, '2022-05-19 16:28:50'),
(2589, 'Edit24', 'DESKTOP', '2022-05-19 16:29:03', 0, 0, 1, '0000-00-00 00:00:00'),
(2590, 'Edit24', 'DESKTOP', '2022-05-19 16:29:17', 1, 0, 1, '2022-05-19 16:30:19'),
(2591, 'Edit24', 'DESKTOP', '2022-05-19 16:30:25', 0, 0, 1, '0000-00-00 00:00:00'),
(2592, 'Edit24', 'DESKTOP', '2022-05-19 16:30:31', 1, 0, 1, '2022-05-19 16:30:35'),
(2593, 'sss', 'DESKTOP', '2022-05-19 16:31:42', 1, 1, 1, '2022-05-19 16:32:41'),
(2594, 'Edit24', 'DESKTOP', '2022-05-19 16:33:21', 1, 0, 0, '0000-00-00 00:00:00'),
(2595, 'Edit24', 'DESKTOP', '2022-05-19 16:35:16', 0, 0, 1, '0000-00-00 00:00:00'),
(2596, 'sss', 'DESKTOP', '2022-05-19 16:35:43', 1, 1, 1, '2022-05-19 16:37:03'),
(2597, 'Edit24', 'DESKTOP', '2022-05-19 16:36:27', 1, 0, 1, '2022-05-19 16:36:56'),
(2598, 'sss', 'DESKTOP', '2022-05-19 18:03:16', 1, 0, 1, '2022-05-19 18:25:02'),
(2599, 'aaaa', 'DESKTOP', '2022-05-19 18:25:06', 1, 0, 1, '2022-05-19 18:25:38'),
(2600, 'jjjj', 'DESKTOP', '2022-05-19 18:25:46', 1, 0, 1, '2022-05-19 18:26:21'),
(2601, 'aaaa', 'DESKTOP', '2022-05-19 18:26:25', 1, 0, 1, '2022-05-19 18:27:21'),
(2602, 'jjjj', 'DESKTOP', '2022-05-19 18:27:26', 1, 0, 1, '2022-05-19 18:27:34'),
(2603, 'aaaa', 'DESKTOP', '2022-05-19 18:27:48', 1, 0, 1, '2022-05-19 21:28:15'),
(2604, 'aaaa', 'DESKTOP', '2022-05-19 21:28:19', 1, 0, 1, '2022-05-19 22:22:00'),
(2605, 'sss', 'DESKTOP', '2022-05-19 22:22:46', 1, 0, 1, '2022-05-19 23:07:43'),
(2606, 'Edit24', 'DESKTOP', '2022-05-19 23:07:48', 1, 0, 1, '2022-05-19 23:08:42'),
(2607, 'sss', 'DESKTOP', '2022-05-19 23:08:46', 1, 0, 1, '2022-05-19 23:09:18'),
(2608, 'Edit24', 'DESKTOP', '2022-05-19 23:09:23', 1, 0, 1, '2022-05-19 23:10:27'),
(2609, 'aaaa', 'DESKTOP', '2022-05-19 23:10:31', 1, 0, 1, '2022-05-19 23:10:58'),
(2610, 'Edit24', 'DESKTOP', '2022-05-19 23:11:03', 1, 0, 1, '2022-05-19 23:14:09'),
(2611, 'sss', 'DESKTOP', '2022-05-19 23:12:03', 1, 1, 1, '0000-00-00 00:00:00'),
(2612, 'sss', 'DESKTOP', '2022-05-19 23:14:12', 1, 0, 1, '2022-05-19 23:14:24'),
(2613, 'Edit24', 'DESKTOP', '2022-05-19 23:14:34', 1, 0, 1, '2022-05-19 23:54:48'),
(2614, 'sss', 'DESKTOP', '2022-05-19 23:54:53', 1, 0, 1, '2022-05-20 00:05:34'),
(2615, 'sss', 'DESKTOP', '2022-05-20 00:05:39', 1, 0, 1, '2022-05-20 01:19:45'),
(2616, 'sss', 'DESKTOP', '2022-05-21 14:35:27', 1, 0, 1, '2022-05-21 15:31:18'),
(2617, 'Edit24', 'DESKTOP', '2022-05-21 15:31:22', 1, 0, 1, '2022-05-21 17:27:51'),
(2618, 'sss', 'DESKTOP', '2022-05-21 18:45:06', 1, 0, 1, '2022-05-21 19:00:09'),
(2619, 'sss', 'DESKTOP', '2022-05-21 19:00:14', 1, 0, 1, '2022-05-21 21:00:12'),
(2620, 'sss', 'DESKTOP', '2022-05-21 19:36:02', 1, 1, 1, '2022-05-21 19:55:50'),
(2621, 'sss', 'DESKTOP', '2022-05-21 19:55:53', 1, 1, 1, '2022-05-21 20:14:26'),
(2622, 'sss', 'DESKTOP', '2022-05-21 21:00:16', 1, 0, 1, '2022-05-21 22:17:47'),
(2623, 'sss', 'DESKTOP', '2022-05-21 22:17:51', 1, 0, 1, '2022-05-21 23:40:40'),
(2624, 'sss', 'DESKTOP', '2022-05-21 23:40:45', 1, 0, 1, '2022-05-22 08:40:00'),
(2625, 'aaaa', 'DESKTOP', '2022-05-22 08:40:24', 1, 0, 1, '2022-05-22 09:23:38'),
(2626, 'sss', 'DESKTOP', '2022-05-22 09:30:13', 1, 0, 0, '0000-00-00 00:00:00'),
(2627, 'aaaa', 'DESKTOP', '2022-05-22 09:42:22', 1, 0, 1, '2022-05-22 10:35:14'),
(2628, 'sss', 'DESKTOP', '2022-05-22 10:35:19', 1, 0, 1, '2022-05-22 22:09:41'),
(2629, 'aaaa', 'DESKTOP', '2022-05-22 22:07:33', 1, 0, 1, '2022-05-22 22:09:27'),
(2630, 'sss', 'DESKTOP', '2022-05-27 10:16:47', 0, 0, 1, '0000-00-00 00:00:00'),
(2631, 'sss', 'DESKTOP', '2022-05-27 10:17:14', 0, 0, 1, '0000-00-00 00:00:00'),
(2632, 'sss', 'DESKTOP', '2022-05-27 10:17:21', 0, 0, 1, '0000-00-00 00:00:00'),
(2633, 'sss', 'DESKTOP', '2022-05-27 10:17:24', 0, 0, 1, '0000-00-00 00:00:00'),
(2634, 'sss', 'DESKTOP', '2022-05-27 10:21:41', 1, 0, 1, '2022-05-27 10:21:47'),
(2635, 'aaaa', 'DESKTOP', '2022-05-30 11:04:51', 1, 0, 1, '2022-05-30 11:07:21'),
(2636, 'sss', 'DESKTOP', '2022-05-30 11:07:24', 1, 0, 1, '2022-05-30 12:22:45'),
(2637, 'sss', 'DESKTOP', '2022-05-31 14:36:01', 1, 0, 1, '2022-05-31 14:37:17'),
(2638, 'user99', 'DESKTOP', '2022-06-18 16:23:28', 1, 0, 1, '2022-06-18 16:26:21'),
(2639, 'sss', 'DESKTOP', '2022-06-18 16:24:45', 1, 1, 1, '2022-06-18 16:37:42'),
(2640, 'sss', 'DESKTOP', '2022-06-18 16:26:27', 1, 0, 1, '2022-06-18 16:36:55'),
(2641, 'aaaa', 'DESKTOP', '2022-06-18 16:36:59', 1, 0, 1, '2022-06-18 16:37:16'),
(2642, 'user99', 'DESKTOP', '2022-06-18 16:37:26', 1, 0, 1, '2022-06-18 17:00:38'),
(2643, 'sss', 'DESKTOP', '2022-06-18 17:00:41', 1, 0, 1, '2022-06-18 17:23:48'),
(2644, 'sss', 'DESKTOP', '2022-06-18 17:15:27', 1, 1, 1, '2022-06-18 17:30:48'),
(2645, 'aaaa', 'DESKTOP', '2022-06-18 17:23:52', 1, 0, 1, '2022-06-18 18:18:26'),
(2646, 'sss', 'DESKTOP', '2022-06-18 18:24:30', 1, 1, 1, '2022-06-19 00:36:47'),
(2647, 'sss', 'DESKTOP', '2022-06-19 11:07:58', 0, 0, 1, '0000-00-00 00:00:00'),
(2648, 'sss', 'DESKTOP', '2022-06-19 11:08:16', 1, 0, 1, '2022-06-19 13:12:27'),
(2649, 'sss', 'DESKTOP', '2022-06-20 12:51:40', 1, 0, 1, '2022-06-20 14:24:35'),
(2650, 'sss', 'DESKTOP', '2022-06-20 12:58:37', 1, 1, 1, '0000-00-00 00:00:00'),
(2651, 'sss', 'DESKTOP', '2022-06-20 14:24:41', 1, 0, 1, '2022-06-20 14:56:39'),
(2652, 'sss', 'DESKTOP', '2022-06-20 15:00:57', 0, 0, 1, '0000-00-00 00:00:00'),
(2653, 'sss', 'DESKTOP', '2022-06-20 15:01:09', 1, 0, 1, '2022-06-20 15:18:16'),
(2654, 'sss', 'DESKTOP', '2022-06-20 15:18:25', 1, 1, 1, '2022-06-20 15:32:00'),
(2655, 'sss', 'DESKTOP', '2022-06-20 15:32:09', 1, 0, 1, '2022-06-20 18:15:24'),
(2656, 'sss', 'DESKTOP', '2022-06-20 18:17:23', 1, 0, 1, '2022-06-20 18:35:23'),
(2657, 'sss', 'DESKTOP', '2022-06-20 18:35:27', 0, 0, 1, '0000-00-00 00:00:00'),
(2658, 'aaaa', 'DESKTOP', '2022-06-20 18:35:34', 0, 0, 1, '0000-00-00 00:00:00'),
(2659, 'sss', 'DESKTOP', '2022-06-20 18:35:39', 1, 0, 1, '2022-06-20 19:02:44'),
(2660, 'sss', 'DESKTOP', '2022-06-20 19:02:49', 1, 0, 1, '2022-06-20 19:36:22'),
(2661, 'sss', 'DESKTOP', '2022-06-20 19:07:33', 1, 1, 1, '0000-00-00 00:00:00'),
(2662, 'sss', 'DESKTOP', '2022-06-20 19:36:26', 1, 0, 1, '2022-06-20 22:36:09'),
(2663, 'ffff', 'DESKTOP', '2022-06-20 22:36:46', 1, 0, 1, '2022-06-20 22:52:09'),
(2664, 'evike', 'DESKTOP', '2022-06-20 22:48:26', 0, 1, 1, '0000-00-00 00:00:00'),
(2665, 'sss', 'DESKTOP', '2022-06-20 22:48:32', 0, 1, 1, '0000-00-00 00:00:00'),
(2666, 'sss', 'DESKTOP', '2022-06-20 22:48:37', 1, 1, 1, '2022-06-20 23:47:34'),
(2667, 'sss', 'DESKTOP', '2022-06-20 22:52:14', 1, 0, 0, '0000-00-00 00:00:00'),
(2668, 'sss', 'DESKTOP', '2022-06-20 23:47:37', 1, 1, 1, '2022-06-21 00:09:14'),
(2669, 'sss', 'DESKTOP', '2022-06-21 00:15:11', 1, 1, 1, '2022-06-21 00:23:11'),
(2670, 'sss', 'DESKTOP', '2022-06-21 00:23:18', 1, 0, 1, '2022-06-21 00:23:39');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `log_data`
--

CREATE TABLE `log_data` (
  `id` int(11) NOT NULL,
  `log_type` int(11) NOT NULL,
  `username` varchar(25) NOT NULL,
  `log_message` varchar(1000) NOT NULL,
  `admin_name` varchar(25) NOT NULL,
  `log_date` datetime NOT NULL,
  `is_seen` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `log_data`
--

INSERT INTO `log_data` (`id`, `log_type`, `username`, `log_message`, `admin_name`, `log_date`, `is_seen`) VALUES
(7620, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 14:15:31', 1),
(7621, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:25:54', 1),
(7622, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:27:22', 1),
(7623, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:27:32', 1),
(7624, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:27:38', 1),
(7625, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:27:58', 1),
(7626, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:29:39', 1),
(7627, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:29:45', 1),
(7628, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:29:48', 1),
(7629, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:30:04', 1),
(7630, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:30:47', 1),
(7631, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:30:59', 1),
(7632, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:31:01', 1),
(7633, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:31:12', 1),
(7634, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:31:48', 1),
(7635, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:32:47', 1),
(7636, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:33:09', 1),
(7637, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:33:14', 1),
(7638, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:34:43', 1),
(7639, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:36:17', 1),
(7640, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:36:20', 1),
(7641, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:37:57', 1),
(7642, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:37:59', 1),
(7643, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:38:23', 1),
(7644, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:38:30', 1),
(7645, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:39:24', 1),
(7646, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:39:38', 1),
(7647, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:41:10', 1),
(7648, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:41:42', 1),
(7649, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:41:59', 1),
(7650, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:43:46', 1),
(7651, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:43:56', 1),
(7652, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:53:35', 1),
(7653, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:53:40', 1),
(7654, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:54:16', 1),
(7655, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:54:20', 1),
(7656, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:54:33', 1),
(7657, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:54:45', 1),
(7658, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:57:27', 1),
(7659, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:57:32', 1),
(7660, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 14:59:25', 1),
(7661, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 14:59:31', 1),
(7662, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:00:12', 1),
(7663, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:00:16', 1),
(7664, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:13:09', 1),
(7665, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:14:35', 1),
(7666, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:15:07', 1),
(7667, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:15:12', 1),
(7668, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:20:36', 1),
(7669, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:22:54', 1),
(7670, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:23:02', 1),
(7671, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:28:59', 1),
(7672, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:29:05', 1),
(7673, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:29:25', 1),
(7674, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:29:35', 1),
(7675, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:29:36', 1),
(7676, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:33:17', 1),
(7677, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:33:20', 1),
(7678, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:33:26', 1),
(7679, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:33:33', 1),
(7680, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:33:41', 1),
(7681, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 15:33:47', 1),
(7682, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:34:59', 1),
(7683, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2021-12-08 15:57:26', 1),
(7684, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 15:57:43', 1),
(7685, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 16:00:50', 1),
(7686, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:00:54', 1),
(7687, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 16:01:38', 1),
(7688, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:01:48', 1),
(7689, 2, 'lkjh', 'Sikeres regisztráció történt.', 'SYSTEM', '2021-12-08 16:03:02', 1),
(7690, 1, 'lkjh', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:03:10', 1),
(7691, 26, 'lkjh', 'A felhasználó kedvelte a/az HTML kvízt', 'SYSTEM', '2021-12-08 16:03:20', 1),
(7692, 1, 'lkjh', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 16:03:33', 1),
(7693, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:08:37', 1),
(7694, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:08:59', 1),
(7695, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:16:01', 1),
(7696, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 16:16:46', 1),
(7697, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:16:59', 1),
(7698, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 16:17:24', 1),
(7699, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:17:33', 1),
(7700, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:22:59', 1),
(7701, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:24:08', 1),
(7702, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-08 16:24:25', 1),
(7703, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:24:31', 1),
(7704, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-08 16:24:44', 1),
(7705, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:32:14', 1),
(7706, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:32:59', 1),
(7707, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:33:03', 1),
(7708, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:34:07', 1),
(7709, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:34:10', 1),
(7710, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:34:42', 1),
(7711, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:34:55', 1),
(7712, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:36:12', 1),
(7713, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:36:26', 1),
(7714, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:36:40', 1),
(7715, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:36:46', 1),
(7716, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:37:11', 1),
(7717, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:37:35', 1),
(7718, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-08 16:37:37', 1),
(7719, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-12 11:03:29', 1),
(7720, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-12 11:06:27', 1),
(7721, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-12 11:11:20', 1),
(7722, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2021-12-12 11:53:33', 1),
(7723, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-12 11:53:39', 1),
(7724, 9, 'sss', 'Új kérdés: Az h?', 'SYSTEM', '2021-12-12 12:00:59', 1),
(7725, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2021-12-12 13:09:50', 1),
(7726, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-12 13:10:00', 1),
(7727, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-12 13:10:10', 1),
(7728, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-12 13:10:14', 1),
(7729, 35, 'sss', 'A/Az 7179 - azonosítójú kérdés javítva!', 'SYSTEM', '2021-12-12 13:21:44', 1),
(7730, 35, 'sss', 'A/Az 7544 - azonosítójú kérdés javítva!', 'SYSTEM', '2021-12-12 13:21:58', 1),
(7731, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2021-12-12 15:00:25', 1),
(7732, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-12 15:00:30', 1),
(7733, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2021-12-12 15:32:01', 1),
(7734, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-12 15:32:05', 1),
(7735, 13, 'sss', 'A/Az Kicsi redfeurdth témájú kvíz adatait sikeresen elküldted. Ennek jóváhagyásáról, és a további tennivalókról értesíteni fogunk! ', 'SYSTEM', '2021-12-12 15:34:14', 1),
(7736, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2021-12-12 15:59:20', 1),
(7737, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-12 15:59:24', 1),
(7738, 18, 'sss', 'A/Az Űűűűűűűűűűűűűűűűűűű témájú kérésedet sikeresen rögzítettük. Ennek jóváhagyásáról értesíteni fogunk! ', 'SYSTEM', '2021-12-12 16:01:49', 1),
(7739, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2021-12-12 16:19:18', 1),
(7740, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2021-12-13 09:53:23', 1),
(7741, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2021-12-13 09:53:51', 1),
(7742, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2021-12-13 17:10:03', 1),
(7743, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2021-12-15 12:46:22', 1),
(7744, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-07 09:37:09', 1),
(7745, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-07 09:39:54', 1),
(7746, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-04-07 09:40:04', 1),
(7747, 11, 'norbika', 'Kérdés visszaküldve! - A 1478 - azonosítójú kérdést visszaküldték javításra. Ok:  Rossz témakörválasztás. A kérdés túl bonyolult/nem egyértelmű a megfogalmazás.!', 'sss', '2022-04-07 09:45:54', 0),
(7748, 11, 'norbika', 'Kérdés visszaküldve! - A 1480 - azonosítójú kérdést visszaküldték javításra. Ok:  A kérdés túl bonyolult/nem egyértelmű a megfogalmazás.!', 'sss', '2022-04-07 09:46:00', 0),
(7749, 11, 'norbika', 'Kérdés visszaküldve! - A 1479 - azonosítójú kérdést visszaküldték javításra. Ok:  Hibás adat/Helytelen a kérdés.!', 'sss', '2022-04-07 09:46:10', 0),
(7750, 16, 'aaaa', 'Kvíz törölve! A/Az Arrafelé a mocsárban 1.  nevű kvízed törölve lett a következő indokkal: Nem egyértelmű kvíznév, vagy leírás. ', 'sss', '2022-04-07 09:50:41', 1),
(7751, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-04-07 09:56:04', 1),
(7752, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-07 13:27:47', 1),
(7753, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-21 09:09:31', 1),
(7754, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 09:09:44', 1),
(7755, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-21 09:28:00', 1),
(7756, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 10:45:47', 1),
(7757, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-21 12:43:46', 1),
(7758, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 12:43:52', 1),
(7759, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-21 12:44:05', 1),
(7760, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 12:44:09', 1),
(7761, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-21 15:27:55', 1),
(7762, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 15:28:00', 1),
(7763, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-21 15:55:35', 1),
(7764, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 15:55:46', 1),
(7765, 1, 'llll', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-21 15:55:56', 1),
(7766, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 15:56:04', 1),
(7767, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-21 16:17:40', 1),
(7768, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 16:17:49', 1),
(7769, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-21 16:22:20', 1),
(7770, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 16:22:24', 1),
(7771, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-21 16:37:41', 1),
(7772, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 16:38:40', 1),
(7773, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-21 17:04:18', 1),
(7774, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 17:04:26', 1),
(7775, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-21 17:50:10', 1),
(7776, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 17:50:15', 1),
(7777, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-21 20:00:43', 1),
(7778, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 23:41:03', 1),
(7779, 7, '15', 'Hír közzétéve a Főoldalon. A hír témája/címe: Message important', 'SYSTEM', '2022-04-21 23:45:05', 1),
(7780, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-21 23:48:42', 1),
(7781, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-21 23:48:50', 1),
(7782, 7, '94', 'Hír közzétéve a Főoldalon. A hír témája/címe: Felicia Mercado', 'SYSTEM', '2022-04-21 23:49:32', 1),
(7783, 7, 'sss', 'A/Az qwr  rewfsd hírt törölték. Ennek oka: Próba hír törlése', 'aaaa', '2022-04-21 23:56:49', 0),
(7784, 7, 'sss', 'A/Az A legelső hír 3 hírt törölték. Ennek oka: Próba hír törlése', 'aaaa', '2022-04-21 23:57:19', 0),
(7785, 7, 'sss', 'A/Az aw4fztr hírt törölték. Ennek oka: Próba hír törlése', 'aaaa', '2022-04-21 23:57:30', 0),
(7786, 7, 'sss', 'A/Az A legelső hír 2 hírt törölték. Ennek oka: Próba hír törlése', 'aaaa', '2022-04-21 23:57:33', 0),
(7787, 7, 'sss', 'A/Az Message important hírt törölték. Ennek oka: Próba hír törlése', 'aaaa', '2022-04-21 23:57:36', 0),
(7788, 7, 'sss', 'A/Az A legelső hír 2 hírt törölték. Ennek oka: nincs mar szukseg ra', 'aaaa', '2022-04-22 00:18:14', 0),
(7789, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-22 00:32:23', 1),
(7790, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-22 09:13:11', 1),
(7791, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-22 12:00:07', 1),
(7792, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-22 12:01:10', 1),
(7793, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-22 14:01:54', 1),
(7794, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-22 14:02:00', 1),
(7795, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-22 20:20:53', 1),
(7796, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-22 20:20:58', 1),
(7797, 6, 'sss', 'Beváltottál 15000 pontot 1 hónapos Prémium csomagra!', 'SYSTEM', '2022-04-22 20:34:07', 1),
(7798, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-22 21:05:19', 1),
(7799, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-22 21:05:31', 1),
(7800, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-22 21:21:32', 1),
(7801, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-22 21:21:36', 1),
(7802, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 08:36:01', 1),
(7803, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 08:36:01', 1),
(7804, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-23 08:36:11', 1),
(7805, 34, 'sss', 'Részvétel a/az ANIMÁLIA nevű kvízen.', 'SYSTEM', '2022-04-23 09:40:25', 1),
(7806, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 10:01:59', 1),
(7807, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-23 10:02:02', 1),
(7808, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 11:32:22', 1),
(7809, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-23 11:32:26', 1),
(7810, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 12:32:04', 1),
(7811, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-23 13:31:22', 1),
(7812, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 15:04:42', 1),
(7813, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-23 15:04:51', 1),
(7814, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 16:26:21', 1),
(7815, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-23 16:26:26', 1),
(7816, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 17:23:49', 1),
(7817, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-23 17:23:52', 1),
(7818, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-23 20:33:31', 1),
(7819, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-23 20:33:36', 1),
(7820, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-24 09:09:45', 1),
(7821, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 09:09:51', 1),
(7822, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-24 10:34:01', 1),
(7823, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 10:34:05', 1),
(7824, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-24 13:09:33', 1),
(7825, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 13:09:56', 1),
(7826, 1, 'llll', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-24 13:17:55', 1),
(7827, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 13:18:01', 1),
(7828, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-24 13:19:50', 1),
(7829, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 13:19:54', 1),
(7830, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-24 14:38:02', 1),
(7831, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 14:38:07', 1),
(7832, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-24 16:03:14', 1),
(7833, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 16:03:18', 1),
(7834, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-24 18:02:07', 1),
(7835, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 18:02:11', 1),
(7836, 8, 'sss', 'Pontváltozás történt: -150 levonás. Ok: kérésre felajánlott pontok', 'SYSTEM', '2022-04-24 18:02:56', 1),
(7837, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-24 18:05:43', 1),
(7838, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 18:05:50', 1),
(7839, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-24 21:55:07', 1),
(7840, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 21:55:13', 1),
(7841, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-24 22:32:12', 1),
(7842, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-24 22:32:19', 1),
(7843, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-24 23:20:27', 1),
(7844, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-27 12:22:36', 1),
(7845, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-27 14:34:53', 1),
(7846, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-27 14:34:57', 1),
(7847, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-27 18:25:57', 1),
(7848, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-27 18:26:01', 1),
(7849, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-27 19:55:23', 1),
(7850, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-27 19:55:27', 1),
(7851, 13, 'sss', 'A/Az Proba kviz témájú kvíz adatait sikeresen elküldted. Ennek jóváhagyásáról, és a további tennivalókról értesíteni fogunk! ', 'SYSTEM', '2022-04-27 20:05:32', 1),
(7852, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-04-27 20:06:15', 1),
(7853, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-04-27 20:07:04', 1),
(7854, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-27 21:58:00', 1),
(7855, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-27 21:58:15', 1),
(7856, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-27 22:30:22', 1),
(7857, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-27 22:30:26', 1),
(7858, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-28 00:37:35', 1),
(7859, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 00:37:42', 1),
(7860, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-28 00:41:27', 1),
(7861, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 00:41:32', 1),
(7862, 1, 'llll', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 09:13:05', 1),
(7863, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 09:13:12', 1),
(7864, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 10:18:45', 1),
(7865, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 10:18:50', 1),
(7866, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-04-28 12:02:44', 1),
(7867, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 12:18:26', 1),
(7868, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 12:18:30', 1),
(7869, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 12:35:19', 1),
(7870, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 12:35:23', 1),
(7871, 18, 'sss', 'A/Az PPP oba kviz témájú kérésedet sikeresen rögzítettük. Ennek jóváhagyásáról értesíteni fogunk! ', 'SYSTEM', '2022-04-28 12:35:28', 1),
(7872, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-04-28 12:35:42', 1),
(7873, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-04-28 12:35:47', 1),
(7874, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 12:47:25', 1),
(7875, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-28 12:47:49', 1),
(7876, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 14:36:05', 1),
(7877, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 14:36:09', 1),
(7878, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-28 15:06:52', 1),
(7879, 1, 'Norberto99', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 15:06:59', 1),
(7880, 1, 'Norberto99', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-28 15:07:03', 1),
(7881, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 15:07:07', 1),
(7882, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-28 15:10:17', 1),
(7883, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 15:10:20', 1),
(7884, 9, 'sss', 'Új kérdés: Mennyi 1+1?', 'SYSTEM', '2022-04-28 16:20:51', 1),
(7885, 9, 'sss', 'Új kérdés: Mennyi 1+1?', 'SYSTEM', '2022-04-28 16:21:22', 1),
(7886, 36, 'sss', 'Az általad beküldött kérdés: Mennyi 1+1? már szerepel a játékban!', 'SYSTEM', '2022-04-28 16:21:37', 1),
(7887, 36, 'sss', 'Az általad beküldött kérdés: Mennyi 1+1? már szerepel a játékban!', 'SYSTEM', '2022-04-28 16:23:50', 1),
(7888, 36, 'sss', 'Az általad beküldött kérdés: Mennyi 1+1? már szerepel a játékban!', 'SYSTEM', '2022-04-28 16:26:50', 1),
(7889, 9, 'sss', 'Új kérdés: Ki az?', 'SYSTEM', '2022-04-28 17:10:02', 1),
(7890, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 18:39:48', 1),
(7891, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 18:39:53', 1),
(7892, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-28 18:53:11', 1),
(7893, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 18:53:16', 1),
(7894, 1, 'llll', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-28 19:05:11', 1),
(7895, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 19:05:16', 1),
(7896, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 19:44:14', 1),
(7897, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 19:44:18', 1),
(7898, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 21:09:59', 1),
(7899, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 21:10:03', 1),
(7900, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 21:49:41', 1),
(7901, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 21:49:50', 1),
(7902, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-28 22:41:15', 1),
(7903, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-28 22:41:20', 1),
(7904, 35, 'sss', 'A/Az 7727 - azonosítójú kérdés javítva!', 'SYSTEM', '2022-04-28 23:57:57', 1),
(7905, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-04-28 23:58:46', 1),
(7906, 11, 'sss', 'Kérdés visszaküldve! - A 7727 - azonosítójú kérdést visszaküldték javításra. Ok:  A kérdés túl bonyolult/nem egyértelmű a megfogalmazás.!', 'sss', '2022-04-28 23:59:56', 1),
(7907, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-04-29 00:00:17', 1),
(7908, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-29 00:41:38', 1),
(7909, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-29 00:41:42', 1),
(7910, 35, 'sss', 'A/Az 7727 - azonosítójú kérdés javítva!', 'SYSTEM', '2022-04-29 01:52:37', 1),
(7911, 35, 'sss', 'A/Az 7728 - azonosítójú kérdés javítva!', 'SYSTEM', '2022-04-29 02:17:15', 1),
(7912, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-29 09:37:21', 1),
(7913, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-29 09:37:27', 1),
(7914, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-29 09:37:40', 1),
(7915, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-29 09:37:48', 1),
(7916, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-04-29 09:40:03', 1),
(7917, 11, 'sss', 'Kérdés visszaküldve! - A 7179 - azonosítójú kérdést visszaküldték javításra. Ok: Nem megfelelő formátum! Helytelen információ!!', 'sss', '2022-04-29 09:41:58', 1),
(7918, 35, 'sss', 'A/Az 7179 - azonosítójú kérdés javítva!', 'SYSTEM', '2022-04-29 09:43:29', 1),
(7919, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-29 10:15:45', 1),
(7920, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-29 10:15:50', 1),
(7921, 1, 'llll', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-29 10:16:46', 1),
(7922, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-29 10:16:51', 1),
(7923, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-29 10:41:03', 1),
(7924, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-29 10:41:08', 1),
(7925, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-29 12:03:53', 1),
(7926, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-29 12:03:57', 1),
(7927, 35, 'aaaa', 'A/Az 1727 - azonosítójú kérdés javítva!', 'SYSTEM', '2022-04-29 12:04:40', 1),
(7928, 9, 'aaaa', 'Új kérdés: Ki az azzzz?', 'SYSTEM', '2022-04-29 12:20:18', 1),
(7929, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-04-29 12:20:37', 1),
(7930, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-04-29 12:20:41', 1),
(7931, 9, 'aaaa', 'Új kérdés: \'6+6\' mennyi?', 'SYSTEM', '2022-04-29 12:25:09', 1),
(7932, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-04-29 12:29:47', 1),
(7933, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-29 12:29:51', 1),
(7934, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-04-29 12:57:54', 1),
(7935, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-30 17:18:17', 1),
(7936, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-30 17:18:28', 1),
(7937, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-30 19:06:31', 1),
(7938, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-30 19:06:36', 1),
(7939, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-04-30 19:35:04', 1),
(7940, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-04-30 19:35:08', 1),
(7941, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 09:59:52', 1),
(7942, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 09:59:57', 1),
(7943, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 12:18:00', 1),
(7944, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 12:18:04', 1),
(7945, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 12:59:38', 1),
(7946, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 12:59:47', 1),
(7947, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-01 13:03:14', 1),
(7948, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 13:03:19', 1),
(7949, 1, 'llll', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-01 13:20:13', 1),
(7950, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 13:20:17', 1),
(7951, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-01 13:20:29', 1),
(7952, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 13:20:36', 1),
(7953, 1, 'llll', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 14:34:53', 1),
(7954, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 14:34:58', 1),
(7955, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-01 14:49:05', 1),
(7956, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 14:49:10', 1),
(7957, 26, 'llll', 'A felhasználó értékelte a/az ANIMÁLIA kvízt.', 'SYSTEM', '2022-05-01 14:49:47', 1),
(7958, 1, 'llll', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 15:12:36', 1),
(7959, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 15:12:51', 1),
(7960, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 15:47:07', 1),
(7961, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 15:47:12', 1),
(7962, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-01 15:50:30', 1),
(7963, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 15:50:34', 1),
(7964, 26, 'llll', 'A felhasználó értékelte a/az BIOLÓGIA + KÉMIA kvízt.', 'SYSTEM', '2022-05-01 15:56:51', 1),
(7965, 1, 'llll', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 19:49:31', 1),
(7966, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 19:49:39', 1),
(7967, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 20:53:09', 1),
(7968, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 20:53:14', 1),
(7969, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-01 21:06:02', 1),
(7970, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 21:06:07', 1),
(7971, 26, 'iiii', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 21:40:01', 1),
(7972, 26, 'iiii', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 21:43:44', 1),
(7973, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-01 21:46:44', 1),
(7974, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 21:46:50', 1),
(7975, 26, 'aaaa', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 21:51:31', 1),
(7976, 26, 'aaaa', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 21:53:34', 1),
(7977, 26, 'aaaa', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 21:54:49', 1),
(7978, 26, 'aaaa', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 21:57:09', 1),
(7979, 26, 'aaaa', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 21:58:24', 1),
(7980, 26, 'aaaa', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 22:01:09', 1),
(7981, 26, 'aaaa', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 22:02:45', 1),
(7982, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-01 22:46:37', 1),
(7983, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 22:46:42', 1),
(7984, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-01 22:48:20', 1),
(7985, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-01 22:48:28', 1),
(7986, 26, 'aaaa', 'A felhasználó kedvelte a/az BIOLÓGIA + KÉMIA kvízt', 'SYSTEM', '2022-05-01 22:49:40', 1),
(7987, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-02 09:41:12', 1),
(7988, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 09:41:20', 1),
(7989, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-02 10:05:37', 1),
(7990, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 10:05:44', 1),
(7991, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 10:05:45', 1),
(7992, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-02 10:46:08', 1),
(7993, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 10:46:12', 1),
(7994, 26, 'sss', 'A felhasználó értékelte a/az A világ országai és fővárosai kvízt.', 'SYSTEM', '2022-05-02 11:01:51', 1),
(7995, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-02 11:10:43', 1),
(7996, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 11:10:46', 1),
(7997, 26, 'aaaa', 'A felhasználó kedvelte a/az ANIMÁLIA kvízt', 'SYSTEM', '2022-05-02 11:10:51', 1),
(7998, 26, 'aaaa', 'A felhasználó értékelte a/az ANIMÁLIA kvízt.', 'SYSTEM', '2022-05-02 11:10:59', 1),
(7999, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-02 13:55:45', 1),
(8000, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 13:55:51', 1),
(8001, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-02 17:17:45', 1),
(8002, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 17:17:50', 1),
(8003, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-02 18:27:40', 1),
(8004, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 18:27:44', 1),
(8005, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-02 21:40:01', 1),
(8006, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 21:40:06', 1),
(8007, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-02 21:59:16', 1),
(8008, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 21:59:20', 1),
(8009, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-02 22:00:24', 1),
(8010, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 22:00:27', 1),
(8011, 26, 'sss', 'A felhasználó hozzászólt a/az MŰVÉSZET kvízhez.', 'SYSTEM', '2022-05-02 22:51:36', 1),
(8012, 26, 'sss', 'A felhasználó hozzászólt a/az MINDENNAPOK kvízhez.', 'SYSTEM', '2022-05-02 22:54:28', 1),
(8013, 26, 'sss', 'A felhasználó hozzászólt a/az MINDENNAPOK kvízhez.', 'SYSTEM', '2022-05-02 23:05:42', 1),
(8014, 26, 'sss', 'A felhasználó hozzászólt a/az MINDENNAPOK kvízhez.', 'SYSTEM', '2022-05-02 23:07:07', 1),
(8015, 26, 'sss', 'A felhasználó hozzászólt a/az MINDENNAPOK kvízhez.', 'SYSTEM', '2022-05-02 23:07:50', 1),
(8016, 26, 'sss', 'A felhasználó hozzászólt a/az MINDENNAPOK kvízhez.', 'SYSTEM', '2022-05-02 23:08:25', 1),
(8017, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-02 23:25:24', 1),
(8018, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-02 23:25:28', 1),
(8019, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-03 22:30:01', 1),
(8020, 1, 'Norberto99', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-03 22:30:13', 1),
(8021, 1, 'Norberto99', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-03 22:30:54', 1),
(8022, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-03 22:30:59', 1),
(8023, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-03 22:31:49', 1),
(8024, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-03 22:31:54', 1),
(8025, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-03 22:43:51', 1),
(8026, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-03 22:54:16', 1),
(8027, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-03 22:54:22', 1),
(8028, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-03 22:55:39', 1),
(8029, 1, 'Norberto99', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-03 22:55:51', 1),
(8030, 1, 'Norberto99', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-03 23:16:30', 1),
(8031, 1, 'llll', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-03 23:16:35', 1),
(8032, 1, 'llll', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-03 23:16:54', 1),
(8033, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-03 23:17:07', 1),
(8034, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-05-03 23:17:44', 1),
(8035, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-03 23:17:49', 1),
(8036, 26, 'EzEgyHosszuNevv', 'A felhasználó értékelte a/az KARÁCSONY kvízt.', 'SYSTEM', '2022-05-03 23:30:20', 1),
(8037, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-03 23:30:43', 1),
(8038, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-03 23:30:47', 1),
(8039, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-05-03 23:36:13', 1),
(8040, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-04 09:25:18', 1),
(8041, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 09:25:31', 1),
(8042, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-04 10:33:01', 1),
(8043, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 10:33:04', 1),
(8044, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-04 10:41:31', 1),
(8045, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 10:41:34', 1),
(8046, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-04 11:31:40', 1),
(8047, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 11:31:44', 1),
(8049, 27, 'aaaa', 'A/Az Torrentezési alapismeretek témájú kvíz adatai módosultak. ', 'SYSTEM', '2022-05-04 12:50:38', 1),
(8050, 27, 'aaaa', 'A/Az Torrentezési alapismeretek témájú kvíz adatai módosultak. ', 'SYSTEM', '2022-05-04 12:53:49', 1),
(8051, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-04 12:57:36', 1),
(8052, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 12:57:40', 1),
(8053, 27, 'sss', 'A/Az ANIMÁLIA témájú kvíz adatai módosultak. ', 'SYSTEM', '2022-05-04 12:58:59', 0),
(8055, 27, 'sss', 'A/Az ANIMÁLIA témájú kvíz adatai módosultak. ', 'SYSTEM', '2022-05-04 12:59:38', 1),
(8056, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-04 14:09:38', 1),
(8057, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 14:09:42', 1),
(8058, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-04 14:21:19', 1),
(8059, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 14:21:52', 1),
(8060, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-04 16:02:20', 1),
(8061, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 16:02:24', 1),
(8062, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-04 16:29:29', 1),
(8063, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 16:29:33', 1),
(8064, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-04 17:41:29', 1),
(8065, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-04 17:41:34', 1),
(8066, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-04 22:37:01', 1),
(8067, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-05 11:52:40', 1),
(8068, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-05 13:39:08', 1),
(8069, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-05 13:39:13', 1),
(8070, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-05 16:10:39', 1),
(8071, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-05 16:10:45', 1),
(8072, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-05 17:05:23', 1),
(8073, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-05 17:05:26', 1),
(8074, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-05 18:27:39', 1),
(8075, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-05 18:27:43', 1),
(8076, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-05 21:08:43', 1),
(8077, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-05 21:08:47', 1),
(8078, 29, 'sss', 'Jelölésedet elküldtük a/az qqqq nevű felhasználónak!', 'SYSTEM', '2022-05-05 21:42:30', 1),
(8079, 29, 'qqqq', 'Barátnak jelöltek, a/az sss nevű felhasználó!', 'SYSTEM', '2022-05-05 21:42:30', 0),
(8080, 29, 'sss', 'Jelölésedet elküldtük a/az blanka nevű felhasználónak!', 'SYSTEM', '2022-05-05 21:42:48', 1),
(8081, 29, 'blanka', 'Barátnak jelöltek, a/az sss nevű felhasználó!', 'SYSTEM', '2022-05-05 21:42:48', 0),
(8082, 29, 'sss', 'Jelölésedet elküldtük a/az kitudja nevű felhasználónak!', 'SYSTEM', '2022-05-05 21:46:00', 1),
(8083, 29, 'kitudja', 'Barátnak jelöltek, a/az sss nevű felhasználó!', 'SYSTEM', '2022-05-05 21:46:00', 0),
(8084, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-06 18:13:40', 1),
(8085, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-06 18:13:46', 1),
(8086, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-06 21:35:07', 1),
(8087, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-06 21:35:57', 1),
(8088, 29, 'sss', 'Jelölésedet elküldtük a/az EzEgyHosszuNevv nevű felhasználónak!', 'SYSTEM', '2022-05-06 22:38:52', 1),
(8089, 29, 'EzEgyHosszuNevv', 'Barátnak jelöltek, a/az sss nevű felhasználó!', 'SYSTEM', '2022-05-06 22:38:52', 1),
(8090, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-06 22:39:03', 1),
(8091, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-06 22:39:08', 1),
(8092, 29, 'sss', 'Visszaigazoltak barátnak: a/az EzEgyHosszuNevv nevű felhasználó!', 'SYSTEM', '2022-05-06 22:39:15', 1),
(8093, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-06 22:39:24', 1),
(8094, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-06 22:39:27', 1),
(8095, 29, 'sss', 'Jelölésedet elküldtük a/az aaaa nevű felhasználónak!', 'SYSTEM', '2022-05-06 22:46:12', 1),
(8096, 29, 'aaaa', 'Barátnak jelöltek, a/az sss nevű felhasználó!', 'SYSTEM', '2022-05-06 22:46:12', 1),
(8097, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-06 22:46:16', 1),
(8098, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-06 22:46:20', 1),
(8099, 29, 'sss', 'Visszaigazoltak barátnak: a/az aaaa nevű felhasználó!', 'SYSTEM', '2022-05-06 23:01:51', 1),
(8100, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-06 23:02:01', 1),
(8101, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-06 23:02:05', 1),
(8102, 8, 'sss', 'Vásároltál 1 segítséget 4 pontért!', 'SYSTEM', '2022-05-06 23:37:29', 1),
(8103, 8, 'sss', 'Vásároltál 77 segítséget 308 pontért!', 'SYSTEM', '2022-05-06 23:50:20', 1),
(8104, 8, 'sss', 'Vásároltál 1 segítséget 4 pontért!', 'SYSTEM', '2022-05-06 23:51:58', 1),
(8105, 8, 'sss', 'Vásároltál 1 segítséget 4 pontért!', 'SYSTEM', '2022-05-06 23:56:05', 1),
(8106, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-07 01:54:17', 1),
(8107, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-07 10:58:55', 1),
(8108, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-07 11:51:24', 1),
(8109, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-07 11:51:29', 1),
(8110, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-07 12:23:18', 1),
(8111, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-07 12:23:21', 1),
(8112, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-07 12:27:53', 1),
(8113, 10, 'sss', 'A 7386 - azonosítójú beküldött kérdésedet elfogadtuk. Jutalmad: 15 pont!', 'sss', '2022-05-07 12:29:18', 1),
(8114, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-05-07 12:29:28', 1),
(8115, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-07 15:39:41', 1),
(8116, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-07 15:39:47', 1),
(8117, 8, 'sss', 'Vásároltál 1 segítséget 4 pontért!', 'SYSTEM', '2022-05-07 15:40:02', 1),
(8118, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-07 22:27:33', 1),
(8119, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 14:01:50', 1),
(8120, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-14 14:31:43', 1),
(8121, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 14:31:47', 1),
(8122, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-14 14:39:03', 1),
(8123, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 14:39:08', 1),
(8124, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-14 17:08:57', 1),
(8125, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 17:09:00', 1),
(8126, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-14 17:17:34', 1),
(8127, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 17:17:40', 1),
(8128, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-14 17:18:51', 1),
(8129, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 17:18:55', 1),
(8130, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-14 19:41:05', 1),
(8131, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 19:41:08', 1),
(8132, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-14 20:08:16', 1),
(8133, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 20:08:26', 1),
(8134, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-14 20:10:03', 1),
(8135, 3, 'iiii', 'WARN-t kaptál, ezért bizonyos funkciók meg lettek tőled vonva! A figyelmeztetés oka: Proba, amelynek időtartama 3 nap. A warn miatt 1000 pontot vontunk le tőled!', 'sss', '2022-05-14 20:10:37', 1),
(8136, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-14 20:11:40', 1),
(8137, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-05-14 20:11:47', 1),
(8138, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-14 20:12:01', 1),
(8139, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-16 09:17:16', 1),
(8140, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 09:17:23', 1),
(8141, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 10:17:43', 1),
(8142, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 10:17:48', 1),
(8143, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 10:58:32', 1),
(8144, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 10:58:36', 1),
(8145, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-16 11:26:02', 1),
(8146, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:26:06', 1),
(8147, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:26:35', 1),
(8148, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:26:39', 1),
(8149, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:27:03', 1);
INSERT INTO `log_data` (`id`, `log_type`, `username`, `log_message`, `admin_name`, `log_date`, `is_seen`) VALUES
(8150, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:27:07', 1),
(8151, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:44:44', 1),
(8152, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:44:50', 1),
(8153, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:45:40', 1),
(8154, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:45:51', 1),
(8155, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:49:12', 1),
(8156, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:49:16', 1),
(8157, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:49:55', 1),
(8158, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:49:59', 1),
(8159, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:51:28', 1),
(8160, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:51:35', 1),
(8161, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:52:00', 1),
(8162, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:52:04', 1),
(8163, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 11:57:57', 1),
(8164, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 11:58:00', 1),
(8165, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-16 12:50:19', 1),
(8166, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 12:50:23', 1),
(8167, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 12:53:37', 1),
(8168, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 12:53:42', 1),
(8169, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 12:56:37', 1),
(8170, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 12:56:41', 1),
(8171, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 12:59:12', 1),
(8172, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 12:59:19', 1),
(8173, 1, 'iiii', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-16 13:53:21', 1),
(8174, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 13:53:26', 1),
(8175, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 13:57:00', 1),
(8176, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 13:57:04', 1),
(8177, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 13:57:44', 1),
(8178, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 13:57:50', 1),
(8179, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 13:58:51', 1),
(8180, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 13:58:57', 1),
(8181, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 14:00:12', 1),
(8182, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 14:00:17', 1),
(8183, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 14:00:56', 1),
(8184, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 14:01:03', 1),
(8185, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 14:22:41', 1),
(8186, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 14:22:45', 1),
(8187, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 14:24:59', 1),
(8188, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 14:25:03', 1),
(8189, 8, 'sss', 'A profilod rejtettségét ingyen beállítottad a prémium tagságod idejéig!', 'SYSTEM', '2022-05-16 14:25:28', 1),
(8190, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 14:28:18', 1),
(8191, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 14:28:22', 1),
(8192, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 14:56:56', 1),
(8193, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 14:57:02', 1),
(8194, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 14:59:50', 1),
(8195, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 14:59:54', 1),
(8196, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 15:00:08', 1),
(8197, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 15:00:11', 1),
(8198, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 15:00:39', 1),
(8199, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 15:00:42', 1),
(8200, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 15:04:41', 1),
(8201, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 15:04:48', 1),
(8202, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 15:04:56', 1),
(8203, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 15:04:58', 1),
(8204, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 15:07:28', 1),
(8205, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 15:07:32', 1),
(8206, 29, 'aaaa', 'Jelölésedet elküldtük a/az Mess98 nevű felhasználónak!', 'SYSTEM', '2022-05-16 15:42:48', 1),
(8207, 29, 'Mess98', 'Barátnak jelöltek, a/az aaaa nevű felhasználó!', 'SYSTEM', '2022-05-16 15:42:48', 0),
(8208, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 16:07:25', 1),
(8209, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 16:07:28', 1),
(8210, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 16:36:57', 1),
(8211, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 16:37:02', 1),
(8212, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 16:37:18', 1),
(8213, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 16:37:23', 1),
(8214, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 16:44:40', 1),
(8215, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 16:44:45', 1),
(8216, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 16:48:16', 1),
(8217, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 16:48:20', 1),
(8218, 8, 'EzEgyHosszuNevv', 'Vásároltál 2 segítséget 48 pontért!', 'SYSTEM', '2022-05-16 16:53:44', 1),
(8219, 8, 'EzEgyHosszuNevv', 'Vásároltál 1 segítséget 24 pontért!', 'SYSTEM', '2022-05-16 16:54:33', 0),
(8220, 1, 'EzEgyHosszuNevv', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-16 18:32:19', 1),
(8221, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 18:32:27', 1),
(8222, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 19:01:11', 1),
(8223, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 19:01:14', 1),
(8224, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 19:44:35', 1),
(8225, 1, 'Norberto99', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 19:44:40', 1),
(8226, 6, 'Norberto99', 'Az általad kapott PREMIUM ideje lejárt!', 'SYSTEM', '2022-05-16 19:44:40', 0),
(8227, 1, 'Norberto99', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 19:44:55', 1),
(8228, 1, 'jjjj', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 19:45:00', 1),
(8229, 1, 'jjjj', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-16 21:54:21', 1),
(8230, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 21:54:25', 1),
(8231, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-16 22:00:25', 1),
(8232, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 22:00:29', 1),
(8233, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-16 23:09:52', 1),
(8234, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-16 23:11:34', 1),
(8235, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 09:55:41', 1),
(8236, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 09:55:51', 1),
(8237, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 10:11:22', 1),
(8238, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 10:11:32', 1),
(8239, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 11:16:10', 1),
(8240, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 11:16:16', 1),
(8241, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 11:21:48', 1),
(8242, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 11:21:52', 1),
(8243, 27, 'sss', 'A/Az MATEMATIKA + FIZIKA témájú kvíz adatai módosultak. ', 'SYSTEM', '2022-05-17 11:22:25', 0),
(8244, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 11:22:47', 1),
(8245, 1, 'Norberto99', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 11:22:56', 1),
(8246, 1, 'Norberto99', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 11:22:57', 1),
(8247, 1, 'Norberto99', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 11:23:16', 1),
(8248, 1, 'EzEgyHosszuNevv', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 11:23:21', 1),
(8249, 1, 'EzEgyHosszuNevv', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 11:25:56', 1),
(8250, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 11:25:59', 1),
(8251, 27, 'sss', 'A/Az MATEMATIKA + FIZIKA témájú kvíz adatai módosultak. ', 'SYSTEM', '2022-05-17 11:26:23', 0),
(8252, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 12:07:49', 1),
(8253, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 12:08:06', 1),
(8254, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 12:29:52', 1),
(8255, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 12:29:55', 1),
(8256, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 12:49:34', 1),
(8257, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 12:50:51', 1),
(8258, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 13:52:09', 1),
(8259, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 13:52:13', 1),
(8260, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 13:53:02', 1),
(8261, 1, 'iiii', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 13:53:06', 1),
(8262, 1, 'iiii', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 14:06:49', 1),
(8263, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 14:06:52', 1),
(8264, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 14:36:29', 1),
(8265, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 14:36:32', 1),
(8266, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 15:41:10', 1),
(8267, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 15:41:15', 1),
(8268, 8, 'sss', 'Pontváltozás történt: -100 levonás. Ok: kérésre felajánlott pontok', 'SYSTEM', '2022-05-17 16:47:08', 1),
(8269, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 19:02:13', 1),
(8270, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 19:02:17', 1),
(8271, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 19:28:08', 1),
(8272, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 19:28:12', 1),
(8273, 29, 'sss', 'Jelölésedet elküldtük a/az paraZita0 nevű felhasználónak!', 'SYSTEM', '2022-05-17 19:38:44', 1),
(8274, 29, 'paraZita0', 'Barátnak jelöltek, a/az sss nevű felhasználó!', 'SYSTEM', '2022-05-17 19:38:44', 1),
(8275, 1, 'paraZita0', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 19:39:02', 1),
(8276, 1, 'paraZita0', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 19:54:56', 1),
(8277, 1, 'paraZita0', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 20:07:12', 1),
(8278, 1, 'paraZita0', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 20:15:53', 1),
(8279, 1, 'jjjj', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 20:16:04', 1),
(8280, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-17 20:17:34', 1),
(8281, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 20:17:38', 1),
(8282, 29, 'jjjj', 'Jelölésedet elküldtük a/az aaaa nevű felhasználónak!', 'SYSTEM', '2022-05-17 20:29:40', 0),
(8283, 29, 'aaaa', 'Barátnak jelöltek, a/az jjjj nevű felhasználó!', 'SYSTEM', '2022-05-17 20:29:40', 1),
(8284, 29, 'jjjj', 'Visszaigazoltak barátnak: a/az aaaa nevű felhasználó!', 'SYSTEM', '2022-05-17 20:29:49', 0),
(8285, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-17 22:07:35', 1),
(8286, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-17 22:07:40', 1),
(8287, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-18 08:44:09', 1),
(8288, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-18 08:44:22', 1),
(8289, 1, 'jjjj', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-18 09:08:21', 1),
(8290, 1, 'jjjj', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-18 09:12:56', 1),
(8291, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-18 09:13:01', 1),
(8292, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-18 09:13:11', 1),
(8293, 1, 'jjjj', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-18 09:13:15', 1),
(8294, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-18 09:14:01', 1),
(8295, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-18 09:14:19', 1),
(8296, 29, 'aaaa', 'Jelölésedet elküldtük a/az jjjj nevű felhasználónak!', 'SYSTEM', '2022-05-18 09:14:58', 1),
(8297, 29, 'jjjj', 'Barátnak jelöltek, a/az aaaa nevű felhasználó!', 'SYSTEM', '2022-05-18 09:14:58', 0),
(8298, 29, 'aaaa', 'Jelölésedet elküldtük a/az jjjj nevű felhasználónak!', 'SYSTEM', '2022-05-18 09:17:06', 1),
(8299, 29, 'jjjj', 'Barátnak jelöltek, a/az aaaa nevű felhasználó!', 'SYSTEM', '2022-05-18 09:17:06', 0),
(8300, 29, 'jjjj', 'Jelölésedet elküldtük a/az aaaa nevű felhasználónak!', 'SYSTEM', '2022-05-18 09:17:47', 0),
(8301, 29, 'aaaa', 'Barátnak jelöltek, a/az jjjj nevű felhasználó!', 'SYSTEM', '2022-05-18 09:17:47', 1),
(8302, 29, 'jjjj', 'Visszaigazoltak barátnak: a/az aaaa nevű felhasználó!', 'SYSTEM', '2022-05-18 09:18:04', 0),
(8303, 1, 'jjjj', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-18 09:18:48', 1),
(8304, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-18 11:14:09', 1),
(8305, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-18 11:14:13', 1),
(8306, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-18 20:23:13', 1),
(8307, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-18 20:23:21', 1),
(8308, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-18 21:45:51', 1),
(8309, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 15:09:41', 1),
(8310, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-19 15:58:30', 1),
(8311, 2, 'Edit24', 'Sikeres regisztráció történt.', 'SYSTEM', '2022-05-19 16:25:49', 1),
(8312, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 16:26:06', 1),
(8313, 1, 'Edit24', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 16:27:24', 1),
(8314, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 16:27:52', 1),
(8315, 8, 'Edit24', 'A jelszavadat sikeresen megváltoztattad.', 'SYSTEM', '2022-05-19 16:28:43', 1),
(8316, 1, 'Edit24', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 16:28:50', 1),
(8317, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 16:29:17', 1),
(8318, 8, 'Edit24', 'A jelszavadat sikeresen megváltoztattad.', 'SYSTEM', '2022-05-19 16:30:16', 1),
(8319, 1, 'Edit24', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 16:30:19', 1),
(8320, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 16:30:31', 1),
(8321, 1, 'Edit24', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 16:30:35', 1),
(8322, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-19 16:31:42', 1),
(8323, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-05-19 16:32:41', 1),
(8324, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 16:33:21', 1),
(8325, 8, 'Edit24', 'A jelszavadat sikeresen megváltoztattad.', 'SYSTEM', '2022-05-19 16:34:42', 1),
(8326, 30, 'Edit24', 'Ezt a fiókot a felhasználó törölte. Indok: (saját fiók törlése)', 'SYSTEM', '2022-05-19 16:34:58', 0),
(8327, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-19 16:35:43', 1),
(8328, 31, 'Edit24', 'Ezt a fiókot egy Admin visszaállította a következő indokkal: Csak ugy', 'sss', '2022-05-19 16:36:02', 0),
(8329, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 16:36:27', 1),
(8330, 8, 'Edit24', 'A jelszavadat sikeresen megváltoztattad.', 'SYSTEM', '2022-05-19 16:36:50', 1),
(8331, 1, 'Edit24', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 16:36:56', 1),
(8332, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-05-19 16:37:03', 1),
(8333, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 18:03:16', 1),
(8334, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 18:25:02', 1),
(8335, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 18:25:06', 1),
(8336, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 18:25:38', 1),
(8337, 1, 'jjjj', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 18:25:46', 1),
(8338, 1, 'jjjj', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 18:26:21', 1),
(8339, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 18:26:25', 1),
(8340, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 18:27:21', 1),
(8341, 1, 'jjjj', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 18:27:26', 1),
(8342, 1, 'jjjj', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 18:27:34', 1),
(8343, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 18:27:48', 1),
(8344, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-19 21:28:15', 1),
(8345, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 21:28:19', 1),
(8346, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-19 22:22:00', 1),
(8347, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 22:22:46', 1),
(8348, 29, 'sss', 'Jelölésedet elküldtük a/az Edit24 nevű felhasználónak!', 'SYSTEM', '2022-05-19 23:07:38', 1),
(8349, 29, 'Edit24', 'Barátnak jelöltek, a/az sss nevű felhasználó!', 'SYSTEM', '2022-05-19 23:07:38', 1),
(8350, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 23:07:43', 1),
(8351, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 23:07:48', 1),
(8352, 29, 'sss', 'Visszaigazoltak barátnak: a/az Edit24 nevű felhasználó!', 'SYSTEM', '2022-05-19 23:08:04', 1),
(8353, 1, 'Edit24', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 23:08:42', 1),
(8354, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 23:08:46', 1),
(8355, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 23:09:18', 1),
(8356, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 23:09:23', 1),
(8357, 29, 'Edit24', 'Jelölésedet elküldtük a/az aaaa nevű felhasználónak!', 'SYSTEM', '2022-05-19 23:10:18', 0),
(8358, 29, 'aaaa', 'Barátnak jelöltek, a/az Edit24 nevű felhasználó!', 'SYSTEM', '2022-05-19 23:10:18', 1),
(8359, 1, 'Edit24', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 23:10:27', 1),
(8360, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 23:10:31', 1),
(8361, 29, 'Edit24', 'Visszaigazoltak barátnak: a/az aaaa nevű felhasználó!', 'SYSTEM', '2022-05-19 23:10:42', 0),
(8362, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 23:10:58', 1),
(8363, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 23:11:03', 1),
(8364, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-19 23:12:03', 1),
(8365, 1, 'Edit24', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 23:14:09', 1),
(8366, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 23:14:12', 1),
(8367, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-19 23:14:24', 1),
(8368, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 23:14:34', 1),
(8369, 1, 'Edit24', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-19 23:54:48', 1),
(8370, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-19 23:54:53', 1),
(8371, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-20 00:05:34', 1),
(8372, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-20 00:05:39', 1),
(8373, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-20 01:19:45', 1),
(8374, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-21 14:35:27', 1),
(8375, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-21 15:31:18', 1),
(8376, 1, 'Edit24', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-21 15:31:22', 1),
(8377, 1, 'Edit24', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-21 17:27:51', 1),
(8378, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-21 18:45:06', 1),
(8379, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-21 19:00:09', 1),
(8380, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-21 19:00:14', 1),
(8381, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-21 19:36:02', 1),
(8382, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-05-21 19:55:50', 1),
(8383, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-05-21 19:55:53', 1),
(8384, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-05-21 20:14:26', 1),
(8385, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-21 21:00:12', 1),
(8386, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-21 21:00:16', 1),
(8387, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-21 22:17:47', 1),
(8388, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-21 22:17:51', 1),
(8389, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-21 23:40:40', 1),
(8390, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-21 23:40:45', 1),
(8391, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-22 08:40:00', 1),
(8392, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-22 08:40:24', 1),
(8393, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-22 09:23:38', 1),
(8394, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-22 09:30:13', 1),
(8395, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-22 09:42:22', 1),
(8396, 7, '94', 'Hír közzétéve a Főoldalon. A hír témája/címe: Uj hiiiir most', 'SYSTEM', '2022-05-22 10:02:12', 1),
(8397, 7, '94', 'Hír közzétéve a Főoldalon. A hír témája/címe: ÚÚÚj hiiiir', 'SYSTEM', '2022-05-22 10:08:17', 1),
(8398, 7, 'aaaa', 'A/Az ÚÚÚj hiiiir hírt törölték. Ennek oka: ot7hiyhdgrfssrdgf', 'aaaa', '2022-05-22 10:23:51', 0),
(8399, 7, '94', 'Hír közzétéve a Főoldalon. A hír témája/címe: FEifye5rgd', 'SYSTEM', '2022-05-22 10:25:13', 1),
(8400, 7, 'aaaa', 'A/Az FEifye5rgd hírt törölték. Ennek oka: 5e6gdytfg5eydtf', 'aaaa', '2022-05-22 10:26:08', 0),
(8401, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-22 10:35:14', 1),
(8402, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-22 10:35:19', 1),
(8403, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-22 22:07:33', 1),
(8404, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-22 22:09:27', 1),
(8405, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-22 22:09:41', 1),
(8406, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-27 10:21:41', 1),
(8407, 6, 'sss', 'Az általad kapott PREMIUM ideje lejárt!', 'SYSTEM', '2022-05-27 10:21:44', 1),
(8408, 5, 'sss', 'A profilod rejtettségi ideje lejárt!', 'SYSTEM', '2022-05-27 10:21:45', 1),
(8409, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-27 10:21:47', 1),
(8410, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-30 11:04:51', 1),
(8411, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-30 11:07:21', 1),
(8412, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-30 11:07:24', 1),
(8413, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-05-30 12:22:45', 1),
(8414, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-05-31 14:36:01', 1),
(8415, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-05-31 14:37:17', 1),
(8416, 2, 'user99', 'Sikeres regisztráció történt.', 'SYSTEM', '2022-06-18 16:23:19', 1),
(8417, 1, 'user99', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-18 16:23:28', 1),
(8418, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-18 16:24:45', 1),
(8419, 8, 'user99', 'Egy Admin módosításokat végzett a profilodon: új rangod: 5, engedélyezett jogok: Chat használata, Kérések használata, Kvíz készítése, Kérdések beküldése, Felhasználókereső használata, Új hír kiírása, , megvont jogok: Nincs; pontszámváltozás: 18000; ', 'sss', '2022-06-18 16:25:26', 0),
(8420, 1, 'user99', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-06-18 16:26:21', 1),
(8421, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-18 16:26:27', 1),
(8422, 7, '15', 'Hír közzétéve a Főoldalon. A hír témája/címe: Újév 2022', 'SYSTEM', '2022-06-18 16:35:11', 1),
(8423, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-06-18 16:36:55', 1),
(8424, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-18 16:36:59', 1),
(8425, 7, '94', 'Hír közzétéve a Főoldalon. A hír témája/címe: fwseyvdrxgf6uvsyetr ', 'SYSTEM', '2022-06-18 16:37:06', 1),
(8426, 7, 'aaaa', 'A/Az fwseyvdrxgf6uvsyetr  hírt törölték. Ennek oka: qwerttreqwrg', 'aaaa', '2022-06-18 16:37:13', 0),
(8427, 1, 'aaaa', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-06-18 16:37:16', 1),
(8428, 1, 'user99', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-18 16:37:26', 1),
(8429, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-06-18 16:37:42', 1),
(8430, 1, 'user99', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-06-18 17:00:38', 1),
(8431, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-18 17:00:41', 1),
(8432, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-18 17:15:27', 1),
(8433, 35, 'sss', 'A/Az 7535 - azonosítójú kérdés javítva!', 'SYSTEM', '2022-06-18 17:17:02', 1),
(8434, 11, 'sss', 'Kérdés visszaküldve! - A 7535 - azonosítójú kérdést visszaküldték javításra. Ok:  Hibás adat/Helytelen a kérdés.!', 'sss', '2022-06-18 17:17:19', 1),
(8435, 11, 'sss', 'Kérdés visszaküldve! - A 7537 - azonosítójú kérdést visszaküldték javításra. Ok:  (Túl sok) Helyesírási hiba!.!', 'sss', '2022-06-18 17:19:25', 1),
(8436, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-06-18 17:23:48', 1),
(8437, 1, 'aaaa', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-18 17:23:52', 1),
(8438, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-06-18 17:30:48', 1),
(8439, 1, 'aaaa', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-18 18:18:26', 1),
(8440, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-18 18:24:30', 1),
(8441, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-06-19 00:36:47', 1),
(8442, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-19 11:08:16', 1),
(8443, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-19 13:12:27', 1),
(8444, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 12:51:40', 1),
(8445, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-20 12:58:37', 1),
(8446, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-20 14:24:35', 1),
(8447, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 14:24:41', 1),
(8448, 7, 'aaaa', 'A/Az Felicia Mercado hírt törölték. Ennek oka: Nem kell', 'sss', '2022-06-20 14:25:33', 0),
(8449, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-20 14:56:39', 1),
(8450, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 15:01:09', 1),
(8451, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-20 15:18:16', 1),
(8452, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-20 15:18:25', 1),
(8453, 24, 'sss', 'A/Az Űűűűűűűűűűűűűűűűűűű nevű kérésed törölve lett! Ok: Nem megfelelő leírás. . A kérésre 100 pontot szántál, melyet ezennel visszaadtunk.', 'sss', '2022-06-20 15:18:59', 1),
(8454, 16, 'sss', 'Kvíz törölve! A/Az Proba kviz nevű kvízed törölve lett a következő indokkal: Nem megfelelő leírás. ', 'sss', '2022-06-20 15:20:58', 1),
(8455, 16, 'aaaa', 'Kvíz törölve! A/Az Qwerrrre6yrtdf nevű kvízed törölve lett a következő indokkal: Nem megfelelő leírás. ', 'sss', '2022-06-20 15:21:03', 0),
(8456, 16, 'sss', 'Kvíz törölve! A/Az Kicsi redfeurdth nevű kvízed törölve lett a következő indokkal: Nem megfelelő leírás. ', 'sss', '2022-06-20 15:21:07', 1),
(8457, 16, 'sss', 'Kvíz törölve! A/Az bhjglfpp nevű kvízed törölve lett a következő indokkal: Hosszú / Bonyolult kvíznév. ', 'sss', '2022-06-20 15:21:16', 1),
(8458, 16, 'sss', 'Kvíz törölve! A/Az sss3awresc52r4awefsd5q4arews nevű kvízed törölve lett a következő indokkal: Nem egyértelmű kvíznév, vagy leírás. ', 'sss', '2022-06-20 15:21:20', 1),
(8459, 16, 'sss', 'Kvíz törölve! A/Az hallo gygrfzdxc nevű kvízed törölve lett a következő indokkal: Nem megfelelő leírás. ', 'sss', '2022-06-20 15:21:24', 1),
(8460, 16, 'sss', 'Kvíz törölve! A/Az ssis nevű kvízed törölve lett a következő indokkal: Duplikált kvíz. Nem egyértelmű kvíznév, vagy leírás. ', 'sss', '2022-06-20 15:21:29', 1),
(8461, 16, 'sss', 'Kvíz törölve! A/Az sssq nevű kvízed törölve lett a következő indokkal: Nem megfelelő leírás. ', 'sss', '2022-06-20 15:21:33', 1),
(8462, 16, 'sss', 'Kvíz törölve! A/Az erfgrefdrwfsd nevű kvízed törölve lett a következő indokkal: Hosszú / Bonyolult kvíznév. ', 'sss', '2022-06-20 15:21:40', 1),
(8463, 16, 'aaaa', 'Kvíz törölve! A/Az 3etrthfg 6wyrhtgűúőáé.,.-óü98ö7 nevű kvízed törölve lett a következő indokkal: Hosszú / Bonyolult kvíznév. ', 'sss', '2022-06-20 15:22:01', 0),
(8464, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-06-20 15:32:00', 1),
(8465, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 15:32:09', 1),
(8466, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-20 18:15:24', 1),
(8467, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 18:17:23', 1),
(8468, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-20 18:35:23', 1),
(8469, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 18:35:39', 1),
(8470, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-20 19:02:44', 1),
(8471, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 19:02:49', 1),
(8472, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-20 19:07:33', 1),
(8473, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-20 19:36:22', 1),
(8474, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 19:36:26', 1),
(8475, 27, 'sss', 'A/Az ANIMÁLIA témájú kvíz adatai módosultak. ', 'SYSTEM', '2022-06-20 19:36:57', 0),
(8476, 1, 'sss', 'Automatikus kijelentkeztetés inaktivitás / időtúllépés miatt. ', 'SYSTEM', '2022-06-20 22:36:09', 1),
(8477, 2, 'ffff', 'Sikeres regisztráció történt.', 'SYSTEM', '2022-06-20 22:36:39', 1),
(8478, 1, 'ffff', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 22:36:46', 1),
(8479, 26, 'ffff', 'A felhasználó értékelte a/az A világ országai és fővárosai kvízt.', 'SYSTEM', '2022-06-20 22:38:02', 1),
(8480, 26, 'ffff', 'A felhasználó kedvelte a/az A világ országai és fővárosai kvízt', 'SYSTEM', '2022-06-20 22:38:08', 1),
(8481, 26, 'ffff', 'A felhasználó értékelte a/az Szorzás és osztás kvízt.', 'SYSTEM', '2022-06-20 22:38:27', 1),
(8482, 26, 'ffff', 'A felhasználó kedvelte a/az Szorzás és osztás kvízt', 'SYSTEM', '2022-06-20 22:38:30', 1),
(8483, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-20 22:48:37', 1),
(8484, 8, 'ffff', 'Egy Admin módosításokat végzett a profilodon: az aktuális rangodhoz tartozó jogok lettek újra aktívak; pontszámváltozás: 150; ', 'sss', '2022-06-20 22:49:19', 1),
(8485, 18, 'ffff', 'A/Az vwtesgrdfx témájú kérésedet sikeresen rögzítettük. Ennek jóváhagyásáról értesíteni fogunk! ', 'SYSTEM', '2022-06-20 22:49:26', 1),
(8486, 11, 'sss', 'Kérdés visszaküldve! - A 7727 - azonosítójú kérdést visszaküldték javításra. Ok:  Hibás adat/Helytelen a kérdés.!', 'sss', '2022-06-20 22:51:31', 1),
(8487, 11, 'sss', 'Kérdés visszaküldve! - A 7739 - azonosítójú kérdést visszaküldték javításra. Ok:  Rossz témakörválasztás.!', 'sss', '2022-06-20 22:51:40', 1),
(8488, 1, 'ffff', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-06-20 22:52:09', 1),
(8489, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-20 22:52:14', 1),
(8490, 24, 'ffff', 'A/Az vwtesgrdfx nevű kérésed törölve lett! Ok: Nem megfelelő leírás. . A kérésre 100 pontot szántál, melyet ezennel visszaadtunk.', 'sss', '2022-06-20 22:52:42', 0),
(8491, 13, 'sss', 'A/Az Alapismeretekaaaa témájú kvíz adatait sikeresen elküldted. Ennek jóváhagyásáról, és a további tennivalókról értesíteni fogunk! ', 'SYSTEM', '2022-06-20 22:59:07', 1),
(8492, 9, 'sss', 'Új kérdés: Mennyi az eredménye a 7/7*8/8 műveletsornak?', 'SYSTEM', '2022-06-20 23:00:01', 1),
(8493, 26, 'sss', 'A felhasználó hozzászólt a/az HTML kvízhez.', 'SYSTEM', '2022-06-20 23:00:43', 1),
(8494, 37, 'aaaa', 'Meghosszabbítottuk a/az Próba kérés 1. nevű kérés teljesítésének határidejét! Az új határidő: 2021-09-17 12:25:05 .', 'sss', '2022-06-20 23:07:30', 0),
(8495, 37, 'aaaa', 'Meghosszabbítottuk a/az Próba kérés 1. nevű kérés teljesítésének határidejét! Az új határidő: 2021-09-19 12:25:05 .', 'sss', '2022-06-20 23:07:50', 0),
(8496, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-06-20 23:47:34', 1),
(8497, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-20 23:47:37', 1),
(8498, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-06-21 00:09:14', 1),
(8499, 1, 'sss', 'Bejelentkezés Adminként.', 'SYSTEM', '2022-06-21 00:15:11', 1),
(8500, 1, 'sss', 'Kijelentkezés Adminként.', 'SYSTEM', '2022-06-21 00:23:11', 1),
(8501, 1, 'sss', 'Bejelentkezés megtörtént.', 'SYSTEM', '2022-06-21 00:23:18', 1),
(8502, 1, 'sss', 'Sikeres kijelentkezés történt.', 'SYSTEM', '2022-06-21 00:23:39', 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `news`
--

CREATE TABLE `news` (
  `id` int(11) NOT NULL,
  `publisher_id` int(11) NOT NULL,
  `title` varchar(50) CHARACTER SET utf8 NOT NULL,
  `description` varchar(3000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `filename` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `image_path` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `image_size` double DEFAULT NULL,
  `file_path` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `file_size` double DEFAULT NULL,
  `publication_date` datetime NOT NULL,
  `is_deleted` int(11) NOT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  `deletion_reason` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `deletion_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- A tábla adatainak kiíratása `news`
--

INSERT INTO `news` (`id`, `publisher_id`, `title`, `description`, `filename`, `image_path`, `image_size`, `file_path`, `file_size`, `publication_date`, `is_deleted`, `deleted_by`, `deletion_reason`, `deletion_time`) VALUES
(1, 15, 'A legelső hír', 'Kedves felhasználók!\r\n\r\nÖrömmel értesítünk benneteket, hogy létrejött az oldal hírfolyama. Itt fogunk közzétenni minden fontos információt.\r\nHamarosan lehetőség lesz saját hírt kiírni a főoldalra azon felhasználóknak, akik elérték a 4. rangot.\r\n\r\nÜdv,\r\n\r\nQuizbirodalom staff', 'latex_lab01.pdf', 'k_1_20210319131625.jpg', 0.5, 'f_1_20210319131625.pdf', NULL, '2020-12-01 13:09:38', 0, NULL, NULL, NULL),
(23, 15, 'Karácsonyi kvíz', 'Kedves felhasználók!\n\nNemsokára itt a karácsony. Az ünnepekre való ráhangolódás céljából egy karácsonyi kvízt teszünk elérhetővé számotokra, amelyen bármely felhasználónk részt vehet korlátozások nélkül.\nA jutalmak ez esetben nagyobb pontmennyiségek lesznek.\nTovábbi részleteket a kvíz indulásakor olvashattok itt a Főoldalon a Kiemelt kvíz résznél.\n\nJó szórakozást!\n\nQ.Staff', NULL, 'K_merry-christmas-wallpaper-full-hd-free-download-3-min_ffd25c18b87_1616399872.jpg', 0.18, NULL, NULL, '2020-12-14 09:57:52', 0, NULL, NULL, NULL),
(24, 15, 'Újév - 2021', 'Kedves felhasználók!\n\nBoldog Új Évet Kívánunk mindenkinek!\n\nSzeretnénk közölni, hogy idén is számíthattok új kvízekre, valamint olyan kvízekre is, amelyeket ünnepek alkalmából teszünk elérhetővé számotokra. Maradjatok továbbra is velünk.\n\nÜdv,\n\nQ.Staff', NULL, 'K_2021-golden-lettering-new-year-background-with-bottle-glasses-champagne-glowing-bokeh-light_87521-235015_1616400686.jpg', 0.07, NULL, NULL, '2021-01-02 10:11:26', 0, NULL, NULL, NULL),
(39, 15, 'Halloween kvíz', 'Kedves felhasználók!\r\n\r\nKözeleg október 31.-e, amelynek estéjén a Halloween-t szoktuk ünnepelni. Az eseményre való ráhangolódás céljából idén is újra elérhetővé tesszük a halloweeni kvízt, amelyet hamarosan a Főoldalon fogtok megtalálni. \r\n\r\nA kvízen csak egyszer lehet részt venni, amely csak pár napig lesz elérhető.\r\nAddig is íme néhány hasznos link:', NULL, 'K_halloweenquiz_post15_1634911287.jpeg', 0.14, NULL, NULL, '2021-10-22 17:01:27', 0, NULL, NULL, NULL),
(50, 15, 'Újév 2022', 'Boldog Új Évet Kívánunk minden felhasználónak!\r\n\r\nIdén is számíthattok új kvízekre izgalmas témakörökben, melyekkel bővíteni szeretnénk a kvíz kínálatot számotokra!\r\nAddig is a meglévő kvízek közül válogathattok, vagy küldhettek be sajátot, valamint továbbra is használjátok az oldal többi funkcióit is!', NULL, 'K_new-years-day-gff269f4ce_192015_1655559311.jpg', 0.7, NULL, NULL, '2022-01-01 16:35:11', 0, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `permission_play_quiz`
--

CREATE TABLE `permission_play_quiz` (
  `userid` int(11) NOT NULL,
  `quizid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `permission_play_quiz`
--

INSERT INTO `permission_play_quiz` (`userid`, `quizid`) VALUES
(3, 0),
(3, 127),
(3, 129),
(3, 137),
(3, 138),
(3, 139),
(3, 140),
(3, 164),
(3, 174),
(3, 180),
(15, 154),
(15, 172),
(76, 164),
(76, 174),
(76, 178),
(87, 122),
(87, 126),
(87, 128),
(87, 136),
(87, 137),
(87, 138),
(87, 150),
(87, 154),
(87, 164),
(87, 169),
(87, 172),
(87, 174),
(94, 0),
(94, 127),
(94, 128),
(94, 129),
(94, 136),
(94, 138),
(94, 139),
(94, 164),
(96, 44),
(101, 169),
(107, 169),
(107, 172),
(108, 150),
(108, 154),
(108, 156),
(108, 157),
(112, 172),
(116, 174),
(116, 180);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `permission_submit_question`
--

CREATE TABLE `permission_submit_question` (
  `userid` int(11) NOT NULL,
  `quizid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `permission_submit_question`
--

INSERT INTO `permission_submit_question` (`userid`, `quizid`) VALUES
(3, 66),
(3, 68),
(3, 122),
(3, 128),
(3, 138),
(15, 117),
(15, 125),
(15, 154),
(15, 155),
(15, 156),
(15, 157),
(15, 169),
(15, 170),
(15, 172),
(54, 64),
(54, 68),
(54, 73),
(55, 64),
(55, 68),
(55, 72),
(55, 73),
(76, 164),
(76, 174),
(76, 180),
(87, 64),
(87, 66),
(87, 72),
(87, 73),
(87, 127),
(87, 129),
(87, 136),
(87, 137),
(87, 138),
(87, 155),
(87, 156),
(87, 170),
(87, 172),
(94, 45),
(94, 67),
(94, 122),
(94, 129),
(94, 137),
(94, 164),
(101, 172),
(107, 172),
(108, 154),
(108, 155),
(108, 158),
(108, 169),
(108, 170),
(108, 172),
(112, 172),
(116, 164),
(116, 174);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `played_quiz_question`
--

CREATE TABLE `played_quiz_question` (
  `quiz_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `position` int(11) NOT NULL,
  `correct` int(11) NOT NULL,
  `own_answer` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `played_quiz_question`
--

INSERT INTO `played_quiz_question` (`quiz_id`, `question_id`, `position`, `correct`, `own_answer`) VALUES
(238, 1523, 1, 1, 1),
(238, 1526, 9, 1, 1),
(238, 1529, 5, 0, 3),
(238, 1530, 6, 0, 2),
(238, 1531, 8, 1, 1),
(238, 1532, 3, -1, 1),
(238, 1534, 4, 1, 1),
(238, 1540, 2, -1, 2),
(238, 1541, 10, 1, 1),
(238, 1542, 7, 0, 2),
(239, 1520, 6, 1, 1),
(239, 1527, 5, -1, 0),
(239, 1531, 9, 1, 1),
(239, 1537, 2, -1, 1),
(239, 1540, 8, 1, 1),
(239, 1541, 7, 1, 1),
(239, 1544, 1, 1, 1),
(239, 1545, 4, 0, 4),
(239, 1552, 10, 1, 1),
(239, 1553, 3, 1, 1),
(240, 1500, 8, 1, 1),
(240, 1501, 11, 1, 1),
(240, 1502, 13, 1, 1),
(240, 1503, 10, 1, 1),
(240, 1504, 9, 0, 3),
(240, 1505, 4, 1, 1),
(240, 1506, 5, 0, 2),
(240, 1507, 12, 1, 1),
(240, 1509, 7, -1, 0),
(240, 1510, 6, -1, 0),
(240, 1511, 1, 1, 1),
(240, 1512, 3, 1, 1),
(240, 1515, 2, 1, 1),
(241, 1521, 9, 1, 1),
(241, 1525, 6, 1, 1),
(241, 1531, 2, 1, 1),
(241, 1535, 1, 1, 1),
(241, 1539, 5, 1, 1),
(241, 1540, 3, 1, 1),
(241, 1541, 4, 1, 1),
(241, 1542, 8, 1, 1),
(241, 1543, 10, 1, 1),
(241, 1545, 7, 1, 1),
(269, 1520, 7, 1, 1),
(269, 1522, 10, 1, 1),
(269, 1528, 9, 0, 2),
(269, 1530, 4, 0, 4),
(269, 1533, 6, 1, 1),
(269, 1535, 1, 1, 1),
(269, 1542, 8, 1, 1),
(269, 1543, 2, 1, 1),
(269, 1545, 3, 1, 1),
(269, 1552, 5, 1, 1),
(279, 1699, 4, 1, 1),
(279, 1701, 1, 1, 1),
(279, 1702, 2, 1, 1),
(279, 1705, 8, 1, 1),
(279, 1707, 5, 1, 1),
(279, 1716, 7, 1, 1),
(279, 1721, 6, 1, 1),
(279, 1722, 3, 1, 1),
(280, 1689, 3, 1, 1),
(280, 1690, 7, 1, 1),
(280, 1692, 1, 1, 1),
(280, 1697, 4, 1, 1),
(280, 1705, 2, 1, 1),
(280, 1709, 5, 0, 4),
(280, 1712, 8, 1, 1),
(280, 1725, 6, 0, 3),
(281, 1692, 7, 1, 1),
(281, 1693, 5, 1, 1),
(281, 1695, 8, 1, 1),
(281, 1698, 4, 1, 1),
(281, 1703, 2, 1, 1),
(281, 1708, 3, 1, 1),
(281, 1721, 6, 1, 1),
(281, 1722, 1, 1, 1),
(282, 1694, 2, 1, 1),
(282, 1705, 1, 1, 1),
(282, 1708, 5, 1, 1),
(282, 1710, 7, 1, 1),
(282, 1715, 4, 1, 1),
(282, 1716, 8, 1, 1),
(282, 1721, 3, 1, 1),
(282, 1725, 6, 0, 4),
(283, 1691, 3, 1, 1),
(283, 1695, 6, 1, 1),
(283, 1698, 2, 1, 1),
(283, 1703, 1, 1, 1),
(283, 1707, 4, 1, 1),
(283, 1709, 7, 0, 4),
(283, 1711, 5, 1, 1),
(283, 1713, 8, 1, 1),
(284, 1693, 4, 1, 1),
(284, 1699, 6, 1, 1),
(284, 1708, 5, 1, 1),
(284, 1716, 2, 1, 1),
(284, 1718, 7, 1, 1),
(284, 1719, 3, 1, 1),
(284, 1720, 1, 1, 1),
(284, 1725, 8, 1, 1),
(286, 1689, 6, 1, 1),
(286, 1691, 1, 1, 1),
(286, 1693, 2, 1, 1),
(286, 1696, 5, 1, 1),
(286, 1698, 8, 1, 1),
(286, 1701, 4, 1, 1),
(286, 1702, 3, 1, 1),
(286, 1707, 7, 1, 1),
(292, 1695, 8, 1, 1),
(292, 1698, 6, 1, 1),
(292, 1703, 4, 1, 1),
(292, 1706, 7, 1, 1),
(292, 1708, 1, 1, 1),
(292, 1712, 3, 1, 1),
(292, 1716, 5, 1, 1),
(292, 1719, 2, 0, 2),
(298, 1692, 5, 1, 1),
(298, 1693, 7, 1, 1),
(298, 1696, 8, 1, 1),
(298, 1699, 2, 1, 1),
(298, 1700, 6, 1, 1),
(298, 1704, 1, 1, 1),
(298, 1713, 4, 1, 1),
(298, 1721, 3, 1, 1),
(304, 1500, 2, 1, 1),
(304, 1501, 11, 1, 1),
(304, 1502, 8, 1, 1),
(304, 1504, 12, 0, 3),
(304, 1506, 5, 0, 2),
(304, 1510, 13, 1, 1),
(304, 1511, 3, 1, 1),
(304, 1512, 7, 1, 1),
(304, 1513, 4, -1, 0),
(304, 1514, 10, 1, 1),
(304, 1516, 9, 1, 1),
(304, 1517, 6, 1, 1),
(304, 1518, 1, 1, 1),
(311, 1521, 1, 1, 1),
(311, 1524, 8, 1, 1),
(311, 1525, 9, 1, 1),
(311, 1529, 2, 1, 1),
(311, 1530, 10, 0, 2),
(311, 1532, 4, 1, 1),
(311, 1539, 3, 1, 1),
(311, 1542, 7, 1, 1),
(311, 1543, 6, 1, 1),
(311, 1544, 5, 1, 1),
(313, 1689, 8, 1, 1),
(313, 1698, 7, 1, 1),
(313, 1706, 1, 1, 1),
(313, 1709, 3, 0, 3),
(313, 1716, 2, 1, 1),
(313, 1717, 5, 1, 1),
(313, 1718, 4, 1, 1),
(313, 1723, 6, 1, 1),
(335, 1733, 9, 1, 1),
(335, 1734, 12, 1, 1),
(335, 1735, 18, 1, 1),
(335, 1748, 7, 1, 1),
(335, 1750, 19, 1, 1),
(335, 1758, 13, 1, 1),
(335, 1799, 16, 1, 1),
(335, 1800, 11, 1, 1),
(335, 1821, 14, 0, 3),
(335, 1832, 1, 1, 1),
(335, 1838, 5, 1, 1),
(335, 1848, 4, 1, 1),
(335, 1856, 8, 1, 1),
(335, 1869, 15, 0, 3),
(335, 1875, 10, 1, 1),
(335, 1897, 20, 1, 1),
(335, 1906, 3, 1, 1),
(335, 1908, 17, 1, 1),
(335, 1941, 2, 1, 1),
(335, 1946, 6, 1, 1),
(354, 1700, 2, 1, 1),
(354, 1704, 3, 0, 4),
(354, 1705, 5, 0, 4),
(354, 1708, 6, 1, 1),
(354, 1711, 1, 1, 1),
(354, 1716, 4, 1, 1),
(354, 1723, 8, 0, 4),
(354, 1724, 7, 1, 1),
(355, 1526, 5, 1, 1),
(355, 1527, 3, 0, 3),
(355, 1528, 8, 0, 3),
(355, 1530, 9, 0, 2),
(355, 1535, 1, 0, 3),
(355, 1536, 2, 1, 1),
(355, 1538, 7, 0, 2),
(355, 1539, 4, 1, 1),
(355, 1543, 6, 1, 1),
(355, 1553, 10, -1, 0),
(390, 1522, 7, 1, 1),
(390, 1527, 5, 1, 1),
(390, 1528, 9, 0, 2),
(390, 1529, 4, 0, 4),
(390, 1531, 6, 0, 3),
(390, 1532, 8, 1, 1),
(390, 1538, 10, 1, 1),
(390, 1542, 2, 0, 2),
(390, 1543, 1, 1, 1),
(390, 1553, 3, 1, 1),
(392, 1689, 3, 0, 4),
(392, 1693, 7, 0, 3),
(392, 1696, 2, 0, 3),
(392, 1702, 4, 0, 2),
(392, 1703, 1, 0, 2),
(392, 1713, 6, 1, 1),
(392, 1714, 8, 0, 4),
(392, 1716, 5, 1, 1),
(407, 1755, 7, 0, 3),
(407, 1769, 20, 1, 1),
(407, 1771, 15, 1, 1),
(407, 1784, 4, 1, 1),
(407, 1791, 6, 1, 1),
(407, 1793, 13, 1, 1),
(407, 1799, 17, 1, 1),
(407, 1805, 5, -1, 0),
(407, 1818, 8, 1, 1),
(407, 1823, 12, 1, 1),
(407, 1825, 1, 1, 1),
(407, 1846, 9, 1, 1),
(407, 1852, 16, 1, 1),
(407, 1867, 3, 1, 1),
(407, 1880, 14, 0, 3),
(407, 1883, 2, 1, 1),
(407, 1892, 11, 1, 1),
(407, 1912, 18, 0, 2),
(407, 1942, 19, 1, 1),
(407, 1951, 10, 1, 1),
(409, 1732, 14, 1, 1),
(409, 1751, 18, 1, 1),
(409, 1778, 15, 1, 1),
(409, 1782, 10, 1, 1),
(409, 1783, 17, 1, 1),
(409, 1787, 1, 1, 1),
(409, 1796, 19, 1, 1),
(409, 1800, 13, 1, 1),
(409, 1808, 3, 1, 1),
(409, 1835, 7, 1, 1),
(409, 1868, 9, 1, 1),
(409, 1881, 4, 1, 1),
(409, 1884, 12, 1, 1),
(409, 1906, 16, 1, 1),
(409, 1912, 20, 1, 1),
(409, 1915, 8, 1, 1),
(409, 1921, 2, 1, 1),
(409, 1931, 11, 1, 1),
(409, 1940, 6, 1, 1),
(409, 1944, 5, 1, 1),
(411, 1765, 6, 1, 1),
(411, 1774, 2, 1, 1),
(411, 1775, 17, 0, 2),
(411, 1779, 11, 1, 1),
(411, 1795, 7, -1, 0),
(411, 1815, 16, 1, 1),
(411, 1825, 14, 0, 3),
(411, 1831, 12, 1, 1),
(411, 1835, 13, 1, 1),
(411, 1838, 3, 1, 1),
(411, 1843, 10, 1, 1),
(411, 1884, 1, 1, 1),
(411, 1907, 15, 1, 1),
(411, 1924, 18, 1, 1),
(411, 1928, 9, 1, 1),
(411, 1932, 4, 1, 1),
(411, 1935, 20, 0, 2),
(411, 1936, 8, 0, 2),
(411, 1944, 5, 1, 1),
(411, 1948, 19, 1, 1),
(412, 1731, 2, 1, 1),
(412, 1736, 5, 1, 1),
(412, 1768, 3, 1, 1),
(412, 1778, 8, 1, 1),
(412, 1793, 18, 1, 1),
(412, 1805, 11, 1, 1),
(412, 1818, 16, 1, 1),
(412, 1827, 20, 1, 1),
(412, 1829, 13, 1, 1),
(412, 1839, 9, 1, 1),
(412, 1841, 17, 1, 1),
(412, 1859, 10, 1, 1),
(412, 1874, 6, 1, 1),
(412, 1882, 14, 1, 1),
(412, 1887, 15, 1, 1),
(412, 1890, 7, 1, 1),
(412, 1898, 1, -1, 0),
(412, 1907, 4, 1, 1),
(412, 1936, 12, 1, 1),
(412, 1941, 19, 1, 1),
(414, 1766, 11, 1, 1),
(414, 1771, 5, 1, 1),
(414, 1773, 15, 1, 1),
(414, 1779, 6, 0, 3),
(414, 1783, 18, 0, 3),
(414, 1788, 16, 0, 4),
(414, 1796, 3, 0, 3),
(414, 1807, 1, 0, 2),
(414, 1813, 2, 0, 3),
(414, 1818, 7, 0, 2),
(414, 1819, 8, -1, 0),
(414, 1833, 14, 1, 1),
(414, 1848, 12, -1, 0),
(414, 1853, 17, 1, 1),
(414, 1860, 9, 0, 2),
(414, 1907, 20, 1, 1),
(414, 1911, 4, 1, 1),
(414, 1918, 13, 0, 1),
(414, 1925, 19, 1, 1),
(414, 1931, 10, 1, 1),
(419, 1735, 1, 1, 1),
(419, 1739, 19, 1, 1),
(419, 1747, 11, 1, 1),
(419, 1761, 2, 1, 1),
(419, 1769, 6, 1, 1),
(419, 1784, 15, 1, 1),
(419, 1790, 16, 1, 1),
(419, 1799, 12, 1, 1),
(419, 1811, 3, 1, 1),
(419, 1812, 18, 0, 3),
(419, 1823, 8, 1, 1),
(419, 1834, 13, 1, 1),
(419, 1852, 20, 0, 3),
(419, 1856, 14, 0, 2),
(419, 1857, 10, -1, 0),
(419, 1901, 7, 1, 1),
(419, 1903, 4, 1, 1),
(419, 1937, 5, -1, 0),
(419, 1941, 17, 1, 1),
(419, 1948, 9, 1, 1),
(423, 1732, 1, 1, 1),
(423, 1734, 13, 1, 1),
(423, 1735, 20, 1, 1),
(423, 1740, 12, 1, 1),
(423, 1743, 8, 1, 1),
(423, 1750, 9, 0, 3),
(423, 1753, 14, 1, 1),
(423, 1761, 5, 1, 1),
(423, 1783, 15, 0, 3),
(423, 1788, 2, 1, 1),
(423, 1799, 17, 1, 1),
(423, 1821, 3, 1, 1),
(423, 1842, 10, 0, 2),
(423, 1854, 16, 1, 1),
(423, 1862, 6, 1, 1),
(423, 1881, 19, 1, 1),
(423, 1893, 18, 0, 2),
(423, 1894, 4, 1, 1),
(423, 1927, 7, 1, 1),
(423, 1945, 11, 1, 1),
(424, 7204, 16, 1, 1),
(424, 7216, 8, 0, 2),
(424, 7228, 2, 1, 1),
(424, 7237, 12, 1, 1),
(424, 7256, 3, 1, 1),
(424, 7266, 5, 1, 1),
(424, 7280, 13, 1, 1),
(424, 7312, 11, 1, 1),
(424, 7322, 7, 1, 1),
(424, 7323, 14, 0, 2),
(424, 7361, 9, 0, 2),
(424, 7430, 1, 1, 1),
(424, 7435, 6, 1, 1),
(424, 7439, 4, 1, 1),
(424, 7455, 15, 0, 3),
(424, 7463, 10, 1, 1),
(425, 7189, 11, 0, 4),
(425, 7198, 10, 1, 1),
(425, 7229, 2, 1, 1),
(425, 7310, 1, 0, 3),
(425, 7311, 7, 0, 4),
(425, 7376, 9, 0, 2),
(425, 7379, 5, 0, 2),
(425, 7402, 14, 1, 1),
(425, 7403, 8, 0, 3),
(425, 7412, 13, 0, 4),
(425, 7422, 15, 0, 4),
(425, 7430, 16, 0, 2),
(425, 7441, 6, 0, 4),
(425, 7492, 4, 1, 1),
(425, 7495, 12, 0, 4),
(425, 7510, 3, 1, 1),
(426, 7186, 7, 1, 1),
(426, 7202, 14, 1, 1),
(426, 7293, 16, 1, 1),
(426, 7318, 9, 1, 1),
(426, 7337, 15, 1, 1),
(426, 7340, 6, 1, 1),
(426, 7374, 3, 0, 2),
(426, 7392, 4, 0, 2),
(426, 7404, 8, 1, 1),
(426, 7405, 11, 1, 1),
(426, 7446, 10, 1, 1),
(426, 7462, 12, 1, 1),
(426, 7483, 1, 1, 1),
(426, 7497, 5, 1, 1),
(426, 7508, 2, 0, 3),
(426, 7522, 13, 1, 1),
(427, 7189, 11, 0, 4),
(427, 7240, 4, 0, 2),
(427, 7243, 10, 1, 1),
(427, 7250, 5, 1, 1),
(427, 7274, 7, 0, 4),
(427, 7288, 16, 1, 1),
(427, 7318, 3, 1, 1),
(427, 7336, 8, 0, 3),
(427, 7339, 2, 0, 4),
(427, 7361, 15, 0, 3),
(427, 7392, 6, 0, 2),
(427, 7459, 14, 1, 1),
(427, 7494, 1, 0, 4),
(427, 7499, 12, 1, 1),
(427, 7524, 9, 1, 1),
(427, 7531, 13, 0, 2),
(428, 7209, 7, 1, 1),
(428, 7215, 15, 1, 1),
(428, 7216, 4, 0, 3),
(428, 7224, 5, 0, 2),
(428, 7240, 8, 0, 4),
(428, 7277, 3, 1, 1),
(428, 7299, 13, 1, 1),
(428, 7335, 1, 0, 3),
(428, 7342, 6, 1, 1),
(428, 7371, 9, 1, 1),
(428, 7386, 14, 1, 1),
(428, 7427, 10, 1, 1),
(428, 7440, 16, 0, 2),
(428, 7442, 12, 0, 4),
(428, 7471, 11, 0, 3),
(428, 7511, 2, 0, 3),
(429, 7290, 4, 1, 1),
(429, 7294, 15, 1, 1),
(429, 7301, 16, 1, 1),
(429, 7319, 14, 0, 2),
(429, 7320, 1, 0, 3),
(429, 7325, 6, 0, 2),
(429, 7337, 11, 1, 1),
(429, 7342, 2, 0, 4),
(429, 7376, 8, 1, 1),
(429, 7391, 9, 0, 2),
(429, 7445, 7, 0, 4),
(429, 7476, 12, 1, 1),
(429, 7480, 13, 1, 1),
(429, 7502, 10, 0, 2),
(429, 7518, 3, 0, 2),
(429, 7519, 5, 0, 4),
(430, 7184, 13, 0, 4),
(430, 7211, 15, 1, 1),
(430, 7214, 6, 1, 1),
(430, 7215, 16, 1, 1),
(430, 7235, 14, 1, 1),
(430, 7266, 9, 0, 4),
(430, 7326, 10, 1, 1),
(430, 7327, 4, 1, 1),
(430, 7360, 1, 1, 1),
(430, 7408, 12, 0, 3),
(430, 7437, 8, 0, 4),
(430, 7439, 2, 0, 4),
(430, 7457, 11, 1, 1),
(430, 7468, 7, 0, 2),
(430, 7497, 3, 0, 2),
(430, 7498, 5, 0, 4),
(431, 7227, 6, 1, 1),
(431, 7245, 15, 0, 2),
(431, 7252, 10, 1, 1),
(431, 7257, 8, 0, 4),
(431, 7346, 9, 1, 1),
(431, 7353, 13, 0, 3),
(431, 7373, 1, 0, 4),
(431, 7398, 12, 1, 1),
(431, 7408, 16, 0, 2),
(431, 7414, 4, 1, 1),
(431, 7415, 11, 1, 1),
(431, 7427, 2, 0, 3),
(431, 7435, 5, 1, 1),
(431, 7446, 7, 1, 1),
(431, 7456, 14, 0, 3),
(431, 7482, 3, 0, 3),
(432, 7188, 13, 0, 2),
(432, 7219, 15, 1, 1),
(432, 7220, 3, 0, 4),
(432, 7231, 9, 1, 1),
(432, 7238, 1, 0, 4),
(432, 7338, 5, 0, 4),
(432, 7358, 8, 0, 2),
(432, 7364, 11, 1, 1),
(432, 7365, 16, 0, 3),
(432, 7402, 12, 1, 1),
(432, 7450, 4, 1, 1),
(432, 7457, 7, 1, 1),
(432, 7467, 14, 1, 1),
(432, 7488, 2, 1, 1),
(432, 7504, 6, 1, 1),
(432, 7521, 10, -1, 0),
(433, 7209, 11, 1, 1),
(433, 7243, 12, 0, 4),
(433, 7259, 13, 1, 1),
(433, 7278, 5, 1, 1),
(433, 7281, 1, 0, 2),
(433, 7293, 4, 1, 1),
(433, 7312, 6, 1, 1),
(433, 7338, 7, 0, 2),
(433, 7347, 2, 1, 1),
(433, 7358, 10, 1, 1),
(433, 7362, 14, 0, 2),
(433, 7363, 15, 0, 4),
(433, 7381, 3, 1, 1),
(433, 7394, 16, 1, 1),
(433, 7402, 9, 1, 1),
(433, 7448, 8, 1, 1),
(434, 7201, 13, 1, 1),
(434, 7216, 4, 1, 1),
(434, 7242, 7, 1, 1),
(434, 7260, 1, 0, 2),
(434, 7310, 2, 1, 1),
(434, 7311, 6, 1, 1),
(434, 7320, 14, 1, 1),
(434, 7365, 3, 1, 1),
(434, 7371, 11, 1, 1),
(434, 7382, 10, 0, 4),
(434, 7411, 9, 1, 1),
(434, 7457, 16, 1, 1),
(434, 7460, 8, 1, 1),
(434, 7462, 15, 1, 1),
(434, 7472, 5, 1, 1),
(434, 7509, 12, 1, 1),
(435, 7182, 16, 1, 1),
(435, 7197, 12, 0, 4),
(435, 7201, 8, 1, 1),
(435, 7224, 13, 1, 1),
(435, 7252, 15, 1, 1),
(435, 7271, 11, 0, 3),
(435, 7284, 4, 1, 1),
(435, 7314, 1, 0, 2),
(435, 7342, 14, 1, 1),
(435, 7346, 5, 1, 1),
(435, 7359, 9, 0, 2),
(435, 7381, 7, 0, 3),
(435, 7399, 6, 1, 1),
(435, 7417, 3, 0, 3),
(435, 7442, 2, 0, 4),
(435, 7511, 10, -1, 0),
(437, 7203, 6, 1, 1),
(437, 7217, 16, 1, 1),
(437, 7223, 4, 0, 2),
(437, 7238, 10, 1, 1),
(437, 7244, 11, 0, 4),
(437, 7257, 7, 0, 4),
(437, 7269, 2, 0, 2),
(437, 7286, 1, 0, 3),
(437, 7295, 5, 0, 2),
(437, 7305, 9, 0, 2),
(437, 7308, 15, 0, 2),
(437, 7376, 14, 0, 2),
(437, 7433, 13, 0, 3),
(437, 7459, 12, 0, 2),
(437, 7472, 3, 1, 1),
(437, 7496, 8, 0, 2),
(438, 7198, 12, 1, 1),
(438, 7202, 10, 1, 1),
(438, 7210, 16, 0, 4),
(438, 7230, 4, 0, 2),
(438, 7249, 6, 0, 4),
(438, 7291, 1, 1, 1),
(438, 7320, 13, 1, 1),
(438, 7342, 14, 1, 1),
(438, 7347, 15, 1, 1),
(438, 7381, 7, 0, 3),
(438, 7384, 3, 1, 1),
(438, 7386, 2, 1, 1),
(438, 7400, 8, 0, 4),
(438, 7443, 11, 0, 4),
(438, 7513, 5, 1, 1),
(438, 7521, 9, 0, 2),
(439, 7186, 7, 0, 2),
(439, 7222, 12, 0, 3),
(439, 7257, 9, 0, 3),
(439, 7266, 11, 1, 1),
(439, 7307, 13, 1, 1),
(439, 7315, 14, 1, 1),
(439, 7321, 10, 0, 3),
(439, 7325, 2, 1, 1),
(439, 7342, 3, 0, 4),
(439, 7355, 6, 1, 1),
(439, 7380, 4, 0, 4),
(439, 7453, 5, 1, 1),
(439, 7479, 15, 0, 2),
(439, 7493, 8, 1, 1),
(439, 7506, 16, 0, 3),
(439, 7518, 1, 0, 2),
(440, 7226, 4, 0, 3),
(440, 7239, 10, 0, 3),
(440, 7252, 15, 0, 2),
(440, 7260, 8, 0, 3),
(440, 7278, 12, 0, 3),
(440, 7353, 5, 0, 3),
(440, 7373, 11, -1, 0),
(440, 7408, 3, 0, 3),
(440, 7409, 7, 1, 1),
(440, 7410, 1, 0, 2),
(440, 7411, 13, 0, 4),
(440, 7476, 16, 1, 1),
(440, 7482, 14, 0, 3),
(440, 7502, 6, 0, 3),
(440, 7512, 2, 0, 3),
(440, 7526, 9, 0, 3),
(441, 7214, 12, 1, 1),
(441, 7256, 6, 0, 3),
(441, 7259, 4, 0, 4),
(441, 7267, 8, 1, 1),
(441, 7273, 7, 0, 3),
(441, 7281, 14, 0, 2),
(441, 7287, 10, 0, 2),
(441, 7290, 11, 1, 1),
(441, 7318, 15, 0, 4),
(441, 7339, 5, 0, 4),
(441, 7357, 9, 0, 3),
(441, 7376, 13, 0, 2),
(441, 7432, 16, 0, 2),
(441, 7454, 2, 0, 2),
(441, 7476, 3, 1, 1),
(441, 7489, 1, 0, 4),
(442, 7196, 13, 1, 1),
(442, 7218, 8, 0, 3),
(442, 7228, 6, 1, 1),
(442, 7239, 15, 0, 2),
(442, 7251, 3, 0, 2),
(442, 7271, 12, 0, 4),
(442, 7298, 11, 0, 3),
(442, 7337, 5, 1, 1),
(442, 7389, 1, 1, 1),
(442, 7395, 4, 0, 4),
(442, 7435, 9, 1, 1),
(442, 7484, 7, 0, 3),
(442, 7494, 14, 1, 1),
(442, 7508, 2, 0, 3),
(442, 7518, 16, 0, 2),
(442, 7529, 10, 0, 3),
(443, 7201, 1, 1, 1),
(443, 7218, 10, 1, 1),
(443, 7235, 8, 1, 1),
(443, 7264, 2, 1, 1),
(443, 7283, 15, 1, 1),
(443, 7302, 4, 1, 1),
(443, 7319, 11, 1, 1),
(443, 7332, 5, 1, 1),
(443, 7387, 6, 1, 1),
(443, 7404, 9, 0, 2),
(443, 7418, 12, 1, 1),
(443, 7423, 3, 0, 4),
(443, 7451, 16, 0, 3),
(443, 7471, 14, 0, 2),
(443, 7500, 13, 1, 1),
(443, 7518, 7, 1, 1),
(444, 7226, 7, 0, 3),
(444, 7233, 12, 0, 3),
(444, 7268, 3, 0, 4),
(444, 7273, 16, 1, 1),
(444, 7317, 6, 1, 1),
(444, 7330, 15, 0, 4),
(444, 7333, 5, 1, 1),
(444, 7398, 4, 0, 4),
(444, 7401, 10, 0, 3),
(444, 7405, 14, 1, 1),
(444, 7407, 13, 1, 1),
(444, 7415, 8, 1, 1),
(444, 7419, 11, 1, 1),
(444, 7474, 1, 1, 1),
(444, 7502, 9, 0, 2),
(444, 7507, 2, 0, 3),
(446, 7196, 11, 1, 1),
(446, 7211, 2, 0, 2),
(446, 7238, 14, 0, 3),
(446, 7275, 7, 0, 3),
(446, 7348, 10, 0, 4),
(446, 7368, 3, 0, 2),
(446, 7381, 8, 0, 3),
(446, 7419, 15, 0, 3),
(446, 7428, 9, 1, 1),
(446, 7454, 6, 0, 2),
(446, 7461, 1, 0, 2),
(446, 7474, 16, 1, 1),
(446, 7478, 13, 0, 2),
(446, 7481, 12, 1, 1),
(446, 7490, 5, 0, 3),
(446, 7517, 4, 0, 4),
(447, 7191, 13, 0, 2),
(447, 7305, 14, 0, 2),
(447, 7329, 16, 1, 1),
(447, 7338, 1, 1, 1),
(447, 7341, 15, 0, 4),
(447, 7346, 4, 1, 1),
(447, 7359, 11, 1, 1),
(447, 7373, 5, 1, 1),
(447, 7381, 10, 1, 1),
(447, 7430, 12, 1, 1),
(447, 7443, 3, 0, 2),
(447, 7479, 9, 1, 1),
(447, 7492, 2, 1, 1),
(447, 7498, 7, 0, 4),
(447, 7504, 8, 1, 1),
(447, 7531, 6, 0, 4),
(448, 7180, 10, 1, 1),
(448, 7210, 15, 0, 3),
(448, 7268, 4, 0, 4),
(448, 7282, 6, 1, 1),
(448, 7319, 13, 0, 2),
(448, 7323, 12, 0, 3),
(448, 7324, 5, 1, 1),
(448, 7331, 16, 1, 1),
(448, 7343, 14, 0, 2),
(448, 7346, 2, 1, 1),
(448, 7396, 11, 1, 1),
(448, 7407, 8, 0, 3),
(448, 7414, 1, 1, 1),
(448, 7435, 3, 1, 1),
(448, 7451, 7, 1, 1),
(448, 7470, 9, 1, 1),
(449, 7212, 3, 1, 1),
(449, 7249, 1, 1, 1),
(449, 7254, 16, 0, 4),
(449, 7276, 15, 1, 1),
(449, 7286, 7, 1, 1),
(449, 7314, 6, 1, 1),
(449, 7316, 2, 1, 1),
(449, 7338, 9, 1, 1),
(449, 7349, 14, 0, 3),
(449, 7391, 13, 0, 2),
(449, 7408, 8, 1, 1),
(449, 7471, 10, 0, 2),
(449, 7497, 5, 1, 1),
(449, 7503, 12, 0, 2),
(449, 7509, 4, 1, 1),
(449, 7529, 11, 1, 1),
(460, 1731, 17, 1, 1),
(460, 1751, 14, 1, 1),
(460, 1755, 3, 0, 2),
(460, 1759, 8, 1, 1),
(460, 1776, 4, 1, 1),
(460, 1781, 7, 1, 1),
(460, 1782, 1, 1, 1),
(460, 1787, 11, 1, 1),
(460, 1850, 20, 1, 1),
(460, 1875, 10, 1, 1),
(460, 1884, 13, 1, 1),
(460, 1898, 9, 1, 1),
(460, 1899, 2, 1, 1),
(460, 1906, 16, 1, 1),
(460, 1914, 12, 1, 1),
(460, 1915, 18, 1, 1),
(460, 1919, 6, 1, 1),
(460, 1925, 5, 1, 1),
(460, 1946, 15, 1, 1),
(460, 1948, 19, 1, 1),
(463, 1688, 4, 1, 1),
(463, 1692, 5, 1, 1),
(463, 1695, 7, 1, 1),
(463, 1703, 3, 1, 1),
(463, 1707, 8, 1, 1),
(463, 1710, 2, 1, 1),
(463, 1713, 6, 1, 1),
(463, 1714, 1, 1, 1),
(464, 7188, 6, 1, 1),
(464, 7194, 9, 0, 3),
(464, 7200, 1, 1, 1),
(464, 7260, 4, 1, 1),
(464, 7267, 14, 1, 1),
(464, 7307, 13, 1, 1),
(464, 7345, 12, 0, 2),
(464, 7384, 11, 1, 1),
(464, 7397, 10, 1, 1),
(464, 7409, 8, 1, 1),
(464, 7454, 15, 1, 1),
(464, 7468, 16, 0, 4),
(464, 7485, 2, 0, 2),
(464, 7491, 7, 0, 4),
(464, 7509, 3, 1, 1),
(464, 7525, 5, 1, 1),
(465, 1731, 7, 1, 1),
(465, 1743, 12, 1, 1),
(465, 1752, 4, 1, 1),
(465, 1758, 13, 1, 1),
(465, 1763, 1, 0, 4),
(465, 1782, 20, 1, 1),
(465, 1796, 19, 1, 1),
(465, 1801, 10, 1, 1),
(465, 1806, 9, 1, 1),
(465, 1811, 5, 1, 1),
(465, 1819, 8, 1, 1),
(465, 1839, 17, 1, 1),
(465, 1859, 15, 1, 1),
(465, 1861, 18, 1, 1),
(465, 1864, 11, 1, 1),
(465, 1881, 16, 1, 1),
(465, 1902, 6, 1, 1),
(465, 1909, 2, 1, 1),
(465, 1919, 3, 1, 1),
(465, 1941, 14, 1, 1),
(466, 1733, 16, 1, 1),
(466, 1735, 11, 1, 1),
(466, 1748, 18, 1, 1),
(466, 1754, 7, 1, 1),
(466, 1781, 8, 1, 1),
(466, 1788, 13, 1, 1),
(466, 1802, 9, 1, 1),
(466, 1806, 1, 1, 1),
(466, 1828, 4, 1, 1),
(466, 1847, 5, 0, 3),
(466, 1856, 2, 1, 1),
(466, 1874, 15, 1, 1),
(466, 1882, 14, 1, 1),
(466, 1886, 12, 1, 1),
(466, 1902, 6, 1, 1),
(466, 1905, 10, 1, 1),
(466, 1927, 3, 1, 1),
(466, 1941, 17, 1, 1),
(466, 1942, 20, 1, 1),
(466, 1946, 19, 1, 1),
(467, 7191, 11, -1, 0),
(467, 7252, 7, -1, 0),
(467, 7255, 1, -1, 0),
(467, 7292, 6, -1, 0),
(467, 7301, 9, -1, 0),
(467, 7326, 4, -1, 0),
(467, 7327, 5, -1, 0),
(467, 7331, 10, -1, 0),
(467, 7418, 2, -1, 0),
(467, 7443, 13, -1, 0),
(467, 7469, 14, -1, 0),
(467, 7476, 15, -1, 0),
(467, 7481, 3, -1, 0),
(467, 7495, 12, -1, 0),
(467, 7517, 16, -1, 0),
(467, 7532, 8, -1, 0),
(468, 1736, 13, 1, 1),
(468, 1737, 15, 1, 1),
(468, 1740, 20, 1, 1),
(468, 1753, 19, 1, 1),
(468, 1775, 8, 1, 1),
(468, 1778, 1, 1, 1),
(468, 1785, 2, 1, 1),
(468, 1787, 3, 1, 1),
(468, 1790, 17, 1, 1),
(468, 1794, 18, 1, 1),
(468, 1821, 5, 1, 1),
(468, 1829, 16, 1, 1),
(468, 1853, 12, 1, 1),
(468, 1884, 6, 1, 1),
(468, 1888, 10, 1, 1),
(468, 1889, 11, 1, 1),
(468, 1891, 4, 1, 1),
(468, 1907, 14, 1, 1),
(468, 1916, 7, 1, 1),
(468, 1917, 9, 1, 1),
(473, 7187, 4, 1, 1),
(473, 7199, 5, 0, 3),
(473, 7214, 12, 1, 1),
(473, 7241, 11, 1, 1),
(473, 7247, 10, 1, 1),
(473, 7264, 6, 1, 1),
(473, 7317, 1, 0, 3),
(473, 7335, 13, 0, 3),
(473, 7355, 3, 1, 1),
(473, 7372, 14, 1, 1),
(473, 7384, 15, 1, 1),
(473, 7424, 8, 1, 1),
(473, 7438, 7, 1, 1),
(473, 7490, 16, 0, 4),
(473, 7496, 2, 1, 1),
(473, 7532, 9, 1, 1),
(474, 7182, 4, -1, 0),
(474, 7221, 1, -1, 0),
(474, 7229, 7, -1, 0),
(474, 7282, 12, -1, 0),
(474, 7303, 10, -1, 0),
(474, 7356, 11, -1, 0),
(474, 7362, 8, -1, 0),
(474, 7387, 13, -1, 0),
(474, 7407, 15, -1, 0),
(474, 7413, 2, -1, 0),
(474, 7417, 9, -1, 0),
(474, 7442, 3, -1, 0),
(474, 7453, 5, 1, 1),
(474, 7473, 16, -1, 0),
(474, 7504, 14, -1, 0),
(474, 7511, 6, -1, 0),
(475, 7187, 2, -1, 0),
(475, 7188, 13, -1, 0),
(475, 7267, 3, -1, 0),
(475, 7284, 7, -1, 0),
(475, 7304, 15, -1, 0),
(475, 7311, 11, -1, 0),
(475, 7326, 1, -1, 0),
(475, 7341, 6, -1, 0),
(475, 7356, 14, -1, 0),
(475, 7357, 4, -1, 0),
(475, 7367, 16, -1, 0),
(475, 7370, 8, -1, 0),
(475, 7486, 10, -1, 0),
(475, 7498, 12, -1, 0),
(475, 7514, 9, -1, 0),
(475, 7532, 5, -1, 0),
(479, 1748, 2, 1, 1),
(479, 1749, 14, 1, 1),
(479, 1763, 19, 1, 1),
(479, 1784, 3, 1, 1),
(479, 1803, 11, 1, 1),
(479, 1810, 7, 1, 1),
(479, 1811, 1, 1, 1),
(479, 1816, 4, 1, 1),
(479, 1817, 16, 0, 4),
(479, 1854, 20, 1, 1),
(479, 1870, 17, 1, 1),
(479, 1872, 12, 1, 1),
(479, 1879, 13, 1, 1),
(479, 1884, 9, 1, 1),
(479, 1898, 5, 1, 1),
(479, 1902, 10, 1, 1),
(479, 1915, 15, 1, 1),
(479, 1923, 8, 1, 1),
(479, 1928, 18, 1, 1),
(479, 1935, 6, 1, 1),
(482, 1693, 8, 0, 3),
(482, 1697, 1, 1, 1),
(482, 1698, 7, 0, 4),
(482, 1715, 4, 1, 1),
(482, 1720, 6, 0, 2),
(482, 1722, 2, 1, 1),
(482, 1724, 5, 1, 1),
(482, 1725, 3, 1, 1),
(483, 1689, 2, 1, 1),
(483, 1695, 1, 1, 1),
(483, 1699, 7, 1, 1),
(483, 1701, 4, 1, 1),
(483, 1705, 6, 1, 1),
(483, 1706, 5, 1, 1),
(483, 1712, 8, 1, 1),
(483, 1725, 3, 1, 1),
(485, 1521, 4, 1, 1),
(485, 1529, 8, 0, 3),
(485, 1530, 7, 0, 2),
(485, 1531, 10, 1, 1),
(485, 1534, 2, 1, 1),
(485, 1535, 1, 1, 1),
(485, 1536, 9, 0, 4),
(485, 1540, 3, 1, 1),
(485, 1542, 6, 0, 2),
(485, 1552, 5, 1, 1),
(486, 1501, 10, 1, 1),
(486, 1502, 2, 1, 1),
(486, 1503, 4, 1, 1),
(486, 1504, 7, 1, 1),
(486, 1506, 3, 0, 2),
(486, 1507, 6, 1, 1),
(486, 1510, 11, 1, 1),
(486, 1511, 5, 1, 1),
(486, 1514, 8, 1, 1),
(486, 1515, 13, 1, 1),
(486, 1516, 9, 1, 1),
(486, 1517, 12, 1, 1),
(486, 1518, 1, 1, 1),
(488, 7226, 10, 1, 1),
(488, 7228, 2, 1, 1),
(488, 7293, 16, 1, 1),
(488, 7302, 5, 1, 1),
(488, 7309, 1, 1, 1),
(488, 7374, 6, 0, 4),
(488, 7399, 9, 1, 1),
(488, 7403, 11, 0, 3),
(488, 7412, 4, 1, 1),
(488, 7417, 13, 1, 1),
(488, 7418, 3, 1, 1),
(488, 7425, 7, 1, 1),
(488, 7431, 14, 1, 1),
(488, 7477, 8, 1, 1),
(488, 7496, 15, 1, 1),
(488, 7515, 12, 0, 3),
(490, 1739, 5, 1, 1),
(490, 1749, 19, 1, 1),
(490, 1754, 17, 1, 1),
(490, 1762, 11, 1, 1),
(490, 1784, 20, 1, 1),
(490, 1787, 18, 1, 1),
(490, 1789, 4, 1, 1),
(490, 1800, 6, 1, 1),
(490, 1801, 14, 1, 1),
(490, 1805, 8, 1, 1),
(490, 1837, 2, 1, 1),
(490, 1840, 9, 1, 1),
(490, 1867, 10, 1, 1),
(490, 1872, 15, 1, 1),
(490, 1883, 13, 1, 1),
(490, 1885, 3, 1, 1),
(490, 1904, 7, 1, 1),
(490, 1905, 1, 1, 1),
(490, 1912, 16, 1, 1),
(490, 1921, 12, 1, 1),
(507, 7182, 4, 1, 1),
(507, 7200, 2, -1, 0),
(507, 7210, 10, -1, 0),
(507, 7214, 7, 1, 1),
(507, 7232, 9, -1, 0),
(507, 7252, 3, 1, 1),
(507, 7268, 5, 0, 4),
(507, 7269, 13, 1, 1),
(507, 7280, 1, 1, 1),
(507, 7294, 15, 1, 1),
(507, 7326, 8, -1, 0),
(507, 7329, 12, -1, 0),
(507, 7488, 11, -1, 0),
(507, 7498, 6, 0, 2),
(507, 7527, 14, 0, 2),
(507, 7532, 16, 0, 3),
(525, 7436, 16, -1, 0),
(526, 7555, 7, 1, 1),
(526, 7556, 3, 1, 1),
(526, 7562, 12, 1, 1),
(526, 7563, 13, 1, 1),
(526, 7569, 4, 1, 1),
(526, 7570, 2, 1, 1),
(526, 7572, 6, 1, 1),
(526, 7576, 5, 1, 1),
(526, 7577, 10, 1, 1),
(526, 7581, 9, 1, 1),
(526, 7583, 1, 1, 1),
(526, 7587, 11, 1, 1),
(526, 7593, 8, 1, 1),
(527, 7556, 4, 1, 1),
(527, 7557, 11, 1, 1),
(527, 7565, 3, 1, 1),
(527, 7567, 6, 1, 1),
(527, 7571, 7, 1, 1),
(527, 7574, 12, 1, 1),
(527, 7575, 5, 1, 1),
(527, 7579, 9, 1, 1),
(527, 7584, 8, 1, 1),
(527, 7585, 10, 1, 1),
(527, 7588, 1, 1, 1),
(527, 7593, 2, 1, 1),
(527, 7595, 13, 1, 1),
(532, 7646, 10, 1, 1),
(532, 7649, 3, 1, 1),
(532, 7651, 7, 1, 1),
(532, 7656, 12, 1, 1),
(532, 7670, 4, 0, 2),
(532, 7674, 5, 1, 1),
(532, 7677, 11, 1, 1),
(532, 7679, 1, 1, 1),
(532, 7681, 13, 1, 1),
(532, 7687, 15, 1, 1),
(532, 7691, 14, 1, 1),
(532, 7706, 6, 1, 1),
(532, 7708, 8, -1, 0),
(532, 7709, 2, 1, 1),
(532, 7712, 9, 0, 3),
(534, 7657, 10, 1, 1),
(534, 7658, 1, 1, 1),
(534, 7659, 6, 1, 1),
(534, 7668, 13, 1, 1),
(534, 7673, 15, 1, 1),
(534, 7674, 9, 1, 1),
(534, 7687, 7, 1, 1),
(534, 7695, 2, 0, 4),
(534, 7698, 4, 1, 1),
(534, 7699, 11, 1, 1),
(534, 7700, 8, 1, 1),
(534, 7706, 5, 1, 1),
(534, 7709, 14, 1, 1),
(534, 7711, 3, 1, 1),
(534, 7713, 12, 1, 1),
(535, 7647, 10, 1, 1),
(535, 7654, 6, 1, 1),
(535, 7655, 1, 1, 1),
(535, 7667, 9, 1, 1),
(535, 7668, 15, 1, 1),
(535, 7673, 3, 1, 1),
(535, 7674, 11, 1, 1),
(535, 7681, 13, 1, 1),
(535, 7686, 14, 1, 1),
(535, 7692, 4, 1, 1),
(535, 7698, 2, 1, 1),
(535, 7702, 7, 1, 1),
(535, 7712, 8, 1, 1),
(535, 7713, 5, 1, 1),
(535, 7715, 12, 1, 1),
(536, 1768, 20, -1, 0),
(536, 1898, 1, -1, 0),
(537, 7547, 12, 1, 1),
(537, 7548, 6, 1, 1),
(537, 7551, 1, 0, 3),
(537, 7556, 10, 1, 1),
(537, 7559, 8, 1, 1),
(537, 7577, 9, 1, 1),
(537, 7578, 11, 1, 1),
(537, 7586, 3, 1, 1),
(537, 7587, 7, 0, 2),
(537, 7590, 4, 1, 1),
(537, 7592, 5, 1, 1),
(537, 7593, 2, 1, 1),
(537, 7594, 13, 1, 1),
(538, 1739, 20, -1, 0),
(540, 7652, 2, 1, 1),
(540, 7654, 14, 1, 1),
(540, 7655, 12, 1, 1),
(540, 7660, 4, 1, 1),
(540, 7667, 10, 1, 1),
(540, 7671, 11, 1, 1),
(540, 7676, 7, 1, 1),
(540, 7685, 8, 1, 1),
(540, 7686, 3, 1, 1),
(540, 7690, 9, 1, 1),
(540, 7692, 6, 1, 1),
(540, 7694, 1, 1, 1),
(540, 7695, 15, 1, 1),
(540, 7696, 13, 1, 1),
(540, 7702, 5, 1, 1),
(548, 7652, 4, 1, 1),
(548, 7653, 14, 1, 1),
(548, 7666, 11, 1, 1),
(548, 7670, 3, 1, 1),
(548, 7673, 10, 1, 1),
(548, 7681, 2, 0, 2),
(548, 7683, 13, 1, 1),
(548, 7686, 15, 1, 1),
(548, 7697, 5, 1, 1),
(548, 7700, 9, 1, 1),
(548, 7703, 12, 1, 1),
(548, 7704, 1, 1, 1),
(548, 7706, 7, 1, 1),
(548, 7709, 8, 1, 1),
(548, 7714, 6, 1, 1),
(550, 1736, 18, 1, 1),
(550, 1749, 7, 1, 1),
(550, 1764, 11, 1, 1),
(550, 1772, 5, 0, 4),
(550, 1797, 9, 1, 1),
(550, 1800, 13, 1, 1),
(550, 1804, 19, 1, 1),
(550, 1809, 6, 1, 1),
(550, 1811, 17, 1, 1),
(550, 1821, 12, 1, 1),
(550, 1824, 16, 1, 1),
(550, 1826, 15, 1, 1),
(550, 1838, 14, 1, 1),
(550, 1853, 20, 1, 1),
(550, 1855, 1, 1, 1),
(550, 1865, 4, 0, 2),
(550, 1874, 2, 1, 1),
(550, 1878, 10, 1, 1),
(550, 1907, 3, 1, 1),
(550, 1925, 8, 1, 1),
(554, 1760, 16, 1, 1),
(554, 1762, 19, 1, 1),
(554, 1765, 20, 1, 1),
(554, 1792, 11, 1, 1),
(554, 1795, 14, 1, 1),
(554, 1798, 6, 1, 1),
(554, 1807, 2, 1, 1),
(554, 1813, 10, 1, 1),
(554, 1818, 15, 1, 1),
(554, 1847, 13, 1, 1),
(554, 1849, 1, 1, 1),
(554, 1856, 18, 1, 1),
(554, 1872, 7, 1, 1),
(554, 1883, 8, 1, 1),
(554, 1894, 17, 1, 1),
(554, 1908, 3, 1, 1),
(554, 1909, 5, 0, 2),
(554, 1942, 9, 1, 1),
(554, 1944, 4, 1, 1),
(554, 1948, 12, 1, 1),
(557, 7185, 2, 1, 1),
(557, 7211, 6, 1, 1),
(557, 7214, 13, 1, 1),
(557, 7217, 10, 1, 1),
(557, 7239, 15, 0, 4),
(557, 7242, 8, 1, 1),
(557, 7289, 7, 0, 2),
(557, 7295, 9, 1, 1),
(557, 7347, 16, 1, 1),
(557, 7373, 1, 1, 1),
(557, 7386, 14, 1, 1),
(557, 7401, 4, 0, 3),
(557, 7440, 12, 1, 1),
(557, 7443, 3, 0, 3),
(557, 7493, 5, 1, 1),
(557, 7499, 11, 0, 2),
(558, 7649, 4, 1, 1),
(558, 7651, 9, 1, 1),
(558, 7664, 10, 1, 1),
(558, 7669, 3, 0, 3),
(558, 7674, 8, 1, 1),
(558, 7677, 6, 0, 2),
(558, 7681, 2, 0, 2),
(558, 7687, 14, 1, 1),
(558, 7690, 1, 1, 1),
(558, 7695, 13, 0, 4),
(558, 7705, 12, 1, 1),
(558, 7706, 7, 1, 1),
(558, 7709, 5, 1, 1),
(558, 7714, 11, 0, 2),
(558, 7715, 15, 1, 1),
(563, 7551, 1, 1, 1),
(563, 7553, 10, 1, 1),
(563, 7562, 6, 0, 2),
(563, 7569, 13, 1, 1),
(563, 7571, 7, 1, 1),
(563, 7572, 8, 1, 1),
(563, 7573, 5, 1, 1),
(563, 7582, 3, 1, 1),
(563, 7584, 12, 1, 1),
(563, 7586, 9, 0, 2),
(563, 7588, 2, 1, 1),
(563, 7590, 4, 0, 3),
(563, 7592, 11, 1, 1),
(564, 1521, 3, 1, 1),
(564, 1524, 1, 1, 1),
(564, 1525, 9, 1, 1),
(564, 1529, 6, 0, 2),
(564, 1533, 7, 1, 1),
(564, 1534, 5, 1, 1),
(564, 1535, 2, 1, 1),
(564, 1536, 8, 0, 4),
(564, 1542, 4, 0, 3),
(564, 1545, 10, 1, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `premium`
--

CREATE TABLE `premium` (
  `userid` int(11) NOT NULL,
  `minuspoints` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `delay` int(11) NOT NULL,
  `adminid` int(11) DEFAULT NULL,
  `startdate` datetime NOT NULL,
  `enddate` datetime NOT NULL,
  `deletedby` int(11) DEFAULT NULL,
  `deletereason` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `deletetime` datetime DEFAULT NULL,
  `is_active` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `premium`
--

INSERT INTO `premium` (`userid`, `minuspoints`, `price`, `delay`, `adminid`, `startdate`, `enddate`, `deletedby`, `deletereason`, `deletetime`, `is_active`) VALUES
(15, 15000, 0, 30, NULL, '2021-08-18 15:39:43', '2021-09-17 15:39:43', NULL, NULL, NULL, 0),
(15, 15000, 0, 30, NULL, '2022-04-22 20:34:07', '2022-05-22 20:34:07', NULL, NULL, NULL, 0),
(94, 15000, 0, 30, NULL, '2021-08-17 12:26:12', '2021-09-16 12:26:12', 15, 'Warn miatt törölve', '2021-08-17 15:28:09', 0),
(94, 0, 0, 1, 15, '2021-08-17 15:29:07', '2021-08-17 15:32:00', NULL, NULL, NULL, 0),
(94, 0, 0, 1, 15, '2021-08-18 10:52:00', '2021-08-19 10:52:00', 15, 'Ingyenes prémium törlése', '2021-08-18 15:02:43', 0),
(94, 0, 0, 2, 15, '2021-08-18 18:04:36', '2021-08-20 18:04:36', 15, 'Warn miatt törölve', '2021-08-18 18:21:12', 0),
(94, 15000, 0, 30, NULL, '2021-08-19 10:02:24', '2021-09-18 10:02:24', 15, 'Warn miatt törölve', '2021-08-25 11:15:58', 0),
(94, 15000, 0, 30, NULL, '2021-08-25 11:16:24', '2021-09-24 11:16:24', NULL, NULL, NULL, 0),
(107, 0, 0, 1, 15, '2021-08-18 21:04:16', '2021-08-19 21:04:16', 15, 'Ingyenes prémium törlése', '2021-08-18 21:05:04', 0),
(112, 0, 0, 1, 15, '2021-08-17 13:53:45', '2021-08-18 13:53:45', 15, 'Warn miatt törölve', '2021-08-17 14:10:08', 0),
(112, 0, 0, 1, 15, '2021-08-18 15:21:49', '2021-08-18 15:25:00', NULL, NULL, NULL, 0),
(112, 0, 0, 1, 15, '2021-08-18 15:27:36', '2021-08-18 15:30:00', NULL, NULL, NULL, 0),
(116, 15000, 0, 30, NULL, '2021-08-17 12:29:12', '2021-09-16 12:29:12', NULL, NULL, NULL, 0),
(118, 0, 0, 1, 15, '2021-08-24 14:35:19', '2021-08-24 14:40:00', NULL, NULL, NULL, 0),
(118, 15000, 0, 30, NULL, '2021-08-24 14:42:03', '2021-09-23 14:42:03', 15, 'Warn miatt törölve', '2021-08-24 14:52:43', 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `private_message`
--

CREATE TABLE `private_message` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `description` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sending_time` datetime NOT NULL,
  `read_msg` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `private_message`
--

INSERT INTO `private_message` (`id`, `sender_id`, `receiver_id`, `description`, `sending_time`, `read_msg`) VALUES
(12, 94, 15, 'Szia!\n\nEz az első üzenetem. :)\n\n\nÜdv,\naaaa', '2021-03-04 13:58:35', 1),
(13, 15, 94, 'Hello, nekem is neked.\n\nIdv, sss', '2021-03-04 13:59:31', 1),
(14, 94, 15, 'Szia!\n\nEz az első üzenetem. :)\n\n\nÜdv,\naaaa', '2021-03-04 14:17:44', 1),
(17, 94, 77, 'Haliho', '2021-03-15 15:57:07', 0),
(21, 15, 97, 've6rtgdf rysetrdgzfxvc 6w4ystegrdf', '2021-03-20 13:45:53', 0),
(23, 94, 112, 'Szia :)\n\nEz egy privát üzenet!\nbla bla\n\nÜdv,', '2021-06-13 22:57:39', 1),
(24, 101, 76, 'Hellóka?', '2021-07-02 18:17:04', 1),
(28, 94, 118, 'Szia, \nhogy vagy?', '2021-08-25 10:55:28', 1),
(32, 15, 113, 'Sziaaaaaa', '2021-10-23 09:47:33', 0),
(33, 109, 106, 'Hi$ this is a test', '2022-05-16 10:18:23', 1),
(34, 15, 94, 'Szia aaaa!\n\nWhat!s up?', '2022-05-16 14:27:30', 1),
(35, 94, 15, 'Szia SSS$ \nAAAa vagyok', '2022-05-16 15:01:48', 1),
(38, 15, 94, 'Szijaaaaa aaaa. SSS vagyok\r\nEmojikat küldtem tesztelésképp\r\n🤷‍♂️💕😥💥😊🌹🙄😜🙂👩‍🦰👏🤞💖🤗🤷‍♀️🤷‍♀️💙', '2022-05-16 21:57:50', 1),
(39, 15, 94, 'Sziaaa!\n\nÍrj vissza, amint tudsz! 👍👍', '2022-06-20 22:54:16', 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `question_comment`
--

CREATE TABLE `question_comment` (
  `id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `posted_by` varchar(30) NOT NULL,
  `comment_text` varchar(1000) NOT NULL,
  `comment_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `question_comment`
--

INSERT INTO `question_comment` (`id`, `question_id`, `posted_by`, `comment_text`, `comment_time`) VALUES
(741, 7725, 'sss', 'Ezt a kérdést elfogadták! 15 pont jutalom került jóváírásra a beküldőnek.', '2021-10-19 13:44:21'),
(742, 7726, 'sss', 'Módositott adatok:  Kérdés: Milyen élelmiszerből láthatunk sokat Halloween-kor?; ', '2021-10-19 13:45:07'),
(743, 7726, 'sss', 'Ezt a kérdést elfogadták! 15 pont jutalom került jóváírásra a beküldőnek.', '2021-10-19 13:45:58'),
(744, 7727, 'sss', 'Ezt a kérdést visszaküldték javításra! Ok:  (Túl sok) Helyesírási hiba!..', '2021-10-19 13:46:09'),
(748, 7730, 'sss', 'Ezt a kérdést elfogadták! 15 pont jutalom került jóváírásra a beküldőnek.', '2021-10-19 13:47:30'),
(769, 7727, 'sss', 'Módosítás előtti adatok: kérdés - miért gondolják a felnőttek, hogy a Halloween nem jó a gyerekeknek? , helyes válasz - mert a \"csokit vagy csalok\" játék veszélyes lehet , rossz válaszok: mert még túl fiatalok, hogy másokat ijesztgessenek , mert a jelmezeik nem elég ijesztőek , mert túl sokat játszanak aznap', '2022-04-28 23:57:57'),
(770, 7727, 'sss', 'Ezt a kérdést visszaküldték javításra! Ok:  A kérdés túl bonyolult/nem egyértelmű a megfogalmazás..', '2022-04-28 23:59:56'),
(771, 7727, 'sss', 'Módosítás előtti adatok: kérdés - miért gondolják a felnőttek, hogy a Halloween nem jó a gyerekeknek? , helyes válasz - mert a \"csokit vagy csalok\" játék veszélyes lehet , rossz válaszok: mert még túl fiatalok, hogy másokat ijesztgessenek , mert a jelmezeik nem elég ijesztőek , mert túl sokat játszanak aznap', '2022-04-29 01:52:37'),
(785, 7727, 'sss', 'Ezt a kérdést visszaküldték javításra! Ok:  Hibás adat/Helytelen a kérdés..', '2022-06-20 22:51:31'),
(786, 7739, 'sss', 'Ezt a kérdést visszaküldték javításra! Ok:  Rossz témakörválasztás..', '2022-06-20 22:51:40'),
(787, 7738, 'sss', 'Módositott adatok:  Nehézség: 1; ', '2022-06-21 00:04:50');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `quiz_comment`
--

CREATE TABLE `quiz_comment` (
  `user_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `comment_text` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment_date` datetime NOT NULL,
  `last_modified` datetime NOT NULL,
  `is_deleted` int(11) NOT NULL,
  `is_verified` int(11) NOT NULL,
  `verified_by` int(11) NOT NULL,
  `moderation` varchar(500) DEFAULT NULL,
  `verification_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `quiz_comment`
--

INSERT INTO `quiz_comment` (`user_id`, `quiz_id`, `comment_text`, `comment_date`, `last_modified`, `is_deleted`, `is_verified`, `verified_by`, `moderation`, `verification_time`) VALUES
(15, 1, 'december 28 hozzaszolas', '2020-12-28 12:48:54', '2020-12-28 12:48:54', 0, 0, 0, NULL, NULL),
(15, 1, '!!!censored!!!', '2021-03-20 13:53:03', '2021-03-20 13:53:03', 0, 2, 94, ' A nem helyén való hozzászólásoknak helye nincs!.\nModerálva aaaa által', '2021-09-20 16:03:45'),
(15, 1, '!!!censored!!!', '2021-03-31 11:02:31', '2021-03-31 11:02:31', 0, 2, 15, ' Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul. Ne használj feleslegesen szóismétléseket. A nem helyén való hozzászólásoknak helye nincs!. Vigyázz a szóhasználatra!.\nModerálva sss által', '2021-09-18 15:38:52'),
(15, 1, 'Annyi minden !!!censored!!!', '2021-08-12 16:47:27', '2021-08-12 16:47:27', 0, 2, 94, ' Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul.\nModerálva aaaa által', '2021-09-18 17:28:54'),
(15, 1, 'Nagyon változatos kvíz! Köszönöm! 😊', '2021-09-18 15:34:45', '2021-09-18 15:34:45', 0, 1, 15, NULL, '2021-09-18 15:36:59'),
(15, 1, 'Heloka 💖🤩😍❤🤷‍♂️😎💙💕\n\n😘🐱‍🏍😄🤗😂😁😊☺🤷‍♀️🤣😥🙄👍😙🤞😒💥👏🤳🌹😜', '2022-05-02 22:51:36', '2022-05-02 22:51:36', 0, 0, 0, NULL, NULL),
(15, 3, 'coool', '2020-12-24 12:38:21', '2020-12-24 12:38:21', 0, 1, 15, NULL, '2021-09-18 00:20:12'),
(15, 5, '!!!censored!!!', '2021-07-01 17:58:14', '2021-07-01 17:58:14', 0, 2, 94, ' Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul.\nModerálva aaaa által', '2021-09-18 17:29:11'),
(15, 6, 'Ez egy nagyon jo kviz XD', '2021-07-02 11:07:06', '2021-07-02 11:07:06', 0, 1, 94, NULL, '2021-09-18 17:29:06'),
(15, 6, '!!!censored!!!', '2021-08-06 10:56:56', '2021-08-06 10:56:56', 0, 2, 94, ' Vigyázz a szóhasználatra!.\nModerálva aaaa által', '2021-09-18 17:29:01'),
(15, 9, '!!!censored!!!{\n    echo \"sssssssssssss\";\n}\n\n!!!  A nem helyén való hozzászólásoknak helye nincs!.', '2021-09-17 12:57:27', '2021-09-17 12:57:27', 0, 2, 15, NULL, '2021-09-18 13:58:33'),
(15, 67, '!!!censored!!!', '2021-09-17 12:45:57', '2021-09-17 12:45:57', 0, 2, 94, ' A nem helyén való hozzászólásoknak helye nincs!.\nModerálva aaaa által', '2021-09-18 17:28:03'),
(15, 86, '!!!censored!!!', '2021-09-17 12:56:27', '2021-09-17 12:56:27', 0, 2, 94, ' A nem helyén való hozzászólásoknak helye nincs!.\nModerálva aaaa által', '2021-09-18 17:27:47'),
(15, 97, 'Tetszik ez a kvíz! \nÉrdekes kérdéseket tartalmaz.', '2020-12-25 18:10:12', '2020-12-25 18:10:12', 0, 1, 94, NULL, '2021-09-20 16:03:54'),
(15, 176, 'Jól megdolgoztatja az agyat ez a kvíz :))\nDe amúgy jó 😙🙂', '2021-09-19 14:34:52', '2021-09-19 14:34:52', 0, 1, 94, NULL, '2021-09-20 16:02:18'),
(15, 177, '!!!censored!!!', '2021-09-18 14:52:14', '2021-09-18 14:52:14', 0, 2, 94, 'Nem helyén való hozzászólás!\nModerálva aaaa által', '2021-09-18 17:27:34'),
(15, 177, 'Menő kvíz! ', '2022-06-20 23:00:43', '2022-06-20 23:00:43', 0, 0, 0, NULL, NULL),
(39, 177, 'Szupiii\n😂', '2021-09-29 15:47:17', '2021-09-29 15:47:17', 0, 1, 15, NULL, '2021-10-23 12:25:21'),
(94, 1, '!!!censored!!!', '2020-12-22 01:48:22', '2020-12-23 01:48:22', 0, 2, 15, ' Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul.\nModerálva sss által', '2021-10-17 15:21:46'),
(94, 1, '!!!censored!!!', '2020-12-22 01:48:46', '2020-12-23 01:48:46', 0, 2, 94, ' Vigyázz a szóhasználatra!.\nModerálva aaaa által', '2021-09-20 16:01:49'),
(94, 1, '!!!censored!!!', '2021-02-15 23:56:43', '2021-02-15 23:56:43', 0, 2, 15, ' Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul.\nModerálva sss által', '2021-09-18 15:29:08'),
(94, 1, '!!!censored!!!\n\n:-)\n:)', '2021-09-15 18:19:41', '2021-09-15 18:19:41', 0, 2, 94, ' Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul.\nModerálva aaaa által', '2021-09-18 17:28:15'),
(94, 5, '!!!censored!!!', '2021-08-24 13:30:44', '2021-08-24 13:30:44', 0, 2, 94, ' A nem helyén való hozzászólásoknak helye nincs!.\nModerálva aaaa által', '2021-09-18 17:28:29'),
(94, 6, '!!!censored!!!\n\n joo kviiiz', '2021-06-13 21:30:31', '2021-06-13 21:30:31', 0, 2, 94, ' Ne használj feleslegesen szóismétléseket.\nModerálva aaaa által', '2021-09-20 16:03:39'),
(94, 10, 'Ez klassz!', '2022-05-01 23:37:16', '2022-05-01 23:37:16', 0, 0, 0, NULL, NULL),
(94, 97, 'as ez aaaaz\n\n!!!censored!!!\n\n\n\ntttttt', '2021-06-13 21:29:32', '2021-06-13 21:29:32', 0, 2, 94, ' Vigyázz a szóhasználatra!.\nModerálva aaaa által', '2021-09-20 16:02:32'),
(99, 1, '7', '2020-12-22 09:02:12', '2020-12-23 09:02:12', 0, 0, 0, NULL, NULL),
(99, 1, '!!!censored!!!', '2020-12-22 21:34:23', '2020-12-23 21:34:23', 0, 2, 15, ' Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul.\nModerálva sss által', '2021-10-01 14:48:56'),
(99, 1, '!!!censored!!!', '2020-12-22 21:39:41', '2020-12-23 21:39:41', 0, 2, 15, ' Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul.\nModerálva sss által', '2021-10-23 12:25:08'),
(99, 1, '!!!censored!!!', '2020-12-23 10:09:25', '2020-12-23 10:09:25', 0, 2, 15, ' A nem helyén való hozzászólásoknak helye nincs!.\nModerálva sss által', '2021-10-22 21:48:36'),
(99, 1, '!!!censored!!!', '2020-12-23 11:30:01', '2020-12-23 11:30:01', 0, 2, 94, 'Rövid, egyszavas hozzászólásokat mellőzd, ha lehet!\nModerálva aaaa által', '2021-09-18 16:50:44'),
(99, 1, '!!!censored!!!', '2020-12-23 15:31:18', '2020-12-23 15:31:18', 0, 2, 15, ' Vigyázz a szóhasználatra!.\nModerálva sss által', '2022-06-20 23:07:12'),
(99, 1, '15', '2020-12-23 16:40:35', '2020-12-23 16:40:35', 0, 0, 0, NULL, NULL),
(99, 1, '16', '2020-12-23 18:23:01', '2020-12-23 18:23:01', 0, 0, 0, NULL, NULL),
(99, 1, '17', '2020-12-23 21:41:14', '2020-12-23 21:41:14', 0, 0, 0, NULL, NULL),
(99, 1, 'a\n!!!censored!!!\naaaaaa\n!!!censored!!!', '2020-12-24 17:04:38', '2020-12-24 17:04:38', 0, 2, 15, ' Ne használj feleslegesen szóismétléseket.\nModerálva sss által', '2021-09-18 15:40:24'),
(99, 7, '!!!censored!!! !!!censored!!!  5yersgdf', '2021-06-15 10:38:23', '2021-06-15 10:38:23', 0, 2, 15, 'A semmitmondó hozzászólásokat mellőzd, kérlek!\nModerálva sss által', '2021-09-18 15:20:34'),
(99, 12, 'Nagyon tetszik ez a kvíz. \nA legjobb ezen az oldalon. :)', '2021-03-21 20:26:23', '2021-03-21 20:26:23', 0, 1, 15, NULL, '2021-09-18 00:26:23'),
(99, 97, '10/10. 20 pontot kaptam.', '2021-02-15 19:49:32', '2021-02-15 19:49:32', 0, 1, 94, NULL, '2021-09-20 16:04:01'),
(100, 1, '2', '2020-12-17 11:43:51', '2020-12-24 11:43:51', 0, 1, 15, NULL, '2022-06-20 19:30:05'),
(112, 97, 'Tetszik ez a kvíz :)', '2021-06-07 23:18:45', '2021-06-07 23:18:45', 0, 1, 15, NULL, '2021-09-18 00:26:30'),
(116, 177, 'Tetszik ez a kvíz!', '2021-09-09 23:54:00', '2021-09-09 23:54:00', 0, 1, 94, NULL, '2021-09-18 17:28:18');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `quiz_like`
--

CREATE TABLE `quiz_like` (
  `user_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `liking_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `quiz_like`
--

INSERT INTO `quiz_like` (`user_id`, `quiz_id`, `liking_date`) VALUES
(15, 4, '2021-06-23 11:16:10'),
(15, 11, '2021-06-15 13:20:45'),
(15, 12, '2021-06-30 16:56:12'),
(15, 97, '2020-12-25 18:11:23'),
(15, 176, '2021-09-08 14:13:01'),
(15, 177, '2021-09-10 16:01:09'),
(39, 177, '2021-09-29 15:43:03'),
(94, 1, '2021-07-01 19:39:23'),
(94, 2, '2021-06-15 10:53:47'),
(94, 3, '2021-06-15 10:54:10'),
(94, 4, '2021-06-15 10:57:12'),
(94, 5, '2021-06-15 10:57:59'),
(94, 6, '2021-06-15 11:00:13'),
(94, 7, '2022-05-01 22:49:40'),
(94, 10, '2021-08-19 10:13:55'),
(94, 11, '2021-06-16 12:10:20'),
(94, 67, '2020-12-25 22:22:11'),
(94, 86, '2020-12-26 18:42:43'),
(94, 164, '2021-08-23 12:42:19'),
(96, 10, '2021-06-15 13:44:46'),
(96, 67, '2021-05-25 15:44:01'),
(96, 86, '2021-06-25 12:10:38'),
(99, 2, '2021-06-15 10:52:25'),
(99, 3, '2021-06-15 10:51:50'),
(99, 5, '2021-06-15 10:57:51'),
(99, 6, '2021-06-15 11:00:03'),
(99, 67, '2020-12-25 12:50:27'),
(99, 97, '2021-02-15 19:45:32'),
(99, 177, '2021-10-22 21:32:29'),
(106, 67, '2021-01-09 12:33:49'),
(106, 86, '2021-01-09 12:34:25'),
(106, 97, '2021-01-09 12:33:29'),
(109, 7, '2022-05-01 21:43:44'),
(112, 67, '2021-06-13 20:47:24'),
(112, 86, '2021-06-13 20:47:42'),
(112, 97, '2021-06-07 23:18:30'),
(113, 67, '2021-06-14 17:01:31'),
(116, 176, '2021-10-23 09:26:53'),
(116, 177, '2021-09-09 23:51:13'),
(118, 1, '2021-08-25 12:12:40'),
(118, 5, '2021-08-24 16:11:21'),
(118, 67, '2021-08-25 12:07:22'),
(118, 164, '2021-08-24 21:57:57'),
(118, 176, '2021-09-08 14:13:21'),
(121, 177, '2021-12-08 16:03:20'),
(124, 164, '2022-06-20 22:38:08'),
(124, 176, '2022-06-20 22:38:30');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `quiz_played`
--

CREATE TABLE `quiz_played` (
  `test_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `totalcorrect` int(11) NOT NULL,
  `finishing_date` datetime NOT NULL,
  `is_verified` int(11) NOT NULL,
  `score` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `quiz_played`
--

INSERT INTO `quiz_played` (`test_id`, `user_id`, `quiz_id`, `totalcorrect`, `finishing_date`, `is_verified`, `score`) VALUES
(238, 94, 97, 5, '2021-06-10 11:02:57', 0, 50),
(239, 15, 97, 7, '2021-06-10 11:18:06', 0, 66.66),
(240, 94, 86, 9, '2021-06-10 11:34:33', 1, 65),
(241, 94, 97, 10, '2021-06-10 11:49:20', 0, 100),
(269, 15, 97, 8, '2021-06-10 21:54:46', 0, 76.47),
(279, 94, 148, 8, '2021-06-12 22:55:49', 1, 100),
(280, 15, 148, 6, '2021-06-12 23:04:17', 1, 60),
(281, 112, 148, 8, '2021-06-12 23:36:08', 1, 100),
(282, 94, 148, 7, '2021-06-13 11:03:21', 0, 83.33),
(283, 99, 148, 7, '2021-06-13 12:06:39', 1, 81.81),
(284, 99, 148, 8, '2021-06-13 12:14:33', 0, 100),
(286, 106, 148, 8, '2021-06-13 17:49:41', 1, 100),
(292, 113, 148, 7, '2021-06-14 17:00:15', 1, 90),
(298, 109, 148, 8, '2021-06-15 01:09:25', 1, 100),
(304, 15, 86, 10, '2021-06-15 13:32:11', 1, 71.42),
(311, 96, 97, 9, '2021-06-15 16:48:31', 0, 88.88),
(313, 15, 148, 7, '2021-06-15 20:39:17', 0, 84.61),
(335, 15, 162, 18, '2021-06-16 19:10:39', 1, 90.62),
(354, 115, 148, 5, '2021-06-25 14:58:08', 0, 60),
(355, 115, 97, 4, '2021-06-25 15:01:40', 0, 37.5),
(390, 99, 97, 6, '2021-07-02 14:11:47', 0, 52.94),
(392, 101, 148, 2, '2021-07-02 18:41:34', 0, 22.22),
(407, 76, 162, 16, '2021-07-06 22:50:21', 0, 77.41),
(409, 15, 162, 20, '2021-07-07 16:48:40', 0, 100),
(411, 76, 162, 15, '2021-07-07 21:30:06', 0, 67.85),
(412, 15, 162, 19, '2021-07-08 18:21:45', 0, 96.66),
(414, 76, 162, 9, '2021-07-09 22:03:40', 0, 37.93),
(419, 76, 162, 15, '2021-07-14 22:11:40', 1, 64.28),
(423, 76, 162, 16, '2021-07-17 21:42:00', 0, 75),
(424, 15, 164, 12, '2021-07-19 17:07:32', 1, 76.92),
(425, 76, 164, 5, '2021-07-19 17:27:41', 0, 33.33),
(426, 15, 164, 13, '2021-07-19 22:51:05', 1, 86.95),
(427, 99, 164, 7, '2021-07-20 18:53:29', 1, 44.44),
(428, 76, 164, 8, '2021-07-20 21:23:14', 0, 52),
(429, 76, 164, 7, '2021-07-21 14:32:54', 0, 42.3),
(430, 76, 164, 8, '2021-07-21 14:36:43', 0, 58.33),
(431, 76, 164, 8, '2021-07-21 14:46:02', 0, 52.38),
(432, 76, 164, 9, '2021-07-23 21:35:08', 0, 47.82),
(433, 76, 164, 11, '2021-07-23 21:40:17', 0, 68),
(434, 76, 164, 14, '2021-07-23 21:45:10', 0, 86.95),
(435, 76, 164, 8, '2021-07-26 21:32:37', 0, 57.69),
(437, 76, 164, 4, '2021-07-27 22:11:05', 0, 25.92),
(438, 76, 164, 9, '2021-07-27 22:22:15', 0, 57.69),
(439, 76, 164, 7, '2021-07-30 23:59:26', 0, 42.3),
(440, 76, 164, 2, '2021-07-31 16:54:06', 0, 9.09),
(441, 76, 164, 4, '2021-07-31 16:57:35', 0, 26.92),
(442, 76, 164, 6, '2021-08-02 14:54:54', 0, 34.61),
(443, 15, 164, 12, '2021-08-04 00:25:37', 1, 84),
(444, 76, 164, 8, '2021-08-04 15:39:33', 0, 47.82),
(446, 76, 164, 4, '2021-08-04 17:32:57', 0, 23.8),
(447, 76, 164, 10, '2021-08-04 18:49:01', 0, 56.52),
(448, 76, 164, 10, '2021-08-04 19:00:06', 0, 57.69),
(449, 15, 164, 11, '2021-08-05 13:15:13', 1, 73.07),
(460, 15, 162, 19, '2021-08-08 21:02:46', 1, 93.1),
(463, 116, 148, 8, '2021-08-17 11:04:52', 0, 100),
(464, 94, 164, 11, '2021-08-19 10:25:23', 1, 70.83),
(465, 94, 162, 19, '2021-08-19 10:36:14', 1, 96.77),
(466, 15, 162, 19, '2021-08-22 22:09:56', 1, 93.33),
(467, 94, 164, 0, '2021-08-22 23:18:30', 1, 0),
(468, 94, 162, 20, '2021-08-22 23:31:30', 1, 100),
(473, 94, 164, 12, '2021-08-23 19:30:39', 0, 72),
(474, 94, 164, 1, '2021-08-23 19:43:05', 1, 4.76),
(475, 15, 164, 0, '2021-08-23 19:44:14', 1, 0),
(479, 118, 162, 19, '2021-08-24 16:10:15', 1, 96.55),
(482, 118, 148, 5, '2021-08-24 16:14:57', 0, 66.66),
(483, 118, 148, 8, '2021-08-24 16:16:51', 1, 100),
(485, 118, 97, 6, '2021-08-24 19:40:25', 0, 61.11),
(486, 118, 86, 12, '2021-08-24 19:42:54', 0, 90.47),
(488, 15, 164, 13, '2021-08-25 13:22:31', 1, 85.71),
(490, 118, 162, 20, '2021-08-26 09:57:19', 0, 100),
(507, 94, 164, 6, '2021-09-06 11:29:28', 1, 40),
(525, 94, 164, 0, '2021-09-06 14:33:09', 1, 0),
(526, 94, 176, 13, '2021-09-08 14:08:53', 1, 100),
(527, 15, 176, 13, '2021-09-08 14:12:45', 0, 100),
(532, 94, 177, 12, '2021-09-09 19:29:06', 0, 80.95),
(534, 116, 177, 14, '2021-09-09 23:53:37', 1, 90),
(535, 15, 177, 15, '2021-09-10 20:34:57', 1, 100),
(536, 15, 162, 0, '2021-09-19 14:28:22', 0, 0),
(537, 15, 176, 11, '2021-09-19 14:33:49', 1, 82.6),
(538, 15, 162, 0, '2021-09-19 22:30:15', 0, 0),
(540, 39, 177, 15, '2021-09-29 15:45:58', 1, 100),
(548, 94, 177, 14, '2021-10-23 09:04:36', 1, 89.47),
(550, 15, 162, 18, '2022-04-23 09:40:25', 0, 86.66),
(554, 15, 162, 19, '2022-05-04 14:15:02', 0, 93.33),
(557, 94, 164, 11, '2022-05-07 12:26:13', 1, 72),
(558, 116, 177, 10, '2022-05-16 19:50:28', 0, 57.89),
(563, 124, 176, 10, '2022-06-20 22:40:53', 1, 77.27),
(564, 124, 97, 7, '2022-06-20 22:43:17', 0, 72.22);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `quiz_question`
--

CREATE TABLE `quiz_question` (
  `id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `difficulty` int(11) NOT NULL,
  `question` varchar(255) NOT NULL,
  `ans1` varchar(155) NOT NULL,
  `ans2` varchar(155) NOT NULL,
  `ans3` varchar(155) NOT NULL,
  `ans4` varchar(155) NOT NULL,
  `username` varchar(30) NOT NULL,
  `is_verified` int(11) DEFAULT NULL,
  `is_active` tinyint(4) NOT NULL,
  `sending_time` datetime NOT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `verification_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `quiz_question`
--

INSERT INTO `quiz_question` (`id`, `quiz_id`, `difficulty`, `question`, `ans1`, `ans2`, `ans3`, `ans4`, `username`, `is_verified`, `is_active`, `sending_time`, `verified_by`, `verification_time`) VALUES
(110, 8, 2, 'Melyik csapat nyerte a Bajnokok Ligája 2006-2007-es sorozatát?', 'AC Milan', 'FC Liverpool', 'Manchester United', 'FC Barcelona', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(122, 5, 2, 'Mit jelent magyarul az irokéz canada szó, Kanada állam elnevezése?', 'falu', 'fagyos föld', 'rénszarvasok földje', 'sok tó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(126, 8, 1, 'Milyen nemzetiségű sportoló (volt) Alekszandr Tkacsov tornász?', 'orosz', 'belga', 'osztrák', 'olasz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(127, 8, 2, 'Ki volt az első magyar profi ökölvívó, aki a WBF világbajnoki címét címvédőként megvédte?', 'Kótai Mihály', 'Kovács István', 'Papp László', 'Erdei Zsolt', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(130, 10, 2, 'Az alábbiak közül melyik országban a legmagasabb az egy főre jutó kávéfogyasztás?', 'Finnország', 'Ausztria', 'India', 'Brazília', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(138, 5, 1, 'Melyik mű szereplője Maugli?', 'A dzsungel könyve', 'Az átváltozás', 'Nemo kapitány', 'Bacchánsnők', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(141, 8, 1, 'Magyarországon melyik neves labdarúgónkat választották az évszázad sportolójává?', 'Puskás Ferenc', 'Détári Lajos', 'Kocsis Sándor', 'Albert Flórián', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(144, 10, 1, 'Milyen eredetű étel a bográcsgulyás?', 'magyar', 'svájci', 'olasz', 'kínai', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(153, 5, 2, 'Ki írta: \"Hasadnak rendületlenül / Légy híve, oh magyar!\"?', 'Arany János', 'Vörösmarty Mihály', 'Petőfi Sándor', 'Karinthy Frigyes', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(154, 6, 1, 'Melyik mérték szolgál a tömeg mérésére?', 'kilogramm', 'fermi', 'magyar mérföld', 'lenz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(155, 6, 2, 'Ki definiálta a határozott integrált?', 'Bernhard Riemann', 'Sir Isaac Newton', 'Gottfried Wilhelm Leibniz', 'Bolyai János', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(156, 7, 1, 'Melyik NEM páros szerv?', 'szív', 'tüdő', 'vese', 'szem', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(157, 7, 2, 'A felsoroltak közül melyik rendelkezik a legtöbb kromoszómával?', 'haraszt', 'ecetmuslica', 'ember', 'közönséges csimpánz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(158, 8, 1, 'Az alábbiak közül melyik NEM tartozik egy labdarúgó játékvezető felszereléséhez?', 'kék lap', 'sárga lap', 'piros lap', 'síp', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(159, 8, 2, 'Ki szerezte az első gólt a német Bundesligában?', 'Timo Konietzka', 'Uli Hoeneß', 'Helmuth Rahn', 'Gerd Müller', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(160, 9, 1, 'Milyen állat a mesében Maja?', 'méhecske', 'szamár', 'kutya', 'delfin', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(161, 9, 2, 'Melyik filmben szerepel Marylin Monroe híres jelenete, amelyben a fehér ruháját fellibbenti egy légáramlat?', 'Hétévi vágyakozás', 'Aszfaltdzsungel', 'Van, aki forrón szereti', 'Szőkék előnyben', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(162, 10, 1, 'Mi NEM szükséges a gulyásleves elkészítéséhez?', 'karfiol', 'vöröshagyma', 'pirospaprika', 'olaj vagy zsír', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(163, 10, 2, 'Melyik étel 100 grammja tartalmazza a legkevesebb zsírt?', 'sertéscomb', 'mák', 'lazac', 'márványsajt', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(166, 2, 2, 'Melyik dán városban található a világhírű Legoland?', 'Billund', 'Koppenhága', 'Kolding', 'Aalborg', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(171, 5, 1, 'Mit csinál a tavaszi szél a népdal szerint?', 'vizet áraszt', 'társat választ', 'erősen fúj', 'táncot jár', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(172, 5, 2, 'Melyik jelentős amerikai regény szerzője NEM nő?', 'A hang és a téboly', 'Elfújta a szél', 'Tamás bátya kunyhója', 'Ne bántsátok a feketerigót!', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(173, 6, 1, 'Melyik növényt használják általánosan fogkrém összetevőjeként?', 'menta', 'dió', 'vadgesztenye', 'csalán', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(174, 6, 2, 'Mi a \"hardware\" szó eredeti jelentése?', 'vasáru', 'merevlemez', 'kemény portéka', 'külső bemeneti eszköz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(175, 7, 1, 'Mi a xenon vegyjele?', 'Xe', 'Se', 'Sr', 'Ca', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(176, 7, 2, 'Ki volt Új Tátrafüred és Magyarország első tüdőgyógyintézetének alapítója?', 'Szontágh Miklós', 'Markusovszky Lajos', 'Hőgyes Endre', 'Festetich Leó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(177, 8, 1, 'Mi a Manchester United csapatának beceneve?', 'Vörös Ördögök', 'Költők', 'Fecskék', 'Csülök', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(178, 8, 2, 'Melyik az sakkbábu, amellyel ha sakkot adunk és az ellenfél nem tudja kiütni, akkor a királlyal kell lépnie?', 'huszár', 'vezér', 'futó', 'bástya', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(179, 9, 1, 'Milyen állat Shrek barátja?', 'szamár', 'patkány', 'medve', 'kutya', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(180, 10, 1, 'Milyen szoknyát hordanak a skót férfiak?', 'kockás', 'csíkos', 'átlátszó', 'egyszínű', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(181, 10, 2, 'Melyik nemzetközi rövidítés jelöli a bruttó nemzeti termék közgazdasági fogalmat?', 'GNP', 'GDP', 'NNP', 'NDP', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(183, 2, 1, 'Az Országos Meteorológiai Szolgálat által kiadható veszélyjelzések közül melyik a legmagasabb fokozat?', 'piros riasztás', 'narancs riasztás', 'sárga riasztás', 'zöld riasztás', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(184, 2, 2, 'Ki fejlesztette ki az Enigma nevű forgótárcsás, elektromechanikus rejtjelező készüléket?', 'Arthur Scherbius', 'Radó Sándor', 'Ernst Werner von Siemens', 'Alan Mathison Turing', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(185, 3, 1, 'Az alábbiak közül melyik Párizs repülőtere?', 'Le Bourget', 'Ruzyne', 'Heathrow', 'Domogyedovo', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(186, 3, 2, 'Hogy hívták Rippl-Rónai József francia származású feleségét?', 'Lazarine', 'Jacquline', 'Odette', 'Geraldine', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(187, 4, 1, 'Ki kapott orvosi Nobel-díjat?', 'Szent-Györgyi Albert', 'Albert Schweitzer', 'Thomas Mann', 'Menachem Begin', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(188, 5, 1, 'Hogy hívják Kanga kicsinyét a Micimackó című műben?', 'Zsebibaba', 'Füles', 'Böbe', 'Malacka', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(189, 6, 1, 'Ki kapott orvosi Nobel-díjat?', 'Szent-Györgyi Albert', 'Oláh György', 'Harsányi János', 'Gábor Dénes', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(190, 6, 2, 'Melyik autógyáros saját találmánya volt a turbófeltöltő?', 'Louis Renault', 'Ferdinand Porsche', 'Karl Benz', 'Enzo Ferrari', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(191, 7, 1, 'Mi a talaj?', 'a földfelszín legfelső termékeny rétege', 'újraképződött szerves anyag', 'gyökértípus', 'szilikát ásvány', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(192, 7, 2, 'Melyik nemesfém a legdrágább az alábbiak közül?', 'ródium', 'arany', 'ezüst', 'platina', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(193, 8, 1, 'Melyik sportágban lehet zsákolni?', 'kosárlabda', 'foci', 'röplabda', 'kézilabda', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(194, 8, 2, 'Ki nyerte a női teniszezőknél a legtöbb egyéni Grand Slam-tornát 2009-ig?', 'Margareth Smith Court', 'Steffi Graf', 'Martina Navratilova', 'Venus Williams', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(195, 9, 1, 'Melyik mese szereplője Pumba?', 'Az oroszlánkirály', '101 kiskutya', 'Asterix, a gall', 'Mirr-Murr, a kandúr', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(196, 9, 2, 'Melyik film zenéjét szerezte Philip Glass?', 'Kundun', 'Bombajó bokszoló', 'Wyatt Earp', 'Star Trek - Insurrection', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(197, 10, 1, 'Mik szerepelnek a kínai horoszkópban?', 'állatok', 'növények', 'tárgyak', 'emberek', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(198, 10, 2, 'Melyik étel 100 grammja tartalmazza a legtöbb fehérjét?', 'napraforgómag', 'fehér kenyér', 'sertéscsülök', 'tehéntej (2,8%)', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(199, 1, 1, 'Ki festette a Mona Lisát?', 'Leonardo da Vinci', 'Giorgio Vasari', 'Michelangelo Buonarroti', 'Raffaello Santi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(200, 1, 2, 'Melyik díj összege (pénzbeli értéke) a magasabb?', 'Templeton-díj', 'Nobel-díj', 'Oscar-díj', 'Crafoord-díj', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(201, 2, 1, 'Melyik modellt gyártja az Audi?', 'A4', 'S60', 'C-Klasse (W 202)', 'Dedra', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(202, 2, 2, 'Mi a közös Jimmy Carterben, Mihail Gorbacsovban, Bill Clintonban és Barack Obamában?', 'Grammy-díjazottak', 'legalább egyszer újraválasztották őket', 'Nobel-békedíjasok', 'van legalább egy orosz felmenőjük', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(203, 3, 1, 'Melyik városban található nevezetes híd a Csing Ma híd?', 'Hongkong', 'Shimonoszeki', 'Vancouver', 'Charleston', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(204, 3, 2, 'Milyen díjat adnak át évente az Anna-bálon Balatonfüreden?', 'Kiss Ernő díj', 'Jókai díj', 'Anna-Krisztina díj', 'Kisfaludy díj', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(205, 4, 1, 'Mi lett oda Mátyás király halálával a szólás szerint?', 'az igazság', 'az ész', 'az ország', 'a sereg', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(206, 4, 2, 'Ki jegyezte le szemtanúként a tatárjárás eseményeit?', 'Rogerius mester', 'Anonymus', 'Julianus barát', 'Galeotto Marzio', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(207, 5, 1, 'Melyik NEM személyes névmás?', 'megannyi', 'mi', 'ti', 'ő', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(208, 6, 2, 'Melyik elem fordul elő leggyakrabban a Földön az alábbiak közül (atom %-ban)?', 'kén', 'szén', 'nitrogén', 'fluor', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(209, 7, 1, 'Mi a nátrium-klorid hétköznapi elnevezése?', 'konyhasó', 'tinkal', 'fixírsó', 'alabástrom', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(210, 7, 2, 'Az aranyat melyik fémmel ötvözve készítenek fehéraranyat?', 'Palládium', 'Sárgaréz', 'Platina', 'Cink', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(211, 8, 1, 'Melyik sportág jeles képviselője Dzsudzsák Balázs?', 'labdarúgás', 'tenisz', 'szinkronúszás', 'jégkorong', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(212, 8, 2, 'Melyik magyar tenyésztésű versenyló nyerte meg az Epsomi Derbyt?', 'Kisbér', 'Kincsem', 'Imperiál', 'Api', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(213, 9, 1, 'Ki volt a Republic frontembere?', 'Bódi \"Cipő\" László', 'Ferenczi György', 'Baronits Zsolt', 'Waszlavik \"Gazember\" László', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(214, 9, 2, 'Melyik rendező forgatta újra a Psycho című filmet 1998-ban?', 'ifj. Gus Van Sant', 'James Cameron', 'David Fincher', 'Stephen Daldry', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(215, 10, 1, 'Mi Garfield kedvenc étele?', 'Lasagne', 'Vajas kifli', 'Tejberizs', 'Szalonna', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(216, 10, 2, 'Mi látható I. István király fején a 10000 forintos bankjegyen?', 'III. Béla halotti koronája', 'a Szent Korona', 'semmi', 'babérkoszorú', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(217, 1, 1, 'Melyik festő született legrégebben az alábbiak közül?', 'Leonardo da Vinci', 'Anthonis van Dyck', 'Frans Snyders', 'Frans Hals', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(218, 1, 2, 'Melyik festő alkotása a Madonna a rózsalugasban című kép?', 'Martin Schongauer', 'Andrea Mantegna', 'Jean-Louis-André-Théodore Géricault', 'Paolo Veronese', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(219, 2, 1, 'Mit ünnepelünk karácsonykor?', 'Jézus Krisztus születését', 'Jézus Krisztus feltámadását', 'Jézus Krisztus keresztre feszítését', 'Jézus Krisztus keresztútját', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(220, 2, 2, 'Milyen fából készülnek hagyományosan a kubai szivarok csomagolására használt szivarládák?', 'cedrela', 'ében', 'cédrus', 'szantál', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(221, 3, 1, 'Az alábbiak közül melyik nevezetesség található Párizsban?', 'Eiffel-torony', 'Westminster-apátság', 'Mozart-emlékmúzeum', 'Szent György-várkastély', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(222, 3, 2, 'Melyik ország területén NEM halad át az Egyenlítő?', 'Egyenlítői-Guinea', 'Brazília', 'Ecuador', 'Zaire', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(223, 4, 1, 'Hogy hívták Mátyás király állandó zsoldoshadseregének magját?', 'Fekete Sereg', 'Ezüst sereg', 'Arany sereg', 'Vas sereg', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(224, 4, 2, 'Melyik pápa építtette álma nyomán a római Santa Maria Maggiore bazilikát?', 'Liberius', 'Szent Péter', 'I. Marinus', 'VI. Pius', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(225, 5, 1, 'Mit szeret Micimackó?', 'mézet', 'répát', 'káposztát', 'málnát', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(226, 5, 2, 'Ki írta a Bezzeg a Töhötöm! című könyvet?', 'Berkes Péter', 'Tihanyi Tamás', 'Móra Ferenc', 'Lázár Ervin', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(227, 6, 2, 'Minek az ókori őse az aeolipil, más néven Hérón-labda?', 'gőzgép', 'villámhárító', 'villanykörte', 'hőlégbalon', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(228, 7, 1, 'Mely élelmiszerekkel fedezheti az ember a C-vitamin-szükségletét?', 'friss zöldségek, gyümölcsök', 'tengeri halak', 'szárnyasmáj', 'sertéshús', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(229, 7, 2, 'Melyik a Magyarországon élő legkisebb madárfaj?', 'tüzesfejű királyka', 'kormos légykapó', 'ökörszem', 'süvöltő', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(230, 8, 1, 'Melyik sportághoz tartoznak az alábbi szavak: gyors-, hát-, mell- ?', 'úszás', 'kosárlabda', 'kézilabda', 'kajak', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(231, 8, 2, 'Melyik országból származik Remy Bonjasky kickboxos, háromszoros K1-világbajnok?', 'Suriname', 'Lengyelország', 'Ghána', 'Nigéria', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(232, 9, 1, 'Mi a kis hableány neve?', 'Ariel', 'Persil', 'Tide', 'Mirafresh', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(233, 10, 1, 'Milyen gyümölccsel készül a hawaii módra készülő húsétel?', 'ananásszal', 'kivivel', 'banánnal', 'datolyával', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(234, 10, 2, 'Melyik ország jegyezte be az Európai Unióban saját termékeként a kürtőskalácsot?', 'Szlovákia', 'Magyarország', 'Románia', 'Szlovénia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(235, 1, 2, 'Melyik múzeumból loptak el 1990-ben 13 képet, köztük Rembrandt és Manet műveit, melyek máig sem kerültek elő?', 'Isabella Stewart Gardner Museum, Boston', 'Louvre, Párizs', 'Szépművészeti Múzeum, Budapest', 'Munch Museum, Oslo', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(236, 2, 1, 'Melyik zeneszerzőről nevezték el a ferihegyi repülőteret?', 'Liszt Ferenc', 'Erkel Ferenc', 'Bartók Béla', 'Kodály Zoltán', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(237, 3, 1, 'Melyik a leghosszabb az alábbiak közül?', 'a Föld egyenlítői sugara', 'teljes magyar határszakasz', 'Malaka-szoros', 'Bajkál-tó hossza', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(238, 3, 2, 'Melyik Florida legnépesebb városa?', 'Jacksonville', 'Miami', 'Tampa', 'Orlando', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(239, 4, 1, 'Melyik városban ülésezik a Bundestag?', 'Berlin', 'London', 'Helsinki', 'Varsó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(240, 5, 1, 'Mi a kalamajka?', 'zűrzavar, kellemetlenség', 'evőeszköz', 'kismajom becézve', 'vadvirág', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(241, 6, 1, 'Mi a frekvencia mértékegysége?', 'hertz', 'henry', 'kandela', 'siemens', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(242, 7, 1, 'Melyik részét fogyasztjuk az uborkának?', 'termés', 'gyökér', 'szár', 'levél', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(243, 7, 2, 'A tudomány mai állása szerint melyik a legidősebb, a Földön ma is élő élőlény?', 'a neptunfű', 'a vasfa', 'a vörösfenyő', 'a Coli baktérium egyik válfaja', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(244, 8, 1, 'Kinek van a legtöbb olimpiai aranyérme az alábbiak közül?', 'Egerszegi Krisztina', 'Nagy Tímea', 'Repka Attila', 'Kádárné Csák Ibolya', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(245, 8, 2, 'Melyik ország nyerte a jégkorongbajnokságot a 2006-os téli olimpián?', 'Svédország', 'Kanada', 'Finnország', 'Oroszország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(246, 9, 1, 'Melyik rajzfilmfigura nem kutya?', 'Vuk', 'Snoopy', 'Goofy', 'Plútó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(247, 9, 2, 'Melyik együttes albuma volt a Rubycon (1975)?', 'Tangerine Dream', 'Pink Floyd', 'Yes', 'Genesis', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(248, 10, 2, 'Mi a neve a híres müncheni Oktoberfest erre az alkalomra készített sörének?', 'Wiesnbier', 'Festbier', 'Kerzenbier', 'Oktoberbier', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(249, 1, 1, 'Melyik tánc magyar eredetű?', 'legényes', 'forlana', 'mazurka', 'biul', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(250, 1, 2, 'Melyik itáliai művész vált ismertté az eredeti családnevén?', 'Lotto', 'Caravaggio', 'Tintoretto', 'Botticelli', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(251, 4, 1, 'Melyik miniszterelnökünk lépett legkésőbb hivatalba?', 'Orbán Viktor', 'Rákosi Mátyás', 'Lukács László', 'Grósz Károly', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(252, 4, 2, 'Melyik évszakban rendezték meg a Saturnalia ünnepét az ókori Rómában?', 'tél', 'tavasz', 'nyár', 'ősz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(253, 5, 1, 'Kinek a műve a Szózat?', 'Vörösmarty Mihály', 'Áprily Lajos', 'Márai Sándor', 'Örkény István', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(254, 5, 2, 'Ki a szerzője a Finnugor vámpír és a Kommunista Monte Cristo című regényeknek?', 'Szécsi Noémi', 'Leslie L. Lawrence', 'Döbrentei Kornél', 'Vass Virág', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(255, 6, 2, 'Melyik országé a televíziós csatornák által használt .tv domain?', 'Tuvalu', 'nem tartozik egyetlen országhoz sem', 'Vanuatu', 'Tajvan', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(370, 8, 1, 'Melyik férfi együttes nyerte meg a vízilabda olimpiai bajnokságot 1964-ben?', 'Magyarország', 'Jugoszlávia', 'Németország', 'Olaszország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(371, 8, 2, 'Ki az argentin labdarúgó-válogatott gólrekordere?', 'Gabriel Batistuta', 'Hernán Crespo', 'Carlos Tévez', 'Diego Maradona', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(373, 10, 1, 'Melyik cukorkát nevezik a \"torok kéményseprőjének\"?', 'negró', 'gyógypemetefű-cukorka', 'franciadrazsé', 'dunakavics', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(374, 10, 2, 'Melyik étel 100 grammja tartalmazza a legtöbb szénhidrátot?', 'padlizsán', 'parmezán sajt', 'harcsa', 'tojás', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(379, 5, 2, 'Hogy hívták Zrínyi Miklós kamarását, aki Szigetvár 1566-os ostroma után életben maradt és megírta az ostrom történetét?', 'Ferenac Črnko', 'Horváth Stančić Márk', 'Brankovics György', 'Mekcsey István', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(382, 8, 1, 'Melyik futballcsapat városa Athén?', 'Panathinaikos', 'FC Sion', 'FK Borac', 'Beşiktaş J.K.', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(385, 10, 2, 'Mi a ragadványneve Warren E. Buffetnek, az ismert milliárdos befektetőnek?', 'az omahai bölcs', 'a templom egere', 'a kígyó', 'az aranykezű', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(391, 5, 1, 'Mit jelent az open szó?', 'nyitva', 'zárva', 'csukva', 'ajtó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(392, 5, 2, 'Milyen nemzetiségű az 1967-ben irodalmi Nobel-díjat kapott Miguel Ángel Asturias?', 'guatemalai', 'chilei', 'kolumbiai', 'mexikói', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(394, 8, 1, 'Melyik versenyló nyert meg 54 versenyből 54-et?', 'Kincsem', 'Imperial', 'Sardenzal', 'Rodrigo', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(396, 10, 1, 'Az alábbiak közül melyikből készítenek pálinkát?', 'cefre', 'cafat', 'cafrang', 'cafka', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(397, 10, 2, 'Melyik étel 100 grammja tartalmazza a legkevesebb szénhidrátot?', 'edámi sajt', 'napraforgómag', 'karalábé', 'rizs', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(402, 5, 1, 'Melyik szereplő egy medve az alábbiak közül?', 'Micimackó', 'Killi', 'Mihály', 'Tu-Tu', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(404, 6, 2, 'Ki NEM kémikus volt az alábbiak közül?', 'Békésy György', 'Erdey-Grúz Tibor', 'Martinovics Ignác', 'Görgey Artúr', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(406, 7, 2, 'Melyik anyag oxidja a legpuhább?', 'gyémánt', 'alumínium', 'réz', 'vas', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(407, 8, 1, 'Melyik futballcsapat játszik az angol bajnokságban?', 'Arsenal', 'SL Benfica', 'RSC Anderlecht', 'Boavista FC', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(408, 8, 2, 'Ki volt az első magyar labdarúgó, aki mesterhármast ért el a német Bundesligában?', 'Szalai Ádám', 'Puskás Ferenc', 'Détári Lajos', 'Dárdai Pál', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(409, 9, 2, 'Melyik filmben játszotta saját egykori tornatanárát Koltai Róbert?', 'Pókfoci', 'Hannibál tanár úr', 'Magasiskola', 'Ámbár tanár úr', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(410, 10, 1, 'Melyik italnak van térfogatszázalék szerint a legnagyobb alkoholtartalma?', 'vodka', 'sör', 'bor', 'pezsgő', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(411, 10, 2, 'Melyik volt Kossuth Lajos külföldön kiadott politikai folyóirata?', 'Negyvenkilencz', 'Negyvennyolc', 'Szabadság', 'Emigrációban', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(418, 5, 1, 'Hogyan folytatódik Petőfi Sándor verssora: \"Talpra magyar, hí ...!\"?', 'a haza', 'az idő', 'a csata', 'az óra', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(419, 5, 2, 'Milyen nemzetiségű volt Nyikolaj Vasziljevics Gogol?', 'ukrán', 'orosz', 'szlovák', 'belarusz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(420, 6, 1, 'Melyik mérték szolgál az idő mérésére?', 'óra', 'Réaumur-fok', 'farad', 'inch', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(421, 6, 2, 'Mi a neve az első európai bolygóközi űrszondának?', 'Giotto', 'Mariner', 'Viking', 'Voyager', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(422, 7, 1, 'Melyik részét fogyasztjuk a dinnyének?', 'termés', 'szár', 'levél', 'gyökér', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(423, 7, 2, 'Melyik évszakban virágzik Magyarországon az illatos tündérfa?', 'tél', 'nyár', 'ősz', 'tavasz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(424, 9, 1, 'Melyik meseszereplő kedvenc eledele a spenót?', 'Popeye', 'Spongyabob', 'Micimackó', 'Süsü, a sárkány', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(425, 9, 2, 'Ki (volt) Donald kacsa megrajzolója?', 'Carl Barks', 'Walt Disney', 'Ed Benedict', 'Valker István', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(428, 2, 1, 'Mire szolgál a GPS?', 'helyzetmeghatározásra', 'rádiózásra', 'idő meghatározására', 'térfogatmérésre', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(429, 2, 2, 'Kinek az arcképe látható az amerikai 20 dolláros bankjegyen?', 'Andrew Jackson', 'George Washington', 'Herbert C. Hoover', 'Benjamin Franklin', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(430, 3, 1, 'Az alábbi fővárosok közül melyik van legtávolabb légvonalban Budapesttől?', 'Madrid', 'Pozsony', 'Brüsszel', 'Zágráb', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(431, 3, 2, 'Mi található az Osztrák Köztársaság címerállatának karmaiban?', 'sarló és kalapács', 'jogar és országalma', 'kard és kereszt', 'babérkoszorú', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(433, 5, 1, 'Ki NEM ismerőse Micimackónak?', 'Maugli', 'Malacka', 'Zsebibaba', 'Bagoly', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(434, 5, 2, 'Melyik regényt írta az Állat az emberben című mű szerzője?', 'Nana', 'Állati elmék', 'Bűn és bűnhődés', 'Doktor Dolittle és az állatok', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(435, 6, 1, 'Melyik mérték szolgál a hosszúság mérésére?', 'méter', 'lumen', 'gray', '(bécsi) mérő', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(436, 7, 1, 'Melyik családba tartozik a görögdinnye?', 'tökfélék', 'mályvafélék', 'pillangósvirágúak', 'tátogatók', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(437, 7, 2, 'Melyiknek van a legtöbb kromoszómája az alábbiak közül?', 'egy harasztnak', 'egy embernek', 'egy lónak', 'egy burgonyának', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(438, 8, 1, 'Az alábbiak közül melyik sportoló nyert orosz színekben olimpiai aranyérmet?', 'Sztanyiszlav Pozdnyakov', 'Heike Drechsler', 'Pietro Mennea', 'Barbara Krause', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(439, 8, 2, 'Az alábbiak közül melyik sportág nemzetközi sportszövetsége rendelkezik a legtöbb taggal?', 'röplabda', 'labdarúgás', 'kosárlabda', 'vizilabda', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(440, 9, 1, 'Ki REX a Rex felügyelő című tévésorozatban?', 'kutya', 'nyomozó', 'a rendőrség központi neve', 'mesterlövész', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(441, 10, 2, 'Milyen pereme volt az 1971-től gyártott 10 forintos érmének?', 'falevél motívumokkal díszített', 'szaggatottan recés', 'sima', 'feiratos: \"Munka a Nemzeti Jólét Alapja\"', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(443, 3, 1, 'Melyik kontinensen található Kína?', 'Ázsia', 'Afrika', 'Amerika', 'Ausztrália és Óceánia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(444, 3, 2, 'Melyik szóból ered Füred neve?', 'fürj', 'fürdő', 'fürt', 'füge', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(445, 4, 1, 'Melyik ókori város volt a mai Izrael területén?', 'Názáret', 'Petra', 'Ugarit', 'Lagas', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(446, 4, 2, 'Melyik ország himnusza volt a \"Hej, sloveni\"?', 'Jugoszlávia', 'Szlovénia', 'Szlovákia', 'Románia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(447, 5, 1, 'Hogy folytatódik a mondás: \"Többet ésszel, mint...\"?', 'erővel', 'pénzzel', 'tűzzel', 'vízzel', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(448, 5, 2, 'Ki írta A Nagy Medve fiai című könyvet?', 'Liselotte Welskopf-Henrich', 'James Fenimore Cooper', 'Karl May', 'Dékány András', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(449, 6, 1, 'Melyik mérték szolgál a hosszúság mérésére?', 'tengeri mérföld', 'bit', 'slug', 'rem', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(450, 6, 2, 'Mit jelent eredetileg az elektron szó?', 'borostyán', 'parányi', 'negatív', 'áram', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(451, 7, 1, 'Melyik rendbe tartozik a közönséges bükk?', 'bükkfavirágúak', 'ajakosvirágúak', 'olajfavirágúak', 'kaprivirágúak', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(452, 7, 2, 'Milyen fa a bibliai sittimfa, melyből többek között a frigyláda is készülhetett?', 'akácia', 'tölgy', 'cédrus', 'ébenfa', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(453, 8, 2, 'Melyik külföldi csapattal játszotta első, nem hivatalos mérkőzését a magyar labdarúgó válogatott 1901-ben?', 'Richmond AFC', 'Bécs válogatottja', 'PNIŠK Zágráb', 'Bohémia és Morvaország válogatottja', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(454, 9, 1, 'Hogy hívják a Shrek női főszereplőjét?', 'Fiona', 'Ariel', 'Hófehérke', 'Anasztázia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(455, 10, 1, 'Milyen eredetű sütemény a Rigó Jancsi?', 'magyar', 'angol', 'arab', 'kínai', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(456, 10, 2, 'Hogy hívják az egyetlen drágakővel díszített gyűrűt?', 'szoliter', 'monolit', 'brilliáns', 'diadém', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(457, 1, 1, 'Melyik városban található a Szépművészeti Múzeum?', 'Budapest', 'Keszthely', 'Sopron', 'Kecskemét', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(458, 1, 2, 'Melyik városban van a Cornell Egyetem központja?', 'Ithaca', 'Washington', 'Dallas', 'Vancouver', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(459, 2, 1, 'Mit csinál a pedikűrös?', 'lábat ápol', 'korcsolyázik', 'kórusban énekel', 'pénzt vált', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(460, 4, 1, 'Melyik személy szokásos megnevezése: \"Isten ostora\"?', 'Attila', 'Bonaparte Napóleon', 'Mohamed Ali', 'Timur Lenk', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(461, 5, 1, 'Milyen állat a Fekete István művében szereplő Hu?', 'bagoly', 'medve', 'kenguru', 'tigris', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(462, 6, 1, 'Milyen nemzetiségű volt Jedlik Ányos, a szódavíz feltalálója?', 'magyar', 'belga', 'francia', 'orosz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(463, 6, 2, 'Melyik az éjszakai égbolt legfényesebb csillaga?', 'Szíriusz', 'Esthajnalcsillag', 'Sarkcsillag', 'Vega', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(464, 7, 1, 'Melyik növény virága fehér?', 'hóvirág', 'közönséges mézontófű', 'erdei gyömbérgyökér', 'takarmánylucerna', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(465, 8, 2, 'Ki nyerte a Forma-1-es világbajnokságot 2009-ben?', 'Jenson Button', 'Sebastian Vettel', 'Lewis Hamilton', 'Kimi Raikkönen', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(466, 9, 1, 'Ki színész(-nő) az alábbiak közül?', 'Schell Judit', 'Németh Ákos', 'Zalán Tibor', 'Khell Zsolt', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(467, 9, 2, 'Melyik filmet NEM Roman Polanski rendezte?', 'Puszta formalitás (1994)', 'Szellemíró (2010)', 'A zongorista (2002)', 'Iszonyat (1965)', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(468, 10, 1, 'A spenót melyik részét fogyasztjuk?', 'levelét', 'gyökerét', 'virágát', 'termését', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(469, 10, 2, 'Melyik étel 100 grammja tartalmazza a legkevesebb fehérjét?', 'tehéntej (2,8%)', 'dió', 'fehér kenyér', 'barna kenyér', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(470, 1, 1, 'Melyik városban található az Állami Operaház?', 'Budapest', 'Ráckeve', 'Keszthely', 'Debrecen', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(471, 1, 2, 'Melyik mű ábrázolja a legtöbb emberalakot?', 'a magyar Szent Korona', 'Leonardo da Vinci: Az utolsó vacsora', 'Auguste Renoir: Evezősök reggelije', 'Jacques-Louis David: Horatiusok esküje', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(472, 2, 1, 'Melyik ország autójelzése a DK?', 'Dánia', 'Irán', 'Algéria', 'Lengyelország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(473, 3, 2, 'Mi szerepel Gyöngyös címerében?', 'farkas', 'szőlőfürt', 'szőlőlevél', 'hegy', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(474, 4, 1, 'Melyik uralkodóház tagja volt II. (Vak) Béla?', 'Árpád-ház', 'Wittelsbach-ház', 'Anjou-ház', 'Přemysl-ház', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(475, 4, 2, 'Mi volt a római kori (latin) neve Salzburgnak?', 'Juvavum', 'Vindobona', 'Augusta Treverorum', 'Salamantica', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(476, 5, 2, 'Ki írt 1849-ben verset Magyarországhoz címmel az alábbiak közül?', 'Henrik Ibsen', 'Petőfi Sándor', 'Alekszandr Szergejevics Puskin', 'Heinrich Heine', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(477, 6, 1, 'Mit mér a méter?', 'hosszúságot', 'térfogatot', 'sebességet', 'területet', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(478, 7, 1, 'Melyik egy körte fajta neve?', 'Vilmos', 'Mihály', 'Sándor', 'Ferenc', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(479, 7, 2, 'Melyik a legnagyobb barna medve?', 'kodiak medve', 'grizzly medve', 'európai barna medve', 'kamcsatkai medve', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(480, 8, 2, 'Mi a keresztneve \"Magic\" Johnsonnak, az egykori híres NBA játékosnak?', 'Earvin', 'Michael', 'Scott', 'Ray', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(481, 9, 2, 'Melyik együttes száma az 1974-ben megjelent Fox on the Run?', 'Sweet', 'Smokie', 'Queen', 'Led Zeppelin', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(482, 10, 1, 'Melyik sütemény készül sütés nélkül?', 'kókuszgolyó', 'linzer', 'muffin', 'képviselőfánk', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(483, 1, 1, 'Ki szerezte A négy évszak című hegedűverseny-sorozatot?', 'Antonio Vivaldi', 'Carl Orff', 'Gustav Mahler', 'Georges Bizet', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(484, 2, 1, 'Az alábbiak közül melyik hírügynökség működik Magyarországon?', 'MTI', 'AIN', 'VNA', 'TT', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(485, 2, 2, 'Mi volt Samuel Morse, a távíró feltalálója eredeti foglalkozása?', 'festő', 'banktisztviselő', 'orvos', 'vaskereskedő', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(486, 3, 1, 'Mi Japán pénzneme?', 'jen', 'tolar', 'font', 'lek', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(487, 3, 2, 'Melyik országban találhatóak a világörökség részeként számon tartott Longmen-barlangok?', 'Kína', 'Nagy-Britannia', 'Ausztrália', 'Franciaország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(488, 4, 2, 'Ki volt Zeusz első felesége?', 'Métisz', 'Aphrodité', 'Héra', 'Pallasz Athéné', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(489, 5, 1, 'Melyik szereplő egy róka az alábbiak közül?', 'Vuk', 'Pumbaa', 'Csámpás', 'Szi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(490, 6, 1, 'Melyik hosszúságmérték?', 'arasz', 'gray', 'mol', 'négyszögöl', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(491, 6, 2, 'Mi a jele a Boltzmann-állandónak?', 'k', 'b', 'n', 't', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(492, 7, 1, 'Milyen gyümölcs a Vilmos?', 'körte', 'mandula', 'gesztenye', 'szamóca', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(493, 7, 2, 'A felsoroltak közül mit nevezünk más néven anyósülésnek?', 'egy kaktuszfajt (Echinocactus grusonii)', 'villamosszéket', 'autóban a vezető mögötti ülést', 'kispadot falusi utcán a kapu mellett', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(494, 8, 1, 'Melyik magyar híresség volt egyben olimpiai bajnok is?', 'Hajós Alfréd', 'Czeizel Endre', 'József Attila', 'Laborfalvi Róza', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(495, 9, 1, 'Milyen állat Shrek legjobb barátja?', 'szamár', 'pulyka', 'sárkány', 'egér', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(496, 9, 2, 'Melyik képregényt rajzolja Bill Watterson?', 'Kázmér és Huba', 'Snoopy', 'Garfield', 'Pókember', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(497, 1, 1, 'Mi Dobó Kata foglalkozása?', 'színész', 'író', 'költő', 'lakberendező', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(498, 1, 2, 'Melyik operett szerzője Kálmán Imre?', 'Az obsitos', 'Nebáncsvirág', 'A cigánybáró', 'Bál a Savoyban', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(499, 2, 1, 'Mi a Tippmix?', 'sportfogadás', 'társasjáték', 'tv sorozat', 'számítógép márka', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(500, 2, 2, 'Hol található a világ legforgalmasabb repülőtere?', 'Atlanta', 'Chicago', 'London', 'New York', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(501, 3, 1, 'Az alábbiak közül melyik szoros köti össze a Bering-tengert és a Csukcs-tengert?', 'Bering-szoros', 'Torres-szoros', 'Tatár-szoros', 'Szunda-szoros', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(502, 4, 1, 'Melyik rendet alapította Guzman Domonkos?', 'dominikánus rend', 'karthauzi rend', 'templomos lovagrend', 'ciszterci rend', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(503, 6, 1, 'Melyik csillagkép latin neve a Leo?', 'Oroszlán', 'Sárkány', 'Szextáns', 'Kis Kutya', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(504, 7, 1, 'Ki vagy mi a kurkuma?', 'fűszernövény', 'hadnagy', 'fegyver', 'halfajta', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(505, 8, 1, 'Milyen nemzetiségű sportoló (volt) Dmitrij Szvatkovszkij öttusázó?', 'orosz', 'ír', 'szlovák', 'litván', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(506, 9, 1, 'Hogy hívják a Shrek című animációs filmben a királylányt?', 'Fiona', 'Alice', 'Katie', 'Scarlette', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(507, 10, 1, 'Melyik pizzán találhatunk ananászt?', 'hawaii', 'marinara', 'salami', 'quattro formaggi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(508, 10, 2, 'Melyik étel 100 grammja tartalmazza a legkevesebb fehérjét?', 'márványsajt', 'marhalapocka', 'csirkemellfilé', 'mák', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(509, 1, 1, 'Milyen típusú hangszer a nagydob?', 'ütős', 'pengetős', 'fafúvós', 'rézfúvós', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(510, 2, 1, 'Az alábbiak közül melyik ország hírügynöksége az IRNA?', 'Irán', 'Dánia', 'Szlovénia', 'Svédország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(511, 3, 2, 'Melyik országban található a Rio-Antirio híd?', 'Görögországban', 'Törökországban', 'Brazíliában', 'Spanyolországban', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(626, 8, 2, 'Melyik futballcsapat játszik a szerb bajnokságban?', 'Habitfarm Javor', 'NK Varteks', 'Tottenham Hotspur', 'FK Sileks Kratovo', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(635, 8, 1, 'Melyik NEM küzdősport?', 'zumba', 'vívás', 'karate', 'cselgáncs', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(640, 5, 1, 'Mi volt a kocsmáros régies elnevezése?', 'csapláros', 'kövész', 'takács', 'tapacíros', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(643, 10, 2, 'Melyik étel 100 grammja tartalmazza a legtöbb szénhidrátot?', 'cékla', 'edámi sajt', 'marhalapocka', 'kaviár', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(650, 8, 2, 'Ki volt az a játékos, aki a Real Madrid történetében a legtöbb, 12 bajnoki címmel rendelkezik?', 'Francisco Gento', 'Puskás Ferenc', 'Raúl Gonzalez', 'Emilio Butragueno', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(652, 10, 1, 'Az alábbiak közül melyik olasz nemzeti étel?', 'lasagne', 'hachée', 'szusi', 'bigos', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(653, 10, 2, 'Melyik étel 100 grammja tartalmazza a legtöbb fehérjét?', 'dió', 'tojás', 'kecsketej', 'földieper', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(659, 5, 1, 'Melyik nyelvcsalád tagja a szlovák nyelv?', 'szláv', 'hámi', 'mongol', 'sémi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(660, 6, 1, 'Az alábbiak közül melyik tudományág foglalkozik állattannal?', 'zoológia', 'mineralógia', 'kozmológia', 'krisztológia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(661, 7, 2, 'Az alábbiak közül melyik állat élőhelye Dél-Amerika?', 'zsírfecske', 'babirussza', 'prérikutya', 'szervál', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(662, 9, 1, 'Melyik mese szereplője Kag?', 'Vuk', 'A nagy ho-ho-ho-horgász', 'South Park', 'Dumbó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(663, 10, 1, 'Melyik egy étel elnevezése?', 'disznósajt', 'marhasajt', 'libasajt', 'kakassajt', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(668, 5, 2, 'Mi volt az eredeti neve Méhes Györgynek, a székelyudvarhelyi születésű Kossuth-díjas írónak?', 'Nagy Elek', 'Mohr György', 'Balogh Elemér', 'Steinbauer Alfréd', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(669, 7, 2, 'Melyik főosztályba tartozik a kockás sikló?', 'négylábúak', 'kétéltűek', 'emlősszerűek', 'felemásgyíkok', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(670, 8, 1, 'Milyen nemzetiségű sportoló (volt) Szergej Beloglazov birkózó?', 'orosz', 'svájci', 'észt', 'portugál', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(671, 10, 2, 'Melyik ország találmánya a nyakkendő?', 'Horvátország', 'Nagy-Britannia', 'Németország', 'Szerbia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(672, 2, 1, 'Melyik az az autómárka, melynek logója 4 karika egymásba fonódva?', 'Audi', 'BMW', 'Ford', 'Citroen', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(675, 5, 2, 'Ki írta a Tündérvölgy című regényt?', 'Kukorelly Endre', 'Nádas Péter', 'Lázár Ervin', 'Korpusz Sándor', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(676, 6, 1, 'Melyik mérték NEM a hosszúság mérésére szolgál?', 'sievert', 'ujj', 'angol mérföld', 'méter', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(677, 6, 2, 'Melyik elem fordul elő leggyakrabban a Földön az alábbiak közül (atom %-ban)?', 'alumínium', 'hidrogén', 'foszfor', 'klór', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(678, 7, 1, 'Milyen háziállat a mangalica?', 'sertés', 'pulyka', 'tyúk', 'kacsa', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(679, 8, 2, 'Melyik válogatottól szenvedte el a legsúlyosabb, 17:1 arányú vereségét Franciaország férfi labdarúgó-válogatottja?', 'Dánia', 'Olaszország', 'Németország', 'Csehország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(680, 9, 2, 'Kinek a száma volt eredetileg az \"I Will Always Love You\" című sláger, a Több mint testőr című film betétdala?', 'Dolly Parton', 'Whitney Houston', 'Elvis Presley', 'Celine Dion', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(681, 10, 1, 'Milyen eredetű étel az Újházi tyúkhúsleves?', 'magyar', 'lengyel', 'német', 'román', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(682, 2, 1, 'Az alábbiak közül melyik Málta autójelzése?', 'M', 'RM', 'SYR', 'IL', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(683, 2, 2, 'Mikor alapították a Samlerhuset csoportot, európa egyik vezető érme és emlékérem forgalmazóját?', '1994', '1852', '1366', '1915', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(686, 6, 2, 'Mi az email szó eredeti jelentése?', 'zománc', 'postafiók', 'kiviteli tilalom', 'ismertetőjel, jelkép', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(687, 7, 1, 'Milyen színű virága van a hóvirágnak?', 'fehér', 'piros', 'lila', 'sárga', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(688, 7, 2, 'Mitől retteg, akinek alektorofóbiája van?', 'a csirkéktől', 'a könyvektől', 'a mennydörgéstől', 'a saját fogaitól', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(689, 8, 1, 'Melyik sakkfigurát nevezték régen toronynak?', 'bástya', 'gyalog', 'huszár', 'vezér', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(690, 9, 1, 'Melyik a Republic száma?', '67-es út', 'Kiabálj', 'Országút blues', 'Így mulat egy beates magyar úr', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(691, 9, 2, 'A Mézga család című rajzfilmsorozatban ki Köbüki?', 'Mézga Géza', 'a harmincadik századbeli rokon', 'Mézga Aladár', 'Máris szomszéd', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(695, 5, 2, 'Milyen állatok vontatták a skandináv mitológiában Freya, a szépség és szerelem istennőjének szekerét?', 'macskák', 'hattyúk', 'szárnyas lovak', 'delfinek', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(696, 6, 1, 'Mi az Aquarius csillagkép magyar neve?', 'Vízöntő', 'Nyúl', 'Eridanus folyó', 'Lant', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(697, 6, 2, 'Az alábbi égitestek közül melyik a legnagyobb átmérőjű?', 'Betelgeuse', 'Nap', 'Szíriusz A', 'Proxima Centauri', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(698, 9, 2, 'Ki rendezte A Birodalom visszavág című filmet?', 'Irvin Kershner', 'George Lucas', 'Richard Marquand', 'Steven Spielberg', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(699, 2, 1, 'Melyik állathoz köti a népnyelv a szorgalmat?', 'hangya', 'légy', 'darázs', 'szúnyog', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(700, 3, 2, 'Melyik Sopron legnagyobb tere?', 'Deák tér', 'Orsolya tér', 'Fő tér', 'Széchenyi tér', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(701, 4, 1, 'Ki alapította a Szeretet Misszionáriusai-rendet?', 'Teréz anya', 'Merici Angéla', 'Maurus, Amalfi kereskedő', 'Norbert, xanteni kanonok', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(702, 4, 2, 'A legenda szerint melyik csatában használták először a győzelem jelét, a \"V\"-t formázó mutató és középső ujjat?', 'azincourt-i csata', 'marathóni csata', 'yorktowni csata', 'pharszaloszi csata', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(703, 6, 1, 'Milyen nemzetiségű volt Bródy Imre, a kriptonlámpa feltalálója?', 'magyar', 'svájci', 'belga', 'angol', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(704, 7, 2, 'Melyik a legkisebb hazai madár?', 'királyka', 'ökörszem', 'törpecinege', 'kenderike', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(705, 8, 1, 'Ki NEM autóversenyző az alábbiak közül?', 'Terence Hill', 'Damon Hill', 'Graham Hill', 'Phil Hill', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(706, 9, 2, 'Melyik légitársaság vezetője volt Howard Hughes, akinek életét Martin Scorsese Aviator című filmje is feldolgozta?', 'TWA', 'Pan Am', 'American Airlines', 'American Overseas Airlines', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(707, 1, 1, 'Melyik hangszer tagja a vonósnégyesnek?', 'hegedű', 'hárfa', 'viola da gamba', 'baryton', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(708, 2, 1, 'Mi teszi a mestert a közmondás szerint?', 'gyakorlat', 'tudás', 'ruha', 'ismeret', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(709, 3, 1, 'Melyik család kastélya található Nádasdladányon?', 'Nádasdy', 'Bezerédy', 'Rimanóczy-Pejacsevich', 'Apponyi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(710, 4, 2, 'Melyik jeles francia tábornok győzött Valmynál?', 'Kellermann', 'Murat', 'Bonaparte Napóleon', 'Jourdan', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(711, 6, 1, 'Az alábbiak közül melyik tudományág foglalkozik az időjárással, a légkörrel?', 'meteorológia', 'fiziológia', 'epigráfia', 'ergonómia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(712, 8, 1, 'Milyen nemzetiségű sportoló (volt) Denise Lewis hétpróbázó?', 'brit', 'fehérorosz', 'lengyel', 'ukrán', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33');
INSERT INTO `quiz_question` (`id`, `quiz_id`, `difficulty`, `question`, `ans1`, `ans2`, `ans3`, `ans4`, `username`, `is_verified`, `is_active`, `sending_time`, `verified_by`, `verification_time`) VALUES
(713, 8, 2, 'Hol rendezték a 2007-es Copa Américát?', 'Venezuela', 'Brazília', 'Argentína', 'Chile', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(714, 9, 1, 'Milyen állat Mirr-Murr, Csukás István több meséjének szereplője?', 'macska', 'kutya', 'tigris', 'farkas', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(715, 9, 2, 'Melyik filmben hangzik el a már klasszikussá vált mondat: \"Szorgos népünk győzni fog!\"?', 'Éretlenek', 'Hupikék törpikék', 'A tizedes meg a többiek', 'Bors', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(716, 10, 1, 'Mi a penne?', 'tészta', 'sütemény', 'zöldségféle', 'gyümölcs', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(717, 1, 1, 'Melyik városban található Zeusz-templom?', 'Athén', 'Párizs', 'Barcelona', 'Granada', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(718, 1, 2, 'Az alábbiak közül melyik szobrász alkotása VII. Pius pápa síremléke?', 'Bertel Thorvaldsen', 'Mürón', 'Michelangelo Buonarroti', 'Umberto Boccioni', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(719, 2, 1, 'Mi a suszter foglalkozása?', 'cipész', 'varrónő', 'bányász', 'szabó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(720, 3, 1, 'Az alábbiak közül melyik nevezetesség található Londonban?', 'Big Ben', 'Nagymesteri Palota', 'Mátyás király lovas szobra', 'Scala', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(721, 4, 1, 'Melyik miniszterelnökünk alakított kormányt az MSZP - SZDSZ támogatásával?', 'Medgyessy Péter', 'Hegedüs András', 'br. Bánffy Dezső', 'Lakatos Géza', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(722, 6, 1, 'Minek a mértékegysége az arasz?', 'hosszúság', 'sebesség', 'adatátviteli sebesség', 'terület', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(723, 6, 2, 'Melyik csillagász figyelt meg a Marson először \"csatornákat\"?', 'Giovanni Virginio Schiaparelli', 'Asaph Hall', 'Christiaan Huygens', 'Galileo Galilei', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(724, 8, 2, 'Melyik vállalat volt a magyar labdarúgó bajnokság első névszponzora?', 'Raab Karcher', 'Borsodi Sörgyár', 'Dreher Sörgyár', 'Monicomp Kft.', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(725, 9, 2, 'Ki rendezte az Eper és vér című filmet (1970)?', 'Stuart Hagmann', 'Mészáros Márta', 'Tony Richardson', 'Arthur Penn', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(726, 10, 2, 'Melyik étel 100 grammja tartalmazza a legtöbb szénhidrátot?', 'sárgarépa', 'márványsajt', 'cékla', 'málna', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(727, 1, 1, 'Mi Hernádi Judit foglalkozása?', 'színész', 'kritikus', 'jelmeztervező', 'író', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(728, 1, 2, 'Melyik festő született legrégebben az alábbiak közül?', 'Frans Snyders', 'Thomas Gainsborough', 'Canaletto', 'Jacques-Louis David', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(729, 3, 1, 'Melyik csúcs található a Mátra területén?', 'Kékes', 'Nagy-Csákány', 'Meleg-hegy', 'Hármashatár-hegy', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(730, 3, 2, 'Ki volt az a kaposvári festőművész, aki Ady és Babits verseihez készített szecessziós stílusú színes illusztrációkat?', 'Balázs János', 'Rippl-Rónai József', 'Bernáth Aurél', 'Vaszary János', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(731, 6, 2, 'Melyik a legkisebb egész szám?', 'nincs ilyen', 'a 0', 'az 1', 'a mínusz végtelen', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(732, 7, 1, 'Hogyan nevezzük a nőstény lovat?', 'kanca', 'üsző', 'szuka', 'ünő', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(733, 7, 2, 'Milyen csecsemőknek ajánlják az AR jelzésű tápszereket?', 'bukós babáknak', 'lisztérzékenyeknek', 'koraszülötteknek', 'vashiányos babáknak', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(734, 1, 2, 'Ki írta a Tavaszi zsongás című zongoraművet?', 'Christian Sinding', 'Wolfgang Amadeus Mozart', 'Ludwig van Beethoven', 'Andrew Lloyd Webber', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(735, 2, 1, 'Melyik ország autójelzése az IND?', 'India', 'Jordánia', 'Kolumbia', 'Thaiföld', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(736, 4, 1, 'Mi a szokásos elnevezése Attila hun uralkodónak?', 'Isten ostora', 'a Megvesztegethetetlen', 'a tigris', 'a világ ura', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(737, 5, 2, 'Ki volt a szerelem, a szőlő és az igazság istene Rómában?', 'Liber', 'Bacchus', 'Dionüszosz', 'Odüsszeusz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(738, 6, 1, 'Melyik a legkisebb római szám?', 'CXLVI', 'MDCCVIII', 'MDCCCLXVI', 'MCMXXXVIII', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(739, 6, 2, 'Melyik a legkisebb a régi magyar űrmértékek közül?', 'meszely', 'icce', 'pint', 'akó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(740, 7, 1, 'Melyik magyar kutyafajta?', 'puli', 'dalmata', 'mopsz', 'beagle', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(741, 8, 1, 'Melyik kézilabdacsapat nyerte a 2012-2013-as női Bajnokok Ligáját?', 'Győri Audi ETO KC', 'Larvik HK', 'Krim Ljubljana', 'Oltchim Valcea', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(742, 8, 2, 'Melyik páros nyerte a 2009-es Magyar Országos Rallye Bajnokságot?', 'Hadik András - Juhász István', 'Ifj.Tóth János - Gergely Ferenc', 'Botka Dávid - Szenner Zsolt', 'Herczig Norbert - Baranyai László', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(743, 2, 2, 'Mi a neve a nyomdászok évente megrendezett ünnepélyének?', 'János', 'Mátyás', 'Hess András', 'Knerr', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(744, 3, 1, 'Az alábbiak közül melyik város fekszik a Duna partján?', 'Pozsony', 'Arles', 'Wroclaw', 'Pisa', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(745, 5, 1, 'Melyik NEM személyes névmás?', 'akárhány', 'ő', 'mi', 'te', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(746, 7, 1, 'Milyen úton terjed a malária?', 'szúnyog által, transzfúzió révén', 'ismeretlen módon', 'beteg állat harapása által', 'étellel, itallal', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(747, 8, 1, 'Az alábbiak közül melyik sportoló nyert orosz színekben olimpiai aranyérmet?', 'Szvetlana Horkina', 'Daniela Silivas', 'Daley Thompson', 'Knut Holmann', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(748, 8, 2, 'Az alábbi atléták közül ki nyerte a legtöbb érmet világbajnokságon és olimpián együttvéve?', 'Merlene Ottey', 'Szergej Bubka', 'Jackie Joyner-Kersee', 'Carl Lewis', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(749, 9, 1, 'Melyik mese szereplője Karak?', 'Vuk', 'János vitéz', 'Tarzan', 'Szaffi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(750, 9, 2, 'Melyik magyar színész(nő) játszott a Casablanca című filmben?', 'Szőke Szakáll', 'Tony Curtis', 'Gábor Zsazsa', 'Lugosi Béla', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(751, 10, 1, 'Miből erjesztik a japán szakét?', 'rizsből', 'szőlőből', 'szilvából', 'barackból', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(752, 1, 2, 'Az alábbiak közül melyik opera játszódik Spanyolországban?', 'A kővendég', 'A három narancs szerelmese', 'A varázslónő', 'Lakmé', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(753, 2, 1, 'Melyik ünnep van a katolikus keresztény naptárban január 6-án?', 'vízkereszt', 'szeplőtelen fogantatás', 'Gyümölcsoltó Boldogasszony ünnepe', 'Keresztelő Szent János születése', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(754, 3, 1, 'Mi Görögország fővárosa?', 'Athén', 'Heraklion', 'Valletta', 'Szaloniki', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(755, 5, 1, 'Mit jelent az angol pink szó?', 'rózsaszín', 'lázadó', 'adatállomány', 'likőr', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(756, 5, 2, 'Milyen származású Aladdin az eredeti Ezeregyéjszaka meséi szerint?', 'kínai', 'iráni', 'indiai', 'mongol', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(757, 6, 1, 'Melyik mérték szolgál a tömeg mérésére?', 'gramm', '(bécsi) akó', 'icce', 'kalória', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(758, 6, 2, 'Ha egy medencében lévő csónakból sziklát dobsz a medence aljára, hogyan változik a vízszint?', 'csökken', 'emelkedik', 'nem változik', 'nem dönthető el mérés nélkül', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(759, 1, 1, 'Melyik tánc magyar eredetű?', 'botoló', 'krakowiak', 'trepak', 'padovana', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(760, 3, 1, 'Az alábbiak közül melyik nevezetes híd található Velencében?', 'Sóhajok hídja', 'Tower híd', 'Mária híd', 'Golden Gate híd', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(761, 3, 2, 'Az alábbiak közül melyik nevezetes híd található Moszkvában?', '\"Nagy Kőhíd\"', 'Szaratov híd', 'Sóhajok hídja', 'Palacky híd', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(762, 4, 2, 'Ki volt az apja Taksony magyar nagyfejedelemnek?', 'Zsolt', 'Árpád', 'Orseolo Péter', 'Álmos', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(763, 7, 1, 'Milyen állat a foltos hiéna?', 'ragadozó', 'rágcsáló', 'párosujjú patás', 'tojásrakó', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(764, 9, 2, 'Az alábbiak közül ki nyerte a rendezők között a legtöbb Oscar-díjat?', 'William Wyler', 'John Ford', 'Martin Scorsese', 'James Cameron', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(765, 10, 1, 'Melyik alapanyagra NINCS szükség a paprikás burgonya elkészítésénél?', 'sárgarépa', 'hagyma', 'burgonya', 'kolbász', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(766, 10, 2, 'Melyik étel 100 grammja tartalmazza a legtöbb zsírt?', 'kaviár', 'sertéscomb', 'barna kenyér', 'cékla', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(767, 2, 1, 'Melyik országból származik a Toyota?', 'Japán', 'Szerbia', 'USA', 'Dél-Korea', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(890, 5, 1, 'Hogyan fejeződik be a közmondás: Veri, mint szódás a ...?', 'lovát', 'kutyát', 'macskát', 'bikát', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(892, 10, 1, 'Melyik ország nemzeti étele a lasagne?', 'Olaszország', 'Hollandia', 'Svédország', 'Horvátország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(893, 5, 2, 'Az alábbi írók közül ki a férfi?', 'Evelyn Waugh', 'Evelyn Lau', 'George Sand', 'George Eliot', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(895, 10, 1, 'Mit csinálnak legtöbbször a fetával?', 'megeszik, ez egy sajtféleség', 'sporteszközzel egy kapuba ütik', 'mutogatják az állatkertben, ez egy madár', 'megisszák, ez egy erjesztett ital', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(899, 5, 1, 'Melyik szereplő egy őz az alábbiak közül?', 'Bambi', 'Kiz', 'Kele', 'Miska', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(902, 8, 1, 'Milyen nemzetiségű sportoló (volt) Oleg Protopopov műkorcsolyázó?', 'orosz', 'svéd', 'litván', 'francia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(903, 10, 1, 'Mi a puliszka?', 'kukoricadarából készült főtt étel', 'Dél-Afrikai emlős', 'emberi tulajdonság', 'borzos kutyafajta', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(907, 5, 1, 'Melyik szó jelentése ez: fogalomírás?', 'ideográfia', 'csepőte', 'bukszus', 'buna', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(911, 5, 1, 'Mit jelent az angol original szó?', 'eredeti', 'eleven', 'ehetetlen', 'cápa', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(912, 8, 2, 'Melyik ország nyerte 2007-ben a férfi vízilabda-világbajnokságot?', 'Horvátország', 'Spanyolország', 'Magyarország', 'Szerbia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(913, 5, 1, 'Milyen állat a Fekete István művében szereplő Bogáncs?', 'kutya', 'dögkeselyű', 'kenguru', 'sakál', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(915, 10, 1, 'Milyen eredetű ital a Jägermeister?', 'német', 'bolgár', 'francia', 'román', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(918, 5, 1, 'Milyen állat Garfield?', 'macska', 'egér', 'kutya', 'kacsa', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(919, 7, 1, 'Melyik a legkeményebb anyag az alábbiak közül a módosított Mohs-skála szerint?', 'gyémánt', 'kalcit', 'bór-karbid', 'apatit', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(920, 9, 1, 'Melyik együttes játssza a Gyöngyhajú lány című számot?', 'Omega', 'Európa Kiadó', 'After Crying', 'Takáts Tamás Dirty Blues Band', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(921, 9, 2, 'Melyik NEM Emir Kusturica filmje?', 'Cigánytábor az égbe megy', 'Macskajaj', 'Cigányok ideje', 'Underground', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(924, 5, 1, 'Melyik a helyes?', 'úgy', 'amig', 'igy', 'ugy', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(925, 8, 1, 'Milyen nemzetiségű sportoló volt Anatolij Sztarosztyin öttusázó?', 'orosz', 'lengyel', 'észt', 'finn', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(926, 9, 1, 'Melyik mese szereplője Tigris?', 'Micimackó visszatér', 'Mézga család', 'Kukori és Kotkoda (I. sorozat)', 'Csipkerózsika', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(927, 10, 1, 'Mi van minden kelt tésztában?', 'élesztő', 'sütőpor', 'vaníliás cukor', 'szódabikarbóna', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(929, 2, 2, 'Melyik két \"népbetegség\" káros hatásaira fejlesztette ki John Harvey Kellogg a kukoricapelyhet?', 'székrekedés és maszturbáció', 'cukorbetegség és hasnyálmirigy-gyulladás', 'szívinfarktus és stroke', 'alkoholizmus és gyomorfekély', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(932, 5, 1, 'Mi a szimbólum jelentése?', 'jelkép', 'kétnyelvű', 'eredetiség', 'leírás', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(933, 6, 1, 'Melyik mérték szolgál a hőmérséklet mérésére?', 'Fahrenheit-fok', 'tonna', 'metrikus karát', 'fermi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(934, 2, 2, 'Milyen terméket kezdett el gyártani Nor-Coc márkanévvel Kokron József és fiainak üzeme az 1930-as években?', 'svájci sapkát', 'ceruzát', 'mentolos cukorkát', 'füstszűrős cigarettát', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(935, 5, 1, 'Melyik NEM személyes névmás?', 'valami', 'te', 'én', 'mi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(936, 5, 2, 'Ki írta a Természetes gazdasági rend szabadföld és szabadpénz révén című gazdaságelméleti művet?', 'Silvio Gesell', 'John Maynard Keynes', 'Milton Friedman', 'David Ricardo', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(937, 6, 2, 'Minek a jele a matematikában az sgn jelölés?', 'az előjelé', 'a szinuszé', 'egy esemény valószínűségéé', 'a határértéké', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(938, 8, 1, 'Milyen nemzetiségű sportoló (volt) Jelena Davidova tornász?', 'orosz', 'svájci', 'finn', 'észt', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(939, 9, 1, 'Mi Galambos Lajos művészneve?', 'Lagzi Lajcsi', 'Buli Lajcsi', 'Disco Lajcsi', 'Bál Lajcsi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(940, 9, 2, 'Melyik film zenéjét szerezte Michael Nyman?', 'A rajzoló szerződése', 'A rettenthetetlen', 'Szárnyas fejvadász', 'Flashdance', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(941, 10, 2, 'Melyik étel 100 grammja tartalmazza a legkevesebb fehérjét?', 'tejföl (20%)', 'csirkemellfilé', 'zabpehely', 'lencse', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(942, 3, 1, 'Az alábbiak közül melyik ország határolja Magyarországot északról?', 'Szlovákia', 'Szerbia', 'Norvégia', 'Svédország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(943, 3, 2, 'Milyen női szerzetesrend működött Gyöngyösön?', 'Szent Vince rend', 'Szent Domonkos rend', 'Jó Pásztor Nővérek rendje', 'Angolkisasszonyok', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(944, 5, 1, 'Melyik a helyes?', 'így', 'amig', 'igy', 'ugy', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(945, 6, 1, 'Milyen nemzetiségű volt Kempelen Farkas, a beszélő gép feltalálója?', 'magyar', 'francia', 'norvég', 'olasz', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(946, 7, 2, 'Melyik fokozottan védett madárfajunk NEM a gémfélék (Ardeidae) családjába tartozik?', 'kanalasgém', 'nagy kócsag', 'bakcsó', 'bölömbika', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(947, 10, 2, 'Melyik étel 100 grammja tartalmazza a legkevesebb szénhidrátot?', 'dió', 'mák', 'napraforgómag', 'lencse', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(949, 2, 1, 'Hol használnak csillét?', 'bányában', 'tengeralattjárón', 'űrhajón', 'uszodában', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(950, 5, 2, 'Melyik birodalom szerepel Steven Erikson tízrészes fantasy-opuszában?', 'Malaza', 'Narnia', 'Tománia', 'Arrakis', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(951, 6, 1, 'Hogy nevezik az elsőéves egyetemistákat?', 'gólyák', 'fecskék', 'verebek', 'cinkék', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(952, 7, 1, 'Az alábbiak közül melyik állat dögevő?', 'foltos hiéna', 'zsiráf', 'Thomson gazella', 'indiai orrszarvú', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(953, 9, 1, 'Melyik mese szereplője Ariel?', 'A kis hableány', 'Mekk mester', 'Csipkerózsika', 'Tarzan', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(955, 3, 1, 'Hol található Magyarország atomerőműve?', 'Paks', 'Dunaföldvár', 'Tiszaújváros', 'Pilisborosjenő', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(956, 6, 1, 'Melyik a legnagyobb római szám (az alábbiak közül)?', 'MDCLXXVII', 'CMXXXIII', 'CXLVI', 'MCDXV', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(957, 1, 2, 'Melyik balett szerzője Igor Sztravinszkij?', 'Pulcinella', 'Harun al Rasid', 'Szentivánéji álom', 'Csipkerózsika', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(958, 3, 1, 'Mit jelent a cunami?', 'szökőár', 'földrengés', 'jégeső', 'tűzvész', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(959, 6, 1, 'Minek a rövidítése MEK?', 'Magyar Elektronikus Könyvtár', 'helyi hálózat', 'hibaellenőrző eljárás', 'készenléti jel', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(960, 6, 2, 'Melyik országban tevékenykedett Heinrich Lenz fizikus?', 'Oroszország', 'Németország', 'Kína', 'Lengyelország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(961, 7, 2, 'Az alábbiak közül melyik szerv játszhat szerepet egy gyógyszer kiválasztásában?', 'tüdő', 'pajzsmirigy', 'agy', 'mellékvese', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(962, 1, 2, 'Az alábbiak közül melyik szobrász alkotása a Marie Lou?', 'Constant Permeke', 'Umberto Boccioni', 'Henry Moore', 'Jean-Baptiste Pigalle', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(963, 6, 2, 'Az alábbiak közül melyik találmány született a legrégebben?', 'biztonsági zár', 'képtávíró (fakszimile)', 'zsebszámológép', 'zajtalan biztonsági gyufa', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(964, 7, 1, 'Melyik növényt termesztik ehető leveleiért?', 'spenót', 'burgonya', 'paradicsom', 'répa', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(965, 9, 1, 'Miért nőtt meg Pinokkió orra?', 'hazudott', 'csúnyán beszélt', 'lopott', 'Gepetto mester rálépett', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(966, 1, 1, 'Melyik tánc hawaii eredetű?', 'hula kahiko', 'racsenica', 'cachucha', 'likkeni', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(967, 1, 2, 'Mit tart a kezében a lovas Donatello: Gattamelata lovasszobrán?', 'botot', 'dárdát', 'kardot', 'pajzsot', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(968, 2, 1, 'Hogy hívják a pálinkafőzéshez erjesztett gyümölcslét?', 'cefre', 'cifra', 'cvekker', 'center', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(969, 4, 1, 'Melyik vár híres kapitánya volt Dobó István?', 'Eger', 'Gyula', 'Drégely', 'Kőszeg', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(970, 6, 2, 'Melyik elem fordul elő leggyakrabban a Földön az alábbiak közül, atom %-ban?', 'alumínium', 'klór', 'kalcium', 'nitrogén', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(971, 7, 1, 'Az alábbiak közül melyik egy pókfaj neve?', 'tarantula', 'katta', 'szurikáta', 'csicsörke', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(972, 8, 1, 'Melyik bajnokságban játszó futballcsapat az Espanyol?', 'spanyol', 'török', 'portugál', 'görög', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(973, 8, 2, 'Melyik egyesület nyerte meg 1947-ben az elsőként kiírt magyar női röplabda-bajnokságot?', 'Columbia SE', 'Tungsram SC', 'BSE-FCSM', 'Eger SE', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(974, 9, 2, 'Ki írt filmzenét A hét mesterlövész című filmhez?', 'Elmer Bernstein', 'Jerry Goldsmith', 'Howard Shore', 'Ennio Morricone', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(975, 10, 1, 'Mi NEM kell a gofri elkészítéséhez?', 'sűrített paradicsom', 'cukor', 'tej', 'vaj vagy margarin', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(976, 10, 2, 'Melyik étel 100 grammja tartalmazza a legkevesebb szénhidrátot?', 'parmezán sajt', 'karalábé', 'paradicsom', 'padlizsán', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(977, 3, 1, 'Az alábbiak közül melyik ország határolja Magyarországot délről?', 'Horvátország', 'Norvégia', 'Litvánia', 'Svédország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(978, 4, 1, 'Mi a rövidítése az ENSZ Gyermeksegélyalapjának?', 'UNICEF', 'OECD', 'IMO', 'GATT', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(979, 5, 1, 'Mi nem esik messze a fájától a mondás szerint?', 'alma', 'körte', 'sárkánygyümölcs', 'csillaggyümölcs', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(980, 5, 2, 'Melyik nyelvújítónknak köszönhetjük mai matematikai szókincsünk egy jelentős részét, pl. a kör, és a derékszög szavakat?', 'Dugonics András', 'Kazinczy Ferenc', 'Barczafalvi Szabó Dávid', 'Szemere Pál', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(981, 6, 2, 'Melyik tudós használta a torziós ingát a gravitációs állandó meghatározásat célzó kutatásaihoz?', 'Henry Cavendish', 'Isaac Newton', 'Galileo Galilei', 'Johannes Kepler', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(982, 7, 2, 'Milyen gomba a tavaszi tőkegomba?', 'íze miatt ehetetlen', 'mérgező', 'ehető', 'nyersen mérgező', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(983, 9, 2, 'Ki adta ki az első, irányzatteremtő ambient műfajú lemezt Music for Airports címmel?', 'Brian Eno', 'Mike Oldfield', 'Jean Michael Jarre', 'Vangelis', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(984, 10, 1, 'Milyen italt kínálnak általában korsóban?', 'sör', 'fehérbor', 'pezsgő', 'szaké', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(985, 10, 2, 'Melyik étel 100 grammja tartalmazza a legkevesebb szénhidrátot?', 'sertéscomb', 'zabpehely', 'padlizsán', 'csirkecomb', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(986, 1, 1, 'Melyik testrészükkel mutatják be a táncosok a spiccet?', 'lábfejükkel', 'kézfejükkel', 'könyökükkel', 'fejükkel', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(987, 4, 1, 'Milyen néven szokták említeni Thalészt?', 'a görög filozófia atyja', 'a sanssouci bölcs', 'a charme nagykövete', 'a rózsák atyja', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(988, 4, 2, 'Hol található az első magyar porcelángyár, melyet Brentzenheim Ferdinánd alapított 1825-ben?', 'Telkibánya', 'Gyula', 'Herend', 'Veszprém', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(989, 8, 1, 'Melyik észak-amerikai kosárlabdacsapat székhelye Chicago?', 'Bulls', 'Thunder', 'Wizards', 'Mavericks', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(990, 8, 2, 'Kik nyerték el a legtöbbször, nyolc alkalommal a Mr. Olympia címet a testépítők legrangosabb versenyén?', 'Lee Haney és Ronnie Coleman', 'Frank Zane és Franco Columbu', 'Hargitay Miklós és Arnold Schwarzenegger', 'Lou Ferrigno és Oleg Emelianov', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(991, 10, 1, 'Mi NEM kell a sajtos omlett elkészítéséhez?', 'ketchup', 'tojás', 'zsiradék', 'sajt', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(992, 1, 1, 'Hogyan nevezzük azt a művészt, aki velünk egy időben él?', 'kortárs', 'kortes', 'kortés', 'szolfézs', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(993, 6, 1, 'Milyen tudós volt a német Albert Einstein?', 'fizikus', 'biológus', 'orvos', 'történész', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(994, 7, 2, 'Miből nyerte ki 1867-ben Huber német kémikus a B3 vitamint?', 'dohánylevélből', 'paprikából', 'halolajból', 'búzacsírából', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(995, 8, 1, 'Melyik betű jelzi az időkérést a sportban?', 'T', 'I', 'O', 'L', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(996, 10, 2, 'Melyik napilapunkat alapították legkorábban?', 'Nemzeti Sport', 'Magyar Hírlap', 'Világgazdaság', 'Népszabadság', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(997, 2, 2, 'Az alábbiak közül melyiket alapították legkésőbb?', 'trappista rend', 'evangélikus egyház', 'pálos rend', 'Academia Istropolitana', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(998, 3, 1, 'Az alábbiak közül melyik város nevezetessége az Eiffel-torony?', 'Párizs', 'Tirana', 'Koppenhága', 'Zágráb', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(999, 7, 1, 'Melyik állat kérődzik?', 'szarvasmarha', 'vakond', 'házikacsa', 'majom', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1000, 9, 1, 'Milyen állat Frakk a mesében?', 'kutya', 'macska', 'pingvin', 'egér', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1001, 1, 1, 'Melyik városban található a Louvre?', 'Párizs', 'Marseille', 'Lyon', 'Toulouse', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1002, 3, 2, 'Melyik országnak nincs hivatalos címere?', 'Törökország', 'Bosznia-Hercegovina', 'Palesztina', 'Amerikai Egyesült Államok', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1003, 6, 2, 'Melyik tudós állította elsőként, hogy a Föld kering a Nap körül és forog saját tengelye körül?', 'Szamoszi Arisztarkhosz', 'Galileo Galilei', 'Nikolaus Kopernikusz', 'Kolumbusz Kristóf', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1004, 7, 1, 'Az elemek mely csoportjába tartozik a szén?', 'széncsoport', 'mangáncsoport', 'szkandiumcsoport', 'rézcsoport', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1005, 9, 1, 'Melyik NEM animációs sorozat?', 'Így jártam anyátokkal', 'South Park', 'A Simpson család', 'Family Guy', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1006, 10, 1, 'Mi a neve az eszkimók jégkunyhójának?', 'iglu', 'tipi', 'wigwam', 'lemur', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1007, 3, 1, 'Melyik ország területe a legnagyobb az alábbiak közül?', 'Németország', 'Lettország', 'Litvánia', 'Észtország', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1008, 4, 1, 'Mi XIV. Lajos szokásos elnevezése?', 'a Napkirály', 'a Megvesztegethetetlen', 'a charme nagykövete', 'a béke Napóleonja', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1009, 7, 2, 'Az alábbiak közül melyik állatnak van a legtöbb nyakcsigolyája?', 'háromujjú lajhár', 'kék bálna', 'zsiráf', 'vadászgörény', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1010, 8, 1, 'Melyik bajnokságban játszó futballcsapat a West Ham United?', 'angol', 'spanyol', 'holland', 'svájci', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1011, 8, 2, 'Melyik játékvezető vezette már valamelyik labdarúgó- világbajnokságon a nyitómérkőzést?', 'Zsolt István', 'Palotai Károly', 'Puhl Sándor', 'Kassai Viktor', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1012, 9, 1, 'Melyik mese szereplője Gombóc Artúr?', 'Pom-pom meséi', 'Minden kutya mennybe jut', 'Egyiptom hercege', 'Herkules', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1013, 10, 1, 'Melyik férfinév egy csokoládé márka is egyben?', 'Tibi', 'Zoli', 'Tomi', 'Peti', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1014, 8, 2, 'Kinek a nevéhez fűződik sífutásban a korcsolyázó-technika, a \"szabad-stílus\" első alkalmazása?', 'Pauli Siitonen', 'Alekszander Zavjalov', 'Ole-Einar Björndalen', 'Lukas Bauer', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1015, 9, 1, 'Melyik számot játssza az alábbiak közül a Republic együttes?', 'Szállj el, kismadár', 'Száguldás', 'Szeret a nő', 'American Idiot', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1016, 9, 2, 'Melyik színész egyik szerepbeli kiszólásából lett a szállóige: \"Bocsánat, hogy a csapos közbeszól\"?', 'Mály Gerő', 'Latabár Kálmán', 'Kabos Gyula', 'Gózon Gyula', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1017, 1, 2, 'Melyik mű ábrázolja a legtöbb emberalakot?', 'Sandro Botticelli: Tavasz', 'Raffaello Santi: Sixtusi Madonna', 'Pablo Picasso: Az avignoni kisasszonyok', 'Henri Matisse: Tánc', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1018, 4, 2, 'Miből készült Hammurapi törvényoszlopa?', 'diorit', 'dolomit', 'agyag', 'gránit', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1019, 6, 1, 'Milyen nemzetiségű volt Karl Benz, a benzinmotoros autó feltalálója?', 'német', 'olasz', 'skót', 'svéd', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1020, 7, 1, 'Melyik növény virága piros?', 'pipacs', 'salátaboglárka', 'mezei katáng', 'borsos varjúháj', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1021, 7, 2, 'Melyik az a madár, amely egyedülálló módon a denevérekhez hasonlóan visszhanggal tájékozódik?', 'szuszók', 'denevérpapagáj', 'kolibri', 'seregély', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1022, 8, 2, 'Melyik sakkozó őrizte rekordnak számító 27 éven át sakkvilágbajnoki címét?', 'Emanuel Lasker', 'José Raúl Capablanca', 'Rudolf Spielmann', 'Garri Kaszparov', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1023, 9, 1, 'Melyik mese szereplője Hápogi szomszéd?', 'Kukori és Kotkoda', 'Vuk', 'Z, a hangya', 'Bambi', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1143, 8, 1, 'Melyik bajnokságban játszó futballcsapat a Panathinaikos?', 'görög', 'portugál', 'szerb', 'norvég', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1144, 10, 1, 'Hol található a Valentino divatház székhelye?', 'Olaszország', 'Amerikai Egyesült Államok', 'Németország', 'Anglia', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1145, 5, 2, 'Ki a Varjúdombi mesék írója?', 'Tarbay Ede', 'Lázár Ervin', 'Csukás István', 'Kormos István', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1151, 5, 1, 'Milyen névmás az én?', 'személyes', 'kölcsönös', 'határozatlan', 'mutató', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1152, 8, 1, 'Az alábbiak közül melyik sportoló nyert orosz színekben olimpiai aranyérmet?', 'Ludmilla Turiscseva', 'Jayne Torvill', 'Fabio Casartelli', 'Arsi Harju', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1153, 8, 2, 'Hol épült meg 1905-ben az ország első vidéki fedett uszodája?', 'Ózd', 'Debrecen', 'Hévíz', 'Keszthely', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1157, 8, 1, 'Az alábbiak közül melyik a Manchester United futballcsapatának a beceneve?', 'Vörös Ördögök', 'Öreg hölgy', 'Protestánsok', 'Költők', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1159, 10, 2, 'Melyik természettudós/biológus afrikai útja volt a WWF megalakulásának közvetlen előzménye?', 'Sir Julian Huxley', 'Sir David Attenborough', 'Kaán Károly', 'Sir Peter Scott', 'norbi', 1, 1, '2020-06-13 11:03:00', 15, '2021-09-26 20:27:33'),
(1162, 11, 1, 'Mit jelent a Halloween szó?', 'Mindenszentek estéje', 'Halottak estéje', 'Halottak napja', 'Köszöntések napja', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-29 12:48:01'),
(1163, 11, 1, 'Mikor ünneplik a Halloweent?', 'október 31-én éjjel', 'október 30-án éjjel', 'november 1-én éjjel', 'november 2-án éjjel', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-29 14:48:41'),
(1164, 11, 1, 'Melyik néptől származnak a Halloween-szokások?', 'a keltáktól', 'a britektől', 'a vikingektől', 'az amerikaiaktól', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 00:34:45'),
(1165, 11, 2, 'A hét melyik napjához kapcsolódik a Halloween boszorkánybeavató szertartása?', 'szombat', 'vasárnap', 'csütörtök', 'kedd', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 12:08:17'),
(1166, 11, 1, 'Melyik a kakukktojás az alábbiak közül?', 'hétmérföldes csizma', 'varázskalap', 'boszorkány', 'töklámpás', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 12:55:02'),
(1167, 11, 1, 'Kiről kapta a nevét a Halloween egyik szimbóluma, a Töklámpás?', 'Jack', 'Jeffrey', 'Joe', 'John', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 13:02:14'),
(1168, 11, 2, 'Mi elől menekültek azok, akik a Halloween-szokásokat vitték Amerikába?', 'Az 1840-es burgonyavész elől', 'A brit uralkodó haragja elől', 'A Nagy Francia Forradalom elől', 'Az Őszirózsás forradalom elől', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 13:02:24'),
(1171, 11, 2, 'Hogy hívják a hagyományos, sütőtökből kivájt, kifaragott lámpást?', 'Jack-O’-Lantern', 'Tom-O’-Lantern', 'Bob- O’-Lantern', 'Joe- O’-Lantern', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 12:08:42'),
(1174, 11, 2, 'Melyik filmszerep vált híressé Lon Chaney Jr. alakításában 1941-ben?', 'A farkasember', 'A múmia', 'Az Operaház Fantomja', 'Fekete sarkantyú', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 13:03:14'),
(1175, 11, 1, 'Mit szoktak játszani a résztvevők a Halloween-partikon?', 'almát halásznak', 'narancsot keresnek', 'eperért énekelnek', 'körtetornyot építenek', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 13:20:26'),
(1176, 11, 1, 'Mi a magyar neve az Amerikában népszerű, gyerekek által kedvelt „Trick or treath!” nevű játéknak?', '„Csokit, vagy csínyt!”', '„Almát, vagy szellemeket!”', '„Finomságot, vagy ijesztgetünk!”', '„Adsz, vagy horrort kapsz!”', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 13:01:51'),
(1178, 11, 2, 'Megközelítőleg a gyerekek hány százaléka vesz részt évente Amerikában Halloween-ünnepségeken, vagy a „Trick or treath” játékban?', '85-90%', '60-65%', '70-75%', '80-85%', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 13:00:28'),
(1180, 11, 1, 'A hiedelmek szerint milyen állattá tudtak átváltozni a boszorkányok?', 'fekete macska', 'fekete pók', 'fekete vámpír denevér', 'fekete ló', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 13:02:07'),
(1189, 11, 2, 'Körülbelül hány milliárd dollárt költöttek az amerikaiak 2010-ben Halloweenkor?', '5.8', '4.3', '6.7', '2.9', 'norbika', 1, 1, '2020-05-08 00:00:00', 15, '2021-09-28 13:23:27'),
(1191, 11, 2, 'Mit jelképez Japánban a fekete macska?', 'bőséget és szerencsét', 'balszerencsét', 'a Halloween-t', 'félelmet', 'norbika', 1, 1, '2020-05-09 00:00:00', 15, '2021-09-28 13:24:26'),
(1195, 12, 1, 'Mikor van Szent Miklós napja?', 'december 6.', 'december 24.', 'december 5.', 'december 11.', 'norbi', 1, 1, '2020-05-10 09:42:23', 15, '2021-09-26 20:27:33'),
(1224, 12, 1, 'Hogy hívják Jézus anyját?', 'Mária', 'Sára', 'Rozália', 'Katalin', 'norbi', 1, 1, '2020-05-10 09:42:23', 15, '2021-09-26 20:27:33'),
(1237, 12, 1, 'Ki/Mi vezette a napkeleti bölcseket Jézushoz?', 'a Messiás csillaga', 'egy angyal', 'a pásztorok', 'Heródes', 'norbi', 1, 1, '2020-05-10 09:42:23', 15, '2021-09-26 20:27:33'),
(1239, 12, 2, 'Kitől kapta Karácsony-föld a nevét?', 'Vasco da Gamatól', 'Cook kapitánytól', 'Scott kapitánytól', 'Kolumbusz Kristóftól', 'norbi', 1, 1, '2020-05-10 09:42:23', 15, '2021-09-26 20:27:33'),
(1246, 12, 1, 'Hogyan ünneplik a karácsonyi lakomát az ausztrálok?', 'piknikeznek a tengerparton', 'nincs náluk lakoma karácsonykor', 'szobában kandalló mellett', 'elutaznak a hegyekbe', 'norbi', 1, 1, '2020-05-10 09:42:23', 15, '2021-09-26 20:27:33'),
(1247, 12, 1, 'Kik díszítik Angliában a karácsonyfát?', 'az egész család', 'a nagyszülők', 'a szülők', 'a gyerekek', 'norbi', 1, 1, '2020-05-10 09:42:23', 15, '2021-09-26 20:27:33'),
(1248, 12, 1, 'Mik húzzák a Télapó szánját?', 'rénszarvasok', 'dán szarvasok', 'fehér lovak', 'őzek', 'norbi', 1, 1, '2020-05-10 09:42:23', 15, '2021-09-26 20:27:33'),
(1253, 12, 2, 'Milyen eredetű és mit jelent a karácsony szó?', 'szláv eredetű, jelentése: átlépő', 'görög eredetű, jelentése: felkent', 'finnugor eredetű, jelentése: áldott', 'latin eredetű, jelentése: megváltó', 'norbi', 1, 1, '2020-05-10 09:42:23', 15, '2021-09-26 20:27:33'),
(1256, 12, 2, 'Hány méter magas volt a világ legmagasabb karácsonyfája, amelyet 1950-ben Washingtonban állítottak fel?', 'körülbelül 70 méter', 'körülbelül 55 méter', 'körülbelül 80 méter', 'körülbelül 95 méter', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-28 00:57:14'),
(1269, 10, 1, 'Melyik hozzávaló NEM kell a bejgli elkészítéséhez?', 'zselatin', 'liszt', 'élesztő', 'tojássárgája', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-29 12:37:27'),
(1271, 12, 1, 'Hogy hívják a három napkeleti bölcset?', 'Gáspár, Menyhért, Boldizsár', 'Baltazár, Izajás, Dániel', 'Gáspár, József, Lipót', 'Ambrosius, Menyhért, Mikeás', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-28 16:07:10'),
(1272, 12, 2, 'Ki írta a Betlehemi királyok című verset?', 'József Attila', 'Tóth Árpád', 'Ady Endre', 'Wass Albert', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-28 20:48:24'),
(1274, 12, 2, 'Hogy mondják Hawaii-on a \"Boldog karácsonyt!\"?', 'Mele Kalikimaka', 'Christmas Kalikimaka', 'Santa Kalimaka', 'Kalikimaka Christmas', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-28 15:59:45'),
(1286, 12, 1, 'Mikor van karácsony első napja?', 'december 25.-én', 'december 24.-én', 'december 6.-án', 'december 26.-án', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 16:05:46'),
(1291, 12, 1, 'A hiedelmek szerint mit hozott régen a karácsonyi abrosz?', 'bőséget, egészséget', 'vigadalmat', 'bajt, betegséget', 'szerencsét', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 20:50:25'),
(1295, 12, 1, 'Kiknek a védőszentje Szent Borbála?', 'hajadon lányoké', 'az egyházi papoké', 'csecsemőké', 'halottaké', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:14:03'),
(1298, 12, 1, 'Mikor keresztelték meg Jézust?', 'Vízkereszt napján (január 6.)', 'december 25.', 'december 26.', 'nem volt megkeresztelve', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 21:02:43'),
(1299, 12, 1, 'Milyen eredetű szó az advent?', 'latin', 'német', 'héber', 'görög', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:11:31'),
(1303, 12, 2, 'Ki írta a karácsonyi éjszakán című verset?', 'Arany János', 'Zelk Zoltán', 'Weöres Sándor', 'József Attila', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:12:00'),
(1304, 12, 1, 'Hogy hívják a Lucától karácsonyig tányérkában csiráztatott búzát?', 'Luca-búza', 'Luca-csíra', 'búzacsíra', 'karácsonyi csíra', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:13:53'),
(1308, 12, 2, 'Hogyan folytatódik: \"Kis karácsonyfagyertya...\"?', 'szép fehér', 'felül törött', 'igénytelen, értéktelen', 'talán semmit sem ér', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:13:36'),
(1310, 12, 1, 'Mikor van vége a karácsonyi ünnepsornak?', 'vízkeresztkor', 'szilveszterkor', 'János napján', 'farsangkor', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:13:45'),
(1311, 4, 2, 'Mikor kapta Karácsony-föld a nevét?', '1498', '1322', '1396', '1748', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-29 07:11:58'),
(1312, 12, 1, 'Miért tették az állatok alá a karácsonyi asztal alól a szalmát, vagy a szénát?', 'hogy egészségesek, szaporák legyenek az állatok', 'hogy túléljék a telet', 'hogy szopjanak az állatok', 'elégették ezt a szalmát és szénát', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:28:05'),
(1313, 12, 1, 'Mikor van vízkereszt napja?', 'január 6.', 'január 3.', 'január 9.', 'december 30.', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:27:47'),
(1314, 12, 2, 'Mi az angoloknál a karácsonyi menü?', 'pulyka és puding', 'pulyka és bejgli', 'hideg sonka és kalács', 'hal és sáfrányos kenyér', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:26:30'),
(1321, 12, 1, 'Milyen évszakban van az ausztrálok karácsonya?', 'nyár', 'tél', 'tavasz', 'ősz', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-28 00:53:52'),
(1323, 4, 2, 'Mikor kapta a Karácsony-sziget a nevét?', '1777. december 24.', '1685. december 25.', '1511. december 22.', '1792. december 23.', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-29 07:11:11'),
(1326, 12, 1, 'Mi NEM hiányozhat a betlehemi kellékből?', 'a betlehemi csillag', 'kutyák', 'gyertyák', 'bárányok', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:27:39'),
(1328, 1, 2, 'Mikor készült Gerard David Pásztorok imádása című műve?', 'XV. század vége', 'XX. század', 'XIII. század eleje', 'XVIII. század közepe', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-29 07:12:12'),
(1331, 12, 2, 'Milyen névnap van december 25.-én?', 'Eugénia', 'Kamilla', 'Teofil', 'Viktória', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-28 00:51:00'),
(1335, 12, 1, 'Mikor van Ádám és Éva napja?', 'december 24.', 'december 25.', 'december 26.', 'december 31.', 'norbika', 1, 1, '2020-05-10 00:00:00', 15, '2021-09-28 00:51:50'),
(1348, 12, 2, 'Mit jelképez a magyar hagyományok szerint a halpikkely?', 'gazdagságot', 'sok gyermeket', 'egészséget', 'boldog házasságot', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:31:03'),
(1363, 12, 1, 'Kiknek a napja december 28.-a?', 'aprószentek', 'Viktória', 'Tamás', 'Jézus', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:31:48'),
(1366, 1, 2, 'Ki volt az a két művész, akik mindketten megfestették a Krisztus születése című művet?', 'Botticelli és Dürer', 'Holbein és Dürer', 'Tiziano és Dürer', 'Holbein és Botticelli', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-29 12:38:37'),
(1370, 12, 2, 'Mit sütöttek a Luca-pogácsába?', 'tollat, pénzt', 'követ, kavicsot', 'hajszálat', 'parafadugót', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:32:17'),
(1385, 12, 1, 'Hány gyertya van az adventi koszorún?', '4', '3', '2', '6', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:38:49'),
(1387, 12, 1, 'Min jár a Télapó?', 'szánon', 'autón', 'szekéren', 'hintón', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:38:56'),
(1388, 12, 1, 'Mit ünnepeltek a régi rómaiak december 25.-én?', 'a legyőzhetetlen Nap születését', 'Jézus halálát', 'Augustus győzelmét', 'a megvilágosodást', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:39:01'),
(1392, 12, 1, 'Mit fontak december 28.-án?', 'kis korbácsot', 'kis kosarat', 'lucakosarat', 'fagyöngykoszorút', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:39:30'),
(1394, 12, 1, 'Mikor jön Franciaországban a Jézuska?', 'december 24.-én, az éjféli mise alatt', 'december 24.-én reggel', 'december 26.-án reggel', 'december 24.-én délben', 'norbika', 1, 1, '2020-05-11 00:00:00', 15, '2021-09-28 22:43:40'),
(1398, 12, 2, 'Mivel szórták fel Luca-napkor az udvart?', 'szénával, szalmával', 'babbal, borsóval', 'mákkal, dióval', 'sóval, borssal', 'norbika', 1, 1, '2020-05-12 00:00:00', 15, '2021-09-28 22:43:23'),
(1401, 12, 1, 'Mikor van Szent Borbála napja?', 'december 4.', 'november 25.', 'december 13.', 'december 2.', 'norbika', 1, 1, '2020-05-12 00:00:00', 15, '2021-09-28 22:43:14'),
(1406, 12, 2, 'Ki jelentette fel Szent Luciát?', 'egy elhagyott vőlegény', 'egy büszkeségében sértett apa', 'egy megszégyenített bátty', 'egy hiú húg', 'norbika', 1, 1, '2020-05-12 00:00:00', 15, '2021-09-28 22:44:27'),
(1412, 12, 1, 'Mikor nyílik a mikulásvirág?', 'tél elején', 'tél közepén', 'tél végén', 'ősszel', 'norbika', 1, 1, '2020-05-12 00:00:00', 15, '2021-09-28 22:44:04'),
(1417, 12, 2, 'Kinek kellett öntözni a Luca-búzát?', 'a gazdasszonynak', 'a gyerekeknek', 'a főúrnak', 'a cselédnek', 'norbika', 1, 1, '2020-05-12 00:00:00', 15, '2021-09-28 22:54:07'),
(1420, 12, 2, 'Hány évig volt Szent Miklós Myra város vezetője?', '52', '48', '36', '44', 'norbika', 1, 1, '2020-05-12 00:00:00', 15, '2021-09-28 22:52:26'),
(1443, 4, 2, 'Ki fedezte fel a Karácsony-szigetet?', 'Cook kapitány', 'Vasco da Gama', 'Fülöp herceg', 'az inkák', 'norbika', 1, 1, '2020-05-12 00:00:00', 15, '2021-09-29 12:36:05'),
(1497, 45, -1, 'Ki az a aerrca4wtre?', 'werd', 'efd', 'ef', 'efsetrf', 'aaaa', 3, 0, '2020-08-22 23:41:35', 15, '2021-09-26 20:15:18'),
(1499, 84, -1, 'Na lassuk mi lesz?', 'ez', 'az', 'amax', 'rdfcec', 'aaaa', 3, 0, '2020-08-23 14:56:34', 15, '2021-09-26 20:15:18'),
(1500, 86, 1, 'Mennyi 11+22?', '33', '34', '30', '35', 'sss', 1, 1, '2020-08-24 16:37:04', 15, '2021-09-26 20:27:33'),
(1501, 86, 1, 'Mennyi 99+99?', '198', '199', '200', '197', 'sss', 1, 1, '2020-08-24 16:37:56', 15, '2021-09-26 20:27:33'),
(1502, 86, 1, 'Mennyi 15+64?', '79', '69', '89', '99', 'sss', 1, 1, '2020-08-24 16:38:23', 15, '2021-09-26 20:27:33'),
(1503, 86, 1, 'Mennyi 50+50?', '100', '105', '101', '99', 'sss', 1, 1, '2020-08-24 16:38:43', 15, '2021-09-26 20:27:33'),
(1504, 86, 2, 'Mennyi 72-49?', '23', '33', '41', '11', 'sss', 1, 1, '2020-08-24 16:39:36', 15, '2021-09-26 20:27:33'),
(1505, 86, 1, 'Mennyi 60-17?', '43', '53', '33', '13', 'sss', 1, 1, '2020-08-24 16:40:20', 15, '2021-09-26 20:27:33'),
(1506, 86, 2, 'Mennyi 25+25+63?', '113', '123', '133', '128', 'sss', 1, 1, '2020-08-24 16:41:03', 15, '2021-09-26 20:27:33'),
(1507, 86, 2, 'Mennyi 90-41+75?', '124', '117', '98', '131', 'sss', 1, 1, '2020-08-24 16:41:56', 15, '2021-09-26 20:27:33'),
(1508, 86, 1, 'Mennyi 90+90?', '180', '190', '120', '150', 'sss', 1, 1, '2020-08-24 16:49:17', 15, '2021-09-26 20:27:33'),
(1509, 86, 1, 'Mennyi 54-37?', '17', '19', '21', '23', 'sss', 1, 1, '2020-08-24 16:50:02', 15, '2021-09-26 20:27:33'),
(1510, 86, 2, 'Mennyi 52+37-47?', '42', '49', '47', '46', 'sss', 1, 1, '2020-08-24 16:51:08', 15, '2021-09-26 20:27:33'),
(1511, 86, 2, 'Mennyi 55-46+17?', '26', '24', '28', '30', 'sss', 1, 1, '2020-08-24 16:51:49', 15, '2021-09-26 20:27:33'),
(1512, 86, 2, 'Mennyi 44-25+63+78?', '160', '145', '156', '163', 'sss', 1, 1, '2020-08-24 16:52:48', 15, '2021-09-26 20:27:33'),
(1513, 86, 2, 'Mennyi 77-25+97?', '149', '168', '157', '134', 'sss', 1, 1, '2020-08-24 16:53:29', 15, '2021-09-26 20:27:33'),
(1514, 86, 1, 'Mennyivel egyenlő 30 duplájának duplája?', '120', '60', '90', '150', 'sss', 1, 1, '2020-08-24 16:54:31', 15, '2021-09-26 20:27:33'),
(1515, 86, 2, 'Mennyit kapunk ha kivonjuk 49-ből a 49 számjegyeinek összegét?', '36', '41', '31', '46', 'sss', 1, 1, '2020-08-24 16:55:31', 15, '2021-09-26 20:27:33'),
(1516, 86, 2, 'Mennyit kapunk ha hozzáadjuk 55 duplájához a 96 számjegyeinek összegét?', '125', '115', '105', '135', 'sss', 1, 1, '2020-08-24 16:57:28', 15, '2021-09-26 20:27:33'),
(1517, 86, 2, 'Mennyi kapunk ha kivonjuk egymásból 78 és 67 számjegyeinek összegét?', '2', '3', '1', '0', 'sss', 1, 1, '2020-08-24 17:00:42', 15, '2021-09-26 20:27:33'),
(1518, 86, 1, 'Mennyit kell hozzáadjunk a 64-hez, hogy 100-at kapjunk?', '36', '38', '27', '35', 'sss', 1, 1, '2020-08-24 17:01:29', 15, '2021-09-26 20:27:33'),
(1520, 97, 1, 'Minek a rövidítése a VPN?', 'Virtual Private Network', 'Virtual Paralel Network', 'Virtual Package Network', 'Virtual Personal Network', 'aaaa', 1, 1, '2020-10-19 17:10:59', 15, '2021-09-26 20:27:33'),
(1521, 97, 2, 'Mit tesz lehetővé a VPN?', 'biztonságos kapcsolatot hoz létre a számítógép és az internet között', 'biztonságos és gyors internetkapcsolatot teremt', 'biztonságos böngészést nyújt, melyet még a VPN-szolgáltató sem lát', 'védelmet nyújt a hackeres támadásokkal szemben', 'aaaa', 1, 1, '2020-10-19 17:31:14', 15, '2021-09-26 20:27:33'),
(1524, 97, 2, 'Melyik VPN-technológiák a legelterjedtebbek manapság?', 'SSL, IPSec', 'IPSec, PPTP', 'L2TP, SSL', 'MLPS, IPSec', 'aaaa', 1, 1, '2020-10-19 22:15:58', 15, '2021-09-26 20:27:33'),
(1525, 97, 2, 'Mi a vészleállító feladata?', 'automatikusan megszakítja az internetkapcsolatot hiba esetén', 'bizonyos online tartalmak elérhetőségét blokkolja adott országokban', 'hiba esetén titkosítja az adatokat', 'megvéd az SSL/TLS böngészéstől', 'aaaa', 1, 1, '2020-10-19 22:40:26', 15, '2021-09-26 20:27:33');
INSERT INTO `quiz_question` (`id`, `quiz_id`, `difficulty`, `question`, `ans1`, `ans2`, `ans3`, `ans4`, `username`, `is_verified`, `is_active`, `sending_time`, `verified_by`, `verification_time`) VALUES
(1526, 97, 2, 'Mi a VPN-kliens?', 'alkalmazás, amivel egy VPN-kiszolgálóhoz csatlakozunk', 'számítógép, ami létrehozza a kapcsolatot közted és egy VPN-szolgáltatás között', 'kiszolgálótípus, ami elrejti a felhasználó helyzetét a felkeresett webhelyek előtt', 'hardvereszköz, ami az internetről érkező adatcsomagokat továbbítja', 'aaaa', 1, 1, '2020-10-19 22:52:07', 15, '2021-09-26 20:27:33'),
(1528, 97, 2, 'Hány alapvető VPN-típus létezik?', '2', '3', '4', '5', 'aaaa', 1, 1, '2020-10-19 22:55:19', 15, '2021-09-26 20:27:33'),
(1529, 97, 2, 'Hogy nevezik másképp a Site-to-site VPN-t?', 'Router-to-Router VPN', 'Peer-to-Peer VPN', 'Point-to-point VPN', 'Switch-to-switch VPN', 'aaaa', 1, 1, '2020-10-19 22:59:08', 15, '2021-09-26 20:27:33'),
(1530, 97, 2, 'Milyen típusú VPN-t használnak a vállalatok a különböző földrajzi elhelyezkedésű irodáik összekapcsolásához?', 'Site-to-site VPN', 'Remote access VPN', 'Peer-to-Peer VPN', 'Country-to-Country VPN', 'aaaa', 1, 1, '2020-10-19 23:15:12', 15, '2021-09-26 20:27:33'),
(1531, 97, 2, 'Milyen néven ismert még a Site-to-Site VPN?', 'Intranet alapú VPN', 'Peer-to-Peer VPN', 'Remote connection based VPN', 'Country-to-country VPN', 'aaaa', 1, 1, '2020-10-19 23:18:56', 15, '2021-09-26 20:27:33'),
(1532, 97, 1, 'Minek a rövidítése az IPSec?', 'Internet Protocol Security', 'Internet Private System', 'International Protocol System', 'Internet Private Security', 'aaaa', 1, 1, '2020-10-19 23:29:54', 15, '2021-09-26 20:27:33'),
(1533, 97, 2, 'Mire szolgál az alagút-mód az IPSec típusú VPN-ek esetében?', 'védelmezi az adatátviteli folyamatot a két különböző hálózat között', 'gyorsítja az adatátviteli folyamatot a két különböző hálózat között', 'az adatcsomagban található üzenetet titkosítja', 'az adatok tárolásának megbízhatóságát biztosítja', 'aaaa', 1, 1, '2020-10-19 23:39:42', 15, '2021-09-26 20:27:33'),
(1534, 97, 2, 'Melyik az IPSec típusú VPN egyik jellemzője?', 'ellenőrzi a munkameneteket és individuálisan titkosítja az adatcsomagokat a kapcsolaton keresztül', 'biztosítja az adatok tárolásának integritását ', 'nem biztosít titkosítást', 'a PPP protokollra hagyatkozik', 'aaaa', 1, 1, '2020-10-19 23:42:33', 15, '2021-09-26 20:27:33'),
(1535, 97, 1, 'Minek a rövidítése a PPTP VPN?', 'Point-to-Point Tunneling Protocol', 'Point-to-Point Protocol', 'Private Procedural Tunneling Protocol', 'Private Point To Protocol', 'aaaa', 1, 1, '2020-10-19 23:48:36', 15, '2021-09-26 20:27:33'),
(1536, 97, 1, 'Minek a rövidítése a L2TP VPN?', 'Layer to Tunneling Protocol', 'Law to Tunneling Protocol', 'Label to Tunneling Protocol', 'Law of Two Tunning Protocol', 'aaaa', 1, 1, '2020-10-19 23:58:33', 15, '2021-09-26 20:27:33'),
(1537, 97, 2, 'Melyik kettő működik egy protokollként?', 'SSL és TLS', 'MPLS és SSL', 'PPTP és SSL', 'TLS és L2TP', 'aaaa', 1, 1, '2020-10-20 00:00:45', 15, '2021-09-26 20:27:33'),
(1538, 97, 1, 'Az alábbiak közül melyik rejtheti el a felhasználó böngészési előzményeit?', 'VPN', 'Inkognitó mód', 'Tűzfal', 'Antivírus', 'aaaa', 1, 1, '2020-10-20 00:08:28', 15, '2021-09-26 20:27:33'),
(1541, 97, 1, 'Melyik NEM tartozik az első 5 legjobb VPN-szolgáltató közé?', 'ProtoVPN', 'NordVPN', 'ExpressVPN', 'CyberGhost', 'aaaa', 1, 1, '2020-10-20 00:29:26', 15, '2021-09-26 20:27:33'),
(1542, 97, 2, 'Az alábbiak közül melyik VPN-ek alagút protokollok?', 'PPTP, L2TP, IPSec', 'IPSec, L2TP, SSL', 'PPP, IPSec, SSL', 'PPP, L2TP, PPTP', 'aaaa', 1, 1, '2020-10-20 08:49:50', 15, '2021-09-26 20:27:33'),
(1544, 97, 2, 'Melyik állítás HAMIS az alábbiak közül?', 'az adatforgalom részleteit nem látja a VPN-szolgáltató', 'az internetszolgáltatód elől is elrejtheted a tevékenységedet VPN használatával', 'a VPN megnehezíti az adathalászok és hackerek adatlopási kísérleteit', 'a webhelyek számára az adatforgalom a VPN-szerver országából érkezőnek látszik', 'aaaa', 1, 1, '2020-10-20 10:01:30', 15, '2021-09-26 20:27:33'),
(1545, 97, 2, 'Melyik állítás IGAZ az alábbiak közül?', 'A legtöbb VPN-szolgáltató IPSec titkosítási módot használ', 'A VPN nem elérhető Android okostelefonokon', 'Az IPSec ma már nem biztonságos, mert a kódolása visszafejthető', 'A legtöbb VPN-szolgáltató a TLS-titkosítási kulcsok cseréjét alkalmazza', 'aaaa', 1, 1, '2020-10-20 10:25:07', 15, '2021-09-26 20:27:33'),
(1559, 11, 1, 'Mi a Halloween?', 'ősi rituálé, mely során a halált ünnepelték', 'a Mikulás születésnapja', 'a sütőtökszezon kezdete', 'egy vállalat Ohio-ban', 'sss', 1, 1, '2020-11-01 20:34:28', 15, '2021-09-26 20:27:33'),
(1561, 11, 1, 'Milyen étel a sütőtök?', 'gyümölcs', 'zöldség', 'gyümölcs is és zöldség is egyben', 'édesség', 'sss', 1, 1, '2020-11-01 20:39:15', 15, '2021-09-26 20:27:33'),
(1567, 67, 1, 'Kit találnak a katonák a Saudraie erdőben?', 'egy anyát 3 gyermekével', 'egy anyát 2 gyermekével', 'egy markotányosnőt', 'egy sebesült, idős asszonyt', 'sss', 1, 1, '2020-12-07 16:35:10', 15, '2021-09-26 20:27:33'),
(1570, 67, -1, 'Jhdg hmdngbf?', 'efgh', 'hnghfdfrgh', 'mhngbfd', 'mmnhgbv', 'sss', 3, 0, '2020-12-07 19:32:04', 15, '2021-09-26 20:15:18'),
(1571, 67, 2, 'Az alábbiak közül ki NEM Michelle gyermeke?', 'Elise', 'Georgette', 'René-Jean', 'Gros-Alain', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1573, 67, 2, 'Hány női tagja volt a „Vörössipkás zászlóalj”-nak?', '2', '1', '3', 'egy sem', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1574, 67, 2, 'Mennyi idős Michelle legidősebb gyermeke?', '4 és fél éves', '2 éves', '3 éves', '20 hónapos', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1575, 67, 1, 'Mi volt a Claymore korvett?', 'egy hadihajó', 'egy teherhajó', 'a republikánusok titkos fegyvere', 'Marat egyik ideológiája', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1577, 67, 2, 'Hogy hívták a Claymore korvett kapitányát?', 'Boisberthelot', 'Philippe Gacquoil', 'Balcarras', 'La Vieuville', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1579, 67, 1, 'Ki rendelte el a korvettet megmentő ember kivégzését?', 'az aggastyán', 'a kapitány', 'Gacquoil', 'a matrózok többsége', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1582, 67, 2, 'Hány ágyú maradt épen a korvetten az ágyú okozta katasztrófa után?', '9', '15', '13', '4', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1584, 67, 2, 'Mi lett a Claymore sorsa végűl?', 'tűzben leégett a legénységgel együtt', 'elsüllyedt a legénységgel együtt', 'zátonyra futott', 'megmenekült', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1585, 67, 1, 'Hányan voltak abban a csónakban a nyílt vízen, amellyel az aggastyánt megszöktették?', '2', '3', '4', '5', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1587, 67, 1, 'Mit akar először tenni a matróz az aggastyánnal, amikor kettesben vannak a nyílt vízen?', 'megölni', 'megzsarolni', 'átadni őt a hatóságoknak', 'meggyőzni őt, hogy álljon át a republikánusok oldalára', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1589, 67, 1, 'Hogy hívják a matrózt, akivel az aggastyán elszökött a korvettről?', 'Halmalo', 'Tellmarch', 'Gavard', 'Imanus', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1591, 67, 2, 'Mi volt az aggastyán vezéri jelvénye, amelyet a matrózának adott át?', 'zöld selyemcsokor', 'piros selyemcsokor', 'fehér selyemcsokor', 'kék selyemcsokor', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1592, 67, 2, 'Mit parancsol az aggastyán a matróznak, miután az eljut a Saint-Aubin-i erdőbe?', 'lázadjanak fel és ne kegyelmezzenek senkinek', 'fegyverezze le a Couesbon-kastély népét', 'gyilkoltassa le Thuault urat', 'adja át az öreg Goupil de Préfeln-ek a jelvényt', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1593, 67, 2, 'Hogy reagál az aggastyán, amikor a matróza beszél neki a La Tourgue-ban található titkos föld alatti folyosóról?', 'nem hisz neki', 'megdöbbenten hallgatja azt végig', 'ketten tervet szőnek a titkot felhasználva', 'megkéri, hogy ne mondja el senkinek a titkot', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1594, 67, 1, 'Mi az aggastyán neve?', 'Lantenac', 'Gavard', 'Imanus', 'Halmalo', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1595, 67, 2, 'A könyv szerint ki szólítja először a nevén az aggastyánt?', 'Tellmarch', 'Halmalo', 'Talmont', 'Gauvain', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1596, 67, 2, 'Kit neveztek a „kódis”-nak?', 'Tellmarch', 'Halmalo', 'Lantenac', 'Cimourdain', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1597, 67, 2, 'Mit olvasott Lantenac magáról egy plakát apróbetűs soraiban?', 'hogy kiléte megállapítása után agyonlövendő', 'hogy kiléte megállapítása után felakasztandó', 'hogy kiléte megállapítása után biztonságba helyezendő', 'hogy kiléte megállapítása után elfogatandó', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1598, 67, 1, 'Kinek az aláírása szerepelt a Lantenac által olvasott plakáton?', 'Gauvain', 'Cimourdain', 'Halmalo', 'Imanus', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1600, 67, 2, 'Hány golyót kapott a „Vörössipkás zászlóalj” markotányosnője a kivégzésekor?', '4', '2', '1', '3', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1605, 67, 1, 'Mi volt Cimourdain foglalkozása?', 'pap', 'kertész', 'ács', 'tanító', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1611, 67, 1, 'Mi a konvent?', 'egy gyülekezet', 'egy nagy épület', 'egy hadihajó', 'egy titkos találkozóhely', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1612, 67, 2, 'Naponta hány ülést tartott a konvent?', '2', '1', '3', '4', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1613, 67, 2, 'Mit ígér meg Cimourdain az ülésen, amikor rábízzák az egykori vicomte-ot?', 'ha hibát követ el, azonnal kivégezteti', 'egy percre sem veszi le róla a szemét', 'nem engedi, hogy meggondolatlan döntéseket hozzon', 'nem engedi, hogy az érzelmek eluralkodjanak rajta', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1615, 67, 1, 'Ki NEM tartozott a Cerberus fejei közé?', 'Cimourdain', 'Danton', 'Robespierre', 'Marat', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1641, 67, 1, 'Hol voltak „a túszok” elszállásolva a La Tourgue-ban?', 'a könyvtárban', 'a magtárban', 'Lantenac márkival egy helyen', 'a pincében', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1649, 67, 1, 'Ki a „megmentő”, akinek sikerül utolsó percen kimenekítenie a márkit titokban a toronyból?', 'Halmalo', 'Gacquoil', 'Gouge-le-Bruant', 'Cinke', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(1654, 67, 1, 'Mit tett Gauvain a tömlöcben kivégzésre váró Lantenac-al?', 'titokban lehetőséget adott neki, hogy megszökhessen', 'egy tőrrel leszúrja', 'a bocsánatát kérte', 'hosszasan elbeszélgetett vele a történtekről', 'sss', 1, 1, '2020-12-07 19:53:23', 15, '2021-09-26 20:27:33'),
(7180, 164, 2, 'Melyik ország fővárosa Kabul?', 'Afganisztán', 'Burundi', 'Zöld-foki Köztársaság', 'Egyesült Arab Emírségek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7181, 164, 2, 'Melyik ország fővárosa Tirana?', 'Albánia', 'Burkina Faso', 'Zimbabwe', 'Nigéria', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7182, 164, 2, 'Melyik ország fővárosa Algír?', 'Algéria', 'Bulgária', 'Zambia', 'Ghána', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7183, 164, 2, 'Melyik ország fővárosa Andorra la Vella?', 'Andorra', 'Brazília', 'Vietnám', 'Etiópia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7184, 164, 2, 'Melyik ország fővárosa Luanda?', 'Angola', 'Botswana', 'Venezuela', 'Algéria', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7185, 164, 2, 'Melyik ország fővárosa Buenos Aires?', 'Argentína', 'Bosznia-Hercegovina', 'Vatikán', 'Jordánia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7186, 164, 2, 'Melyik ország fővárosa Canberra?', 'Ausztrália', 'Bolívia', 'Vanuatu', 'Hollandia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7187, 164, 2, 'Melyik ország fővárosa Bécs?', 'Ausztria', 'Bissau-Guinea', 'Üzbegisztán', 'Andorra', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7188, 164, 2, 'Melyik ország fővárosa Baku?', 'Azerbajdzsán', 'Bhután', 'Uruguay', 'Törökország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7189, 164, 2, 'Melyik ország fővárosa Nassau?', 'Bahama-szigetek', 'Belize', 'Ukrajna', 'Madagaszkár', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7190, 164, 2, 'Melyik ország fővárosa Manáma?', 'Bahrein', 'Belgium', 'Új-Zéland', 'Türkmenisztán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7191, 164, 2, 'Melyik ország fővárosa Dakka?', 'Banglades', 'Barbados', 'Uganda', 'Kazahsztán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7192, 164, 2, 'Melyik ország fővárosa Bridgetown?', 'Barbados', 'Banglades', 'Türkmenisztán', 'Paraguay', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7193, 164, 2, 'Melyik ország fővárosa Brüsszel?', 'Belgium', 'Bahrein', 'Tuvalu', 'Eritrea', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7194, 164, 2, 'Melyik ország fővárosa Belmopan?', 'Belize', 'Bahama-szigetek', 'Tunézia', 'Görögország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7195, 164, 2, 'Melyik ország fővárosa Timpu?', 'Bhután', 'Azerbajdzsán', 'Törökország', 'Irak', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7196, 164, 2, 'Melyik ország fővárosa Bissau?', 'Bissau-Guinea', 'Ausztria', 'Togo', 'Kiribati', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7197, 164, 2, 'Melyik ország fővárosa La Paz?', 'Bolívia', 'Ausztrália', 'Thaiföld', 'Azerbajdzsán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7198, 164, 2, 'Melyik ország fővárosa Szarajevó?', 'Bosznia-Hercegovina', 'Argentína', 'Tanzánia', 'Mali', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7199, 164, 2, 'Melyik ország fővárosa Gaborone?', 'Botswana', 'Angola', 'Tajvan', 'Thaiföld', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7200, 164, 2, 'Melyik ország fővárosa Brazíliaváros?', 'Brazília', 'Andorra', 'Tádzsikisztán', 'Közép-afrikai Köztársaság', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7201, 164, 2, 'Melyik ország fővárosa Szófia?', 'Bulgária', 'Amerikai Egyesült Államok', 'Szudán', 'Gambia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7202, 164, 2, 'Melyik ország fővárosa Ouagadougou?', 'Burkina Faso', 'Algéria', 'Szomália', 'Ausztria', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7203, 164, 2, 'Melyik ország fővárosa Gitega?', 'Burundi', 'Albánia', 'Szlovénia', 'Libanon', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7204, 164, 2, 'Melyik ország fővárosa Santiago de Chile?', 'Chile', 'Afganisztán', 'Szlovákia', 'Szerbia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7205, 164, 2, 'Melyik ország fővárosa Nicosia?', 'Ciprus', 'Etiópia', 'Szíria', 'Belize', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7206, 164, 2, 'Melyik ország fővárosa Moroni?', 'Comore-szigetek', 'Észtország', 'Szingapúr', 'Németország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7207, 164, 2, 'Melyik ország fővárosa San José de Costa Rica?', 'Costa Rica', 'Észak-Korea', 'Szerbia', 'Svájc', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7208, 164, 2, 'Melyik ország fővárosa N’Djamena?', 'Csád', 'Eritrea', 'Szenegál', 'Kirgizisztán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7209, 164, 2, 'Melyik ország fővárosa Prága?', 'Csehország', 'Elefántcsontpart', 'Szaúd-Arábia', 'Bissau-Guinea', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7210, 164, 2, 'Melyik ország fővárosa Koppenhága?', 'Dánia', 'Egyiptom', 'Svédország', 'Kolumbia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7211, 164, 2, 'Melyik ország fővárosa Pretoria?', 'Dél-afrikai Köztársaság', 'Egyesült Királyság', 'Svájc', 'Brazília', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7212, 164, 2, 'Melyik ország fővárosa Juba?', 'Dél-Szudán', 'Egyesült Arab Emírségek', 'Suriname', 'Barbados', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7213, 164, 2, 'Melyik ország fővárosa Santo Domingo?', 'Dominikai Köztársaság', 'Egyenlítői-Guinea', 'Spanyolország', 'Belgium', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7214, 164, 2, 'Melyik ország fővárosa Dzsibuti?', 'Dzsibuti', 'Ecuador', 'Sierra Leone', 'Magyarország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7215, 164, 2, 'Melyik ország fővárosa Quito?', 'Ecuador', 'Dzsibuti', 'Seychelle-szigetek', 'Argentína', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7216, 164, 2, 'Melyik ország fővárosa Malabo?', 'Egyenlítői-Guinea', 'Dominikai Köztársaság', 'San Marino', 'Románia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7217, 164, 2, 'Melyik ország fővárosa Washington?', 'Amerikai Egyesült Államok', 'Dél-Szudán', 'Salamon-szigetek', 'Ausztrália', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7218, 164, 2, 'Melyik ország fővárosa Abu-Dzabi?', 'Egyesült Arab Emírségek', 'Dél-Korea', 'Ruanda', 'Venezuela', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7219, 164, 2, 'Melyik ország fővárosa Kairó?', 'Egyiptom', 'Dél-afrikai Köztársaság', 'Románia', 'Moldova', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7220, 164, 2, 'Melyik ország fővárosa Yamoussoukro?', 'Elefántcsontpart', 'Dánia', 'Portugália', 'Guinea', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7221, 164, 2, 'Melyik ország fővárosa Aszmara?', 'Eritrea', 'Csehország', 'Peru', 'Szenegál', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7222, 164, 2, 'Melyik ország fővárosa Phenjan?', 'Észak-Korea', 'Csád', 'Paraguay', 'Banglades', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7223, 164, 2, 'Melyik ország fővárosa Tallinn?', 'Észtország', 'Costa Rica', 'Pápua Új-Guinea', 'Szíria', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7224, 164, 2, 'Melyik ország fővárosa Addis Abeba?', 'Etiópia', 'Comore-szigetek', 'Panama', 'Tanzánia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7225, 164, 2, 'Melyik ország fővárosa Minszk?', 'Fehéroroszország', 'Ciprus', 'Pakisztán', 'Katar', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7226, 164, 2, 'Melyik ország fővárosa Suva?', 'Fidzsi-szigetek', 'Chile', 'Örményország', 'Írország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7227, 164, 2, 'Melyik ország fővárosa Helsinki?', 'Finnország', 'Zöld-foki Köztársaság', 'Oroszország', 'Tádzsikisztán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7228, 164, 2, 'Melyik ország fővárosa Párizs?', 'Franciaország', 'Zimbabwe', 'Omán', 'Dzsibuti', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7229, 164, 2, 'Melyik ország fővárosa Manila?', 'Fülöp-szigetek', 'Zambia', 'Olaszország', 'Sierra Leone', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7230, 164, 2, 'Melyik ország fővárosa Libreville?', 'Gabon', 'Vietnám', 'Norvégia', 'Botswana', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7231, 164, 2, 'Melyik ország fővárosa Banjul?', 'Gambia', 'Venezuela', 'Nigéria', 'Guyana', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7232, 164, 2, 'Melyik ország fővárosa Accra?', 'Ghána', 'Vatikán', 'Niger', 'Burundi', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7233, 164, 2, 'Melyik ország fővárosa Athén?', 'Görögország', 'Vanuatu', 'Nicaragua', 'Guatemala', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7234, 164, 2, 'Melyik ország fővárosa Tbiliszi?', 'Grúzia', 'Üzbegisztán', 'Nepál', 'Vietnám', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7235, 164, 2, 'Melyik ország fővárosa Guatemalaváros?', 'Guatemala', 'Uruguay', 'Németország', 'Zimbabwe', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7236, 164, 2, 'Melyik ország fővárosa Conakry?', 'Guinea', 'Ukrajna', 'Namíbia', 'Kuba', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7237, 164, 2, 'Melyik ország fővárosa Georgetown?', 'Guyana', 'Új-Zéland', 'Mozambik', 'Finnország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7238, 164, 2, 'Melyik ország fővárosa Port-au-Prince?', 'Haiti', 'Uganda', 'Montenegró', 'Salamon-szigetek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7239, 164, 2, 'Melyik ország fővárosa Amszterdam?', 'Hollandia', 'Türkmenisztán', 'Mongólia', 'Pakisztán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7240, 164, 2, 'Melyik ország fővárosa Tegucigalpa?', 'Honduras', 'Tuvalu', 'Monaco', 'Indonézia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7241, 164, 2, 'Melyik ország fővárosa Zágráb?', 'Horvátország', 'Tunézia', 'Moldova', 'Örményország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7242, 164, 2, 'Melyik ország fővárosa Újdelhi?', 'India', 'Törökország', 'Mianmar', 'Dél-Szudán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7243, 164, 2, 'Melyik ország fővárosa Jakarta?', 'Indonézia', 'Togo', 'Mexikó', 'Afganisztán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7244, 164, 2, 'Melyik ország fővárosa Bagdad?', 'Irak', 'Thaiföld', 'Mauritánia', 'Egyiptom', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7245, 164, 2, 'Melyik ország fővárosa Teherán?', 'Irán', 'Tanzánia', 'Marshall-szigetek', 'Uganda', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7246, 164, 2, 'Melyik ország fővárosa Dublin?', 'Írország', 'Tajvan', 'Marokkó', 'Szudán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7247, 164, 2, 'Melyik ország fővárosa Reykjavík?', 'Izland', 'Tádzsikisztán', 'Málta', 'Nepál', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7248, 164, 2, 'Melyik ország fővárosa Tel-Aviv?', 'Izrael', 'Izrael', 'Mali', 'Ruanda', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7249, 164, 2, 'Melyik ország fővárosa Kingston?', 'Jamaica', 'Izland', 'Maldív-szigetek', 'Ukrajna', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7250, 164, 2, 'Melyik ország fővárosa Tokió?', 'Japán', 'Írország', 'Malawi', 'Jamaica', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7251, 164, 2, 'Melyik ország fővárosa Szanaa?', 'Jemen', 'Irán', 'Malajzia', 'Kongói Demokratikus Köztársaság', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7252, 164, 2, 'Melyik ország fővárosa Ammán?', 'Jordánia', 'Irak', 'Magyarország', 'Dánia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7253, 164, 2, 'Melyik ország fővárosa Phnompen?', 'Kambodzsa', 'Indonézia', 'Madagaszkár', 'Malajzia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7254, 164, 2, 'Melyik ország fővárosa Yaoundé?', 'Kamerun', 'India', 'Luxemburg', 'Kuvait', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7255, 164, 2, 'Melyik ország fővárosa Ottawa?', 'Kanada', 'Horvátország', 'Litvánia', 'Bolívia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7256, 164, 2, 'Melyik ország fővárosa Doha?', 'Katar', 'Honduras', 'Liechtenstein', 'Gabon', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7257, 164, 2, 'Melyik ország fővárosa Astana?', 'Kazahsztán', 'Hollandia', 'Líbia', 'Malawi', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7258, 164, 2, 'Melyik ország fővárosa Nairobi?', 'Kenya', 'Haiti', 'Libéria', 'Peru', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7259, 164, 2, 'Melyik ország fővárosa Peking?', 'Kína', 'Guyana', 'Libanon', 'Portugália', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7260, 164, 2, 'Melyik ország fővárosa Biskek?', 'Kirgizisztán', 'Guinea', 'Lettország', 'Szlovénia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7261, 164, 2, 'Melyik ország fővárosa Bairiki?', 'Kiribati', 'Guatemala', 'Lesotho', 'Togo', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7262, 164, 2, 'Melyik ország fővárosa Bogotá?', 'Kolumbia', 'Grúzia', 'Lengyelország', 'Egyesült Királyság', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7263, 164, 2, 'Melyik ország fővárosa Kinshasa?', 'Kongói Demokratikus Köztársaság', 'Görögország', 'Laosz', 'Angola', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7264, 164, 2, 'Melyik ország fővárosa Szöul?', 'Dél-Korea', 'Ghána', 'Kuvait', 'Zambia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7265, 164, 2, 'Melyik ország fővárosa Bangui?', 'Közép-afrikai Köztársaság', 'Gambia', 'Kuba', 'Luxemburg', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7266, 164, 2, 'Melyik ország fővárosa Havanna?', 'Kuba', 'Gabon', 'Közép-afrikai Köztársaság', 'Spanyolország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7267, 164, 2, 'Melyik ország fővárosa Kuvaitváros?', 'Kuvait', 'Fülöp-szigetek', 'Kongói Demokratikus Köztársaság', 'Marshall-szigetek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7268, 164, 2, 'Melyik ország fővárosa Vientián?', 'Laosz', 'Franciaország', 'Kolumbia', 'Egyenlítői-Guinea', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7269, 164, 2, 'Melyik ország fővárosa Varsó?', 'Lengyelország', 'Finnország', 'Kiribati', 'Maldív-szigetek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7270, 164, 2, 'Melyik ország fővárosa Maseru?', 'Lesotho', 'Fidzsi-szigetek', 'Kirgizisztán', 'Nicaragua', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7271, 164, 2, 'Melyik ország fővárosa Riga?', 'Lettország', 'Fehéroroszország', 'Kína', 'Bahrein', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7272, 164, 2, 'Melyik ország fővárosa Bejrút?', 'Libanon', 'Szudán', 'Kenya', 'Fülöp-szigetek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7273, 164, 2, 'Melyik ország fővárosa Monrovia?', 'Libéria', 'Szomália', 'Kazahsztán', 'Mozambik', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7274, 164, 2, 'Melyik ország fővárosa Tripoli?', 'Líbia', 'Szlovénia', 'Katar', 'Lesotho', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7275, 164, 2, 'Melyik ország fővárosa Vaduz?', 'Liechtenstein', 'Szlovákia', 'Kanada', 'Omán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7276, 164, 2, 'Melyik ország fővárosa Vilnius?', 'Litvánia', 'Szíria', 'Kamerun', 'Mexikó', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7277, 164, 2, 'Melyik ország fővárosa Luxembourg?', 'Luxemburg', 'Szingapúr', 'Kambodzsa', 'Fehéroroszország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7278, 164, 2, 'Melyik ország fővárosa Antananarivo?', 'Madagaszkár', 'Szerbia', 'Jordánia', 'Szomália', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7279, 164, 2, 'Melyik ország fővárosa Budapest?', 'Magyarország', 'Szenegál', 'Jemen', 'Monaco', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7280, 164, 2, 'Melyik ország fővárosa Kuala Lumpur?', 'Malajzia', 'Szaúd-Arábia', 'Japán', 'Libéria', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7281, 164, 2, 'Melyik ország fővárosa Lilongwe?', 'Malawi', 'Svédország', 'Jamaica', 'Uruguay', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7282, 164, 2, 'Melyik ország fővárosa Malé?', 'Maldív-szigetek', 'Svájc', 'Izrael', 'Comore-szigetek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7283, 164, 2, 'Melyik ország fővárosa Bamako?', 'Mali', 'Suriname', 'Izland', 'Oroszország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7284, 164, 2, 'Melyik ország fővárosa Valletta?', 'Málta', 'Spanyolország', 'Írország', 'Csád', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7285, 164, 2, 'Melyik ország fővárosa Rabat?', 'Marokkó', 'Sierra Leone', 'Irán', 'Kenya', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7286, 164, 2, 'Melyik ország fővárosa Majuro?', 'Marshall-szigetek', 'Seychelle-szigetek', 'Irak', 'Bahama-szigetek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7287, 164, 2, 'Melyik ország fővárosa Nouakchott?', 'Mauritánia', 'San Marino', 'Indonézia', 'Mianmar', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7288, 164, 2, 'Melyik ország fővárosa Mexikóváros?', 'Mexikó', 'Salamon-szigetek', 'India', 'Niger', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7289, 164, 2, 'Melyik ország fővárosa Nepjida?', 'Mianmar', 'Kuvait', 'Horvátország', 'Ciprus', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7290, 164, 2, 'Melyik ország fővárosa Chişinău?', 'Moldova', 'Kuba', 'Honduras', 'Mauritánia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7291, 164, 2, 'Melyik ország fővárosa Monaco?', 'Monaco', 'Közép-afrikai Köztársaság', 'Hollandia', 'Norvégia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7292, 164, 2, 'Melyik ország fővárosa Ulánbátor?', 'Mongólia', 'Kongói Demokratikus Köztársaság', 'Haiti', 'Kanada', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7293, 164, 2, 'Melyik ország fővárosa Maputo?', 'Mozambik', 'Kiribati', 'Guinea', 'Panama', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7294, 164, 2, 'Melyik ország fővárosa London?', 'Egyesült Királyság', 'Kirgizisztán', 'Guatemala', 'Suriname', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7295, 164, 2, 'Melyik ország fővárosa Windhoek?', 'Namíbia', 'Kína', 'Grúzia', 'Franciaország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7296, 164, 2, 'Melyik ország fővárosa Berlin?', 'Németország', 'Kenya', 'Görögország', 'Kína', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7297, 164, 2, 'Melyik ország fővárosa Katmandu?', 'Nepál', 'Kazahsztán', 'Ghána', 'Észak-Korea', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7298, 164, 2, 'Melyik ország fővárosa Managua?', 'Nicaragua', 'Katar', 'Gambia', 'Kambodzsa', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7299, 164, 2, 'Melyik ország fővárosa Niamey?', 'Niger', 'Kanada', 'Gabon', 'Montenegró', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7300, 164, 2, 'Melyik ország fővárosa Abuja?', 'Nigéria', 'Kamerun', 'Fülöp-szigetek', 'Pápua Új-Guinea', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7301, 164, 2, 'Melyik ország fővárosa Oslo?', 'Norvégia', 'Kambodzsa', 'Franciaország', 'Vanuatu', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7302, 164, 2, 'Melyik ország fővárosa Róma?', 'Olaszország', 'Jordánia', 'Finnország', 'Haiti', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7303, 164, 2, 'Melyik ország fővárosa Maszkat?', 'Omán', 'Jemen', 'Fidzsi-szigetek', 'Szlovákia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7304, 164, 2, 'Melyik ország fővárosa Moszkva?', 'Oroszország', 'Japán', 'Fehéroroszország', 'Csehország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7305, 164, 2, 'Melyik ország fővárosa Jereván?', 'Örményország', 'Jamaica', 'Etiópia', 'Zöld-foki Köztársaság', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7306, 164, 2, 'Melyik ország fővárosa Iszlámábád?', 'Pakisztán', 'Ruanda', 'Észtország', 'Dél-afrikai Köztársaság', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7307, 164, 2, 'Melyik ország fővárosa Panamaváros?', 'Panama', 'Románia', 'Észak-Korea', 'Ecuador', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7308, 164, 2, 'Melyik ország fővárosa Port Moresby?', 'Pápua Új-Guinea', 'Portugália', 'Eritrea', 'Marokkó', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7309, 164, 2, 'Melyik ország fővárosa Asunción?', 'Paraguay', 'Peru', 'Elefántcsontpart', 'Izland', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7310, 164, 2, 'Melyik ország fővárosa Lima?', 'Peru', 'Paraguay', 'Egyiptom', 'Lettország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7311, 164, 2, 'Melyik ország fővárosa Lisszabon?', 'Portugália', 'Pápua Új-Guinea', 'Egyesült Királyság', 'Szaúd-Arábia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7312, 164, 2, 'Melyik ország fővárosa Bukarest?', 'Románia', 'Panama', 'Egyesült Arab Emírségek', 'Olaszország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7313, 164, 2, 'Melyik ország fővárosa Kigali?', 'Ruanda', 'Pakisztán', 'Egyenlítői-Guinea', 'Costa Rica', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7314, 164, 2, 'Melyik ország fővárosa Honiara?', 'Salamon-szigetek', 'Örményország', 'Ecuador', 'San Marino', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7315, 164, 2, 'Melyik ország fővárosa San Marino?', 'San Marino', 'Oroszország', 'Dzsibuti', 'Chile', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7316, 164, 2, 'Melyik ország fővárosa Victoria?', 'Seychelle-szigetek', 'Omán', 'Dél-Szudán', 'Dominikai Köztársaság', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7317, 164, 2, 'Melyik ország fővárosa Freetown?', 'Sierra Leone', 'Olaszország', 'Dél-Szudán', 'Svédország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7318, 164, 2, 'Melyik ország fővárosa Madrid?', 'Spanyolország', 'Luxemburg', 'Dél-Korea', 'Fidzsi-szigetek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7319, 164, 2, 'Melyik ország fővárosa Paramaribo?', 'Suriname', 'Litvánia', 'Dél-afrikai Köztársaság', 'Jemen', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7320, 164, 2, 'Melyik ország fővárosa Bern?', 'Svájc', 'Liechtenstein', 'Dánia', 'Bosznia-Hercegovina', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7321, 164, 2, 'Melyik ország fővárosa Stockholm?', 'Svédország', 'Líbia', 'Csehország', 'Szingapúr', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7322, 164, 2, 'Melyik ország fővárosa Rijád?', 'Szaúd-Arábia', 'Libéria', 'Csád', 'Bulgária', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7323, 164, 2, 'Melyik ország fővárosa Dakar?', 'Szenegál', 'Libanon', 'Costa Rica', 'Dél-Korea', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7324, 164, 2, 'Melyik ország fővárosa Belgrád?', 'Szerbia', 'Lettország', 'Comore-szigetek', 'Tajvan', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7325, 164, 2, 'Melyik ország fővárosa Szingapúr?', 'Szingapúr', 'Lesotho', 'Ciprus', 'Észtország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7326, 164, 2, 'Melyik ország fővárosa Damaszkusz?', 'Szíria', 'Lengyelország', 'Chile', 'Üzbegisztán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7327, 164, 2, 'Melyik ország fővárosa Pozsony?', 'Szlovákia', 'Laosz', 'Burundi', 'Grúzia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7328, 164, 2, 'Melyik ország fővárosa Ljubljana?', 'Szlovénia', 'Norvégia', 'Burkina Faso', 'Honduras', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7329, 164, 2, 'Melyik ország fővárosa Mogadishu?', 'Szomália', 'Nigéria', 'Bulgária', 'Irán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7330, 164, 2, 'Melyik ország fővárosa Kartúm?', 'Szudán', 'Niger', 'Brazília', 'Izrael', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7331, 164, 2, 'Melyik ország fővárosa Dusanbe?', 'Tádzsikisztán', 'Nicaragua', 'Botswana', 'Bhután', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7332, 164, 2, 'Melyik ország fővárosa Tajpej?', 'Tajvan', 'Nepál', 'Bosznia-Hercegovina', 'Albánia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7333, 164, 2, 'Melyik ország fővárosa Dodoma?', 'Tanzánia', 'Németország', 'Bolívia', 'Japán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7334, 164, 2, 'Melyik ország fővárosa Bangkok?', 'Thaiföld', 'Namíbia', 'Bissau-Guinea', 'Líbia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7335, 164, 2, 'Melyik ország fővárosa Lomé?', 'Togo', 'Mozambik', 'Bhután', 'Tunézia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7336, 164, 2, 'Melyik ország fővárosa Ankara?', 'Törökország', 'Montenegró', 'Belize', 'India', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7337, 164, 2, 'Melyik ország fővárosa Tunisz?', 'Tunézia', 'Mongólia', 'Belgium', 'Mongólia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7338, 164, 2, 'Melyik ország fővárosa Vaiaku?', 'Tuvalu', 'Monaco', 'Barbados', 'Liechtenstein', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7339, 164, 2, 'Melyik ország fővárosa Asgabat?', 'Türkmenisztán', 'Moldova', 'Banglades', 'Tuvalu', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7340, 164, 2, 'Melyik ország fővárosa Kampala?', 'Uganda', 'Mianmar', 'Bahrein', 'Málta', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7341, 164, 2, 'Melyik ország fővárosa Wellington?', 'Új-Zéland', 'Mexikó', 'Bahama-szigetek', 'Lengyelország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7342, 164, 2, 'Melyik ország fővárosa Kijev?', 'Ukrajna', 'Mauritánia', 'Azerbajdzsán', 'Vatikán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7343, 164, 2, 'Melyik ország fővárosa Montevideo?', 'Uruguay', 'Marshall-szigetek', 'Ausztria', 'Seychelle-szigetek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7344, 164, 2, 'Melyik ország fővárosa Taskent?', 'Üzbegisztán', 'Marokkó', 'Ausztrália', 'Laosz', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7345, 164, 2, 'Melyik ország fővárosa Port Vila?', 'Vanuatu', 'Málta', 'Argentína', 'Litvánia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7346, 164, 2, 'Melyik ország fővárosa Vatikánváros?', 'Vatikán', 'Mali', 'Angola', 'Amerikai Egyesült Államok', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7347, 164, 2, 'Melyik ország fővárosa Caracas?', 'Venezuela', 'Maldív-szigetek', 'Andorra', 'Új-Zéland', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7348, 164, 2, 'Melyik ország fővárosa Hanoi?', 'Vietnám', 'Malawi', 'Amerikai Egyesült Államok', 'Namíbia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7349, 164, 2, 'Melyik ország fővárosa Lusaka?', 'Zambia', 'Malajzia', 'Algéria', 'Elefántcsontpart', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7350, 164, 2, 'Melyik ország fővárosa Harare?', 'Zimbabwe', 'Magyarország', 'Albánia', 'Kamerun', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7351, 164, 2, 'Melyik ország fővárosa Praia?', 'Zöld-foki Köztársaság', 'Madagaszkár', 'Afganisztán', 'Horvátország', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7352, 164, 1, 'Mi Afganisztán fővárosa?', 'Kabul', 'Nassau', 'Abu-Dzabi', 'Zágráb', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7353, 164, 1, 'Mi Albánia fővárosa?', 'Tirana', 'Szkopje', 'Abuja', 'Yaoundé', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7354, 164, 1, 'Mi Algéria fővárosa?', 'Algír', 'Baku', 'Accra', 'Yamoussoukro', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7355, 164, 1, 'Mi Andorra fővárosa?', 'Andorra la Vella', 'Canberra', 'Addis Abeba', 'Windhoek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7356, 164, 1, 'Mi Angola fővárosa?', 'Luanda', 'Timpu', 'Algír', 'Wellington', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7357, 164, 1, 'Mi Argentína fővárosa?', 'Buenos Aires', 'Nassau', 'Ammán', 'Washington', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7358, 164, 1, 'Mi Ausztrália fővárosa?', 'Canberra', 'Wellington', 'Amszterdam', 'Vilnius', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7359, 164, 1, 'Mi Azerbajdzsán fővárosa?', 'Baku', 'Gaborone', 'Ankara', 'Victoria', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7360, 164, 1, 'Mi Bahama-szigetek fővárosa?', 'Nassau', 'Bridgetown', 'Antananarivo', 'Vatikánváros', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7361, 164, 1, 'Mi Bahrein fővárosa?', 'Manáma', 'Timpu', 'Asgabat', 'Varsó', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7362, 164, 1, 'Mi Banglades fővárosa?', 'Dakka', 'Belmopan', 'Astana', 'Valletta', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7363, 164, 1, 'Mi Barbados fővárosa?', 'Bridgetown', 'Timpu', 'Asunción', 'Vaiaku', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7364, 164, 1, 'Mi Belgium fővárosa?', 'Brüsszel', 'Szarajevó', 'Aszmara', 'Vaduz', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7365, 164, 1, 'Mi Belize fővárosa?', 'Belmopan', 'Manáma', 'Athén', 'Ulánbátor', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7366, 164, 1, 'Mi Bhután fővárosa?', 'Timpu', 'Bissau', 'Bagdad', 'Újdelhi', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7367, 164, 1, 'Mi Bissau-Guinea fővárosa?', 'Bissau', 'Szarajevó', 'Bairiki', 'Tunisz', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7368, 164, 1, 'Mi Bolívia fővárosa?', 'La Paz', 'Santiago de Chile', 'Baku', 'Tripoli', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7369, 164, 1, 'Mi Bosznia-Hercegovina fővárosa?', 'Szarajevó', 'Podgorica', 'Bamako', 'Tokió', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7370, 164, 1, 'Mi Botswana fővárosa?', 'Gaborone', 'N’Djamena', 'Bangkok', 'Tirana', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7371, 164, 1, 'Mi Brazília fővárosa?', 'Brazíliaváros', 'Moroni', 'Bangui', 'Timpu', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7372, 164, 1, 'Mi Bulgária fővárosa?', 'Szófia', 'Ljubljana', 'Banjul', 'Tel-Aviv', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7373, 164, 1, 'Mi Burkina Faso fővárosa?', 'Ouagadougou', 'Moroni', 'Bécs', 'Teherán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7374, 164, 1, 'Mi Burundi fővárosa?', 'Gitega', 'N’Djamena', 'Bejrút', 'Tegucigalpa', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7375, 164, 1, 'Mi Chile fővárosa?', 'Santiago de Chile', 'Bejrút', 'Belgrád', 'Tbiliszi', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7376, 164, 1, 'Mi Ciprus fővárosa?', 'Nicosia', 'Szarajevó', 'Belmopan', 'Taskent', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7377, 164, 1, 'Mi Comore-szigetek fővárosa?', 'Moroni', 'Tegucigalpa', 'Berlin', 'Tallinn', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7378, 164, 1, 'Mi Costa Rica fővárosa?', 'San José de Costa Rica', 'Juba', 'Bern', 'Tajpej', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7379, 164, 1, 'Mi Csád fővárosa?', 'N’Djamena', 'Quito', 'Biskek', 'Szöul', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7380, 164, 1, 'Mi Csehország fővárosa?', 'Prága', 'Tallinn', 'Bissau', 'Szófia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7381, 164, 1, 'Mi Dánia fővárosa?', 'Koppenhága', 'Szarajevó', 'Bogotá', 'Szingapúr', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7382, 164, 1, 'Mi Dél-afrikai Köztársaság fővárosa?', 'Pretoria', 'Santo Domingo', 'Brazíliaváros', 'Szarajevó', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7383, 164, 1, 'Mi Dél-Szudán fővárosa?', 'Juba', 'Quito', 'Bridgetown', 'Szanaa', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7384, 164, 1, 'Mi Dominikai Köztársaság fővárosa?', 'Santo Domingo', 'Malabo', 'Brüsszel', 'Suva', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7385, 164, 1, 'Mi Dzsibuti fővárosa?', 'Dzsibuti', 'Moroni', 'Budapest', 'Stockholm', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7386, 164, 1, 'Mi Ecuador fővárosa?', 'Quito', 'Caracas', 'Buenos Aires', 'Santo Domingo', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2022-05-07 12:29:18'),
(7387, 164, 1, 'Mi Egyenlítői-Guinea fővárosa?', 'Malabo', 'Abu-Dzabi', 'Bukarest', 'Santiago de Chile', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7388, 164, 1, 'Mi Amerikai Egyesült Államok fővárosa?', 'Washington', 'Bridgetown', 'Canberra', 'San Marino', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7389, 164, 1, 'Mi Egyesült Arab Emírségek fővárosa?', 'Abu-Dzabi', 'Dakka', 'Caracas', 'San José de Costa Rica', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7390, 164, 1, 'Mi Egyiptom fővárosa?', 'Kairó', 'Yamoussoukro', 'Chişinău', 'Róma', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7391, 164, 1, 'Mi Elefántcsontpart fővárosa?', 'Yamoussoukro', 'N’Djamena', 'Conakry', 'Rijád', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7392, 164, 1, 'Mi Eritrea fővárosa?', 'Aszmara', 'Juba', 'Dakar', 'Riga', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7393, 164, 1, 'Mi Észak-Korea fővárosa?', 'Phenjan', 'Szöul', 'Dakka', 'Reykjavík', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7394, 164, 1, 'Mi Észtország fővárosa?', 'Tallinn', 'Vilnius', 'Damaszkusz', 'Rabat', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7395, 164, 1, 'Mi Etiópia fővárosa?', 'Addis Abeba', 'Juba', 'Dodoma', 'Quito', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7396, 164, 1, 'Mi Fehéroroszország fővárosa?', 'Minszk', 'Prága', 'Doha', 'Pretoria', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7397, 164, 1, 'Mi Fidzsi-szigetek fővárosa?', 'Suva', 'Kairó', 'Dublin', 'Praia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7398, 164, 1, 'Mi Finnország fővárosa?', 'Helsinki', 'Tallinn', 'Dusanbe', 'Prága', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7399, 164, 1, 'Mi Franciaország fővárosa?', 'Párizs', 'London', 'Dzsibuti', 'Pozsony', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7400, 164, 1, 'Mi Fülöp-szigetek fővárosa?', 'Manila', 'Minszk', 'Freetown', 'Port-au-Prince', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7401, 164, 1, 'Mi Gabon fővárosa?', 'Libreville', 'Yamoussoukro', 'Gaborone', 'Port Vila', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7402, 164, 1, 'Mi Gambia fővárosa?', 'Banjul', 'Dakar', 'Georgetown', 'Port Moresby', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7403, 164, 1, 'Mi Ghána fővárosa?', 'Accra', 'Kairó', 'Gitega', 'Podgorica', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7404, 164, 1, 'Mi Grúzia fővárosa?', 'Tbiliszi', 'Tegucigalpa', 'Hanoi', 'Phenjan', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7405, 164, 1, 'Mi Guatemala fővárosa?', 'Guatemalaváros', 'Port Vila', 'Harare', 'Peking', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7406, 164, 1, 'Mi Guinea fővárosa?', 'Conakry', 'Manila', 'Havanna', 'Párizs', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7407, 164, 1, 'Mi Guyana fővárosa?', 'Georgetown', 'Nouakchott', 'Helsinki', 'Paramaribo', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7408, 164, 1, 'Mi Haiti fővárosa?', 'Port-au-Prince', 'Helsinki', 'Honiara', 'Panamaváros', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7409, 164, 1, 'Mi Hollandia fővárosa?', 'Amszterdam', 'Tbiliszi', 'Iszlámábád', 'Ouagadougou', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7410, 164, 1, 'Mi Honduras fővárosa?', 'Tegucigalpa', 'Nouakchott', 'Jakarta', 'Ottawa', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7411, 164, 1, 'Mi Horvátország fővárosa?', 'Zágráb', 'Brüsszel', 'Jereván', 'Oslo', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7412, 164, 1, 'Mi India fővárosa?', 'Újdelhi', 'Tbiliszi', 'Juba', 'Nouakchott', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7413, 164, 1, 'Mi Indonézia fővárosa?', 'Jakarta', 'Port-au-Prince', 'Kabul', 'Nicosia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7414, 164, 1, 'Mi Irak fővárosa?', 'Bagdad', 'Jakarta', 'Kairó', 'Niamey', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7415, 164, 1, 'Mi Irán fővárosa?', 'Teherán', 'Tegucigalpa', 'Kampala', 'Nepjida', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7416, 164, 1, 'Mi Írország fővárosa?', 'Dublin', 'Amszterdam', 'Kartúm', 'Nassau', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7417, 164, 1, 'Mi Izland fővárosa?', 'Reykjavík', 'Conakry', 'Katmandu', 'Nairobi', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7418, 164, 1, 'Mi Izrael fővárosa?', 'Tel-Aviv', 'Újdelhi', 'Kigali', 'N’Djamena', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7419, 164, 1, 'Mi Jamaica fővárosa?', 'Kingston', 'Reykjavík', 'Kijev', 'Moszkva', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7420, 164, 1, 'Mi Jemen fővárosa?', 'Szanaa', 'Reykjavík', 'Kinshasa', 'Montevideo', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33');
INSERT INTO `quiz_question` (`id`, `quiz_id`, `difficulty`, `question`, `ans1`, `ans2`, `ans3`, `ans4`, `username`, `is_verified`, `is_active`, `sending_time`, `verified_by`, `verification_time`) VALUES
(7421, 164, 1, 'Mi Jordánia fővárosa?', 'Ammán', 'Jakarta', 'Koppenhága', 'Monrovia', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7422, 164, 1, 'Mi Kambodzsa fővárosa?', 'Phnompen', 'Amszterdam', 'Kuala Lumpur', 'Monaco', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7423, 164, 1, 'Mi Kamerun fővárosa?', 'Yaoundé', 'Újdelhi', 'Kuvaitváros', 'Mogadishu', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7424, 164, 1, 'Mi Kanada fővárosa?', 'Ottawa', 'Dublin', 'La Paz', 'Minszk', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7425, 164, 1, 'Mi Katar fővárosa?', 'Doha', 'Újdelhi', 'Libreville', 'Mexikóváros', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7426, 164, 1, 'Mi Kazahsztán fővárosa?', 'Astana', 'Teherán', 'Lilongwe', 'Maszkat', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7427, 164, 1, 'Mi Kenya fővárosa?', 'Nairobi', 'Majuro', 'Lima', 'Maseru', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7428, 164, 1, 'Mi Kína fővárosa?', 'Peking', 'Phnompen', 'Lisszabon', 'Maputo', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7429, 164, 1, 'Mi Kirgizisztán fővárosa?', 'Biskek', 'Kingston', 'Ljubljana', 'Manila', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7430, 164, 1, 'Mi Kiribati fővárosa?', 'Bairiki', 'Majuro', 'Lomé', 'Manáma', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7431, 164, 1, 'Mi Kolumbia fővárosa?', 'Bogotá', 'Kingston', 'London', 'Managua', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7432, 164, 1, 'Mi Kongói Demokratikus Köztársaság fővárosa?', 'Kinshasa', 'Yaoundé', 'Luanda', 'Malé', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7433, 164, 1, 'Mi Dél-Korea fővárosa?', 'Szöul', 'Yaoundé', 'Lusaka', 'Malabo', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7434, 164, 1, 'Mi Közép-afrikai Köztársaság fővárosa?', 'Bangui', 'Kinshasa', 'Luxembourg', 'Majuro', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7435, 164, 1, 'Mi Kuba fővárosa?', 'Havanna', 'Kinshasa', 'Madrid', 'Madrid', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7436, 164, 1, 'Mi Kuvait fővárosa?', 'Kuvaitváros', 'Manila', 'Majuro', 'Luxembourg', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7437, 164, 1, 'Mi Laosz fővárosa?', 'Vientián', 'Majuro', 'Malabo', 'Lusaka', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7438, 164, 1, 'Mi Lengyelország fővárosa?', 'Varsó', 'Manila', 'Malé', 'Luanda', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7439, 164, 1, 'Mi Lesotho fővárosa?', 'Maseru', 'Nairobi', 'Managua', 'London', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7440, 164, 1, 'Mi Lettország fővárosa?', 'Riga', 'Bogotá', 'Manáma', 'Lomé', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7441, 164, 1, 'Mi Libanon fővárosa?', 'Bejrút', 'Kuala Lumpur', 'Manila', 'Ljubljana', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7442, 164, 1, 'Mi Libéria fővárosa?', 'Monrovia', 'Szöul', 'Maputo', 'Lisszabon', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7443, 164, 1, 'Mi Líbia fővárosa?', 'Tripoli', 'Kuala Lumpur', 'Maseru', 'Lima', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7444, 164, 1, 'Mi Liechtenstein fővárosa?', 'Vaduz', 'Riga', 'Maszkat', 'Lilongwe', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7445, 164, 1, 'Mi Litvánia fővárosa?', 'Vilnius', 'Vaduz', 'Mexikóváros', 'Libreville', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7446, 164, 1, 'Mi Luxemburg fővárosa?', 'Luxembourg', 'Havanna', 'Minszk', 'La Paz', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7447, 164, 1, 'Mi Madagaszkár fővárosa?', 'Antananarivo', 'Libreville', 'Mogadishu', 'Kuvaitváros', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7448, 164, 1, 'Mi Magyarország fővárosa?', 'Budapest', 'Bukarest', 'Monaco', 'Kuala Lumpur', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7449, 164, 1, 'Mi Malajzia fővárosa?', 'Kuala Lumpur', 'Lilongwe', 'Monrovia', 'Koppenhága', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7450, 164, 1, 'Mi Malawi fővárosa?', 'Lilongwe', 'Tripoli', 'Montevideo', 'Kinshasa', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7451, 164, 1, 'Mi Maldív-szigetek fővárosa?', 'Malé', 'Tripoli', 'Moroni', 'Kingston', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7452, 164, 1, 'Mi Mali fővárosa?', 'Bamako', 'Kuala Lumpur', 'Moszkva', 'Kijev', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7453, 164, 1, 'Mi Málta fővárosa?', 'Valletta', 'Vaduz', 'N’Djamena', 'Kigali', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7454, 164, 1, 'Mi Marokkó fővárosa?', 'Rabat', 'Libreville', 'Nairobi', 'Katmandu', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7455, 164, 1, 'Mi Marshall-szigetek fővárosa?', 'Majuro', 'Libreville', 'Nassau', 'Kartúm', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7456, 164, 1, 'Mi Mauritánia fővárosa?', 'Nouakchott', 'Lilongwe', 'Nepjida', 'Kampala', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7457, 164, 1, 'Mi Mexikó fővárosa?', 'Mexikóváros', 'Valletta', 'Niamey', 'Kairó', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7458, 164, 1, 'Mi Mianmar fővárosa?', 'Nepjida', 'Katmandu', 'Nicosia', 'Kabul', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7459, 164, 1, 'Mi Moldova fővárosa?', 'Chişinău', 'Bukarest', 'Nouakchott', 'Juba', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7460, 164, 1, 'Mi Monaco fővárosa?', 'Monaco', 'Dublin', 'Oslo', 'Jereván', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7461, 164, 1, 'Mi Montenegró fővárosa?', 'Podgorica', 'Nouakchott', 'Ouagadougou', 'Iszlámábád', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7462, 164, 1, 'Mi Mozambik fővárosa?', 'Maputo', 'Katmandu', 'Panamaváros', 'Honiara', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7463, 164, 1, 'Mi Egyesült Királyság fővárosa?', 'London', 'Dublin', 'Paramaribo', 'Helsinki', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7464, 164, 1, 'Mi Németország fővárosa?', 'Berlin', 'Brüsszel', 'Peking', 'Harare', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7465, 164, 1, 'Mi Nepál fővárosa?', 'Katmandu', 'Windhoek', 'Phenjan', 'Hanoi', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7466, 164, 1, 'Mi Nicaragua fővárosa?', 'Managua', 'Ulánbátor', 'Phnompen', 'Guatemalaváros', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7467, 164, 1, 'Mi Niger fővárosa?', 'Niamey', 'Katmandu', 'Podgorica', 'Gitega', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7468, 164, 1, 'Mi Nigéria fővárosa?', 'Abuja', 'Managua', 'Port Moresby', 'Georgetown', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7469, 164, 1, 'Mi Norvégia fővárosa?', 'Oslo', 'Stockholm', 'Port Vila', 'Gaborone', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7470, 164, 1, 'Mi Olaszország fővárosa?', 'Róma', 'Oslo', 'Port-au-Prince', 'Freetown', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7471, 164, 1, 'Mi Omán fővárosa?', 'Maszkat', 'Niamey', 'Pozsony', 'Dzsibuti', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7472, 164, 1, 'Mi Oroszország fővárosa?', 'Moszkva', 'Oslo', 'Prága', 'Dusanbe', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7473, 164, 1, 'Mi Örményország fővárosa?', 'Jereván', 'Managua', 'Praia', 'Dublin', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7474, 164, 1, 'Mi Pakisztán fővárosa?', 'Iszlámábád', 'Maszkat', 'Pretoria', 'Doha', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7475, 164, 1, 'Mi Panama fővárosa?', 'Panamaváros', 'Maputo', 'Quito', 'Dodoma', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7476, 164, 1, 'Mi Pápua Új-Guinea fővárosa?', 'Port Moresby', 'Niamey', 'Rabat', 'Damaszkusz', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7477, 164, 1, 'Mi Paraguay fővárosa?', 'Asunción', 'Managua', 'Reykjavík', 'Dakka', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7478, 164, 1, 'Mi Peru fővárosa?', 'Lima', 'Maputo', 'Riga', 'Dakar', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7479, 164, 1, 'Mi Portugália fővárosa?', 'Lisszabon', 'Lima', 'Rijád', 'Conakry', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7480, 164, 1, 'Mi Románia fővárosa?', 'Bukarest', 'Madrid', 'Róma', 'Chişinău', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7481, 164, 1, 'Mi Ruanda fővárosa?', 'Kigali', 'Honiara', 'San José de Costa Rica', 'Caracas', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7482, 164, 1, 'Mi Salamon-szigetek fővárosa?', 'Honiara', 'Lima', 'San Marino', 'Canberra', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7483, 164, 1, 'Mi San Marino fővárosa?', 'San Marino', 'Honiara', 'Santiago de Chile', 'Bukarest', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7484, 164, 1, 'Mi Seychelle-szigetek fővárosa?', 'Victoria', 'Niamey', 'Santo Domingo', 'Buenos Aires', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7485, 164, 1, 'Mi Sierra Leone fővárosa?', 'Freetown', 'Asunción', 'Stockholm', 'Budapest', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7486, 164, 1, 'Mi Spanyolország fővárosa?', 'Madrid', 'Lisszabon', 'Suva', 'Brüsszel', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7487, 164, 1, 'Mi Suriname fővárosa?', 'Paramaribo', 'Kigali', 'Szanaa', 'Bridgetown', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7488, 164, 1, 'Mi Svájc fővárosa?', 'Bern', 'Belgrád', 'Szarajevó', 'Brazíliaváros', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7489, 164, 1, 'Mi Svédország fővárosa?', 'Stockholm', 'Rijád', 'Szingapúr', 'Bogotá', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7490, 164, 1, 'Mi Szaúd-Arábia fővárosa?', 'Rijád', 'Asunción', 'Szófia', 'Bissau', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7491, 164, 1, 'Mi Szenegál fővárosa?', 'Dakar', 'Belgrád', 'Szöul', 'Biskek', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7492, 164, 1, 'Mi Szerbia fővárosa?', 'Belgrád', 'Damaszkusz', 'Tajpej', 'Bern', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7493, 164, 1, 'Mi Szingapúr fővárosa?', 'Szingapúr', 'Pozsony', 'Tallinn', 'Berlin', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7494, 164, 1, 'Mi Szíria fővárosa?', 'Damaszkusz', 'Dakar', 'Taskent', 'Belmopan', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7495, 164, 1, 'Mi Szlovákia fővárosa?', 'Pozsony', 'Isztambul', 'Tbiliszi', 'Belgrád', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7496, 164, 1, 'Mi Szlovénia fővárosa?', 'Ljubljana', 'Belgrád', 'Tegucigalpa', 'Bejrút', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7497, 164, 1, 'Mi Szomália fővárosa?', 'Mogadishu', 'Ljubljana', 'Teherán', 'Bécs', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7498, 164, 1, 'Mi Szudán fővárosa?', 'Kartúm', 'Rijád', 'Tel-Aviv', 'Banjul', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7499, 164, 1, 'Mi Tádzsikisztán fővárosa?', 'Dusanbe', 'Asgabat', 'Timpu', 'Bangui', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7500, 164, 1, 'Mi Tajvan fővárosa?', 'Tajpej', 'Dodoma', 'Tirana', 'Bangkok', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7501, 164, 1, 'Mi Tanzánia fővárosa?', 'Dodoma', 'Dakar', 'Tokió', 'Bamako', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7502, 164, 1, 'Mi Thaiföld fővárosa?', 'Bangkok', 'Ljubljana', 'Tripoli', 'Baku', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7503, 164, 1, 'Mi Togo fővárosa?', 'Lomé', 'Kampala', 'Tunisz', 'Bairiki', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7504, 164, 1, 'Mi Törökország fővárosa?', 'Ankara', 'Isztambul', 'Újdelhi', 'Bagdad', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7505, 164, 1, 'Mi Tunézia fővárosa?', 'Tunisz', 'Dodoma', 'Ulánbátor', 'Athén', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7506, 164, 1, 'Mi Tuvalu fővárosa?', 'Vaiaku', 'Kampala', 'Vaduz', 'Aszmara', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7507, 164, 1, 'Mi Türkmenisztán fővárosa?', 'Asgabat', 'Lomé', 'Vaiaku', 'Asunción', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7508, 164, 1, 'Mi Uganda fővárosa?', 'Kampala', 'Asgabat', 'Valletta', 'Astana', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7509, 164, 1, 'Mi Új-Zéland fővárosa?', 'Wellington', 'Canberra', 'Varsó', 'Asgabat', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7510, 164, 1, 'Mi Ukrajna fővárosa?', 'Kijev', 'Montevideo', 'Vatikánváros', 'Antananarivo', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7511, 164, 1, 'Mi Üzbegisztán fővárosa?', 'Taskent', 'Port Vila', 'Vientián', 'Andorra la Vella', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7512, 164, 1, 'Mi Vanuatu fővárosa?', 'Port Vila', 'Asgabat', 'Vilnius', 'Amszterdam', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7513, 164, 1, 'Mi Vatikán fővárosa?', 'Vatikánváros', 'Hanoi', 'Washington', 'Ammán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7514, 164, 1, 'Mi Venezuela fővárosa?', 'Caracas', 'Kampala', 'Wellington', 'Algír', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7515, 164, 1, 'Mi Vietnám fővárosa?', 'Hanoi', 'Asgabat', 'Windhoek', 'Addis Abeba', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7516, 164, 1, 'Mi Zambia fővárosa?', 'Lusaka', 'Caracas', 'Yamoussoukro', 'Accra', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7517, 164, 1, 'Mi Zöld-foki Köztársaság fővárosa?', 'Praia', 'Lusaka', 'Zágráb', 'Abu-Dzabi', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7518, 164, 2, 'Melyik főváros található Európában az alábbiak közül?', 'Minszk', 'Bagdad', 'Lusaka', 'Algír', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7519, 164, 2, 'Melyik főváros található Európában az alábbiak közül?', 'Nicosia', 'Jakarta', 'Kabul', 'Ammán', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7520, 164, 2, 'Melyik főváros található Európában az alábbiak közül?', 'Szarajevó', 'Rijád', 'Jereván', 'Accra', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7521, 164, 2, 'Melyik főváros található Ázsiában az alábbiak közül?', 'Kuala Lumpur', 'London', 'Algír', 'Amszterdam', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7522, 164, 2, 'Melyik főváros található Ázsiában az alábbiak közül?', 'Ulánbátor', 'Kijev', 'Wellington', 'Varsó', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7523, 164, 2, 'Melyik főváros található Ázsiában az alábbiak közül?', 'Tajpej', 'Kairó', 'Bern', 'San Salvador', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7524, 164, 2, 'Melyik főváros található Afrikában az alábbiak közül?', 'Lusaka', 'Montevideo', 'Peking', 'Bejrút', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7525, 164, 2, 'Melyik főváros található Afrikában az alábbiak közül?', 'Bissau', 'Dakka', 'Jeruzsálem', 'Újdelhi', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7526, 164, 2, 'Melyik főváros található Afrikában az alábbiak közül?', 'Rabat', 'Teherán', 'Tokió', 'Phenjan', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7527, 164, 2, 'Melyik főváros található Észak-Amerikában az alábbiak közül?', 'Havanna', 'Montevideo', 'Lima', 'Bogotá', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7528, 164, 2, 'Melyik főváros található Észak-Amerikában az alábbiak közül?', 'Guatemalaváros', 'Brazíliaváros', 'Caracas', 'Kairó', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7529, 164, 2, 'Melyik főváros található Észak-Amerikában az alábbiak közül?', 'Ottawa', 'Georgetown', 'Quito', 'Kisinyov', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7530, 164, 2, 'Melyik főváros található Dél-Amerikában az alábbiak közül?', 'Sucre', 'Washington D.C.', 'Havanna', 'Port-au-Prince', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7531, 164, 2, 'Melyik főváros található Dél-Amerikában az alábbiak közül?', 'Paramaribo', 'Mexikóváros', 'Belmopan', 'San Salvador', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7532, 164, 2, 'Melyik főváros található Dél-Amerikában az alábbiak közül?', 'Asunción', 'Managua', 'Ottawa', 'Rijád', 'sss', 1, 1, '2021-07-19 16:57:00', 15, '2021-09-26 20:27:33'),
(7545, 176, 2, 'Mennyi 66*24?', '1584', '1524', '1472', '1658', 'aaaa', 1, 1, '2021-09-08 11:41:39', 15, '2021-09-28 00:27:20'),
(7546, 176, 2, 'Mennyi 20*47?', '940', '520', '675', '860', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7547, 176, 1, 'Mennyi 50*50?', '2500', '250', '1000', '5050', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7548, 176, 1, 'Milyen számra végződik 6 a 16.-ik hatványon?', '6', '0', '2', '4', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7549, 176, 1, 'Melyik a nagyobb: 2 a 3.-ik hatványon, vagy 3 a 2.-ik hatványon?', '3 a 2.-ik hatványon', '2 a 3.-ik hatványon', 'egyenlők', 'nem lehet eldönteni', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7550, 176, 1, 'Mennyi 11*11?', '121', '111', '101', '1111', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7551, 176, 2, 'Melyik nagyobb: 12*36, vagy 18*24?', 'egyenlők', '12*36', '18*24', 'nem lehet eldönteni', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7552, 176, 2, 'Melyik kisebb: 70*21, vagy 35*48?', '70*21', '35*48', 'egyenlők', 'nem lehet eldönteni', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7553, 176, 2, 'Mennyivel kell megszorozni a 25-t ahhoz, hogy 900-at kapjunk?', '36', '25', '50', '28', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7554, 176, 1, 'Mennyi 100*10?', '1000', '10000', '100000', '1100', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7555, 176, 1, 'Mennyi 9*56?', '504', '402', '603', '306', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7556, 176, 2, 'Melyik osztás végezhető el maradék nélkül az alábbiak közül?', '72/3', '46/6', '54/7', '69/13', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7557, 176, 2, 'Mennyi 500/25?', '20', '25', '15', '30', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7558, 176, 1, 'Mennyi 1 a 100.-ik hatványon?', '1', '0', '100', 'egy több mint 100 számjegyből álló szám', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7559, 176, 2, 'Mennyi 400/80?', '5', '6', '15', '20', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7560, 176, 1, 'Mennyi 80*80?', '6400', '640', '8000', '8080', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7561, 176, 2, 'Melyik NEM a 2 hatványa?', '224', '2', '16', '512', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7562, 176, 2, 'Mennyi 666/9?', '74', '78', '68', '64', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7563, 176, 2, 'Mennyi 213 / 71?', '3', '4', '5', 'nem osztható maradék nélkül', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7564, 176, 1, 'Mennyi 333/111?', '3', '33', '11', '1', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7565, 176, 1, 'Mennyi 38/4?', 'nem osztható maradék nélkül', '9', '8', '7', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7566, 176, 2, 'Mennyi 65/5?', '13', '12', '14', '15', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7567, 176, 2, 'Melyik a nagyobb: 74/21, vagy 90/43?', '74/21', '90/43', 'egyenlők', 'nem lehet eldönteni', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7568, 176, 2, 'Melyik a kisebb: 222/13, vagy 333/26?', '333/26', '222/13', 'egyenlők', 'nem lehet eldönteni', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7569, 176, 1, 'Melyik NEM az 5 hatványa az alábbiak közül?', '21', '65', '80', '100', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7570, 176, 2, 'Mennyi 43*17 – 17*42?', '17', '18', '27', '28', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7571, 176, 1, 'Mennyi 0*500?', '0', '500', '501', '1', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7572, 176, 2, 'Mennyi 11*500?', '550', '505', '500', '555', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7573, 176, 2, 'Mennyi 29*69 - 67*29?', '58', '29', '38', '19', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7574, 176, 2, 'Mennyi (41-31)*(41+31)?', '720', '410', '310', '700', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7575, 176, 2, 'Mennyi (2+9) a 2.-ik hatványon?', '121', '290', '219', '129', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7576, 176, 2, 'Mennyi (12)^2 – (11)^2?', '23', '22', '21', '24', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7577, 176, 2, 'Mennyi 111*111?', '12321', '11111', '12221', '13331', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7578, 176, 2, 'Mennyi 1/0?', 'nem határozható meg egyértelműen', '0', '1', 'ez az osztás nem létezik', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7579, 176, 1, 'Mennyi 0/1?', '0', '1', 'nem határozható meg egyértelműen', 'ez az osztás nem létezik', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7580, 176, 2, 'Mennyi 0/0?', 'nem határozható meg egyértelműen', '0', '1', 'ez az osztás nem létezik', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7581, 176, 2, 'Mennyi az alábbi műveletsor eredménye: (45-16)*(23-71)*(10-10)*(1-2)?', '0', 'egy negatív szám', '1', '10', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7582, 176, 1, 'Mennyi 1/1?', '1', '0', '-1', 'nem határozható meg egyértelműen', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7583, 176, 1, 'Mennyi 20*20?', '400', '410', '420', '200', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7584, 176, 2, 'Mennyi 10/5*5?', '10', '0.4', '4', '0.25', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7585, 176, 2, 'Mennyi 19/13*13?', '19', '13', '0.11', '20', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7586, 176, 1, 'Mennyi 40*30?', '1200', '120', '2400', '3600', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7587, 176, 2, 'Mennyi 7*7*7?', '343', '243', '2401', '401', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7588, 176, 2, 'Mennyi 9*9*9 – 9^2?', '648', '999', '749', '589', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7589, 176, 1, 'Mennyi 51/17?', '3', '4', '2', '5', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7590, 176, 2, 'Mennyi (61-19)*2?', '84', '61', '72', '69', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7591, 176, 1, 'Mennyi 144*144?', '20736', '10990', '14422', '18888', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7592, 176, 2, 'Mennyi (80-79)*(80+79)?', '159', '149', '169', '179', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7593, 176, 2, 'Mennyi (60+59)/(60-59)?', '119', '129', '109', '139', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7594, 176, 2, 'Melyik nagyobb: 666*3, vagy 333*6?', 'egyenlők', '666*3', '333*6', 'nem lehet eldönteni', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7595, 176, 1, 'Mennyi (22+44)*1?', '66', '24', '42', '67', 'aaaa', 1, 1, '2021-09-08 13:15:00', 15, '2021-09-26 20:27:33'),
(7645, 177, 1, 'Minek a rövidítése a HTML?', 'Hyper Text Markup Language ', 'Home Tool Markup Language', 'Hyperlinks and Text Markup Language', 'Hyper Transfer Markup Language', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7646, 177, 2, 'Melyik állítás hamis az alábbiak közül?', 'a HTML fájlok megnyitásához egy webszerverre van szükség', 'a HTML-t weboldalak létrehozásánál használják', 'a HTML elemek sorozatából áll', 'a HTML-elemek megmondják a böngészőnek, hogyan kell megjeleníteni a tartalmat', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7647, 177, 2, 'Mit jelent a <!DOCTYPE html> deklaráció?', 'hogy a dokumentum egy HTML5 dokumentum', 'az oldal címét határozza meg', 'az oldal legelső bekezdését határozza meg', 'metaadatokat tartalmaz a HTML-oldalról', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7648, 177, 1, 'Melyik a HTML oldal gyökér eleme (root element)?', '<html>', '<head>', '<meta>', '<body>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7649, 177, 2, 'Melyik html-elem tartalmaz meta információkat a HTML oldalról?', '<head>', '<body>', '<script>', '<html>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7650, 177, 1, 'Melyik html-elem határozza meg az oldal címét, amely a böngésző címsorában, vagy az oldal lapján jelenik meg?', '<title>', '<h1>', '<head>', '<h2>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7651, 177, 1, 'Melyik html-elem határozza meg az oldal törzsét és tárolja az összes látható tartalmat?', '<body>', '<head>', '<script>', '<h1>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7652, 177, 1, 'Melyik html-elem jelenít meg nagyobb címsort?', '<h1>', '<h2>', '<h3>', '<p>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7653, 177, 1, 'Mire használjuk a <p> elemet?', 'bekezdés megjelenítésére', 'új sor megjelenítésére', 'címsor megjelenítésére', 'kép megjelenítésére', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7654, 177, 1, 'Adott az alábbi html-elem: <h1>My First Heading</h1> Melyik a kezdőcímke (start tag)?', '<h1>', '</h1>', 'My First Heading', 'az adott elemben nem található kezdőcímke', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7655, 177, 1, 'Adott az alábbi html-elem: <h1>My First Heading</h1> Melyik a végcímke (end tag)?', '</h1>', '<h1>', 'My First Heading', 'az adott elemben nem található kezdőcímke', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7656, 177, 2, 'Melyik html-elem egy üres elem, mert nem tartalmaz semmilyen tartalmat az alábbiak közül (empty element)?', '<br>', '<p>', '<ul>', '<meta>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7657, 177, 1, 'Melyik html-elemmel szúrhatunk be egy új sort?', '<br>', '<break>', '<bl>', '<lb>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7658, 177, 2, 'Meddig megy a html-heading elemek számozása?', '<h1> -től <h6> -ig', '<h1> -től <h10> -ig', '<h1> -től <h9> -ig', '<h1> -től <h3> -ig', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7659, 177, 2, 'Melyik html-elemmel jeleníthető meg egy vízszintes vonal?', '<hr>', '<vh>', '<lb>', '<br>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7660, 177, 1, 'Melyik html-elemmel jeleníthetők meg többszörös szóközök, vagy bekezdések?', '<pre>', '<br>', '<hr>', '<h1>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7661, 177, 1, 'Melyik attribútummal lehet stílust beállítani egy html-elemre?', 'style', 'design', 'target', 'background', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7662, 177, 1, 'Melyik html-elem az alábbiak közül?', 'center', 'background-color', 'text-align', 'color', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7663, 177, 1, 'Mire használjuk a <b> tag-et?', 'vastagított szöveg megjelenítésére', 'dőlt betűs szöveg megjelenítésére', 'aláhúzott szöveg megjelenítésére', 'alsó index megjelenítésére', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7664, 177, 1, 'Mire használjuk az <i> tag-et?', 'dőlt betűs szöveg megjelenítésére', 'vastagított szöveg megjelenítésére', 'aláhúzott szöveg megjelenítésére', 'alsó index megjelenítésére', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7665, 177, 1, 'Mire használjuk az <u> tag-et?', 'aláhúzott szöveg megjelenítésére', 'dőlt betűs szöveg megjelenítésére', 'vastagított szöveg megjelenítésére', 'felső index megjelenítésére', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7666, 177, 1, 'Melyik tag-et használjuk kisbetűs szöveg megjelenítésére?', '<small>', '<h3>', '<h2>', '<p>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7667, 177, 1, 'Melyik tag-et használjuk szöveg kiemelésére (hátterét kiszínezi)?', '<mark>', '<del>', '<em>', '<b>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7668, 177, 2, 'Mit jelenít meg a <del> tag?', 'egy középen áthúzott szöveget', 'törölt szöveget, ami ugyebár nem látható', 'kiemelt szöveget', 'idézett szöveget', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7669, 177, 2, 'Melyik html-elem kelti ugyanazt a hatást, mint az <u> tag?', '<ins>', '<del>', '<em>', '<b>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7670, 177, 1, 'Melyik html-elemet használjuk, ha alsó indexben szeretnénk egy számot megjeleníteni (például a víz képletét, a H2O-t)?', '<sub>', '<sup>', '<ins>', '<em>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7671, 177, 1, 'Melyik html-elemet használjuk, ha felső indexben szeretnénk egy számot megjeleníteni (például egy hatványkitevőt)?', '<sup>', '<sub>', '<ins>', '<em>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7672, 177, 2, 'Mire használjuk a <blockquote> elemet?', 'ha egy más forrásból idézett szöveget kell megjeleníteni', 'ha idézőjelek között akarunk egy szöveget megjeleníteni', 'ha sortördelések nélkül akarunk szöveget megjeleníteni', 'ha oldaltörés nélkül kell szöveget megjeleníteni', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7673, 177, 1, 'Mit csinál a <q> tag?', 'idézőjelek között jelenít meg szöveget', 'kiemeli a szöveget egy háttérszínnel', 'apró betűs szöveget jelenít meg', 'aláhúzott szöveget jelenít meg', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7674, 177, 1, 'Mire használjuk az <address> elemet?', 'ha a szerző/tulajdonos elérhetőségével kapcsolatos információkat akarunk megjeleníteni', 'ha egy más forrásból idézett szöveget kell megjeleníteni', 'ha idézőjelek között akarunk egy szöveget megjeleníteni', 'ha fontos szöveget akarunk megjeleníteni', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7675, 177, 2, 'Létezik-e, és ha igen mi a hatása a <bdo dir=\"rtl\"> elemnek?', 'igen, jobbról balra olvasva jelenít meg szöveget', 'igen, kiemeli a szöveget egy háttérszínnel', 'igen, bekeretezetten jelenít meg szöveget', 'nincs ilyen elem html-ben', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7676, 177, 2, 'Hogyan kell comment-eket írni HTML-ben?', '<!-- és -->', '/* és */', '-- és /--', '<- és /->', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7677, 177, 1, 'Hogyan állíthatjuk be egy bekezdés szövegének színét kékre?', '<p style = \"color: blue;\">Lorem ipsum...</p>', '<p style = \"background-color: blue;\">Lorem ipsum...</p>', '<p style = \"bgcolor: blue;\">Lorem ipsum...</p>', '<br style = \"color: blue;\">Lorem ipsum...</br>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7678, 177, 2, 'Hogyan állíthatjuk be egy címsor keretének színét pirosra?', '<h1 style=\"border: 2px solid red;\">Hello World</h1>', '<h1 style=\"bgcolor: 2px solid red;\">Hello World</h1>', '<h1 style=\" background-color: 2px solid red;\">Hello World</h1>', '<h1 style=\"border: red;\">Hello World</h1>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7679, 177, 2, 'Hányféleképpen adható stílus egy html-elemre?', '3', '2', '4', '5', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7680, 177, 2, 'Melyik az Inline formája a CSS  html-elemhez való hozzáadásának?', 'a style attribútum használata', 'a <style> elem használata', 'a <link> elem használata', 'a <script> elem használata', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7681, 177, 2, 'Melyik az Internal formája a CSS html-elemhez való hozzáadásának?', 'a <style> elem használata', 'a style attribútum használata', 'a <link> elem használata', 'a <script> elem használata', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7682, 177, 2, 'Melyik az External formája a CSS html-elemhez való hozzáadásának?', 'a <link> elem használata', 'a <style> elem használata', 'a style attribútum használata', 'a <script> elem használata', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7683, 177, 1, 'Melyik elemmel hozható létre hyperlink (link)?', '<a>', '<link>', '<h>', 'href', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7684, 177, 1, 'Mit határoz meg a target attribútum a Hyperlinkek esetében?', 'a dokumentum megnyitásának helyét', 'a dokumentum megnyitásának idejét', 'a dokumentum megnyitásának módját', 'azt a tartalmat, amit abban az esetben kell megjeleníteni, ha a link nem elérhető', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7685, 177, 1, 'Melyik elemmel jeleníthetünk meg képet?', '<img>', '<image>', '<a>', '<photo>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7686, 177, 1, 'Mit jelent az alt attribútum egy kép esetén?', 'egy szöveget, amit akkor kell megjeleníteni, ha nem sikerült betölteni a képet', 'egy szöveget, amelyet a kép alá szeretnénk illeszteni', 'egy szöveget, amelyet a kép fölé szeretnénk illeszteni', 'egy másodlagos képet, amit akkor kell megjeleníteni, ha nem sikerült betölteni az eredeti képet', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7687, 177, 1, 'Hogyan hozhatunk létre táblázatot HTML-ben?', '<table>', '<tbl>', '<td>', '<th>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7688, 177, 1, 'Mi jelöli a táblázat fejlécét (első sorát) HTML-ben?', '<th>', '<td>', '<tr>', '<header>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7689, 177, 1, 'Hivel szúrható be új sor egy táblázatban HTML-ben?', '<tr>', '<td>', '<table>', '<ts>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7690, 177, 1, 'Melyik attribútummal egyesíthető 2 oszlop egy táblázatban HTML-ben?', 'colspan', 'rowspan', 'tabspan', 'span', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7691, 177, 1, 'Melyik attribútummal egyesíthető 2 sor egy táblázatban HTML-ben?', 'rowspan', 'colspan', 'tabspan', 'span', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7692, 177, 1, 'Melyik elemmel hozhatunk létre számozott listát HTML-ben?', '<ol>', '<ul>', '<li>', '<th>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7693, 177, 1, 'Melyik elemmel hozhatunk létre számozatlan listát HTML-ben?', '<ul>', '<ol>', '<li>', '<th>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7694, 177, 1, 'Melyik elemmel adhatunk hozzá új elemet egy listához HTML-ben?', '<li>', '<ul>', '<ol>', '<th>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7695, 177, 2, 'Melyik blokkszintű elem az alábbiak közül?', '<fieldset>', '<map>', '<span>', '<input>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7696, 177, 2, 'Melyik blokkszintű elem az alábbiak közül?', '<div>', '<label>', '<textarea>', '<select>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7697, 177, 2, 'Melyik Inline színtű elem az alábbiak közül?', '<button>', '<form>', '<footer>', '<video>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7698, 177, 1, 'Mire használjuk az <iframe> elemet?', 'weboldal megjelenítésére egy másik weboldalon belül', 'új webpage-en jeleníteni meg egy weboldalt', 'kis méretben megjeleníteni a weboldalt', 'weboldal megjelenítésére egy másik böngészőben', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7699, 177, 1, 'Melyik html-elem közé írhatunk JavaScript kódot?', '<script>', '<link>', '<html>', '<js>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7700, 177, 2, 'Melyik NEM attribútuma a <meta> elemnek?', 'rel', 'charset', 'name', 'content', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7701, 177, 1, 'Melyik elemet használjuk, ha programozás kódot akarunk megjeleníteni?', '<code>', '<pre>', '<fieldset>', '<var>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7702, 177, 2, 'Melyik a kakukktojás az alábbiak közül?', '<tbl>', '<kbd>', '<samp>', '<var>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7703, 177, 2, 'Melyik html-elemmel állíthatjuk be az oldal karakterkészletét?', '<meta>', '<samp>', '<char>', '<set>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7704, 177, 1, 'Melyik elem segítségével gyűjthetünk be adatokat a felhasználóktól?', '<form>', '<link>', '<script>', '<nav>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7705, 177, 1, 'Hogyan hozhatunk létre szövegbeviteli mezőt?', '<input type=\"text\">', '<input type=\"submit\">', '<input type=\"checkbox\">', '<input type=\"radio\">', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7706, 177, 1, 'Hogyan hozhatunk létre jelölőnégyzetet?', '<input type=\"checkbox\">', '<input type=\"radio\">', '<input type=\"text\">', '<input type=\"submit\">', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7707, 177, 1, 'Melyik elem segítségével hozhatunk létre nagyobb/terjedelmesebb szövegbeviteli részt?', '<textarea>', '<datalist>', '<label>', '<select>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7708, 177, 2, 'Melyik elem nincsen HTML-ben az alábbiak közül?', '<input type=\"mobiltel\">', '<input type=\"color\">', '<input type=\"month\">', '<input type=\"url\">', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7709, 177, 1, 'Melyik attribútummal tehető egy button inaktívvá?', 'disabled', 'enabled', 'inactive', 'freezed', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7710, 177, 1, 'Melyik attribútummal tehető input mező kötelezően kitöltendővé?', 'required', 'enabled', 'readonly', 'filled', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7711, 177, 1, 'Melyik elem segítségével jeleníthetünk meg és játszhatunk le egy videót?', '<video>', '<media>', '<file>', '<source>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7712, 177, 1, 'Melyik elem segítségével jeleníthetünk meg és játszhatunk le hanganyagot?', '<audio>', '<video>', '<media>', '<file>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7713, 177, 1, 'Hogyan állítható be egy oldal háttérszíne sárgára?', '<body style=\"background-color:yellow;\">', '<background> yellow</background>', '<body bg=\"yellow\">', '<body background-color:yellow>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7714, 177, 1, 'Hogyan tudunk új ablakban/böngészőben megnyitni egy oldalt?', '<a href=\"url\" target=\"_blank\"> ', '<a href=\"url\" target=\"new\">', '<a href=\"url\" target=\"_newpage\">', '<a href=\"url\" new>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7715, 177, 1, 'Melyek mind <table> elemek?', '<table> <tr> <td> ', '<table> <tr> <tt>', '<thead> <body> <tr>', '<table> <head> <tfoot>', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7716, 177, 1, 'Mire használható a HTML <canvas> eleme?', 'grafika rajzolására / megjelenítésre', 'MySQL-ben történő adatok lekérdezésére', 'húzható elemek (drag and drop) létrehozására', 'adatok manipulálására MySQL-ben', 'aaaa', 1, 1, '2021-09-09 17:19:00', 15, '2021-09-26 20:27:33'),
(7721, 11, 1, 'Melyik jellegzetes nap előtti napon ünneplik a Halloween-t?', 'Mindenszentek', 'Halottak napja', 'Anyák napja', 'Apák napja', 'sss', 1, 1, '2021-10-19 12:56:27', 15, '2021-10-19 13:51:03'),
(7722, 11, 2, 'Melyik ősi nép szerint volt Halloween az év utolsó napja?', 'kelták', 'vikingek', 'sumerok', 'héberek', 'sss', 1, 1, '2021-10-19 12:57:15', 15, '2021-10-19 13:50:12'),
(7725, 11, 1, 'Hogyan kezdődött Halloween ünneplése?', 'A Samhain – egy kelta fesztivál – része volt eredetileg', 'Alkalomteremtés volt, hogy sok édességet ehessünk', 'Boszorkányoktól átvett rituálé volt', 'Egy Harry Potter könyvből vett ünnepség volt', 'sss', 1, 1, '2021-10-19 13:04:51', 15, '2021-10-19 13:44:21'),
(7726, 11, 1, 'Milyen élelmiszerből láthatunk sokat Halloweenkor?', 'faragott sütőtököt', 'pizsamás banánokat', 'zöldborsópürét', 'padlizsánt', 'sss', 1, 1, '2021-10-19 13:06:13', 15, '2021-10-19 13:45:58'),
(7727, 11, 1, 'Miért gondolják a felnőttek, hogy a Halloween nem jó a gyerekeknek?', 'mert a \"csokit vagy csalok\" játék veszélyes lehet', 'mert még túl fiatalok, hogy másokat ijesztgessenek', 'mert a jelmezeik nem elég ijesztőek', 'mert túl sokat játszanak aznap', 'sss', 2, 0, '2021-10-19 13:11:19', NULL, NULL),
(7730, 11, 2, 'Az USA-ban hol szokott lenni a legnagyobb Halloween ünneplés?', 'New York-ban', 'Miami-ban', 'San Francisco-ban', 'Las Vegas-ban', 'sss', 1, 1, '2021-10-19 13:23:35', 15, '2021-10-19 13:47:30'),
(7738, 164, 2, 'Mennyi 1+1?', 'trfsd', 'wr', 'r', 'ere', 'sss', NULL, 0, '2022-04-28 16:20:51', NULL, NULL),
(7739, 164, 1, 'Mennyi 1+1?', '2', '3', '4', '5', 'sss', 2, 0, '2022-04-28 16:21:22', NULL, NULL),
(7740, 164, 2, 'Ki az?', 'ab', 'ag', 'afe', 'aew', 'sss', NULL, 0, '2022-04-28 17:10:02', NULL, NULL),
(7743, 6, 1, 'Mennyi az eredménye a 7/7*8/8 műveletsornak?', '2', '1', '3', '4', 'sss', NULL, 0, '2022-06-20 23:00:01', NULL, NULL);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `quiz_rating`
--

CREATE TABLE `quiz_rating` (
  `user_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL,
  `rating_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `quiz_rating`
--

INSERT INTO `quiz_rating` (`user_id`, `quiz_id`, `rating`, `rating_time`) VALUES
(15, 1, 3, '2020-12-23 22:55:44'),
(15, 4, 3, '2021-01-02 20:37:55'),
(15, 5, 2, '2020-12-28 18:21:53'),
(15, 6, 4, '2020-12-24 12:39:25'),
(15, 7, 2, '2020-12-28 18:32:25'),
(15, 8, 3, '2021-02-19 14:15:18'),
(15, 9, 3, '2020-12-28 18:13:50'),
(15, 11, 5, '2021-06-10 22:46:00'),
(15, 12, 5, '2021-06-08 17:41:42'),
(15, 67, 1, '2021-08-08 22:35:55'),
(15, 97, 5, '2020-12-23 22:57:17'),
(15, 164, 5, '2022-05-02 11:01:51'),
(15, 176, 5, '2021-09-08 14:10:04'),
(94, 1, 2, '2020-12-24 15:18:27'),
(94, 2, 3, '2021-08-23 19:15:27'),
(94, 3, 3, '2021-02-16 08:57:06'),
(94, 5, 3, '2021-08-24 13:30:32'),
(94, 6, 5, '2021-06-10 10:53:49'),
(94, 8, 1, '2020-12-28 19:03:20'),
(94, 10, 3, '2021-08-19 10:07:10'),
(94, 11, 5, '2021-06-16 12:10:07'),
(94, 67, 5, '2020-12-25 22:22:16'),
(94, 86, 5, '2020-12-26 18:42:37'),
(94, 164, 4, '2021-08-08 22:38:27'),
(96, 67, 5, '2021-05-25 15:44:17'),
(96, 86, 4, '2021-06-25 12:10:31'),
(96, 97, 5, '2021-06-15 16:49:30'),
(99, 1, 2, '2020-12-25 12:43:55'),
(99, 2, 2, '2020-12-25 12:49:33'),
(99, 6, 5, '2020-12-25 22:29:24'),
(99, 7, 3, '2022-05-01 15:56:51'),
(99, 9, 1, '2021-01-09 12:22:10'),
(99, 10, 4, '2021-01-09 12:19:59'),
(99, 12, 5, '2021-03-21 20:25:45'),
(99, 67, 5, '2020-12-25 12:50:37'),
(99, 86, 3, '2020-12-25 23:54:28'),
(99, 97, 5, '2021-02-15 19:49:53'),
(106, 1, 3, '2021-06-13 18:22:57'),
(106, 12, 5, '2022-05-03 23:30:20'),
(106, 67, 5, '2021-01-09 12:33:45'),
(106, 86, 5, '2021-01-09 12:34:20'),
(106, 97, 5, '2021-01-09 12:33:24'),
(112, 86, 4, '2021-06-13 20:48:16'),
(112, 97, 4, '2021-06-07 23:18:19'),
(116, 177, 5, '2021-10-23 09:26:36'),
(118, 1, 3, '2021-08-25 12:12:36'),
(118, 67, 5, '2021-08-25 12:05:34'),
(118, 164, 4, '2021-08-24 21:57:55'),
(118, 176, 5, '2021-09-08 14:13:28'),
(124, 164, 5, '2022-06-20 22:38:02'),
(124, 176, 5, '2022-06-20 22:38:27');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `request_vote`
--

CREATE TABLE `request_vote` (
  `user_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `offered_points` int(11) NOT NULL,
  `vote_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `request_vote`
--

INSERT INTO `request_vote` (`user_id`, `quiz_id`, `offered_points`, `vote_date`) VALUES
(15, 5, 30, '2020-08-21 17:42:36'),
(15, 74, 100, '2020-08-20 23:41:36'),
(15, 75, 100, '2020-08-20 23:57:34'),
(15, 75, 55, '2020-08-21 17:35:30'),
(15, 75, 55, '2020-08-21 17:35:34'),
(15, 77, 100, '2020-08-21 00:17:45'),
(15, 78, 399, '2020-08-21 00:20:45'),
(15, 79, 100, '2020-08-21 00:21:45'),
(15, 82, 50, '2020-08-21 21:01:22'),
(15, 82, 55, '2020-08-21 21:08:32'),
(15, 84, 100, '2020-08-23 14:05:02'),
(15, 88, 100, '2020-08-26 17:25:42'),
(15, 91, 100, '2020-10-18 23:03:13'),
(15, 92, 100, '2020-10-18 23:03:29'),
(15, 93, 150, '2020-10-18 23:04:10'),
(15, 94, 100, '2020-10-18 23:09:28'),
(15, 96, 100, '2020-10-18 23:10:18'),
(15, 116, 100, '2021-02-19 20:36:04'),
(15, 116, 210, '2021-07-07 16:53:54'),
(15, 116, 150, '2022-04-24 18:02:56'),
(15, 142, 250, '2021-02-19 10:28:34'),
(15, 142, 150, '2021-02-19 16:09:14'),
(15, 142, 99, '2021-02-24 11:35:59'),
(15, 142, 30, '2021-03-03 15:04:42'),
(15, 142, 333, '2021-07-03 23:58:56'),
(15, 144, 455, '2021-02-19 11:00:09'),
(15, 144, 30, '2021-02-20 09:09:07'),
(15, 144, 200, '2021-03-31 11:05:15'),
(15, 145, 30, '2021-02-19 16:05:20'),
(15, 145, 30, '2021-02-19 16:06:19'),
(15, 145, 45, '2021-02-19 16:08:04'),
(15, 145, 30, '2021-02-19 22:00:34'),
(15, 145, 30, '2021-03-20 13:59:43'),
(15, 145, 222, '2021-08-23 15:39:02'),
(15, 146, 100, '2021-02-19 14:40:28'),
(15, 161, 100, '2021-08-23 13:49:50'),
(15, 161, 100, '2022-05-17 16:47:08'),
(15, 165, 1007, '2021-08-15 14:38:56'),
(15, 181, 366, '2022-04-28 12:35:28'),
(55, 87, 100, '2020-08-24 16:31:38'),
(94, 82, 4000, '2020-08-21 21:01:58'),
(94, 82, 441, '2020-08-21 21:02:43'),
(94, 100, 100, '2020-10-20 12:35:33'),
(94, 101, 100, '2020-10-20 12:46:42'),
(94, 102, 100, '2020-10-20 13:36:55'),
(94, 103, 100, '2020-10-20 13:37:58'),
(94, 106, 100, '2020-10-20 15:50:26'),
(94, 106, 72, '2020-10-20 17:51:34'),
(94, 107, 100, '2020-10-21 12:29:53'),
(94, 109, 100, '2020-10-21 12:31:20'),
(94, 112, 100, '2020-10-21 12:53:09'),
(94, 116, 5000, '2020-11-01 17:09:01'),
(94, 142, 100, '2021-06-13 13:31:44'),
(94, 142, 100, '2021-08-25 00:22:06'),
(94, 142, 100, '2021-09-06 14:36:30'),
(94, 144, 256, '2021-06-15 17:29:41'),
(94, 145, 30, '2021-02-21 17:44:11'),
(94, 161, 1000, '2021-06-13 13:46:03'),
(94, 161, 100, '2021-06-15 17:28:59'),
(94, 161, 30, '2021-08-19 10:09:57'),
(94, 161, 450, '2021-08-24 13:28:18'),
(94, 161, 1000, '2021-09-06 14:36:51'),
(99, 121, 150, '2020-12-07 09:05:46'),
(99, 145, 250, '2021-02-19 11:07:53'),
(99, 147, 100, '2021-02-19 14:42:01'),
(118, 161, 100, '2021-08-25 17:39:16');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `thema`
--

CREATE TABLE `thema` (
  `id_number` int(11) NOT NULL,
  `quiz_name` varchar(100) NOT NULL,
  `description` varchar(1000) NOT NULL,
  `is_deleted` int(11) NOT NULL,
  `language` varchar(30) NOT NULL,
  `phase` int(11) NOT NULL,
  `is_request` int(11) NOT NULL,
  `num_of_question` int(11) NOT NULL,
  `minimum_requested_quest` int(11) DEFAULT NULL,
  `accept_questions` int(11) NOT NULL,
  `show_answers` int(11) NOT NULL,
  `time_to_answer` int(11) NOT NULL,
  `num_of_playing` int(11) NOT NULL,
  `access` int(11) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `requested_by` varchar(25) NOT NULL,
  `accomplished_by` varchar(25) DEFAULT NULL,
  `request_date` datetime NOT NULL,
  `accomplish_date` datetime DEFAULT NULL,
  `byuser_minreq_quest` int(11) DEFAULT NULL,
  `reason` varchar(150) NOT NULL,
  `anonymus_accomplish` int(11) NOT NULL,
  `anonymus_request` int(11) NOT NULL,
  `password` varchar(128) DEFAULT NULL,
  `is_undertaken` int(11) NOT NULL,
  `undertaken_by` varchar(30) DEFAULT NULL,
  `accomplish_deadline` datetime DEFAULT NULL,
  `verification` int(11) NOT NULL,
  `pass_degree` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `thema`
--

INSERT INTO `thema` (`id_number`, `quiz_name`, `description`, `is_deleted`, `language`, `phase`, `is_request`, `num_of_question`, `minimum_requested_quest`, `accept_questions`, `show_answers`, `time_to_answer`, `num_of_playing`, `access`, `start_date`, `end_date`, `requested_by`, `accomplished_by`, `request_date`, `accomplish_date`, `byuser_minreq_quest`, `reason`, `anonymus_accomplish`, `anonymus_request`, `password`, `is_undertaken`, `undertaken_by`, `accomplish_deadline`, `verification`, `pass_degree`) VALUES
(1, 'MŰVÉSZET', 'A művészet témakör a klasszikus zenével, festészettel, szobrászattal, színházzal, építészettel, táncművészettel kapcsolatos kérdéseket tartalmazza. Ide tartoznak a fenti témák legnevesebb képviselőinek életrajzi adatai is.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 15000, 40),
(2, 'MINDENNAPOK', 'A mindennapok témakör az autókkal, napi gazdasággal kapcsolatos kérdéseket tartalmazza. Itt találhatók napjaink hírességeivel és érdekes eseményeivel kapcsolatos kérdések is.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 15000, 40),
(3, 'FÖLDRAJZ', 'A földrajz témakör a kontinensekkel, országokkal, fővárosokkal, népességgel, folyókkal, tavakkal, tengerekkel, hegyekkel kapcsolatos kérdéseket tartalmazza.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 5, 40),
(4, 'TÖRTÉNELEM', 'A történelem témakör az emberiség történetének mérföldköveit foglalja össze az őskortól napjainkig. Itt találhatók a háborúkról, uralkodókról, felfedezőkről, régészetről szóló kérdések.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 15000, 40),
(5, 'IRODALOM', 'Az irodalom témakör a novellákkal, drámákkal, sci-fi és fantasy regényekkel, gyermekirodalommal, filozófiával, mitológiával és a bibliával kapcsolatos kérdéseket tartalmazza. Itta találhatók a szerzőkkel kapcsolatos kérdések, a leghíresebb idézetek is.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 1500, 40),
(6, 'MATEMATIKA + FIZIKA', 'Ez a témakör a matematika és a fizika tudományokkal kapcsolatos kérdéseket dolgozza fel. Megtalálható minden a fejszámolástól geometriáig, a mechanikától az elektromosságig. Itt találhatók a csillagászattal, űrkutatással, gépekkel, mértékegységekkel, híres tudósokkal és kutatásaikkal kapcsolatos kérdések.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 0, 0, NULL, 0, NULL, NULL, 1500, 40),
(7, 'BIOLÓGIA + KÉMIA', 'Ez a témakör a biológia és a kémia tudományokat dolgozza fel. Itt találhatók a növényekről, állatokról, emberi testről, orvostudományról, elemekről, vegyületekről és a fenti területek tudósairól szóló kérdések', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 1500, 40),
(8, 'SPORT', 'Ez a témakör a leghíresebb sportolókról és a legnagyobb sportsikerekről szóló kérdések gyűjtőhelye. Megtalálhatók itt a csapatsportok és az egyéni sikerek egyaránt.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 1500, 40),
(9, 'SZÓRAKOZÁS', 'A szórakozás témakörben a könnyűzenével, mozival, televízióval, színészekkel, előadókkal, kártya és társasjátékokkal kapcsolatos kérdések találhatók.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 1500, 40),
(10, 'ÉLETMÓD', 'Az életmód az ételekkel, italokkal, divattal, tudatos táplálkozással, fitnesszel, jógával, szépségápolással, lakberendezéssel és horoszkóppal kapcsolatos kérdéseket tartalmazza. Itt található minden, ami a női magazinokban fellelhető, vagy azokból kimaradt.', 0, '1', 3, 0, 10, 99, 4, 1, 20, 0, 3, NULL, NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 1500, 40),
(11, 'HALLOWEEN', 'Ez a témakör tartalmaz minden olyan kérdést, ami a Halloween-hoz köthető. Az itt található kérdések kitérnek a halloween-i szokásokra, hagyományokra, néhány kapcsolódó film-re és könyvre, illetve néhány érdekességre.\r\nTovábbá megtalálhatóak benne a történelméhez kapcsolódó kérdések is. ', 0, '1', 3, 0, 12, 99, 2, 1, 20, 1, 3, '2020-10-30', NULL, 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 0, 50),
(12, 'KARÁCSONY', 'Ez a tág témakör kérdéseket tartalmaz az Adventi időszakról, a téli jeles napokról (pl: Katalin, Szent András, Borbála), Szent Miklósról, mint püspök és mint a Mikulás, a lucázásról, Jézus születéséről és annak előzményeiről, az angyalokról, téli/karácsonyi dalokról, slágerekről, filmekről, történetekről, rajzfilmekről, valamint a Szilveszterről, a karácsonyi és újévi népszokásokról, ételekről, hagyományokról.', 0, '1', 3, 0, 24, 99, 2, 1, 20, 1, 3, '2021-03-21', '2021-06-23', 'sss', 'sss', '2014-01-01 00:00:00', '2014-01-01 00:00:00', NULL, 'Alaptémakör', 1, 1, NULL, 0, NULL, NULL, 0, 50),
(67, 'Victor Hugo - 1793', 'Victor Hugo EZERHÉTSZÁZKILENCVENHÁROM című regényéből tartalmaz mindenféle kérdéseket. Megtalálható benne a szereplők jellemzéséről, a leírásokról, kisebb-nagyobb eseményekkel kapcsolatos kérdések.', 0, '1', 3, 0, 20, 29, 3, 1, 20, 10, 4, '2021-06-12', NULL, 'sss', 'sss', '2020-08-20 13:15:35', '2020-12-07 20:17:02', NULL, 'A regény olvasásának tesztelése', 1, 0, 'd404559f602eab6fd602ac7680dacbfaadd13630335e951f097af3900e9de176b6db28512f2e000b9d04fba5133e8b1c6e8df59db3a8ab9d60be4b97cc9e81db', 0, '', NULL, 2, 75),
(86, 'Összeadás és kivonás', 'Ez a témakör a kétjegyű természetes számokkal végzett összeadás- és kivonással kapcsolatos kérdéseket tartalmazza.', 0, '1', 3, 1, 13, 19, 4, 1, 15, 2, 4, NULL, NULL, 'aaaa', 'sss', '2020-08-24 16:23:40', '2020-10-18 17:24:23', NULL, 'Kérés teljesítés', 1, 0, '4dff4ea340f0a823f15d3f4f01ab62eae0e5da579ccb851f8db9dfe84c58b2b37b89903a740e1ee172da793a6e79d560e5f7f9bd058a12a280433ed6fa46510a', 1, 'sss', '2020-08-24 16:30:00', 1, 55),
(97, 'VPN - Virtuális magánhálózat', 'Ez a témakör a virtuális magánhálózatok megértésével, működésével, az előnyei és hátrányaival kapcsolatos kérdéseket tartalmazza. Előfordulhatnak olyan kérdések is, amelyek választ adnak a felhasználók által leggyakrabban feltett kérdésekre is ebben a témakörben.', 0, '1', 3, 1, 10, 19, 4, 2, 25, 2, 3, NULL, NULL, 'sss', 'aaaa', '2020-10-19 15:54:27', '2020-10-27 15:25:07', NULL, 'Kérés teljesítés', 0, 0, NULL, 1, 'aaaa', '2020-10-26 17:06:50', 0, 66),
(116, 'Antoine de Saint-Exupéry - A kis herceg', 'Ez a témakör A kis herceg című regényhez kapcsolódó, főként olvasásellenőrző kérdéseket tartalmaz. Megtalálható itt a műhöz szorosan kapcsolódó híres idézetekkel kapcsolatos kérdések is.', 0, '1', 2, 1, 13, 19, 4, 1, 20, 6, 3, NULL, NULL, 'aaaa', NULL, '2020-11-01 17:09:01', NULL, 25, 'Kérés teljesítés', 0, 1, NULL, 0, NULL, NULL, 2000, 50),
(121, 'Teszt kvíz', 'Ez egy részletes leírás ...részletes leírás...', 0, '2', 2, 1, 22, 32, 4, 1, 40, 6, 3, NULL, NULL, 'llll', NULL, '2020-12-07 09:05:46', NULL, NULL, 'Kérés teljesítés', 0, 0, NULL, 0, NULL, NULL, 2000, 50),
(126, 'Teszt kvíz 2', 'Nagyon részletes leírás....', 0, '1', 2, 0, 20, 29, 5, 1, 45, 3, 2, NULL, NULL, 'sss', 'sss', '2021-01-09 00:48:37', NULL, NULL, 'csak úgy', 0, 0, 'aa66509891ad28030349ba9581e8c92528faab6a34349061a44b6f8fcd8d6877a67b05508983f12f8610302d1783401a07ec41c7e9ebd656de34ec60d84d9511', 0, NULL, NULL, 2000, 50),
(136, 'Teszt kvíz 3', 'Részletes\r\nrészletes\r\nleírás....\r\n....', 0, '2', 2, 0, 20, 29, 3, 2, 45, 3, 2, '2021-01-12', '2021-01-13', 'sss', 'sss', '2021-01-12 10:55:40', NULL, NULL, 'csak úgy', 0, 0, NULL, 0, NULL, NULL, 2000, 50),
(141, 'Próba teszt kvíz 5.', 'Leírás helye itt...', 0, '1', 1, 0, 20, 29, 4, 1, 45, 2, 4, NULL, NULL, 'sss', 'sss', '2021-02-18 16:20:14', NULL, NULL, 'csak úgy', 1, 0, 'fb0e6a12ca8dad75dbd2e9c04c488a5ea9c910fbc3743bd1ce043a4a622b4f42c78b4f8c7226195db79ad798e90d1513679fad3bfbc61f8b3f4fac840c482029', 0, NULL, NULL, 0, 50),
(142, 'Móricz Zsigmond - Légy jó mindhalálig', 'Ez a kvíz Móricz Zsigmond Légy jó mindhalálig című regényével kapcsolatos kérdéseket tartalmaz. Megtalálható benne a szereplők jelleméről, az eseményekkel és helyszínekkel kapcsolatos kérdések is.', 0, '1', 2, 1, 15, 22, 4, 1, 25, 6, 3, NULL, NULL, 'sss', NULL, '2021-02-19 10:28:34', NULL, 30, 'Kérés teljesítés', 0, 1, NULL, 0, NULL, NULL, 2000, 50),
(144, 'Próba kérés 1.', 'Részletes leírás a próba kérésről........\r\n....', 0, '1', 2, 1, 28, 41, 4, 2, 55, 6, 3, NULL, NULL, 'sss', NULL, '2021-02-19 11:00:08', NULL, 37, 'Kérés teljesítés', 1, 0, NULL, 1, 'aaaa', '2021-09-19 12:25:05', 0, 50),
(145, 'Kérés 2.0', 'Itt található a nagyon részletes leírás....', 0, '1', 2, 1, 22, 32, 4, 2, 55, 6, 3, NULL, NULL, 'llll', NULL, '2021-02-19 11:07:53', NULL, 2, 'Kérés teljesítés', 0, 0, NULL, 1, 'jjjj', '2021-09-30 23:31:53', 0, 50),
(150, 'Atmenes tesztelo', 'Leírás helye\r\nbla bla...', 0, '1', 1, 0, 40, 58, 4, 1, 99, 5, 2, '2021-06-16', '2021-06-22', 'aaaa', 'aaaa', '2021-06-09 16:00:01', NULL, NULL, 'csak ugy', 1, 0, NULL, 0, NULL, NULL, -1, 78),
(160, 'A mesemondó - Hans Christian Andersen Modern Klasszikusai', 'Ez a témakör A mesemondó című rajzfilmsorozatból tartalmaz kérdéseket. Megtalálható mindenféle kérdés az epizódok cselekményéről, a szereplőkről, illetve az írott változatbeli való hasonlóságokról, különbségekről.\r\n\r\nLink: https://hu.wikipedia.org/wiki/A_mesemond%C3%B3\r\nIMDB link: https://www.imdb.com/title/tt0459692/', 0, '1', 2, 0, 15, 22, 1, 1, 30, 0, 3, NULL, NULL, 'aaaa', 'aaaa', '2021-06-11 23:28:47', NULL, NULL, 'A rajzfilm emlékének fenntartására', 1, 0, NULL, 0, NULL, NULL, 2, 65),
(161, 'Legújabb teszt kérés', 'Témakör leírása itt....', 0, '1', 2, 1, 22, 32, 4, 1, 40, 6, 3, NULL, NULL, 'aaaa', NULL, '2021-06-13 13:46:03', NULL, 0, 'Kérés teljesítés', 0, 1, NULL, 0, NULL, NULL, 1, 50),
(164, 'A világ országai és fővárosai', 'Ez a kvíz a világ különböző országainak a fővárosaira kérdez rá. Előnyt jelent, ha tudjuk melyik ország melyik kontinensen van. A kvíz teljesítéséhez elég annyit tudni, hogy melyik országnak melyik a fővárosa, illetve fordítva, melyik ország fővárosa egy adott város.', 0, '1', 3, 0, 16, 23, 3, 1, 20, 0, 2, '2021-10-24', '2022-12-23', 'sss', 'sss', '2021-07-19 16:50:36', '2021-07-19 17:03:34', NULL, 'A tudás felmérése a témakörben', 1, 0, NULL, 0, NULL, NULL, 300, 50),
(176, 'Szorzás és osztás', 'Ez a témakör a kettő-és legfeljebb háromjegyű számokkal végzett szorzás és osztási műveletekkel kapcsolatos kérdéseket tartalmaz. Előfordulhatnak hatványozáshoz kötődő kérdések is.', 0, '1', 3, 0, 13, 19, 1, 1, 20, 0, 3, NULL, NULL, 'aaaa', 'aaaa', '2021-09-08 11:32:55', '2021-09-08 13:56:04', NULL, 'Szórakozás céljából', 0, 0, NULL, 0, NULL, NULL, 100000, 50),
(177, 'HTML', 'Ez a témakör a HTML nyelvvel kapcsolatos kérdéseket tartalmazza. Legtöbb kérdés a HTML tag-ek használatáról méri fel a tudást. A kvíz nem tér ki a dizájnhoz (CSS-hez) fűződő részletekre. Főképp kezdő programozók számára ajánlott kitölteni.', 0, '1', 3, 1, 15, 22, 4, 1, 20, 0, 3, NULL, NULL, 'llll', 'aaaa', '2021-09-08 18:23:20', '2021-09-09 18:22:22', 50, 'Kérés teljesítés', 0, 0, NULL, 1, 'aaaa', '2021-09-15 18:28:00', 5, 50);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `undertaken_request`
--

CREATE TABLE `undertaken_request` (
  `user_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `undertaken_request`
--

INSERT INTO `undertaken_request` (`user_id`, `request_id`, `status`) VALUES
(15, 83, -1),
(15, 86, 1),
(15, 87, 0),
(15, 106, 0),
(15, 116, -1),
(15, 121, -1),
(15, 145, -1),
(15, 161, -1),
(94, 74, -1),
(94, 75, -1),
(94, 79, -1),
(94, 84, -1),
(94, 96, 0),
(94, 97, 1),
(94, 142, -1),
(94, 144, 0),
(94, 177, 1),
(95, 93, 0),
(95, 94, 0),
(99, 77, 0),
(99, 142, -1),
(99, 144, -1),
(116, 145, 0),
(116, 161, -1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user`
--

CREATE TABLE `user` (
  `id` int(8) NOT NULL,
  `deleteduser` int(1) NOT NULL,
  `adminuser` int(1) NOT NULL,
  `points` int(11) NOT NULL,
  `quizplayed_total` int(11) NOT NULL,
  `warn` int(11) NOT NULL,
  `totalwarn` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `keep_level` int(1) NOT NULL,
  `lastvisit_admin` datetime DEFAULT NULL,
  `questiontype` int(1) NOT NULL,
  `temagames` int(11) NOT NULL,
  `perfectgames` int(11) NOT NULL,
  `profilehiding` int(1) NOT NULL,
  `premium` int(1) NOT NULL,
  `help` int(7) NOT NULL,
  `accept_privmessage` int(1) NOT NULL,
  `registrtime` datetime NOT NULL,
  `lastvisit` datetime NOT NULL,
  `profilehiding_expire` datetime NOT NULL,
  `premium_expire` datetime NOT NULL,
  `warn_expire` datetime NOT NULL,
  `lawtousechat` int(1) NOT NULL,
  `lawtosendquestion` int(1) NOT NULL,
  `lawtopostnews` int(1) NOT NULL,
  `lawtosearchuser` int(1) NOT NULL,
  `lawtoeditfaq` int(1) NOT NULL,
  `lawtogetpoints` int(1) NOT NULL,
  `lawtosendmail` int(1) NOT NULL,
  `lawtouserequests` int(11) NOT NULL,
  `lawtocreatequiz` int(11) NOT NULL,
  `delete_reason` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `fullname` varchar(100) CHARACTER SET utf8 NOT NULL,
  `email` varchar(60) CHARACTER SET utf8 NOT NULL,
  `user` varchar(25) CHARACTER SET utf8 NOT NULL,
  `pw` varchar(128) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- A tábla adatainak kiíratása `user`
--

INSERT INTO `user` (`id`, `deleteduser`, `adminuser`, `points`, `quizplayed_total`, `warn`, `totalwarn`, `level`, `keep_level`, `lastvisit_admin`, `questiontype`, `temagames`, `perfectgames`, `profilehiding`, `premium`, `help`, `accept_privmessage`, `registrtime`, `lastvisit`, `profilehiding_expire`, `premium_expire`, `warn_expire`, `lawtousechat`, `lawtosendquestion`, `lawtopostnews`, `lawtosearchuser`, `lawtoeditfaq`, `lawtogetpoints`, `lawtosendmail`, `lawtouserequests`, `lawtocreatequiz`, `delete_reason`, `fullname`, `email`, `user`, `pw`) VALUES
(3, 0, 0, 53, 5, 0, 0, 2, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', '2018-12-31 10:33:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 'Sándor', 'esandor89@yahoo.com', 'Mesi', '2ca906c9b9c114b808a541e96a94a7985323a211571c71f33d026c95040bd49d196776bd902846cc3b23f7066b517c633e61b7bacfaf1ea6fb06efdc03ef9a23'),
(5, 1, 0, 51969, 84, 0, 1, 3, 0, '0000-00-00 00:00:00', 25, 2, 0, 1, 0, 1, 0, '0000-00-00 00:00:00', '2018-11-10 10:44:45', '2020-08-02 02:02:53', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, 0, 0, 'xyz ok', 'Kedves', 'qwertgfs@gmail.com', 'norbi', '83b05d98186648cd5576ed158c9cf2174413b86d48720c3ffbe6452bc38a6527256ff3435eb1698f24efbc880c8ea870afe314f3004c71cfdd5f0e3c00e3979f'),
(15, 0, 1, 90649, 4206, 0, 24, 5, 0, '2022-06-21 00:23:08', 0, 63, 33, 0, 0, 599, 1, '2018-01-01 00:00:00', '2022-06-21 00:23:18', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 1, 1, 1, 1, 1, NULL, 'fw4', 'norbertkedves30@gmail.com', 'sss', 'fb0e6a12ca8dad75dbd2e9c04c488a5ea9c910fbc3743bd1ce043a4a622b4f42c78b4f8c7226195db79ad798e90d1513679fad3bfbc61f8b3f4fac840c482029'),
(38, 1, 0, 6, 1, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Saját fiók törlése', 'Kedves', 'norbert3@gmail.com', 'Norbert', '50c16866ee5c26f2d3a35c00a9a1c4a21c86669226fb452366fa233f3a084eea71f24cf65a046b0a7d32b4c1e97e367dcad51171166919cdefe3d07376940ec6'),
(39, 0, 0, 19119, 272, 0, 0, 3, 0, '0000-00-00 00:00:00', 0, 98, 28, 0, 0, 2, 0, '2018-01-01 00:00:00', '2021-09-29 15:47:17', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 0, 0, 0, 1, 1, 1, 1, NULL, 'Kedves', 'norbikedves3@gmail.com', 'norbika', '4099ab215083281abd06960cfae8693ef1c880d07600ffe95e7783f2b1ed5826a327854e11950f388b6dfbe223df8f1ab6ec95272c80a944f75ffdaefc778525'),
(56, 0, 0, 10163, 32, 0, 0, 2, 0, '0000-00-00 00:00:00', 39, 18, 12, 0, 0, 0, 0, '2018-07-21 15:49:03', '2020-05-06 18:20:33', '2018-08-13 22:20:30', '2018-08-13 22:20:48', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 'frts', 'vsdtyv@asd.com', 'rrrr', '3e181257ea477ec94c71d9e9acef7d5810855f64deb03e6ab3c163c1a3a04c9bd9ae4c2b24ad1f31bf22d68283c393be80dea0a0cab2d2dafa9ac47a5ebb8f83'),
(72, 1, 0, 1, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-05-07 18:16:20', '2020-05-07 18:16:20', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Saját fiók törlése', 'xxxxx x', 'zitaaa776@gmail.com', 'zita77', '807d186b6f4ead369d38330efb53abc8a9b52512a440ed4534240069a28bc4ab5d80235c5e708a2827642d7f6043ff3c967f6ab45a63991337262761bfada7f3'),
(73, 0, 0, 1421, 27, 0, 3, 1, 0, '0000-00-00 00:00:00', 1, 0, 0, 1, 0, 2, 0, '2020-05-07 20:52:52', '2020-05-07 21:12:36', '2020-08-17 23:02:55', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Arany dALMA', 'nincsen@gmail.com', 'eljenAkalacs00', '9b6c1b212abcb9ae4128388fe56ac0c76d4e48c9065d9a2cfa0664e4b6c9f86e1ae761d170c3c300d426cfa548a4369ed4fb2e1ef30b2aa691295699a0d9d6e3'),
(74, 0, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-05-08 09:44:41', '2020-05-08 09:44:51', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'qw w', 'teveyrtsgdfv@gmail.com', 'zitta', 'b5b4df5fb892b3df165893810278c67d63d5a5d1a834e3de3efea7e44fe377c7e2a3889f3f1af02df4439616db099623928c30836489fecba70ff71e91fc681c'),
(75, 0, 0, 12, 1, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-05-08 11:43:52', '2020-05-08 11:49:34', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Proba Szerencse', 'ked@gmail.com', 'szerencse', '2e937c2688753f2f23f2dab4d108a684fb1997708492f3dc36a364fb79c1f78f3cfffd551816b427f0f06aa673cefd2b085dc463600d7a451f1e71d031af54aa'),
(76, 0, 0, 25267, 829, 0, 0, 4, 0, '0000-00-00 00:00:00', 0, 0, 1, 0, 0, 64, 0, '2020-05-08 12:00:49', '2021-09-29 17:14:19', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 0, 1, 1, 1, 1, NULL, 'Sandor Éva', 'eva.sandor.76@gmail.com', 'evike', 'a4afc04cd870df09f7ce0e5cd0565bdc3b642e72ad6bc32572f495ae112c06185a29d022d729cc6ce443fdc8b2e61842a4b2009967bc45afe523f4b7899a8b12'),
(77, 0, 0, 15994, 69, 0, 0, 3, 0, '0000-00-00 00:00:00', 0, 3, 0, 0, 0, 5, 0, '2020-05-09 18:31:18', '2020-05-09 19:04:08', '2020-06-08 18:45:28', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 0, 1, 1, 0, 0, NULL, 'Sandor Emese', 'emesesandor089@gmail.com', 'Mess98', '8a1af016a41d88441dc429c7d606c7c8e4e52f714dca644eab28a1be5db10f977967069f7d125bdbf567b817e8f3744d43f5c30bb83f9947d26733e4bf9dcf4d'),
(78, 0, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-05-14 17:05:03', '2020-05-14 17:13:32', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Teszt 1', 'norhgfxdesrs@gmail.com', 'norbikaa', '237c6845d34040bf389096f3ba3df52618a901046e9a2689318808abe19ba8fdcfc95d7feb4b2646e280acad0d76ee653d76a773e5047848396157f8bd008451'),
(79, 1, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-05-14 17:15:24', '2020-05-14 17:17:13', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, 'Túl sok warn', 'Teszt ketto', 'nor3kyrdhes@gmail.com', 'asdf', '089db5177fa99b73a0170f494363275edd6f7b9b29f3f14731cf49b24dbf99b062952022b92b665f06b19834151202726d1f449259dfa387a18f731bcd5d00df'),
(80, 0, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-05-14 17:20:45', '2020-05-14 17:21:23', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Teszt Harom', 'cstrgdfes@gmail.com', 'qwerty', '735a0838bc6dbf708bfa928fc956e5af7dd3e64d5abfd27a537985f2334e3fcbc79cf2d01888d00427343ff868ac72d312628cc5e41e91c3e600f737554cb02e'),
(81, 0, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-05-25 14:16:19', '2020-05-25 14:17:49', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Lkh GGG', 'telcwetsrvekkk@gmail.com', 'rrrrr', 'fce350d4aa375859840dd00d9424a5f7ed1e501fe7122b2138372c72df19c474e15d3c57123bfaee259d00b5501259170358a6c96bdcba5bc25b644fc578adaf'),
(82, 1, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-05-25 14:18:10', '2020-05-25 14:19:21', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, 'Túl sok warn', 'DD Pp', 'kehhhi@gmail.com', 'ssssss', 'ee94631b43074476b00215a12dd2a950494beaf9bc6632aa2f80ea6547840925e235f3b6740dcb72bb39e4bf65eef8c8294881dd2a5a4fa8c6e9ceada1340bea'),
(85, 0, 0, 174, 26, 0, 0, 2, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-06-23 17:59:06', '2020-06-23 18:28:50', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Parna Parkinson', 'parna@gmail.com', 'parna', 'dea288a0af636c9adbec0bc1c3108341b57b2d2d16033f8fc14602aa0a96182db7c3d5fc50e72468ca1a0094834cff2a84bb3cbeff9906798747c23c7ee2bd5a'),
(86, 0, 0, 523, 161, 0, 0, 3, 0, '0000-00-00 00:00:00', 0, 1, 0, 1, 0, 0, 0, '2020-06-26 09:55:46', '2020-06-26 10:28:30', '2020-07-26 09:59:16', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 0, 0, 1, 1, 0, 0, NULL, 'sikeres siker', 'sikerelmeny@gmail.com', 'yaay', 'b8123f50cf9bb27d66a5258963f229bd779e2c31042e253ed1fcbd943eb9b6b1f9be1de1066a9a53b0467dc961e09bc4c904bdb7086394809af7c855caebbfb4'),
(87, 0, 0, 991837, 500057, 0, 14, 5, 0, '0000-00-00 00:00:00', 0, 1, 0, 0, 0, 47, 0, '2020-06-30 15:28:26', '2022-05-17 20:15:34', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 1, 1, 1, 1, 1, NULL, 'Para Zita', 'parazitttgs@gmail.com', 'paraZita0', '315520b508a059bf473bc6aa7820d8e7cdf4c2a8390c52abeeed1f986a97a7bd0d2caa98c6932fd29bb828b5bbb8bee31477022b815316a101ee5786f15e8fc5'),
(89, 1, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-07-10 23:25:43', '2020-07-10 23:25:54', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, 'Túl sok szabálytalankodás', 'Para Zita', 'innocent6@gmail.com', 'innocent', 'fae6170fb58893e8bdeefba57443e3bc257bdd39050578e2b89b4092714c4c92d5b5bca4ddf9fad2d89dc9231c791029a155f8b6b6e6defb57e8dd6b2fa0e568'),
(90, 0, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-07-14 14:48:49', '2020-07-14 14:50:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'As DF', 'cwstgrd@gmail.com', 'kicsike', '92c3786f5ba54a8cad2a4a14696b0d46ffd66a94b3442995568c8d3f6e1a429d2c836cb0b752b98074d1b63bcc5d10fdfe9e9fe376b129c62a102e0ff1c38098'),
(91, 0, 0, 1, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-07-14 14:53:22', '2020-07-14 14:53:22', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'av aetr', 'ap@gmail.com', 'kicsike1', '730839a4c45fe05cec8735c1e1dfe9c2e7dd92c017819b087b2ba83269797b6a3dcc482115fd4156fee6185fc01bbaca76d9db6c7cfa73d01f6c1f6b6f69534c'),
(92, 0, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-07-15 23:38:03', '2020-07-15 23:38:17', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Para Ztrg', 'asdd@gmail.com', 'kitudja', 'fb0e6a12ca8dad75dbd2e9c04c488a5ea9c910fbc3743bd1ce043a4a622b4f42c78b4f8c7226195db79ad798e90d1513679fad3bfbc61f8b3f4fac840c482029'),
(93, 0, 0, 999999523, 10000, 0, 1, 5, 0, '0000-00-00 00:00:00', 1, 1, 1, 0, 0, 1000, 0, '2020-07-18 23:09:08', '2021-02-17 20:03:56', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 1, 1, 1, 1, 1, NULL, 'Kurtos Kalacs', 'kurtos@gmail.com', 'blanka', 'b8123f50cf9bb27d66a5258963f229bd779e2c31042e253ed1fcbd943eb9b6b1f9be1de1066a9a53b0467dc961e09bc4c904bdb7086394809af7c855caebbfb4'),
(94, 0, 1, 25880, 45867, 0, 8, 5, 0, '2021-10-22 21:50:50', 0, 5, 2, 0, 0, 91, 0, '2020-08-17 18:18:20', '2022-06-18 17:38:08', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 1, 1, 1, 1, 1, NULL, 'Kedves Norbert', 'kedvesnorbert@gmail.com', 'aaaa', 'fb631661a01277f546350b12d5c09c8014cb5408bb453a919d8619e8dc8293e1c0b849287eedc9b974c5fbabfd8f1767dba274b9e3cc76b4be73d3d19219413a'),
(95, 0, 0, 49, 456, 0, 0, 2, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-10-21 08:47:35', '2021-03-13 19:13:56', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'Para Zita', 'teleerdgf26@gmail.com', 'qqqq', '65767112892acf7b243ae61b646a5c7e5f2fbee65a6e175d35f0fc04ae94fdb06b93bd741a16969373ab408074611ea5ca646004ca554172f77bb55557d03455'),
(96, 0, 0, 40116, 36, 0, 0, 2, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 18, 1, '2020-10-21 16:38:07', '2022-05-17 11:22:57', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'Kedves Norberto', 'norbertkedves@gmail.com', 'Norberto99', 'facc99af2ec2b39ac85924bf8cca9b62d8f8a126addecd8872fad172a336213b7dca797d95e04dd31015f5501481fd1fa7d1804e6f47aab430bbbc27721282e7'),
(97, 0, 0, 9665, 1001, 0, 0, 4, 0, '0000-00-00 00:00:00', 0, 1, 0, 0, 0, 1, 0, '2020-08-16 17:38:07', '2020-08-16 18:38:07', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 0, 1, 1, 1, 1, NULL, 'Alpha Be', 'qgcofevtvekubnstdh@ttirv.net', 'Alpha', 'd2069ae71db7206aff9aa5c9349eeca3a98b9f0fddb2983917179cef5176790e88dcb5c1a3be15175827b5383baaaa8160ac33fd59de13eb1dc9a2f9015469ab'),
(98, 0, 0, 1186, 510, 0, 0, 3, 0, '0000-00-00 00:00:00', 0, 0, 1, 0, 0, 0, 0, '2020-08-11 13:38:20', '2021-02-07 19:26:30', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 0, 0, 0, 1, 1, 1, 1, NULL, 'Kedves László', 'valami@gmail.com', 'Laci', 'c5a402f671116dc81081a3bea00f8e9001abcc964cb428c03b063b35c4f804c69ee2698724d33376e8c1d17e5082e053af58858dcd990eb6ca6a5e635eb11d6a'),
(99, 0, 0, 3948, 9654, 0, 0, 3, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 48, 0, '2020-11-01 17:53:11', '2022-05-03 23:16:35', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 0, 0, 0, 1, 1, 1, 1, NULL, 'Para Zita', 'telefonocska@gmail.com', 'llll', '7ef7fdc3df6753682e72dd1415179c09a86062cca833ecbce3b111bd7729869b5452e0f3ff9528dc6d29b1b73dc2b79e3a0ded2d3e863b606a09d1405dae7c93'),
(100, 0, 0, 1277, 504, 0, 0, 3, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-10-31 19:50:34', '2020-10-31 22:50:34', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 0, 1, 1, 1, 1, NULL, 'VV Alexa', 'feketepalko@gmail.com', 'Orrcsepp', '6c111dceb4c82b77f3c6d5b8521b96048a45892902ba5ef0af5992c13889b8dc571ccf50220a4e296caad5c15c5c665a6779e1f3c677cb642301cdbe389c4466'),
(101, 0, 0, 1131, 506, 0, 0, 3, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 0, '2020-10-31 19:45:17', '2021-07-02 18:41:29', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 0, 0, 1, 1, 1, 1, NULL, 'Sándor Emese', 'emesesandor89@gmail.com', 'Mesi98', '16d205b47b1774a931b3f9f7fc99ab5ee0040b93fb78d4fdcaaa911be897ecb4933376e2d9ca9774db2d28458e3b0608fc918a961156049b0ddbf78d100ff05b'),
(102, 0, 0, -6002, 0, 0, 3, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 0, '2020-11-03 10:10:59', '2021-08-16 20:59:46', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Para Zita', 'eee726@gmail.com', 'eeeee', 'bdbc73c705b06734179e63946a294c125c8ee68a643c215c872bdb8a5ea4e21ff67dffa6d49fd77ac956f49830241726d84bda04b06a88fef6a52e8fd24232ff'),
(103, 0, 0, 11, 1, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, '2020-12-09 10:08:18', '2021-03-15 21:35:35', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Ana  konda', 'kctgrdci@gmail.com', 'pppp', 'a3cd0e72d31f159b0aa3550d70f4f215cd014ca6fa5830b4e45f00eb9e273cc9b17ada3d9ed88064b4505c6fbed480f4c55eed4f23fe1b37684d4c0ace20b274'),
(104, 0, 0, 41, 3, 0, 0, 2, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 2, 0, '2020-12-09 10:09:52', '2021-06-04 19:59:37', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'Para Zita', 'norbertkedves20@gmail.com', 'pppp01', 'a3cd0e72d31f159b0aa3550d70f4f215cd014ca6fa5830b4e45f00eb9e273cc9b17ada3d9ed88064b4505c6fbed480f4c55eed4f23fe1b37684d4c0ace20b274'),
(105, 0, 0, 5188, 1000, 0, 0, 4, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 2, 0, '2020-12-02 19:07:50', '2020-12-02 19:59:08', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 1, 1, 1, 1, 1, NULL, 'Bors Cintia Eszter ', 'borseszter7@gmail.com', 'borseszter7', 'da0e41239d6761cfed431e4415b9ca0e4a29c69e3b043e416d066af127cc2f94ae9db4c10e65daf018f7cc3eafa8ab8d0b42a85fa809f812c6ff542fa9ba47fb'),
(106, 0, 0, 169, 22, 0, 0, 2, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 10, 0, '2020-12-21 16:51:36', '2022-05-17 11:25:28', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'Para Zita', 'hosszunevvbr@gmail.com', 'EzEgyHosszuNevv', '29912f0b1ed7bbdc35a0fb3bd0ab33b6c5b192b10ec5c2bcbe7810190682a598e493aed55d8204deb30b3d721d76b0aa1c166a8a1aa084accce1af1d8ee102f4'),
(107, 0, 0, -697, 0, 1, 2, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 0, '2021-01-02 21:33:00', '2021-09-09 16:59:12', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2021-09-13 21:10:41', 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 'Para Zita', 'norbertkedves260@gmail.com', 'bbbb', 'dffc6b4d8ec084b82ab97a5691858c8f63770eb0f6d5e3e86e560b652c0440fd384150173296b79231ed77b8f644b5bc1936ae6fa4c29850487721ba908cd125'),
(108, 0, 0, 19, 2, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 4, 0, '2021-03-05 14:02:54', '2021-09-09 16:59:32', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Kedves Norbert', 'norbertkedvesctr@gmail.com', 'tttt', 'dedf2165dedd5ff46232de30635bdea59df0cf4e03bd34778955e1668cca30d64804836652147080abeea3f240b21dd2257d941494ca5d1342a017998dfee919'),
(109, 0, 0, -972, 10, 1, 1, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 17, 0, '2021-03-17 10:37:28', '2022-05-17 13:53:06', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2022-05-17 20:10:37', 0, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'Kedves Norbert', 'kedvesnorbert2@gmail.com', 'iiii', '992a3c9d8f1cefc598cc1a66b4ecb6920f6f27511a8d27d7e1fe24a6d95982fea7130241090aa70be77a58d35f37d192dcd68db419ec0a1d382fdafc75060d9f'),
(110, 0, 0, 10015, 6001, 0, 0, 4, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, '2021-02-27 20:48:52', '2021-02-27 21:30:31', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 0, 1, 1, 1, 1, NULL, 'Blanka Blanka', 'email@email.com', 'Blanka1', 'b8123f50cf9bb27d66a5258963f229bd779e2c31042e253ed1fcbd943eb9b6b1f9be1de1066a9a53b0467dc961e09bc4c904bdb7086394809af7c855caebbfb4'),
(111, 0, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 3, 0, '2021-03-24 19:09:28', '2021-03-24 19:09:38', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Tutan Hamon', 'tut@hamon.ko', 'iiiii', '992a3c9d8f1cefc598cc1a66b4ecb6920f6f27511a8d27d7e1fe24a6d95982fea7130241090aa70be77a58d35f37d192dcd68db419ec0a1d382fdafc75060d9f'),
(112, 1, 0, -393, 6, 0, 1, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 33, 1, '2021-06-07 23:08:20', '2021-08-19 14:25:10', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Felhasználók zaklatása', 'Para Zita', 'tecredvwiiii26@gmail.com', 'hhhh', '369e41992e0e16a343002fb51be107f2a39cdb0679a4a7605588374684b6146b609253f88eb0d19b776a99c19302abe3433c89662c5feb2f5a077e1b84b5c156'),
(113, 0, 0, 85, 3, 0, 0, 2, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 4, 0, '2021-06-14 16:56:49', '2021-06-15 00:53:59', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'K Norbert', 'norbert30@gmail.com', 'oooo', '9a7939f36f89892224e90bf15a03d1014c2fc6855536aabd5fea4dd7a523b41c59140e2b1f72ee15dbeeb743b0bfe897b850491f5722aee2143f6370129bb86a'),
(114, 0, 0, 1, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 3, 0, '2021-06-14 17:14:15', '2021-06-14 17:15:24', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Kedves Norbert', 'telefonocskvfa726@gmail.com', 'ooooo', '9a7939f36f89892224e90bf15a03d1014c2fc6855536aabd5fea4dd7a523b41c59140e2b1f72ee15dbeeb743b0bfe897b850491f5722aee2143f6370129bb86a'),
(115, 0, 0, 12, 3, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 2, 0, '2021-06-25 14:45:20', '2021-06-25 15:20:26', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Teszt teszt', 'teszt@example.com', 'Okok', '73ee0f9f6a192d3c13ce36b5c5c72cec7c9016ce381cfb8f58f1e1c390e9cc07c411569883f9efc774def42c6c490ae7563ec350d69f1c7d55b736e86aae1eda'),
(116, 0, 0, 4770, 3, 0, 3, 2, 0, '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 11, 0, '2021-08-14 02:06:34', '2022-05-19 18:27:26', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'Kedves N', 'nor30@gmail.com', 'jjjj', '00475ccf8979e41f8c8ba48920fb003a38e8ebaee9f8eb87b29f5544be1b1031b1962e7b62ae45bdd4e03830dc3dab17683319a6097d5399eb148bf86124d0d6'),
(118, 0, 0, 946, 15, 0, 7, 2, 0, '2021-08-25 17:30:41', 2, 0, 2, 0, 0, 7, 0, '2021-08-24 14:02:40', '2021-09-26 15:58:39', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'Kiss Katalin', 'kicsike@yahoo.com', 'zzzz', '2f21f42f2880ff3ac3fc2c1717c8ffb685144412f962311a79219150af118a67b10ec28e5167f497eeffa0b95f6c3067388c2189fba89fcf1394c578732eb95c'),
(119, 0, 0, 1, 0, 0, 0, 1, 0, NULL, 0, 0, 0, 0, 0, 3, 0, '2021-08-24 16:41:23', '2021-08-24 16:41:30', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Proba Baba', 'probababa@gmail.com', 'asdfgh', '04511b029cb62f6bf4f6cf0bcf8b25048677567b1c3f757068c477b41489d4efcc97b3891a2768a9fa72f756bb5630f2a2a6ba22e3e32bb9cb79ad8f9f9b70ba'),
(120, 0, 0, 1, 0, 0, 0, 1, 0, NULL, 0, 0, 0, 0, 0, 3, 0, '2021-09-05 22:36:14', '2021-09-05 22:37:46', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Kerekes Jozsef', 'keres@j.go', 'kerekes', '91f2ef35b53131b89b4d9bc2afd5b73e1422c532c17fa87f03c5eaa089c2a11f0fd38a645bfd9827c755b9425d778f481dfffb83ce94b92ca0db2d704617da83'),
(121, 0, 0, 1, 0, 0, 0, 1, 0, NULL, 0, 0, 0, 0, 0, 3, 0, '2021-12-08 16:03:02', '2021-12-08 16:03:10', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'K Lajos', 'tele714@gmai.com', 'lkjh', '7ef7fdc3df6753682e72dd1415179c09a86062cca833ecbce3b111bd7729869b5452e0f3ff9528dc6d29b1b73dc2b79e3a0ded2d3e863b606a09d1405dae7c93'),
(122, 0, 0, 5, 0, 0, 0, 1, 0, NULL, 0, 0, 0, 0, 0, 4, 0, '2022-05-19 16:25:49', '2022-05-21 16:13:03', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, 1, 1, 0, 0, NULL, 'Farkasinszky Edit', 'edit@gmail.com', 'Edit24', '0e5ee12a5cde5fad8426a00e258c7cc1e21d6184349dd9f40a474c669c5139ec46d66766be3d78c4b993bd34e0db4e82e4b9a62118d0682a0d3a7329fbbb2295'),
(123, 0, 0, 18003, 640, 0, 0, 5, 1, NULL, 0, 0, 0, 0, 0, 3, 0, '2022-06-18 16:23:19', '2022-06-18 16:56:17', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 1, 1, 0, 1, 1, 1, 1, NULL, 'Kedves Norbert', 'kedves.norbert@student.ms.sapientia.ro', 'user99', '63801c0d895aa20bb067557766e8235fff5442f417dd6d51b93af0a222255f1d68595d4feb34105209d672deac1827dd4ae661f9e7372e1106ea4ec12bb20cd1'),
(124, 0, 0, 187, 2, 0, 0, 2, 0, NULL, 0, 0, 0, 0, 0, 3, 1, '2022-06-20 22:36:39', '2022-06-20 22:51:57', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 0, 0, 0, 0, 1, 1, 1, 0, NULL, 'F Nagy Erika', 'telefonocska726@gmail.com', 'ffff', 'a2ab06d95b3b13af561ceb77f8877a43bbdfddf9064a9f657c7da5546ff35e735c9a6fbf1b5069f3896da9a796de4a88454dbfc525373676a87eceeac5e8c714');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `warn`
--

CREATE TABLE `warn` (
  `userid` int(11) NOT NULL,
  `warnreason` varchar(100) CHARACTER SET utf8 NOT NULL,
  `prohibited` varchar(500) CHARACTER SET utf8 NOT NULL,
  `minuspoints` int(11) NOT NULL,
  `warndelay` int(11) NOT NULL,
  `adminid` int(11) NOT NULL,
  `warningstarted` datetime NOT NULL,
  `warningends` datetime NOT NULL,
  `deletedby` int(11) DEFAULT NULL,
  `delete_reason` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `delete_time` datetime DEFAULT NULL,
  `is_active` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- A tábla adatainak kiíratása `warn`
--

INSERT INTO `warn` (`userid`, `warnreason`, `prohibited`, `minuspoints`, `warndelay`, `adminid`, `warningstarted`, `warningends`, `deletedby`, `delete_reason`, `delete_time`, `is_active`) VALUES
(102, 'Fő tesztelés', 'Pontok gyüjtése, Privát üzenet küldése, ', 250, 16, 15, '2021-08-16 13:09:08', '2021-09-01 13:09:08', 15, 'Első próba törlés', '2021-08-16 20:34:20', 0),
(102, 'Második teszt', 'Pontok gyüjtése, Privát üzenet küldése, ', 5555, 5, 15, '2021-08-16 20:39:24', '2021-08-21 20:39:24', 15, 'Masodik eltorlesi teszt', '2021-08-16 20:41:14', 0),
(112, 'Harmadik teszt', 'Kvíz készítése, Pontok gyüjtése, Privát üzenet küldése, Kérdések beküldése, Chat használata, Kérések használata, ', 500, 3, 15, '2021-08-17 14:10:08', '2021-08-20 14:10:08', 15, 'tesztelés miatt', '2021-08-17 14:22:12', 0),
(116, 'Proba 18', 'Pontok gyüjtése, ', 100, 8, 15, '2021-08-16 00:55:01', '2021-08-17 11:07:33', NULL, NULL, NULL, 0),
(116, 'Proba 11', 'Pontok gyüjtése, Privát üzenet küldése, ', 500, 3, 15, '2021-08-17 11:09:32', '2021-08-17 11:11:00', NULL, NULL, NULL, 0),
(116, 'Proba 1', 'Pontok gyüjtése, Privát üzenet küldése, ', 200, 4, 15, '2021-08-17 11:11:38', '2021-08-21 11:11:38', 15, 'tesztelés miatt', '2021-08-17 11:11:54', 0),
(118, 'Teszt warn', 'Pontok gyüjtése, Privát üzenet küldése, ', 500, 3, 15, '2021-08-24 14:12:57', '2021-08-27 14:12:57', 15, 'Teszt torles', '2021-08-24 14:13:33', 0),
(118, 'Proba 17', 'Pontok gyüjtése, Privát üzenet küldése, ', 100, 3, 15, '2021-08-24 14:14:07', '2021-08-24 14:20:00', NULL, NULL, NULL, 0);

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `background`
--
ALTER TABLE `background`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `chat_group`
--
ALTER TABLE `chat_group`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `chat_history`
--
ALTER TABLE `chat_history`
  ADD PRIMARY KEY (`group_id`,`event_text`,`event_date`);

--
-- A tábla indexei `chat_message`
--
ALTER TABLE `chat_message`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `competition`
--
ALTER TABLE `competition`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `favorite_quiz`
--
ALTER TABLE `favorite_quiz`
  ADD PRIMARY KEY (`user_id`,`quiz_id`);

--
-- A tábla indexei `friend`
--
ALTER TABLE `friend`
  ADD PRIMARY KEY (`id1`,`id2`);

--
-- A tábla indexei `group_member`
--
ALTER TABLE `group_member`
  ADD PRIMARY KEY (`group_id`,`user_id`);

--
-- A tábla indexei `login`
--
ALTER TABLE `login`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `log_data`
--
ALTER TABLE `log_data`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `permission_play_quiz`
--
ALTER TABLE `permission_play_quiz`
  ADD PRIMARY KEY (`userid`,`quizid`);

--
-- A tábla indexei `permission_submit_question`
--
ALTER TABLE `permission_submit_question`
  ADD PRIMARY KEY (`userid`,`quizid`);

--
-- A tábla indexei `played_quiz_question`
--
ALTER TABLE `played_quiz_question`
  ADD PRIMARY KEY (`quiz_id`,`question_id`);

--
-- A tábla indexei `premium`
--
ALTER TABLE `premium`
  ADD PRIMARY KEY (`userid`,`startdate`);

--
-- A tábla indexei `private_message`
--
ALTER TABLE `private_message`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `question_comment`
--
ALTER TABLE `question_comment`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `quiz_comment`
--
ALTER TABLE `quiz_comment`
  ADD PRIMARY KEY (`user_id`,`quiz_id`,`comment_date`);

--
-- A tábla indexei `quiz_like`
--
ALTER TABLE `quiz_like`
  ADD PRIMARY KEY (`user_id`,`quiz_id`);

--
-- A tábla indexei `quiz_played`
--
ALTER TABLE `quiz_played`
  ADD PRIMARY KEY (`test_id`);

--
-- A tábla indexei `quiz_question`
--
ALTER TABLE `quiz_question`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `quiz_rating`
--
ALTER TABLE `quiz_rating`
  ADD PRIMARY KEY (`user_id`,`quiz_id`);

--
-- A tábla indexei `request_vote`
--
ALTER TABLE `request_vote`
  ADD PRIMARY KEY (`user_id`,`quiz_id`,`vote_date`);

--
-- A tábla indexei `thema`
--
ALTER TABLE `thema`
  ADD PRIMARY KEY (`id_number`);

--
-- A tábla indexei `undertaken_request`
--
ALTER TABLE `undertaken_request`
  ADD PRIMARY KEY (`user_id`,`request_id`);

--
-- A tábla indexei `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user` (`user`);

--
-- A tábla indexei `warn`
--
ALTER TABLE `warn`
  ADD PRIMARY KEY (`userid`,`warningstarted`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `background`
--
ALTER TABLE `background`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=149;

--
-- AUTO_INCREMENT a táblához `chat_group`
--
ALTER TABLE `chat_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT a táblához `chat_message`
--
ALTER TABLE `chat_message`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=318;

--
-- AUTO_INCREMENT a táblához `competition`
--
ALTER TABLE `competition`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT a táblához `login`
--
ALTER TABLE `login`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2671;

--
-- AUTO_INCREMENT a táblához `log_data`
--
ALTER TABLE `log_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8503;

--
-- AUTO_INCREMENT a táblához `news`
--
ALTER TABLE `news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT a táblához `private_message`
--
ALTER TABLE `private_message`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT a táblához `question_comment`
--
ALTER TABLE `question_comment`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=788;

--
-- AUTO_INCREMENT a táblához `quiz_played`
--
ALTER TABLE `quiz_played`
  MODIFY `test_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=565;

--
-- AUTO_INCREMENT a táblához `quiz_question`
--
ALTER TABLE `quiz_question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7744;

--
-- AUTO_INCREMENT a táblához `thema`
--
ALTER TABLE `thema`
  MODIFY `id_number` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=184;

--
-- AUTO_INCREMENT a táblához `user`
--
ALTER TABLE `user`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

DELIMITER $$
--
-- Események
--
CREATE DEFINER=`root`@`localhost` EVENT `activate_competition` ON SCHEDULE EVERY 12 HOUR STARTS '2021-10-20 23:39:00' ENDS '2030-11-26 21:57:40' ON COMPLETION PRESERVE ENABLE DO BEGIN
	DECLARE x INT DEFAULT 0;
	DECLARE c_id INT;
	DECLARE c_announcement_date DATE;
	DECLARE c_startdate DATETIME;
	DECLARE c_enddate DATETIME;
	DECLARE c_activity INT;
	DECLARE done BOOLEAN DEFAULT 0;
	DECLARE curz1 CURSOR FOR SELECT id, announcement_date, startdate, enddate, activity FROM competition WHERE activity > -1 ORDER BY announcement_date ASC;        
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
	
START TRANSACTION;
	OPEN curz1;
		REPEAT
			FETCH curz1 INTO c_id, c_announcement_date, c_startdate, c_enddate, c_activity;
			IF ( ! done  AND x < 1) THEN
				IF( c_activity = 1 ) THEN
					IF(NOW() > c_enddate) THEN
						UPDATE competition SET activity = -1 WHERE id = c_id;
					END IF;
				ELSE
					IF(c_announcement_date <= NOW() AND c_enddate > NOW()) THEN
						UPDATE competition SET activity = 1 WHERE id = c_id;
						SET x = 1;
					END IF;
				END IF;
			END IF;
		UNTIL done END REPEAT;
	CLOSE curz1;
	
COMMIT;
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
