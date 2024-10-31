# 목적
SSAFY GPU 서버에서 AI 모델 구동
SSAFY GPU 서버 특성상 Docker를 활용할 수 없으므로, tmux를 활용하여 서버를 직접 구동해야 함
## CPU 서버 사용 시
사용하는 Image Model의 크기가 작으므로, CPU로도 구동이 가능함.
동봉된 dockerfile로 빌드한 후, Port Mapping 만 해서 docker run 하면 됨.
# Requirements
## Ubuntu
- tmux
## Python
- python 3.12
- pytorch 2.4.1
- fastapi 0.115.2
- python-multipart 0.0.12
- uvicorn 0.32.0