Gothic 1 Remake — Permadeath Backup Manager
Неофициальный инструмент, который автоматически копирует ваши сохранения, пока запущена игра. Он помогает не потерять прогресс при вылетах, зависаниях или повреждении файлов сохранения. Особенно полезен в режиме «Необратимая смерть» (Permadeath).
Unofficial tool that automatically copies your saves while the game is running. It helps prevent progress loss due to crashes, freezes, or corrupted save files. Especially useful in Permadeath mode.
Внимание: Это неофициальный инструмент, он никак не связан с разработчиками игры. Используйте на свой страх и риск.
Warning: This is an unofficial tool and is not affiliated with the game developers. Use at your own risk.
⚙️ Как это работает / How it works
Скрипт использует встроенный «Планировщик заданий» (Task Scheduler) Windows для выполнения фоновых проверок каждые 5 минут.
The script uses the built-in Windows Task Scheduler to run background checks every 5 minutes.
Программа не должна постоянно висеть открытой. Вы запускаете меню один раз, включаете бэкапы, и можете закрывать окно.
The program does not need to stay open. You launch the menu once, start the backups, and you can close the window.
Во время работы планировщик тихо запускает VBS-скрипт, который в скрытом режиме (без мелькания окон) проверяет, запущен ли процесс игры (G1R или Gothic). Если игра работает — папка с сохранениями копируется. Если игра выключена — скрипт просто завершает работу.
During operation, the scheduler quietly runs a VBS script that silently (without window flickering) checks if the game process (G1R or Gothic) is running. If the game is running, the save folder is copied. If the game is closed, the script simply exits.
✨ Особенности / Features
Автоматизация: Создаёт копию сейвов каждые 5 минут, но только когда вы в игре.
Automation: Creates a save copy every 5 minutes, but only when you are in-game.
Лимит хранилища: Хранит только последние 30 обычных бэкапов, автоматически удаляя самые старые, чтобы не засорять диск.
Storage limit: Keeps only the last 30 regular backups, automatically deleting the oldest ones to save disk space.
Контрольные точки (Milestones): Каждый 30-й бэкап сохраняется в отдельную папку Milestones. Эти бэкапы скрипт не удаляет никогда.
Milestones: Every 30th backup is saved to a separate Milestones folder. The script never deletes these backups.
Безопасное восстановление: При попытке восстановить бэкап программа проверяет, не запущена ли игра. Ваши текущие сломанные сохранения не удаляются, а переименовываются в резервную папку SaveGames_old_....
Safe restore: When trying to restore a backup, the program checks if the game is running. Your current broken saves are not deleted; they are renamed into a backup folder SaveGames_old_....
Скрытность: Работает полностью в фоне без раздражающих всплывающих окон.
Stealth: Runs completely in the background with no annoying pop-up windows.
📥 Установка и запуск / Installation & Launch
Нажмите зелёную кнопку Code вверху страницы и выберите Download ZIP.
Click the green Code button at the top of the page and select Download ZIP.
Распакуйте скачанный архив в любое удобное место.
Extract the downloaded archive to any convenient location.
Запустите файл Run.bat (или сам скрипт .ps1, если используете PowerShell напрямую).
Run the Run.bat file (or the .ps1 script itself if using PowerShell directly).
В появившемся меню выберите пункт 1, чтобы установить фоновую задачу.
In the menu that appears, select option 1 to install the background task.
Закройте окно и играйте.
Close the window and play the game.
Примечание: Ваш антивирус или Windows Defender может предупредить о создании скрытой задачи в планировщике или о работе VBS-скрипта. Это нормальное поведение для данного инструмента.
Note: Your antivirus or Windows Defender may warn you about creating a hidden scheduled task or running a VBS script. This is normal behavior for this tool.
📋 Описание меню / Menu description
1. Start backups — Создает задачу в Windows и запускает автоматические бэкапы.
1. Start backups — Creates a Windows task and starts automatic backups.
2. Stop backups — Полностью удаляет задачу из планировщика. Бэкапы прекращаются.
2. Stop backups — Completely removes the task from the scheduler. Backups are stopped.
3. Restore a backup — Открывает список доступных бэкапов (обычных и Milestone) для восстановления. Важно: закройте игру перед восстановлением!
3. Restore a backup — Opens a list of available backups (regular and Milestone) for restoration. Important: close the game before restoring!
4. Choose backup folder — Позволяет изменить папку, куда будут сохраняться резервные копии. (После смены пути нужно снова нажать пункт 1).
4. Choose backup folder — Allows you to change the directory where backups are saved. (After changing the path, you must press option 1 again).
5. Open game save folder — Быстро открывает папку с сохранениями самой игры в Проводнике.
5. Open game save folder — Quickly opens the game's actual save folder in Explorer.
6. Check status — Показывает, работает ли фоновая задача, время последнего и следующего запуска, а также количество сохраненных бэкапов.
6. Check status — Shows if the background task is running, the time of the last and next run, and the number of saved backups.
7. Exit — Закрыть меню.
7. Exit — Close the menu.
📂 Расположение файлов / File locations
Папка бэкапов по умолчанию / Default backup folder:
%USERPROFILE%\Documents\Gothic_Permadeath_Backups
Оригинальные сохранения игры / Original game saves:
%LOCALAPPDATA%\G1R\Saved\SaveGames
Служебные файлы скрипта (Worker & VBS) / Script helper files:
%LOCALAPPDATA%\GothicBackup
🗑️ Удаление (Деинсталляция) / Uninstallation
Если вы удалите игру, скрипт и бэкапы останутся на вашем компьютере. Чтобы полностью удалить программу:
If you uninstall the game, the script and backups will remain on your computer. To completely remove the program:
Откройте меню программы и выберите 2. Stop backups.
Open the program menu and select 2. Stop backups.
Удалите папку с бэкапами (в Документах).
Delete the backup folder (in Documents).
Удалите папку со служебными файлами: %LOCALAPPDATA%\GothicBackup.
Delete the helper files folder: %LOCALAPPDATA%\GothicBackup.
