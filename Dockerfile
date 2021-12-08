FROM jupyter/scipy-notebook:ubuntu-20.04@sha256:b6a4ce777b837496d5612b7ce4efba9aa015576cb6993817721b8d293a7c2a3c

COPY requirements.txt /tmp
RUN pip install -U pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

COPY bin/entrypoint.sh /tmp/entrypoint.sh

ENTRYPOINT ["/tmp/entrypoint.sh"]
