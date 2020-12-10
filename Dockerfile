FROM amazoncorretto:11

# shadow-utils provides groupadd, useradd etc.
RUN yum install -y shadow-utils && \
    yum clean all

RUN groupadd --system app && \
    useradd --system --gid app app && \
    mkdir -p /app
WORKDIR /app
USER app

COPY target/uberjar/emergency-letter.jar emergency-letter.jar

# com.amazonaws.services.lambda.runtime.api.client.util.EnvWriter.<init> accesses java.util.Collections$UnmodifiableMap.m
CMD ["/bin/java", "--illegal-access=deny", \
             "--add-opens", "java.base/java.util=ALL-UNNAMED", \
             "-XX:MaxRAMPercentage=75.0", "-XX:+ExitOnOutOfMemoryError", \
             "-XshowSettings:vm", "-XX:+PrintCommandLineFlags", \
             "-jar", "emergency-letter.jar"]
