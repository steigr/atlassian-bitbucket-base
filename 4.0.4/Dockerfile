from %BASE_IMAGE%

env BITBUCKET_VERSION=4.0.4 \
    GOSU_VERSION=1.7 \
    TINI_VERSION=0.8.3 \
    BITBUCKET_APP_DIR=$CATALINA_HOME/atlassian-bitbucket \
    BITBUCKET_APP_USER=bitbucket \
    BITBUCKET_APP_GROUP=bitbucket

entrypoint ["tini"]

# Create User and Group
run groupadd -r $BITBUCKET_APP_GROUP \
 && adduser -g $BITBUCKET_APP_GROUP -d $BITBUCKET_APP_DIR -M -r -s $(command -v bash) $BITBUCKET_APP_USER

# Download Atlassian Bitbucket Server
run wget --progress=bar:force -O- "https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz" \
    | tar -z -x -C "$CATALINA_HOME" --strip-components 1 atlassian-bitbucket-${BITBUCKET_VERSION}/atlassian-bitbucket

# Install GoSU
run wget -qO/bin/gosu https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 \
 && chmod 0755 /bin/gosu

# Install tini
run wget -qO /bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini \
 && chmod 0755 /bin/tini