import 'package:flutter/material.dart';

class AttendanceDialog extends StatelessWidget {
  final int streak;
  final int reward;

  const AttendanceDialog({
    super.key,
    required this.streak,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            // 타이틀
            const Text(
              '출석 완료!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // 연속 출석 일수
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: Color(0xFFFF9800)),
                  const SizedBox(width: 4),
                  Text(
                    '$streak일 연속 출석',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 보상 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '오늘의 보상: ',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.monetization_on, color: Color(0xFFFFD700)),
                  const SizedBox(width: 4),
                  Text(
                    '+$reward',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 연속 출석 보상 안내
            Text(
              _getStreakBonusText(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // 받기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '보상 받기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStreakBonusText() {
    if (streak >= 7) {
      return '7일 연속 출석 달성! 최대 보상 획득 중';
    } else if (streak >= 5) {
      return '5일 연속 출석 달성! 7일 달성 시 최대 보상';
    } else if (streak >= 3) {
      return '3일 연속 출석 달성! 5일 달성 시 추가 보상';
    } else {
      return '3일 연속 출석 시 추가 보상!';
    }
  }
}
