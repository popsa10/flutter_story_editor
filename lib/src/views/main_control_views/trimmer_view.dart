import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_story_editor/src/models/simple_sketecher.dart';
import 'package:flutter_story_editor/src/models/stroke.dart';
import 'package:flutter_story_editor/src/theme/style.dart';

import 'package:video_trimmer_pro/video_trimmer_pro.dart';

// TrimmerView is a StatefulWidget that provides a video trimming interface.
class TrimmerView extends StatefulWidget {
  final File file; // File to be trimmed.
  final int pageIndex; // Index of the current page in the page controller.
  final PageController pageController; // Controller for page navigation.
  final Function(File) onTrimCompleted; // Callback function after trim is completed.
  final bool? trimOnAdjust; // If true, trims the video as adjustments are made.
  final List<Stroke> lines; // List of drawing strokes to be displayed over the video.

  // Constructor for initializing TrimmerView with required parameters.
  const TrimmerView({
    super.key,
    required this.file,
    required this.pageIndex,
    required this.pageController,
    required this.onTrimCompleted,
    this.trimOnAdjust = false,
    required this.lines
  });

  @override
  TrimmerViewState createState() => TrimmerViewState();
}

// State class for TrimmerView, handling video loading, trimming, and UI interactions.
class TrimmerViewState extends State<TrimmerView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Ensures state is kept when swiping between tabs.

  double _startValue = 0.0; // Start position of the trim.
  double _endValue = 0.0; // End position of the trim.
  final Trimmer _trimmer = Trimmer(); // Trimmer instance for handling video operations.

  bool _isPlaying = false; // Indicates if the video is currently playing.
  bool _progressVisibility = false; // Shows or hides the progress indicator.
  Timer? _debounce; // Timer for debouncing trim operations.

  // Asynchronously trims the video and updates the UI on completion.
  Future<String?> _trimVideo() async {
    setState(() {
      _progressVisibility = true; // Show progress bar.
    });

    String? value;

    // Perform the trim operation and handle the result.
    await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (value) {
          widget.onTrimCompleted(File(value!)); // Callback with the new file.
        }).then((value) {
      setState(() {
        _progressVisibility = false; // Hide progress bar.
      });
    });

    return value;
  }

  // Debounces the trim operation to avoid excessive processing.
  void _debounceTrim() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _trimVideo();
    });
  }

  // Loads the video into the trimmer.
  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();
    _loadVideo(); // Initial video load.


    widget.pageController.addListener(() async {
      if (widget.pageController.page!.round() != widget.pageIndex &&
          _isPlaying) {
        await _trimmer.videoPlaybackControl(
            startValue: _startValue, endValue: _endValue);
        setState(() => _isPlaying = true);
      }
    });
  }

  @override
  void dispose() {
    _trimmer.dispose(); // Clean up the trimmer resources.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for keeping state alive.

    return Scaffold(
      body: VideoViewer(trimmer: _trimmer),
    );
  }
}


