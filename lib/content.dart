abstract final class Content {
  static const String githubHandle = 'kiriakoff';
  static const String githubUrl = 'https://github.com/kiriakoff';
  static const String siteUrl = 'https://kiria-f.ru';
  static const String contactTg = 'tg://resolve?domain=kiria_f';

  static int get age {
    const birthYear = 2001;
    const birthMonth = 10;
    const birthDay = 30;
    final now = DateTime.now();
    var age = now.year - birthYear;
    if (now.month < birthMonth || (now.month == birthMonth && now.day < birthDay)) {
      age--;
    }
    return age;
  }

  static int get currentYear => DateTime.now().year;
}

String _ageLabelRu(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  final String word;
  if (mod10 == 1 && mod100 != 11) {
    word = 'год';
  } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    word = 'года';
  } else {
    word = 'лет';
  }
  return '$n $word';
}

String _ageLabelEn(int n) => n == 1 ? '1 year old' : '$n years old';

class Strings {
  final String name;
  final String role;
  final String company;
  final String city;
  final String githubButton;
  final String tgButton;
  final String aboutTitle;
  final String aboutLead;
  final List<String> aboutItems;
  final String stackTitle;
  final List<(String, List<String>)> stack;
  final String nowTitle;
  final List<(String, String, String)> now;
  final String email;
  final String narrowWindow;
  final String Function(int age) ageLabelBuilder;

  const Strings({
    required this.name,
    required this.role,
    required this.company,
    required this.city,
    required this.githubButton,
    required this.tgButton,
    required this.aboutTitle,
    required this.aboutLead,
    required this.aboutItems,
    required this.stackTitle,
    required this.stack,
    required this.nowTitle,
    required this.now,
    required this.email,
    required this.narrowWindow,
    required this.ageLabelBuilder,
  });

  String get ageLabel => ageLabelBuilder(Content.age);

  String copyright(int year) => '© $year $name';

  static const Strings ru = Strings(
    name: 'Фёдор Кирьяков',
    role: 'SRE / SDE',
    company: 'Т-Банк (ТЦР)',
    city: 'Самара',
    githubButton: 'GitHub',
    tgButton: 'Телеграм',
    aboutTitle: 'О себе',
    aboutLead: 'Технарь и душнила.',
    aboutItems: [
      'Тут нереально напишу про то, как я автоматизирую всё автоматизируемое. А неавтоматизируемое привожу к автоматизируемости и автоматизирую.',
      'Ещё напишу про то, какой нереальный конфиг Nvim сочинил (ну когда сочиню). Пока могу максимум конфигом Kitty похвастаться.',
      'Ещё фотку пресака скину, чтобы вообще всю целевую закрыть.',
    ],
    stackTitle: 'Стек',
    stack: [
      ('Языки', ['RU', 'EN', 'Rust', 'Python', 'C#']),
      ('Инфраструктура', ['Linux', 'Docker', 'Ansible', 'Nginx', 'Git (верчу ремоуты как твою мамку)']),
      ('К слову', ['Arch Linux']),
    ],
    nowTitle: 'Сейчас',
    now: [
      (
        'с 2023',
        'SRE в Т-Банке (ТЦР)',
        'Внутренняя система облачного хранения данных: автоматизация, интеграции и надёжность',
      ),
      (
        'с 2025',
        'Аспирантура в СамГТУ',
        '«Системный анализ и математическая статистика»',
      ),
    ],
    email: 'kiriakov.f.m@gmail.com',
    narrowWindow: 'Сделай пошире',
    ageLabelBuilder: _ageLabelRu,
  );

  static const Strings en = Strings(
    name: 'Fedor Kiriakov',
    role: 'SRE / SDE',
    company: 'T-Bank (TCR)',
    city: 'Samara',
    githubButton: 'GitHub',
    tgButton: 'Telegram',
    aboutTitle: 'About',
    aboutLead: 'A techie and a pedant.',
    aboutItems: [
      'Someday I will write here about how I automate everything automatable. And whatever is not automatable, I make automatable — and then automate it.',
      'I will also write about the incredible Nvim config I have come up with (well, once I actually come up with it). So far the best I can show off is my Kitty config.',
      'And I will throw in a photo of my gaming rig, just to win over the target audience completely.',
    ],
    stackTitle: 'Stack',
    stack: [
      ('Languages', ['RU', 'EN', 'Rust', 'Python', 'C#']),
      ('Infrastructure', ['Linux', 'Docker', 'Ansible', 'Nginx', 'Git (I twist remotes like your mom)']),
      ('btw', ['Arch Linux']),
    ],
    nowTitle: 'Now',
    now: [
      (
        'since 2023',
        'SRE at T-Bank (TCR)',
        'Internal cloud data storage system: automation, integrations and reliability',
      ),
      (
        'since 2025',
        'PhD program at SamSTU',
        '“System analysis and mathematical statistics”',
      ),
    ],
    email: 'kiriakov.f.m@gmail.com',
    narrowWindow: 'Make it wider',
    ageLabelBuilder: _ageLabelEn,
  );
}
