create extension if not exists pgcrypto;

create table if not exists policy_status (
    id int primary key not null,
    name varchar(255) not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone not null
);

create table if not exists campaign (
    id int primary key not null,
    external_id uuid not null,
    name varchar(255) not null,
    commission_percentage numeric(10, 2) not null default 0,
    status_id integer not null default 1,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone not null
);

create table if not exists coverage (
    id serial primary key not null,
    external_id uuid not null,
    name varchar(255) not null,
    description text null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone not null
);

create table if not exists policy (
    id int primary key not null,
    external_id uuid not null,
    campaign_id integer not null,
    status_id integer not null,
    policy_number varchar(255) null,
    effective_date timestamp with time zone not null,
    expiry_date timestamp with time zone not null,
    gross_premium numeric(12, 6) not null,
    iof numeric(12, 6) not null,
    commission numeric(12, 6) not null,
    issue_date timestamp with time zone null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone not null,

    constraint fk_policy_campaign
        foreign key (campaign_id)
        references campaign (id),

    constraint fk_policy_policy_status
        foreign key (status_id)
        references policy_status (id)
);

create table if not exists policy_coverage (
    id int primary key not null,
    external_id uuid not null,
    coverage_id integer not null,
    gross_premium numeric(12, 6) not null,
    iof numeric(12, 6) not null,
    sum_insured numeric(12, 6) not null,
    effective_date timestamp with time zone not null,
    expiry_date timestamp with time zone not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone not null,
    policy_id integer not null,

    constraint fk_policy_coverage_coverage
        foreign key (coverage_id)
        references coverage (id),

    constraint fk_policy_coverage_policy
        foreign key (policy_id)
        references policy (id)
);

create table if not exists policy_beneficiary (
    id int primary key not null,
    external_id uuid not null,
    policy_id int not null,
    name varchar(255) not null,
    date_of_birth date not null,
    document varchar(255) not null,
    document_type integer not null,
    phone_number varchar(255) null,
    gender varchar(1) null,
    email varchar(255) null,
    zip_code varchar(255) null,
    street varchar(255) null,
    district varchar(255) null,
    state varchar(255) null,
    city varchar(255) null,
    street_number varchar(255) null,
    complement varchar(255) null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone not null,

    constraint fk_policy_beneficiary_policy
        foreign key (policy_id)
        references policy (id)
);

create table if not exists endorsement (
    id int primary key not null,
    external_id uuid not null,
    campaign_id int not null,
    endorsement_number character varying(255) not null,
    gross_premium numeric(12, 6) not null,
    iof numeric(12, 6) not null,
    commission numeric(12, 6) not null,
    effective_date timestamp with time zone not null,
    expiry_date timestamp with time zone not null,
    issue_date timestamp with time zone null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone not null,
    policy_id int not null,

    constraint fk_endorsement_policy
        foreign key (policy_id)
        references policy (id)
);