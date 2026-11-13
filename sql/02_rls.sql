-- ============================================================
-- noah-kaigo / 02_rls.sql   ※ 01_schema.sql の後に実行
-- Supabase ▸ SQL Editor ▸ New query に全文を貼り付けて Run
-- ------------------------------------------------------------
-- アクセス範囲
--   候補者（未ログイン = anon）: noah_submissions への INSERT のみ。読み取り・更新・削除は不可
--   管理者（ログイン済 = authenticated）: 両テーブルの読み書き
--
-- 管理者アカウントは Supabase ▸ Authentication ▸ Users ▸ Add user で作成する
-- （メール＋パスワード。パスワードを「PIN」として担当者に共有）。
-- 公開サインアップは使わないので、Authentication ▸ Providers ▸ Email の
-- 「Allow new users to sign up」は OFF のままにしておく（他アプリと共通設定）。
-- ============================================================

alter table public.noah_submissions enable row level security;
alter table public.noah_members     enable row level security;

-- 既存ポリシーの掃除（再実行できるように）
drop policy if exists noah_sub_anon_insert   on public.noah_submissions;
drop policy if exists noah_sub_auth_all      on public.noah_submissions;
drop policy if exists noah_mem_auth_all      on public.noah_members;

-- 1) 候補者: 回答の新規登録だけ許可（deleted=false の行のみ）
--    返り値を要求しない insert（return=minimal）で呼ぶため SELECT 権限は不要
create policy noah_sub_anon_insert on public.noah_submissions
  for insert to anon
  with check ( deleted = false );

-- 2) 管理者: 全件読み書き
create policy noah_sub_auth_all on public.noah_submissions
  for all to authenticated
  using (true) with check (true);

create policy noah_mem_auth_all on public.noah_members
  for all to authenticated
  using (true) with check (true);

-- 権限付与（RLS はこの上で効く）
revoke all on public.noah_submissions, public.noah_members from anon, authenticated;
grant insert on public.noah_submissions to anon;
grant select, insert, update, delete on public.noah_submissions, public.noah_members to authenticated;

-- ------------------------------------------------------------
-- 確認（実行後にブラウザまたは curl で）
--   未ログインで一覧取得 → 権限エラーか空になること:
--   curl -s "https://klwmsyxxtmhxrsgstpen.supabase.co/rest/v1/noah_submissions?select=id" -H "apikey: <anon key>"
-- ------------------------------------------------------------
