FROM python:3.8.10

# Creating virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrading pip
RUN pip install --upgrade pip

COPY . /app/
WORKDIR /app

RUN pip install -r requirements.txt

ENTRYPOINT [ "./entrypoint.sh" ]
EXPOSE 80