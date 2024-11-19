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

-- auto-generated definition
create table member
(
    id                           bigserial
        primary key,
    member_name                  varchar(16)                                         not null
        unique,
    password                     varchar(255)                                        not null,
    complaint_count              integer      default 0 not null,
    state smallint default 0                                                         not null
        constraint member_state_check
            check (state = ANY (ARRAY [0, 1, 2])),
    nickname                     varchar(16)                                         not null
        unique,
    reactivation_date            timestamp,
    created_at                   timestamp    default CURRENT_TIMESTAMP              not null,
    role                         varchar(255) default 'ROLE_USER'::character varying not null,
    is_push_notification_enabled boolean      default false
);


-- auto-generated definition
create table member_group
(
    id             bigserial
        primary key,
    group_name     varchar(15),
    creator_id     bigint                              not null
        references member
            on delete cascade,
    is_favorite    boolean   default false             not null,
    is_constructed boolean   default false             not null,
    created_at     timestamp default CURRENT_TIMESTAMP not null
);

create index member_group_id_is_constructed
    on member_group (id, is_constructed);


-- auto-generated definition
create table message
(
    id                bigserial
        primary key,
    sender_id         bigint                    not null,
    receiver_type     smallint    default 0     not null
        constraint message_receiver_type_check
            check (receiver_type = ANY (ARRAY [0, 1, 2, 3])),
    hint_image_first  varchar(255),
    hint_image_second varchar(255),
    dot_hint_image    varchar(255),
    title             varchar(15)               not null,
    content           varchar(150)              not null,
    hint              varchar(20) default '힌트가 없어요 ㅠ0ㅠ'::character varying,
    lat               double precision,
    lng               double precision,
    coordinate        vector(3),
    is_treasure       boolean     default false not null,
    is_found          boolean     default false not null,
    created_at        timestamp                 not null,
    image             varchar(255),
    vector            vector(12288),
    group_id          bigint
                                                references member_group
                                                    on delete set null,
    receiver          bigint[]
);

create index message_id_receiver_type_index
    on message (id, receiver_type);

create index message_is_treasure__index
    on message (is_treasure);

create index message_receiver_type_index
    on message (receiver_type);


-- auto-generated definition
create table message_box
(
    id                bigserial
        primary key,
    message_id        bigint                              not null
        references message
            on delete cascade,
    member_id         bigint                              not null
        references member
            on delete cascade,
    is_deleted        boolean   default false             not null,
    message_direction smallint                            not null
        constraint message_box_message_direction_check
            check (message_direction = ANY (ARRAY [0, 1])),
    state             boolean   default false,
    created_at        timestamp default CURRENT_TIMESTAMP not null,
    is_reported       boolean   default false
);

create index message_box_message_id_message_direction_index
    on message_box (message_id, message_direction);

create index message_box_member_id_message_direction_is_deleted_index
    on message_box (member_id, message_direction, is_deleted);

create index message_box_messageid_index
    on message_box (message_id);


-- auto-generated definition
create table notification
(
    id         bigserial
        primary key,
    member_id  bigint
        references member
            on delete cascade,
    title      varchar(100)                        not null,
    content    text                                not null,
    is_read    boolean   default false             not null,
    created_at timestamp default CURRENT_TIMESTAMP not null,
    message_id bigint
        references message
            on delete cascade,
    image      varchar(255),
    hint       varchar(20)
);

create table nick_book
(
    id        bigserial
        primary key,
    member_id bigint      not null
        references member
            on delete cascade,
    nickname  varchar(20) not null,
    name      varchar(20),
    constraint unique_member_nickname
        unique (member_id, nickname)
);

create table complaint_reason
(
    id               smallserial
        primary key,
    complaint_reason varchar(50) not null
);

create table complaint
(
    id                  bigserial
        primary key,
    reporter_id         bigint                              not null,
    reported_id         bigint                              not null,
    state               smallint                            not null
        constraint complaint_state_check
            check (state = ANY (ARRAY [0, 1, 2])),
    message_id          bigint                              not null
        references message,
    complaint_reason_id smallint                            not null
        references complaint_reason,
    created_at          timestamp default CURRENT_TIMESTAMP not null
);

create table group_member
(
    id        bigserial
        primary key,
    group_id  bigint not null
        references member_group
            on delete cascade,
    member_id bigint not null
        references member
            on delete cascade
);

create index group_member_member_id_fk
    on group_member (member_id);
