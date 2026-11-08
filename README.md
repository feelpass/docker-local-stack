# Docker Local Infrastructure

각 서비스별로 독립적으로 관리되는 Docker 기반 로컬 인프라 구축 프로젝트입니다.
AWS 프로파일 관리 기능과 유연한 포트 설정을 지원합니다.

## 📁 프로젝트 구조

```
docker-infra/
├── Makefile           # 루트 Makefile (전체 서비스 관리)
├── .env               # 환경 변수 설정
├── scripts/           # 유틸리티 스크립트
│   ├── backup.sh      # 백업 스크립트
│   ├── restore.sh     # 복원 스크립트
│   └── health-check.sh # 헬스체크 대시보드
├── mysql/             # MySQL 서비스
│   ├── docker-compose.yml
│   ├── Makefile
│   └── init/
├── redis/             # Redis 서비스
│   ├── docker-compose.yml
│   └── Makefile
├── dynamodb/          # DynamoDB 서비스
│   ├── docker-compose.yml
│   ├── Makefile
│   └── init.sh
├── mongodb/           # MongoDB 서비스
│   ├── docker-compose.yml
│   ├── Makefile
│   └── init/
├── kafka/             # Kafka 서비스
│   ├── docker-compose.yml
│   └── Makefile
├── elasticsearch/     # Elasticsearch + Kibana
│   ├── docker-compose.yml
│   └── Makefile
└── minio/             # MinIO (S3 호환 스토리지)
    ├── docker-compose.yml
    └── Makefile
```

## 🚀 Quick Start

### 초기 설정

```bash
# 1. 환경 파일 설정 (처음 한 번만)
make setup

# 2. .env 파일 편집하여 포트 및 AWS 프로파일 설정
nano .env

# 3. 개발 환경 시작
make dev
```

### 전체 서비스 관리 (루트 디렉토리에서)

```bash
# 모든 서비스 시작
make up-all

# 모든 서비스 + Admin UI 시작
make up-all-admin

# 모든 서비스 중지
make down-all

# 개발 환경 시작 (MySQL, Redis, DynamoDB)
make dev

# 전체 상태 확인
make status
```

### 개별 서비스 관리

#### MySQL
```bash
# MySQL 디렉토리에서
cd mysql
make up              # MySQL 시작
make up-admin        # MySQL + phpMyAdmin 시작
make down            # 중지
make cli             # MySQL CLI 접속
make help            # 도움말

# 또는 루트에서
make mysql-up        # MySQL 시작
make mysql-down      # MySQL 중지
make mysql-cli       # MySQL CLI 접속
```

#### Redis
```bash
# Redis 디렉토리에서
cd redis
make up              # Redis 시작
make up-admin        # Redis + Commander 시작
make down            # 중지
make cli             # Redis CLI 접속
make monitor         # 실시간 모니터링

# 또는 루트에서
make redis-up        # Redis 시작
make redis-down      # Redis 중지
make redis-cli       # Redis CLI 접속
```

#### DynamoDB
```bash
# DynamoDB 디렉토리에서
cd dynamodb
make up              # DynamoDB 시작
make up-admin        # DynamoDB + Admin UI 시작
make down            # 중지
make init            # 테이블 초기화
make list-tables     # 테이블 목록

# 또는 루트에서
make dynamodb-up     # DynamoDB 시작
make dynamodb-down   # DynamoDB 중지
make dynamodb-init   # 테이블 초기화
```

#### MongoDB
```bash
# MongoDB 디렉토리에서
cd mongodb
make up              # MongoDB 시작
make up-admin        # MongoDB + Mongo Express 시작
make down            # 중지
make cli             # MongoDB Shell 접속
make dbs             # 데이터베이스 목록

# 또는 루트에서
make mongodb-up      # MongoDB 시작
make mongodb-down    # MongoDB 중지
make mongodb-cli     # MongoDB Shell 접속
```

#### Kafka
```bash
# Kafka 디렉토리에서
cd kafka
make up              # Kafka 클러스터 시작
make up-admin        # Kafka + UI 시작
make down            # 중지
make topics          # 토픽 목록
make create-topic TOPIC=test  # 토픽 생성

# 또는 루트에서
make kafka-up        # Kafka 시작
make kafka-down      # Kafka 중지
make kafka-topics    # 토픽 목록
```

#### Elasticsearch
```bash
# Elasticsearch 디렉토리에서
cd elasticsearch
make up              # Elasticsearch 시작
make up-admin        # Elasticsearch + Kibana 시작
make down            # 중지
make indices         # 인덱스 목록
make health          # 클러스터 헬스 체크

# 또는 루트에서
make elasticsearch-up        # Elasticsearch 시작
make elasticsearch-down      # Elasticsearch 중지
make elasticsearch-indices   # 인덱스 목록
```

#### MinIO
```bash
# MinIO 디렉토리에서
cd minio
make up              # MinIO 시작
make down            # 중지
make buckets         # 버킷 목록
make init            # 기본 버킷 생성

# 또는 루트에서
make minio-up        # MinIO 시작
make minio-down      # MinIO 중지
make minio-buckets   # 버킷 목록
```

## 📦 서비스 정보

### 기본 포트

| Service | Port | Admin UI Port | Description |
|---------|------|---------------|-------------|
| MySQL | 3306 | 8082 (phpMyAdmin) | 관계형 데이터베이스 |
| Redis | 6379 | 8081 (Commander) | 인메모리 캐시 |
| DynamoDB | 8000 | 8001 (Admin) | NoSQL 데이터베이스 |
| MongoDB | 27017 | 8083 (Express) | 도큐먼트 데이터베이스 |
| Kafka | 9092 | 8080 (UI) | 메시지 브로커 |
| Zookeeper | 2181 | - | Kafka 코디네이터 |
| Elasticsearch | 9200 | 5601 (Kibana) | 검색 및 분석 엔진 |
| MinIO | 9000 | 9001 (Console) | S3 호환 오브젝트 스토리지 |

## 📚 각 서비스별 상세 설명

### MySQL 서비스

#### 개요
MySQL 8.0 기반의 관계형 데이터베이스 서비스입니다. phpMyAdmin을 통한 웹 UI 관리를 지원합니다.

#### 주요 기능
- **버전**: MySQL 8.0
- **관리 도구**: phpMyAdmin (최신 버전)
- **초기화 스크립트**: `mysql/init/` 디렉토리에 SQL 파일 추가로 자동 실행
- **볼륨 영속성**: `mysql-data` 볼륨으로 데이터 보존
- **헬스체크**: mysqladmin ping으로 상태 모니터링

#### 설정 옵션 (.env)
```bash
MYSQL_PORT=3306                 # MySQL 포트
PHPMYADMIN_PORT=8082            # phpMyAdmin 포트
MYSQL_ROOT_PASSWORD=root        # Root 비밀번호
MYSQL_DATABASE=bomcalendar      # 기본 데이터베이스
MYSQL_USER=admin                 # 사용자 이름
MYSQL_PASSWORD=admin123         # 사용자 비밀번호
```

#### 사용 예제
```bash
# MySQL CLI 접속
make mysql-cli

# SQL 파일 실행
docker exec -i local-mysql mysql -uroot -proot < backup.sql

# 데이터베이스 백업
docker exec local-mysql mysqldump -uroot -proot bomcalendar > backup.sql
```

### Redis 서비스

#### 개요
Redis 7 Alpine 기반의 인메모리 캐시 및 메시지 브로커 서비스입니다.

#### 주요 기능
- **버전**: Redis 7 (Alpine Linux)
- **관리 도구**: Redis Commander
- **영속성**: AOF (Append Only File) 활성화
- **볼륨**: `redis-data`로 데이터 영속화
- **패스워드**: 선택적 설정 가능

#### 설정 옵션 (.env)
```bash
REDIS_PORT=6379                  # Redis 포트
REDIS_COMMANDER_PORT=8081        # Redis Commander 포트
# REDIS_PASSWORD=redis123        # 패스워드 (선택사항)
```

#### 사용 예제
```bash
# Redis CLI 접속
make redis-cli

# 키-값 설정
redis-cli SET mykey "Hello World"
redis-cli GET mykey

# 모니터링
make redis-monitor

# 모든 키 조회
redis-cli KEYS "*"
```

### DynamoDB Local 서비스

#### 개요
AWS DynamoDB와 완전히 호환되는 로컬 NoSQL 데이터베이스입니다.

#### 주요 기능
- **버전**: Amazon DynamoDB Local (최신)
- **관리 도구**: DynamoDB Admin UI
- **실행 모드**: 인메모리 모드 (개발용)
- **AWS SDK 호환**: 모든 AWS SDK와 완벽 호환
- **초기화 스크립트**: `dynamodb/init.sh`로 테이블 자동 생성

#### 설정 옵션 (.env)
```bash
DYNAMODB_PORT=8000               # DynamoDB 포트
DYNAMODB_ADMIN_PORT=8001         # Admin UI 포트
AWS_ACCESS_KEY_ID=local          # AWS 액세스 키
AWS_SECRET_ACCESS_KEY=local      # AWS 시크릿 키
AWS_REGION=ap-northeast-2        # AWS 리전
```

#### 사용 예제
```bash
# 테이블 목록 조회
aws dynamodb list-tables --endpoint-url http://localhost:8000

# 테이블 생성
aws dynamodb create-table \
    --table-name Users \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --endpoint-url http://localhost:8000

# 아이템 추가
aws dynamodb put-item \
    --table-name Users \
    --item '{"id": {"S": "user1"}, "name": {"S": "John"}}' \
    --endpoint-url http://localhost:8000
```

### MongoDB 서비스

#### 개요
MongoDB 6 기반의 도큐먼트 데이터베이스 서비스입니다.

#### 주요 기능
- **버전**: MongoDB 6
- **관리 도구**: Mongo Express
- **초기화 스크립트**: `mongodb/init/` 디렉토리의 JS 파일 자동 실행
- **볼륨**: `mongodb-data`로 데이터 영속화
- **헬스체크**: mongosh ping 명령으로 상태 확인

#### 설정 옵션 (.env)
```bash
MONGO_PORT=27017                 # MongoDB 포트
MONGO_EXPRESS_PORT=8083          # Mongo Express 포트
MONGO_ROOT_USER=root             # Root 사용자
MONGO_ROOT_PASSWORD=root123      # Root 비밀번호
MONGO_DATABASE=bomcalendar       # 기본 데이터베이스
```

#### 사용 예제
```bash
# MongoDB Shell 접속
make mongodb-cli

# 데이터베이스 목록
show dbs

# 컬렉션 생성 및 문서 추가
use bomcalendar
db.users.insertOne({name: "John", age: 30})
db.users.find()

# 백업
docker exec local-mongodb mongodump --out /backup
```

### Kafka 서비스

#### 개요
Apache Kafka 메시지 스트리밍 플랫폼입니다. Zookeeper와 함께 실행됩니다.

#### 주요 기능
- **버전**: Confluent Kafka 7.5.0
- **관리 도구**: Kafka UI
- **구성요소**: Kafka Broker + Zookeeper
- **자동 토픽 생성**: 활성화
- **볼륨**: `kafka-data`, `zookeeper-data`로 영속화

#### 설정 옵션 (.env)
```bash
KAFKA_PORT=9092                  # Kafka 외부 포트
ZOOKEEPER_PORT=2181              # Zookeeper 포트
KAFKA_UI_PORT=8080               # Kafka UI 포트
```

#### 사용 예제
```bash
# 토픽 생성
make kafka-create-topic TOPIC=events PARTITIONS=3

# 토픽 목록
make kafka-topics

# 메시지 발행 (프로듀서)
make kafka-produce TOPIC=events
# 메시지 입력 후 Ctrl+C로 종료

# 메시지 소비 (컨슈머)
make kafka-consume TOPIC=events

# Kafka Shell 접속
make kafka-shell
```

#### Kafka 네트워크 구성
- **내부 통신**: `kafka:29092` (컨테이너 간)
- **외부 통신**: `localhost:9092` (호스트에서)

### 기본 인증 정보

#### MySQL
- Root: root / root
- User: admin / admin123

#### MongoDB
- Root: root / root123

#### Redis
- Password: 없음 (설정 가능)

#### DynamoDB
- AWS_ACCESS_KEY_ID: local
- AWS_SECRET_ACCESS_KEY: local

#### Kafka
- 인증 없음 (개발 환경)

### Elasticsearch 서비스

#### 개요
Elasticsearch 8.11 기반의 분산 검색 및 분석 엔진입니다. Kibana를 통한 시각화를 지원합니다.

#### 주요 기능
- **버전**: Elasticsearch 8.11.0
- **관리 도구**: Kibana 8.11.0
- **모드**: 단일 노드 (개발용)
- **보안**: xpack.security 비활성화 (개발용)
- **볼륨**: `elasticsearch-data`로 인덱스 영속화

#### 설정 옵션 (.env)
```bash
ELASTICSEARCH_PORT=9200          # Elasticsearch 포트
KIBANA_PORT=5601                 # Kibana 포트
```

#### 사용 예제
```bash
# 인덱스 생성
curl -X PUT "localhost:9200/logs" -H 'Content-Type: application/json' -d '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'

# 문서 추가
curl -X POST "localhost:9200/logs/_doc" -H 'Content-Type: application/json' -d '{
  "timestamp": "2024-01-01T10:00:00",
  "level": "INFO",
  "message": "Application started"
}'

# 검색
curl "localhost:9200/logs/_search?q=level:INFO"

# 인덱스 목록
make elasticsearch-indices
```

### MinIO 서비스

#### 개요
Amazon S3와 완전히 호환되는 오브젝트 스토리지 서버입니다.

#### 주요 기능
- **버전**: MinIO 최신 버전
- **관리 도구**: MinIO Console (웹 UI)
- **S3 호환**: 완벽한 S3 API 호환성
- **버킷**: 자동 생성 (uploads, backups, logs)
- **볼륨**: `minio-data`로 객체 영속화

#### 설정 옵션 (.env)
```bash
MINIO_PORT=9000                  # MinIO API 포트
MINIO_CONSOLE_PORT=9001          # MinIO Console 포트
MINIO_ROOT_USER=minioadmin       # 관리자 사용자
MINIO_ROOT_PASSWORD=minioadmin   # 관리자 비밀번호
MINIO_DEFAULT_BUCKETS=uploads,backups,logs  # 기본 버킷
```

#### 사용 예제
```bash
# 버킷 목록
make minio-buckets

# 파일 업로드
make minio-upload FILE=./test.txt BUCKET=uploads

# 파일 다운로드
make minio-download FILE=test.txt BUCKET=uploads

# S3 CLI 사용
aws s3 ls --endpoint-url http://localhost:9000

# Python boto3 사용
import boto3
s3 = boto3.client('s3',
    endpoint_url='http://localhost:9000',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin'
)
s3.list_buckets()
```

## 🔧 설정

### 포트 설정

모든 포트는 루트 디렉토리의 `.env` 파일에서 중앙 관리됩니다:

```bash
# .env 파일 편집
nano .env

# 예시: 포트 변경
MYSQL_PORT=3307
REDIS_PORT=6380
DYNAMODB_PORT=8001
```

### AWS 프로파일 설정 및 사용법

#### 프로파일 구성 (`aws/profiles.conf`)

`aws/profiles.conf` 파일은 여러 AWS 환경을 관리하기 위한 설정 파일입니다:

```ini
[default]
aws_access_key_id = local
aws_secret_access_key = local
region = ap-northeast-2

[dev]
aws_access_key_id = ${AWS_DEV_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_DEV_SECRET_ACCESS_KEY}
region = ap-northeast-2

[staging]
aws_access_key_id = ${AWS_STAGING_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_STAGING_SECRET_ACCESS_KEY}
region = us-west-2

[prod]
aws_access_key_id = ${AWS_PROD_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_PROD_SECRET_ACCESS_KEY}
region = us-east-1
```

#### `.env` 파일에서 AWS 프로파일 설정

```bash
# 각 프로파일별 자격 증명 설정
AWS_PROFILE_DEV_KEY=your-dev-key
AWS_PROFILE_DEV_SECRET=your-dev-secret
AWS_PROFILE_DEV_REGION=ap-northeast-2

AWS_PROFILE_STAGING_KEY=your-staging-key
AWS_PROFILE_STAGING_SECRET=your-staging-secret
AWS_PROFILE_STAGING_REGION=us-west-2

AWS_PROFILE_PROD_KEY=your-prod-key
AWS_PROFILE_PROD_SECRET=your-prod-secret
AWS_PROFILE_PROD_REGION=us-east-1
```

## 🌐 네트워크

모든 서비스는 `local-infra`라는 공유 Docker 네트워크를 사용합니다:

```bash
# 네트워크 생성 (자동으로 생성됨)
docker network create local-infra

# 네트워크 확인
docker network ls | grep local-infra
```

## 📝 유용한 명령어

### 전체 서비스 관리
```bash
make help            # 도움말
make status          # 모든 서비스 상태
make urls            # 모든 서비스 URL 표시
make up-all          # 모든 서비스 시작
make down-all        # 모든 서비스 중지
make clean-all       # 모든 데이터 삭제 (주의!)
make setup           # 초기 환경 설정
```

### Docker 유지보수 명령어
```bash
# 🧹 정리 명령어
make docker-clean          # 기본 정리 (안전)
make docker-clean-all      # 전체 정리 (주의!)
make docker-fix-space      # 🚨 긴급 공간 확보
make docker-clean-logs     # 로그 파일 비우기
make docker-remove-volumes # 미사용 볼륨 제거

# 📊 모니터링 명령어
make docker-stats          # 실시간 리소스 사용량
make docker-disk           # Docker 디스크 사용량
make docker-logs-size      # 컨테이너 로그 크기
make docker-inspect-size   # 상세 용량 분석
make docker-check          # Docker 시스템 정보

# 🔧 관리 명령어
make docker-pull-all       # 모든 이미지 업데이트
make containers-restart    # 모든 컨테이너 재시작
make containers-stop-all   # 모든 컨테이너 중지
make fix-permissions       # 볼륨 권한 수정
```

### AWS 프로파일 관리
```bash
make aws-profiles    # 사용 가능한 프로파일 목록
make aws-whoami      # 현재 프로파일 확인
make aws-test        # AWS 연결 테스트
make aws-config      # AWS 설정 편집
```

### 개발 프리셋
```bash
make dev             # 기본 개발 환경 (MySQL, Redis, DynamoDB)
make dev-full        # 전체 개발 환경 (모든 서비스 + Admin UI)
```

### 백업 및 복원
```bash
# 모든 서비스 백업
make backup

# 특정 서비스만 백업
make backup-service SERVICE=mysql
make backup-service SERVICE=mongodb

# 백업 복원 (날짜 디렉토리 지정)
make restore BACKUP_DIR=backups/20240101_120000

# 압축 백업
./scripts/backup.sh all --compress
```

### 헬스체크 대시보드
```bash
# 터미널 대시보드 보기
make health

# JSON 형식으로 출력
make health-json

# 스크립트 직접 실행
./scripts/health-check.sh
```

## 🛠️ 트러블슈팅

### Docker 용량 관리

#### 디스크 공간 부족 시
```bash
# 🚨 긴급 공간 확보 (모든 서비스 중지 후 정리)
make docker-fix-space

# 기본 정리 (안전)
make docker-clean

# 전체 정리 (주의: 모든 미사용 리소스 삭제)
make docker-clean-all

# Docker 디스크 사용량 확인
make docker-disk

# 컨테이너 로그 크기 확인
make docker-logs-size

# 로그 파일 비우기
make docker-clean-logs

# 미사용 볼륨 제거
make docker-remove-volumes

# 상세 용량 분석
make docker-inspect-size
```

#### Docker 리소스 모니터링
```bash
# 실시간 리소스 사용량 (CPU, 메모리, 네트워크, I/O)
make docker-stats

# Docker 시스템 정보 확인
make docker-check

# 모든 컨테이너 재시작
make containers-restart

# 모든 Docker 컨테이너 중지 (주의!)
make containers-stop-all
```

#### 이미지 관리
```bash
# 모든 서비스 이미지 업데이트
make docker-pull-all

# 미사용 이미지 제거
docker image prune -af
```

#### 권한 문제 해결
```bash
# 볼륨 권한 문제 수정
make fix-permissions
```

### 포트 충돌
```bash
# .env 파일에서 포트 변경
MYSQL_PORT=3307
REDIS_PORT=6380

# 특정 포트 사용 중인 프로세스 확인
lsof -i :3306  # Mac/Linux
netstat -ano | findstr :3306  # Windows
```

### 서비스가 시작되지 않을 때
```bash
# 개별 서비스 디렉토리에서
make logs            # 로그 확인
make clean           # 데이터 초기화
make up              # 재시작

# 또는 루트에서
make mysql-logs      # MySQL 로그 확인
make redis-logs      # Redis 로그 확인
```

### Docker 리소스 부족
Docker Desktop 설정에서 메모리를 최소 4GB로 설정하세요.

### AWS 프로파일 관련 문제

#### DynamoDB 연결 실패
```bash
# 엔드포인트 URL 확인
aws dynamodb list-tables --endpoint-url http://localhost:8000

# Docker 컨테이너 상태 확인
docker ps | grep dynamodb

# 헬스체크 상태 확인
docker inspect local-dynamodb | grep -A 5 Health
```

### 각 서비스별 문제 해결

#### MySQL 한글 깨짐
```sql
-- docker-compose.yml에 추가
command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

#### Redis 메모리 부족
```bash
# redis.conf 설정 또는 docker-compose.yml에 추가
command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
```

#### MongoDB 인증 실패
```bash
# 데이터 볼륨 초기화 후 재시작
docker volume rm mongodb-data
make mongodb-up
```

#### Kafka 토픽 생성 실패
```bash
# Kafka가 완전히 시작될 때까지 대기
sleep 10
make kafka-topics

# 수동으로 토픽 생성
docker exec -it local-kafka kafka-topics --create \
  --topic test --bootstrap-server localhost:29092 \
  --partitions 1 --replication-factor 1
```

## 📚 예제

### MySQL 접속
```bash
# CLI
make mysql-cli

# 외부 도구 (포트는 .env에서 설정)
mysql -h 127.0.0.1 -P ${MYSQL_PORT} -u root -proot
```

### Redis 사용
```bash
# CLI
make redis-cli

# Python (포트는 .env에서 설정)
import redis
import os
r = redis.Redis(host='localhost', port=int(os.getenv('REDIS_PORT', 6379)))
```

### DynamoDB 사용
```bash
aws dynamodb list-tables \
  --endpoint-url http://localhost:${DYNAMODB_PORT} \
  --region ${AWS_REGION}

# Node.js에서 사용
const AWS = require('aws-sdk');
AWS.config.update({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION,
  endpoint: `http://localhost:${process.env.DYNAMODB_PORT}`
});
```

### Kafka 메시지 발행/소비
```bash
cd kafka
make produce TOPIC=test   # 메시지 발행
make consume TOPIC=test   # 메시지 소비
```

### 프로그래밍 언어별 연결 예제

#### Python
```python
import os
import redis
import pymongo
import mysql.connector
import boto3
from kafka import KafkaProducer, KafkaConsumer

# Redis 연결
r = redis.Redis(
    host='localhost', 
    port=int(os.getenv('REDIS_PORT', 6379)),
    password=os.getenv('REDIS_PASSWORD', None)
)

# MySQL 연결
mysql_conn = mysql.connector.connect(
    host='localhost',
    port=int(os.getenv('MYSQL_PORT', 3306)),
    user=os.getenv('MYSQL_USER', 'admin'),
    password=os.getenv('MYSQL_PASSWORD', 'admin123'),
    database=os.getenv('MYSQL_DATABASE', 'bomcalendar')
)

# MongoDB 연결
mongo_client = pymongo.MongoClient(
    f"mongodb://{os.getenv('MONGO_ROOT_USER', 'root')}:"
    f"{os.getenv('MONGO_ROOT_PASSWORD', 'root123')}@"
    f"localhost:{os.getenv('MONGO_PORT', 27017)}/"
)

# DynamoDB 연결
dynamodb = boto3.resource(
    'dynamodb',
    endpoint_url=f"http://localhost:{os.getenv('DYNAMODB_PORT', 8000)}",
    region_name=os.getenv('AWS_REGION', 'ap-northeast-2'),
    aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID', 'local'),
    aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY', 'local')
)

# Kafka Producer
producer = KafkaProducer(
    bootstrap_servers=f"localhost:{os.getenv('KAFKA_PORT', 9092)}"
)
```

#### Node.js / JavaScript
```javascript
const redis = require('redis');
const mysql = require('mysql2');
const { MongoClient } = require('mongodb');
const AWS = require('aws-sdk');
const { Kafka } = require('kafkajs');

// Redis 연결
const redisClient = redis.createClient({
    host: 'localhost',
    port: process.env.REDIS_PORT || 6379,
    password: process.env.REDIS_PASSWORD
});

// MySQL 연결
const mysqlConnection = mysql.createConnection({
    host: 'localhost',
    port: process.env.MYSQL_PORT || 3306,
    user: process.env.MYSQL_USER || 'admin',
    password: process.env.MYSQL_PASSWORD || 'admin123',
    database: process.env.MYSQL_DATABASE || 'bomcalendar'
});

// MongoDB 연결
const mongoUri = `mongodb://${process.env.MONGO_ROOT_USER || 'root'}:` +
    `${process.env.MONGO_ROOT_PASSWORD || 'root123'}@` +
    `localhost:${process.env.MONGO_PORT || 27017}`;
const mongoClient = new MongoClient(mongoUri);

// DynamoDB 연결
AWS.config.update({
    region: process.env.AWS_REGION || 'ap-northeast-2',
    endpoint: `http://localhost:${process.env.DYNAMODB_PORT || 8000}`,
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'local',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'local'
});
const dynamodb = new AWS.DynamoDB.DocumentClient();

// Kafka 연결
const kafka = new Kafka({
    clientId: 'my-app',
    brokers: [`localhost:${process.env.KAFKA_PORT || 9092}`]
});
```

#### Java / Spring Boot
```yaml
# application.yml
spring:
  # MySQL
  datasource:
    url: jdbc:mysql://localhost:${MYSQL_PORT:3306}/${MYSQL_DATABASE:bomcalendar}
    username: ${MYSQL_USER:admin}
    password: ${MYSQL_PASSWORD:admin123}
  
  # Redis
  redis:
    host: localhost
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD:}
  
  # MongoDB
  data:
    mongodb:
      uri: mongodb://${MONGO_ROOT_USER:root}:${MONGO_ROOT_PASSWORD:root123}@localhost:${MONGO_PORT:27017}/${MONGO_DATABASE:bomcalendar}?authSource=admin
  
  # Kafka
  kafka:
    bootstrap-servers: localhost:${KAFKA_PORT:9092}

# DynamoDB
aws:
  dynamodb:
    endpoint: http://localhost:${DYNAMODB_PORT:8000}
    region: ${AWS_REGION:ap-northeast-2}
    accessKey: ${AWS_ACCESS_KEY_ID:local}
    secretKey: ${AWS_SECRET_ACCESS_KEY:local}
```

## 🎯 특징

- **독립적 관리**: 각 서비스를 개별적으로 시작/중지 가능
- **Admin UI 포함**: 각 서비스별 관리 도구 제공
- **초기화 스크립트**: 자동 스키마/데이터 생성
- **공유 네트워크**: 서비스 간 통신 가능
- **중앙화된 포트 관리**: 루트 .env 파일에서 모든 포트 설정
- **AWS 프로파일 관리**: 여러 AWS 계정 간 쉬운 전환
- **환경별 설정**: dev, staging, prod 환경 지원

## 📄 라이센스

MIT License