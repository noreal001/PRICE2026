FROM nginx:alpine

# Копируем твой index.html в папку, где его увидит сервер
COPY index.html /usr/share/nginx/html/index.html

# Эта команда на лету меняет порт 80 на тот, который требует Railway ($PORT)
CMD sed -i 's/listen \(.*\)80;/listen '"$PORT"';/' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
