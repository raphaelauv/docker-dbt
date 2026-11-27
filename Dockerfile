FROM python:3.14-slim

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV UV_NO_CACHE=1
ENV UV_SYSTEM_PYTHON=1

COPY --from=ghcr.io/astral-sh/uv:0.13.10 /uv /usr/local/bin/uv

RUN apt-get update \
  && apt-get install -y --no-install-recommends git \
  && apt-get purge -y --auto-remove \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/program /data
WORKDIR /opt/program

COPY requirements.txt /opt/program/
RUN uv pip install -r /opt/program/requirements.txt

COPY src/ /opt/program/

RUN mkdir -p /opt/program/src
WORKDIR /opt/program/src

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]