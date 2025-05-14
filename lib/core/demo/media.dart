import 'dart:math';

class DemoMedia {
  static String get getRandomImage => "https://picsum.photos/200/300";

  static String get getAppRandomImage =>
      "https://picsum.photos/id/${Random().nextInt(800)}/200/300.jpg";

  static String get getRandomVideo => Random().nextBool()
      ? "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_5mb.mp4"
      : "https://file-examples.com/storage/fe0e9b723466913cf9611b7/2017/04/file_example_MP4_640_3MG.mp4";

  static List<String> getRandomImagesAndVideos(int length) {
    return List.generate(
      length,
      (index) => Random().nextBool() ? getRandomImage : getRandomVideo,
    );
  }
}
