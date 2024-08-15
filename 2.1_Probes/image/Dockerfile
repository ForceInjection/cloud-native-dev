From nginx:alpine

RUN echo "ready"  > /usr/share/nginx/html/readinesscheck.txt \
 && echo "alive"  > /usr/share/nginx/html/livenesscheck.txt  \
 && echo "started"  > /usr/share/nginx/html/startupcheck.txt

COPY troublemaker.sh /home/troublemaker.sh
COPY entrypoint.sh /home/entrypoint.sh

WORKDIR /home

ENTRYPOINT ["entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
