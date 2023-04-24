ARG JAVA_HOME=/opt/openjdk


# Disable Dependabot updates
FROM dockerproxy.com/library/openjdk:8-alpine AS lts

# 方便环境变量的设置
RUN mkdir --parents /opt/openjdk/lts; mv /usr/lib/jvm/java-*/* /opt/openjdk/lts


FROM dockerproxy.com/library/openjdk:19-alpine AS latest

# 方便环境变量的设置
RUN mkdir --parents /opt/openjdk/latest; mv /opt/openjdk-*/* /opt/openjdk/latest


FROM ccr.ccs.tencentyun.com/storezhang/alpine:3.17.2 AS builder

ARG JAVA_HOME


# 复制文件
COPY --from=lts ${JAVA_HOME} /docker/${JAVA_HOME}
COPY --from=latest ${JAVA_HOME} /docker/${JAVA_HOME}
COPY --from=latest /etc/ssl/certs/java/cacerts /docker/etc/ssl/certs/java/cacerts




# 打包真正的镜像
FROM ccr.ccs.tencentyun.com/storezhang/alpine:3.17.2


LABEL author="storezhang<华寅>" \
    email="storezhang@gmail.com" \
    qq="160290688" \
    wechat="storezhang" \
    description="Java镜像，为了更符合中国国情，包含一个最新的Java发布版本和一个Java8版本"


# 复制文件
COPY --from=builder /docker /


RUN set -ex \
    \
    \
    \
    # 安装依赖库
    && apk update \
    && apk --no-cache add nss \
    \
    # 解决找不到库的问题
    && LD_PATH=/etc/ld-musl-x86_64.path \
    && echo "/lib" >> ${LD_PATH} \
    && echo "/usr/lib" >> ${LD_PATH} \
    && echo "/usr/local/lib" >> ${LD_PATH} \
    && echo "${JAVA_HOME}/lib/default" >> ${LD_PATH} \
    && echo "${JAVA_HOME}/lib/server" >> ${LD_PATH} \
    \
    \
    \
    && rm -rf /var/cache/apk/*


ARG JAVA_HOME
ENV JAVA_OPTS ""
ENV JAVA_LIB /var/lib/java

ENV PATH=${JAVA_HOME}/bin:${MAVEN_HOME}/bin:$PATH
ENV JAVA_LTS ${JAVA_HOME}/lts
ENV JAVA_LATEST ${JAVA_HOME}/latest
