<?php
// Include database connection
require_once '../../config/config.php';

// Prevent PHP errors from being displayed directly in the output
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Set response headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests for CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Helper function to return errors as JSON
function returnError($message)
{
    echo json_encode([
        'status' => 'error',
        'message' => $message
    ]);
    exit;
}

// Function to get all groups for a specific user
// Function to create a new group
function createGroup($db, $data)
{
    // Validate required fields
    if (
        !isset($data['user_id']) || !isset($data['group_name']) ||
        !isset($data['contribution_amount']) || !isset($data['start_month']) ||
        !isset($data['total_participants'])
    ) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    // Sanitize and prepare data
    $userId = (int)$data['user_id'];
    $groupName = mysqli_real_escape_string($db, $data['group_name']);
    $contributionAmount = (int)$data['contribution_amount'];
    $startMonth = mysqli_real_escape_string($db, $data['start_month']);
    $totalParticipants = (int)$data['total_participants'];
    $currentMonth = 1; // New groups start at month 1

    // Prepare the SQL statement
    $query = "INSERT INTO `groups` (user_id, group_name, contribution_amount, start_month, total_participants, current_month) 
              VALUES (?, ?, ?, ?, ?, ?)";

    // Use prepared statement
    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param(
            $stmt,
            "isisii",
            $userId,
            $groupName,
            $contributionAmount,
            $startMonth,
            $totalParticipants,
            $currentMonth
        );

        if (mysqli_stmt_execute($stmt)) {
            $groupId = mysqli_insert_id($db);
            mysqli_stmt_close($stmt);
            return [
                'status' => 'success',
                'message' => 'Grup berhasil dibuat',
                'group_id' => $groupId
            ];
        } else {
            $error = mysqli_stmt_error($stmt);
            mysqli_stmt_close($stmt);
            return [
                'status' => 'error',
                'message' => 'Gagal membuat grup: ' . $error
            ];
        }
    } else {
        return [
            'status' => 'error',
            'message' => 'Error preparing statement: ' . mysqli_error($db)
        ];
    }
}

// Function to get all groups for a specific user
function getUserGroups($db, $userId)
{
    // Sanitize user ID
    $userId = (int)$userId;

    // Prepare the SQL statement
    $query = "SELECT * FROM `groups` WHERE user_id = ? ORDER BY id DESC";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "i", $userId);

        if (mysqli_stmt_execute($stmt)) {
            $result = mysqli_stmt_get_result($stmt);

            if ($result) {
                $groups = [];
                while ($row = mysqli_fetch_assoc($result)) {
                    // Convert numeric values to integers
                    $row['id'] = (int)$row['id'];
                    $row['user_id'] = (int)$row['user_id'];
                    $row['contribution_amount'] = (int)$row['contribution_amount'];
                    $row['total_participants'] = (int)$row['total_participants'];
                    $row['current_month'] = (int)$row['current_month'];

                    $groups[] = $row;
                }

                mysqli_stmt_close($stmt);
                return [
                    'status' => 'success',
                    'data' => $groups
                ];
            }
        }

        $error = mysqli_stmt_error($stmt);
        mysqli_stmt_close($stmt);
        return [
            'status' => 'error',
            'message' => 'Error executing query: ' . $error
        ];
    }

    return [
        'status' => 'error',
        'message' => 'Error preparing statement: ' . mysqli_error($db)
    ];
}



// Function to update a group
// Function to update a group
// Function to update group
function updateGroup($db, $data) {
    // Validate required fields
    if (!isset($data['user_id']) || !isset($data['group_id']) || !isset($data['group_name'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    $userId = (int)$data['user_id'];
    $groupId = (int)$data['group_id'];
    $groupName = mysqli_real_escape_string($db, $data['group_name']);

    // Update query dengan prepared statement
    $stmt = mysqli_prepare($db, "UPDATE `groups` SET group_name = ? WHERE id = ? AND user_id = ?");
    mysqli_stmt_bind_param($stmt, "ssi", $groupName, $groupId, $userId);
    
    if (mysqli_stmt_execute($stmt)) {
        if (mysqli_affected_rows($db) > 0) {
            return [
                'status' => 'success',
                'message' => 'Nama grup berhasil diperbarui'
            ];
        } else {
            return [
                'status' => 'error',
                'message' => 'Grup tidak ditemukan atau tidak ada perubahan'
            ];
        }
    } else {
        return [
            'status' => 'error',
            'message' => 'Gagal memperbarui grup: ' . mysqli_error($db)
        ];
    }
}

// Function to delete a group
function deleteGroup($db, $data)
{
    // Validate required fields
    if (!isset($data['user_id']) || !isset($data['group_id'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    // Convert and sanitize data
    $userId = (int)$data['user_id'];
    $groupId = (int)$data['group_id'];

    // Check if group belongs to the user using prepared statement
    $checkQuery = "SELECT * FROM `groups` WHERE id = ? AND user_id = ?";

    if ($checkStmt = mysqli_prepare($db, $checkQuery)) {
        mysqli_stmt_bind_param($checkStmt, "ii", $groupId, $userId);
        mysqli_stmt_execute($checkStmt);
        $checkResult = mysqli_stmt_get_result($checkStmt);

        if (mysqli_num_rows($checkResult) === 0) {
            mysqli_stmt_close($checkStmt);
            return [
                'status' => 'error',
                'message' => 'Grup tidak ditemukan atau Anda tidak memiliki akses'
            ];
        }
        mysqli_stmt_close($checkStmt);
    }

    // Delete group using prepared statement
    $deleteQuery = "DELETE FROM `groups` WHERE id = ? AND user_id = ?";

    if ($deleteStmt = mysqli_prepare($db, $deleteQuery)) {
        mysqli_stmt_bind_param($deleteStmt, "ii", $groupId, $userId);

        if (mysqli_stmt_execute($deleteStmt)) {
            mysqli_stmt_close($deleteStmt);
            return [
                'status' => 'success',
                'message' => 'Grup berhasil dihapus'
            ];
        } else {
            $error = mysqli_stmt_error($deleteStmt);
            mysqli_stmt_close($deleteStmt);
            return [
                'status' => 'error',
                'message' => 'Gagal menghapus grup: ' . $error
            ];
        }
    }

    return [
        'status' => 'error',
        'message' => 'Error preparing statement: ' . mysqli_error($db)
    ];
}

try {
    // Handle GET request (get all groups for a user)
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        if (isset($_GET['user_id'])) {
            $userId = $_GET['user_id'];
            echo json_encode(getUserGroups($db, $userId));
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'User ID tidak ditemukan'
            ]);
        }
    }

    // Handle POST request (create, update, or delete a group)
    else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $json_data = file_get_contents('php://input');
        $data = json_decode($json_data, true);

        if ($data === null) {
            returnError('Invalid JSON data');
        }

        if (!isset($data['action'])) {
            returnError('Action tidak ditentukan');
        }

        switch ($data['action']) {
            case 'create':
                echo json_encode(createGroup($db, $data));
                break;

            case 'update':
                echo json_encode(updateGroup($db, $data));
                break;

            case 'delete':
                echo json_encode(deleteGroup($db, $data));
                break;

            default:
                returnError('Action tidak valid');
                break;
        }
    }

    // Handle other request methods
    else {
        returnError('Method tidak diizinkan');
    }
} catch (Exception $e) {
    returnError('Server error: ' . $e->getMessage());
}
