create or replace function public.gw_get_all(p_password text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  result jsonb;
begin
  if not public.gw_password_ok(p_password) then
    raise exception 'invalid password';
  end if;
  select coalesce(jsonb_object_agg(s.key, s.value), '{}'::jsonb)
  into result
  from public.gw_shared_state s;
  return result;
end;
$$;

revoke all on function public.gw_get_all(text) from public;
grant execute on function public.gw_get_all(text) to anon, authenticated;

