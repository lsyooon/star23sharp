-- WARNING: DELETES EXISTING TABLES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
DROP TABLE IF EXISTS group_member;
DROP TABLE IF EXISTS complaint;
DROP TABLE IF EXISTS complaint_reason;
DROP TABLE IF EXISTS nick_book;
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS message_box;
DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS member_group;
DROP TABLE IF EXISTS member;

CREATE TABLE member (
  id                BIGSERIAL        PRIMARY KEY,
  member_name       VARCHAR(16)     NOT NULL UNIQUE,
  password          VARCHAR(255)     NOT NULL,
  complaint_count   INT              NOT NULL DEFAULT 0,
  state             SMALLINT         NOT NULL DEFAULT 0 CHECK (state IN (0, 1, 2)), -- 0: Active, 1: Suspended, 2: Deleted
  nickname          VARCHAR(16)      NOT NULL UNIQUE,
  reactivation_date TIMESTAMP        NULL,
  created_at       TIMESTAMP         NOT NULL,
  role             VARCHAR(255)      NOT NULL DEFAULT ROLE_USER,
  is_push_notification_enabled   BOOLEAN DEFAULT FALSE
);

CREATE TABLE member_group (
    id            BIGSERIAL              PRIMARY KEY,
    group_name    VARCHAR(15)   NULL,
    creator_id    BIGINT        NOT NULL REFERENCES member(id) ON DELETE CASCADE, -- 회원이 삭제되면 그 회원이 저장하고 있던 그룹도 삭제됨
    is_favorite      BOOLEAN    NOT NULL DEFAULT FALSE,
    is_constructed   BOOLEAN    NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMP  NOT NULL
);

CREATE TABLE message (
   id               BIGSERIAL       PRIMARY KEY,
   sender_id        BIGINT          NOT NULL, -- member.id
   receiver_type    SMALLINT        NOT NULL DEFAULT 0 CHECK (receiver_type IN (0, 1, 2, 3)), -- 0: 개인, 1: 미지정 단체, 2: 지정 단체, 3: 불특정 다수(public)
   receiver         BIGINT[]        NULL, -- member의 PK.
   hint_image_first VARCHAR(255)    NULL,
   hint_image_second VARCHAR(255)   NULL,
   dot_hint_image   VARCHAR(255)    NULL,
   title            VARCHAR(15)     NOT NULL,
   content          VARCHAR(100)    NULL,
   hint             VARCHAR(20)     NULL,
   lat              FLOAT8          NULL, --위도 latitude
   lng              FLOAT8          NULL, --경도 longitude
   coordinate       VECTOR(3)       NULL, --xyz
   is_treasure      BOOLEAN         NOT NULL DEFAULT FALSE,
   is_found         BOOLEAN         NOT NULL DEFAULT FALSE,
   created_at       TIMESTAMP       NOT NULL,
   image            VARCHAR(255)    NULL,
   vector           VECTOR(12288)   NULL,
   group_id         BIGINT          NULL REFERENCES member_group(id) ON DELETE SET NULL
);

CREATE TABLE message_box (
   id                BIGSERIAL     PRIMARY KEY,
   message_id        BIGINT        NOT NULL REFERENCES message(id) ON DELETE CASCADE,
   member_id         BIGINT        NOT NULL REFERENCES member(id) ON DELETE CASCADE,
   is_deleted        BOOLEAN       NOT NULL DEFAULT FALSE,
   message_direction SMALLINT      NOT NULL CHECK (message_direction IN (0, 1)), -- 발신: 0, 수신: 1
   state             BOOLEAN       NULL DEFAULT FALSE, -- 메시지 확인 시 true
   created_at       TIMESTAMP      NOT NULL,
   is_reported       BOOLEAN       DEFAULT FALSE
);

CREATE TABLE notification (
    id          BIGSERIAL       PRIMARY KEY,
    member_id   BIGINT          NULL REFERENCES member(id) ON DELETE CASCADE, -- 멤버 삭제 시 알림도 함께 삭제
    title       VARCHAR(15)     NOT NULL,
    content     TEXT            NOT NULL,
    is_read     BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    message_id  BIGINT          DEFAULT NULL REFERENCES message(id) ON DELETE CASCADE, -- 메시지 삭제 시 알림도 삭제
    image       VARCHAR(255)
);

CREATE TABLE nick_book (
    id        BIGSERIAL       PRIMARY KEY,
    member_id BIGINT          NOT NULL REFERENCES member(id) ON DELETE CASCADE,
    nickname  VARCHAR(20)     NOT NULL,
    name      VARCHAR(20)     NULL
);

CREATE TABLE complaint_reason (
    id               SMALLSERIAL     PRIMARY KEY,
    complaint_reason VARCHAR(50)     NOT NULL
);

CREATE TABLE complaint (
    id                   BIGSERIAL      PRIMARY KEY,
    reporter_id          BIGINT         NOT NULL, -- member.id
    reported_id          BIGINT         NOT NULL, -- member.id
    state                SMALLINT       NOT NULL CHECK (state IN (0, 1, 2)), -- 0: 미처리, 1: 반려, 2: 처리
    message_id           BIGINT         NOT NULL REFERENCES message(id),
    complaint_reason_id  SMALLINT      NOT NULL REFERENCES complaint_reason(id),
    created_at  TIMESTAMP       NOT NULL
);

CREATE TABLE group_member (
    id            BIGSERIAL     PRIMARY KEY,
    group_id      BIGINT        NOT NULL REFERENCES member_group(id) ON DELETE CASCADE, -- 그룹 삭제 시 그룹 멤버도 삭제
    member_id     BIGINT        NOT NULL REFERENCES member(id) ON DELETE CASCADE -- 회원 삭제 시 그룹에서도 삭제
);
