class PixelizeModel {
  final String imageUrl;

  PixelizeModel({required this.imageUrl});

  factory PixelizeModel.fromJson(Map<String, dynamic> json) {
    return PixelizeModel(
      imageUrl: json['data']['pixelized_image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
    };
  }
}
