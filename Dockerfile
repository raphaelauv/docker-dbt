FROM python:3.14-slim

ENV PYTHONUNBUFFERED=1

RUN apt-get update \
  && apt-get install -y --no-install-recommends git \
  && rm -rf /var/lib/apt/lists/*

# uv is only mounted for the install, not kept in the image
RUN --mount=from=ghcr.io/astral-sh/uv:0.13.10,source=/uv,target=/bin/uv \
    --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    uv pip install --system --no-cache -r /tmp/requirements.txt

RUN mkdir -p /data
COPY src/ /opt/program/
COPY entrypoint.sh /

WORKDIR /opt/program/src
ENTRYPOINT ["/entrypoint.sh"]
