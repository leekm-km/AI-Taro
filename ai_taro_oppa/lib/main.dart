import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '타로오빠',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LanguageSelectPage(),
    );
  }
}

enum AppLang { ko, en, zh, th }

enum Gender { male, female }

extension GenderLabel on Gender {
  String labelFor(AppLang lang) {
    switch (lang) {
      case AppLang.ko:
        return this == Gender.male ? '남자' : '여자';
      case AppLang.en:
        return this == Gender.male ? 'Male' : 'Female';
      case AppLang.zh:
        return this == Gender.male ? '男' : '女';
      case AppLang.th:
        return this == Gender.male ? 'ชาย' : 'หญิง';
    }
  }
}

enum Persona { oppa, nuna, hyung, eonni, neutral }

extension PersonaLabel on Persona {
  String labelFor(AppLang lang) {
    switch (lang) {
      case AppLang.ko:
        switch (this) {
          case Persona.oppa: return '오빠';
          case Persona.nuna: return '누나';
          case Persona.hyung: return '형';
          case Persona.eonni: return '언니';
          case Persona.neutral: return '타로 친구';
        }
      case AppLang.en:
        switch (this) {
          case Persona.oppa: return 'Oppa';
          case Persona.nuna: return 'Nuna';
          case Persona.hyung: return 'Hyung';
          case Persona.eonni: return 'Unnie';
          case Persona.neutral: return 'Taro Buddy';
        }
      case AppLang.zh:
        switch (this) {
          case Persona.oppa: return '欧巴';
          case Persona.nuna: return '努娜';
          case Persona.hyung: return '亨';
          case Persona.eonni: return '恩尼';
          case Persona.neutral: return '塔罗朋友';
        }
      case AppLang.th:
        switch (this) {
          case Persona.oppa: return 'โอปป้า';
          case Persona.nuna: return 'นูนา';
          case Persona.hyung: return 'ฮยอง';
          case Persona.eonni: return 'ออนนี่';
          case Persona.neutral: return 'เพื่อนทาโร่';
        }
    }
  }
}

extension AppLangName on AppLang {
  String get label {
    switch (this) {
      case AppLang.ko: return '한국어';
      case AppLang.en: return 'English';
      case AppLang.zh: return '中文';
      case AppLang.th: return 'ไทย';
    }
  }
}

/// 1) 언어 선택
class LanguageSelectPage extends StatelessWidget {
  const LanguageSelectPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('언어를 선택하세요')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
            children: [
              _LangButton(lang: AppLang.ko, enabled: true),
              _LangButton(lang: AppLang.en, enabled: false),
              _LangButton(lang: AppLang.zh, enabled: false),
              _LangButton(lang: AppLang.th, enabled: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({required this.lang, required this.enabled});
  final AppLang lang;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GenderSelectPage(lang: lang)),
        );
      } : null,
      child: Text(lang.label),
    );
  }
}

class GenderSelectPage extends StatefulWidget {
  const GenderSelectPage({super.key, required this.lang});
  final AppLang lang;

  @override
  State<GenderSelectPage> createState() => _GenderSelectPageState();
}

class _GenderSelectPageState extends State<GenderSelectPage> {
  Gender? _gender;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('성별 선택')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('당신의 성별을 선택하세요', style: t.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(Gender.male.labelFor(widget.lang)),
                  selected: _gender == Gender.male,
                  onSelected: (_) => setState(() => _gender = Gender.male),
                ),
                ChoiceChip(
                  label: Text(Gender.female.labelFor(widget.lang)),
                  selected: _gender == Gender.female,
                  onSelected: (_) => setState(() => _gender = Gender.female),
                ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: _gender == null ? null : () {
                final persona = _gender == Gender.male ? Persona.hyung : Persona.oppa;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GreetingPage(lang: widget.lang, persona: persona),
                  ),
                );
              },
              child: const Text('다음'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 2) 환영 인사 + 카테고리 선택 + "카드 뽑기"
class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key, required this.lang, required this.persona});
  final AppLang lang;
  final Persona persona;
  @override
  State<GreetingPage> createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage> {
  late final String _fullText;
  String _visible = '';
  Timer? _timer;
  String? _category;

  final TextEditingController _lineCtrl = TextEditingController();
  String _userLine = '';

  @override
  void initState() {
    super.initState();
    _fullText = _greetingFor(widget.lang, widget.persona);
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lineCtrl.dispose();
    super.dispose();
  }

  void _startTyping() {
    _timer?.cancel();
    int i = 0;
    _visible = '';
    _timer = Timer.periodic(const Duration(milliseconds: 35), (t) {
      if (i >= _fullText.length) {
        t.cancel();
      } else {
        setState(() {
          _visible += _fullText[i];
          i++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('타로오빠')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 미소년 일러스트 (생성 이미지가 들어갈 자리)
            AspectRatio(
              aspectRatio: 3/2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: t.colorScheme.surfaceVariant,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // TODO: 생성된 이미지를 assets/characters/welcome_boy.png 로 저장 후 아래 주석 해제
                      // Image.asset('assets/characters/welcome_boy.png', fit: BoxFit.cover),
                      Center(child: Icon(Icons.person, size: 96, color: t.colorScheme.outline)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 자막 영역(타자 효과)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: t.colorScheme.surface,
                border: Border.all(color: t.colorScheme.outlineVariant),
              ),
              child: Text(
                _visible,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _cat('재물운'),
                _cat('연애운'),
                _cat('직업운'),
                _cat('건강운'),
                _cat('학업운'),
              ],
            ),
            const SizedBox(height: 12),
            if (_category != null)
              TextField(
                controller: _lineCtrl,
                onChanged: (v) => setState(() => _userLine = v),
                maxLines: 1,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: '마음속에 맴도는 한 줄',
                  hintText: '예: 이번 달 연애에서 제일 중요한 건?',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.style),
              label: const Text('카드 뽑기'),
              onPressed: (_category == null || _userLine.trim().isEmpty) ? null : () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CardSelectPage(
                    deckSize: 16,
                    pickCount: 3,
                    category: _category!,
                    persona: widget.persona,
                    lang: widget.lang,
                    userLine: _userLine.trim(),
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _cat(String name) {
    final selected = _category == name;
    return ChoiceChip(
      selected: selected,
      label: Text(name),
      onSelected: (_) => setState(() => _category = name),
    );
  }

  String _greetingFor(AppLang lang, Persona persona) {
    switch (lang) {
      case AppLang.ko:
        // 정체성 명확: 타로오빠 / 다정한 톤
        // 남성 이용자는 형(persona.hyung) 선택되어도 화자는 '타로오빠'로 고정 표기
        return '나는 타로오빠야. 네 얘기를 천천히 듣고, 오늘 필요한 조언만 또렷하게 건네줄게. 마음속에 맴도는 한 줄을 적어볼래?';
      case AppLang.en:
        return 'I’m Taro Oppa. Tell me a little, and I’ll offer only the guidance you need today—clearly and gently. What’s on your mind?';
      case AppLang.zh:
        return '我是塔罗欧巴。把心里的一点想法告诉我吧，我会用温和而清晰的方式给出今天需要的指引。你在想什么？';
      case AppLang.th:
        return 'เราเป็นทาโร่โอปป้า เล่าให้เราฟังสักนิด แล้วเราจะให้คำแนะนำที่ชัดเจนและอ่อนโยนสำหรับวันนี้ เธอกำลังคิดเรื่องอะไรอยู่?';
    }
  }
}

/// 3) 겹쳐진 카드 덱 UI (16장 기본), 선택 개수만 컨트롤
class CardSelectPage extends StatefulWidget {
  const CardSelectPage({
    super.key,
    this.deckSize = 16,
    this.pickCount = 3,
    required this.category,
    required this.persona,
    required this.lang,
    required this.userLine,
  });
  final int deckSize;
  final int pickCount;
  final String category;
  final Persona persona;
  final AppLang lang;
  final String userLine;

  @override
  State<CardSelectPage> createState() => _CardSelectPageState();
}

class _CardSelectPageState extends State<CardSelectPage> {
  late final List<int> _deck;
  final Set<int> _selected = {};
  final Random _rng = Random();

  late List<int> _drawPool;
  int _drawPtr = 0;
  final Map<int, Map<String, dynamic>> _drawnByFace = {}; // faceIndex -> {id:int, reversed:bool}
  int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    // 16 face-down cards (purely for animation/selection UI)
    _deck = List<int>.generate(widget.deckSize, (i) => i);
    _deck.shuffle();

    // Full 78-card tarot pool for actual draws
    _drawPool = List<int>.generate(78, (i) => i)..shuffle();
    _drawPtr = 0;
  }

  void _toggle(int card) {
    setState(() {
      if (_selected.contains(card)) {
        _selected.remove(card);
      } else if (_selected.length < widget.pickCount) {
        _selected.add(card);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final canConfirm = _selected.length == widget.pickCount;
    return Scaffold(
      appBar: AppBar(title: Text('카드 뽑기 - ${widget.category}')),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return Stack(
            children: [
              Positioned(
                left: 16, right: 16, top: 12,
                child: Column(
                  children: [
                    Text('카드를 ${widget.pickCount}장 뽑아주세요', textAlign: TextAlign.center, style: t.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '지금 고민이 되는 내용을 마음 속으로 떠올리면서, 카드를 하나 하나 신중히 선택해봐',
                      textAlign: TextAlign.center,
                      style: t.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: h * 0.20,
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    final n = _deck.length;
                    final pad = 24.0;                 // side padding
                    final width = size.maxWidth;
                    final baseY = size.maxHeight * 0.62;
                    final curveAmp = (size.maxHeight * 0.12).clamp(40.0, 140.0);
            
                    return Stack(
                      children: [
                        for (int i = 0; i < n; i++)
                          _buildFanCardLinear(
                            index: i,
                            pad: pad,
                            width: width,
                            baseY: baseY,
                            curveAmp: curveAmp,
                          ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                left: 16, right: 16, bottom: 24,
                child: FilledButton(
                  onPressed: canConfirm ? () {
                    final picks = _selected.toList()..sort();
                    final lines = <String>[];
                    for (final face in picks) {
                      final d = _drawnByFace[face]!;
                      final id = d["id"] as int;
                      final rev = (d["reversed"] as bool) ? "역" : "정";
                      lines.add("#${picks.indexOf(face)+1}: ID $id ($rev)");
                    }
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('선택 완료'),
                        content: Text([
                          '질문: ${widget.userLine}',
                          '카테고리: ${widget.category}',
                          ...lines,
                        ].join('\n')),
                        actions: [ TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기')) ],
                      ),
                    );
                  } : null,
                  child: Text(canConfirm ? '확인' : '카드 선택 중... (${_selected.length}/${widget.pickCount})'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFanCardLinear({
    required int index,
    required double pad,
    required double width,
    required double baseY,
    required double curveAmp,
  }) {
    final cardNo = _deck[index];
    final selected = _selected.contains(cardNo);
    final isHover = _hoverIndex == index;
  
    // Horizontal position 0..1 across the row
    final n = _deck.length;
    final t = n == 1 ? 0.5 : index / (n - 1);   // 0 (left) → 1 (right)
  
    // X coordinate across full width with side padding
    final x = pad + t * (width - 2 * pad);
  
    // Gentle arc using cosine: highest at ends, lowest at middle
    final y = baseY - curveAmp * (1 - cos(t * pi));
  
    // Slight rotation following the arc; left tilts CCW, right CW
    final rotation = (t - 0.5) * (pi / 12); // about ±15°
  
    // Hover effect
    final lift = isHover ? -14.0 : 0.0;
    final scale = isHover ? 1.04 : 1.0;
  
    // Left→Right staggered entrance
    final dur = Duration(milliseconds: 380 + (index * 40));
  
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: dur,
      curve: Curves.easeOutCubic,
      builder: (context, k, child) {
        final dx = (x - 60) - (1 - k) * 140;  // slide in from left
        final dy = (y - 90) + lift;
        return Positioned(
          left: dx,
          top: dy,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoverIndex = index),
            onExit:  (_) => setState(() => _hoverIndex = null),
            cursor: SystemMouseCursors.click,
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTap: () => _onPick(cardNo, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF546E7A), Color(0xFF263238)],
                      ),
                      border: Border.all(
                        color: selected ? Colors.orange : Colors.black54,
                        width: selected ? 3 : 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.auto_awesome, color: Colors.white70, size: 28),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPick(int faceIndex, int visualIndex) {
    setState(() {
      if (_selected.contains(faceIndex)) {
        _selected.remove(faceIndex);
        _drawnByFace.remove(faceIndex);
        return;
      }
      if (_selected.length >= widget.pickCount) return;

      // draw next from 78-card pool
      final realId = _drawPool[_drawPtr % _drawPool.length];
      _drawPtr++;
      final reversed = (Random().nextBool());
      _selected.add(faceIndex);
      _drawnByFace[faceIndex] = {"id": realId, "reversed": reversed};
    });
  }
}
