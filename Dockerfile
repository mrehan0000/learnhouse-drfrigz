FROM ghcr.io/learnhouse/app:latest
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

# Run pending Alembic migrations before the app starts, so schema changes
# shipped in new image tags (new columns/tables on existing models) are
# actually applied instead of silently skipped by SQLModel's create_all().
COPY run-migrations-and-start.sh /app/run-migrations-and-start.sh
RUN chmod +x /app/run-migrations-and-start.sh
CMD ["sh", "/app/run-migrations-and-start.sh"]
