FROM amazon/aws-cli

# Install necessary packages
RUN yum -y install \
    tar \
    gzip \
    https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm \
    mysql-community-client

# Copy necessary scripts and files
COPY scripts/upload-dump.sh ./scripts/upload-dump.sh
COPY scripts/apply-dump.sh ./scripts/apply-dump.sh

# Set executable permissions
RUN chmod +x ./scripts/upload-dump.sh
RUN chmod +x ./scripts/apply-dump.sh

# Default command (if none is provided)
CMD ["./scripts/upload-dump.sh"]
