# 목적
SSAFY GPU 서버에서 AI 모델 구동.
SSAFY GPU 서버 특성상 Docker를 활용할 수 없으므로, tmux를 활용하여 서버를 직접 구동해야 함.
**인가를 확인하는 기능이 없으므로, nginx 등 프록시 없이 구동할 때에는 주의해야 함**
## CPU 서버 사용 시
사용하는 Image Model의 크기가 작으므로, CPU로도 구동이 가능함.
동봉된 dockerfile로 빌드한 후, Port Mapping 만 해서 docker run 하면 됨.
# Requirements
## Ubuntu
- tmux
## Python
- python 3.12
- pytorch 2.4.1
    ```bash
    # ROCM 6.1 (Linux only)
    pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/rocm6.1
    # CUDA 11.8
    pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu118
    # CUDA 12.1
    pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu121
    # CUDA 12.4
    pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu124
    # CPU only
    pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cpu
    ```
- fastapi 0.115.2
- python-multipart 0.0.12
- uvicorn 0.32.0
- transformers 4.46.2