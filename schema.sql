-- ============================================================
--  Attendance Tracker — Supabase schema
--  Run this in your Supabase Dashboard → SQL Editor → New query.
--  Safe to re-run (drops/recreates policies each time).
-- ============================================================

-- ---------- Tables ----------

create table if not exists public.people (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name       text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.visits (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  person_id  uuid not null references public.people (id) on delete cascade,
  date       date not null,
  time24     text not null,          -- 24h "HH:MM", e.g. "09:30" or "14:05"
  created_at timestamptz not null default now()
);

create table if not exists public.notes (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  visit_id   uuid not null references public.visits (id) on delete cascade,
  text       text not null,
  created_at timestamptz not null default now()
);

-- ---------- Indexes ----------

create index if not exists people_user_idx   on public.people (user_id);
create index if not exists visits_person_idx on public.visits (person_id);
create index if not exists visits_user_idx   on public.visits (user_id);
create index if not exists notes_visit_idx   on public.notes  (visit_id);
create index if not exists notes_user_idx    on public.notes  (user_id);

-- ---------- Row Level Security ----------
-- Every account can read/write only its own rows.

alter table public.people enable row level security;
alter table public.visits enable row level security;
alter table public.notes  enable row level security;

-- people
drop policy if exists "people_select" on public.people;
drop policy if exists "people_insert" on public.people;
drop policy if exists "people_update" on public.people;
drop policy if exists "people_delete" on public.people;
create policy "people_select" on public.people for select using (auth.uid() = user_id);
create policy "people_insert" on public.people for insert with check (auth.uid() = user_id);
create policy "people_update" on public.people for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "people_delete" on public.people for delete using (auth.uid() = user_id);

-- visits
drop policy if exists "visits_select" on public.visits;
drop policy if exists "visits_insert" on public.visits;
drop policy if exists "visits_update" on public.visits;
drop policy if exists "visits_delete" on public.visits;
create policy "visits_select" on public.visits for select using (auth.uid() = user_id);
create policy "visits_insert" on public.visits for insert with check (auth.uid() = user_id);
create policy "visits_update" on public.visits for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "visits_delete" on public.visits for delete using (auth.uid() = user_id);

-- notes
drop policy if exists "notes_select" on public.notes;
drop policy if exists "notes_insert" on public.notes;
drop policy if exists "notes_update" on public.notes;
drop policy if exists "notes_delete" on public.notes;
create policy "notes_select" on public.notes for select using (auth.uid() = user_id);
create policy "notes_insert" on public.notes for insert with check (auth.uid() = user_id);
create policy "notes_update" on public.notes for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "notes_delete" on public.notes for delete using (auth.uid() = user_id);
