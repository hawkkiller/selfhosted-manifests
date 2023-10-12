# Start from Amazon Linux 2
FROM amazonlinux:2

# Install necessary packages
RUN yum -y install tar gzip unzip \
    && yum -y localinstall https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm \
    && yum -y update \
    && yum -y install mysql-community-client

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -f awscliv2.zip && rm -rf aws

# Copy necessary scripts and files
COPY scripts/upload-backup.sh ./scripts/upload-backup.sh
COPY scripts/apply-backup.sh ./scripts/apply-backup.sh

# Set executable permissions
RUN chmod +x ./scripts/upload-backup.sh
RUN chmod +x ./scripts/apply-backup.sh

# Default command (if none is provided)
CMD ["./scripts/upload-backup.sh"]
