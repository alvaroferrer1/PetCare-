create extension if not exists "pgcrypto";

create type pet_species as enum ('dog', 'cat');
create type care_event_type as enum (
  'vaccine',
  'vet_visit',
  'medication',
  'food',
  'grooming',
  'deworming',
  'other'
);
create type care_event_status as enum ('pending', 'completed', 'cancelled');
create type food_safety_level as enum ('safe', 'caution', 'toxic', 'unknown');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text default '',
  phone text default '',
  preferred_language text default 'es',
  emergency_vet_name text default '',
  emergency_vet_phone text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  species pet_species not null,
  breed text default '',
  birth_date date,
  weight numeric(5,2),
  photo_url text,
  notes text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.care_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  pet_id uuid not null references public.pets(id) on delete cascade,
  type care_event_type not null,
  title text not null,
  description text default '',
  event_date timestamptz not null,
  status care_event_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.health_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  pet_id uuid not null references public.pets(id) on delete cascade,
  symptoms text default '',
  mood text default '',
  appetite text default '',
  energy_level integer not null default 3 check (energy_level between 1 and 5),
  notes text default '',
  note_date timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.food_safety_items (
  id uuid primary key default gen_random_uuid(),
  food_name text not null,
  normalized_name text not null,
  species pet_species not null,
  safety_level food_safety_level not null,
  description text not null,
  source text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(normalized_name, species)
);

create table if not exists public.ai_summaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  pet_id uuid not null references public.pets(id) on delete cascade,
  summary jsonb not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.care_events enable row level security;
alter table public.health_notes enable row level security;
alter table public.food_safety_items enable row level security;
alter table public.ai_summaries enable row level security;

create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "pets_select_own" on public.pets
  for select using (auth.uid() = user_id);
create policy "pets_insert_own" on public.pets
  for insert with check (auth.uid() = user_id);
create policy "pets_update_own" on public.pets
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "pets_delete_own" on public.pets
  for delete using (auth.uid() = user_id);

create policy "care_events_select_own" on public.care_events
  for select using (auth.uid() = user_id);
create policy "care_events_insert_own" on public.care_events
  for insert with check (auth.uid() = user_id);
create policy "care_events_update_own" on public.care_events
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "care_events_delete_own" on public.care_events
  for delete using (auth.uid() = user_id);

create policy "health_notes_select_own" on public.health_notes
  for select using (auth.uid() = user_id);
create policy "health_notes_insert_own" on public.health_notes
  for insert with check (auth.uid() = user_id);
create policy "health_notes_update_own" on public.health_notes
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "health_notes_delete_own" on public.health_notes
  for delete using (auth.uid() = user_id);

create policy "food_safety_read_authenticated" on public.food_safety_items
  for select to authenticated using (true);

create policy "ai_summaries_select_own" on public.ai_summaries
  for select using (auth.uid() = user_id);
create policy "ai_summaries_insert_own" on public.ai_summaries
  for insert with check (auth.uid() = user_id);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger pets_set_updated_at
before update on public.pets
for each row execute function public.set_updated_at();

create trigger care_events_set_updated_at
before update on public.care_events
for each row execute function public.set_updated_at();

create trigger health_notes_set_updated_at
before update on public.health_notes
for each row execute function public.set_updated_at();

create trigger food_safety_items_set_updated_at
before update on public.food_safety_items
for each row execute function public.set_updated_at();
