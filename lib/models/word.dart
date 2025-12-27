import 'package:equatable/equatable.dart';

/// 단어 모델
class Word extends Equatable {
  final String text;
  final String meaning;
  final int length;

  const Word({
    required this.text,
    required this.meaning,
  }) : length = text.length;

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      text: json['text'] as String,
      meaning: json['meaning'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'meaning': meaning,
    };
  }

  @override
  List<Object?> get props => [text, meaning];
}
