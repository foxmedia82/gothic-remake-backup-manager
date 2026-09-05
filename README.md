# Gothic 1 Remake - Permadeath Backup Manager

Automatic backup manager for Gothic 1 Remake permadeath runs.

Creates hidden backups every 5 minutes while the game is running, keeps the last 30 backups, and saves every 30th backup as a milestone.

## Features

- Backups every 5 minutes
- Only while the game is running
- Keeps the last 30 regular backups
- Every 30th backup is also saved to Milestones
- Fully hidden
- Safe restore (current saves are renamed, not deleted)

## Requirements

- Windows 10 / 11
- Gothic 1 Remake
- PowerShell (built into Windows)

## How to use

1. Download GothicBackup.ps1 and Run.bat
2. Put them in any folder
3. Double-click Run.bat
4. Choose option 1 to start backups

### Menu

1. Start backups — every 5 minutes
2. Stop backups
3. Restore a backup
4. Choose backup folder
5. Open game save folder
6. Check status
7. Exit

Default backup folder:

%USERPROFILE%\Documents\Gothic_Permadeath_Backups

Game saves folder:

%LOCALAPPDATA%\G1R\Saved\SaveGames

## Notes

- Antivirus may warn about the hidden scheduled task. This is normal.
- If you change the backup folder (option 4), run option 1 again.
- Helper files are stored in:

%LOCALAPPDATA%\GothicBackup\

## License

MIT

---

# Русская версия

Автоматический менеджер бэкапов для Gothic 1 Remake (режим permadeath).

Делает скрытые бэкапы каждые 5 минут, пока запущена игра. Хранит последние 30 обычных бэкапов и каждый 30-й сохраняет отдельно как веху (Milestone).

## Возможности

- Бэкапы каждые 5 минут
- Только когда игра запущена
- Хранит последние 30 обычных бэкапов
- Каждый 30-й бэкап дублируется в папку Milestones
- Полностью скрытый запуск
- Безопасное восстановление (текущие сейвы переименовываются, а не удаляются)

## Как пользоваться

1. Скачайте GothicBackup.ps1 и Run.bat
2. Положите в любую папку
3. Запустите Run.bat
4. Выберите пункт 1, чтобы начать бэкапы

### Меню

1. Start backups — запустить создание бэкапов каждые 5 минут
2. Stop backups — остановить создание бэкапов
3. Restore a backup — восстановить сейв из бэкапа
4. Choose backup folder — выбрать свою папку для хранения бэкапов
5. Open game save folder — открыть папку с сейвами игры (полезно убедиться, что скрипт видит папку сейвов)
6. Check status — проверить статус
7. Exit — выход

Папка бэкапов по умолчанию:

%USERPROFILE%\Documents\Gothic_Permadeath_Backups

Папка сейвов игры:

%LOCALAPPDATA%\G1R\Saved\SaveGames

## Важно

- Антивирус может ругаться на скрытую задачу планировщика — это нормально.
- Если сменили папку бэкапов (пункт 4), снова нажмите пункт 1, если до этого уже запускали бэкапы.
- Служебные файлы лежат здесь:

%LOCALAPPDATA%\GothicBackup\

## Лицензия

MIT
