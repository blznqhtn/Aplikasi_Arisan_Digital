-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 05, 2025 at 02:02 PM
-- Server version: 8.0.30
-- PHP Version: 8.3.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dbarisan`
--

-- --------------------------------------------------------

--
-- Table structure for table `draw_dates`
--

CREATE TABLE `draw_dates` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `month` int NOT NULL,
  `draw_date` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `draw_dates`
--

INSERT INTO `draw_dates` (`id`, `group_id`, `month`, `draw_date`, `created_at`) VALUES
(10, 21, 1, '2025-05-16 19:50:00', '2025-05-16 12:50:37'),
(11, 21, 2, '2025-05-18 12:44:00', '2025-05-18 05:44:31'),
(12, 21, 3, '2025-05-18 12:59:00', '2025-05-18 05:59:23'),
(13, 22, 1, '2025-05-19 11:30:00', '2025-05-19 04:30:25'),
(14, 23, 1, '2025-05-19 21:43:00', '2025-05-19 14:43:12'),
(15, 24, 1, '2025-05-20 18:51:00', '2025-05-20 11:51:54'),
(16, 25, 1, '2025-05-20 22:06:00', '2025-05-20 15:06:24'),
(17, 25, 2, '2025-05-20 22:09:00', '2025-05-20 15:09:06'),
(18, 26, 1, '2025-06-17 19:57:00', '2025-06-17 12:57:50'),
(19, 27, 1, '2025-07-24 14:22:00', '2025-07-24 07:22:48');

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE `groups` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `group_name` varchar(255) NOT NULL,
  `contribution_amount` int NOT NULL,
  `start_month` varchar(100) NOT NULL,
  `total_participants` int NOT NULL,
  `current_month` int NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_completed` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `user_id`, `group_name`, `contribution_amount`, `start_month`, `total_participants`, `current_month`, `created_at`, `is_completed`) VALUES
(21, 1, 'keluarga 1', 200000, 'May 2025', 3, 4, '2025-05-16 12:49:43', 1),
(22, 1, 'keluarga 2', 40000, 'May 2025', 3, 2, '2025-05-19 04:28:46', 0),
(23, 1, 'grup 1', 20000, 'May 2025', 3, 2, '2025-05-19 14:42:09', 0),
(24, 1, 'arisan1', 20000, 'May 2025', 3, 2, '2025-05-20 11:51:04', 0),
(25, 1, 'grup2', 200000, 'May 2025', 3, 3, '2025-05-20 15:05:32', 0),
(26, 1, 'grup 3', 50000, 'June 2025', 3, 2, '2025-06-17 12:56:48', 0),
(27, 2, 'mmmm', 40000, 'July 2025', 3, 2, '2025-07-24 07:21:25', 0);

-- --------------------------------------------------------

--
-- Table structure for table `participants`
--

CREATE TABLE `participants` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `password` varchar(255) NOT NULL,
  `payment_confirmed` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `participants`
--

INSERT INTO `participants` (`id`, `group_id`, `name`, `created_at`, `password`, `payment_confirmed`) VALUES
(3, 2, 'juna', '2025-05-10 11:36:08', 'juna123', 0),
(6, 3, 'qahtani', '2025-05-10 11:52:35', 'zxcvbn', 1),
(7, 3, 'bilzan', '2025-05-10 12:21:08', 'asdfgh', 1),
(8, 3, 'achmad', '2025-05-10 12:21:25', 'qwerty', 1),
(9, 4, 'cr7', '2025-05-10 13:43:56', 'goat1', 0),
(10, 4, 'lm2', '2025-05-10 13:44:05', 'pessi', 0),
(11, 4, 'antony', '2025-05-10 13:44:18', 'realgoat', 0),
(12, 5, 'vario', '2025-05-11 07:37:39', 'gacor123', 0),
(13, 5, 'soulgt', '2025-05-11 07:37:51', 'soul123', 0),
(14, 5, 'aerox', '2025-05-11 07:38:05', 'aerox123', 0),
(15, 5, 'nmax', '2025-05-11 07:38:40', 'nmax123', 0),
(16, 5, 'pcx', '2025-05-11 07:38:57', 'pcx123', 0),
(17, 6, 'raffi ahmad', '2025-05-11 07:51:29', 'sultanandara', 0),
(18, 6, 'bilzan', '2025-05-11 07:51:50', 'sultanpesona', 0),
(19, 6, 'antony', '2025-05-11 07:52:12', 'realgoat', 0),
(20, 7, 'agus', '2025-05-12 07:13:28', '22222222', 0),
(21, 7, 'kobokan', '2025-05-12 07:13:40', '11111111', 0),
(22, 7, 'lokdon', '2025-05-12 07:13:54', '4444444444', 0),
(23, 8, 'local', '2025-05-13 03:21:03', 'oijifjai', 0),
(24, 8, 'ijooo', '2025-05-13 03:21:19', 'uahduifhu', 0),
(25, 8, 'kotak', '2025-05-13 03:21:30', 'iuheuhw', 0),
(26, 9, '123456', '2025-05-13 23:56:33', 'qwerty', 0),
(27, 9, '789123', '2025-05-13 23:56:58', 'asdfgh', 0),
(28, 9, '456789', '2025-05-13 23:57:35', 'zxcvbn', 0),
(31, 10, 'rehanewok', '2025-05-14 00:55:01', 'idhuahf', 0),
(32, 10, 'ewok2100', '2025-05-14 00:55:34', 'aiosjdfj', 0),
(33, 10, 'local', '2025-05-14 00:55:50', 'uihguhher', 0),
(34, 11, 'whfuoawfhha', '2025-05-14 03:58:50', 'ajkhffj', 0),
(35, 11, 'kwfj', '2025-05-14 03:58:59', 'bfjkwaj', 0),
(36, 11, 'wjfjkaw', '2025-05-14 03:59:07', 'ajwkfjwk', 0),
(37, 13, 'akuu', '2025-05-14 06:33:51', 'udhuihuf', 0),
(38, 13, 'kamuu', '2025-05-14 06:34:06', 'kjbdfjkah', 0),
(39, 13, 'diaa', '2025-05-14 06:34:16', 'iodhffioahf', 0),
(40, 14, 'adit', '2025-05-15 01:51:45', 'adit123', 0),
(41, 14, 'denis', '2025-05-15 01:52:05', 'denis123', 0),
(42, 14, 'jarwo', '2025-05-15 01:52:18', 'jarwo123', 0),
(43, 15, 'lkasjk', '2025-05-15 15:57:41', 'akjsna', 0),
(44, 15, 'lkaoia', '2025-05-15 15:57:48', 'kado', 0),
(45, 16, 'bilzan', '2025-05-16 05:50:11', 'achmad', 1),
(46, 16, 'qahtani', '2025-05-16 05:50:25', 'al', 1),
(47, 16, 'achmad', '2025-05-16 05:50:42', 'qahtani', 1),
(48, 17, 'iodhiah', '2025-05-16 06:34:37', 'ajdhff', 1),
(49, 17, 'kjshdf', '2025-05-16 06:34:44', 'iidhfa', 1),
(50, 17, 'ashdfiao', '2025-05-16 06:34:52', 'ahfia', 1),
(51, 18, 'min', '2025-05-16 07:18:50', 'admin', 1),
(52, 18, 'adm', '2025-05-16 07:19:06', 'minad', 1),
(53, 18, 'local', '2025-05-16 07:19:47', 'local', 1),
(54, 18, 'tambah', '2025-05-16 07:20:00', 'tambah', 1),
(55, 19, 'admin', '2025-05-16 07:33:52', 'pw', 0),
(56, 19, 'p1', '2025-05-16 07:34:07', 'pw123', 0),
(57, 19, 'p2', '2025-05-16 07:34:19', 'pw456', 0),
(58, 20, 'bilzan', '2025-05-16 12:18:04', 'akubilzan', 0),
(59, 20, 'bilzan1', '2025-05-16 12:20:09', 'akubilzan1', 0),
(60, 20, 'bilzan', '2025-05-16 12:20:20', 'akubilzan2', 0),
(61, 21, 'bilzan', '2025-05-16 12:49:58', 'bilzan123', 0),
(62, 21, 'linda', '2025-05-16 12:50:15', 'linda123', 0),
(63, 21, 'trisno', '2025-05-16 12:50:27', 'trisno123', 0),
(64, 22, 'aliya', '2025-05-19 04:29:03', 'aliya123', 0),
(65, 22, 'zahra', '2025-05-19 04:29:26', 'zahra123', 0),
(66, 22, 'ikhsan', '2025-05-19 04:30:07', 'ikhsan123', 0),
(67, 23, 'peserta1', '2025-05-19 14:42:27', 'peserta1123', 0),
(68, 23, 'peserta2', '2025-05-19 14:42:41', 'peserta2123', 0),
(69, 23, 'peserta3', '2025-05-19 14:42:57', 'peserta3123', 0),
(70, 24, 'tika', '2025-05-20 11:51:19', 'tika123', 0),
(71, 24, 'reka', '2025-05-20 11:51:31', 'reka123', 0),
(72, 24, 'arka', '2025-05-20 11:51:40', 'arka123', 0),
(73, 25, 'jika', '2025-05-20 15:05:49', 'jika123', 0),
(74, 25, 'lokal', '2025-05-20 15:06:03', 'lokalp', 0),
(75, 25, 'polisi', '2025-05-20 15:06:13', 'polisi', 0),
(76, 26, 'admin', '2025-06-17 12:57:02', 'admin123', 0),
(77, 26, 'user', '2025-06-17 12:57:20', 'user123', 0),
(78, 26, 'local', '2025-06-17 12:57:36', 'local123', 0),
(79, 27, '111', '2025-07-24 07:21:55', '111', 0),
(80, 27, '222', '2025-07-24 07:22:23', '222', 0),
(81, 27, '333', '2025-07-24 07:22:43', '333', 0);

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `participant_id` int NOT NULL,
  `month` int NOT NULL,
  `amount` int NOT NULL,
  `payment_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_status` varchar(20) DEFAULT 'completed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `group_id`, `participant_id`, `month`, `amount`, `payment_date`, `payment_status`) VALUES
(1, 3, 6, 1, 1000, '2025-05-10 12:24:27', 'completed'),
(2, 3, 7, 1, 1000, '2025-05-10 12:38:36', 'completed'),
(3, 3, 8, 1, 1000, '2025-05-10 12:38:38', 'completed'),
(4, 4, 9, 1, 20000, '2025-05-10 13:44:26', 'completed'),
(5, 4, 10, 1, 20000, '2025-05-10 13:44:29', 'completed'),
(6, 4, 11, 1, 20000, '2025-05-10 13:44:33', 'completed'),
(7, 4, 9, 2, 20000, '2025-05-10 13:45:45', 'completed'),
(8, 4, 10, 2, 20000, '2025-05-10 13:45:48', 'completed'),
(9, 4, 11, 2, 20000, '2025-05-10 13:45:50', 'completed'),
(10, 4, 9, 3, 20000, '2025-05-11 07:14:22', 'completed'),
(11, 4, 10, 3, 20000, '2025-05-11 07:14:25', 'completed'),
(12, 4, 11, 3, 20000, '2025-05-11 07:14:27', 'completed'),
(13, 5, 12, 1, 5000, '2025-05-11 07:39:12', 'completed'),
(14, 5, 13, 1, 5000, '2025-05-11 07:39:14', 'completed'),
(15, 5, 14, 1, 5000, '2025-05-11 07:39:17', 'completed'),
(16, 5, 15, 1, 5000, '2025-05-11 07:39:19', 'completed'),
(17, 5, 16, 1, 5000, '2025-05-11 07:39:22', 'completed'),
(18, 5, 12, 2, 5000, '2025-05-11 07:41:03', 'completed'),
(19, 5, 13, 2, 5000, '2025-05-11 07:41:06', 'completed'),
(20, 5, 14, 2, 5000, '2025-05-11 07:41:08', 'completed'),
(21, 5, 15, 2, 5000, '2025-05-11 07:41:11', 'completed'),
(22, 5, 16, 2, 5000, '2025-05-11 07:41:13', 'completed'),
(23, 6, 17, 1, 2500000, '2025-05-11 07:55:28', 'completed'),
(24, 6, 18, 1, 2500000, '2025-05-11 07:55:36', 'completed'),
(25, 6, 19, 1, 2500000, '2025-05-11 07:55:38', 'completed'),
(26, 6, 17, 2, 2500000, '2025-05-11 07:56:12', 'completed'),
(27, 6, 18, 2, 2500000, '2025-05-11 07:56:15', 'completed'),
(28, 6, 19, 2, 2500000, '2025-05-11 07:56:18', 'completed'),
(29, 7, 20, 1, 20000, '2025-05-12 07:13:59', 'completed'),
(30, 7, 21, 1, 20000, '2025-05-12 07:14:01', 'completed'),
(31, 7, 22, 1, 20000, '2025-05-12 07:14:04', 'completed'),
(32, 7, 20, 2, 20000, '2025-05-12 07:14:55', 'completed'),
(33, 7, 21, 2, 20000, '2025-05-12 07:14:57', 'completed'),
(34, 7, 22, 2, 20000, '2025-05-12 07:15:00', 'completed'),
(35, 7, 20, 3, 20000, '2025-05-12 07:18:05', 'completed'),
(36, 7, 21, 3, 20000, '2025-05-12 07:18:09', 'completed'),
(37, 7, 22, 3, 20000, '2025-05-12 07:18:11', 'completed'),
(38, 8, 23, 1, 100000, '2025-05-13 03:21:36', 'completed'),
(39, 8, 24, 1, 100000, '2025-05-13 03:21:39', 'completed'),
(40, 8, 25, 1, 100000, '2025-05-13 03:21:41', 'completed'),
(41, 8, 23, 2, 100000, '2025-05-13 03:53:47', 'completed'),
(42, 8, 24, 2, 100000, '2025-05-13 03:53:51', 'completed'),
(43, 8, 25, 2, 100000, '2025-05-13 03:53:53', 'completed'),
(44, 8, 23, 3, 100000, '2025-05-13 03:56:55', 'completed'),
(45, 8, 24, 3, 100000, '2025-05-13 03:56:57', 'completed'),
(46, 8, 25, 3, 100000, '2025-05-13 03:57:00', 'completed'),
(47, 9, 26, 1, 10000000, '2025-05-13 23:57:43', 'completed'),
(48, 9, 27, 1, 10000000, '2025-05-13 23:57:46', 'completed'),
(49, 9, 28, 1, 10000000, '2025-05-13 23:57:50', 'completed'),
(50, 9, 26, 2, 10000000, '2025-05-13 23:58:56', 'completed'),
(51, 9, 27, 2, 10000000, '2025-05-13 23:59:00', 'completed'),
(52, 9, 28, 2, 10000000, '2025-05-13 23:59:02', 'completed'),
(53, 10, 29, 1, 20000, '2025-05-14 00:56:39', 'completed'),
(54, 10, 30, 1, 20000, '2025-05-14 00:56:42', 'completed'),
(55, 10, 31, 1, 20000, '2025-05-14 00:56:44', 'completed'),
(56, 10, 32, 1, 20000, '2025-05-14 00:56:47', 'completed'),
(57, 10, 33, 1, 20000, '2025-05-14 00:56:49', 'completed'),
(58, 10, 29, 2, 20000, '2025-05-14 00:57:45', 'completed'),
(59, 10, 30, 2, 20000, '2025-05-14 01:08:54', 'completed'),
(60, 10, 31, 2, 20000, '2025-05-14 01:09:04', 'completed'),
(61, 10, 32, 2, 20000, '2025-05-14 01:09:06', 'completed'),
(62, 10, 33, 2, 20000, '2025-05-14 01:09:08', 'completed'),
(63, 10, 31, 3, 20000, '2025-05-14 03:57:54', 'completed'),
(64, 10, 32, 3, 20000, '2025-05-14 03:57:56', 'completed'),
(65, 10, 33, 3, 20000, '2025-05-14 03:57:59', 'completed'),
(66, 11, 34, 1, 10000000, '2025-05-14 04:11:33', 'completed'),
(67, 11, 35, 1, 10000000, '2025-05-14 04:11:38', 'completed'),
(68, 11, 36, 1, 10000000, '2025-05-14 04:11:40', 'completed'),
(69, 11, 36, 2, 10000000, '2025-05-14 04:13:56', 'completed'),
(70, 11, 35, 2, 10000000, '2025-05-14 04:13:59', 'completed'),
(71, 11, 34, 2, 10000000, '2025-05-14 04:14:02', 'completed'),
(72, 11, 34, 3, 10000000, '2025-05-14 04:14:32', 'completed'),
(73, 11, 35, 3, 10000000, '2025-05-14 04:14:34', 'completed'),
(74, 11, 36, 3, 10000000, '2025-05-14 04:14:37', 'completed'),
(75, 13, 37, 1, 20000, '2025-05-14 08:05:57', 'completed'),
(76, 13, 38, 1, 20000, '2025-05-14 08:06:00', 'completed'),
(77, 13, 39, 1, 20000, '2025-05-14 08:06:02', 'completed'),
(78, 14, 40, 1, 95000, '2025-05-15 06:40:17', 'completed'),
(79, 14, 41, 1, 95000, '2025-05-15 06:40:25', 'completed'),
(80, 14, 42, 1, 95000, '2025-05-15 06:40:27', 'completed'),
(81, 14, 40, 2, 95000, '2025-05-15 07:22:15', 'completed'),
(82, 14, 41, 2, 95000, '2025-05-15 07:22:18', 'completed'),
(83, 14, 42, 2, 95000, '2025-05-15 07:22:20', 'completed'),
(84, 14, 40, 3, 95000, '2025-05-15 07:39:09', 'completed'),
(85, 14, 41, 3, 95000, '2025-05-15 07:39:12', 'completed'),
(86, 14, 42, 3, 95000, '2025-05-15 07:39:14', 'completed'),
(87, 13, 37, 2, 20000, '2025-05-15 15:23:15', 'completed'),
(88, 13, 38, 2, 20000, '2025-05-15 15:23:18', 'completed'),
(89, 13, 39, 2, 20000, '2025-05-15 15:23:20', 'completed'),
(90, 13, 37, 3, 20000, '2025-05-15 15:34:36', 'completed'),
(91, 13, 38, 3, 20000, '2025-05-15 15:34:39', 'completed'),
(92, 13, 39, 3, 20000, '2025-05-15 15:34:41', 'completed'),
(93, 15, 43, 1, 20000, '2025-05-15 15:57:53', 'completed'),
(94, 15, 44, 1, 20000, '2025-05-15 15:57:56', 'completed'),
(95, 15, 43, 2, 20000, '2025-05-16 01:48:34', 'completed'),
(96, 15, 44, 2, 20000, '2025-05-16 01:48:37', 'completed'),
(97, 16, 45, 1, 20000, '2025-05-16 05:50:47', 'completed'),
(98, 16, 46, 1, 20000, '2025-05-16 05:50:49', 'completed'),
(99, 16, 47, 1, 20000, '2025-05-16 05:50:52', 'completed'),
(100, 17, 48, 1, 10000, '2025-05-16 06:34:55', 'completed'),
(101, 17, 49, 1, 10000, '2025-05-16 06:34:58', 'completed'),
(102, 17, 50, 1, 10000, '2025-05-16 06:35:01', 'completed'),
(103, 17, 48, 2, 10000, '2025-05-16 06:46:52', 'completed'),
(104, 17, 49, 2, 10000, '2025-05-16 06:46:55', 'completed'),
(105, 17, 50, 2, 10000, '2025-05-16 06:46:57', 'completed'),
(106, 18, 51, 1, 100000, '2025-05-16 07:33:00', 'completed'),
(107, 18, 52, 1, 100000, '2025-05-16 07:33:04', 'completed'),
(108, 18, 53, 1, 100000, '2025-05-16 07:33:07', 'completed'),
(109, 18, 54, 1, 100000, '2025-05-16 07:33:09', 'completed'),
(110, 19, 55, 1, 100000, '2025-05-16 07:42:24', 'completed'),
(111, 19, 56, 1, 100000, '2025-05-16 07:42:27', 'completed'),
(112, 19, 57, 1, 100000, '2025-05-16 07:42:29', 'completed'),
(113, 19, 55, 2, 100000, '2025-05-16 08:29:12', 'completed'),
(114, 19, 56, 2, 100000, '2025-05-16 08:29:16', 'completed'),
(115, 19, 57, 2, 100000, '2025-05-16 08:29:18', 'completed'),
(116, 19, 55, 3, 100000, '2025-05-16 11:52:21', 'completed'),
(117, 19, 56, 3, 100000, '2025-05-16 11:52:24', 'completed'),
(118, 19, 57, 3, 100000, '2025-05-16 11:52:27', 'completed'),
(119, 20, 58, 1, 15000, '2025-05-16 12:20:38', 'completed'),
(120, 20, 59, 1, 15000, '2025-05-16 12:20:41', 'completed'),
(121, 20, 60, 1, 15000, '2025-05-16 12:20:43', 'completed'),
(122, 20, 58, 2, 15000, '2025-05-16 12:24:33', 'completed'),
(123, 20, 59, 2, 15000, '2025-05-16 12:24:35', 'completed'),
(124, 20, 60, 2, 15000, '2025-05-16 12:24:38', 'completed'),
(125, 21, 61, 1, 200000, '2025-05-16 12:50:40', 'completed'),
(126, 21, 62, 1, 200000, '2025-05-16 12:50:43', 'completed'),
(127, 21, 63, 1, 200000, '2025-05-16 12:50:45', 'completed'),
(128, 21, 61, 2, 200000, '2025-05-18 05:51:06', 'completed'),
(129, 21, 62, 2, 200000, '2025-05-18 05:51:19', 'completed'),
(130, 21, 63, 2, 200000, '2025-05-18 05:51:21', 'completed'),
(131, 21, 61, 3, 200000, '2025-05-18 05:59:26', 'completed'),
(132, 21, 62, 3, 200000, '2025-05-18 05:59:28', 'completed'),
(133, 21, 63, 3, 200000, '2025-05-18 05:59:36', 'completed'),
(134, 22, 64, 1, 40000, '2025-05-19 04:30:30', 'completed'),
(135, 22, 65, 1, 40000, '2025-05-19 04:30:32', 'completed'),
(136, 22, 66, 1, 40000, '2025-05-19 04:30:37', 'completed'),
(137, 23, 67, 1, 20000, '2025-05-19 14:43:20', 'completed'),
(138, 23, 68, 1, 20000, '2025-05-19 14:43:23', 'completed'),
(139, 23, 69, 1, 20000, '2025-05-19 14:43:25', 'completed'),
(140, 24, 70, 1, 20000, '2025-05-20 11:51:58', 'completed'),
(141, 24, 71, 1, 20000, '2025-05-20 11:52:00', 'completed'),
(142, 24, 72, 1, 20000, '2025-05-20 11:52:02', 'completed'),
(143, 25, 73, 1, 200000, '2025-05-20 15:06:28', 'completed'),
(144, 25, 74, 1, 200000, '2025-05-20 15:06:31', 'completed'),
(145, 25, 75, 1, 200000, '2025-05-20 15:06:33', 'completed'),
(146, 25, 73, 2, 200000, '2025-05-20 15:09:09', 'completed'),
(147, 25, 74, 2, 200000, '2025-05-20 15:09:18', 'completed'),
(148, 25, 75, 2, 200000, '2025-05-20 15:09:20', 'completed'),
(149, 26, 76, 1, 50000, '2025-06-17 12:57:59', 'completed'),
(150, 26, 77, 1, 50000, '2025-06-17 12:58:03', 'completed'),
(151, 26, 78, 1, 50000, '2025-06-17 12:58:05', 'completed'),
(152, 27, 79, 1, 40000, '2025-07-24 07:22:59', 'completed'),
(153, 27, 80, 1, 40000, '2025-07-24 07:23:01', 'completed'),
(154, 27, 81, 1, 40000, '2025-07-24 07:23:04', 'completed');

-- --------------------------------------------------------

--
-- Table structure for table `pengelola`
--

CREATE TABLE `pengelola` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `pengelola`
--

INSERT INTO `pengelola` (`id`, `username`, `email`, `password`, `created_at`) VALUES
(1, 'bilzan', 'bilzan@gmail.com', '$2y$10$xpAT4zarwmIdqX7nDuCgt.QpEEFTpXEFTzL2tI7oD0tkbDmCUwJzm', '2025-05-09 07:20:03'),
(2, 'admin111', 'a@gmail.com', '$2y$10$JzK8lJgRsuNbExrrZiRVve4cYi/5x4u63FKYYpRIrTxzcT.wxZp22', '2025-07-24 07:20:35');

-- --------------------------------------------------------

--
-- Table structure for table `winners`
--

CREATE TABLE `winners` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `participant_id` int NOT NULL,
  `month` int NOT NULL,
  `win_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `winners`
--

INSERT INTO `winners` (`id`, `group_id`, `participant_id`, `month`, `win_date`) VALUES
(1, 3, 8, 1, '2025-05-10 13:14:53'),
(2, 4, 10, 1, '2025-05-10 13:46:27'),
(3, 4, 9, 2, '2025-05-11 07:14:38'),
(4, 5, 13, 1, '2025-05-11 07:41:38'),
(5, 6, 17, 1, '2025-05-11 07:58:13'),
(6, 7, 21, 1, '2025-05-12 07:16:32'),
(7, 7, 22, 2, '2025-05-12 07:18:28'),
(8, 7, 20, 3, '2025-05-12 07:19:19'),
(9, 8, 25, 1, '2025-05-13 03:22:00'),
(10, 8, 24, 2, '2025-05-13 03:54:09'),
(11, 8, 23, 3, '2025-05-13 03:57:11'),
(12, 9, 26, 1, '2025-05-13 23:58:18'),
(13, 9, 27, 2, '2025-05-14 00:39:45'),
(14, 10, 32, 1, '2025-05-14 00:57:11'),
(15, 10, 33, 2, '2025-05-14 01:09:38'),
(16, 10, 31, 3, '2025-05-14 03:58:11'),
(17, 11, 36, 1, '2025-05-14 04:13:17'),
(18, 11, 35, 2, '2025-05-14 04:14:18'),
(19, 11, 34, 3, '2025-05-14 04:14:50'),
(20, 13, 38, 1, '2025-05-14 08:10:03'),
(21, 14, 42, 1, '2025-05-15 06:52:21'),
(22, 14, 41, 2, '2025-05-15 07:22:32'),
(23, 14, 40, 3, '2025-05-15 15:22:33'),
(24, 13, 39, 2, '2025-05-15 15:24:08'),
(25, 13, 37, 3, '2025-05-15 15:46:26'),
(26, 15, 43, 1, '2025-05-15 15:58:14'),
(27, 15, 44, 2, '2025-05-16 01:48:57'),
(28, 17, 50, 1, '2025-05-16 06:46:32'),
(29, 19, 55, 1, '2025-05-16 08:28:24'),
(30, 19, 57, 2, '2025-05-16 08:30:25'),
(31, 19, 56, 3, '2025-05-16 11:52:38'),
(32, 20, 59, 1, '2025-05-16 12:24:05'),
(33, 20, 58, 2, '2025-05-16 12:24:49'),
(34, 21, 62, 1, '2025-05-16 12:50:57'),
(35, 21, 61, 2, '2025-05-18 05:51:38'),
(36, 21, 63, 3, '2025-05-18 05:59:48'),
(37, 22, 66, 1, '2025-05-19 04:31:13'),
(38, 23, 67, 1, '2025-05-19 14:43:50'),
(39, 24, 71, 1, '2025-05-20 11:52:26'),
(40, 25, 73, 1, '2025-05-20 15:06:52'),
(41, 25, 74, 2, '2025-05-20 15:09:33'),
(42, 26, 76, 1, '2025-06-17 12:58:22'),
(43, 27, 80, 1, '2025-07-24 07:23:30');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `draw_dates`
--
ALTER TABLE `draw_dates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `participants`
--
ALTER TABLE `participants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `participant_id` (`participant_id`);

--
-- Indexes for table `pengelola`
--
ALTER TABLE `pengelola`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `winners`
--
ALTER TABLE `winners`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `participant_id` (`participant_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `draw_dates`
--
ALTER TABLE `draw_dates`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `participants`
--
ALTER TABLE `participants`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=155;

--
-- AUTO_INCREMENT for table `pengelola`
--
ALTER TABLE `pengelola`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `winners`
--
ALTER TABLE `winners`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `draw_dates`
--
ALTER TABLE `draw_dates`
  ADD CONSTRAINT `draw_dates_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
