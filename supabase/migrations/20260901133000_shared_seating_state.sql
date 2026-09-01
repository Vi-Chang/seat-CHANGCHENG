create extension if not exists pgcrypto with schema extensions;

create table if not exists public.gw_config (
  singleton boolean primary key default true check (singleton),
  password_hash text not null
);

insert into public.gw_config (singleton, password_hash)
values (true, '$2a$12$0/Bo5QGFbnOPOF21PyrYmeae3/6.tRFMbpzTE35LBbnsDIuwRBdne')
on conflict (singleton) do update set password_hash = excluded.password_hash;

create table if not exists public.gw_shared_state (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

alter table public.gw_config enable row level security;
alter table public.gw_shared_state enable row level security;

revoke all on table public.gw_config from anon, authenticated;
revoke all on table public.gw_shared_state from anon, authenticated;

create or replace function public.gw_password_ok(p_password text)
returns boolean
language sql
stable
security definer
set search_path = public, extensions
as $$
  select exists (
    select 1 from public.gw_config c
    where c.singleton = true
      and extensions.crypt(p_password, c.password_hash) = c.password_hash
  );
$$;

create or replace function public.gw_auth(p_password text)
returns boolean
language sql
stable
security definer
set search_path = public, extensions
as $$
  select public.gw_password_ok(p_password);
$$;

create or replace function public.gw_get_value(p_password text, p_key text)
returns text
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  result text;
begin
  if not public.gw_password_ok(p_password) then
    raise exception 'invalid password';
  end if;
  select s.value into result from public.gw_shared_state s where s.key = p_key;
  return result;
end;
$$;

create or replace function public.gw_set_value(p_password text, p_key text, p_value text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  if not public.gw_password_ok(p_password) then
    raise exception 'invalid password';
  end if;
  if p_key not in ('gw-roster', 'gw-history', 'gw-saved', 'gw-weekly') then
    raise exception 'invalid key';
  end if;
  insert into public.gw_shared_state (key, value, updated_at)
  values (p_key, p_value, now())
  on conflict (key) do update set value = excluded.value, updated_at = now();
  return true;
end;
$$;

create or replace function public.gw_delete_value(p_password text, p_key text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  if not public.gw_password_ok(p_password) then
    raise exception 'invalid password';
  end if;
  delete from public.gw_shared_state where key = p_key;
  return true;
end;
$$;

revoke all on function public.gw_password_ok(text) from public;
revoke all on function public.gw_auth(text) from public;
revoke all on function public.gw_get_value(text, text) from public;
revoke all on function public.gw_set_value(text, text, text) from public;
revoke all on function public.gw_delete_value(text, text) from public;

grant execute on function public.gw_auth(text) to anon, authenticated;
grant execute on function public.gw_get_value(text, text) to anon, authenticated;
grant execute on function public.gw_set_value(text, text, text) to anon, authenticated;
grant execute on function public.gw_delete_value(text, text) to anon, authenticated;

