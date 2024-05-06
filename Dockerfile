# Build image to compile all packages
FROM python:3.11 AS build

ENV VIRTUAL_ENV=/home/packages/.venv
ADD https://astral.sh/uv/install.sh /install.sh
RUN chmod -R 655 /install.sh \
    && /install.sh && rm /install.sh

COPY ./requirements.txt .
RUN /root/.cargo/bin/uv venv /home/packages/.venv
RUN /root/.cargo/bin/uv pip install --no-cache -r requirements.txt

# Run image for the function app code
FROM mcr.microsoft.com/azure-functions/python:4-python3.11

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    PATH="/home/packages/.venv/bin:$PATH" \
    VIRTUAL_ENV=/home/packages/.venv

COPY --from=build /home/packages/.venv /home/packages/.venv
COPY ./funcs /home/site/wwwroot
