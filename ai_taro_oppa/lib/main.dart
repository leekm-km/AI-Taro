import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

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
  final List<String> imagePaths;
  
  const Persona(this.id, this.nameKo, this.nameEn, this.color, this.description, this.greetings, this.imagePaths);
  
  String getRandomImage() {
    final random = Random();
    return imagePaths[random.nextInt(imagePaths.length)];
  }
}

const List<Persona> personas = [
  Persona('lucien', '루시앙 보스', 'Lucien Voss', Color(0xFF0b1c3f), '냉정하고 분석적인 점성술사', {
    'ko': '별들이 당신의 운명을 드러낼 준비가 되었소. 카드를 선택하시오.',
    'en': 'The stars are ready to reveal your fate. Choose your cards.',
    'zh': '星辰已准备好揭示你的命运。选择你的牌。',
    'th': 'ดวงดาวพร้อมที่จะเปิดเผยชะตาของคุณแล้ว เลือกไพ่ของคุณ'
  }, [
    'assets/characters/루시앙1.jpg', 'assets/characters/루시앙2.png', 'assets/characters/루시앙3.png',
    'assets/characters/루시앙4.png', 'assets/characters/루시앙5.png', 'assets/characters/루시앙-타로1.jpg',
    'assets/characters/루시앙-타로2.jpg', 'assets/characters/루시앙-타로3.jpg', 'assets/characters/루시앙-타로4.jpg',
  ]),
  Persona('isolde', '이졸데 하르트만', 'Isolde Hartmann', Color(0xFF6d235c), '시적이고 감정적인 예언자', {
    'ko': '당신의 영혼이 이끄는 대로... 카드를 선택해 주세요.',
    'en': 'As your soul guides you... please choose your cards.',
    'zh': '随心而动...请选择你的牌。',
    'th': 'ตามที่จิตวิญญาณของคุณนำทาง... โปรดเลือกไพ่ของคุณ'
  }, [
    'assets/characters/이졸데1.jpg', 'assets/characters/이졸데-타로1.jpg',
    'assets/characters/이졸데-타로2.jpg', 'assets/characters/이졸데-타로3.jpg',
  ]),
  Persona('cheongun', '청운 선인', 'Cheongun Seonin', Color(0xFF5aa7c4), '사유적이고 느긋한 도사', {
    'ko': '음양의 이치가 카드 속에 담겨 있소. 마음 가는 대로 고르시게.',
    'en': 'The principle of yin and yang resides in the cards. Choose as your heart desires.',
    'zh': '阴阳之理蕴含在牌中。随心所欲地选择吧。',
    'th': 'หลักการของหยินและหยางอยู่ในไพ่ เลือกตามที่ใจต้องการ'
  }, [
    'assets/characters/청운1.png', 'assets/characters/청운2.jpg', 'assets/characters/청운3.jpg',
    'assets/characters/청운4.png', 'assets/characters/청운5.png',
  ]),
  Persona('linhua', '린화', 'Linhua', Color(0xFFa01828), '장난스럽고 신비로운 점쟁이', {
    'ko': '후후~ 어떤 카드가 당신을 부르고 있을까요? 직감을 믿어보세요!',
    'en': 'Hehe~ Which cards are calling you? Trust your intuition!',
    'zh': '呵呵~ 哪些牌在呼唤你呢？相信你的直觉！',
    'th': 'ฮิฮิ~ ไพ่ใบไหนกำลังเรียกคุณอยู่? เชื่อสัญชาตญาณของคุณ!'
  }, [
    'assets/characters/린화1.jpg', 'assets/characters/린화2.jpg', 'assets/characters/린화3.jpg',
    'assets/characters/린화4.jpg', 'assets/characters/린화-타로1.png', 'assets/characters/린화-타로2.png',
    'assets/characters/린화-타로3.png', 'assets/characters/린화-타로4.png',
  ]),
  Persona('thimble', '팀블 오크루트', 'Thimble Oakroot', Color(0xFF6a8a3a), '따뜻하고 재치있는 자연주의자', {
    'ko': '숲의 지혜가 카드에 깃들어 있답니다. 편안하게 선택해보세요.',
    'en': 'The wisdom of the forest dwells in the cards. Choose comfortably.',
    'zh': '森林的智慧蕴藏在牌中。放松地选择吧。',
    'th': 'ภูมิปัญญาของป่าอยู่ในไพ่ เลือกอย่างสบายใจ'
  }, [
    'assets/characters/팀블1.png', 'assets/characters/팀블2.png', 'assets/characters/팀블3.png',
    'assets/characters/팀블4.png', 'assets/characters/팀블5.png', 'assets/characters/팀블-타로1.jpg',
    'assets/characters/팀블-타로2.jpg',
  ]),
];

class FortuneCategory {
  final String id;
  final Map<String, String> names;
  final IconData icon;
  final int cardCount;
  
  const FortuneCategory(this.id, this.names, this.icon, this.cardCount);
  
  String getName(String lang) => names[lang] ?? names['ko']!;
}

const List<FortuneCategory> fortuneCategories = [
  FortuneCategory('general', {'ko': '종합운', 'en': 'General Fortune', 'zh': '综合运', 'th': 'โชคชะตาทั่วไป'}, Icons.stars, 5),
  FortuneCategory('wealth', {'ko': '재물운', 'en': 'Wealth', 'zh': '财运', 'th': 'ทรัพย์สมบัติ'}, Icons.attach_money, 4),
  FortuneCategory('love', {'ko': '연애운', 'en': 'Love', 'zh': '恋爱运', 'th': 'ความรัก'}, Icons.favorite, 3),
  FortuneCategory('marriage', {'ko': '결혼운', 'en': 'Marriage', 'zh': '婚姻运', 'th': 'การแต่งงาน'}, Icons.favorite_border, 5),
  FortuneCategory('career', {'ko': '직업운', 'en': 'Career', 'zh': '事业运', 'th': 'อาชีพ'}, Icons.work, 4),
  FortuneCategory('education', {'ko': '학업운', 'en': 'Education', 'zh': '学业运', 'th': 'การศึกษา'}, Icons.school, 3),
  FortuneCategory('health', {'ko': '건강운', 'en': 'Health', 'zh': '健康运', 'th': 'สุขภาพ'}, Icons.health_and_safety, 4),
  FortuneCategory('relationship', {'ko': '인간관계운', 'en': 'Relationships', 'zh': '人际关系运', 'th': 'ความสัมพันธ์'}, Icons.people, 4),
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
      'visual_elements': card.visualElements,
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

class CharacterSelectPage extends StatefulWidget {
  final String language;

  const CharacterSelectPage({super.key, required this.language});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  final Map<String, String> _personaImages = {};

  @override
  void initState() {
    super.initState();
    for (var persona in personas) {
      _personaImages[persona.id] = persona.getRandomImage();
    }
  }

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
                    radius: 30,
                    backgroundImage: AssetImage(_personaImages[persona.id]!),
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
                          language: widget.language,
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

class FortuneCategoryPage extends StatefulWidget {
  final String language;
  final Persona persona;

  const FortuneCategoryPage({
    super.key,
    required this.language,
    required this.persona,
  });

  @override
  State<FortuneCategoryPage> createState() => _FortuneCategoryPageState();
}

class _FortuneCategoryPageState extends State<FortuneCategoryPage> {
  late String _personaImage;

  @override
  void initState() {
    super.initState();
    _personaImage = widget.persona.getRandomImage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.persona.color.withOpacity(0.05),
      appBar: AppBar(
        title: const Text('운세 카테고리 선택'),
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
                  radius: 40,
                  backgroundImage: AssetImage(_personaImage),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.persona.nameKo,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: widget.persona.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.persona.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.persona.color.withOpacity(0.8),
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
                color: widget.persona.color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.9,
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
                          builder: (_) => QuestionPage(
                            language: widget.language,
                            persona: widget.persona,
                            category: category,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            widget.persona.color.withOpacity(0.15),
                            widget.persona.color.withOpacity(0.08),
                          ],
                        ),
                        border: Border.all(
                          color: widget.persona.color.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.persona.color.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 24,
                            color: widget.persona.color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.getName(widget.language),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.persona.color,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class QuestionPage extends StatefulWidget {
  final String language;
  final Persona persona;
  final FortuneCategory category;

  const QuestionPage({
    super.key,
    required this.language,
    required this.persona,
    required this.category,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  late String _personaImage;

  @override
  void initState() {
    super.initState();
    _personaImage = widget.persona.getRandomImage();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _proceedToCardSelection() {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('질문을 입력해주세요')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardSelectionPage(
          language: widget.language,
          persona: widget.persona,
          category: widget.category,
          question: _questionController.text.trim(),
        ),
      ),
    );
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
                      radius: 50,
                      backgroundImage: AssetImage(_personaImage),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.persona.nameKo,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: widget.persona.color,
                        fontWeight: FontWeight.bold,
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
            ),
            const SizedBox(height: 24),
            Text(
              '무엇이 궁금하신가요?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '예: 이번 달 재물운이 어떨까요?\n예: 새로운 일을 시작해도 될까요?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _proceedToCardSelection,
              style: FilledButton.styleFrom(
                backgroundColor: widget.persona.color,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                '카드 선택하기',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardSelectionPage extends StatefulWidget {
  final String language;
  final Persona persona;
  final FortuneCategory category;
  final String question;

  const CardSelectionPage({
    super.key,
    required this.language,
    required this.persona,
    required this.category,
    required this.question,
  });

  @override
  State<CardSelectionPage> createState() => _CardSelectionPageState();
}

class _CardSelectionPageState extends State<CardSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Set<int> _selectedIndices = {};
  late final int _cardsToSelect;
  int? _hoveredIndex;
  late String _personaImage;
  
  List<TarotCard> _allCards = [];
  List<TarotCard> _shuffledDeck = [];
  List<TarotCard> _displayedCards = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cardsToSelect = widget.category.cardCount;
    _personaImage = widget.persona.getRandomImage();
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

  String _getSelectionGuideMessage() {
    final categoryName = widget.category.getName(widget.language);
    final count = _cardsToSelect;
    
    switch (widget.persona.id) {
      case 'lucien':
        return '별들이 $categoryName을 선택했소. $count장을 고르시오.';
      case 'isolde':
        return '$categoryName을 선택하셨군요... $count장의 카드를 골라주세요.';
      case 'cheongun':
        return '$categoryName을 선택하셨소. 마음 가는 대로 $count장을 고르시게.';
      case 'linhua':
        return '오~ $categoryName을 고르셨네요! 자, $count장을 골라볼까요?';
      case 'thimble':
        return '$categoryName을 선택하셨네요! 편안하게 $count장을 골라보세요.';
      default:
        return '$categoryName을 고르셨군요! 그럼 $count장을 고르세요!';
    }
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

  void _continueToReveal() {
    if (_selectedIndices.length == _cardsToSelect) {
      final random = Random();
      final selectedCards = _selectedIndices.map((index) {
        final card = _displayedCards[index];
        final isReversed = random.nextBool();
        return SelectedCard(card, isReversed);
      }).toList();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CardRevealPage(
            language: widget.language,
            persona: widget.persona,
            category: widget.category,
            question: widget.question,
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
                  radius: 40,
                  backgroundImage: AssetImage(_personaImage),
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
            child: Column(
              children: [
                Text(
                  _getSelectionGuideMessage(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.persona.color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_selectedIndices.length} / $_cardsToSelect',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.persona.color,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = 80.0;
                  final cardHeight = 120.0;
                  final totalCards = _displayedCards.length;
                  final maxAngle = 45.0;
                  final angleStep = (maxAngle * 2) / (totalCards - 1);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(totalCards, (index) {
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

                      final angle = -maxAngle + (index * angleStep);
                      final radians = angle * (3.14159 / 180);
                      final radius = constraints.maxWidth * 0.42;
                      
                      final x = (constraints.maxWidth / 2) + (radius * sin(radians)) - (cardWidth / 2);
                      final y = constraints.maxHeight - (radius * cos(radians)) - (cardHeight / 2) + 80;

                      final isHovered = _hoveredIndex == index;
                      final isSelected = _selectedIndices.contains(index);

                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final scale = animation.value;
                          final opacity = animation.value;

                          return Positioned(
                            left: x,
                            top: y,
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Transform.rotate(
                          angle: radians,
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = index),
                            onExit: (_) => setState(() => _hoveredIndex = null),
                            child: GestureDetector(
                              onTap: () => _toggleCard(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: cardWidth,
                                height: cardHeight,
                                transform: Matrix4.identity()
                                  ..translate(0.0, isHovered && !isSelected ? -15.0 : 0.0),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? widget.persona.color
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.persona.color,
                                    width: isSelected ? 3 : (isHovered ? 2 : 1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? widget.persona.color.withOpacity(0.5)
                                          : (isHovered
                                              ? widget.persona.color.withOpacity(0.3)
                                              : Colors.black.withOpacity(0.1)),
                                      blurRadius: isSelected ? 12 : (isHovered ? 10 : 4),
                                      offset: const Offset(0, 4),
                                      spreadRadius: isSelected ? 2 : 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: isSelected
                                        ? Colors.white
                                        : widget.persona.color,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selectedIndices.length == _cardsToSelect
                  ? _continueToReveal
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

class CardRevealPage extends StatefulWidget {
  final String language;
  final Persona persona;
  final FortuneCategory category;
  final String question;
  final List<SelectedCard> selectedCards;

  const CardRevealPage({
    super.key,
    required this.language,
    required this.persona,
    required this.category,
    required this.question,
    required this.selectedCards,
  });

  @override
  State<CardRevealPage> createState() => _CardRevealPageState();
}

class _CardRevealPageState extends State<CardRevealPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentCardIndex = 0;
  bool _allRevealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _startRevealSequence();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRevealSequence() async {
    for (int i = 0; i < widget.selectedCards.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _currentCardIndex = i;
      });
      _controller.reset();
      await _controller.forward();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    setState(() {
      _allRevealed = true;
    });
  }

  void _continueToAd() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdPlaceholderPage(
          language: widget.language,
          persona: widget.persona,
          category: widget.category,
          question: widget.question,
          selectedCards: widget.selectedCards,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.persona.color.withOpacity(0.05),
      appBar: AppBar(
        title: const Text('카드 공개'),
        backgroundColor: widget.persona.color,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '선택한 카드를 공개합니다...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.persona.color,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ...List.generate(widget.selectedCards.length, (index) {
                      final selectedCard = widget.selectedCards[index];
                      final isRevealing = _currentCardIndex == index;
                      final isRevealed = index <= _currentCardIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isRevealed ? 1.0 : 0.3,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final rotationAngle = isRevealing
                                  ? _controller.value * 3.14159
                                  : (isRevealed ? 3.14159 : 0.0);
                              
                              final showFront = rotationAngle > 3.14159 / 2;
                              
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(rotationAngle),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: showFront
                                        ? widget.persona.color
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationY(showFront ? 3.14159 : 0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: showFront ? Colors.white : Colors.white30,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              showFront ? '${index + 1}' : '?',
                                              style: TextStyle(
                                                color: showFront ? widget.persona.color : Colors.grey.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                showFront
                                                    ? selectedCard.card.koreanName
                                                    : '???',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (showFront)
                                                Text(
                                                  selectedCard.isReversed
                                                      ? '역방향'
                                                      : '정방향',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                            ],
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
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          if (_allRevealed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _continueToAd,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.persona.color,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '계속하기',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AdPlaceholderPage extends StatefulWidget {
  final String language;
  final Persona persona;
  final FortuneCategory category;
  final String question;
  final List<SelectedCard> selectedCards;

  const AdPlaceholderPage({
    super.key,
    required this.language,
    required this.persona,
    required this.category,
    required this.question,
    required this.selectedCards,
  });

  @override
  State<AdPlaceholderPage> createState() => _AdPlaceholderPageState();
}

class _AdPlaceholderPageState extends State<AdPlaceholderPage> {
  int _countdown = 3;
  bool _isLoading = true;
  bool _canSkip = false;
  String? _reading;
  String? _character;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getTarotReading();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown > 0) {
          _startCountdown();
        } else {
          setState(() {
            _canSkip = true;
          });
          if (!_isLoading) {
            _navigateToResult();
          }
        }
      }
    });
  }

  Future<void> _getTarotReading() async {
    try {
      final response = await http.post(
        Uri.parse('/api/tarot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'character': widget.persona.id,
          'language': widget.language,
          'category': widget.category.id,
          'question': widget.question,
          'selected_cards': widget.selectedCards.map((sc) => sc.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _reading = data['reading'] ?? '결과를 가져올 수 없습니다';
            _character = data['character'] ?? widget.persona.nameKo;
            _isLoading = false;
          });
          if (_canSkip) {
            _navigateToResult();
          }
        }
      } else {
        throw Exception('API 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToResult() {
    if (_reading != null && _character != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultPage(
            reading: _reading!,
            character: _character!,
            category: widget.category,
            language: widget.language,
            persona: widget.persona,
            question: widget.question,
            selectedCards: widget.selectedCards,
          ),
        ),
      );
    } else if (_errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  void _skipAd() {
    if (_canSkip && !_isLoading) {
      _navigateToResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              '광고 플레이스홀더',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Continue to see your reading',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                Text(
                  _countdown > 0 ? '$_countdown' : 'Ready!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white70, strokeWidth: 3)
                else if (_canSkip)
                  TextButton(
                    onPressed: _skipAd,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  final String reading;
  final String character;
  final FortuneCategory category;
  final String language;
  final Persona persona;
  final String question;
  final List<SelectedCard> selectedCards;
  final List<Map<String, String>>? conversationHistory;

  const ResultPage({
    super.key,
    required this.reading,
    required this.character,
    required this.category,
    required this.language,
    required this.persona,
    required this.question,
    required this.selectedCards,
    this.conversationHistory,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TextEditingController _followUpController = TextEditingController();
  late List<Map<String, String>> _conversation;
  bool _showFollowUpInput = false;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversationHistory ?? [];
    _conversation.add({
      'role': 'user',
      'content': widget.question,
    });
    _conversation.add({
      'role': 'assistant',
      'content': widget.reading,
    });
    
    // conversationHistory가 있으면 이미 추가 질문을 한 상태이므로 입력창 표시
    if (widget.conversationHistory != null && widget.conversationHistory!.length > 2) {
      _showFollowUpInput = true;
    }
  }

  @override
  void dispose() {
    _followUpController.dispose();
    super.dispose();
  }

  void _openFollowUpInput() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdOnlyPage(
          persona: widget.persona,
        ),
      ),
    );
    
    if (mounted) {
      setState(() {
        _showFollowUpInput = true;
      });
    }
  }

  void _askFollowUpQuestion() {
    final followUpQuestion = _followUpController.text.trim();
    if (followUpQuestion.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FollowUpAdPage(
          language: widget.language,
          persona: widget.persona,
          category: widget.category,
          question: followUpQuestion,
          selectedCards: widget.selectedCards,
          conversationHistory: List.from(_conversation),
        ),
      ),
    );
  }

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
                          widget.character,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(widget.category.icon, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          widget.category.getName(widget.language),
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
                      '질문',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.question,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (!_showFollowUpInput) ...[
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
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: MarkdownBody(
                  data: widget.reading,
                  styleSheet: MarkdownStyleSheet(
                    p: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    strong: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                    em: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_showFollowUpInput)
              FilledButton.icon(
                onPressed: _openFollowUpInput,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('광고보고 추가질문하기'),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.persona.color,
                  minimumSize: const Size(double.infinity, 50),
                ),
              )
            else
              Card(
                color: widget.persona.color.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _followUpController,
                    decoration: InputDecoration(
                      hintText: '궁금한 점을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: widget.persona.color),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: widget.persona.color, width: 2),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _askFollowUpQuestion,
                        icon: Icon(Icons.send, color: widget.persona.color),
                      ),
                    ),
                    maxLines: 3,
                    onSubmitted: (_) => _askFollowUpQuestion(),
                  ),
                ),
              ),
            const SizedBox(height: 12),
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

class FollowUpAdPage extends StatefulWidget {
  final String language;
  final Persona persona;
  final FortuneCategory category;
  final String question;
  final List<SelectedCard> selectedCards;
  final List<Map<String, String>> conversationHistory;

  const FollowUpAdPage({
    super.key,
    required this.language,
    required this.persona,
    required this.category,
    required this.question,
    required this.selectedCards,
    required this.conversationHistory,
  });

  @override
  State<FollowUpAdPage> createState() => _FollowUpAdPageState();
}

class _FollowUpAdPageState extends State<FollowUpAdPage> {
  int _countdown = 3;
  bool _isLoading = true;
  bool _canSkip = false;
  String? _reading;
  String? _character;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getFollowUpReading();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown > 0) {
          _startCountdown();
        } else {
          setState(() {
            _canSkip = true;
          });
          if (!_isLoading) {
            _navigateToResult();
          }
        }
      }
    });
  }

  Future<void> _getFollowUpReading() async {
    try {
      final response = await http.post(
        Uri.parse('/api/tarot/followup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'character': widget.persona.id,
          'language': widget.language,
          'category': widget.category.id,
          'question': widget.question,
          'selected_cards': widget.selectedCards.map((sc) => sc.toJson()).toList(),
          'conversation_history': widget.conversationHistory,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _reading = data['reading'] ?? '결과를 가져올 수 없습니다';
            _character = data['character'] ?? widget.persona.nameKo;
            _isLoading = false;
          });
          if (_canSkip) {
            _navigateToResult();
          }
        }
      } else {
        throw Exception('API 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToResult() {
    if (_reading != null && _character != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultPage(
            reading: _reading!,
            character: _character!,
            category: widget.category,
            language: widget.language,
            persona: widget.persona,
            question: widget.question,
            selectedCards: widget.selectedCards,
            conversationHistory: widget.conversationHistory,
          ),
        ),
      );
    } else if (_errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  void _skipAd() {
    if (_canSkip && !_isLoading) {
      _navigateToResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              '광고 플레이스홀더',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Continue to see your reading',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                Text(
                  _countdown > 0 ? '$_countdown' : 'Ready!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white70, strokeWidth: 3)
                else if (_canSkip)
                  TextButton(
                    onPressed: _skipAd,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdOnlyPage extends StatefulWidget {
  final Persona persona;

  const AdOnlyPage({
    super.key,
    required this.persona,
  });

  @override
  State<AdOnlyPage> createState() => _AdOnlyPageState();
}

class _AdOnlyPageState extends State<AdOnlyPage> {
  int _countdown = 3;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown > 0) {
          _startCountdown();
        } else {
          setState(() {
            _canSkip = true;
          });
        }
      }
    });
  }

  void _skipAd() {
    if (_canSkip) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.persona.color,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              '광고 플레이스홀더',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Continue to ask follow-up questions',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                Text(
                  _countdown > 0 ? '$_countdown' : 'Ready!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (_canSkip)
                  TextButton(
                    onPressed: _skipAd,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
