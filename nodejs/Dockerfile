FROM oraclelinux:9

# Install system dependencies and Node.js 22.x repository
RUN curl -fsSL https://rpm.nodesource.com/setup_22.x  | bash - && \
    dnf install -y \
        curl \
        wget \
        gnupg2 \
        ca-certificates \
        python3 \
        java-17-openjdk \
        fontconfig \
        libXrender \
        libXext \
        libXinerama \
        libreoffice-core \
        libreoffice-* && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Enable AppStream and EPEL repositories
RUN dnf config-manager --set-enabled ol9_appstream && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm  && \
    dnf clean all

# Install Node.js 22.x (includes npm)
RUN dnf install -y nodejs && \
    npm --version && \
    dnf clean all

# Verify npm is installed
RUN npm --version

# Create app directory and non-root user
WORKDIR /usr/src/app

# Copy app source
COPY . .

# ?
RUN useradd -m appuser && chown -R appuser:appuser /usr/src/app
USER appuser

# Copy package.json and install dependencies
COPY --chown=appuser:appuser package*.json ./
RUN npm install --only=production

## npm install -g npm@11.4.0


# Copy app source
COPY --chown=appuser:appuser . .

# path to help carbone find soffice.bin ()
ENV PATH="/usr/lib64/libreoffice/program:${PATH}"


# Expose port and start application
EXPOSE 80 443
CMD ["node", "index.js"]