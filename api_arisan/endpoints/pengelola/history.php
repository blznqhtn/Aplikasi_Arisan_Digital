<?php
// Add these lines at the very top of the file, before any other code
// This will suppress PHP warnings and notices from being output
error_reporting(0);
ini_set('display_errors', 0);

// Make sure this is at the top, right after the error suppression
// Include database connection
require_once '../../config/config.php';

// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// Function to get payment history for a group
function getPaymentHistory($db, $groupId)
{
    // Get group information
    // Note: Escaped 'groups' with backticks since it's a reserved keyword
    $groupQuery = "SELECT * FROM `groups` WHERE id = ?";
    $groupStmt = $db->prepare($groupQuery);
    $groupStmt->bind_param("i", $groupId);
    $groupStmt->execute();
    $groupResult = $groupStmt->get_result();

    if ($groupResult->num_rows === 0) {
        return ["error" => "Group not found"];
    }

    $group = $groupResult->fetch_assoc();
    $currentMonth = $group['current_month'];
    $totalParticipants = $group['total_participants'];

    // Get all participants in the group
    $participantsQuery = "SELECT * FROM participants WHERE group_id = ?";
    $participantsStmt = $db->prepare($participantsQuery);
    $participantsStmt->bind_param("i", $groupId);
    $participantsStmt->execute();
    $participantsResult = $participantsStmt->get_result();

    $participants = [];
    while ($row = $participantsResult->fetch_assoc()) {
        $participants[] = $row;
    }

    // Get payment history for each month
    $monthlyHistory = [];

    for ($month = 1; $month <= $currentMonth; $month++) {
        // Calculate month date based on start_month
        $startMonth = $group['start_month'];
        $startDate = date_create_from_format('F Y', $startMonth);
        if (!$startDate) {
            $startDate = date_create_from_format('M Y', $startMonth);
        }
        if (!$startDate) {
            // Fallback if parsing fails
            $startDate = new DateTime();
        }

        $monthDate = clone $startDate;
        $monthDate->modify('+' . ($month - 1) . ' months');
        $monthDateFormatted = $monthDate->format('F Y');

        // Get payments for this month with payment dates
        $paymentsQuery = "SELECT participant_id, payment_date FROM payments WHERE group_id = ? AND month = ?";
        $paymentsStmt = $db->prepare($paymentsQuery);
        $paymentsStmt->bind_param("ii", $groupId, $month);
        $paymentsStmt->execute();
        $paymentsResult = $paymentsStmt->get_result();

        $paymentDates = [];
        while ($row = $paymentsResult->fetch_assoc()) {
            $paymentDates[$row['participant_id']] = $row['payment_date'];
        }

        // Create participant list with payment status and payment date
        $participantsList = [];
        foreach ($participants as $participant) {
            // Check if the participant has paid for this month
            $hasPaid = isset($paymentDates[$participant['id']]);
            $paymentDate = $hasPaid ? $paymentDates[$participant['id']] : null;

            $participantsList[] = [
                'id' => $participant['id'],
                'name' => $participant['name'],
                'paid' => $hasPaid,
                'payment_date' => $paymentDate
            ];
        }

        $monthlyHistory[] = [
            'month' => $month,
            'date' => $monthDateFormatted,
            'participants' => $participantsList
        ];
    }

    return $monthlyHistory;
}

// Replace the getWinnerHistory function with this improved version
function getWinnerHistory($db, $groupId)
{
    // Note: Escaped 'groups' with backticks since it's a reserved keyword
    $winnerQuery = "SELECT w.*, p.name as winner_name, g.contribution_amount, g.total_participants, g.start_month 
                    FROM winners w 
                    JOIN participants p ON w.participant_id = p.id 
                    JOIN `groups` g ON w.group_id = g.id 
                    WHERE w.group_id = ? 
                    ORDER BY w.month ASC";

    $winnerStmt = $db->prepare($winnerQuery);
    $winnerStmt->bind_param("i", $groupId);
    $winnerStmt->execute();
    $winnerResult = $winnerStmt->get_result();

    $winnerHistory = [];

    while ($row = $winnerResult->fetch_assoc()) {
        // Calculate month date based on start_month
        $startMonth = $row['start_month'];
        $startDate = date_create_from_format('F Y', $startMonth);
        if (!$startDate) {
            $startDate = date_create_from_format('M Y', $startMonth);
        }
        if (!$startDate) {
            // Fallback if parsing fails
            $startDate = new DateTime();
        }

        $monthDate = clone $startDate;
        $monthDate->modify('+' . ($row['month'] - 1) . ' months');
        $monthDateFormatted = $monthDate->format('F Y');

        // Check if date_selected exists before using it
        $winningDate = isset($row['win_date']) ? date('d F Y', strtotime($row['win_date'])) : 'tidak tersedia';

        $winnerHistory[] = [
            'month' => (int)$row['month'],
            'date' => $monthDateFormatted,
            'winner' => $row['winner_name'],
            'participant_id' => (int)$row['participant_id'], // Add participant_id
            'winning_date' => $winningDate,
            'prize_amount' => (int)$row['contribution_amount'] * (int)$row['total_participants']
        ];
    }

    return $winnerHistory;
}

// Handle POST request to record a winner
function recordWinner($db, $groupId, $participantId, $month)
{
    // Start transaction
    $db->begin_transaction();
    
    try {
        // Check if a winner already exists for this month
        $checkQuery = "SELECT id FROM winners WHERE group_id = ? AND month = ?";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bind_param("ii", $groupId, $month);
        $checkStmt->execute();
        $checkResult = $checkStmt->get_result();

        if ($checkResult->num_rows > 0) {
            // Update existing winner
            $row = $checkResult->fetch_assoc();
            $winnerId = $row['id'];

            $updateQuery = "UPDATE winners SET participant_id = ?, date_selected = NOW() WHERE id = ?";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bind_param("ii", $participantId, $winnerId);
            $updateStmt->execute();
        } else {
            // Insert new winner
            $insertQuery = "INSERT INTO winners (group_id, participant_id, month, date_selected) VALUES (?, ?, ?, NOW())";
            $insertStmt = $db->prepare($insertQuery);
            $insertStmt->bind_param("iii", $groupId, $participantId, $month);
            $insertStmt->execute();
        }
        
        // Advance the group to the next month
        $nextMonth = $month + 1;
        $updateGroupQuery = "UPDATE `groups` SET current_month = ? WHERE id = ?";
        $updateGroupStmt = $db->prepare($updateGroupQuery);
        $updateGroupStmt->bind_param("ii", $nextMonth, $groupId);
        $updateGroupStmt->execute();
        
        // (REMOVED) No longer resetting payment_confirmed as it's dynamically calculated.
        
        // Commit transaction
        $db->commit();
        
        return true;
    } catch (Exception $e) {
        // Rollback transaction on error
        $db->rollback();
        error_log("Error recording winner: " . $e->getMessage());
        return false;
    }
}

// Handle POST request to advance to next month
function advanceToNextMonth($db, $groupId)
{
    // Note: Escaped 'groups' with backticks since it's a reserved keyword
    $updateQuery = "UPDATE `groups` SET current_month = current_month + 1 WHERE id = ?";
    $updateStmt = $db->prepare($updateQuery);
    $updateStmt->bind_param("i", $groupId);
    $success = $updateStmt->execute();

    return $success;
}

// Add this at the beginning of the main request handler section
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Handle GET request to fetch history data
    if (isset($_GET['group_id'])) {
        $groupId = (int)$_GET['group_id'];
        
        // Force refresh from database by getting the current month
        $groupQuery = "SELECT current_month FROM `groups` WHERE id = ?";
        $groupStmt = $db->prepare($groupQuery);
        $groupStmt->bind_param("i", $groupId);
        $groupStmt->execute();
        $groupResult = $groupStmt->get_result();
        $groupData = $groupResult->fetch_assoc();
        $currentMonth = $groupData ? (int)$groupData['current_month'] : 1;
        
        error_log("Current month for group $groupId: $currentMonth");
        
        // Get winner history
        $winnerHistory = getWinnerHistory($db, $groupId);
        error_log("Winner history count: " . count($winnerHistory));
        
        // Get payment history
        $paymentHistory = getPaymentHistory($db, $groupId);
        
        $response = [
            'payment_history' => $paymentHistory,
            'winner_history' => $winnerHistory,
            'current_month' => $currentMonth
        ];

        echo json_encode($response);
    } else {
        echo json_encode(['error' => 'Group ID is required']);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST requests for actions
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['action'])) {
        $groupId = $data['group_id'] ?? 0;

        if ($data['action'] === 'record_winner') {
            $participantId = $data['participant_id'] ?? 0;
            $month = $data['month'] ?? 0;

            $success = recordWinner($db, $groupId, $participantId, $month);
            echo json_encode(['success' => $success]);
        } elseif ($data['action'] === 'advance_month') {
            $success = advanceToNextMonth($db, $groupId);
            echo json_encode(['success' => $success]);
        } else {
            echo json_encode(['error' => 'Invalid action']);
        }
    } else {
        echo json_encode(['error' => 'Action is required']);
    }
} else {
    echo json_encode(['error' => 'Invalid request method']);
}
