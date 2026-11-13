-- ============================================================
-- noah-kaigo / 01_schema.sql   ※ 1番目に実行
-- Supabase ▸ SQL Editor ▸ New query に全文を貼り付けて Run
-- 対象プロジェクト: klwmsyxxtmhxrsgstpen（他アプリと共用。テーブル名は noah_ で分離）
-- ------------------------------------------------------------
-- 列名は index.html の subToRow / memToRow に合わせています。変更しないでください。
-- RLS（アクセス制御）は 02_rls.sql で設定します。先にこちらを実行。
-- ============================================================

-- ------------------------------------------------------------
-- noah_submissions : 候補者の回答（1回の受検 = 1行）
--   同じ人の再受検は candidate_key（氏名を正規化した値）でまとめて表示する
-- ------------------------------------------------------------
create table if not exists public.noah_submissions (
  id            text primary key,
  name          text not null,
  contact       text default '',
  lang          text default '',                 -- my / id
  candidate_key text default '',                 -- 氏名の正規化キー（再受検のまとめ用）
  answers       jsonb not null default '{}'::jsonb,  -- {q1:0, q2:3, ...} 選択肢の添字
  timing        jsonb default '{}'::jsonb,       -- {q1:4.2, ...} 回答秒数
  notes         text default '',                 -- 担当者メモ
  submitted_at  timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  updated_by    text default '',
  deleted       boolean not null default false   -- 論理削除
);
create index if not exists noah_submissions_key_idx on public.noah_submissions (candidate_key);
create index if not exists noah_submissions_submitted_idx on public.noah_submissions (submitted_at desc);

-- ------------------------------------------------------------
-- noah_members : 既存メンバー（相性計算の基準。在籍者の受検結果から登録できる）
-- ------------------------------------------------------------
create table if not exists public.noah_members (
  id                   text primary key,
  name                 text not null,
  company              text default 'ノアコンツェル様',
  is_benchmark         boolean not null default false,
  traits               jsonb default '{}'::jsonb,   -- 14特性 0-10
  risks                jsonb default '{}'::jsonb,   -- 6注意点 0-10
  drives               jsonb default '{}'::jsonb,   -- 4動機 %
  fit                  jsonb default '{}'::jsonb,   -- 7項目 0-10
  notes                text default '',
  source_submission_id text,                        -- 受検結果から登録した場合の元ID
  updated_at           timestamptz not null default now(),
  updated_by           text default '',
  deleted              boolean not null default false
);

-- 完了。続けて 02_rls.sql を実行してください。
