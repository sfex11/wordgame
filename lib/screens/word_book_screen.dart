import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../data/word_data.dart';

class WordBookScreen extends StatefulWidget {
  const WordBookScreen({super.key});

  @override
  State<WordBookScreen> createState() => _WordBookScreenState();
}

class _WordBookScreenState extends State<WordBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단어장'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '수집한 단어'),
            Tab(text: '복습 단어'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCollectedWordsTab(),
          _buildWrongWordsTab(),
        ],
      ),
    );
  }

  Widget _buildCollectedWordsTab() {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final collectedWords = provider.gameState.collectedWords;

        if (collectedWords.isEmpty) {
          return _buildEmptyState(
            icon: Icons.book_outlined,
            title: '수집한 단어가 없습니다',
            subtitle: '게임을 플레이하여 단어를 수집하세요!',
          );
        }

        // 단어를 초성별로 그룹화
        final groupedWords = _groupWordsByInitial(collectedWords);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedWords.keys.length,
          itemBuilder: (context, index) {
            final initial = groupedWords.keys.elementAt(index);
            final words = groupedWords[initial]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 초성 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
                // 단어 목록
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: words.map((word) {
                    final meaning = _getMeaning(word);
                    return _buildWordChip(word, meaning, Colors.green);
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWrongWordsTab() {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final wrongWords = provider.gameState.wrongWords;

        if (wrongWords.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: '복습할 단어가 없습니다',
            subtitle: '틀린 단어가 여기에 저장됩니다.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wrongWords.length,
          itemBuilder: (context, index) {
            final word = wrongWords[index];
            final meaning = _getMeaning(word);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    meaning,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  onPressed: () {
                    _showRemoveConfirmation(context, word, provider);
                  },
                  tooltip: '복습 완료',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordChip(String word, String meaning, Color color) {
    return GestureDetector(
      onTap: () => _showWordDetail(word, meaning),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color.shade700,
          ),
        ),
      ),
    );
  }

  Map<String, List<String>> _groupWordsByInitial(List<String> words) {
    final grouped = <String, List<String>>{};

    for (final word in words) {
      if (word.isEmpty) continue;
      final initial = _getInitialConsonant(word[0]);
      grouped.putIfAbsent(initial, () => []).add(word);
    }

    // 초성 순서로 정렬
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var key in sortedKeys) key: grouped[key]!..sort()};
  }

  String _getInitialConsonant(String char) {
    const initials = [
      'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
      'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
    ];

    final code = char.codeUnitAt(0);
    if (code >= 0xAC00 && code <= 0xD7A3) {
      final index = ((code - 0xAC00) / 588).floor();
      return initials[index];
    }
    return char;
  }

  String _getMeaning(String word) {
    for (final item in wordDatabase) {
      if (item['text'] == word) {
        return item['meaning'] ?? '뜻 없음';
      }
    }
    return '뜻 없음';
  }

  void _showWordDetail(String word, String meaning) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          word,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          meaning,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    String word,
    GameProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('복습 완료'),
        content: Text('\'$word\'을(를) 복습 목록에서 제거할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeWrongWord(word);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('제거'),
          ),
        ],
      ),
    );
  }
}
