import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StudyReelsScreen extends StatefulWidget {
  const StudyReelsScreen({super.key});

  @override
  _StudyReelsScreenState createState() => _StudyReelsScreenState();
}

class _StudyReelsScreenState extends State<StudyReelsScreen> {
  final List<String> reelUrls = [
    'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
    'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
  ];

  late PageController _pageController;
  final List<VideoPlayerController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    for (var url in reelUrls) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
      _videoControllers.add(controller);
    }

    // Play first video after init
    _videoControllers.first.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _videoControllers.first.play();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    for (var controller in _videoControllers) {
      controller.pause();
    }
    _videoControllers[index].play();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: reelUrls.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            final controller = _videoControllers[index];
            return Stack(
              children: [
                Center(
                  child: controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
