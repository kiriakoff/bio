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

class Strings {
  final String name;
  final String role;
  final String company;
  final String city;
  final String githubButton;
  final String writeMeButton;
  final String aboutTitle;
  final String aboutLead;
  final List<String> aboutItems;
  final String stackTitle;
  final List<(String, List<String>)> stack;
  final String nowTitle;
  final List<(String, String, String)> now;
  final String email;

  const Strings({
    required this.name,
    required this.role,
    required this.company,
    required this.city,
    required this.githubButton,
    required this.writeMeButton,
    required this.aboutTitle,
    required this.aboutLead,
    required this.aboutItems,
    required this.stackTitle,
    required this.stack,
    required this.nowTitle,
    required this.now,
    required this.email,
  });

  String get ageLabel {
    final n = Content.age;
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

  String copyright(int year) => '© $year $name';

  static const Strings ru = Strings(
    name: 'Фёдор Кирьяков',
    role: 'SRE / SDE',
    company: 'Т-Банк (ТЦР)',
    city: 'Самара',
    githubButton: 'GitHub',
    writeMeButton: 'Написать мне',
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
      ('Инфраструктура', ['Linux', 'Docker', 'ANsible', 'Nginx', 'Git (верчу ремоуты как твою мамку)']),
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
        '«Системный анализ и математическая статистика»»',
      ),
    ],
    email: 'kiriakov.f.m@gmail.com',
  );

  // static const Strings en = Strings(...);
}
