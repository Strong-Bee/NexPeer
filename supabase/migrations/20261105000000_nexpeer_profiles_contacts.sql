create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  display_name text not null,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_username_format check (username ~ '^[a-z0-9_]{3,24}$')
);
create unique index if not exists profiles_username_lower_unique on public.profiles (lower(username));
create table if not exists public.contacts (
  owner_id uuid not null references public.profiles(id) on delete cascade,
  contact_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint contacts_not_self check (owner_id <> contact_id),
  primary key (owner_id, contact_id)
);
create index if not exists contacts_contact_id_idx on public.contacts(contact_id);
alter table public.profiles enable row level security;
alter table public.contacts enable row level security;
drop policy if exists "Authenticated users can discover profiles" on public.profiles;
create policy "Authenticated users can discover profiles" on public.profiles for select to authenticated using (true);
drop policy if exists "Users can create their own profile" on public.profiles;
create policy "Users can create their own profile" on public.profiles for insert to authenticated with check ((select auth.uid()) = id);
drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
drop policy if exists "Users can read their own contacts" on public.contacts;
create policy "Users can read their own contacts" on public.contacts for select to authenticated using ((select auth.uid()) = owner_id);
drop policy if exists "Users can add their own contacts" on public.contacts;
create policy "Users can add their own contacts" on public.contacts for insert to authenticated with check ((select auth.uid()) = owner_id and owner_id <> contact_id);
drop policy if exists "Users can remove their own contacts" on public.contacts;
create policy "Users can remove their own contacts" on public.contacts for delete to authenticated using ((select auth.uid()) = owner_id);
grant select, insert, update on public.profiles to authenticated;
grant select, insert, delete on public.contacts to authenticated;
do $$ begin
  alter publication supabase_realtime add table public.contacts;
exception when duplicate_object then null; when undefined_object then null;
end $$;
