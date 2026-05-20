<?php
// Set timezone to Jakarta (Indonesia)
date_default_timezone_set('Asia/Jakarta');

$server = "localhost";
$user = "root";
$password = "";
$nama_database = "dbarisan";

// Tambahkan error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = mysqli_connect($server, $user, $password, $nama_database);
if (!$db) {
    die("Gagal terhubung dengan database: " . mysqli_connect_error());
}

// Set karakter encoding
mysqli_set_charset($db, "utf8mb4");

// Fungsi untuk debugging waktu
function debug_time($message) {
    $now = new DateTime();
    error_log($message . ": " . $now->format('Y-m-d H:i:s') . " (" . time() . ")");
}

// Log waktu server saat ini untuk debugging
debug_time("Server time at config load");
