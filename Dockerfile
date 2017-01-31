FROM cloudgear/ruby:2.2

RUN mkdir -p /home/app
WORKDIR /home/app
RUN apt-get update -q && apt-get install -yq --no-install-recommends \
    git && \
    # clean up
    rm -rf /var/lib/apt/lists/* && \
    truncate -s 0 /var/log/*log
COPY . .
RUN bundle
EXPOSE 4567
ENTRYPOINT bundle exec ruby app.rb
