# airpoint_server
docker compose down
docker compose up -d


fvm dart pub run build_runner build --delete-conflicting-outputs

# Перейти в папку с видео
ffmpeg -i video_for_students.mp4 -vcodec libx265 -crf 28 video_for_students_min.mp4


ffmpeg -y -i video_for_students.mp4 -c:v libx264 -b:v 1M -pass 1 -an -f mp4 /dev/null && \
ffmpeg -i video_for_students.mp4 -c:v libx264 -b:v 1M -pass 2 -c:a aac -b:a 128k video_for_students_min.mp4

#Локальная база:
ENVIRONMENT=local dart run

# Удалённая база (VPS):
ENVIRONMENT=remote dart run
# Перезагрузить nginx

docker-compose -f docker-compose.prod.yaml restart nginx


# ЭТА команда не работает используй выше
docker exec aviapoint-nginx nginx -s reload


# папка где лежит сервер
cd /home/aviapoint_server



# Запустить если обновилось серверное приложение
docker-compose -f docker-compose.prod.yaml build app
docker-compose -f docker-compose.prod.yaml up -d

# Скрипт для обновления бзы данных (копирует локальную и вставляет на сервер ) uOTC0OWjMVIoaRxI
./export_and_upload.sh 83.166.246.205

# Это запустит только базу данных на порту 5432 и Adminer на порту 8082, а сервер вы запустите локально через dart run bin/aviapoint_server.dart или через IDE.
docker-compose -f docker-compose.dev.yaml up -d

# Подключение по SSH
ssh root@83.166.246.205
uOTC0OWjMVIoaRxI