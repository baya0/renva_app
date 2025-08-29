class StoryModel {
  final String id;
  final String imageUrl;

  final String? description;

  StoryModel({required this.id, required this.imageUrl, this.description});

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? '',
      imageUrl: json['image_url'] ?? '',

      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image_url': imageUrl, 'description': description};
  }

  // Check if this is the Renva story
  bool get isRenvaStory => id == '1' || imageUrl == 'renva_logo';

  @override
  String toString() {
    return 'StoryModel{id: $id}';
  }
}
