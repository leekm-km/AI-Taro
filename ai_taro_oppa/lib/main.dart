import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class Persona {
  final String id;
  final String nameKo;
  final String nameEn;
  final Color color;
  final String description;
  final Map<String, String> greetings;
  
  const Persona(this.id, this.nameKo, this.nameEn, this.color, this.description, this.greetings);
}

const List<Persona> personas = [
  Persona('lucien', '루시앙 보스', 'Lucien Voss', Color(0xFF0b1c3f), '냉정하고 분석적인 점성술사', {
    'ko': '별들이 당신의 운명을 드러낼 준비가 되었소. 카드를 선택하시오.',
    'en': 'The stars are ready to reveal your fate. Choose your cards.',
    'zh': '星辰已准备好揭示你的命运。选择你的牌。',
    'th': 'ดวงดาวพร้อมที่จะเปิดเผยชะตาของคุณแล้ว เลือกไพ่ของคุณ'
  }),
  Persona('isolde', '이졸데 하르트만', 'Isolde Hartmann', Color(0xFF6d235c), '시적이고 감정적인 예언자', {
    'ko': '당신의 영혼이 이끄는 대로... 카드를 선택해 주세요.',
    'en': 'As your soul guides you... please choose your cards.',
    'zh': '随心而动...请选择你的牌。',
    'th': 'ตามที่จิตวิญญาณของคุณนำทาง... โปรดเลือกไพ่ของคุณ'
  }),
  Persona('cheongun', '청운 선인', 'Cheongun Seonin', Color(0xFF5aa7c4), '사유적이고 느긋한 도사', {
    'ko': '음양의 이치가 카드 속에 담겨 있소. 마음 가는 대로 고르시게.',
    'en': 'The principle of yin and yang resides in the cards. Choose as your heart desires.',
    'zh': '阴阳之理蕴含在牌中。随心所欲地选择吧。',
    'th': 'หลักการของหยินและหยางอยู่ในไพ่ เลือกตามที่ใจต้องการ'
  }),
  Persona('linhua', '린화', 'Linhua', Color(0xFFa01828), '장난스럽고 신비로운 점쟁이', {
    'ko': '후후~ 어떤 카드가 당신을 부르고 있을까요? 직감을 믿어보세요!',
    'en': 'Hehe~ Which cards are calling you? Trust your intuition!',
    'zh': '呵呵~ 哪些牌在呼唤你呢？相信你的直觉！',
    'th': 'ฮิฮิ~ ไพ่ใบไหนกำลังเรียกคุณอยู่? เชื่อสัญชาตญาณของคุณ!'
  }),
  Persona('thimble', '팀블 오크루트', 'Thimble Oakroot', Color(0xFF6a8a3a), '따뜻하고 재치있는 자연주의자', {
    'ko': '숲의 지혜가 카드에 깃들어 있답니다. 편안하게 선택해보세요.',
    'en': 'The wisdom of the forest dwells in the cards. Choose comfortably.',
    'zh': '森林的智慧蕴藏在牌中。放松地选择吧。',
    'th': 'ภูมิปัญญาของป่าอยู่ในไพ่ เลือกอย่างสบายใจ'
  }),
];

class FortuneCategory {
  final String id;
  final Map<String, String> names;
  final IconData icon;
  
  const FortuneCategory(this.id, this.names, this.icon);
  
  String getName(String lang) => names[lang] ?? names['ko']!;
}

const List<FortuneCategory> fortuneCategories = [
  FortuneCategory('general', {'ko': '종합운', 'en': 'General Fortune', 'zh': '综合运', 'th': 'โชคชะตาทั่วไป'}, Icons.stars),
  FortuneCategory('wealth', {'ko': '재물운', 'en': 'Wealth', 'zh': '财运', 'th': 'ทรัพย์สมบัติ'}, Icons.attach_money),
  FortuneCategory('love', {'ko': '연애운', 'en': 'Love', 'zh': '恋爱运', 'th': 'ความรัก'}, Icons.favorite),
  FortuneCategory('marriage', {'ko': '결혼운', 'en': 'Marriage', 'zh': '婚姻运', 'th': 'การแต่งงาน'}, Icons.favorite_border),
  FortuneCategory('career', {'ko': '직업운', 'en': 'Career', 'zh': '事业运', 'th': 'อาชีพ'}, Icons.work),
  FortuneCategory('education', {'ko': '학업운', 'en': 'Education', 'zh': '学业运', 'th': 'การศึกษา'}, Icons.school),
  FortuneCategory('health', {'ko': '건강운', 'en': 'Health', 'zh': '健康运', 'th': 'สุขภาพ'}, Icons.favorite_border),
];

class TarotCard {
  final String id;
  final String arcanaType;
  final int? number;
  final String name;
  final String koreanName;
  final String? suit;
  final String? rank;
  final String keywords;
  final String visualElements;
  final String uprightMeaning;
  final String reversedMeaning;
  
  TarotCard({
    required this.id,
    required this.arcanaType,
    this.number,
    required this.name,
    required this.koreanName,
    this.suit,
    this.rank,
    required this.keywords,
    required this.visualElements,
    required this.uprightMeaning,
    required this.reversedMeaning,
  });
  
  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      id: json['id'],
      arcanaType: json['arcana_type'],
      number: json['number'],
      name: json['name'],
      koreanName: json['korean_name'],
      suit: json['suit'],
      rank: json['rank'],
      keywords: json['keywords'],
      visualElements: json['visual_elements'],
      uprightMeaning: json['upright_meaning'],
      reversedMeaning: json['reversed_meaning'],
    );
  }
}

class SelectedCard {
  final TarotCard card;
  final bool isReversed;
  
  SelectedCard(this.card, this.isReversed);
  
  Map<String, dynamic> toJson() {
    return {
      'id': card.id,
      'name': card.name,
      'korean_name': card.koreanName,
      'orientation': isReversed ? 'reversed' : 'upright',
      'meaning': isReversed ? card.reversedMeaning : card.uprightMeaning,
      'keywords': card.keywords,
    };
  }
}

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
                        builder: (_) => FortuneCategoryPage(
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

class FortuneCategoryPage extends StatelessWidget {
  final String language;
  final Persona persona;

  const FortuneCategoryPage({
    super.key,
    required this.language,
    required this.persona,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: persona.color.withOpacity(0.05),
      appBar: AppBar(
        title: const Text('운세 카테고리 선택'),
        backgroundColor: persona.color,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: persona.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: persona.color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: persona.color,
                  child: Text(
                    persona.nameKo[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  persona.nameKo,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: persona.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  persona.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: persona.color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '어떤 운세를 보시겠습니까?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: persona.color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: fortuneCategories.length,
              itemBuilder: (context, index) {
                final category = fortuneCategories[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CardSelectionPage(
                          language: language,
                          persona: persona,
                          category: category,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            persona.color.withOpacity(0.1),
                            persona.color.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category.icon,
                            size: 48,
                            color: persona.color,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category.getName(language),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: persona.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CardSelectionPage extends StatefulWidget {
  final String language;
  final Persona persona;
  final FortuneCategory category;

  const CardSelectionPage({
    super.key,
    required this.language,
    required this.persona,
    required this.category,
  });

  @override
  State<CardSelectionPage> createState() => _CardSelectionPageState();
}

class _CardSelectionPageState extends State<CardSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Set<int> _selectedIndices = {};
  final int _cardsToSelect = 3;
  
  List<TarotCard> _allCards = [];
  List<TarotCard> _shuffledDeck = [];
  List<TarotCard> _displayedCards = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadTarotCards();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTarotCards() async {
    try {
      final jsonString = await rootBundle.loadString('assets/tarot_cards.json');
      final jsonData = jsonDecode(jsonString);
      final cardsList = jsonData['cards'] as List;
      
      setState(() {
        _allCards = cardsList.map((card) => TarotCard.fromJson(card)).toList();
        _shuffledDeck = List.from(_allCards)..shuffle(Random());
        _displayedCards = _shuffledDeck.take(16).toList();
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'JSON 로드 실패: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleCard(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else if (_selectedIndices.length < _cardsToSelect) {
        _selectedIndices.add(index);
      }
    });
  }

  void _continueToQuestion() {
    if (_selectedIndices.length == _cardsToSelect) {
      final random = Random();
      final selectedCards = _selectedIndices.map((index) {
        final card = _displayedCards[index];
        final isReversed = random.nextBool();
        return SelectedCard(card, isReversed);
      }).toList();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionPage(
            language: widget.language,
            persona: widget.persona,
            category: widget.category,
            selectedCards: selectedCards,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = widget.persona.greetings[widget.language] ?? 
                     widget.persona.greetings['ko']!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: widget.persona.color.withOpacity(0.05),
        appBar: AppBar(
          title: Text(widget.persona.nameKo),
          backgroundColor: widget.persona.color,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: widget.persona.color.withOpacity(0.05),
        appBar: AppBar(
          title: Text(widget.persona.nameKo),
          backgroundColor: widget.persona.color,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.persona.color.withOpacity(0.05),
      appBar: AppBar(
        title: Text(widget.persona.nameKo),
        backgroundColor: widget.persona.color,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.persona.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.persona.color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: widget.persona.color,
                  child: Text(
                    widget.persona.nameKo[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  greeting,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.persona.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.category.icon,
                      color: widget.persona.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.category.getName(widget.language),
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.persona.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_selectedIndices.length / $_cardsToSelect 장 선택됨',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.persona.color,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _displayedCards.length,
              itemBuilder: (context, index) {
                final delay = index * 0.04;
                final intervalEnd = (delay + 0.3).clamp(0.0, 1.0);
                final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      delay,
                      intervalEnd,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                );

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final scale = animation.value;
                    final opacity = animation.value;

                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () => _toggleCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: _selectedIndices.contains(index)
                            ? widget.persona.color
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.persona.color,
                          width: _selectedIndices.contains(index) ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _selectedIndices.contains(index)
                                ? widget.persona.color.withOpacity(0.4)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: _selectedIndices.contains(index) ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: _selectedIndices.contains(index)
                              ? Colors.white
                              : widget.persona.color,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selectedIndices.length == _cardsToSelect
                  ? _continueToQuestion
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: widget.persona.color,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                '선택 완료',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionPage extends StatefulWidget {
  final String language;
  final Persona persona;
  final FortuneCategory category;
  final List<SelectedCard> selectedCards;

  const QuestionPage({
    super.key,
    required this.language,
    required this.persona,
    required this.category,
    required this.selectedCards,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
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
      final response = await http.post(
        Uri.parse('/api/tarot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'character': widget.persona.id,
          'language': widget.language,
          'category': widget.category.id,
          'question': _questionController.text.trim(),
          'selected_cards': widget.selectedCards.map((sc) => sc.toJson()).toList(),
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
                category: widget.category,
                language: widget.language,
                selectedCards: widget.selectedCards,
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.category.icon,
                          color: widget.persona.color,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.category.getName(widget.language),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: widget.persona.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              color: widget.persona.color.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택된 카드',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.persona.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.selectedCards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final selectedCard = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: widget.persona.color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedCard.card.koreanName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    selectedCard.isReversed ? '역방향' : '정방향',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: selectedCard.isReversed 
                                          ? Colors.red[700]
                                          : Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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

class ResultPage extends StatelessWidget {
  final String reading;
  final String character;
  final FortuneCategory category;
  final String language;
  final List<SelectedCard> selectedCards;

  const ResultPage({
    super.key,
    required this.reading,
    required this.character,
    required this.category,
    required this.language,
    required this.selectedCards,
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
                        Icon(category.icon, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          category.getName(language),
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
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택된 카드',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...selectedCards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final selectedCard = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.purple,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedCard.card.koreanName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${selectedCard.isReversed ? '역방향' : '정방향'} - ${selectedCard.card.keywords}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: selectedCard.isReversed 
                                          ? Colors.red[700]
                                          : Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
