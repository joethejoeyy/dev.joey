<?php
$pdo = new PDO('mysql:host=mysql-lab;dbname=demo', 'root', 'pass');
$stmt = $pdo->query('SELECT id, message FROM notes ORDER BY id ASC LIMIT 1');
$row = $stmt->fetch(PDO::FETCH_ASSOC);
if ($row) {
  echo $row['id'] . ': ' . $row['message'];
} else {
  echo 'No data found.';
}
?>
