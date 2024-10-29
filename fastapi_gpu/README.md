# 목적
SSAFY GPU 서버에서 AI 모델 구동
SSAFY GPU 서버 특성상 Docker를 활용할 수 없으므로, tmux를 활용하여 서버를 직접 구동해야 함

# Requirements
## Ubuntu
- tmux
## Python
- python 3.11
- pytorch >= 2.4.0
- langchain = 0.3.4
- fastapi 0.115.2
- python-multipart 0.0.12
<!-- - uvicorn 0.32.0 -->