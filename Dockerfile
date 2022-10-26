FROM jupyter/scipy-notebook:ubuntu-22.04@sha256:d76daf85d5a49546d3dd65870423561eb7488c4436a58ab4d8706190fb6db430

COPY requirements.txt /tmp
RUN pip install -U pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

COPY bin/entrypoint.sh /tmp/entrypoint.sh

ENTRYPOINT ["/tmp/entrypoint.sh"]
