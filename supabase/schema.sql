create extension if not exists "pgcrypto";

do $$
begin
  create type pet_species as enum ('dog', 'cat');
exception
  when duplicate_object then null;
end
$$;

do $$
begin
  create type care_event_type as enum (
    'vaccine',
    'vet_visit',
    'medication',
    'food',
    'grooming',
    'deworming',
    'other'
  );
exception
  when duplicate_object then null;
end
$$;

do $$
begin
  create type care_event_status as enum ('pending', 'completed', 'cancelled');
exception
  when duplicate_object then null;
end
$$;

do $$
begin
  create type food_safety_level as enum ('safe', 'caution', 'toxic', 'unknown');
exception
  when duplicate_object then null;
end
$$;

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
  allergies text default '',
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

create table if not exists public.product_checks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  species pet_species not null,
  query text not null,
  product_name text not null,
  ingredients text not null,
  barcode text default '',
  image_url text default '',
  matched_risks jsonb not null default '[]'::jsonb,
  source text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.vet_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  clinic text default '',
  phone text default '',
  notes text default '',
  is_emergency boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pet_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  pet_id uuid not null references public.pets(id) on delete cascade,
  title text not null,
  document_type text not null default 'other',
  file_url text default '',
  notes text default '',
  created_at timestamptz not null default now()
);

create table if not exists public.weight_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  pet_id uuid not null references public.pets(id) on delete cascade,
  weight numeric(5,2) not null,
  logged_at timestamptz not null default now(),
  notes text default '',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.care_events enable row level security;
alter table public.health_notes enable row level security;
alter table public.food_safety_items enable row level security;
alter table public.ai_summaries enable row level security;
alter table public.product_checks enable row level security;
alter table public.vet_contacts enable row level security;
alter table public.pet_documents enable row level security;
alter table public.weight_logs enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "pets_select_own" on public.pets;
drop policy if exists "pets_insert_own" on public.pets;
drop policy if exists "pets_update_own" on public.pets;
drop policy if exists "pets_delete_own" on public.pets;
drop policy if exists "care_events_select_own" on public.care_events;
drop policy if exists "care_events_insert_own" on public.care_events;
drop policy if exists "care_events_update_own" on public.care_events;
drop policy if exists "care_events_delete_own" on public.care_events;
drop policy if exists "health_notes_select_own" on public.health_notes;
drop policy if exists "health_notes_insert_own" on public.health_notes;
drop policy if exists "health_notes_update_own" on public.health_notes;
drop policy if exists "health_notes_delete_own" on public.health_notes;
drop policy if exists "food_safety_read_authenticated" on public.food_safety_items;
drop policy if exists "ai_summaries_select_own" on public.ai_summaries;
drop policy if exists "ai_summaries_insert_own" on public.ai_summaries;
drop policy if exists "product_checks_select_own" on public.product_checks;
drop policy if exists "product_checks_insert_own" on public.product_checks;
drop policy if exists "vet_contacts_select_own" on public.vet_contacts;
drop policy if exists "vet_contacts_insert_own" on public.vet_contacts;
drop policy if exists "vet_contacts_update_own" on public.vet_contacts;
drop policy if exists "vet_contacts_delete_own" on public.vet_contacts;
drop policy if exists "pet_documents_select_own" on public.pet_documents;
drop policy if exists "pet_documents_insert_own" on public.pet_documents;
drop policy if exists "pet_documents_delete_own" on public.pet_documents;
drop policy if exists "weight_logs_select_own" on public.weight_logs;
drop policy if exists "weight_logs_insert_own" on public.weight_logs;
drop policy if exists "weight_logs_delete_own" on public.weight_logs;

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

create policy "product_checks_select_own" on public.product_checks
  for select using (auth.uid() = user_id);
create policy "product_checks_insert_own" on public.product_checks
  for insert with check (auth.uid() = user_id);

create policy "vet_contacts_select_own" on public.vet_contacts
  for select using (auth.uid() = user_id);
create policy "vet_contacts_insert_own" on public.vet_contacts
  for insert with check (auth.uid() = user_id);
create policy "vet_contacts_update_own" on public.vet_contacts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "vet_contacts_delete_own" on public.vet_contacts
  for delete using (auth.uid() = user_id);

create policy "pet_documents_select_own" on public.pet_documents
  for select using (auth.uid() = user_id);
create policy "pet_documents_insert_own" on public.pet_documents
  for insert with check (auth.uid() = user_id);
create policy "pet_documents_delete_own" on public.pet_documents
  for delete using (auth.uid() = user_id);

create policy "weight_logs_select_own" on public.weight_logs
  for select using (auth.uid() = user_id);
create policy "weight_logs_insert_own" on public.weight_logs
  for insert with check (auth.uid() = user_id);
create policy "weight_logs_delete_own" on public.weight_logs
  for delete using (auth.uid() = user_id);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists pets_set_updated_at on public.pets;
create trigger pets_set_updated_at
before update on public.pets
for each row execute function public.set_updated_at();

drop trigger if exists care_events_set_updated_at on public.care_events;
create trigger care_events_set_updated_at
before update on public.care_events
for each row execute function public.set_updated_at();

drop trigger if exists health_notes_set_updated_at on public.health_notes;
create trigger health_notes_set_updated_at
before update on public.health_notes
for each row execute function public.set_updated_at();

drop trigger if exists food_safety_items_set_updated_at on public.food_safety_items;
create trigger food_safety_items_set_updated_at
before update on public.food_safety_items
for each row execute function public.set_updated_at();

drop trigger if exists vet_contacts_set_updated_at on public.vet_contacts;
create trigger vet_contacts_set_updated_at
before update on public.vet_contacts
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  )
  on conflict (id) do update set
    email = excluded.email,
    full_name = excluded.full_name,
    updated_at = now();
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
