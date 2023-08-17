FROM jupyter/scipy-notebook:ubuntu-22.04@sha256:6f01928391c301e6b1a66643c36cc62ac596dd269f2bb98821f0de68602fccca

COPY requirements.txt /tmp
RUN pip install -U pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

COPY bin/entrypoint.sh /tmp/entrypoint.sh

ENTRYPOINT ["/tmp/entrypoint.sh"]
