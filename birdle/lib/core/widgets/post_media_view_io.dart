import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/post_model.dart';

class PostMediaView extends StatefulWidget {
  final PostMediaType mediaType;
  final String mediaPath;
  final double height;

  const PostMediaView({
    super.key,
    required this.mediaType,
    required this.mediaPath,
    this.height = 260,
  });

  @override
  State<PostMediaView> createState() => _PostMediaViewState();
}

class _PostMediaViewState extends State<PostMediaView> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _setupVideo();
  }

  @override
  void didUpdateWidget(covariant PostMediaView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mediaPath != widget.mediaPath ||
        oldWidget.mediaType != widget.mediaType) {
      _disposeVideo();
      _setupVideo();
    }
  }

  void _setupVideo() {
    if (widget.mediaType != PostMediaType.video || widget.mediaPath.isEmpty) {
      return;
    }

    _videoController = VideoPlayerController.file(File(widget.mediaPath))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaType == PostMediaType.none || widget.mediaPath.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.mediaType == PostMediaType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(widget.mediaPath),
          height: widget.height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff0f172a),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const CircularProgressIndicator(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
                setState(() {});
              },
              icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
