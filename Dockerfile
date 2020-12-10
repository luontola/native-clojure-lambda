FROM public.ecr.aws/lambda/java:11

COPY target/uberjar/emergency-letter.jar ${LAMBDA_TASK_ROOT}

CMD [ "emergency_letter.Handler::handleRequest" ]
