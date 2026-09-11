FROM ghcr.io/mrehan0000/learnhouse:dev
# Custom-built image from our fork (mrehan0000/learnhouse, dev branch), which
# adds per-course sequential progression gating on top of upstream. Built and
# tagged locally on this server rather than pulled from a registry — see
# mrehan0000/learnhouse for the actual application source.
#
# Coolify caches the built image by THIS repo's commit SHA, not by the
# content of the FROM image -- it has no way to know the local `dev` tag
# changed underneath it. So whenever the fork is rebuilt (`docker build -t
# ghcr.io/mrehan0000/learnhouse:dev .` from the fork checkout), a commit must
# also land here (even a no-op comment bump like this one, noting the fork
# commit the local image was built from) or Coolify will silently reuse the
# stale image and skip the rebuild entirely.
# Base image last rebuilt from mrehan0000/learnhouse@25ed75d8.
#
# The base image's nginx is Alpine's (apk), which reads /etc/nginx/http.d/*.conf,
# not Debian-style /etc/nginx/conf.d/*.conf. Copying here previously landed in a
# path nginx doesn't fully include, which crashed nginx at startup with
# "server" directive is not allowed here — matches upstream's own Dockerfile,
# which copies its equivalent file to this same http.d path.
COPY nginx-default.conf /etc/nginx/http.d/default.conf

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
