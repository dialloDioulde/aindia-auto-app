/**
 * @created 25/10/2023 - 14:18
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

class Constants {
  final GOOGLE_MAP_COUNTRIES = ["sn", "gm", "ci", "fr", "ca"];

  // WEB SOCKETS EVENTS
  final CREATE_ROOM = "createRoom";
  final ROOM_ALREADY_EXISTS = "roomAlreadyExists";
  final LEFT_ROOM = "leftRoom";
  final LEAVE_ROOM = "leaveRoom";
  final ROOM_NOT_FOUND = "roomNotFound";
  final CLOSE = "close";
  final ORDER_FROM_SERVER = "orderFromServer";
  final UPDATE_DRIVER_POSITION = "updateDriverPosition";
  final CREATE_ORDER = "createOrder";
  final CANCEL_ORDER = "cancelOrder";

  // Language
  final FR_FR = "fr_FR";

  // TIMEZONE
  final AFRICA_DAKAR = 'Africa/Dakar';

  // Dates Format
  final YYYY_MM_DD_HH_MM_SS = 'yyyy-MM-dd HH:mm:ss';

  final DEVICE_TOKEN = "deviceToken";
}
