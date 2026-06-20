class ListingModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final int views;

  ///  CATEGORY (NEW STRUCTURE)
  final Map<String, dynamic> category;

  final String condition;
  final List<String> images;

  final bool? isBoosted;
  final bool? isFeatured;
  final bool? isSold;
  double? distanceKm;

  /// 📍 LOCATION
  final Map<String, dynamic> location;

  /// 👤 SELLER
  final Map<String, dynamic> seller;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.views,
    required this.category,
    required this.condition,
    required this.images,
    required this.location,
    required this.seller,
    this.createdAt,
    this.updatedAt,
    this.isBoosted,
    this.isFeatured,
    this.isSold,
    this.distanceKm,
  });

  /// 🔥 CATEGORY HELPERS (VERY IMPORTANT FOR UI)
  String get mainCategory => category["main"] ?? "";
  String get subCategory => category["sub"] ?? "";
  String get childCategory => category["child"] ?? "";

  /// 📍 LOCATION HELPERS
  String get fullAddress => location["fullAddress"] ?? "";
  String get city => location["city"] ?? "";
  String get state => location["state"] ?? "";

  double get lat => (location["lat"] ?? 0).toDouble();
  double get long => (location["long"] ?? 0).toDouble();

  /// 🔥 FROM FIRESTORE
  factory ListingModel.fromMap(Map<String, dynamic> map, String docId) {
    return ListingModel(
      id: docId,
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      price: map['price'] ?? 0,
      views: map['views'] ?? 0,

      /// ✅ SAFE CATEGORY PARSE
      category: map['category'] is Map
          ? Map<String, dynamic>.from(map['category'])
          : {"main": "", "sub": "", "child": ""},

      condition: map['condition'] ?? "",
      images: List<String>.from(map['images'] ?? []),

      location: Map<String, dynamic>.from(map['location'] ?? {}),
      seller: Map<String, dynamic>.from(map['seller'] ?? {}),

      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : null,

      isBoosted: map['isBoosted'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      isSold: map['isSold'] ?? false,
      distanceKm: map['distanceKm'] != null
          ? (map['distanceKm'] as num).toDouble()
          : null,
    );
  }

  /// 🔥 TO MAP (OPTIONAL - IF YOU USE MODEL FOR UPLOAD)
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "price": price,
      "views": views,

      "category": {
        "main": mainCategory,
        "sub": subCategory,
        "child": childCategory,
      },

      "condition": condition,
      "images": images,

      "location": location,
      "seller": seller,

      "createdAt": createdAt,
      "updatedAt": updatedAt,

      "isBoosted": isBoosted,
      "isFeatured": isFeatured,
      "isSold": isSold,
    };
  }
}
