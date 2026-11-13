-- ============================================================
-- noah-kaigo / 03_admins.sql   ※ 02_rls.sql の後に実行
-- ------------------------------------------------------------
-- このSupabaseプロジェクトは他アプリ（ssw-driver-tracker 等）と共用のため、
-- 「ログイン済み（authenticated）」だけでは他アプリの利用者も noah_ テーブルを
-- 読めてしまう。noah_admins に登録したメールのアカウントだけに絞る。
--
-- 管理者を追加するとき: 下の insert に行を足して再実行する
--   （Authentication ▸ Users でアカウントを作ったうえで、同じメールをここに登録）
-- ============================================================

create table if not exists public.noah_admins (
  email text primary key,
  note  text default ''
);
alter table public.noah_admins enable row level security;
revoke all on public.noah_admins from anon, authenticated;

insert into public.noah_admins (email, note) values
  ('ishibashi@ystalent.co.jp', '管理用（共有PIN）'),
  ('seiji.ishibashi@ystalent.co.jp', '石橋')
on conflict (email) do nothing;

-- 判定関数（SECURITY DEFINER で noah_admins を読む。anon からは呼べない）
create or replace function public.noah_is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.noah_admins where lower(email) = lower(coalesce(auth.jwt()->>'email','')));
$$;
revoke execute on function public.noah_is_admin() from public;
revoke execute on function public.noah_is_admin() from anon;
grant  execute on function public.noah_is_admin() to authenticated, service_role;

-- 管理者ポリシーを「ログイン済み」から「noah_admins に登録済み」へ置き換え
drop policy if exists noah_sub_auth_all on public.noah_submissions;
create policy noah_sub_auth_all on public.noah_submissions
  for all to authenticated
  using ( public.noah_is_admin() ) with check ( public.noah_is_admin() );

drop policy if exists noah_mem_auth_all on public.noah_members;
create policy noah_mem_auth_all on public.noah_members
  for all to authenticated
  using ( public.noah_is_admin() ) with check ( public.noah_is_admin() );
