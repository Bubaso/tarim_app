import 'package:flutter/material.dart';

class StoryItem {
  final String id;
  final String superTitle;
  final String superTitleEn;
  final String headline;
  final String headlineEn;
  final String bigStatValue;
  final String bigStatValueEn;
  final String statLabel;
  final String statLabelEn;
  final String backgroundUrl;

  const StoryItem({
    required this.id,
    required this.superTitle,
    this.superTitleEn = '',
    required this.headline,
    this.headlineEn = '',
    required this.bigStatValue,
    this.bigStatValueEn = '',
    required this.statLabel,
    this.statLabelEn = '',
    required this.backgroundUrl,
  });
}

class StoryGroup {
  final String id;
  final String title;
  final String titleEn;
  final String avatarUrl;
  final String articleId;
  final bool isNew;
  final List<StoryItem> items;

  const StoryGroup({
    required this.id,
    required this.title,
    this.titleEn = '',
    required this.avatarUrl,
    required this.articleId,
    required this.items,
    this.isNew = false,
  });
}
