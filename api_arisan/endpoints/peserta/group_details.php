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
        'error' => $message
    ]);
    exit;
}

// Function to get participant payments
function getParticipantPayments($db, $groupId, $participantId)
{
    $groupId = (int)$groupId;
    $participantId = (int)$participantId;

    // Get payments for this participant
    $query = "SELECT p.month, p.amount, DATE_FORMAT(p.payment_date, '%d/%m/%Y %H:%i') as payment_date 
              FROM payments p 
              WHERE p.group_id = ? AND p.participant_id = ? 
              ORDER BY p.month ASC";

    if ($stmt = mysqli_prepare($db, $query)) {
        mysqli_stmt_bind_param($stmt, "ii", $groupId, $participantId);

        if (mysqli_stmt_execute($stmt)) {
            $result = mysqli_stmt_get_result($stmt);
            $payments = [];

            while ($row = mysqli_fetch_assoc($result)) {
                // Convert numeric values to appropriate types
                $row['month'] = (int)$row['month'];
                $row['amount'] = (float)$row['amount'];
                $payments[] = $row;
            }

            mysqli_stmt_close($stmt);
            return [
                'payments' => $payments
            ];
        }

        $error = mysqli_stmt_error($stmt);
        mysqli_stmt_close($stmt);
        return [
            'error' => 'Error executing query: ' . $error
        ];
    }

    return [
        'error' => 'Error preparing statement: ' . mysqli_error($db)
    ];
}

// Function to get winners history
function getWinnersHistory($db, $groupId)
{
    $groupId = (int)$groupId;

    // Get winners for this group
    $query = "SELECT w.month, p.id as participant_id, p.name as winner_name, 
              DATE_FORMAT(w.win_date, '%d/%m/%Y %H:%i') as win_date 
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
                'winners' => $winners
            ];
        }

        $error = mysqli_stmt_error($stmt);
        mysqli_stmt_close($stmt);
        return [
            'error' => 'Error executing query: ' . $error
        ];
    }

    return [
        'error' => 'Error preparing statement: ' . mysqli_error($db)
    ];
}

// Main execution
try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Check which action is requested
        if (isset($_GET['action'])) {
            $action = $_GET['action'];
            
            if ($action === 'get_participant_payments') {
                if (isset($_GET['group_id']) && isset($_GET['participant_id'])) {
                    $groupId = (int)$_GET['group_id'];
                    $participantId = (int)$_GET['participant_id'];
                    echo json_encode(getParticipantPayments($db, $groupId, $participantId));
                } else {
                    returnError('Missing required parameters: group_id or participant_id');
                }
            } elseif ($action === 'get_winners_history') {
                if (isset($_GET['group_id'])) {
                    $groupId = (int)$_GET['group_id'];
                    echo json_encode(getWinnersHistory($db, $groupId));
                } else {
                    returnError('Missing required parameter: group_id');
                }
            } else {
                returnError('Invalid action');
            }
        } else {
            returnError('No action specified');
        }
    } else {
        returnError('Method not allowed');
    }
} catch (Exception $e) {
    returnError('Server error: ' . $e->getMessage());
}
