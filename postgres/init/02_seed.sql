-- seed.sql
-- Seeder único para popular dados de exemplo.
-- Regra de coberturas:
-- campaign_id = 1 -> coverage_id 3 e 4
-- campaign_id = 2 -> coverage_id 1 e 2

begin;

create extension if not exists pgcrypto;

insert into policy_status (
    id,
    name,
    created_at,
    updated_at
)
values
    (1, 'active', now(), now()),
    (2, 'cancelled', now(), now()),
    (3, 'expired', now(), now())
on conflict (id) do nothing;

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
    (2, gen_random_uuid(), 'Carro', 10.00, 1, now(), now())
on conflict (id) do nothing;

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
    (4, gen_random_uuid(), 'invalidez permanente', 'cobertura para invalidez permanente por acidente', now(), now())
on conflict (id) do nothing;

select setval(
    pg_get_serial_sequence('coverage', 'id'),
    coalesce((select max(id) from coverage), 1)
);

-- ============================================================
-- POLICIES - CAMPANHA 1
-- Gera 500 apólices da campanha Acidentes Pessoais
-- IDs: 100001 até 100500
-- ============================================================

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
select
    100000 + gs.n as id,
    gen_random_uuid() as external_id,
    1 as campaign_id,
    case
        when gs.n % 20 = 0 then 2
        when gs.n % 15 = 0 then 3
        else 1
    end as status_id,
    'ape-2026-' || lpad(gs.n::text, 6, '0') as policy_number,
    timestamp with time zone '2026-01-01 00:00:00-03' + ((gs.n - 1) * interval '1 day') as effective_date,
    timestamp with time zone '2026-01-01 00:00:00-03' + ((gs.n - 1) * interval '1 day') + interval '1 year' as expiry_date,
    round((120 + (gs.n * 1.75))::numeric, 6) as gross_premium,
    round(((120 + (gs.n * 1.75)) * 0.0713)::numeric, 6) as iof,
    round(((120 + (gs.n * 1.75)) * 0.15)::numeric, 6) as commission,
    timestamp with time zone '2026-01-01 10:00:00-03' + ((gs.n - 1) * interval '1 day') as issue_date,
    now() as created_at,
    now() as updated_at
from generate_series(1, 500) as gs(n)
on conflict (id) do nothing;

-- ============================================================
-- POLICIES - CAMPANHA 2
-- Gera 500 apólices da campanha Carro
-- IDs: 200001 até 200500
-- ============================================================

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
select
    200000 + gs.n as id,
    gen_random_uuid() as external_id,
    2 as campaign_id,
    case
        when gs.n % 25 = 0 then 2
        when gs.n % 18 = 0 then 3
        else 1
    end as status_id,
    'car-2026-' || lpad(gs.n::text, 6, '0') as policy_number,
    timestamp with time zone '2026-02-01 00:00:00-03' + ((gs.n - 1) * interval '1 day') as effective_date,
    timestamp with time zone '2026-02-01 00:00:00-03' + ((gs.n - 1) * interval '1 day') + interval '1 year' as expiry_date,
    round((250 + (gs.n * 2.50))::numeric, 6) as gross_premium,
    round(((250 + (gs.n * 2.50)) * 0.0713)::numeric, 6) as iof,
    round(((250 + (gs.n * 2.50)) * 0.10)::numeric, 6) as commission,
    timestamp with time zone '2026-02-01 10:00:00-03' + ((gs.n - 1) * interval '1 day') as issue_date,
    now() as created_at,
    now() as updated_at
from generate_series(1, 500) as gs(n)
on conflict (id) do nothing;

-- ============================================================
-- POLICY COVERAGES
-- Gera 2 coberturas por apólice.
--
-- campaign_id = 1:
--   coverage_id 3 = morte acidental
--   coverage_id 4 = invalidez permanente
--
-- campaign_id = 2:
--   coverage_id 1 = roubo e furto
--   coverage_id 2 = danos acidentais
--
-- Total: 2.000 policy_coverages
-- ============================================================

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
select
    (p.id * 10) + c.seq as id,
    gen_random_uuid() as external_id,
    c.coverage_id,
    round((p.gross_premium * c.premium_percentage)::numeric, 6) as gross_premium,
    round((p.iof * c.premium_percentage)::numeric, 6) as iof,
    c.sum_insured,
    p.effective_date,
    p.expiry_date,
    now() as created_at,
    now() as updated_at,
    p.id as policy_id
from policy p
cross join lateral (
    values
        (
            1,
            case
                when p.campaign_id = 1 then 3
                when p.campaign_id = 2 then 1
            end,
            0.65::numeric,
            case
                when p.campaign_id = 1 then 10000.000000 + ((p.id % 1000) * 50)
                when p.campaign_id = 2 then 30000.000000 + ((p.id % 1000) * 80)
            end
        ),
        (
            2,
            case
                when p.campaign_id = 1 then 4
                when p.campaign_id = 2 then 2
            end,
            0.35::numeric,
            case
                when p.campaign_id = 1 then 8000.000000 + ((p.id % 1000) * 40)
                when p.campaign_id = 2 then 20000.000000 + ((p.id % 1000) * 60)
            end
        )
) as c(seq, coverage_id, premium_percentage, sum_insured)
where p.id between 100001 and 100500
   or p.id between 200001 and 200500
on conflict (id) do nothing;

-- ============================================================
-- POLICY BENEFICIARIES
-- Gera 1 beneficiário por apólice.
-- Total: 1.000 beneficiários
-- ============================================================

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
select
    p.id + 800000 as id,
    gen_random_uuid() as external_id,
    p.id as policy_id,
    case (p.id % 20)
        when 0 then 'joao silva'
        when 1 then 'maria oliveira'
        when 2 then 'pedro santos'
        when 3 then 'ana costa'
        when 4 then 'carlos pereira'
        when 5 then 'juliana almeida'
        when 6 then 'rafael souza'
        when 7 then 'beatriz lima'
        when 8 then 'marcos rocha'
        when 9 then 'fernanda castro'
        when 10 then 'lucas martins'
        when 11 then 'camila ferreira'
        when 12 then 'bruno ribeiro'
        when 13 then 'larissa mendes'
        when 14 then 'thiago barbosa'
        when 15 then 'patricia nunes'
        when 16 then 'gabriel cardoso'
        when 17 then 'amanda vieira'
        when 18 then 'felipe moreira'
        else 'carolina araujo'
    end || ' ' || p.id as name,
    date '1980-01-01' + ((p.id % 10000)::int) as date_of_birth,
    lpad(((10000000000 + p.id) % 99999999999)::text, 11, '0') as document,
    1 as document_type,
    '1199' || lpad((p.id % 10000000)::text, 7, '0') as phone_number,
    case when p.id % 2 = 0 then 'f' else 'm' end as gender,
    'beneficiario.' || p.id || '@email.com' as email,
    case
        when p.id % 3 = 0 then '01001000'
        when p.id % 3 = 1 then '12230000'
        else '13010000'
    end as zip_code,
    case
        when p.id % 3 = 0 then 'praca da se'
        when p.id % 3 = 1 then 'rua das flores'
        else 'rua barao de jaguara'
    end as street,
    case
        when p.id % 3 = 0 then 'se'
        else 'centro'
    end as district,
    'sp' as state,
    case
        when p.id % 3 = 0 then 'sao paulo'
        when p.id % 3 = 1 then 'sao jose dos campos'
        else 'campinas'
    end as city,
    (100 + (p.id % 900))::text as street_number,
    null as complement,
    now() as created_at,
    now() as updated_at
from policy p
where p.id between 100001 and 100500
   or p.id between 200001 and 200500
on conflict (id) do nothing;

-- ============================================================
-- ENDORSEMENTS
-- Gera endossos para uma parte das apólices, apenas para ter massa de dados.
-- Total aproximado: 200 endossos
-- ============================================================

insert into endorsement (
    id,
    external_id,
    campaign_id,
    endorsement_number,
    gross_premium,
    iof,
    commission,
    effective_date,
    expiry_date,
    issue_date,
    created_at,
    updated_at,
    policy_id
)
select
    p.id + 900000 as id,
    gen_random_uuid() as external_id,
    p.campaign_id,
    'end-2026-' || p.policy_number as endorsement_number,
    round((p.gross_premium * 0.10)::numeric, 6) as gross_premium,
    round((p.iof * 0.10)::numeric, 6) as iof,
    round((p.commission * 0.10)::numeric, 6) as commission,
    p.effective_date + interval '30 days' as effective_date,
    p.expiry_date as expiry_date,
    p.issue_date + interval '30 days' as issue_date,
    now() as created_at,
    now() as updated_at,
    p.id as policy_id
from policy p
where (
        p.id between 100001 and 100500
        or p.id between 200001 and 200500
    )
  and p.id % 5 = 0
on conflict (id) do nothing;

commit;
