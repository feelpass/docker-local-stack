# Docker Local Infrastructure

각 서비스별로 독립적으로 관리되는 Docker 기반 로컬 인프라 구축 프로젝트입니다.
AWS 프로파일 관리 기능과 유연한 포트 설정을 지원합니다.

## 📁 프로젝트 구조

```
docker-infra/
├── Makefile           # 루트 Makefile (전체 서비스 관리)
├── mysql/             # MySQL 서비스
│   ├── docker-compose.yml
│   ├── Makefile
│   ├── .env.example
│   └── init/
├── redis/             # Redis 서비스
│   ├── docker-compose.yml
│   ├── Makefile
│   └── .env.example
├── dynamodb/          # DynamoDB 서비스
│   ├── docker-compose.yml
│   ├── Makefile
│   ├── .env.example
│   └── init.sh
├── mongodb/           # MongoDB 서비스
│   ├── docker-compose.yml
│   ├── Makefile
│   ├── .env.example
│   └── init/
└── kafka/             # Kafka 서비스
    ├── docker-compose.yml
    ├── Makefile
    └── .env.example
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

### AWS 프로파일 설정

여러 AWS 계정을 관리하고 전환할 수 있습니다:

```bash
# .env 파일에서 AWS 프로파일 설정
AWS_PROFILE_DEV_KEY=your-dev-key
AWS_PROFILE_DEV_SECRET=your-dev-secret
AWS_PROFILE_DEV_REGION=ap-northeast-2

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

### AWS 프로파일 관리
```bash
make aws-profiles    # 사용 가능한 프로파일 목록
make aws-profile PROFILE=dev     # dev 프로파일로 전환
make aws-profile PROFILE=staging # staging 프로파일로 전환
make aws-profile PROFILE=prod    # prod 프로파일로 전환
make aws-whoami      # 현재 프로파일 확인
make aws-test        # AWS 연결 테스트
make aws-config      # AWS 설정 편집
```

### 개발 프리셋
```bash
make dev             # 기본 개발 환경 (MySQL, Redis, DynamoDB)
make dev-full        # 전체 개발 환경 (모든 서비스 + Admin UI)
```

## 🛠️ 트러블슈팅

### 포트 충돌
```bash
# .env 파일에서 포트 변경
MYSQL_PORT=3307
REDIS_PORT=6380
```

### 서비스가 시작되지 않을 때
```bash
# 개별 서비스 디렉토리에서
make logs            # 로그 확인
make clean           # 데이터 초기화
make up              # 재시작
```

### Docker 리소스 부족
Docker Desktop 설정에서 메모리를 최소 4GB로 설정하세요.

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
# AWS 프로파일 전환 후 사용
make aws-profile PROFILE=dev
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

### AWS 프로파일 전환 예제
```bash
# 개발 환경으로 전환
make aws-profile PROFILE=dev
make dynamodb-up
make dynamodb-init

# 스테이징 환경으로 전환
make aws-profile PROFILE=staging
# DynamoDB 테이블이 스테이징 credentials로 생성됨

# 프로덕션 환경으로 전환
make aws-profile PROFILE=prod
# 주의: 프로덕션 credentials 사용
```

### Kafka 메시지 발행/소비
```bash
cd kafka
make produce TOPIC=test   # 메시지 발행
make consume TOPIC=test   # 메시지 소비
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