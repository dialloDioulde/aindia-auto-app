/**
 * @created 22/10/2023 - 15:52
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

enum DriverPositionStatusEnum { AVAILABLE, BUSY, DISCONNECTED }

class DriverPositionStatus {
  int driverPositionStatusValue(DriverPositionStatusEnum value) {
    var driverPositionStatus;
    switch (value) {
      case DriverPositionStatusEnum.AVAILABLE:
        driverPositionStatus = 1;
        break;
      case DriverPositionStatusEnum.BUSY:
        driverPositionStatus = 2;
        break;
      case DriverPositionStatusEnum.DISCONNECTED:
        driverPositionStatus = 3;
        break;
    }
    return driverPositionStatus;
  }

  String getOrderStatus(int? value) {
    var driverPositionStatus = "Disponible";
    switch (value) {
      case 1:
        driverPositionStatus = "Disponible";
        break;
      case 2:
        driverPositionStatus = "Occcupé";
        break;
      case 3:
        driverPositionStatus = "Déconnecté";
        break;
    }
    return driverPositionStatus;
  }
}
