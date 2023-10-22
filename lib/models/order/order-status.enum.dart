/**
 * @created 22/10/2023 - 15:52
 * @project aindia_auto_app
 * @author mamadoudiallo
 */


enum OrderStatusEnum {
  PENDING,
  IN_PROGRESS,
  PROCESSED,
  CANCELLED,
}

class OrderStatus {
  int orderStatusValue(OrderStatusEnum value) {
    var orderStatus;
    switch (value) {
      case OrderStatusEnum.PENDING:
        orderStatus = 1;
        break;
      case OrderStatusEnum.IN_PROGRESS:
        orderStatus = 2;
        break;
      case OrderStatusEnum.PROCESSED:
        orderStatus = 3;
        break;
      case OrderStatusEnum.CANCELLED:
        orderStatus = 4;
        break;
    }
    return orderStatus;
  }

  String getOrderStatus(int? value) {
    var orderStatus = "En attente";
    switch (value) {
      case 1:
        orderStatus = "En attente";
        break;
      case 2:
        orderStatus = "En cours";
        break;
      case 3:
        orderStatus = "Terminée";
        break;
      case 4:
        orderStatus = "Annulée";
        break;
    }
    return orderStatus;
  }
}