# airpoint_server
docker compose up -d
docker compose down

fvm dart pub run build_runner build --delete-conflicting-outputs

# Перейти в папку с видео
ffmpeg -i video_for_students.mp4 -vcodec libx265 -crf 28 video_for_students_min.mp4


ffmpeg -y -i video_for_students.mp4 -c:v libx264 -b:v 1M -pass 1 -an -f mp4 /dev/null && \
ffmpeg -i video_for_students.mp4 -c:v libx264 -b:v 1M -pass 2 -c:a aac -b:a 128k video_for_students_min.mp4