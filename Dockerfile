FROM nginx:alpine
# Копируем твой index.html в папку сервера
COPY index.html /usr/share/nginx/html/index.html
# Магия для Railway: подставляем динамический порт в настройки сервера
CMD sed -i 's/listen \(.*\)80;/listen '"$PORT"';/' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
