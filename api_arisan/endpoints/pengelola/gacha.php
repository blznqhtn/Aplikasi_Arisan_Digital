<?php
// Add these lines at the very top of the file, before any other code
// This will suppress PHP warnings and notices from being output
error_reporting(0);
ini_set('display_errors', 0);

// Include database connection
require_once '../../config/config.php';

// Set response headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// Helper function to return errors
function returnError($message)
{
    echo json_encode([
        'error' => $message
    ]);
    exit;
}

// Function to check if the draw date has been set and if it's time to draw
function checkDrawDate($db, $groupId)
{
    $groupId = (int)$groupId;
    
    // Get current month from groups table
    $monthQuery = "SELECT current_month FROM `groups` WHERE id = ?";
    $monthStmt = $db->prepare($monthQuery);
    $monthStmt->bind_param("i", $groupId);
    $monthStmt->execute();
    $monthResult = $monthStmt->get_result();
    $monthData = $monthResult->fetch_assoc();
    $currentMonth = (int)$monthData['current_month'];
    
    // Check if draw date is set for the current month
    $query = "SELECT draw_date FROM draw_dates WHERE group_id = ? AND month = ?";
    
    $stmt = $db->prepare($query);
    $stmt->bind_param("ii", $groupId, $currentMonth);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $drawDate = new DateTime($row['draw_date']);
        $now = new DateTime();
        
        // Format the date for display
        $formattedDate = $drawDate->format('d M Y H:i');
        
        // Fix: Ensure proper timezone comparison and add debug info
        $drawDateTimestamp = $drawDate->getTimestamp();
        $nowTimestamp = $now->getTimestamp();
        $canDraw = ($nowTimestamp >= $drawDateTimestamp);
        
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
            'success' => false,
            'message' => 'Missing required fields'
        ];
    }
    
    $groupId = (int)$data['group_id'];
    $drawDate = $data['draw_date'];
    $currentMonth = (int)$data['current_month'];
    
    // Check if a draw date already exists for this month
    $checkQuery = "SELECT id FROM draw_dates WHERE group_id = ? AND month = ?";
    $stmt = $db->prepare($checkQuery);
    $stmt->bind_param("ii", $groupId, $currentMonth);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        // Update existing record
        $row = $result->fetch_assoc();
        $id = $row['id'];
        $stmt->close();
        
        $updateQuery = "UPDATE draw_dates SET draw_date = ? WHERE id = ?";
        $stmt = $db->prepare($updateQuery);
        $stmt->bind_param("si", $drawDate, $id);
        
        if ($stmt->execute()) {
            $stmt->close();
            return [
                'success' => true,
                'message' => 'Tanggal pengundian berhasil diperbarui'
            ];
        }
    } else {
        // Insert new record
        $stmt->close();
        
        $insertQuery = "INSERT INTO draw_dates (group_id, month, draw_date) VALUES (?, ?, ?)";
        $stmt = $db->prepare($insertQuery);
        $stmt->bind_param("iis", $groupId, $currentMonth, $drawDate);
        
        if ($stmt->execute()) {
            $stmt->close();
            return [
                'success' => true,
                'message' => 'Tanggal pengundian berhasil ditetapkan'
            ];
        }
    }
    
    $error = $stmt->error;
    $stmt->close();
    
    return [
        'success' => false,
        'message' => 'Error setting draw date: ' . $error
    ];
}

// Function to get eligible participants for the gacha
function getEligibleParticipants($db, $groupId, $currentMonth)
{
    // First check if the draw date has been set and reached
    $drawDateInfo = checkDrawDate($db, $groupId);
    
    // Include draw date info in the response
    $response = [
        'is_date_set' => $drawDateInfo['is_date_set'],
        'draw_date' => $drawDateInfo['draw_date'],
        'can_draw' => $drawDateInfo['can_draw']
    ];
    
    // Get group information to check if arisan is completed
    $groupQuery = "SELECT total_participants, is_completed FROM `groups` WHERE id = ?";
    $groupStmt = $db->prepare($groupQuery);
    $groupStmt->bind_param("i", $groupId);
    $groupStmt->execute();
    $groupResult = $groupStmt->get_result();
    $groupData = $groupResult->fetch_assoc();
    
    // Check if arisan is marked as completed in the database
    if ($groupData && (bool)$groupData['is_completed']) {
        return array_merge($response, [
            'participants' => [],
            'prize_amount' => 0,
            'is_completed' => true,
            'message' => 'Arisan Selesai'
        ]);
    }

    // Count existing winners
    $winnerCountQuery = "SELECT COUNT(*) as winner_count FROM winners WHERE group_id = ?";
    $winnerCountStmt = $db->prepare($winnerCountQuery);
    $winnerCountStmt->bind_param("i", $groupId);
    $winnerCountStmt->execute();
    $winnerCountResult = $winnerCountStmt->get_result();
    $winnerCountData = $winnerCountResult->fetch_assoc();
    $winnerCount = (int)$winnerCountData['winner_count'];

    // Check if arisan is completed (all participants have won)
    $totalParticipants = (int)$groupData['total_participants'];
    $isCompleted = ($winnerCount >= $totalParticipants);

    if ($isCompleted) {
        // Update the group to mark it as completed
        $updateQuery = "UPDATE `groups` SET is_completed = 1 WHERE id = ?";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bind_param("i", $groupId);
        $updateStmt->execute();
        
        return array_merge($response, [
            'participants' => [],
            'prize_amount' => 0,
            'is_completed' => true,
            'message' => 'Arisan Selesai'
        ]);
    }

    // Get participants who have paid for the current month
    // Exclude participants who have already won in previous months
    $query = "SELECT p.id, p.name, 1 as payment_confirmed 
              FROM participants p
              JOIN payments pm ON p.id = pm.participant_id
              WHERE p.group_id = ? AND pm.month = ?
              AND p.id NOT IN (
                  SELECT participant_id FROM winners WHERE group_id = ?
              )
              ORDER BY p.name ASC";

    $stmt = $db->prepare($query);
    $stmt->bind_param("iii", $groupId, $currentMonth, $groupId);
    $stmt->execute();
    $result = $stmt->get_result();

    $participants = [];
    while ($row = $result->fetch_assoc()) {
        // Convert to appropriate types
        $row['id'] = (int)$row['id'];
        $row['payment_confirmed'] = (bool)$row['payment_confirmed'];
        $row['paid'] = true; // For compatibility with the Flutter app

        $participants[] = $row;
    }

    // Get group information for prize amount calculation
    $groupQuery = "SELECT contribution_amount, total_participants FROM `groups` WHERE id = ?";
    $groupStmt = $db->prepare($groupQuery);
    $groupStmt->bind_param("i", $groupId);
    $groupStmt->execute();
    $groupResult = $groupStmt->get_result();
    $groupData = $groupResult->fetch_assoc();

    $prizeAmount = 0;
    if ($groupData) {
        $prizeAmount = (int)$groupData['contribution_amount'] * (int)$groupData['total_participants'];
    }

    return array_merge($response, [
        'participants' => $participants,
        'prize_amount' => $prizeAmount,
        'is_completed' => false
    ]);
}

// Function to record a winner and advance to the next month
function recordWinnerAndAdvanceMonth($db, $groupId, $participantId, $currentMonth)
{
    // First check if the draw date has been set and reached
    $drawDateInfo = checkDrawDate($db, $groupId);
    
    if (!$drawDateInfo['is_date_set']) {
        return [
            'success' => false,
            'message' => 'Tanggal pengundian belum ditetapkan'
        ];
    }
    
    if (!$drawDateInfo['can_draw']) {
        return [
            'success' => false,
            'message' => 'Belum waktunya pengundian. Pengundian dijadwalkan pada ' . $drawDateInfo['draw_date']
        ];
    }
    
    // Start transaction
    $db->begin_transaction();

    try {
        // 1. Record the winner for the current month
        $checkQuery = "SELECT id FROM winners WHERE group_id = ? AND month = ?";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bind_param("ii", $groupId, $currentMonth);
        $checkStmt->execute();
        $checkResult = $checkStmt->get_result();

        if ($checkResult->num_rows > 0) {
            // Update existing winner
            $row = $checkResult->fetch_assoc();
            $winnerId = $row['id'];

            $updateQuery = "UPDATE winners SET participant_id = ?, win_date = NOW() WHERE id = ?";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bind_param("ii", $participantId, $winnerId);
            $updateStmt->execute();
        } else {
            // Insert new winner
            $insertQuery = "INSERT INTO winners (group_id, participant_id, month, win_date) VALUES (?, ?, ?, NOW())";
            $insertStmt = $db->prepare($insertQuery);
            $insertStmt->bind_param("iii", $groupId, $participantId, $currentMonth);
            $insertStmt->execute();
        }

        // 2. Check if all participants have won
        $totalParticipantsQuery = "SELECT total_participants FROM `groups` WHERE id = ?";
        $totalParticipantsStmt = $db->prepare($totalParticipantsQuery);
        $totalParticipantsStmt->bind_param("i", $groupId);
        $totalParticipantsStmt->execute();
        $totalParticipantsResult = $totalParticipantsStmt->get_result();
        $totalParticipantsData = $totalParticipantsResult->fetch_assoc();
        $totalParticipants = (int)$totalParticipantsData['total_participants'];

        // Count winners including the one we just added
        $winnerCountQuery = "SELECT COUNT(*) as winner_count FROM winners WHERE group_id = ?";
        $winnerCountStmt = $db->prepare($winnerCountQuery);
        $winnerCountStmt->bind_param("i", $groupId);
        $winnerCountStmt->execute();
        $winnerCountResult = $winnerCountStmt->get_result();
        $winnerCountData = $winnerCountResult->fetch_assoc();
        $winnerCount = (int)$winnerCountData['winner_count'];

        // Check if arisan is completed
        $isCompleted = ($winnerCount >= $totalParticipants);

        if ($isCompleted) {
            // Mark the arisan as completed
            $updateCompletedQuery = "UPDATE `groups` SET is_completed = 1 WHERE id = ?";
            $updateCompletedStmt = $db->prepare($updateCompletedQuery);
            $updateCompletedStmt->bind_param("i", $groupId);
            $updateCompletedStmt->execute();
        }

        // 3. Advance the group to the next month only if not completed
        $nextMonth = $currentMonth + 1;
        $updateGroupQuery = "UPDATE `groups` SET current_month = ? WHERE id = ?";
        $updateGroupStmt = $db->prepare($updateGroupQuery);
        $updateGroupStmt->bind_param("ii", $nextMonth, $groupId);
        $updateGroupStmt->execute();

        // 4. (REMOVED) No longer resetting payment_confirmed as it's dynamically calculated.

        // Commit transaction
        $db->commit();

        return [
            'success' => true,
            'message' => $isCompleted ? 'Pemenang terakhir berhasil dicatat. Arisan Selesai!' : 'Pemenang berhasil dicatat dan bulan diperbarui',
            'next_month' => $nextMonth,
            'is_completed' => $isCompleted
        ];
    } catch (Exception $e) {
        // Rollback transaction on error
        $db->rollback();

        return [
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ];
    }
}

// Function to check if arisan is completed
function checkArisanStatus($db, $groupId)
{
    // Get total participants
    $totalParticipantsQuery = "SELECT total_participants, is_completed FROM `groups` WHERE id = ?";
    $totalParticipantsStmt = $db->prepare($totalParticipantsQuery);
    $totalParticipantsStmt->bind_param("i", $groupId);
    $totalParticipantsStmt->execute();
    $totalParticipantsResult = $totalParticipantsStmt->get_result();
    $totalParticipantsData = $totalParticipantsResult->fetch_assoc();
    
    // If is_completed is already set in the database, return that
    if ((bool)$totalParticipantsData['is_completed']) {
        return [
            'is_completed' => true,
            'total_participants' => (int)$totalParticipantsData['total_participants'],
            'winner_count' => (int)$totalParticipantsData['total_participants']
        ];
    }
    
    $totalParticipants = (int)$totalParticipantsData['total_participants'];

    // Count winners
    $winnerCountQuery = "SELECT COUNT(*) as winner_count FROM winners WHERE group_id = ?";
    $winnerCountStmt = $db->prepare($winnerCountQuery);
    $winnerCountStmt->bind_param("i", $groupId);
    $winnerCountStmt->execute();
    $winnerCountResult = $winnerCountStmt->get_result();
    $winnerCountData = $winnerCountResult->fetch_assoc();
    $winnerCount = (int)$winnerCountData['winner_count'];
    
    $isCompleted = ($winnerCount >= $totalParticipants);
    
    // If we detect it's completed but the database doesn't reflect that, update it
    if ($isCompleted && !(bool)$totalParticipantsData['is_completed']) {
        $updateQuery = "UPDATE `groups` SET is_completed = 1 WHERE id = ?";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bind_param("i", $groupId);
        $updateStmt->execute();
    }

    return [
        'is_completed' => $isCompleted,
        'total_participants' => $totalParticipants,
        'winner_count' => $winnerCount
    ];
}

// Main execution
try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Check if this is a request to check the draw date
        if (isset($_GET['check_draw_date']) && isset($_GET['group_id'])) {
            $groupId = (int)$_GET['group_id'];
            echo json_encode(checkDrawDate($db, $groupId));
            exit;
        }
        
        // Handle GET request to fetch eligible participants
        if (isset($_GET['group_id']) && isset($_GET['current_month'])) {
            $groupId = (int)$_GET['group_id'];
            $currentMonth = (int)$_GET['current_month'];

            // Check if arisan is completed first
            $statusCheck = checkArisanStatus($db, $groupId);
            if ($statusCheck['is_completed']) {
                echo json_encode([
                    'participants' => [],
                    'prize_amount' => 0,
                    'is_completed' => true,
                    'message' => 'Arisan Selesai'
                ]);
            } else {
                $response = getEligibleParticipants($db, $groupId, $currentMonth);
                echo json_encode($response);
            }
        } else {
            returnError('Group ID and current month are required');
        }
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Handle POST requests for recording a winner
        $data = json_decode(file_get_contents('php://input'), true);

        if (isset($data['action']) && $data['action'] === 'record_winner') {
            if (isset($data['group_id']) && isset($data['participant_id']) && isset($data['current_month'])) {
                $groupId = (int)$data['group_id'];
                $participantId = (int)$data['participant_id'];
                $currentMonth = (int)$data['current_month'];

                $result = recordWinnerAndAdvanceMonth($db, $groupId, $participantId, $currentMonth);
                echo json_encode($result);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'Missing required fields'
                ]);
            }
        } elseif (isset($data['action']) && $data['action'] === 'check_status') {
            if (isset($data['group_id'])) {
                $groupId = (int)$data['group_id'];
                $result = checkArisanStatus($db, $groupId);
                echo json_encode($result);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'Group ID is required'
                ]);
            }
        } elseif (isset($data['action']) && $data['action'] === 'set_draw_date') {
            if (isset($data['group_id']) && isset($data['draw_date']) && isset($data['current_month'])) {
                $result = setDrawDate($db, $data);
                echo json_encode($result);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'Missing required fields for setting draw date'
                ]);
            }
        } else {
            returnError('Invalid action');
        }
    } else {
        returnError('Invalid request method');
    }
} catch (Exception $e) {
    returnError('Server error: ' . $e->getMessage());
}
