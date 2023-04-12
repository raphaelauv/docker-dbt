FROM python:3.10-slim

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PIP_NO_CACHE_DIR=TRUE
ENV PIP_DISABLE_PIP_VERSION_CHECK=TRUE

RUN apt-get update \
  && apt-get install -y --no-install-recommends git \
  && apt-get purge -y --auto-remove \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/program
WORKDIR /opt/program

COPY requirements.txt /opt/program/
RUN python3 -m pip install -r /opt/program/requirements.txt

COPY src/ /opt/program/

RUN mkdir -p /opt/program/src
WORKDIR /opt/program/src

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]