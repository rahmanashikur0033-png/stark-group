class Vehicle {
  final int? id;
  final String vehicleNumber;
  final String type;
  final String brand;
  final String model;
  final int year;
  final String status;

  const Vehicle({
    this.id,
    required this.vehicleNumber,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int?,
      vehicleNumber: json['vehicleNumber'] as String,
      type: json['type'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleNumber': vehicleNumber,
      'type': type,
      'brand': brand,
      'model': model,
      'year': year,
      'status': status,
    };
  }
}
