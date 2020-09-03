FROM docker.elastic.co/elasticsearch/elasticsearch-oss:7.7.1

# https://www.elastic.co/guide/en/elasticsearch/plugins/current/ingest-attachment.html#ingest-attachment-remove
# use --batch flag for non-interactive install, see https://discuss.elastic.co/t/installing-plugin-through-shell-script-without-prompt/84456
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment

# https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-http.html
ENV http.cors.enabled=true
ENV http.cors.allow-origin=*
