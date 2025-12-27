import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _pages = [
    TutorialPage(
      title: '단어부자에 오신 것을 환영합니다!',
      description: '한글 단어 퍼즐 게임을 즐겨보세요.\n십자말풀이처럼 단어를 완성하면 됩니다.',
      icon: Icons.emoji_events,
      color: const Color(0xFF4CAF50),
    ),
    TutorialPage(
      title: '퍼즐 보드',
      description: '초록색 글자는 힌트입니다.\n파란색 빈칸에 올바른 글자를 채워주세요.',
      icon: Icons.grid_on,
      color: const Color(0xFF2196F3),
      showGridExample: true,
    ),
    TutorialPage(
      title: '글자 선택',
      description: '화면 하단의 글자 버튼을 눌러\n빈칸을 채워주세요.',
      icon: Icons.touch_app,
      color: const Color(0xFFFF9800),
      showLetterExample: true,
    ),
    TutorialPage(
      title: '힌트 사용',
      description: '막히면 힌트를 사용해보세요!\n• 글자 공개: 빈칸 하나 공개\n• 뜻 보기: 단어 의미 확인\n• 오답 표시: 틀린 글자 표시',
      icon: Icons.lightbulb,
      color: const Color(0xFF9C27B0),
    ),
    TutorialPage(
      title: '보상 획득',
      description: '레벨을 클리어하면 코인을 획득합니다.\n코인으로 힌트, 아이템, 캐릭터를\n구매할 수 있어요!',
      icon: Icons.monetization_on,
      color: const Color(0xFFFFD700),
    ),
    TutorialPage(
      title: '준비 완료!',
      description: '이제 단어부자가 될 준비가 되었습니다.\n첫 번째 레벨에 도전해보세요!',
      icon: Icons.rocket_launch,
      color: const Color(0xFFE91E63),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _skipTutorial() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _pages[_currentPage].color.withOpacity(0.8),
              _pages[_currentPage].color.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 건너뛰기 버튼
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipTutorial,
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              // 페이지 뷰
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // 페이지 인디케이터
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // 다음 버튼
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _pages[_currentPage].color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? '다음' : '시작하기',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.8, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 60,
                color: page.color,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 제목
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // 설명
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // 예시 위젯
          if (page.showGridExample) _buildGridExample(),
          if (page.showLetterExample) _buildLetterExample(),
        ],
      ),
    );
  }

  Widget _buildGridExample() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildExampleCell('사', isHint: true),
          const SizedBox(width: 4),
          _buildExampleCell('', isBlank: true),
          const SizedBox(width: 4),
          _buildExampleCell('', isBlank: true),
        ],
      ),
    );
  }

  Widget _buildExampleCell(String letter, {bool isHint = false, bool isBlank = false}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isHint
            ? const Color(0xFFE8F5E9)
            : isBlank
                ? const Color(0xFFE3F2FD)
                : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHint
              ? const Color(0xFF4CAF50)
              : isBlank
                  ? const Color(0xFF2196F3)
                  : Colors.grey,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isHint ? const Color(0xFF4CAF50) : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildLetterExample() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['랑', '과', '사'].map((letter) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4CAF50),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool showGridExample;
  final bool showLetterExample;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.showGridExample = false,
    this.showLetterExample = false,
  });
}
