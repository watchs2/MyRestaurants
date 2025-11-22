class Restaurant {
  final int? id;
  final String name;
  final String address;
  final String? phone;
  final double latitude;
  final double longitude;
  final String? imgUrl;
  final int? stars;

  Restaurant({
    this.id,
    required this.name,
    required this.address,
    this.phone,
    required this.latitude,
    required this.longitude,
    this.imgUrl,
    this.stars,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      imgUrl: map['img_url'] as String?,
      stars: map['stars'] as int?,
    );
  }
}
