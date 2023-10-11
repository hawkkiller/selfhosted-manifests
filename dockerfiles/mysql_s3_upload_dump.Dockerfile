FROM amazon/aws-cli

# Install necessary packages
RUN yum -y install \
    tar \
    gzip \
    https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm \
    mysql-community-client
# Copy necessary scripts and files
COPY scripts/upload_dump.sh /upload_dump.sh

RUN chmod +x /upload_dump.sh

CMD ["upload_dump.sh"]
