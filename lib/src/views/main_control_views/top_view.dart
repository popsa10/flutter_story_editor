
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_story_editor/src/const/filters.dart';
import 'package:flutter_story_editor/src/controller/controller.dart';
import 'package:flutter_story_editor/src/models/stroke.dart';
import 'package:flutter_story_editor/src/utils/utils.dart';
import 'package:flutter_story_editor/src/widgets/draggable_sticker_widget.dart';
import 'package:flutter_story_editor/src/widgets/draggable_text_widget.dart';
import '../../enums/story_editing_modes.dart';
// TopView is a StatefulWidget that provides the top bar interface for story editing controls.
class TopView extends StatefulWidget {
  final File selectedFile; // The currently selected file for editing.
  final VoidCallback onTapCropListener; // Callback for handling crop operations.
  final int currentPageIndex; // Index of the current page being edited.
  final List<List<double>> selectedFilters; // Current filter applied to each file page.
  final List<List<DraggableTextWidget>> textList; // List of text widgets added to each file page.
  final List<List<DraggableStickerWidget>> stickerList; // List of sticker widgets added to each file page.
  final VoidCallback onUndoClickListener; // Callback for undo operations.
  final VoidCallback onPaintClickListener; // Callback for activating the paint editing mode.
  final VoidCallback onTextClickListener; // Callback for activating the text editing mode.
  final VoidCallback onStickersClickListener; // Callback for activating the stickers editing mode.
  final List<Stroke> lines; // List of all drawing strokes on the current page.
  final FlutterStoryEditorController controller;// Controller for managing editor state.
  final Widget cropIcon;
  final Widget textIcon;
  final Widget filterIcon;

  // Constructor for initializing TopView with required parameters.
  const TopView({
    super.key,
    required this.selectedFile,
    required this.onTapCropListener,
    required this.currentPageIndex,
    required this.selectedFilters,
    required this.onUndoClickListener,
    required this.onPaintClickListener,
    required this.lines,
    required this.controller,
    required this.onTextClickListener,
    required this.textList,
    required this.onStickersClickListener,
    required this.stickerList, required this.cropIcon, required this.textIcon, required this.filterIcon
  });

  @override
  State<TopView> createState() => _TopViewState();
}

// State class for TopView, handles the rendering of the top toolbar.
class _TopViewState extends State<TopView> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisSize: MainAxisSize.min,
      children: [
              // Undo icon is shown if there are any changes that can be undone.
              widget.selectedFilters[widget.currentPageIndex] != noFiler || widget.lines.isNotEmpty || widget.textList[widget.currentPageIndex].isNotEmpty || widget.stickerList[widget.currentPageIndex].isNotEmpty ? GestureDetector(
                onTap: widget.onUndoClickListener,
                child: const Icon(
                  Icons.undo,
                  size: 32,
                  color: Colors.white,
                ),
              ) : Container(),
              const SizedBox(
                height: 16,
              ),
              if(!isVideo(widget.selectedFile))
              ...[
                GestureDetector(
                    onTap: widget.onTapCropListener,
                    child:  widget.cropIcon),
                const SizedBox(
                  height: 16,
                ),
              ],
              GestureDetector(
                onTap: widget.onTextClickListener,
                child: widget.textIcon,
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: (){
                  if(widget.controller.editingModeSelected == StoryEditingModes.filters) {
                    widget.controller.setStoryEditingModeSelected = StoryEditingModes.none;
                  }else{
                    widget.controller.setStoryEditingModeSelected = StoryEditingModes.filters;
                  }
                },
                child: widget.filterIcon,
          ),
      ],
    );
  }
}
