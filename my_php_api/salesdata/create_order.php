<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include("../db.php"); // Database connection

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $data = json_decode(file_get_contents("php://input"), true);

    $paymentMethod = $conn->real_escape_string($data['paymentMethod'] ?? 'Cash');
    $voucher = $conn->real_escape_string($data['voucher'] ?? 'None');
    $total = (float)($data['total'] ?? 0);

    date_default_timezone_set('Asia/Manila');
    $orderName = "Customer Order";
    $orderDate = date("M j, Y");
    $orderTime = date("g:i A");

    // Insert into orders with voucher & total
    $stmt = $conn->prepare("INSERT INTO orders (order_name, order_date, order_time, payment_method, voucher, total) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssd", $orderName, $orderDate, $orderTime, $paymentMethod, $voucher, $total);

    if (!$stmt->execute()) {
        echo json_encode(["success" => false, "message" => "Failed to create order: ".$stmt->error]);
        exit;
    }

    $orderId = $stmt->insert_id;
    $stmt->close();
    $conn->close();

    echo json_encode([
        "success" => true,
        "message" => "Order created",
        "order_id" => $orderId
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
