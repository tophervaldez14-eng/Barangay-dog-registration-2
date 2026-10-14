-- Barangay Dog Registration System - Supabase SQL schema
-- Run this in Supabase Dashboard > SQL Editor.
-- This schema enables authenticated staff to use the shared login.
-- Do not use real resident data until the barangay has approved the privacy/security setup.

create extension if not exists pgcrypto;

create table if not exists public.owners (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  phone text,
  purok text not null,
  address text,
  created_at timestamptz not null default now(),
  created_by uuid default auth.uid()
);

create table if not exists public.dogs (
  id uuid primary key default gen_random_uuid(),
  registration_no text unique not null default (
    'DOG-' || to_char(current_date, 'YYYY') || '-' ||
    upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))
  ),
  owner_id uuid not null references public.owners(id) on delete restrict,
  dog_name text not null,
  breed text,
  sex text check (sex in ('Male','Female','Unknown') or sex is null),
  color text,
  birth_date date,
  registration_date date not null default current_date,
  vaccination_status text not null default 'Unknown'
    check (vaccination_status in ('Vaccinated','Unvaccinated','Unknown')),
  vaccination_date date,
  next_vaccination_date date,
  notes text,
  created_at timestamptz not null default now(),
  created_by uuid default auth.uid()
);

create table if not exists public.vaccination_records (
  id uuid primary key default gen_random_uuid(),
  dog_id uuid not null references public.dogs(id) on delete cascade,
  vaccine_type text,
  vaccination_date date,
  next_vaccination_date date,
  vaccinator text,
  notes text,
  created_at timestamptz not null default now(),
  created_by uuid default auth.uid()
);

create index if not exists owners_name_idx on public.owners (lower(full_name));
create index if not exists owners_purok_idx on public.owners (purok);
create index if not exists dogs_owner_id_idx on public.dogs (owner_id);
create index if not exists dogs_registration_no_idx on public.dogs (registration_no);
create index if not exists dogs_vaccination_status_idx on public.dogs (vaccination_status);
create index if not exists vaccination_dog_id_idx on public.vaccination_records (dog_id);

alter table public.owners enable row level security;
alter table public.dogs enable row level security;
alter table public.vaccination_records enable row level security;

drop policy if exists "Authenticated staff can read owners" on public.owners;
create policy "Authenticated staff can read owners" on public.owners
  for select to authenticated using (true);
drop policy if exists "Authenticated staff can add owners" on public.owners;
create policy "Authenticated staff can add owners" on public.owners
  for insert to authenticated with check (true);
drop policy if exists "Authenticated staff can update owners" on public.owners;
create policy "Authenticated staff can update owners" on public.owners
  for update to authenticated using (true) with check (true);

drop policy if exists "Authenticated staff can read dogs" on public.dogs;
create policy "Authenticated staff can read dogs" on public.dogs
  for select to authenticated using (true);
drop policy if exists "Authenticated staff can add dogs" on public.dogs;
create policy "Authenticated staff can add dogs" on public.dogs
  for insert to authenticated with check (true);
drop policy if exists "Authenticated staff can update dogs" on public.dogs;
create policy "Authenticated staff can update dogs" on public.dogs
  for update to authenticated using (true) with check (true);

drop policy if exists "Authenticated staff can read vaccination records" on public.vaccination_records;
create policy "Authenticated staff can read vaccination records" on public.vaccination_records
  for select to authenticated using (true);
drop policy if exists "Authenticated staff can add vaccination records" on public.vaccination_records;
create policy "Authenticated staff can add vaccination records" on public.vaccination_records
  for insert to authenticated with check (true);
drop policy if exists "Authenticated staff can update vaccination records" on public.vaccination_records;
create policy "Authenticated staff can update vaccination records" on public.vaccination_records
  for update to authenticated using (true) with check (true);

-- Note: Shared-account setup is convenient for a prototype but weak for accountability.
-- Before production, consider individual accounts, audit logs, restricted permissions,
-- and an approved privacy notice/retention policy.
