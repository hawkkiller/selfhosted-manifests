FROM amazon/aws-cli

# Install necessary packages
RUN yum -y install \
    tar \
    gzip \
    https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm \
    mysql-community-client
# Copy necessary scripts and files
COPY scripts/apply_dump.sh /apply_dump.sh

RUN chmod +x /apply_dump.sh

CMD ["apply_dump.sh"]
