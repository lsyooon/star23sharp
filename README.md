## 기술 특장점
### AI 기반 장소 인증 시스템
#### 장소 인식 AI 모델
- [CVPR 2024](https://cvpr.thecvf.com/Conferences/2024) 에 등재된 논문 [Bag of Queries: A Place is Worth a Bag of Learnable Queries](https://openaccess.thecvf.com/content/CVPR2024/papers/Ali-bey_BoQ_A_Place_is_Worth_a_Bag_of_Learnable_Queries_CVPR_2024_paper.pdf) 의 [모델](https://github.com/amaralibey/Bag-of-Queries) 을 사용
	- 사진에 찍힌 장소를 인식하는 AI
	- GPS와 연계하여 보물 쪽지 인증에 사용됨
- AI 모델 벤치마크
    - 벡터간의 코사인 거리로 Classification Task의 수행이 가능한지 보기 위한 벤치마크
    - 사용 데이터셋: [GSV-Cities](https://github.com/amaralibey/gsv-cities)
        - 데이터셋 중 일부를 샘플링하여 벤치마크에 활용
            - 3만 5천개의 장소
            - 5만 2천개의 이미지
    - [Cosine Distance](https://en.wikipedia.org/wiki/Cosine_similarity#Cosine_distance) Distribution
        - 히스토그램
        <br/>
        <img src="readme_images/histogram.png" height="500px" > <br/>
        - Cosine distance 통계
            - Same-label cosine distance
                - Mean: 0.6880
                - Std: 0.1158
            - Different-label cosine distance
                - Mean: 0.9999
                - Std: 0.0134

        - 같은 장소에 대한 사진의 벡터간의 Cosine distance와, 다른 장소에 대한 사진의 벡터간의 Cosine distance가 **잘 구분되는 Distribution을 가짐을 알 수 있음**
    - Classification 성능 지표
        - Precision-Recall Curve
            <br/>
            <img src="readme_images/PR_curve.png" height="500px" > <br/>
        - Classification Threshold 0.8491 에서 F1 Score 0.9365
#### 보물 쪽지 저장
![alt text](/readme_images/storing_treasure.png)
1. 같은 장소의 사진 두 장을 찍어 업로드
2. AI 모델에 입력되어 Vector Representation 생성
3. 두 벡터의 평균을 Vector Database에 저장
#### 보물 쪽지 찾기
![alt text](/readme_images/revealing_treasure.png)
1. 보물 쪽지가 숨겨진 장소를 찍어 업로드
2. AI 모델에 입력되어 Vector Representation 생성
3. DB에 저장되어있던 Vector와 Cosine 거리를 비교하여 거리가 임계값(0.8491) 미만이면 같은 장소로 판정
### [Race Condition](https://en.wikipedia.org/wiki/Race_condition#Data_race) 방지
![alt text](/readme_images/race_condition.png)
- [Row level lock](https://www.postgresql.org/docs/current/explicit-locking.html#LOCKING-ROWS) 을 도입하여 성능 손실을 최소화하면서 안정적인 Transaction을 구현
- 보물 쪽지 인증 시 발생할 수 있는 잠재적인 Race Condition 해결