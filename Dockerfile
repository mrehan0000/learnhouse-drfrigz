FROM ghcr.io/learnhouse/app:latest
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

# Static legal pages served directly by nginx. The upstream OSS app has no
# /terms, /privacy, or /contact routes of its own and its built-in links fall
# back to learnhouse.io URLs that are themselves broken — see nginx-default.conf.
COPY legal/terms.html /usr/share/nginx/html/terms.html
COPY legal/privacy.html /usr/share/nginx/html/privacy.html
COPY legal/contact.html /usr/share/nginx/html/contact.html

# Run pending Alembic migrations before the app starts, so schema changes
# shipped in new image tags (new columns/tables on existing models) are
# actually applied instead of silently skipped by SQLModel's create_all().
COPY run-migrations-and-start.sh /app/run-migrations-and-start.sh
RUN chmod +x /app/run-migrations-and-start.sh
CMD ["sh", "/app/run-migrations-and-start.sh"]
