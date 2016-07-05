FROM alpine:3.3

ADD *.go .git /curated-authors-transformer/
ADD test-resources /curated-authors-transformer/test-resources

RUN apk --update add git go \
  && export GOPATH=/gopath \
  && REPO_PATH="github.com/Financial-Times/curated-authors-transformer" \
  && cd curated-authors-transformer \
  && BUILDINFO_PACKAGE="github.com/Financial-Times/service-status-go/buildinfo." \
  && VERSION="version=$(git describe --tag --always 2> /dev/null)" \
  && DATETIME="dateTime=$(date -u +%Y%m%d%H%M%S)" \
  && REPOSITORY="repository=$(git config --get remote.origin.url)" \
  && REVISION="revision=$(git rev-parse HEAD)" \
  && BUILDER="builder=$(go version)" \
  && LDFLAGS="-X '"${BUILDINFO_PACKAGE}$VERSION"' -X '"${BUILDINFO_PACKAGE}$DATETIME"' -X '"${BUILDINFO_PACKAGE}$REPOSITORY"' -X '"${BUILDINFO_PACKAGE}$REVISION"' -X '"${BUILDINFO_PACKAGE}$BUILDER"'" \
  && echo $LDFLAGS \
  && mkdir -p $GOPATH/src/${REPO_PATH} \
  && mv * $GOPATH/src/${REPO_PATH} \
  && cd $GOPATH/src/${REPO_PATH} \
  && go get -t ./... \
  && ls \
  && go test ./... \
  && go build -ldflags="${LDFLAGS}" \
  && mv curated-authors-transformer /curated-authors-transformer-app \
  && apk del go git \
  && rm -rf $GOPATH /var/cache/apk/*
  
EXPOSE 8080

CMD exec /curated-authors-transformer-app 