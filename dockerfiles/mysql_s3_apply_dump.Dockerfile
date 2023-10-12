FROM amazon/aws-cli

# Install necessary packages
RUN yum -y install \
    tar \
    gzip \
    https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm \
    mysql-community-client

COPY scripts/apply-dump.sh ./scripts/apply-dump.sh

RUN chmod +x ./scripts/apply-dump.sh

CMD ["./scripts/apply-dump.sh"]
