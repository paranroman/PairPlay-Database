-- DDL

--Table untuk menyimpan data pemain
CREATE TABLE pemain(
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    username VARCHAR(50) UNIQUE,
    bio TEXT,
    photo VARCHAR(255) DEFAULT 'assets/FrontPage/images.png',
    achievement JSON DEFAULT '["","assets/Frontpage/transparent.png", "assets/Frontpage/transparent.png", "assets/Frontpage/transparent.png", "assets/Frontpage/transparent.png"]'
);

--Table untuk menyimpan id level
CREATE Table level(
    id SERIAL PRIMARY KEY,
    Name VARCHAR(10)
);

--Table untuk menyimpan data game
CREATE TABLE game (
    id SERIAL PRIMARY KEY,
    id_pemain INT,
    id_level INT,
    death INT DEFAULT 0,
    time_spent TIME,
    easter_egg INT,
    FOREIGN KEY (id_pemain) REFERENCES pemain(id),
    FOREIGN KEY (id_level) REFERENCES level(id)
);

--Table untuk menyimpan data leaderboard
CREATE TABLE leaderboard (
    id SERIAL PRIMARY KEY,
    id_pemain INT,
    id_level INT,
    least_death INT DEFAULT 0,
    least_time TIME,
    FOREIGN KEY (id_pemain) REFERENCES pemain(id),
    FOREIGN KEY (id_level) REFERENCES level(id)
);

--DML

--Insert data pemain setelah sign up
INSERT INTO pemain (
    email, 
    password, 
    username)
VALUES (
    'bintanggendut@gmail.com', 
    'starstar',
    'qwopiy'
);

-- Query untuk memasukkan data ke dalam tabel game setiap mati
INSERT INTO game(
    id_pemain, 
    id_level, 
    death, 
    easter_egg
) VALUES (
    $id, 
    $level, 
    $death, 
    $easter_egg
);

-- Query untuk menyimpan waktu yang dihabiskan untuk menyelesaikan level setiap clear level
INSERT INTO game(
    id_pemain, 
    id_level, 
    death, 
    time_spent, 
    easter_egg)
VALUES (
    $id, 
    $level, 
    $death, 
    ($time || ' seconds')::INTERVAL::TIME, 
    $easter_egg
);

--Insert data leaderboard berdasarkan data game, ketika id_pemain dan id_level sama maka data akan diupdate ke data yang mempunyai value lebih kecil
INSERT INTO leaderboard (
    id_pemain, 
    id_level, 
    least_death, 
    least_time)
SELECT 
    id_pemain, 
    id_level, 
    MIN(death) AS least_death, 
    MIN(time_spent) AS least_time
FROM 
    game
GROUP BY 
    id_pemain, 
    id_level
ON CONFLICT 
    (id_pemain, id_level) 
DO UPDATE SET 
    least_death = LEAST(EXCLUDED.least_death, leaderboard.least_death), 
    least_time = LEAST(EXCLUDED.least_time, leaderboard.least_time);

--menampilkan data leaderboard berdasarkan least_time yang paling kecil, dan least_death yang paling kecil
SELECT 
    p.username, 
    l.least_time
FROM 
    leaderboard l
JOIN 
    pemain p 
ON 
    p.id = l.id_pemain
WHERE 
    l.id_level = 1
ORDER BY 
    l.least_time 
ASC;

-- Update progress setiap clear level
UPDATE 
    pemain 
SET 
    progress = $progress 
WHERE 
    id = $id;

-- Ambil progress pemain
SELECT 
    progress 
FROM 
    pemain 
WHERE 
    id = {$_SESSION['USER']->id};

--update username, bio, photo
UPDATE 
    pemain 
SET 
    username = '$username', 
    bio = '$bio', 
    photo ='$photo' 
WHERE 
    id ='$id';

--mengambil data berdasarkan id
SELECT 
    id, 
    username, 
    bio, 
    photo, 
    achievement  
FROM 
    pemain 
WHERE 
    id ='$id';

--mengambil data berdasarkan username
SELECT 
    id, 
    username, 
    bio, 
    photo, 
    achievement 
FROM 
    pemain 
WHERE 
    username = '$username';

--jumlahin semua death yang player punya
SELECT 
    SUM(death) as death 
FROM 
    game 
WHERE 
    id_pemain = '$id';

--mencari apakah player telah menemukan easter egg
SELECT 
    easter_egg 
FROM 
    game 
WHERE 
    id_pemain = '$id' 
AND 
    easter_egg = 1 
LIMIT 1;

--mencari Waktu terkecil dan jumlah mati seorang player tergantung leve yang ia mainkan
SELECT 
    id_level, 
    min(time_spent) as time_spent, 
    sum(death) as death 
FROM 
    game 
WHERE 
    id_pemain = '$id' 
GROUP BY 
    id_level;

--update set achievement yang akan tampil di leaderboard
UPDATE 
    pemain 
SET 
    achievement = '$data' 
WHERE 
    id = '$id';

--fitur search pada index
SELECT 
    * 
FROM 
    pemain 
WHERE 
    LOWER(username) 
LIKE 
    LOWER(:username) 
ORDER BY 
    username 
ASC;
