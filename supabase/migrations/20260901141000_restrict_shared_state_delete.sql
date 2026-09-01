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
  if p_key not in ('gw-roster', 'gw-history', 'gw-saved', 'gw-weekly') then
    raise exception 'invalid key';
  end if;
  delete from public.gw_shared_state where key = p_key;
  return true;
end;
$$;

revoke all on function public.gw_delete_value(text, text) from public;
grant execute on function public.gw_delete_value(text, text) to anon, authenticated;
