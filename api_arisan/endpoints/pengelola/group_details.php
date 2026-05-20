<?php
// Include database connection
require_once '../../config/config.php';

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

// Helper function to return errors
function returnError($message)
{
    echo json_encode([
        'status' => 'error',
        'message' => $message
    ]);
    exit;
}

// Function to get winners history
function getWinnersHistory($db, $groupId)
{
    $groupId = (int)$groupId;

    $query = "SELECT w.month, w.participant_id, p.name as winner_name, 
              DATE_FORMAT(w.draw_date, '%d %M %Y %H:%i') as draw_date
              FROM winners w
              JOIN participants p ON w.participant_id = p.id
              WHERE w.group_id = ?
              ORDER BY w.month ASC";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "i", $groupId);

        if (mysqli_stmt_execute($stmt)) {
            $result = mysqli_stmt_get_result($stmt);
            $winners = [];

            while ($row = mysqli_fetch_assoc($result)) {
                // Convert numeric values to appropriate types
                $row['month'] = (int)$row['month'];
                $row['participant_id'] = (int)$row['participant_id'];
                $winners[] = $row;
            }

            mysqli_stmt_close($stmt);
            return [
                'status' => 'success',
                'data' => $winners
            ];
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

// Function to check if the draw date has been set and if it's time to draw
function checkDrawDate($db, $groupId)
{
    $groupId = (int)$groupId;
    
    // Get current month from groups table
    $monthQuery = "SELECT current_month FROM `groups` WHERE id = ?";
    $stmt = mysqli_prepare($db, $monthQuery);
    mysqli_stmt_bind_param($stmt, "i", $groupId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $monthData = mysqli_fetch_assoc($result);
    $currentMonth = (int)$monthData['current_month'];
    mysqli_stmt_close($stmt);
    
    // Check if draw date is set for the current month
    $query = "SELECT draw_date FROM draw_dates WHERE group_id = ? AND month = ?";
    
    $stmt = mysqli_prepare($db, $query);
    mysqli_stmt_bind_param($stmt, "ii", $groupId, $currentMonth);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        $drawDate = new DateTime($row['draw_date']);
        $now = new DateTime();
        
        // Format the date for display
        $formattedDate = $drawDate->format('d M Y H:i');
        
        // Fix: Ensure proper timezone comparison and add debug info
        $drawDateTimestamp = $drawDate->getTimestamp();
        $nowTimestamp = $now->getTimestamp();
        $canDraw = ($nowTimestamp >= $drawDateTimestamp);
        
        mysqli_stmt_close($stmt);
        return [
            'is_date_set' => true,
            'draw_date' => $formattedDate,
            'can_draw' => $canDraw,
            'now_time' => $now->format('d M Y H:i:s'),
            'draw_time' => $drawDate->format('d M Y H:i:s'),
            'now_timestamp' => $nowTimestamp,
            'draw_timestamp' => $drawDateTimestamp
        ];
    } else {
        mysqli_stmt_close($stmt);
        return [
            'is_date_set' => false,
            'draw_date' => 'Belum ditetapkan',
            'can_draw' => false
        ];
    }
}

// Function to set the draw date
function setDrawDate($db, $data)
{
    if (!isset($data['group_id']) || !isset($data['draw_date']) || !isset($data['current_month'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }
    
    $groupId = (int)$data['group_id'];
    $drawDate = mysqli_real_escape_string($db, $data['draw_date']);
    $currentMonth = (int)$data['current_month'];
    
    // Check if a draw date already exists for this month
    $checkQuery = "SELECT id FROM draw_dates WHERE group_id = ? AND month = ?";
    $stmt = mysqli_prepare($db, $checkQuery);
    mysqli_stmt_bind_param($stmt, "ii", $groupId, $currentMonth);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    
    if (mysqli_num_rows($result) > 0) {
        // Update existing record
        $row = mysqli_fetch_assoc($result);
        $id = $row['id'];
        mysqli_stmt_close($stmt);
        
        $updateQuery = "UPDATE draw_dates SET draw_date = ? WHERE id = ?";
        $stmt = mysqli_prepare($db, $updateQuery);
        mysqli_stmt_bind_param($stmt, "si", $drawDate, $id);
        
        if (mysqli_stmt_execute($stmt)) {
            mysqli_stmt_close($stmt);
            return [
                'status' => 'success',
                'message' => 'Tanggal pengundian berhasil diperbarui'
            ];
        }
    } else {
        // Insert new record
        mysqli_stmt_close($stmt);
        
        $insertQuery = "INSERT INTO draw_dates (group_id, month, draw_date) VALUES (?, ?, ?)";
        $stmt = mysqli_prepare($db, $insertQuery);
        mysqli_stmt_bind_param($stmt, "iis", $groupId, $currentMonth, $drawDate);
        
        if (mysqli_stmt_execute($stmt)) {
            mysqli_stmt_close($stmt);
            return [
                'status' => 'success',
                'message' => 'Tanggal pengundian berhasil ditetapkan'
            ];
        }
    }
    
    $error = mysqli_stmt_error($stmt);
    mysqli_stmt_close($stmt);
    
    return [
        'status' => 'error',
        'message' => 'Error setting draw date: ' . $error
    ];
}

// Function to login as participant
function loginParticipant($db, $data)
{
    if (!isset($data['name']) || !isset($data['password'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    $name = mysqli_real_escape_string($db, $data['name']);
    $password = mysqli_real_escape_string($db, $data['password']);

    // Find the participant with these credentials
    $query = "SELECT p.*, g.group_name, g.contribution_amount, g.start_month, g.total_participants, g.current_month 
              FROM participants p
              JOIN `groups` g ON p.group_id = g.id
              WHERE p.name = ? AND p.password = ?";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "ss", $name, $password);

        if (mysqli_stmt_execute($stmt)) {
            $result = mysqli_stmt_get_result($stmt);

            if (mysqli_num_rows($result) > 0) {
                $data = mysqli_fetch_assoc($result);
                mysqli_stmt_close($stmt);

                return [
                    'status' => 'success',
                    'message' => 'Login berhasil',
                    'data' => [
                        'group_id' => (int)$data['group_id'],
                        'group_name' => $data['group_name'],
                        'contribution_amount' => (int)$data['contribution_amount'],
                        'start_month' => $data['start_month'],
                        'total_participants' => (int)$data['total_participants'],
                        'current_month' => (int)$data['current_month'],
                        'participant_id' => (int)$data['id'],
                        'participant_name' => $data['name']
                    ]
                ];
            } else {
                mysqli_stmt_close($stmt);
                return [
                    'status' => 'error',
                    'message' => 'Nama peserta atau password salah'
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

// Function to get participant by name
function getParticipantByName($db, $data)
{
    if (!isset($data['group_id']) || !isset($data['name'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    $groupId = (int)$data['group_id'];
    $name = mysqli_real_escape_string($db, $data['name']);

    // Get participant with dynamic payment status based on current month
    $query = "SELECT p.id, p.group_id, p.name, p.password, 
              IFNULL((SELECT 1 FROM payments pm WHERE pm.participant_id = p.id AND pm.month = g.current_month LIMIT 1), 0) as payment_confirmed 
              FROM participants p
              JOIN `groups` g ON p.group_id = g.id
              WHERE p.group_id = ? AND p.name = ? LIMIT 1";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "is", $groupId, $name);

        if (mysqli_stmt_execute($stmt)) {
            $result = mysqli_stmt_get_result($stmt);

            if (mysqli_num_rows($result) > 0) {
                $participant = mysqli_fetch_assoc($result);
                // Convert numeric values to integers
                $participant['id'] = (int)$participant['id'];
                $participant['group_id'] = (int)$participant['group_id'];
                $participant['payment_confirmed'] = (bool)$participant['payment_confirmed'];

                mysqli_stmt_close($stmt);
                return [
                    'status' => 'success',
                    'data' => $participant
                ];
            } else {
                mysqli_stmt_close($stmt);
                return [
                    'status' => 'error',
                    'message' => 'Participant not found'
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

// Function to get payments for a specific participant
function getParticipantPayments($db, $groupId, $participantId)
{
    $groupId = (int)$groupId;
    $participantId = (int)$participantId;

    $query = "SELECT p.id, p.group_id, p.month, p.amount, p.payment_status, 
              DATE_FORMAT(p.payment_date, '%d %M %Y %H:%i') as payment_date,
              IFNULL(w.is_winner, 0) as is_winner,
              IFNULL(w.draw_date, NULL) as draw_date
              FROM payments p
              LEFT JOIN winners w ON p.group_id = w.group_id 
                AND p.month = w.month 
                AND p.participant_id = w.participant_id
              WHERE p.group_id = ? AND p.participant_id = ?
              ORDER BY p.month ASC";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "ii", $groupId, $participantId);

        if (mysqli_stmt_execute($stmt)) {
            $result = mysqli_stmt_get_result($stmt);
            $payments = [];

            while ($row = mysqli_fetch_assoc($result)) {
                // Convert numeric values to appropriate types
                $row['id'] = (int)$row['id'];
                $row['group_id'] = (int)$row['group_id'];
                $row['month'] = (int)$row['month'];
                $row['amount'] = (float)$row['amount'];
                $row['is_winner'] = (bool)$row['is_winner'];
                $row['payment_status'] = 'completed'; // Since we only store confirmed payments
                $payments[] = $row;
            }

            mysqli_stmt_close($stmt);
            return [
                'status' => 'success',
                'data' => $payments
            ];
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

// Function to get participants of a group
function getParticipants($db, $groupId)
{
    $groupId = (int)$groupId;

    // Get participants with dynamic payment status based on current month
    $query = "SELECT p.id, p.group_id, p.name, p.password, 
              IFNULL((SELECT 1 FROM payments pm WHERE pm.participant_id = p.id AND pm.month = g.current_month LIMIT 1), 0) as payment_confirmed 
              FROM participants p
              JOIN `groups` g ON p.group_id = g.id
              WHERE p.group_id = ? ORDER BY p.id ASC";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "i", $groupId);

        if (mysqli_stmt_execute($stmt)) {
            $result = mysqli_stmt_get_result($stmt);
            $participants = [];
            $counter = 1; // Untuk nomor urut

            while ($row = mysqli_fetch_assoc($result)) {
                // Convert numeric values to integers
                $row['id'] = (int)$row['id'];
                $row['group_id'] = (int)$row['group_id'];
                $row['payment_confirmed'] = (bool)$row['payment_confirmed'];
                $row['no'] = $counter++; // Menambahkan nomor urut
                $participants[] = $row;
            }

            mysqli_stmt_close($stmt);
            return [
                'status' => 'success',
                'data' => $participants
            ];
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

// Function to update group name
function updateGroupName($db, $data)
{
    if (!isset($data['user_id']) || !isset($data['group_id']) || !isset($data['group_name'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    $userId = (int)$data['user_id'];
    $groupId = (int)$data['group_id'];
    $groupName = mysqli_real_escape_string($db, $data['group_name']);

    // Check if group belongs to the user
    $checkQuery = "SELECT * FROM `groups` WHERE id = ? AND user_id = ?";
    $stmt = mysqli_prepare($db, $checkQuery);
    mysqli_stmt_bind_param($stmt, "ii", $groupId, $userId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($result) === 0) {
        mysqli_stmt_close($stmt);
        return [
            'status' => 'error',
            'message' => 'Grup tidak ditemukan atau Anda tidak memiliki akses'
        ];
    }
    mysqli_stmt_close($stmt);

    // Update group name
    $updateQuery = "UPDATE `groups` SET group_name = ? WHERE id = ? AND user_id = ?";
    if ($stmt = mysqli_prepare($db, $updateQuery)) {
        mysqli_stmt_bind_param($stmt, "sii", $groupName, $groupId, $userId);

        if (mysqli_stmt_execute($stmt)) {
            mysqli_stmt_close($stmt);
            return [
                'status' => 'success',
                'message' => 'Nama grup berhasil diperbarui'
            ];
        }

        $error = mysqli_stmt_error($stmt);
        mysqli_stmt_close($stmt);
        return [
            'status' => 'error',
            'message' => 'Error updating group name: ' . $error
        ];
    }

    return [
        'status' => 'error',
        'message' => 'Error preparing statement: ' . mysqli_error($db)
    ];
}

// Function to add a participant
function addParticipant($db, $data)
{
    if (!isset($data['group_id']) || !isset($data['name']) || !isset($data['password'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    $groupId = (int)$data['group_id'];
    $name = mysqli_real_escape_string($db, $data['name']);
    $password = $data['password']; // Simpan password dalam bentuk plain text untuk ditampilkan

    // First, check current participant count vs limit
    $checkQuery = "SELECT COUNT(*) as current_count, 
                  (SELECT total_participants FROM `groups` WHERE id = ?) as total_participants 
                  FROM participants WHERE group_id = ?";

    $stmt = mysqli_prepare($db, $checkQuery);
    mysqli_stmt_bind_param($stmt, "ii", $groupId, $groupId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $countData = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);

    if ($countData && (int)$countData['current_count'] >= (int)$countData['total_participants']) {
        return [
            'status' => 'error',
            'message' => 'Jumlah peserta sudah mencapai batas maksimal'
        ];
    }

    $query = "INSERT INTO participants (group_id, name, password) VALUES (?, ?, ?)";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "iss", $groupId, $name, $password);

        if (mysqli_stmt_execute($stmt)) {
            $participantId = mysqli_insert_id($db);
            mysqli_stmt_close($stmt);
            return [
                'status' => 'success',
                'message' => 'Peserta berhasil ditambahkan',
                'participant_id' => $participantId
            ];
        }

        $error = mysqli_stmt_error($stmt);
        mysqli_stmt_close($stmt);
        return [
            'status' => 'error',
            'message' => 'Error adding participant: ' . $error
        ];
    }

    return [
        'status' => 'error',
        'message' => 'Error preparing statement: ' . mysqli_error($db)
    ];
}

// Function to update payment status
function updatePayment($db, $data)
{
    if (!isset($data['participant_id']) || !isset($data['group_id'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    $participantId = (int)$data['participant_id'];
    $groupId = (int)$data['group_id'];

    // Start transaction
    mysqli_begin_transaction($db);

    try {
        // 1. (REMOVED) No longer updating payment_confirmed column in participants table as it's dynamically calculated.

        // 2. Get current month from groups table
        $query2 = "SELECT current_month FROM `groups` WHERE id = ?";
        $stmt2 = mysqli_prepare($db, $query2);
        mysqli_stmt_bind_param($stmt2, "i", $groupId);
        mysqli_stmt_execute($stmt2);
        $result2 = mysqli_stmt_get_result($stmt2);
        $group = mysqli_fetch_assoc($result2);
        mysqli_stmt_close($stmt2);

        if (!$group) {
            throw new Exception("Grup tidak ditemukan");
        }

        $currentMonth = (int)$group['current_month'];

        // 3. Check if payment record already exists
        $query3 = "SELECT id FROM payments WHERE group_id = ? AND participant_id = ? AND month = ?";
        $stmt3 = mysqli_prepare($db, $query3);
        mysqli_stmt_bind_param($stmt3, "iii", $groupId, $participantId, $currentMonth);
        mysqli_stmt_execute($stmt3);
        $result3 = mysqli_stmt_get_result($stmt3);
        $paymentExists = mysqli_num_rows($result3) > 0;
        mysqli_stmt_close($stmt3);

        // 4. If payment record doesn't exist, insert it
        if (!$paymentExists) {
            // Get contribution amount from groups table
            $query4 = "SELECT contribution_amount FROM `groups` WHERE id = ?";
            $stmt4 = mysqli_prepare($db, $query4);
            mysqli_stmt_bind_param($stmt4, "i", $groupId);
            mysqli_stmt_execute($stmt4);
            $result4 = mysqli_stmt_get_result($stmt4);
            $groupData = mysqli_fetch_assoc($result4);
            mysqli_stmt_close($stmt4);

            if (!$groupData) {
                throw new Exception("Grup tidak ditemukan");
            }

            $amount = (int)$groupData['contribution_amount'];

            // Insert payment record with current timestamp
            $query5 = "INSERT INTO payments (group_id, participant_id, month, amount, payment_date, payment_status) 
                      VALUES (?, ?, ?, ?, NOW(), 'completed')";
            $stmt5 = mysqli_prepare($db, $query5);
            mysqli_stmt_bind_param($stmt5, "iiii", $groupId, $participantId, $currentMonth, $amount);
            $result5 = mysqli_stmt_execute($stmt5);
            mysqli_stmt_close($stmt5);

            if (!$result5) {
                throw new Exception("Gagal mencatat pembayaran");
            }
        }

        // Commit transaction
        mysqli_commit($db);

        return [
            'status' => 'success',
            'message' => 'Pembayaran berhasil dikonfirmasi'
        ];
    } catch (Exception $e) {
        // Rollback transaction on error
        mysqli_rollback($db);

        return [
            'status' => 'error',
            'message' => $e->getMessage()
        ];
    }
}

// Function to delete a participant
function deleteParticipant($db, $data)
{
    if (!isset($data['participant_id']) || !isset($data['group_id'])) {
        return [
            'status' => 'error',
            'message' => 'Missing required fields'
        ];
    }

    $participantId = (int)$data['participant_id'];
    $groupId = (int)$data['group_id'];

    $query = "DELETE FROM participants WHERE id = ? AND group_id = ?";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "ii", $participantId, $groupId);

        if (mysqli_stmt_execute($stmt)) {
            if (mysqli_affected_rows($db) > 0) {
                mysqli_stmt_close($stmt);
                return [
                    'status' => 'success',
                    'message' => 'Peserta berhasil dihapus'
                ];
            } else {
                mysqli_stmt_close($stmt);
                return [
                    'status' => 'error',
                    'message' => 'Peserta tidak ditemukan'
                ];
            }
        }

        $error = mysqli_stmt_error($stmt);
        mysqli_stmt_close($stmt);
        return [
            'status' => 'error',
            'message' => 'Error deleting participant: ' . $error
        ];
    }

    return [
        'status' => 'error',
        'message' => 'Error preparing statement: ' . mysqli_error($db)
    ];
}

// Main execution
try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Check if this is a request to check the draw date
        if (isset($_GET['check_draw_date']) && isset($_GET['group_id'])) {
            echo json_encode(checkDrawDate($db, $_GET['group_id']));
            exit;
        }
        
        // Check if this is a request to get winners history
        if (isset($_GET['action']) && $_GET['action'] === 'get_winners_history' && isset($_GET['group_id'])) {
            echo json_encode(getWinnersHistory($db, $_GET['group_id']));
            exit;
        }
        
        if (
            isset($_GET['action']) && $_GET['action'] === 'get_participant_payments'
            && isset($_GET['group_id']) && isset($_GET['participant_id'])
        ) {
            echo json_encode(getParticipantPayments($db, $_GET['group_id'], $_GET['participant_id']));
        } else if (isset($_GET['group_id'])) {
            echo json_encode(getParticipants($db, $_GET['group_id']));
        } else {
            returnError('Group ID tidak ditemukan');
        }
    } else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $json_data = file_get_contents('php://input');
        $data = json_decode($json_data, true);

        if ($data === null) {
            returnError('Invalid JSON data');
        }

        if (!isset($data['action'])) {
            returnError('Action tidak ditentukan');
        }

        switch ($data['action']) {
            case 'add':
                echo json_encode(addParticipant($db, $data));
                break;
            case 'update_payment':
                echo json_encode(updatePayment($db, $data));
                break;
            case 'delete':
                echo json_encode(deleteParticipant($db, $data));
                break;
            case 'update':
                echo json_encode(updateGroupName($db, $data));
                break;
            case 'login_participant':
                echo json_encode(loginParticipant($db, $data));
                break;
            case 'get_participant_by_name':
                echo json_encode(getParticipantByName($db, $data));
                break;
            case 'get_participant_payments':
                // For POST requests, we need the group_id and participant_id from the data
                if (isset($data['group_id']) && isset($data['participant_id'])) {
                    echo json_encode(getParticipantPayments($db, $data['group_id'], $data['participant_id']));
                } else {
                    returnError('Missing required fields: group_id or participant_id');
                }
                break;
            case 'set_draw_date':
                if (isset($data['group_id']) && isset($data['draw_date']) && isset($data['current_month'])) {
                    echo json_encode(setDrawDate($db, $data));
                } else {
                    returnError('Missing required fields for setting draw date');
                }
                break;
            default:
                returnError('Action tidak valid');
                break;
        }
    } else {
        returnError('Method tidak diizinkan');
    }
} catch (Exception $e) {
    returnError('Server error: ' . $e->getMessage());
}