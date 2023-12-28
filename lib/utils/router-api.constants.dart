/**
 * @created 18/10/2023 - 15:21
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

class RouterApiConstants {
  static const String registerAccount = '/register-account';
  static const String loginAccount = '/login-account';
  static const String createOrder = '/create-order';
  static const String updateOrder = '/update-order';
  static const String order = '/order/';
  static const String cancelOrder = '/cancel-order/';
  static const String sendOrderToDriver = '/send-order-to-driver';

  static const String orderData = '/order-data/';
  static const String acceptOrder = '/accept-order/';
  static const String rejectOrder = '/reject-order/';

  static const String createOrUpdateDriverPosition = '/create-or-update-driver-position';

  static const String createIdentity = '/create-identity';
  static const String updateIdentity = '/update-identity/';
  static const String identity = '/identity/';

  static const String createOrUpdateDeviceToken = '/create-or-update-token-device';
}
