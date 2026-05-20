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
    if (isset($data['username']) && isset($data['password'])) {
        $username = mysqli_real_escape_string($db, $data['username']);
        $password = $data['password'];

        // Query to find user by username
        $query = "SELECT * FROM pengelola WHERE username = '$username'";
        $result = mysqli_query($db, $query);

        if (mysqli_num_rows($result) === 1) {
            $user = mysqli_fetch_assoc($result);

            // Verify password
            if (password_verify($password, $user['password'])) {
                // Password is correct, login successful
                echo json_encode([
                    'status' => 'success',
                    'message' => 'Login berhasil!',
                    'data' => [
                        'id' => (int)$user['id'], // Explicitly cast to integer
                        'username' => $user['username'],
                        'email' => $user['email']
                    ]
                ]);
            } else {
                // Password is incorrect
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Password yang Anda masukkan salah.'
                ]);
            }
        } else {
            // User not found
            echo json_encode([
                'status' => 'error',
                'message' => 'Username tidak ditemukan.'
            ]);
        }
    } else {
        // Required fields missing
        echo json_encode([
            'status' => 'error',
            'message' => 'Username dan password harus diisi.'
        ]);
    }
} else {
    // Method not allowed
    echo json_encode([
        'status' => 'error',
        'message' => 'Method tidak diizinkan. Gunakan POST.'
    ]);
}
