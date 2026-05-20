<?php
// Include database connection
require_once '../../config/config.php';

// Set response headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests for CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Check if it's a POST request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get JSON data from request body
    $json_data = file_get_contents('php://input');
    $data = json_decode($json_data, true);

    // Check if required fields are present
    if (isset($data['username']) && isset($data['email']) && isset($data['password'])) {
        $username = mysqli_real_escape_string($db, $data['username']);
        $email = mysqli_real_escape_string($db, $data['email']);
        $password = mysqli_real_escape_string($db, $data['password']);

        // Hash the password
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        // Check if username already exists
        $check_username = "SELECT * FROM pengelola WHERE username = '$username'";
        $result_username = mysqli_query($db, $check_username);

        if (mysqli_num_rows($result_username) > 0) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Username sudah digunakan. Silakan gunakan username lain.'
            ]);
            exit;
        }

        // Check if email already exists
        $check_email = "SELECT * FROM pengelola WHERE email = '$email'";
        $result_email = mysqli_query($db, $check_email);

        if (mysqli_num_rows($result_email) > 0) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Email sudah terdaftar. Silakan gunakan email lain.'
            ]);
            exit;
        }

        // Insert new user
        $query = "INSERT INTO pengelola (username, email, password) VALUES ('$username', '$email', '$hashed_password')";

        if (mysqli_query($db, $query)) {
            // Get the inserted user's ID (ensure it's an integer)
            $user_id = mysqli_insert_id($db);

            echo json_encode([
                'status' => 'success',
                'message' => 'Registrasi berhasil. Silakan login.',
                'data' => [
                    'id' => (int)$user_id, // Explicitly cast to integer
                    'username' => $username,
                    'email' => $email
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Gagal mendaftarkan pengguna: ' . mysqli_error($db)
            ]);
        }
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Data tidak lengkap. Harap isi username, email, dan password.'
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Method tidak diizinkan. Gunakan POST.'
    ]);
}
