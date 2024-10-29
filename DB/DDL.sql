-- WARNING: DELETES EXISTING TABLES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
DROP TABLE IF EXISTS custom_names;
DROP TABLE IF EXISTS user_reports;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS message_recipients;
DROP TABLE IF EXISTS messages_sent;
DROP TABLE IF EXISTS treasure_messages;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS group_members;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id BIGSERIAL PRIMARY KEY,
    member_name VARCHAR(255) NOT NULL UNIQUE, -- Unique username/login ID
    password VARCHAR(255) NOT NULL,
    state SMALLINT DEFAULT 0 NOT NULL CHECK (state IN (0, 1, 2)), -- 0: Active, 1: Suspended, 2: Deleted
    nickname VARCHAR(255) NOT NULL UNIQUE,
    reactivation_date TIMESTAMP NULL, -- Suspended without reactivation date -> permaban
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    owner_id BIGINT NULL REFERENCES members(id) on delete set NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE group_members (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) on delete CASCADE,
    member_id BIGINT NOT NULL REFERENCES members(id) on delete CASCADE,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    writer_id BIGINT NULL REFERENCES members(id) on delete set NULL,
    is_treasure Boolean not null default false,
    title VARCHAR(50) NULL,
    content TEXT NULL,
    image VARCHAR(255) null,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE treasure_messages (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT not null references messages(id) on delete cascade, --needs to be indexed
    hint_image VARCHAR(255) NOT NULL,
    hint_vector VECTOR(12288) NOT NULL,
    hint_text VARCHAR(100) NULL,
    dot_hint_image VARCHAR(255) NOT NULL,
    coordinate VECTOR(2) NOT NULL,
    found_by BIGINT NULL REFERENCES members(id) on delete set null,
    found_at TIMESTAMP NULL
);

CREATE TABLE messages_sent (
    id BIGSERIAL PRIMARY KEY,
    sender_id BIGINT NULL REFERENCES members(id) on delete set null,
    message_id BIGINT NULL REFERENCES messages(id) on delete set null,
    is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
    is_public BOOLEAN DEFAULT TRUE NOT NULL,
    to_group BIGINT NULL REFERENCES groups(id),
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE message_recipients (
    id BIGSERIAL PRIMARY KEY,
    sent_id BIGINT NOT NULL REFERENCES messages_sent(id) on delete cascade,
    recipient_id BIGINT NULL REFERENCES members(id) on delete set null,
    is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    read_at TIMESTAMP NULL
);

CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    member_id BIGINT NULL REFERENCES members(id) on delete set null,
    title VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE user_reports (
    id BIGSERIAL PRIMARY KEY,
    reporter_id BIGINT NULL REFERENCES members(id) on delete set null,
    reported_id BIGINT NULL REFERENCES members(id) on delete set null,
    recep_id BIGINT NOT NULL REFERENCES message_recipients(id) on delete set null,
    content TEXT NOT NULL,
    state SMALLINT DEFAULT 0 NOT NULL CHECK (state IN (0, 1, 2)), -- 0: Pending, 1: Rejected, 2: Processed
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE custom_names (
    member_id BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    contact_member_id BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    nickname VARCHAR(20) NOT NULL,
    name VARCHAR(50) NULL,
    PRIMARY KEY (member_id, contact_member_id)
);

-- Indexes for performance optimization
--CREATE INDEX idx_messages_writer_id ON messages (writer_id);
--CREATE INDEX idx_messages_sent_sender_id ON messages_sent (sender_id);
--CREATE INDEX idx_message_recipients_recipient_id ON message_recipients (recipient_id);
--CREATE INDEX idx_notifications_member_id ON notifications (member_id);
--CREATE INDEX idx_user_reports_reporter_id ON user_reports (reporter_id);
--CREATE INDEX idx_user_reports_reported_id ON user_reports (reported_id);
--CREATE INDEX idx_custom_names_member_id ON custom_names (member_id);
