import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  final AdService _adService = AdService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 사운드 설정
              _buildSection(
                title: '사운드',
                children: [
                  _buildSwitchTile(
                    icon: Icons.music_note,
                    title: '배경음악',
                    value: provider.gameState.bgmEnabled,
                    onChanged: (_) => provider.toggleBgm(),
                  ),
                  if (provider.gameState.bgmEnabled)
                    _buildVolumeTile(
                      icon: Icons.music_note_outlined,
                      title: '배경음악 볼륨',
                      value: _audioService.bgmVolume,
                      onChanged: (value) {
                        setState(() {
                          _audioService.setBgmVolume(value);
                        });
                      },
                    ),
                  _buildSwitchTile(
                    icon: Icons.volume_up,
                    title: '효과음',
                    value: provider.gameState.sfxEnabled,
                    onChanged: (_) => provider.toggleSfx(),
                  ),
                  if (provider.gameState.sfxEnabled)
                    _buildVolumeTile(
                      icon: Icons.volume_up_outlined,
                      title: '효과음 볼륨',
                      value: _audioService.sfxVolume,
                      onChanged: (value) {
                        setState(() {
                          _audioService.setSfxVolume(value);
                        });
                      },
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // 게임 정보
              _buildSection(
                title: '게임 정보',
                children: [
                  _buildInfoTile(
                    icon: Icons.star,
                    title: '최고 레벨',
                    value: '${provider.gameState.maxUnlockedLevel}',
                  ),
                  _buildInfoTile(
                    icon: Icons.emoji_events,
                    title: '총 점수',
                    value: '${provider.gameState.totalScore}',
                  ),
                  _buildInfoTile(
                    icon: Icons.monetization_on,
                    title: '보유 코인',
                    value: '${provider.gameState.totalCoins}',
                  ),
                  _buildInfoTile(
                    icon: Icons.book,
                    title: '수집한 단어',
                    value: '${provider.gameState.collectedWords.length}개',
                  ),
                  _buildInfoTile(
                    icon: Icons.local_fire_department,
                    title: '연속 출석',
                    value: '${provider.gameState.dailyStreak}일',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 무료 코인
              _buildSection(
                title: '무료 코인',
                children: [
                  ListTile(
                    leading: const Icon(Icons.play_circle_filled, color: Color(0xFFFFD700)),
                    title: const Text('광고 보고 코인 받기'),
                    subtitle: Text(
                      _adService.canShowRewarded()
                          ? '50코인 획득 가능'
                          : '${_adService.rewardedCooldownRemaining}초 후 가능',
                    ),
                    trailing: ElevatedButton(
                      onPressed: _adService.canShowRewarded()
                          ? () => _showRewardedAd(context, provider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('시청'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 데이터 관리
              _buildSection(
                title: '데이터 관리',
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('데이터 초기화'),
                    subtitle: const Text('모든 진행 상황이 삭제됩니다'),
                    onTap: () => _showResetConfirmation(context, provider),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 앱 정보
              _buildSection(
                title: '앱 정보',
                children: [
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    title: '버전',
                    value: '1.0.0',
                  ),
                  _buildInfoTile(
                    icon: Icons.code,
                    title: '개발자',
                    value: '단어부자 팀',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF4CAF50),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF4CAF50),
        ),
      ),
    );
  }

  Widget _buildVolumeTile({
    required IconData icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 24),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: const Color(0xFF4CAF50),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd(BuildContext context, GameProvider provider) async {
    final success = await _adService.showRewardedAd(
      onRewarded: (amount) {
        provider.addCoins(amount);
        _audioService.playSfx(AudioService.sfxCoinEarn);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('$amount 코인을 획득했습니다!'),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      },
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() {});
  }

  void _showResetConfirmation(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('데이터 초기화'),
          ],
        ),
        content: const Text(
          '정말로 모든 데이터를 삭제하시겠습니까?\n\n'
          '• 모든 레벨 진행 상황\n'
          '• 수집한 단어\n'
          '• 보유 코인\n'
          '• 연속 출석 기록\n\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.resetAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('데이터가 초기화되었습니다'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}
