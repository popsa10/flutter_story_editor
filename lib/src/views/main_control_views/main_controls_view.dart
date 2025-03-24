// Import necessary Dart and Flutter packages.

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_story_editor/src/controller/controller.dart';
import 'package:flutter_story_editor/src/enums/story_editing_modes.dart';
import 'package:flutter_story_editor/src/models/stroke.dart';
import 'package:flutter_story_editor/src/utils/utils.dart';
import 'package:flutter_story_editor/src/views/main_control_views/filters_view.dart';
import 'package:flutter_story_editor/src/widgets/draggable_sticker_widget.dart';
import 'package:flutter_story_editor/src/widgets/draggable_text_widget.dart';

// Import additional custom views for different aspects of the UI.

import 'caption_view.dart';
import 'filter_text_view.dart';
import 'thumbnail_view.dart';
import 'top_view.dart';

class MainControlsView extends StatefulWidget {
  final List<File>? selectedFiles; // Optional list of media files selected for editing.
  final VoidCallback? onSaveClickListener; // Optional callback for save action.
  final TextEditingController? captionController; // Optional controller for caption text.
  final FlutterStoryEditorController controller; // Controller for managing editor states and interactions.
  final List<File> uiViewEditableFiles; // List of editable media files for the UI.
  final List<List<double>> selectedFilters; // List of filters applied to each media file.
  final List<List<DraggableTextWidget>> textList; // Lists of draggable text widgets for each page.
  final List<List<DraggableStickerWidget>> stickerList; // Lists of draggable sticker widgets for each page.
  final Function(List<double>) onFilterChange; // Callback for changing filters.
  final Function(File) onImageCrop; // Callback for cropping images.
  final VoidCallback onUndoClickListener; // Callback for undo actions.
  final VoidCallback onPaintClickListener; // Callback for activating paint mode.
  final VoidCallback onTextClickListener; // Callback for activating text mode.
  final VoidCallback onStickersClickListener; // Callback for activating stickers mode.
  final PageController pageController; // Controller for managing page transitions.
  final int currentPageIndex; // Index of the current page in the editor.
  final List<Stroke> lines; // List of stroke actions for drawing.
  final bool isSaving; // Flag to indicate if a save operation is in progress.
  final bool isFocused; // Flag to check if the keyboard is focused.
  final FocusNode? captionFocusNode;// Optional focus node for the caption input.
  final Widget cropWidget;
  final Widget filterWidget;
  final Widget textWidget;
  final Widget done;
  final Widget cancel;
  final Color bottomColor;


  const MainControlsView(
      {super.key,
      this.selectedFiles,
      this.onSaveClickListener,
      this.captionController,
      required this.controller,
      required this.isFocused,
      required this.uiViewEditableFiles,
      required this.selectedFilters,
      required this.onFilterChange,
      required this.onImageCrop,
      required this.onUndoClickListener,
      required this.pageController,
      required this.currentPageIndex,
      required this.onPaintClickListener,
      required this.onTextClickListener,
      required this.lines,
      required this.isSaving,
      required this.filterWidget,
      required this.cropWidget,
      required this.textWidget,
        required this.textList,
        this.captionFocusNode,
        required this.onStickersClickListener, required this.stickerList, required this.done, required this.cancel, required this.bottomColor,
       });

  @override
  State<MainControlsView> createState() => _MainControlsViewState();
}

class _MainControlsViewState extends State<MainControlsView> {
  final Map<File, Uint8List?> _thumbnails = {}; // Cache for storing generated thumbnails for video files.

  // Variables for tracking original files before modifications.
  List<File>? originalFiles;

  static const double maxVideoSizeMB = 50; // Maximum allowed video size in MB.
  static const double maxImageSizeMB = 5; // Maximum allowed image size in MB.

  // Function to generate thumbnails for video files asynchronously.
  void generateVideoFilesThumbnails() async {
    for (var file in widget.selectedFiles ?? []) {
      if (isVideo(file)) {
        var generatedThumbnail = await generateThumbnail(file);
        if (mounted) {
          setState(() {
            _thumbnails[file] = generatedThumbnail;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Initial setup to generate thumbnails and handle large files.
    generateVideoFilesThumbnails();

    for (var file in widget.selectedFiles!) {
      final bytes = file.readAsBytesSync();
      final sizeInMB = bytes.lengthInBytes / (1024 * 1024);

      if (isVideo(file) && sizeInMB > maxVideoSizeMB) {
        Navigator.pop(context);
      }

      if (!isVideo(file) && sizeInMB > maxImageSizeMB) {
        Navigator.pop(context);
      }
    }

    originalFiles = List<File>.from(widget.selectedFiles!);
  }

  // Function to crop images.
  void _cropImage(BuildContext context) {
    cropImage(
      context,
      file: originalFiles![widget.currentPageIndex],
    ).then((croppedFile) async {
      if (croppedFile != null) {
        File croppedImage = File(croppedFile.path);
        widget.onImageCrop(croppedImage);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PositionedDirectional(top: 12,end: 28,child: GestureDetector(onTap: () {
          Navigator.pop(context);
        },child: Icon(Icons.close,color: Colors.white,size: 24,))),
        for (File file in widget.selectedFiles!)
          if (!(isVideo(file)))
            PositionedDirectional(top: 47,start: 12,child: _buildTop()),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildBottom(),
        ),
      ],
    );
  }

  // Function to build the top view of the editor.
  Widget _buildTop() {
    return TopView(
      stickerList: widget.stickerList,
      textList: widget.textList,
      controller: widget.controller,
      lines: widget.lines,
      filterIcon: widget.filterWidget,
      textIcon: widget.textWidget,
      onTextClickListener: () {
        widget.onTextClickListener();
      },
      onStickersClickListener: () {
        widget.onStickersClickListener();
      },
      onPaintClickListener: () {
        widget.onPaintClickListener();
      },
      cropIcon: widget.cropWidget,
      onUndoClickListener: widget.onUndoClickListener,
      currentPageIndex: widget.currentPageIndex,
      selectedFilters: widget.selectedFilters,
      selectedFile: widget.selectedFiles![widget.currentPageIndex],
      onTapCropListener: () {
        _cropImage(context);
      },
    );
  }

  // Function to build the bottom view of the editor.
  Widget _buildBottom() {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(),
          ),
          if (widget.controller.editingModeSelected == StoryEditingModes.filters)
            FiltersView(
              onFilterChange: (filter) {
                widget.onFilterChange(filter);
              },
              selectedFilters: widget.selectedFilters,
              currentPageIndex: widget.currentPageIndex,
              selectedFiles: originalFiles,
            ),
          Container(
            color: widget.bottomColor,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(onTap: (){
                    widget.onSaveClickListener;
                  },child: widget.done),
                ),
                SizedBox(width: 24,),
                Expanded(child: widget.cancel),
              ],
            ),

          )

        ],
      ),
    );
  }
}
