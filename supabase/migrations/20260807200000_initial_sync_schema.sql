-- Nasyad remote schema (Supabase Postgres)
-- Mirrors local Drift tables + user_id for RLS.

create table if not exists public.devices (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  parent_id text null,
  name text not null,
  description text null,
  status text not null default 'active',
  usage_unit text null,
  current_usage integer not null default 0,
  schedule_type text null,
  interval_value integer null,
  interval_unit text null,
  fixed_due_at timestamptz null,
  last_maintained_at timestamptz null,
  usage_at_last_maintenance integer not null default 0,
  created_at timestamptz not null,
  updated_at timestamptz not null
);

create table if not exists public.device_logs (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  device_id text not null references public.devices (id) on delete cascade,
  date timestamptz not null,
  notes text null,
  kind text not null default 'maintenanceDone',
  usage_value integer null,
  usage_unit text null,
  created_at timestamptz not null
);

create table if not exists public.birthdays (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  birth_month integer not null,
  birth_day integer not null,
  calendar_system text not null default 'gregorian',
  created_at timestamptz not null,
  updated_at timestamptz not null
);

create index if not exists devices_user_updated_idx
  on public.devices (user_id, updated_at);
create index if not exists device_logs_user_created_idx
  on public.device_logs (user_id, created_at);
create index if not exists birthdays_user_updated_idx
  on public.birthdays (user_id, updated_at);

alter table public.devices enable row level security;
alter table public.device_logs enable row level security;
alter table public.birthdays enable row level security;

create policy "devices_select_own"
  on public.devices for select using (auth.uid() = user_id);
create policy "devices_insert_own"
  on public.devices for insert with check (auth.uid() = user_id);
create policy "devices_update_own"
  on public.devices for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "devices_delete_own"
  on public.devices for delete using (auth.uid() = user_id);

create policy "device_logs_select_own"
  on public.device_logs for select using (auth.uid() = user_id);
create policy "device_logs_insert_own"
  on public.device_logs for insert with check (auth.uid() = user_id);
create policy "device_logs_update_own"
  on public.device_logs for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "device_logs_delete_own"
  on public.device_logs for delete using (auth.uid() = user_id);

create policy "birthdays_select_own"
  on public.birthdays for select using (auth.uid() = user_id);
create policy "birthdays_insert_own"
  on public.birthdays for insert with check (auth.uid() = user_id);
create policy "birthdays_update_own"
  on public.birthdays for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "birthdays_delete_own"
  on public.birthdays for delete using (auth.uid() = user_id);
