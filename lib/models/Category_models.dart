class CategoriesModel {
  final String categoryId;
  final String categoryImg;
  final String categoryName;


  CategoriesModel({
    required this.categoryId,
    required this.categoryImg,
    required this.categoryName,
  });

  // Serialize the ServiceModel instance to a JSON map
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryImg': categoryImg,
      'categoryName': categoryName,
    };
  }

  // Create a ServiceModel instance from a JSON map
  factory CategoriesModel.fromMap(Map<String, dynamic> json) {
    return CategoriesModel(
       categoryId: json['categoryId'],
      categoryImg: json['categoryImg'],
      categoryName: json['categoryName'],
    );
  }
}