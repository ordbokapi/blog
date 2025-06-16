FROM docker.io/library/ruby:3.4.4 AS devcontainer

# Create devcontainer user/group and home directory
RUN groupadd -g 1000 devcontainer && \
    useradd -m -u 1000 -g devcontainer devcontainer && \
    mkdir -p /home/devcontainer/blogg && \
    chown -R devcontainer:devcontainer /home/devcontainer

WORKDIR /home/devcontainer/blogg
ENV HOME=/home/devcontainer
USER devcontainer
CMD ["/bin/bash"]
ENTRYPOINT []
