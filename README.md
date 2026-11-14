# Virtual Home Screen

Виртуальный рабочий стол iOS с физикой (тряска телефона).

### Возможности
- Статичный статус-бар (время, Wi-Fi, батарея)
- Белые иконки + Dock
- Резко тряхнул → иконки падают и реагируют на наклон
- Ещё раз тряхнул → возвращаются в сетку

---

## Сборка через GitHub Actions (без своего Mac)

### 1. Создай репозиторий на GitHub
- Зайди на github.com → New repository
- Назови, например, `VirtualHomeScreen`
- **Не** добавляй README, .gitignore и лицензию (они уже есть)

### 2. Загрузи файлы

Самый простой способ — через сайт GitHub:

1. Открой созданный пустой репозиторий
2. Нажми **uploading an existing file**
3. Перетащи **все** файлы и папки из этого архива
4. Commit changes

Или через терминал (если есть git):

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/ТВОЙ_НИК/VirtualHomeScreen.git
git push -u origin main
```

### 3. Запусти сборку

1. Зайди в репозиторий → вкладка **Actions**
2. Выбери workflow **Build IPA**
3. Нажми **Run workflow** → Run workflow

Подожди 2–4 минуты.

### 4. Скачай результат

После завершения сборки внизу страницы появится **Artifacts**.  
Скачай `VirtualHomeScreen-Archive`.

Внутри будет `.xcarchive`.

---

## Важные ограничения прямо сейчас

Текущий workflow собирает **без подписи** (`CODE_SIGNING_ALLOWED=NO`).

Это значит:
- Ты получишь `.xcarchive`
- Но **готовый `.ipa` для установки на телефон** из него сразу не сделать без сертификатов.

Чтобы получить нормальный устанавливаемый IPA, нужны:
- Apple ID (хотя бы бесплатный)
- Сертификат + Provisioning Profile
- Добавить их в GitHub Secrets

---

## Что делать дальше (когда захочешь ставить на телефон)

Есть 3 пути:

**A. Самый простой для начала**  
Попросить кого-то с Mac один раз открыть проект, подписать через свой Apple ID и скинуть тебе IPA (будет жить 7 дней).

**B. Через AltStore / Sideloadly + свой Apple ID**  
Нужен IPA, подписанный твоим Apple ID.

**C. Полноценная подпись в GitHub Actions**  
Нужно добавить сертификаты в Secrets (я могу потом дописать workflow под это).

---

## Структура проекта

```
VirtualHomeScreen/
├── .github/workflows/build.yml   ← сборка
├── VirtualHomeScreen/
│   ├── GameScene.swift           ← вся логика
│   ├── ContentView.swift
│   ├── VirtualHomeScreenApp.swift
│   └── Info.plist
├── project.yml                   ← описание проекта для XcodeGen
├── .gitignore
└── README.md
```

Почти всё, что ты будешь менять — это файл `GameScene.swift`.
