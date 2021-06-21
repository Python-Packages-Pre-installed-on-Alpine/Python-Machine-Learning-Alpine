ARG DOCKER_BASE_IMAGE_PREFIX
ARG DOCKER_BASE_IMAGE_NAMESPACE=pythonpackagesonalpine
ARG DOCKER_BASE_IMAGE_NAME=basic-python-packages-pre-installed-on-alpine
ARG DOCKER_BASE_IMAGE_TAG=tox-alpine
FROM ${DOCKER_BASE_IMAGE_PREFIX}${DOCKER_BASE_IMAGE_NAMESPACE}/${DOCKER_BASE_IMAGE_NAME}:${DOCKER_BASE_IMAGE_TAG}

ARG FIX_ALL_GOTCHAS_SCRIPT_LOCATION
ARG ETC_ENVIRONMENT_LOCATION
ARG CLEANUP_SCRIPT_LOCATION

# Depending on the base image used, we might lack wget/curl/etc to fetch ETC_ENVIRONMENT_LOCATION.
ADD $FIX_ALL_GOTCHAS_SCRIPT_LOCATION .
ADD $CLEANUP_SCRIPT_LOCATION .

RUN set -o allexport \
    && . ./fix_all_gotchas.sh \
    && set +o allexport \
    && apk --no-cache add curl ca-certificates py3-numpy-f2py freetype jpeg libpng libstdc++ libgomp graphviz font-noto \
    # && ln -s locale.h /usr/include/xlocale.h \
    && apk --no-cache add --virtual .build-base g++ musl-dev py3-numpy-dev py3-scipy py3-pandas build-base linux-headers python3-dev git cmake jpeg-dev bash libffi-dev gfortran openblas-dev freetype-dev libpng-dev \
    && pip install wheel \
    && pip install --no-build-isolation pytorch \
    && apk --no-cache del .build-base \
    && python -c "import torch" \
    && . ./cleanup.sh

