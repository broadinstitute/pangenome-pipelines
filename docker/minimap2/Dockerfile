FROM mambaorg/micromamba:2.0.5
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yml /tmp/env.yml
RUN micromamba install -y -n base -f /tmp/env.yml && \
    micromamba clean --all --yes

# We set this environment variable to make sure that the conda environment is activated,
# since Cromwell overrides the entrypoint configuration set in the micromamba base image.
ENV BASH_ENV /usr/local/bin/_activate_current_env.sh