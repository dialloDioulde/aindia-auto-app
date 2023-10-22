/**
 * @created 22/10/2023 - 00:02
 * @project aindia_auto_app
 * @author mamadoudiallo
 */


class MapPositionModel {
  double? latitude;
  double? longitude;

  MapPositionModel(this.latitude, this.longitude);

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
