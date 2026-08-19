import 'package:flutter/material.dart';

class StoryItem {
  final String id;
  final String superTitle;
  final String headline;
  final String bigStatValue;
  final String statLabel;
  final String backgroundUrl;

  const StoryItem({
    required this.id,
    required this.superTitle,
    required this.headline,
    required this.bigStatValue,
    required this.statLabel,
    required this.backgroundUrl,
  });
}

class StoryGroup {
  final String id;
  final String title;
  final String avatarUrl;
  final String articleId;
  final bool isNew;
  final List<StoryItem> items;

  const StoryGroup({
    required this.id,
    required this.title,
    required this.avatarUrl,
    required this.articleId,
    required this.items,
    this.isNew = false,
  });
}
