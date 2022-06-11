FROM python:3.8.10

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY . /app/
WORKDIR /app

RUN pip install -r requirements.txt

ENTRYPOINT [ "./entrypoint.sh" ]
EXPOSE 80