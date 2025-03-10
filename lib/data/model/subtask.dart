import 'dart:convert';

import 'package:tasko/data/model/owner_detail.dart';
import 'package:tasko/utils/utils.dart';

class SubTasks {
  String? subTaskId;
  String? subTaskName;
  String? subTaskDescription;
  Owner? subTaskOwner;
  Owner? subTaskCreator;
  bool? isCompleted;
  bool? subTaskProofOfCompletion;
  List<dynamic>? subTaskProofOfCompletionImage;
  List<dynamic>? subTaskDocuments;
  String? subTaskPriorityLevel;

  SubTasks(
      this.subTaskId,
      this.subTaskName,
      this.subTaskDescription,
      this.subTaskOwner,
      this.subTaskCreator,
      this.isCompleted,
      this.subTaskProofOfCompletion,
      this.subTaskProofOfCompletionImage,
      this.subTaskDocuments,
      this.subTaskPriorityLevel);

  factory SubTasks.fromMap(Map<String, dynamic> map) {
    return SubTasks(
        map['subTaskId'],
        map['subTaskName'],
        map['subTaskDescription'],
        map['subTaskOwner'] != null ? Owner.fromMap(map['subTaskOwner']) : null,
        map['subTaskCreator'] != null
            ? Owner.fromMap(map['subTaskCreator'])
            : null,
        map['isCompleted'],
        map['subTaskProofOfCompletion'],
        map['subTaskProofOfCompletionImage'] == null
            ? []
            : json
                .decode(map['subTaskProofOfCompletionImage']
                    .toString()
                    .replaceAll("'", '"')
                    .replaceAll('JPEG', 'jpg')
                    .replaceAll('WEBP', 'webp'))
                .map((image) => getImagePath(map['subTaskId'], image))
                .toList(),
        map['subTaskDocuments'] == null
            ? []
            : json
                .decode(map['subTaskDocuments']
                    .toString()
                    .replaceAll("'", '"')
                    .replaceAll('JPEG', 'jpg')
                    .replaceAll('WEBP', 'webp'))
                .map((image) => getImagePath(map['subTaskId'], image))
                .toList(),
        map['subTaskPriorityLevel']);
  }

  Map<String, dynamic> toMap() {
    return {
      'subTaskId': subTaskId,
      'subTaskName': subTaskName,
      'subTaskDescription': subTaskDescription,
      'subTaskOwner': subTaskOwner,
      'subTaskCreator': subTaskCreator,
      'isCompleted': isCompleted,
      'subTaskProofOfCompletion': subTaskProofOfCompletion,
      'subTaskProofOfCompletionImage': subTaskProofOfCompletionImage,
      'subTaskDocuments': subTaskDocuments,
      'subTaskPriorityLevel': subTaskPriorityLevel
    };
  }

  static String getImagePath(subtaskId, imageName) {
    return ImageUrlBuilder.getImage('files/tasks/$subtaskId/$imageName');
  }
}
