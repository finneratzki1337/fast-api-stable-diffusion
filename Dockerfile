FROM nvidia/cuda:11.4.2-base-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV AM_I_IN_A_DOCKER_CONTAINER Yes
# Updating on every build for security
RUN apt-get update && apt-get upgrade -y

# Installing necessary setup tools
RUN apt-get install -y wget && apt-get install -y curl && apt-get install -y git
# Handling of image files
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y
# Installing python3.9 pip and upgrading pip
RUN apt-get install -y python3.8 && apt-get install -y python3-pip && python3 -m pip install --upgrade pip
# Installing uvicorn for running the app
RUN apt-get install -y uvicorn
WORKDIR /code


# Install miniconda to handle necessary stable diffusion environment
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh
RUN bash Miniconda3-py38_4.12.0-Linux-x86_64.sh -b -p /miniconda
ENV PATH="/miniconda/bin:${PATH}"
# Installing Stable diffusion in GPU Version
RUN git clone https://github.com/CompVis/stable-diffusion.git
WORKDIR /code/stable-diffusion
RUN conda env create -f environment.yaml
# Downloading the model
RUN curl -keepalive-time 2 https://f004.backblazeb2.com/file/aai-blog-files/sd-v1-4.ckpt > sd-v1-4.ckpt
#RUN conda activate ldm
WORKDIR /code
# Specifically adding requirements txt only from fastapi
COPY requirements.txt .
RUN pip3 install -r requirements.txt
# Switching user for security reasons
RUN useradd -ms /bin/bash exec-user
# Adding all Src files
ADD . /code
RUN chown exec-user files
USER exec-user

#ENV USER_NAME=testuser
#ENV USER_PASSWORD=testpassword
#ENV UVICORN_PORT=5000
#ENV NUMBER_WORKERS=1

#CMD uvicorn app:app --host 0.0.0.0 --port ${UVICORN_PORT} --workers ${NUMBER_WORKERS}
#CMD uvicorn app:app --host 0.0.0.0 --port 5000 --workers 1