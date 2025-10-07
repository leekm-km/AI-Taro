import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

// 언어 정의
class Language {
  final String code;
  final String label;
  
  const Language(this.code, this.label);
}

const List<Language> languages = [
  Language('ko', '한국어'),
  Language('en', 'English'),
  Language('zh', '中文'),
  Language('th', 'ไทย'),
];

// 캐릭터 정의
class Persona {
  final String id;
  final String nameKo;
  final String nameEn;
  final Color color;
  final String description;
  
  const Persona(this.id, this.nameKo, this.nameEn, this.color, this.description);
}

const List<Persona> personas = [
  Persona('lucien', '루시앙 보스', 'Lucien Voss', Color(0xFF0b1c3f), '냉정하고 분석적인 점성술사'),
  Persona('isolde', '이졸데 하르트만', 'Isolde Hartmann', Color(0xFF6d235c), '시적이고 감정적인 예언자'),
  Persona('cheongun', '청운 선인', 'Cheongun Seonin', Color(0xFF5aa7c4), '사유적이고 느긋한 도사'),
  Persona('linhua', '린화', 'Linhua', Color(0xFFa01828), '장난스럽고 신비로운 점쟁이'),
  Persona('thimble', '팀블 오크루트', 'Thimble Oakroot', Color(0xFF6a8a3a), '따뜻하고 재치있는 자연주의자'),
];

// 카테고리 정의
const List<String> categories = [
  '종합운', '재물운', '연애운', '결혼운', '직업운', '학업운', '건강운'
];

/// 1. 언어 선택 페이지
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
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: languages.map((lang) {
              return FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CharacterSelectPage(language: lang.code),
                    ),
                  );
                },
                child: Text(lang.label),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// 2. 캐릭터 선택 페이지
class CharacterSelectPage extends StatelessWidget {
  final String language;

  const CharacterSelectPage({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('캐릭터를 선택하세요')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: personas.length,
            itemBuilder: (context, index) {
              final persona = personas[index];
              return Card(
                color: persona.color.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: persona.color,
                    child: Text(
                      persona.nameKo[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    persona.nameKo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: persona.color,
                    ),
                  ),
                  subtitle: Text(persona.description),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuestionPage(
                          language: language,
                          persona: persona,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 3. 질문 및 카테고리 입력 페이지
class QuestionPage extends StatefulWidget {
  final String language;
  final Persona persona;

  const QuestionPage({
    super.key,
    required this.language,
    required this.persona,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String _selectedCategory = categories[0];
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _getTarotReading() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('질문을 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 백엔드 API 호출 (상대 경로 사용)
      final response = await http.post(
        Uri.parse('/api/tarot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'character': widget.persona.id,
          'language': widget.language,
          'category': _selectedCategory,
          'question': _questionController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResultPage(
                reading: data['reading'] ?? '결과를 가져올 수 없습니다',
                character: data['character'] ?? widget.persona.nameKo,
                category: data['category'] ?? _selectedCategory,
              ),
            ),
          );
        }
      } else {
        throw Exception('API 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.persona.nameKo}에게 물어보기'),
        backgroundColor: widget.persona.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 캐릭터 정보
            Card(
              color: widget.persona.color.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: widget.persona.color,
                      child: Text(
                        widget.persona.nameKo[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.persona.nameKo,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: widget.persona.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.persona.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 카테고리 선택
            Text('운세 카테고리', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: widget.persona.color.withOpacity(0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 질문 입력
            Text('질문을 입력하세요', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '예: 올해 나의 재물운은 어떨까요?',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),

            // 제출 버튼
            FilledButton.icon(
              onPressed: _isLoading ? null : _getTarotReading,
              style: FilledButton.styleFrom(
                backgroundColor: widget.persona.color,
                padding: const EdgeInsets.all(16),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? '리딩 중...' : '타로 리딩 받기'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4. 결과 표시 페이지
class ResultPage extends StatelessWidget {
  final String reading;
  final String character;
  final String category;

  const ResultPage({
    super.key,
    required this.reading,
    required this.character,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('타로 리딩 결과'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          character,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  reading,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('처음으로'),
            ),
          ],
        ),
      ),
    );
  }
}
