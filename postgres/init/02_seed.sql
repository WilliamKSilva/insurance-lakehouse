insert into policy_status (
    id,
    name,
    created_at,
    updated_at
)
values
    (1, 'active', now(), now()),
    (2, 'cancelled', now(), now()),
    (3, 'expired', now(), now());

insert into campaign (
    id,
    external_id,
    name,
    commission_percentage,
    status_id,
    created_at,
    updated_at
)
values
    (1, gen_random_uuid(), 'Acidentes Pessoais (APE)', 15.00, 1, now(), now()),
    (2, gen_random_uuid(), 'Carro', 10.00, 1, now(), now());

insert into coverage (
    id,
    external_id,
    name,
    description,
    created_at,
    updated_at
)
values
    (1, gen_random_uuid(), 'roubo e furto', 'cobertura contra roubo e furto do bem segurado', now(), now()),
    (2, gen_random_uuid(), 'danos acidentais', 'cobertura contra danos físicos acidentais', now(), now()),
    (3, gen_random_uuid(), 'morte acidental', 'cobertura para morte acidental do segurado', now(), now()),
    (4, gen_random_uuid(), 'invalidez permanente', 'cobertura para invalidez permanente por acidente', now(), now());

select setval(
    pg_get_serial_sequence('coverage', 'id'),
    coalesce((select max(id) from coverage), 1)
);

insert into policy (
    id,
    external_id,
    campaign_id,
    status_id,
    policy_number,
    effective_date,
    expiry_date,
    gross_premium,
    iof,
    commission,
    issue_date,
    created_at,
    updated_at
)
values
    (
        1001,
        gen_random_uuid(),
        1,
        1,
        'pol-2026-000001',
        timestamp with time zone '2026-01-01 00:00:00-03',
        timestamp with time zone '2027-01-01 00:00:00-03',
        120.000000,
        8.560000,
        18.000000,
        timestamp with time zone '2026-01-01 10:00:00-03',
        now(),
        now()
    ),
    (
        1002,
        gen_random_uuid(),
        2,
        1,
        'pol-2026-000002',
        timestamp with time zone '2026-02-01 00:00:00-03',
        timestamp with time zone '2027-02-01 00:00:00-03',
        180.000000,
        12.840000,
        27.000000,
        timestamp with time zone '2026-02-01 11:00:00-03',
        now(),
        now()
    );

insert into policy_coverage (
    id,
    external_id,
    coverage_id,
    gross_premium,
    iof,
    sum_insured,
    effective_date,
    expiry_date,
    created_at,
    updated_at,
    policy_id
)
values
    (
        5001,
        gen_random_uuid(),
        3,
        80.000000,
        5.700000,
        5000.000000,
        timestamp with time zone '2026-01-01 00:00:00-03',
        timestamp with time zone '2027-01-01 00:00:00-03',
        now(),
        now(),
        1001

    ),
    (
        5002,
        gen_random_uuid(),
        4,
        40.000000,
        2.860000,
        3000.000000,
        timestamp with time zone '2026-01-01 00:00:00-03',
        timestamp with time zone '2027-01-01 00:00:00-03',
        now(),
        now(),
        1001
    ),
    (
        5003,
        gen_random_uuid(),
        1,
        120.000000,
        8.560000,
        8000.000000,
        timestamp with time zone '2026-02-01 00:00:00-03',
        timestamp with time zone '2027-02-01 00:00:00-03',
        now(),
        now(),
        1002
    ),
    (
        5004,
        gen_random_uuid(),
        2,
        60.000000,
        4.280000,
        10000.000000,
        timestamp with time zone '2026-02-01 00:00:00-03',
        timestamp with time zone '2027-02-01 00:00:00-03',
        now(),
        now(),
        1002
    );

insert into policy_beneficiary (
    id,
    external_id,
    policy_id,
    name,
    date_of_birth,
    document,
    document_type,
    phone_number,
    gender,
    email,
    zip_code,
    street,
    district,
    state,
    city,
    street_number,
    complement,
    created_at,
    updated_at
)
values
    (
        9001,
        gen_random_uuid(),
        1001,
        'joao silva',
        date '1990-05-12',
        '12345678901',
        1,
        '11999990001',
        'm',
        'joao.silva@email.com',
        '12230000',
        'rua das flores',
        'centro',
        'sp',
        'sao jose dos campos',
        '100',
        null,
        now(),
        now()
    ),
    (
        9002,
        gen_random_uuid(),
        1002,
        'maria oliveira',
        date '1988-09-20',
        '23456789012',
        1,
        '11999990002',
        'f',
        'maria.oliveira@email.com',
        '12240000',
        'avenida brasil',
        'jardim paulista',
        'sp',
        'sao jose dos campos',
        '250',
        'apto 12',
        now(),
        now()
    );